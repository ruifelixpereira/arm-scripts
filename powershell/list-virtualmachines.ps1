$subscriptions=Get-AzSubscription

ForEach ($vsub in $subscriptions){

    $context = Get-AzSubscription -SubscriptionId $vsub.SubscriptionID
    Set-AzContext $context

    Write-Host

    Write-Host “Working on “ $vsub

    Write-Host

    #Getting all Azure VMs
    $resources = Get-AzVm

    #Declaring Variables
    $results = @()
    $TagsAsString = ""

    foreach($resource in $resources)
    {
        #Fetching Tags
        $Tags = $resource.Tags
        
        #Checkign if tags is null or have value
        if($Tags -ne $null)
        {
            foreach($Tag in $Tags)
            {
                #$TagsAsString += $Tag.Name + ":" + $Tag.Value + ";"
                $Tags.GetEnumerator() | % { $TagsAsString += $_.Key + ":" + $_.Value + ";" }
            }
        }
        else
        {
            $TagsAsString = ""
        }

        #Adding to Results
        $details = @{        
                    Name = $resource.Name    
                    ResourceGroupName =$resource.ResourceGroupName
                    Location = $resource.Location
                    SubscriptionId = $vsub.SubscriptionID
                    VmSize = $resource.HardwareProfile.VmSize
                    Tags = $TagsAsString
        }                           
        $results += New-Object PSObject -Property $details 

        #Clearing Variable
        $TagsAsString = ""
    }    

    $results | Export-Csv -Path .\AllVMs.txt -Append
}
