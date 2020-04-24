$TargettedObjects = Get-S3Object -BucketName <BUCKETNAME> -KeyPrefix "PATH/OF/INTEREST";
$S3CopyLifetimeInDays = 15; #Set the numbers of days the restored for
$S3Tier = Standard; # Set to either "Bulk", "Standard" or "Expidited" (different costs for each)

foreach($Object in $TargettedObjects){
    $ObjectMetadata = Get-S3ObjectMetadata -Key $Object.Key -BucketName $Object.BucketName
    if($ObjectMetadata.StorageClass -eq "GLACIER" -and [System.Convert]::ToBoolean($ObjectMetadata.RestoreInProgress) -eq $false -and -not $($ObjectMetadata.RestoreExpiration)){ 
        Write-Host "Glacier storage object: $($Object.Key)" -ForegroundColor Cyan 
        Write-Host "Starting restore of object..." -ForegroundColor White
        Restore-S3Object -Key $Object.Key -BucketName $Object.BucketName -CopyLifetimeInDays $S3CopyLifetimeInDays -Tier $S3Tier
    }
    elseif($ObjectMetadata.StorageClass -eq "GLACIER" -and [System.Convert]::ToBoolean($ObjectMetadata.RestoreInProgress) -eq $true){ Write-Host "Found thawing object: $($Object.Key)" -ForegroundColor Yellow }
    elseif($ObjectMetadata.StorageClass -eq "GLACIER" -and $($ObjectMetadata.RestoreExpiration)){ Write-Host "Found thawed standard object: $($Object.Key)" -ForegroundColor Green }
    else{ Write-Host "Found standard object: $($Object.Key)" -ForegroundColor Green }
}
