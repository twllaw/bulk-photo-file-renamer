[CmdletBinding()]
Param(
	[Parameter(Mandatory=$True)]
	[string[]]$folders,
	
	[string]$rename
)

function GetFileAttributeNumber($folder, $matchingAttrName)
{
	$objShell = New-Object -ComObject Shell.Application
	$attrList = @{} 
	$objFolder = $objShell.namespace($folder)

	# Write-Host $folder
	# Write-Host "Matching: $matchingAttrName"
	
	for ($attr = 0; $attr -le 310; $attr++) 
	{ 
		$attrName = $objFolder.GetDetailsOf($objFolder.items, $attr)
		if ($attrName -eq $matchingAttrName)
		{
			return $attr
		}
	}
}

function AddZeroIfOneDigitOnly($value)
{
	if ("$value".Length -lt 2)
	{
		return "0$value"
	}
	return "$value"
}

function GetNewFileName($date, $curFileName)
{	
	$year = (Get-Date $date).Year
	$month = AddZeroIfOneDigitOnly (Get-Date $date).Month
	$day = AddZeroIfOneDigitOnly (Get-Date $date).Day
	$hour = AddZeroIfOneDigitOnly (Get-Date $date).Hour
	$min = AddZeroIfOneDigitOnly (Get-Date $date).Minute
	#Write-Host "$day".Length
	
	$newFileName = "$year" + "$month" + "$day" + "-" + "$hour" + "$min" + "_" + "$curFile"
	
	return $newFileName
}

Write-Host "`nFolders to process:"
foreach ($folder in $folders)
{
	Write-Host "* $folder"
}
Write-Host "`n"

foreach ($folder in $folders)
{
	if (Test-Path $folder) {
		
		Write-Host "Current folder: $folder`n"
		$folderPathIncFiles = $folder + "\*"
		$photoFiles = Get-ChildItem $folderPathIncFiles -Include "*.jpg", "*.mov"
		
		foreach ($photoPath in $photoFiles)
		{
			$shell = New-Object -ComObject Shell.Application
			
			$curFolder = Split-Path $photoPath
			$curFile = Split-Path $photoPath -Leaf
			Write-Host "File: $curFile"
			$shellfolder = $shell.Namespace($curFolder)
			$shellfile = $shellfolder.ParseName($curFile)
			
			$dateTakenAttrNum = GetFileAttributeNumber $curFolder "Date taken"
			$dateModifiedAttrNum = GetFileAttributeNumber $curFolder "Date modified"	
			
			$dateTaken = $shellfolder.GetDetailsOf($shellfile, $dateTakenAttrNum)
			
			<# For some reason certain strange characters gets returned as part of 'Date taken' value, 
				so it cannot be processed as a proper 'date' later on. 
				The code below removes those troublesome characters.
			#>
			$unknownCharList = @()		
			for ($i = 0; $i -lt $dateTaken.Length; $i++)
			{
				try 
				{
					$validChar = [byte][char]$dateTaken[$i]
					# Write-Host "$validChar"
				}
				catch 
				{
					$unknownCharList += $dateTaken[$i]
				}
				# Write-Host "$dateTaken[$i]"
			}
			# Write-Host "WTF Value: $unknownCharList"
			
			foreach ($unknownChar in $unknownCharList)
			{
				#Write-Host "wtfVal: $unknownChar"
				$dateTaken = $dateTaken -replace "$unknownChar"
			}
				
			if ($dateTaken)
			{
				Write-Host "Date Taken: $dateTaken"
				$newFileName = GetNewFileName $dateTaken $curFile
			}
			else # Use 'Date modified' if 'Date taken' doesn't exist
			{
				$dateModified = $shellfolder.GetDetailsOf($shellfile, $dateModifiedAttrNum)
				
				if (-Not $dateModified)
				{
					continue
				}
				Write-Host "Date Modified: $dateModified"				
				$newFileName = GetNewFileName $dateModified $curFile
			}
			
			if ($rename -eq "rename")
			{
				Rename-Item $photoPath $newFileName
				Write-Host "File has been renamed to: $newFileName `n"
			}
			else 
			{
				Write-Host "New file name will be: $newFileName `n"
			}
		}
	}
	else {
		Write-Host "`n$folder is not a valid directory/folder`n"
	}
}