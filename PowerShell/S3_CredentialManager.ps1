Install-Module -Name AWSPowerShell -Force -AllowClobber


$accessKey = "YOUR_AWS_ACCESS_KEY"
$secretKey = "YOUR_AWS_SECRET_KEY"
$targetName = "AWS_S3_Credentials"

# Add the access key
cmdkey /add:$targetName /user:"AccessKey" /pass:$accessKey

# Add the secret key - using a separate name for clarity
$targetSecretName = "${targetName}_Secret"
cmdkey /add:$targetSecretName /user:"SecretKey" /pass:$secretKey

$targetName = "AWS_S3_Credentials"
$targetSecretName = "${targetName}_Secret"
$bucketName = "YOUR_S3_BUCKET_NAME"

# Retrieve the credentials from Windows Credential Manager
$accessKeyCredential = cmdkey /list:$targetName | Where-Object { $_ -match "User:\s*(.+)" } | ForEach-Object { $matches[1] }
$secretKeyCredential = cmdkey /list:$targetSecretName | Where-Object { $_ -match "User:\s*(.+)" } | ForEach-Object { $matches[1] }

# Store credentials in environment variables temporarily (not recommended for production)
$env:AWS_ACCESS_KEY_ID = $accessKeyCredential
$env:AWS_SECRET_ACCESS_KEY = $secretKeyCredential

# List the contents of the S3 bucket
Import-Module AWSPowerShell
Get-S3Object -BucketName $bucketName | ForEach-Object { $_.Key }

# Optionally, clear the environment variables (for security reasons)
Remove-Variable -Name 'env:AWS_ACCESS_KEY_ID'
Remove-Variable -Name 'env:AWS_SECRET_ACCESS_KEY'

# AWS SDK and the AWS CLI can automatically pick up credentials set in environment variables named AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY, hence this method.

# Import AWS module
Import-Module AWSPowerShell

$bucketName = "YOUR_S3_BUCKET_NAME"
$daysOld = 30
$currentDate = Get-Date

# Set AWS credentials (consider using a more secure method for production)
Set-AWSCredentials -AccessKey 'YOUR_AWS_ACCESS_KEY' -SecretKey 'YOUR_AWS_SECRET_KEY' -StoreAs MyStoredCreds

# Retrieve objects from the bucket
$objects = Get-S3Object -BucketName $bucketName

foreach ($object in $objects) {
    $objectAge = ($currentDate - $object.LastModified).Days
    
    if ($objectAge -gt $daysOld) {
        # Delete the object if it's older than the specified number of days
        Remove-S3Object -BucketName $bucketName -Key $object.Key -Confirm:$false
        Write-Output "Deleted $object.Key which was $objectAge days old."
    }
}

# Optional: Clear stored AWS credentials
Clear-AWSCredentials -ProfileName MyStoredCreds


# Import the AWS PowerShell module
Import-Module AWSPowerShell

# Set your AWS credentials
$awsAccessKey = 'YOUR_AWS_ACCESS_KEY'
$awsSecretKey = 'YOUR_AWS_SECRET_KEY'
$awsRegion = 'YOUR_REGION' # e.g., 'us-east-1'

# Set the S3 bucket name
$bucketName = 'YOUR_BUCKET_NAME'

# Set the date threshold (30 days ago)
$dateThreshold = (Get-Date).AddDays(-30)

# Configure the AWS credentials
Set-AWSCredential -AccessKey $awsAccessKey -SecretKey $awsSecretKey -StoreAs MyStoredCreds

# Set the AWS region
Set-DefaultAWSRegion -Region $awsRegion

# Get the S3 objects
$s3Objects = Get-S3Object -BucketName $bucketName

# Loop through each object and delete it if it's older than the threshold
foreach ($object in $s3Objects) {
    $lastModified = $object.LastModified
    if ($lastModified -lt $dateThreshold) {
        Write-Host "Deleting $($object.Key) (Last Modified: $lastModified)..."
        Remove-S3Object -BucketName $bucketName -Key $object.Key -Force
    }
}

# Optionally, clear stored credentials
Remove-AWSCredentialProfile -ProfileName MyStoredCreds