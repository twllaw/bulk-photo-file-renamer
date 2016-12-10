$folder = "D:\Pictures\TestPhotoRenaming"
$objShell = New-Object -ComObject Shell.Application
$attrList = @{} 
$objFolder = $objShell.namespace($folder)

for ($attr = 0 ; $attr  -le 310; $attr++) 
{ 
    $attrName = $objFolder.GetDetailsOf($objFolder.items, $attr) 
    if ( $attrName -and ( -not $attrList.Contains($attrName) )) 
    {  
        $attrList.add( $attrName, $attr )  
    }
	
	echo "$attr is $attrName"
}

<#
0 is Name
1 is Size
2 is Item type
3 is Date modified
4 is Date created
5 is Date accessed
6 is Attributes
7 is Offline status
8 is Availability
9 is Perceived type
10 is Owner
11 is Kind
12 is Date taken
#>