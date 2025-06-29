---
external help file: PSAuthClient-help.xml
Module Name: PSAuthClient
online version:
schema: 2.0.0
---

# Convert-UnixTime

## SYNOPSIS
Convert UnixTime to DateTime and vice versa.

## SYNTAX

### fromDateTime (Default)
```powershell
Convert-UnixTime [[-date] <DateTime>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### fromEpoch
```powershell
Convert-UnixTime [[-epoch] <Int64>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Convert UnixTime to DateTime and vice versa.

## EXAMPLES

### EXAMPLE 1
```powershell
Get-UnixTime
1706961267
```

### EXAMPLE 2
```powershell
Get-UnixTime -epoch 1728896669
Monday, 14 October 2024 11:04:29
```

## PARAMETERS

### -date
The date to convert to Unix time.
If not specified, the current date and time is used.

```yaml
Type: DateTime
Parameter Sets: fromDateTime
Aliases:

Required: False
Position: 1
Default value: (Get-Date)
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -epoch
Unix epoch to convert to DateTime.

```yaml
Type: Int64
Parameter Sets: fromEpoch
Aliases:

Required: False
Position: 1
Default value: 0
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Int64
### System.DateTime
## NOTES

## RELATED LINKS
