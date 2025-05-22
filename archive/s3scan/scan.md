a) Use S3Scanner to Find Public Buckets

```bash
git clone https://github.com/sa7mon/S3Scanner.git
cd S3Scanner
go build -o s3scanner .
s3scanner -bucket-file names.txt -enumerate
```

b) Use Cloudsplaining to Find Insecure Policies

```bash
pip install cloudsplaining
cloudsplaining scan --input-file policy.json
```

c) Use S3Scanner to Find Public Buckets

```bash
s3scanner scan --bucket-list buckets.txt
```

d) Use S3Scanner to Find Public Buckets

4.  Check Encryption Settings
    To ensure data at rest is encrypted, check the default encryption settings:

```
aws s3api get-bucket-encryption --bucket <bucket-name>
```
