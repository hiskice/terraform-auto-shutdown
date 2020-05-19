workflow runbook-weekly-auto-shutdown-vm
{
        Param(
        [Parameter(Mandatory=$true)]
        [String]
        $tagname,
        [Parameter(Mandatory=$true)]
        [String]
        $tagvalue,
        [Parameter(Mandatory=$true)]
        [Boolean]
        $shutdown
        )
     
    $connectionName = "AzureRunAsConnection";
 
    try
    {
        # Get the connection "AzureRunAsConnection "
        $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName        
 
        "Logging in to Azure..."
        Add-AzureRmAccount `
            -ServicePrincipal `
            -TenantId $servicePrincipalConnection.TenantId `
            -ApplicationId $servicePrincipalConnection.ApplicationId `
            -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
    }
    catch {
 
        if (!$servicePrincipalConnection)
        {
            $ErrorMessage = "Connection $connectionName not found."
            throw $ErrorMessage
        } else{
            Write-Error -Message $_.Exception
            throw $_.Exception
        }
    }
         
     
    $vms = Get-AzureRmResource -TagName $tagname -TagValue $tagvalue | where {$_.ResourceType -like "Microsoft.Compute/virtualMachines"}
     
    Foreach -Parallel ($vm in $vms){
        
        if($shutdown){
            Write-Output "Stopping $($vm.Name)";        
            Stop-AzureRmVm -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName -Force;
        }
        else{
            Write-Output "Starting $($vm.Name)";        
            Start-AzureRmVm -Name $vm.Name -ResourceGroupName $vm.ResourceGroupName;
        }
    }
}