# Bartłomiej Gołębiewski IZ07TC1 17678 AZ1_Zadanie3


function az1-17678 {
	[CmdletBinding()]
	Param(
	[Parameter(Mandatory=$true)]
	[string] $Name,
	[Parameter(Mandatory=$true)]
	[string] $LName,
	[Parameter(Mandatory=$true)]
	[int] $Department,
	[Parameter(Mandatory=$false)]
	[string] $Office,
	[Parameter(Mandatory=$false)]
	[string] $MobileNumber )
	
	Write-Verbose "Tworzenie konta użytkownika"
	$login = $Name + "." + $LName
	$IndexNumber = "17678"
	$domain = (Get-ADDomain).dnsroot
	$OU = "OU " + $IndexNumber
        $ouPath = $OU
	$email = $login + "@" +  $domain
	$dn = (Get-ADDomain).distinguishedname
	
	Write-Verbose "Generowanie losowego hasła"
	Add-Type -AssemblyName System.Web
	$password = New-Object -TypeName PSObject
	$password = [System.Web.Security.Membership]::GeneratePassword(10,2)
	
	$destinationOU = "OU=" + $OU  + ',' + $dn
	$displayName = $Name + " " + $LName

	try {
      Write-Verbose "Sprawdzam istnieje OU"
      Get-ADOrganizationalUnit -Identity $destinationOU | out-null   }
	catch {
      Write-Verbose "Tworzę OU $($destinationOU)"
      New-ADOrganizationalUnit -name $OU -path $dn -ProtectedFromAccidentalDeletion $false }
	
	try {
        Write-Verbose "Tworzę użytkownika"
        New-AdUser -Name  $login `
		-DisplayName  $displayName `
        -SamAccountName  $login `
		-Surname  $LName `
        -AccountPassword (ConvertTo-SecureString "$password" -AsPlainText -Force) `
        -Department $Department `
        -Office $Office `
        -EmailAddress $email `
        -MobilePhone $MobileNumber `
        -Enabled $true `
		-ChangePasswordAtLogon $false `
        -PasswordNeverExpires $false `
        -Path $destinationOU 
        Write-Verbose "Utworzono użytkownika" }
    catch {    Write-Verbose "Nie można było utworzyć użytkownika"
         }
}
	
function azexport-17678 {
	$FolderPath ='C:\WIT\17678'
	
    
    if (Test-Path $FolderPath) {
        Write-Host "'$FolderPath' istnieje"
    }else {
        New-Item -Path $FolderPath -ItemType Directory
        Write-Host "Utworzono '$FolderPath'"
    }

    $Computer = Get-ADComputer -Filter * -properties *
	$Computers = $Computer | Group-Object -Property OperatingSystem | Select-Object @{N = "Nazwa OS"; E = "Name"}, @{N = "Ilosc"; E = "Count"} | Sort Ilosc    

    try {
        $toFile = Join-Path -Path $FolderPath -ChildPath 'AZ3_Wersje_OS_17678.csv'
        $Computers | Export-Csv -LiteralPath $toFile -NoTypeInformation
        Write-Host 'Pomyślnie wygenerowano plik'
    }
    catch {
        Write-Host 'Nie udalo sie wygenerowac pliku'
    }

}

function azmenu-17678 {

Write-Host "'1. Założenie konta, 2. Generowanie danych'"
$choose = Read-Host "Wybierz:"
    switch ($choose){
        '1' {
            az1-17678 -Verbose
            Break }
        '2' {
            azexport-17678
            Break }      
    }
}

azmenu-17678 