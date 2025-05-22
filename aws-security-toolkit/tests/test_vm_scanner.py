aws-security-toolkit
├── src
│   ├── scanners
│   │   ├── vm-scanner.py
│   │   ├── s3-scanner.py
│   │   └── cis-scanner.py
│   ├── discovery
│   │   └── resource-discovery.py
│   ├── benchmarks
│   │   └── cis-benchmarks.py
│   └── utils
│       ├── aws_helpers.py
│       └── common.py
├── tests
│   ├── test_vm_scanner.py
│   ├── test_s3_scanner.py
│   └── test_cis_scanner.py
├── config
│   ├── scanner_config.yaml
│   └── aws_config.yaml
├── requirements.txt
├── setup.py
└── README.md