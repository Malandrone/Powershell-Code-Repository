<# DISPLAY DIALOG WINDOW FILE
Description: Displays a dialog window to set an input file path
Input: -
Output: $InputFile
Use:
	$InputFile = DisplayDialogWindowFile
#>
function DisplayDialogWindowFile {
	
   Add-Type -AssemblyName System.Windows.Forms
   $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = [Environment]::GetFolderPath('Desktop') }
   $null = $FileBrowser.ShowDialog()
   $InputFile = $FileBrowser.FileName
   
return $InputFile	
}

<# DISPLAY DIALOG WINDOW FOLDER
Description: Displays a dialog window to set an input folder path
Input:  -
Output: $InputFolder
Use:
	$InputFolder = DisplayDialogWindowFolder
#>
function DisplayDialogWindowFolder {
	
   Add-Type -AssemblyName System.Windows.Forms
   $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
   $null = $FolderBrowser.ShowDialog()
   $InputFolder = $FolderBrowser.SelectedPath
   
return $InputFolder	
}