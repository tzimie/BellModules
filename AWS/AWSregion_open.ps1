# it is expected that Set-AWSCredential is in teh current profile
param ([string]$usr, [string]$grp, [string]$name, [string]$tags) 

@"
RDS|AWSRDSlist|folder|$tags
EC2|AWSEC2list|folder|$tags
S3|AWSS3list|folder|$tags
"@

