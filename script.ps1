# Run the below line in powershell to allow scripts to be run
# Set-ExecutionPolicy RemoteSigned

# Obviously change the user Lucky to whatever your username is

Set-Location "C:\Users\lucky\Documents\Powershell"

<# One way of doing it...

my test.csv file looks like...
Name,Details
skype,This is the skype software
brave,An everyday browser we should all be using


$csv = import-csv "test.csv" -Delimiter ","
ForEach ($appli in $csv) 
{
    Write-Host $Name =$appli.Name `n
}

#>

# ForEach-Object = %

# $_ = the object
Import-CSV "test.csv" | %{
   Write-Host $_.name " - " -NoNewLine
   Write-Host $_.details
}

<#

Use the ? for where-objects
Get-Process | Where-Object {$_.ProcessName -eq "brave"}
Get-Process | ?{$_.ProcessName -eq "brave"} # As an example using the brave browser that's running

#>

<#
if the csv file has no header, i.e. Name, Age, Address, Sex,
You can create the header on the fly with -Header Name,Age,Address,Sex

An example would be a csv file with the below entries but no header
a1,a2,a3
b1,b2,b3
c1,c2,c3

Create the csv file, then test it.
use [void] so it doesn't return it to the screen (.NET thingy)
#>
$csvarray = new-Object System.Collections.ArrayList
[void]$csvarray.Add(@('a1','a2','a3'))
[void]$csvarray.Add(@('b1','b2','b3'))
[void]$csvarray.Add(@('c1','c2','c3'))
Set-Content "test2.csv" -Value $null # Needed to replace test2.csv if it already exists
$csvarray | %{$_ -join ',' | Add-Content "test2.csv"}

 
# Now, spit it out with a custom header for each field since it wasn't created with one.

Import-CSV "test2.csv" -Header h1,h2,h3
