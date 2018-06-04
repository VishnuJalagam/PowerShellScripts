param ([string]$targetSiteURL = "http://thesourcelab1.ihs.com/sites/AP",
[string] $targetListName = "TestList",
[string]$configpath = "E:\Vishnu\ItemDetails.csv"
)
Add-PSSnapin microsoft.sharepoint.powershell

$targetSPWeb = Get-SPWeb $targetSiteURL;
$SourceSPList = $targetSPWeb.Lists[$targetListName]
$csvDictionary = New-Object 'system.collections.generic.dictionary[int,object]'


function ImportCsv()
{

    $id = 0;
    Import-Csv -Delimiter "," -Path $configpath | % {
        $obj = @{};
        $obj.Id = ++$id;
       
        $obj.ItemID = $_.ItemID
        $obj.CreatedBy = $_.CreatedBy
       
        $object = new-object -TypeName PSObject -Property $obj
        $csvDictionary.Add($id, $object);
        
    }
}
function ProcessCsv()
{
    Write-host $csvDictionary.Values
    $csvDictionaryFiltered = $csvDictionary.Values | Where-Object {$_.Action -ne ""}
    
    foreach($obj in $csvDictionaryFiltered)
    {
      try
      {
        $user=  $targetSPWeb.EnsureUser($obj.CreatedBy)
        Write-host  $user
        $SPListItem = $SourceSPList.GetItemById($obj.ItemID);
        $SPListItem["Author"] = $user;
        $SPListItem.Update();
        
      }
      catch
      {
          Write-host "Error occured in updating Item" $obj.ItemID -foregroundcolor Red 
      }
    }
}

function Main
{
    ImportCsv
    ProcessCsv    
}

Main