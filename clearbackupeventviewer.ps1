# powershell

# cleanbackupeventviewer
# Cleaning and backuping event viewer
# By Maulana Muhammad Alghifary
# This script will uploaded to github
# You can do anything you want with this script but you can't sue or police me if something happen when you run this script
# One line before is valid by law

$path_path = $args[0]
#$path_path = $args[1]

if (-not (Test-Path "$path_path")) {
    $event_backup_folder = Read-Host -Prompt "Select the path to save all event viewer: "
}
else {
	$event_backup_folder = "$path_path"
}	

if (-not (Test-Path "$event_backup_folder")){
	Write-Host "Please select directory for saving all event viewer"
	exit 1
}	

$viewer_name = Get-WinEvent -ListLog * | Select-Object -ExpandProperty LogName
#$viewer_name = Get-WinEvent -ListLog *
$date_backup_folder = "${event_backup_folder}\event_viewer_$(Get-Date -Format "dd_MM_yyyy_mm")"

New-Item -ItemType Directory -Path $date_backup_folder -Force

Write-Host "Backuping all event viewer..."
Write-Host "Disabling windows event viewer service..."
Stop-Service -Name "EventLog" -Force
Set-Service -Name "EventLog" -StartupType Disabled

New-Item -ItemType Directory -Path "${date_backup_folder}\event_viewer_1" -Force
$folder_system = "$env:SystemRoot"
Copy-Item -Path "${folder_system}\System32\winevt\Logs" -Destination "${date_backup_folder}\event_viewer_1\" -Recurse

foreach ($viewer_name_2 in $viewer_name) {
    $path_file_single = Join-Path -Path $date_backup_folder -ChildPath "${viewer_name_2}.evtx"
	#$viewer_name_3 = Get-WinEvent -LogName $viewer_name_2 | Select-Object -ExpandProperty LogName
	$viewer_name_3 = "$viewer_name_2"
	
    try {
		Write-Host "Backuping the event viewer ${viewer_name_3}..."
		wevtutil epl "$viewer_name_3" "$path_file_single"
    }	
    catch {
        Write-Warning "Can't backuping event viewer ${viewer_name_2}: $($_.Exception.Message)"
		#break
    }
	try {
		Write-Host "Clearing event viewer ${viewer_name_3}..."
		wevtutil cl "$viewer_name_3"
	}
    catch {
        Write-Warning "Can't clearing event viewer ${viewer_name_2}: $($_.Exception.Message)"
		break
    }		
}

New-Item -ItemType Directory -Path "${date_backup_folder}\event_viewer_2" -Force
$folder_system = "$env:SystemRoot"
Copy-Item -Path "${folder_system}\System32\winevt\Logs" -Destination "${date_backup_folder}\event_viewer_2\" -Recurse
wevtutil cl "Security"
wevtutil cl "System"
Remove-Item -Path "${folder_system}\System32\winevt\Logs\*" -Recurse -Force

Write-Host "Enabling windows event viewer service..."
Start-Service -Name "EventLog" 
Set-Service -Name "EventLog" -StartupType Automatic

Write-Host "Event viewer success backuped"

#foreach ($viewer_name_2 in $viewer_name) {
#    $path_file_single = Join-Path -Path $date_backup_folder -ChildPath "$viewer_name_2"
#    try {
#		Get-WinEvent -LogName $viewer_name_2
#		wevtutil cl $viewer_name_2
#	}	
#    catch {
#        Write-Warning "Can't backuping event viewer $viewer_name_2: $($_.Exception.Message)"
#    }
#}

