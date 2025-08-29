<#
Function name: StoreRecord
Description: Stores a record in a table of the database 
Function calls: -
Input: $Record, $ColumnsArray, $DBPath, $Table
Output: -
Usage:
	StoreRecord $Record $ColumnsArray $DBPath $Table
#>
function StoreRecord {
   param (
   [Parameter(Mandatory=$true)] [string[]] $Record,
   [Parameter(Mandatory=$true)] [string[]] $ColumnsArray,
   [Parameter(Mandatory=$true)] [string] $DBPath,
   [Parameter(Mandatory=$true)] [string] $Table
   )

$Database = [LiteDB.LiteDatabase]::new($DBPath)
$Collection = $Database.GetCollection($Table,[LiteDB.BsonAutoId]::Int64)
 
$BsonDocument = [LiteDB.BsonDocument]::new()   
$i=0
while($i -lt $ColumnsArray.length){
	$Column = "##not_valid_column##"
	$Value = "-"
	$Column = $ColumnsArray[$i]
	$Value = $Record[$i]
	if($Column -ne "##not_valid_column##"){
		$BsonDocument[$Column] = $Value
	}
$i++
}
	
$null = $Collection.Insert($BsonDocument)
$Database.Dispose()
	
return
}

<#
Function name: RecordExists 
Description: Checks if an entry is present in a table of the database 
Function calls: -
Input: $Column, $Entry, $DBPath, $Table
Output: $true/$false
Usage:
	RecordExists $Column $Entry $DBPath $Table
#>
function RecordExists {
   param (
   [Parameter(Mandatory=$true)] [string] $Column,
   [Parameter(Mandatory=$true)] [string] $Entry,
   [Parameter(Mandatory=$true)] [string] $DBPath,
   [Parameter(Mandatory=$true)] [string] $Table
   )

$Database = [LiteDB.LiteDatabase]::new($DBPath)
$Collection = $Database.GetCollection($Table,[LiteDB.BsonAutoId]::Int64)
   
$Query = $Column+" ="+ "'"+$Entry+"'" 
$Result = $Collection.Find($Query) 
   
if (($Result |Out-String) -eq "") {
	$Database.Dispose()
	return $false
	}
else {
	$Database.Dispose()
	return $true
	}

$Database.Dispose()
		
return $false
}

<#
Function name: UpdateRecord 
Description: Updates a record in a table of the database 
Function calls: -
Input: $Column, $Entry, $Record, $ColumnsArray, $DBPath, $Table
Output: -
Usage:
	UpdateRecord $Column $Entry $Record $ColumnsArray $DBPath $Table
#>
function UpdateRecord {
   param (
   [Parameter(Mandatory=$true)] [string] $Column,
   [Parameter(Mandatory=$true)] [string] $Entry,
   [Parameter(Mandatory=$true)] [string[]] $Record,
   [Parameter(Mandatory=$true)] [string[]] $ColumnsArray,
   [Parameter(Mandatory=$true)] [string] $DBPath,
   [Parameter(Mandatory=$true)] [string] $Table
   )

$DBArg = "Filename='"+$DBPath+"';ReadOnly='$false'"
$Database = [LiteDB.LiteDatabase]::new($DBArg)
$Collection = $Database.GetCollection($Table,[LiteDB.BsonAutoId]::Int64)

$Query = $Column+" ="+ "'"+$Entry+"'" 
$Find = $Collection.Find($Query)
  
if( ($Find |Out-String) -ne ""  ) {
	$id = ($Find.Value[0]).RawValue
	$Result = $Collection.FindById($id)

	$i=0
	while($i -lt $ColumnsArray.length){
		$Column = "##not_valid_column##"
		$Value = "-"
		$Column = $ColumnsArray[$i]
		$Value = $Record[$i]
		if($Column -ne "##not_valid_column##"){
			$Result[$Column] = $Value
		}
	$i++
	}
}

try {
	$null = $Collection.Update($Result)
	} catch { }
  
$Database.Dispose()

return
}

<#
Function name: DeleteRecord 
Description: Deletes a record in a table of the database 
Function calls: -
Input: $Column, $Entry, $DBPath, $Table
Output: -
Usage:
	DeleteRecord $Column $Entry $DBPath $Table
#>
function DeleteRecord {
    param (
        [Parameter(Mandatory=$true)] [string] $Column,
        [Parameter(Mandatory=$true)] [string] $Entry,
        [Parameter(Mandatory=$true)] [string] $DBPath,
        [Parameter(Mandatory=$true)] [string] $Table
    )

$DBArg = "Filename='" + $DBPath + "';ReadOnly='false'"
$Database = [LiteDB.LiteDatabase]::new($DBArg)
$Collection = $Database.GetCollection($Table, [LiteDB.BsonAutoId]::Int64)

try {
    $Query = $Column + " = '" + $Entry + "'"
    $Find   = $Collection.FindOne($Query)

    if ($null -ne $Find) {
        $Collection.Delete($Find["_id"]) | Out-Null
		} 
    } catch { }
 
$Database.Dispose()
return
}

<#
Function name: FetchAllRecords
Description: Takes all records from a table of the database 
Function calls: -
Input: $ColumnsArray, $DBPath, $Table
Output: $AllRecords
Usage:
	$AllRecords = FetchAllRecords $ColumnsArray $DBPath $Table
#>
function FetchAllRecords {
    param (
        [Parameter(Mandatory=$true)] [string[]] $ColumnsArray,
        [Parameter(Mandatory=$true)] [string] $DBPath,
        [Parameter(Mandatory=$true)] [string] $Table
    )

$Database = [LiteDB.LiteDatabase]::new($DBPath)
$Collection = $Database.GetCollection($Table, [LiteDB.BsonAutoId]::Int64)

$FetchedRecords = $Collection.FindAll()

$AllRecords = $FetchedRecords | ForEach-Object {
    $obj = @{}
    $obj["_id"] = $_["_id"].ToString()
   
    foreach ($col in $ColumnsArray) {
        if ($_.ContainsKey($col)) {
            $obj[$col] = $_[$col]
        } else {
            $obj[$col] = $null
        }
    }
    
    [PSCustomObject]$obj
}

$Database.Dispose()

return $AllRecords
}

<#
Function name: QueryDB
Description: Retrieves records in a table of the database by input query  
Function calls: -
Input: $Query, 
Output: $DBRecords
Usage:
	$AllRecords = QueryDB $Query $DBPath $Table
#>
function QueryDB {
   param (
   [Parameter(Mandatory=$true)] [string] $Query,
   [Parameter(Mandatory=$true)] [string] $DBPath,
   [Parameter(Mandatory=$true)] [string] $Table
   )

$Database = [LiteDB.LiteDatabase]::new($DBPath)
$Collection = $Database.GetCollection($Table, [LiteDB.BsonAutoId]::Int64)

$FetchedRecords = $Collection.Find($Query)

$AllRecords = $FetchedRecords | ForEach-Object {
    $obj = @{}
    $obj["_id"] = $_["_id"].ToString()
   
    foreach ($col in $FetchedRecords.keys) {
        if ($_.ContainsKey($col)) {
            $obj[$col] = $_[$col]
        } else {
            $obj[$col] = $null
        }
    }
    
    [PSCustomObject]$obj
}

$Database.Dispose()

return $AllRecords
}

<#
Function name: ExportAllRecordsToCSV
Description: Exports all records from a table of the database to a CSV file  
Function calls: -
Input: $ColumnsArray, $DBPath, $Table, $CSVPath
Output:
Usage:
	ExportAllRecordsToCsv $ColumnsArray $DBPath $Table $CSVPath
#>
function ExportAllRecordsToCsv {
    param (
        [Parameter(Mandatory=$true)] [string[]] $ColumnsArray,
        [Parameter(Mandatory=$true)] [string] $DBPath,
        [Parameter(Mandatory=$true)] [string] $Table,
        [Parameter(Mandatory=$true)] [string] $CsvPath
    )

$Database = [LiteDB.LiteDatabase]::new($DBPath)
$Collection = $Database.GetCollection($Table, [LiteDB.BsonAutoId]::Int64)

try {
	$FetchedRecords = $Collection.FindAll()
    $AllRecords = $FetchedRecords | ForEach-Object {
		$Objects = @{}
  
		foreach ($column in $ColumnsArray) {
			$Objects[$column.replace('"','')] = $_[$column.replace('"',"")]
			}
	
        [PSCustomObject] $Objects
		}
} catch { }	

$Database.Dispose()

$ColumnsArray -join ',' | Out-File $CsvPath -Encoding UTF8
foreach ($rec in $AllRecords) {
	$Values = $ColumnsArray | ForEach-Object { $rec.$_ }
    ($Values -join ',') | Add-Content $CsvPath -Encoding UTF8
}

return
}