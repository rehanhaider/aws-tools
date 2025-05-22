import unittest
from src.scanners.cis-scanner import assess_compliance, generate_report

class TestCISScanner(unittest.TestCase):

    def test_assess_compliance(self):
        # Example input for testing
        resource = {
            'type': 'ec2',
            'id': 'i-1234567890abcdef0',
            'configuration': {
                'instance_type': 't2.micro',
                'security_groups': ['sg-12345678']
            }
        }
        result = assess_compliance(resource)
        self.assertTrue(result['compliant'], "Resource should be compliant with CIS standards")

    def test_generate_report(self):
        # Example input for testing
        compliance_data = {
            'resource_id': 'i-1234567890abcdef0',
            'compliance_status': True,
            'details': 'Resource is compliant with CIS standards'
        }
        report = generate_report(compliance_data)
        self.assertIn('Resource ID:', report)
        self.assertIn('Compliance Status:', report)

if __name__ == '__main__':
    unittest.main()