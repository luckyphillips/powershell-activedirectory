
Function Msg{
    Param ($msg)
    [System.Windows.Forms.MessageBox]::Show($msg)
}

Function AddUsers{
    Param ($u_name, $u_givenname, $u_surname, $u_accountname, $u_email)
    $OU="OU=staff,DC=enterprise,DC=com"
    Import-Module ActiveDirectory
    New-ADUser -Name "$u_name" -GivenName "$u_givenname" -Surname "$u_surname" -SamAccountName "$u_accountname" -UserPrincipalName "$u_email" -Path "$OU" -AccountPassword(ConvertTo-SecureString "P4ssw0rd*" -AsPlainText -force) -passThru -Enabled $true
}

$OUname="Luckylab"
$OUdomain="Luckylab"
$OUhost="local"
$OUdescription="Luckys Staff"


try{
    [string] $Path = "OU=$OUname,OU=$OUname,DC=$OUdomain,DC=$OUhost"
    if(![adsi]::Exists("LDAP://$Path"))
    {
    ## Un-COmment the line below to add a new Organization Unit
    # New-ADOrganizationalUnit -Name $OUname -Path "dc=$OUdomain,dc=$OUhost" -Description "$OUdescription" -ProtectedFromAccidentalDeletion:$false
    }
}
    catch{
    echo "Not working on a windows server"
}

$SQLserver = "." # Connects to localhost machine 
$DB = "master" 


Try 
{ 
    $SQLConnection= New-Object System.Data.SQLClient.SQLConnection 
    $SQLConnection.ConnectionString ="server=$SQLserver;database=$DB;Integrated Security=True;" 
    $SQLConnection.Open() 
#    Msg "Connected"
    
} 
catch 
{ 
    Msg "Failed to connect SQL Server"  
    Exit
} 
# Msg "Checking Table"

$SQLCommand = New-Object System.Data.SqlClient.SqlCommand 
 $SQLCommand.CommandText = "if not exists (select * from sysobjects where name='staff' and xtype='U')
    create table staff (
        staff_id int IDENTITY(1,1) PRIMARY KEY,
        staff_FirstName varchar(255) NOT NULL,
        staff_LastName varchar(255),
        staff_email varchar(255)
    );
    if not exists (select * from sysobjects where name='timestamps' and xtype='U')
    create table timestamps (
        staff_id int,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    )    
"
#Get-ADUser -Filter * -SearchBase "dc=Luckylab,dc=local" | Get-ADUser -Property DisplayName | Select Name,ObjectClass,DisplayName | Out-File C:\addusers.txt

$SQLCommand.Connection = $SQLConnection 
 
$SQLAdapter = New-Object System.Data.SqlClient.SqlDataAdapter 
$SqlAdapter.SelectCommand = $SQLCommand                  
$SQLDataset = New-Object System.Data.DataSet 
$SqlAdapter.fill($SQLDataset) | out-null 


<#
# This works to add data to the tables.
$SQLCommand.CommandText = "INSERT INTO staff VALUES('Jenny','Phillips','jenny@onshu.com');"
$SQLCommand.ExecuteReader()
#>

<# Populate the timestamps for testing
for($i = 0; $i -lt 10; $i++)
{
    $rand = Get-Random -InputObject 1, 2, 3
    $SQLQuery = "INSERT INTO timestamps (staff_id) VALUES('$rand');"
    Start-Sleep -Seconds 1
    # $result = Invoke-Sqlcmd -Query $SQLQuery -ServerInstance “YourServerInstance” -Username “YourUserName” -Password “YourPassword” -Database “YourDatabase” -ErrorAction Stop
    $result = Invoke-Sqlcmd -Query $SQLQuery -ServerInstance “.” -Database “master” -ErrorAction Stop
}
#>

<#
 
$tablevalue = @() 
foreach ($data in $SQLDataset.tables[0]) 
{ 
    $tablevalue = $data[0] 
    $tablevalue 
} 
#>

$SQLConnection.Close() 

# Get-LocalUser | Select name


<#

# Get-ADUser -Identity "hitesh" -Properties "LastLogonDate"
Get-ADUser -Filter {enabled -eq $true} -Properties LastLogonTimeStamp |
Select-Object Name,@{Name="Stamp"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp).ToString('yyyy-MM-dd_hh:mm:ss')}}

#>

# Send-MailMessage -From 'User01 ' -To 'User02 ', 'User03 ' -Subject 'Sending the Attachment' -Body "Forgot to send the attachment. Sending now." -Attachments .\data.csv -Priority High -DeliveryNotificationOption OnSuccess, OnFailure -SmtpServer 'smtp.fabrikam.com'
# Send-MailMessage -To “<recipient’s email address>” -From “<sender’s email address>”  -Subject “Your message subject” -Body “Some important plain text!” -Credential (Get-Credential) -SmtpServer “<smtp server>” -Port 587


echo "Location = $location"
$taskName = "staff-email"
$taskExists = Get-ScheduledTask | Where-Object {$_.TaskName -like $taskName }
if(!$taskExists) {

    $location = Split-Path -parent $PSCommandPath
    $trigger = New-ScheduledTaskTrigger -Daily -At 1pm
    $testAction = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-File '$location\project1.ps1'"
    echo $testAction
    #'C:\Users\lucky\Documents\Powershell\project1.ps1'
    Register-ScheduledTask -Action $testAction -Trigger $trigger -TaskName "staff-email" 
    # -File 'C:\Users\lucky\Documents\Powershell\project1.ps1'
}





# Get-ScheduledTask | Where-Object {$_.TaskName -like $taskName }

Unregister-ScheduledTask -TaskName "staff-email"


