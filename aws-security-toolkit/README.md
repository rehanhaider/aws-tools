# README.md content for the aws-security-toolkit project

# AWS Security Toolkit

The AWS Security Toolkit is a comprehensive suite designed to help users scan, discover, and benchmark AWS resources against best practices and compliance standards. This toolkit includes various scanners, discovery scripts, and benchmarking tools to ensure your AWS environment is secure and optimized.

## Features

- **VM Scanner**: Deploys a virtual machine scanner appliance to perform security assessments in client environments.
- **S3 Scanner**: Checks for misconfigurations in S3 buckets and evaluates their settings against best practices.
- **CIS Scanner**: Benchmarks AWS resources against CIS standards, assessing compliance and generating reports.
- **Resource Discovery**: Discovers AWS resources that incur costs, helping users manage their cloud expenses.
- **CIS Benchmarks**: Runs benchmarks against CIS standards to ensure compliance and security.

## Installation

To install the AWS Security Toolkit, clone the repository and install the required dependencies:

```bash
git clone https://github.com/yourusername/aws-security-toolkit.git
cd aws-security-toolkit
pip install -r requirements.txt
```

## Usage

### Running the Scanners

To run the VM scanner, execute the following command:

```bash
python src/scanners/vm-scanner.py
```

To run the S3 scanner, use:

```bash
python src/scanners/s3-scanner.py
```

To run the CIS scanner, execute:

```bash
python src/scanners/cis-scanner.py
```

### Configuration

Configuration settings can be found in the `config` directory. Modify `scanner_config.yaml` and `aws_config.yaml` as needed to suit your environment.

## Contributing

Contributions are welcome! Please submit a pull request or open an issue for any enhancements or bug fixes.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.