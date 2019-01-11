# Select the subscription to use
$subscriptionID = "0f10f0c7-0e05-4c11-a946-f5d540d6f21c" # Provide Azure SubscriptionID
Select-AzureRmSubscription -SubscriptionId $subscriptionID

###########################################
# Create an HDInsight Cluster
###########################################
# Cluster Variables
$resourceGroupName = "testhdinsight1" # Provide Resource Group Name
$storageAccountName = "sahdautomation" # Provide Storage Account Name
$containerName = "testblob" # Provide Blob Container 
$storageAccountKey = "H9vHmiyhAQoKzdBR7LvNvDnunnwWNiEsbTHV2z5bEvrAseEoh9CEItik8Q0QRfTmFuXI/uXh4CzHviR55idGkQ=="
$StorageContext = New-AzureStorageContext -StorageAccountName $defaultStorageAccountName -StorageAccountKey $StorageAccountKey
$clusterName = $containerName 
$clusterNodes = 4
$clusterUser = "mcadmin" # Provide Cluster Username
$clusterSSHUser = "sshuser" # Provide SSH Username
$clusterPSWD = ConvertTo-SecureString "W0rld$123456" -AsPlainText -Force # Provide password to use for cluster and ssh if the same
$clusterCredential = New-Object System.Management.Automation.PSCredential ($clusterUser, $clusterPSWD)
$sshCredential = New-Object System.Management.Automation.PSCredential ($clusterSSHUser, $clusterPSWD)
$clusterType = "Hadoop"
$clusterOS = "Linux" 
$clusterNodeSize = "Standard_A3"
$location = "Central US"




# Create a new HDInsight cluster
New-AzureRmHDInsightCluster -ClusterName $clusterName -ResourceGroupName $resourceGroupName -HttpCredential $clusterCredential -Location $location -DefaultStorageAccountName "$storageAccountName.blob.core.windows.net" -DefaultStorageAccountKey $storageAccountKey -DefaultStorageContainer $containerName -ClusterSizeInNodes $clusterNodes -ClusterType $clusterType -OSType $clusterOS -Version "3.6" -SshCredential $sshCredential -HeadNodeSize $clusterNodeSize -WorkerNodeSize $clusterNodeSize





$clusterName = "testblob" # Provide Cluster Name
Remove-AzureRmHDInsightCluster -ClusterName $clusterName
