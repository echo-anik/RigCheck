import { FileText } from 'lucide-react';
import { Card, CardContent } from '@/components/ui/card';

export default function TermsPage() {
  return (
    <div className="min-h-screen bg-gray-50 py-12">
      <div className="max-w-4xl mx-auto px-4">
        <div className="text-center mb-12">
          <div className="h-16 w-16 bg-primary/10 rounded-full flex items-center justify-center mx-auto mb-4">
            <FileText className="h-8 w-8 text-primary" />
          </div>
          <h1 className="text-4xl font-bold mb-4">Terms of Service</h1>
          <p className="text-muted-foreground">
            Last updated: December 15, 2025
          </p>
        </div>

        <Card className="mb-8">
          <CardContent className="pt-6 prose prose-sm max-w-none">
            <p className="text-muted-foreground mb-6">
              Welcome to RigCheck. By accessing or using our website, you agree to be bound by these 
              Terms of Service. Please read them carefully.
            </p>

            <h2 className="text-2xl font-bold mt-8 mb-4">1. Acceptance of Terms</h2>
            <p className="text-muted-foreground mb-6">
              By creating an account or using RigCheck, you agree to these Terms of Service and our 
              Privacy Policy. If you do not agree, please do not use our service.
            </p>

            <h2 className="text-2xl font-bold mt-8 mb-4">2. Description of Service</h2>
            <p className="text-muted-foreground mb-4">
              RigCheck provides:
            </p>
            <ul className="list-disc pl-6 text-muted-foreground space-y-2 mb-6">
              <li>PC component information and pricing data</li>
              <li>Build creation and compatibility checking tools</li>
              <li>Community features for sharing builds</li>
              <li>Component comparison and search functionality</li>
            </ul>
            <p className="text-muted-foreground mb-6">
              RigCheck is an information platform. We do not sell components or fulfill orders directly.
            </p>

            <h2 className="text-2xl font-bold mt-8 mb-4">3. User Accounts</h2>
            <h3 className="text-xl font-semibold mt-6 mb-3">Registration</h3>
            <ul className="list-disc pl-6 text-muted-foreground space-y-2 mb-6">
              <li>You must provide accurate and complete information</li>
              <li>You are responsible for maintaining account security</li>
              <li>You must be at least 13 years old to create an account</li>
              <li>One person or entity may maintain only one account</li>
            </ul>

            <h3 className="text-xl font-semibold mt-6 mb-3">Account Security</h3>
            <ul className="list-disc pl-6 text-muted-foreground space-y-2 mb-6">
              <li>Keep your password confidential</li>
              <li>Notify us immediately of unauthorized access</li>
              <li>You are responsible for all activities under your account</li>
            </ul>

            <h2 className="text-2xl font-bold mt-8 mb-4">4. Acceptable Use</h2>
            <p className="text-muted-foreground mb-4">
              You agree NOT to:
            </p>
            <ul className="list-disc pl-6 text-muted-foreground space-y-2 mb-6">
              <li>Violate any laws or regulations</li>
              <li>Post false, misleading, or fraudulent content</li>
              <li>Harass, abuse, or harm other users</li>
              <li>Upload malware or malicious code</li>
              <li>Scrape or data mine without permission</li>
              <li>Impersonate others or misrepresent affiliation</li>
              <li>Interfere with the proper functioning of the service</li>
              <li>Attempt to gain unauthorized access to systems</li>
            </ul>

            <h2 className="text-2xl font-bold mt-8 mb-4">5. User Content</h2>
            <h3 className="text-xl font-semibold mt-6 mb-3">Ownership</h3>
            <p className="text-muted-foreground mb-6">
              You retain ownership of builds and content you create. By posting public builds, 
              you grant RigCheck a license to display, distribute, and promote that content.
            </p>

            <h3 className="text-xl font-semibold mt-6 mb-3">Content Standards</h3>
            <p className="text-muted-foreground mb-4">
              User content must:
            </p>
            <ul className="list-disc pl-6 text-muted-foreground space-y-2 mb-6">
              <li>Be accurate and not misleading</li>
              <li>Not violate intellectual property rights</li>
              <li>Not contain offensive or inappropriate material</li>
              <li>Comply with all applicable laws</li>
            </ul>

            <h2 className="text-2xl font-bold mt-8 mb-4">6. Pricing Information</h2>
            <p className="text-muted-foreground mb-6">
              Pricing data is provided for informational purposes only. We strive for accuracy but 
              cannot guarantee that all prices are current or correct. Always verify pricing with 
              retailers before purchasing.
            </p>

            <h2 className="text-2xl font-bold mt-8 mb-4">7. Compatibility Checking</h2>
            <p className="text-muted-foreground mb-6">
              Our compatibility checker is a tool to assist in PC building. While we strive for 
              accuracy, we cannot guarantee that all compatibility issues will be detected. 
              Always verify compatibility before purchasing components.
            </p>

            <h2 className="text-2xl font-bold mt-8 mb-4">8. Disclaimer of Warranties</h2>
            <p className="text-muted-foreground mb-6">
              RigCheck is provided &quot;as is&quot; without warranties of any kind. We do not warrant that:
            </p>
            <ul className="list-disc pl-6 text-muted-foreground space-y-2 mb-6">
              <li>The service will be uninterrupted or error-free</li>
              <li>Information will be accurate or complete</li>
              <li>Defects will be corrected</li>
              <li>The service is free of viruses or harmful components</li>
            </ul>

            <h2 className="text-2xl font-bold mt-8 mb-4">9. Limitation of Liability</h2>
            <p className="text-muted-foreground mb-6">
              RigCheck shall not be liable for any indirect, incidental, special, consequential, 
              or punitive damages resulting from your use of the service. This includes but is not 
              limited to purchasing incompatible components or incorrect pricing information.
            </p>

            <h2 className="text-2xl font-bold mt-8 mb-4">10. Termination</h2>
            <p className="text-muted-foreground mb-4">
              We reserve the right to:
            </p>
            <ul className="list-disc pl-6 text-muted-foreground space-y-2 mb-6">
              <li>Suspend or terminate accounts that violate these terms</li>
              <li>Remove content that violates our policies</li>
              <li>Modify or discontinue the service at any time</li>
            </ul>
            <p className="text-muted-foreground mb-6">
              You may terminate your account at any time by contacting us.
            </p>

            <h2 className="text-2xl font-bold mt-8 mb-4">11. Intellectual Property</h2>
            <p className="text-muted-foreground mb-6">
              All content, features, and functionality of RigCheck (excluding user-generated content) 
              are owned by RigCheck and protected by copyright, trademark, and other intellectual 
              property laws.
            </p>

            <h2 className="text-2xl font-bold mt-8 mb-4">12. Links to Third-Party Sites</h2>
            <p className="text-muted-foreground mb-6">
              Our service may contain links to third-party websites or retailers. We are not 
              responsible for the content, privacy practices, or terms of these external sites.
            </p>

            <h2 className="text-2xl font-bold mt-8 mb-4">13. Changes to Terms</h2>
            <p className="text-muted-foreground mb-6">
              We may modify these Terms of Service at any time. Continued use of the service after 
              changes constitutes acceptance of the new terms.
            </p>

            <h2 className="text-2xl font-bold mt-8 mb-4">14. Governing Law</h2>
            <p className="text-muted-foreground mb-6">
              These terms are governed by the laws of Bangladesh. Any disputes shall be resolved 
              in the courts of Dhaka, Bangladesh.
            </p>

            <h2 className="text-2xl font-bold mt-8 mb-4">15. Contact Information</h2>
            <p className="text-muted-foreground mb-4">
              For questions about these Terms of Service:
            </p>
            <ul className="list-none text-muted-foreground space-y-2 mb-6">
              <li>Email: legal@rigcheck.com</li>
              <li>Phone: +880 1234-567890</li>
            </ul>

            <h2 className="text-2xl font-bold mt-8 mb-4">16. Entire Agreement</h2>
            <p className="text-muted-foreground mb-6">
              These Terms of Service, together with our Privacy Policy, constitute the entire 
              agreement between you and RigCheck regarding the use of our service.
            </p>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
