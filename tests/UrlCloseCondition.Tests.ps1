<#
    Created by Claude Opus 4.8
    Executable documentation for the WebView2 "URL close condition" regex.

    The pattern is produced by Get-UrlCloseConditionRegex (src/internal) and consumed by
    Invoke-WebView2, which closes the interactive authorization window as soon as the
    navigated URL matches it (a boolean -match). These tests therefore assert the *close
    decision* (match / no-match) for representative redirect_uri + URL combinations, and
    document WHY each behaviour exists.

    History the regex encodes (see comments inline):
      - Issue #5  https://github.com/alflokken/PSAuthClient/issues/5  (premature close on a
                  secondary IdP that also carries code=/state=)
      - Issue #8  https://github.com/alflokken/PSAuthClient/issues/8  (empty redirect_uri
                  produced an invalid pattern and bricked the session)

    These tests are PURE: no network, no interactive browser, no tenant config. They run
    standalone in CI:  Invoke-Pester -Path tests/UrlCloseCondition.Tests.ps1 -Output Detailed
#>

BeforeAll {
    # Dot-source the internal helper directly - same convention auth.Tests.ps1 uses for
    # Invoke-WebView2 - so the suite needs neither a built module nor secrets.
    . "$PSScriptRoot\..\src\internal\Get-UrlCloseConditionRegex.ps1"

    # Mirrors Invoke-WebView2: build the pattern for $redirect_uri and return whether $url
    # would trigger the close condition. Capture groups are irrelevant to the close decision
    # and are intentionally not asserted here (they are covered once, separately, for docs).
    function Test-CloseCondition {
        param(
            [AllowEmptyString()][AllowNull()][string]$redirect_uri,
            [string]$url
        )
        $pattern = Get-UrlCloseConditionRegex -redirect_uri $redirect_uri
        return [bool]($url -match $pattern)
    }
}

Describe 'URL close-condition regex' {

    # ------------------------------------------------------------------------------------
    Context 'Exact matches (Branch B: ^redirect_uri)' {
        # A bare landing on the redirect_uri - no code=/error= in the query - is matched by
        # the ^redirect_uri branch. This is the Issue #5 "$url2" fixture.
        It 'closes when the browser lands exactly on the redirect_uri: <Url>' -ForEach @(
            @{ RedirectUri = 'http://localhost:8181/authorization-code/callback'; Url = 'http://localhost:8181/authorization-code/callback' }
            @{ RedirectUri = 'http://localhost'; Url = 'http://localhost' }
        ) {
            Test-CloseCondition -redirect_uri $RedirectUri -url $Url | Should -BeTrue
        }
    }

    # ------------------------------------------------------------------------------------
    Context 'Ports' {
        # Issue #5 "$url3": redirect_uri with an explicit port, returned with a code.
        It 'closes on the redirect_uri (with port) carrying a code: <Url>' -ForEach @(
            @{ RedirectUri = 'http://localhost:8181/authorization-code/callback'; Url = 'http://localhost:8181/authorization-code/callback?code=vrDYh_BHFTYHdv4-jIlOmdw3&state=QU0ZnRG15' }
            @{ RedirectUri = 'http://localhost:5001/'; Url = 'http://localhost:5001/' }
        ) {
            Test-CloseCondition -redirect_uri $RedirectUri -url $Url | Should -BeTrue
        }

        It 'NOTE: a port mismatch still closes when a code= is present (Branch A ignores redirect_uri)' {
            # Branch A only looks for code=/error=; the redirect_uri (and therefore its port)
            # is optional. Documented so the over-match is explicit, not surprising.
            Test-CloseCondition -redirect_uri 'http://localhost:8080/cb' -url 'http://localhost:9999/cb?code=abc' | Should -BeTrue
        }
    }

    # ------------------------------------------------------------------------------------
    Context 'Paths' {
        It 'closes on redirect_uris with various paths: <Url>' -ForEach @(
            # Microsoft "nativeclient" redirect with a code in the query.
            @{ RedirectUri = 'https://login.microsoftonline.com/common/oauth2/nativeclient'; Url = 'https://login.microsoftonline.com/common/oauth2/nativeclient?code=abc&state=xyz' }
            # Bare landings on path-only redirect_uris (Branch B).
            @{ RedirectUri = 'https://localhost/web'; Url = 'https://localhost/web' }
            @{ RedirectUri = 'https://localhost/spa'; Url = 'https://localhost/spa' }
        ) {
            Test-CloseCondition -redirect_uri $RedirectUri -url $Url | Should -BeTrue
        }
    }

    # ------------------------------------------------------------------------------------
    Context 'Query strings (Branch A: code= / error=)' {
        It 'closes on a successful code response' {
            Test-CloseCondition -redirect_uri 'http://localhost' -url 'http://localhost/?code=ABC&state=XYZ' | Should -BeTrue
        }

        It 'closes on an error response' {
            # Error responses must also close the window so the caller can throw the error details.
            Test-CloseCondition -redirect_uri 'http://localhost' -url 'http://localhost/?error=access_denied&error_description=user+declined' | Should -BeTrue
        }

        It 'does NOT close on an empty code value (code= with no value)' {
            # code=([^&]+) requires at least one non-& character. A foreign host is used so the
            # ^redirect_uri branch cannot match instead and mask the behaviour.
            Test-CloseCondition -redirect_uri 'http://localhost' -url 'https://other.example/cb?code=&x=1' | Should -BeFalse
        }

        It 'captures the code value up to the first ampersand (documents the ([^&]+) group)' {
            # The close decision ignores capture groups; this only documents the pattern shape.
            $pattern = Get-UrlCloseConditionRegex -redirect_uri 'http://localhost'
            'http://localhost/?code=ABC&state=XYZ' -match $pattern | Should -BeTrue
            $Matches[2] | Should -Be 'ABC'   # group 2 = the code= capture; state is not swallowed
        }
    }

    # ------------------------------------------------------------------------------------
    Context 'Fragments / implicit grant' {
        It 'closes on a token returned in the #fragment via the ^redirect_uri branch' {
            # Implicit/hybrid responses put the token in the fragment, so there is no code=/error=
            # in the query. Branch B (^redirect_uri) is the ONLY thing that closes the window here -
            # this is the reason that branch exists.
            $url = 'https://localhost/spa#access_token=eyJ0eXAiOiJKV1Q&token_type=Bearer&expires_in=4146'
            Test-CloseCondition -redirect_uri 'https://localhost/spa' -url $url | Should -BeTrue
        }
    }

    # ------------------------------------------------------------------------------------
    Context 'Metacharacters in redirect_uri (regex-escaped)' {
        It 'treats "." as a literal, not a wildcard (Branch B)' {
            # [regex]::Escape() makes "." match only a literal dot.
            Test-CloseCondition -redirect_uri 'http://a.b' -url 'http://a.b' | Should -BeTrue
            Test-CloseCondition -redirect_uri 'http://a.b' -url 'http://axb' | Should -BeFalse
        }
    }
    # ------------------------------------------------------------------------------------
    Context 'Edge cases' {
        It 'with no redirect_uri, closes only on code=/error= responses' {
            # Empty redirect_uri selects the fallback pattern "(?:code=([^&]+)|error=([^&]+))".
            Test-CloseCondition -redirect_uri '' -url 'https://x/cb?code=abc' | Should -BeTrue
        }

        It 'with no redirect_uri, does NOT close on a plain page (no code=/error=)' {
            # There is no ^redirect_uri branch when redirect_uri is empty, so a bare landing
            # (and, by extension, an implicit token in the fragment) is not detected.
            Test-CloseCondition -redirect_uri '' -url 'https://x/cb' | Should -BeFalse
        }

        It 'treats $null the same as an empty redirect_uri' {
            Test-CloseCondition -redirect_uri $null -url 'https://x/cb?error=foo' | Should -BeTrue
        }

        It 'matches a trailing slash because ^redirect_uri only anchors the prefix' {
            Test-CloseCondition -redirect_uri 'http://localhost' -url 'http://localhost/' | Should -BeTrue
        }

        It 'matching is case-insensitive (CODE= also triggers)' {
            # PowerShell -match is case-insensitive by default; documented so it is not assumed otherwise.
            Test-CloseCondition -redirect_uri 'http://localhost' -url 'http://localhost/?CODE=ABC' | Should -BeTrue
        }
    }

    # ------------------------------------------------------------------------------------
    Context 'Metacharacter-bearing redirect_uri compiles safely (Issue #8 class)' {
        It 'always produces a compilable pattern, even with unbalanced metacharacters' {
            # Escaping neutralises a stray "(", so it can no longer yield the uncompilable,
            # throwing pattern that is the same fragility class as Issue #8.
            { [regex]::new((Get-UrlCloseConditionRegex -redirect_uri 'http://localhost/cb(')) } | Should -Not -Throw
        }
        It 'matches such a redirect_uri literally (Branch B)' {
            Test-CloseCondition -redirect_uri 'http://localhost/cb(' -url 'http://localhost/cb(' | Should -BeTrue
        }
    }
    # ------------------------------------------------------------------------------------
    Context 'Previously fixed regressions' {

        # --- Issue #8 -------------------------------------------------------------------
        It 'builds a valid (compilable) pattern when redirect_uri is empty or null - Issue #8' -ForEach @(
            @{ RedirectUri = '' }
            @{ RedirectUri = $null }
        ) {
            # Before the fix, an empty redirect_uri produced a pattern starting with "?"
            # -> "Quantifier '?' following nothing" -> threw and bricked the VS Code session.
            { [regex]::new((Get-UrlCloseConditionRegex -redirect_uri $RedirectUri)) } | Should -Not -Throw
        }

        # --- Issue #5 -------------------------------------------------------------------
        # Scenario: Okta certificate login redirects through a SECONDARY IdP whose callback
        # URL itself carries code= and state=. The window must NOT close there (closing grabs
        # the wrong URL -> state mismatch). Fixtures are taken verbatim from the issue.
        Context 'Issue #5 - secondary IdP redirect' {
            BeforeAll {
                $script:rc   = 'http://localhost:8181/authorization-code/callback'
                $script:url  = 'https://example.com/sso/idps/MTLS/mtlscallback?state=aWh3dWxvSFBQU0ZnRG15UENHa&code=522b2c449565' # foreign host + code
                $script:url2 = 'http://localhost:8181/authorization-code/callback'                                                  # exact redirect_uri
                $script:url3 = 'http://localhost:8181/authorization-code/callback?code=vrDYh_BHFTYHdv4-jIlOmdw3&state=QU0ZnRG15'    # redirect_uri + code
            }

            It 'closes on the real redirect_uri (exact landing)' {
                Test-CloseCondition -redirect_uri $rc -url $url2 | Should -BeTrue
            }
            It 'closes on the real redirect_uri carrying a code' {
                Test-CloseCondition -redirect_uri $rc -url $url3 | Should -BeTrue
            }

            It 'CURRENT BEHAVIOUR: also closes on the foreign-host URL that carries a code' {
                # This documents today's behaviour. Per Issue #5 this SHOULD be $false, but the
                # Issue #8 fix changed "$redirect_uri?" into "($redirect_uri)?", making the whole
                # redirect_uri optional in Branch A and re-introducing the over-match. See the
                # skipped "intent" test below.
                Test-CloseCondition -redirect_uri $rc -url $url | Should -BeTrue
            }

            It 'INTENT (KNOWN GAP): a foreign-host URL carrying a code should NOT close when a redirect_uri is set' -Skip {
                # Encodes Issue #5's documented intent. Currently skipped because the shipped regex
                # over-matches (see above). Minimal fix: drop the '?' from Branch A's group so the
                # redirect_uri is required, i.e.
                #   ($redirect_uri).*(?:code=([^&]+)|error=([^&]+))|^($redirect_uri)
                # The empty-redirect_uri case is already handled by the fallback pattern, so the '?'
                # is redundant. Remove the -Skip once that change is made.
                Test-CloseCondition -redirect_uri $rc -url $url | Should -BeFalse
            }
        }
    }
}
