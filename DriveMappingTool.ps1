#variables
$break = ""

#Set Execution Policy - Im not sure if this needs to be set, putting in for now
$ErrorActionPreference = "SilentlyContinue"
try {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
}
catch {
    write-warning "$_"
}

#Ask User what they are wanting to map
$fDrive = New-Object System.Management.Automation.Host.ChoiceDescription '&F-Drive', 'Choose to map your F Drive'
$other = New-Object System.Management.Automation.Host.ChoiceDescription '&Other', 'Choose to manually enter the network path you want to map to a drive.'
$choices = [System.Management.Automation.Host.ChoiceDescription[]]($fDrive, $other)
$title = "***Drive Mapping Tool***"
$message = 'Do you need to map your F drive? or another drive?'
$result = $Host.UI.PromptForChoice($title, $message, $choices, 0)

#Logic for choice made
if ($result -eq 0) {

    #Retrieve LAN ID
    $lanId = $env:USERNAME

    #Create Root Path
    $getad = (([adsisearcher]"(&(objectCategory=User)(samaccountname=$lanId))").findall()).properties
    $pathF = $getad.homedirectory
    $letter = $getad.homedrive
    
    #Map Network Drive
    $ErrorActionPreference = "Stop"
    try 
    {
        New-PSDrive -Name $letter.SubString(0,1) -PSProvider FileSystem -Root "$pathF" -Persist
        Invoke-Item $letter
        $break
        Write-Output "Your F Drive has been mapped successfully. "
        $break
        Read-Host -Prompt "Press Enter to Exit"
    }
    catch [System.Management.Automation.SessionStateException]
    {
        Invoke-Item $pathF
        $break
        Write-Output "Your F Drive has been mapped successfully. "
        $break
        Read-Host -Prompt "Press Enter to Exit"
    }
    catch [System.ComponentModel.Win32Exception]
    {
        Write-Output "Your F Drive is already mapped"
        Invoke-Item $letter
        $break
        Read-Host -Prompt "Press Enter to Exit"
    }

    
}
else {
    #Get Information from user 
    $drive = Read-Host -Prompt 'Enter the Network Drive Path you want to map'
    Get-PSDrive -PSProvider FileSystem 
    $break
    $letter = Read-Host -Prompt 'Choose a letter A-Z that is not being used above'
    $break

    $ErrorActionPreference = "Stop"
    try {
        New-PSDrive -Name "$letter" -PSProvider FileSystem -Root "$drive" -Persist
    }
    catch [System.Management.Automation.SessionStateException]
    {
        Write-Output "$drive has been mapped."
    }
    catch [System.ComponentModel.Win32Exception]
    {
        Write-Output "The $($letter.ToUpper()) drive could not be mapped. Make sure the drive name(letter) is available and you have the correct path."
        $break
        Read-Host -Prompt "Press Enter to Exit"
        break
    }
    catch [NotSupportedException]
    {
        Write-Output 'Please enter a valid Path'
    }

    Invoke-Item "$($letter):"
    $break
    Write-Output "Your Drive has been mapped successfully. "
    $break
    Read-Host -Prompt "Press Enter to Exit"  
}
