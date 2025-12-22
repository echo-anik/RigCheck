import { Shield } from 'lucide-react';
import { Card, CardContent } from '@/components/ui/card';

export default function PrivacyPage() {
  return (
    <div className="min-h-screen bg-gray-50 py-12">
      <div className="max-w-4xl mx-auto px-4">
        <div className="text-center mb-12">
          <div className="h-16 w-16 bg-primary/10 rounded-full flex items-center justify-center mx-auto mb-4">
            <Shield className="h-8 w-8 text-primary" />
          </div>
          <h1 className="text-4xl font-bold mb-4">Privacy Policy</h1>
          <p className="text-muted-foreground">
            Last updated: December 15, 2025
          </p>
        </div>

        <Card className="mb-8">
          <CardContent className="pt-6 prose prose-sm max-w-none">
            <p className="text-muted-foreground mb-6">
              At RigCheck, we take your privacy seriously. This Privacy Policy explains how we collect, 
              use, disclose, and safeguard your information when you visit our website.
            </p>

            <h2 className="text-2xl font-bold mt-8 mb-4">Information We Collect</h2>
            <h3 className="text-xl font-semibold mt-6 mb-3">Personal Information</h3>
            <p className="text-muted-foreground mb-4">
              When you register for an account, we collect:
            </p>
            <ul className="list-disc pl-6 text-muted-foreground space-y-2 mb-6">
              <li>Name and email address</li>
              <li>Password (encrypted)</li>
              <li>Profile information you choose to provide</li>
            </ul>

            <h3 className="text-xl font-semibold mt-6 mb-3">Usage Information</h3>
            <p className="text-muted-foreground mb-4">
              We automatically collect certain information about your device and how you interact with our service:
            </p>
            <ul className="list-disc pl-6 text-muted-foreground space-y-2 mb-6">
              <li>Browser type and version</li>
              <li>Operating system</li>
              <li>IP address</li>
              <li>Pages visited and features used</li>
              <li>Time and date of visits</li>
            </ul>

            <h3 className="text-xl font-semibold mt-6 mb-3">Build Information</h3>
            <p className="text-muted-foreground mb-4">
              When you create PC builds:
            </p>
            <ul className="list-disc pl-6 text-muted-foreground space-y-2 mb-6">
              <li>Build configurations and component selections</li>
              <li>Build names and descriptions</li>
              <li>Public/private status of builds</li>
            </ul>

            <h2 className="text-2xl font-bold mt-8 mb-4">How We Use Your Information</h2>
            <ul className="list-disc pl-6 text-muted-foreground space-y-2 mb-6">
              <li>To provide and maintain our service</li>
              <li>To authenticate and manage your account</li>
              <li>To save and display your PC builds</li>
              <li>To improve our website and user experience</li>
              <li>To send you important updates and notifications</li>
              <li>To analyze usage patterns and optimize performance</li>
              <li>To prevent fraud and enhance security</li>
            </ul>

            <h2 className="text-2xl font-bold mt-8 mb-4">Information Sharing</h2>
            <p className="text-muted-foreground mb-4">
              We do not sell, trade, or rent your personal information to third parties. 
              We may share information in the following circumstances:
            </p>
            <ul className="list-disc pl-6 text-muted-foreground space-y-2 mb-6">
              <li><strong>Public Builds:</strong> Builds you mark as public will be visible to other users</li>
              <li><strong>Service Providers:</strong> With trusted partners who help us operate our service</li>
              <li><strong>Legal Requirements:</strong> When required by law or to protect our rights</li>
              <li><strong>Business Transfers:</strong> In connection with a merger, sale, or asset transfer</li>
            </ul>

            <h2 className="text-2xl font-bold mt-8 mb-4">Data Security</h2>
            <p className="text-muted-foreground mb-6">
              We implement appropriate security measures to protect your personal information:
            </p>
            <ul className="list-disc pl-6 text-muted-foreground space-y-2 mb-6">
              <li>Encrypted password storage</li>
              <li>Secure HTTPS connections</li>
              <li>Regular security audits</li>
              <li>Access controls and authentication</li>
            </ul>

            <h2 className="text-2xl font-bold mt-8 mb-4">Cookies and Tracking</h2>
            <p className="text-muted-foreground mb-4">
              We use cookies and similar tracking technologies to:
            </p>
            <ul className="list-disc pl-6 text-muted-foreground space-y-2 mb-6">
              <li>Maintain your login session</li>
              <li>Remember your preferences</li>
              <li>Analyze site traffic and usage</li>
              <li>Improve our services</li>
            </ul>
            <p className="text-muted-foreground mb-6">
              You can control cookie settings through your browser preferences.
            </p>

            <h2 className="text-2xl font-bold mt-8 mb-4">Your Rights</h2>
            <p className="text-muted-foreground mb-4">
              You have the right to:
            </p>
            <ul className="list-disc pl-6 text-muted-foreground space-y-2 mb-6">
              <li>Access your personal information</li>
              <li>Correct inaccurate data</li>
              <li>Request deletion of your account</li>
              <li>Export your data</li>
              <li>Opt-out of marketing communications</li>
              <li>Lodge a complaint with authorities</li>
            </ul>

            <h2 className="text-2xl font-bold mt-8 mb-4">Data Retention</h2>
            <p className="text-muted-foreground mb-6">
              We retain your personal information for as long as your account is active or as needed 
              to provide services. You can request account deletion at any time.
            </p>

            <h2 className="text-2xl font-bold mt-8 mb-4">Children&apos;s Privacy</h2>
            <p className="text-muted-foreground mb-6">
              Our service is not intended for users under 13 years of age. We do not knowingly 
              collect information from children under 13.
            </p>

            <h2 className="text-2xl font-bold mt-8 mb-4">Changes to This Policy</h2>
            <p className="text-muted-foreground mb-6">
              We may update this Privacy Policy from time to time. We will notify you of any changes 
              by posting the new policy on this page and updating the &quot;Last updated&quot; date.
            </p>

            <h2 className="text-2xl font-bold mt-8 mb-4">Contact Us</h2>
            <p className="text-muted-foreground mb-4">
              If you have questions about this Privacy Policy, please contact us:
            </p>
            <ul className="list-none text-muted-foreground space-y-2 mb-6">
              <li>Email: privacy@rigcheck.com</li>
              <li>Phone: +880 1234-567890</li>
            </ul>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
