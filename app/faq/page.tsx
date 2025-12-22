'use client';

import { useState } from 'react';
import { ChevronDown, ChevronUp, HelpCircle } from 'lucide-react';
import { Card, CardContent } from '@/components/ui/card';
import { Input } from '@/components/ui/input';

const faqs = [
  {
    category: 'General',
    questions: [
      {
        q: 'What is RigCheck?',
        a: 'RigCheck is a comprehensive PC building platform designed specifically for Bangladesh. We help you browse components, check compatibility, compare prices, and build your perfect PC with confidence.'
      },
      {
        q: 'Is RigCheck free to use?',
        a: 'Yes! RigCheck is completely free. You can browse components, create builds, and use all our tools without any charges. Create a free account to save your builds and access additional features.'
      },
      {
        q: 'Do you sell PC components?',
        a: 'No, we don\'t sell components directly. RigCheck is an information platform that helps you find the right components and compare prices from various retailers across Bangladesh.'
      },
    ]
  },
  {
    category: 'PC Building',
    questions: [
      {
        q: 'How do I start building a PC?',
        a: 'Go to the PC Builder page and select components for each category (CPU, GPU, motherboard, etc.). Our compatibility checker will alert you to any issues. Once you\'re happy with your build, save it to your account.'
      },
      {
        q: 'What if my components aren\'t compatible?',
        a: 'Our compatibility checker will highlight issues like socket mismatches, power supply insufficiency, or RAM incompatibility. Pay attention to warnings and choose alternative components if needed.'
      },
      {
        q: 'Can I share my builds with others?',
        a: 'Yes! When creating a build, you can set it as "public" to share it with the community. You\'ll get a shareable link that you can send to friends or post on social media.'
      },
      {
        q: 'How do I know if a build is good for gaming?',
        a: 'Look for builds tagged as "Gaming" in the Build Gallery. Pay attention to GPU and CPU specs. Generally, mid-range to high-end graphics cards (RTX 4060 and above) are suitable for modern gaming.'
      },
    ]
  },
  {
    category: 'Pricing & Availability',
    questions: [
      {
        q: 'How accurate is your pricing data?',
        a: 'We update pricing data regularly from trusted retailers across Bangladesh. However, prices fluctuate. Always verify the current price with the retailer before purchasing.'
      },
      {
        q: 'Why are prices in BDT?',
        a: 'RigCheck is designed for Bangladesh, so all prices are displayed in Bangladeshi Taka (BDT) to make it easier for local buyers.'
      },
      {
        q: 'Can you notify me when prices drop?',
        a: 'Price tracking and alerts are coming soon! For now, you can add components to your wishlist and check back regularly for price updates.'
      },
      {
        q: 'What if a component shows "Out of Stock"?',
        a: 'Out of stock items are still shown for reference and comparison. Check back later or look for alternative components from the same category.'
      },
    ]
  },
  {
    category: 'Account & Features',
    questions: [
      {
        q: 'Why should I create an account?',
        a: 'With an account, you can save unlimited builds, create a wishlist, make builds public to share with others, and access your build history from any device.'
      },
      {
        q: 'How do I reset my password?',
        a: 'Click "Forgot Password" on the login page. Enter your email and we\'ll send you instructions to reset your password.'
      },
      {
        q: 'Can I delete my account?',
        a: 'Yes. Go to your profile settings and select "Delete Account". Note that this action is permanent and will delete all your saved builds.'
      },
      {
        q: 'What\'s the difference between public and private builds?',
        a: 'Public builds are visible to all users and appear in the Build Gallery. Private builds are only visible to you and perfect for works-in-progress or personal references.'
      },
    ]
  },
  {
    category: 'Compatibility',
    questions: [
      {
        q: 'How does the compatibility checker work?',
        a: 'Our system checks socket types, power requirements, RAM compatibility, case size, and other technical specifications to ensure all components work together properly.'
      },
      {
        q: 'Can the compatibility checker make mistakes?',
        a: 'While we strive for 100% accuracy, we recommend double-checking critical specifications (especially motherboard socket, PSU wattage, and case clearance) before purchasing.'
      },
      {
        q: 'What do the compatibility warnings mean?',
        a: 'Yellow warnings indicate potential issues that may need attention. Red errors indicate critical incompatibilities that will prevent your build from working. Fix all errors before purchasing.'
      },
    ]
  },
  {
    category: 'Technical Support',
    questions: [
      {
        q: 'I found incorrect information. How do I report it?',
        a: 'Please contact us through the Contact page with details about the error. We appreciate community feedback and will investigate and correct issues promptly.'
      },
      {
        q: 'Why isn\'t a specific component showing up?',
        a: 'Our database is constantly growing. If a component is missing, it may not be available in Bangladesh or hasn\'t been added yet. Contact us to request specific components.'
      },
      {
        q: 'The website isn\'t working properly. What should I do?',
        a: 'Try clearing your browser cache and cookies, or try a different browser. If the issue persists, contact our support team with details about the problem.'
      },
    ]
  },
];

export default function FAQPage() {
  const [searchQuery, setSearchQuery] = useState('');
  const [openItems, setOpenItems] = useState<string[]>([]);

  const toggleItem = (id: string) => {
    setOpenItems(prev =>
      prev.includes(id) ? prev.filter(item => item !== id) : [...prev, id]
    );
  };

  const filteredFaqs = faqs.map(category => ({
    ...category,
    questions: category.questions.filter(
      item =>
        item.q.toLowerCase().includes(searchQuery.toLowerCase()) ||
        item.a.toLowerCase().includes(searchQuery.toLowerCase())
    )
  })).filter(category => category.questions.length > 0);

  return (
    <div className="min-h-screen bg-gray-50 py-12">
      <div className="max-w-4xl mx-auto px-4">
        {/* Header */}
        <div className="text-center mb-12">
          <div className="h-16 w-16 bg-primary/10 rounded-full flex items-center justify-center mx-auto mb-4">
            <HelpCircle className="h-8 w-8 text-primary" />
          </div>
          <h1 className="text-4xl font-bold mb-4">Frequently Asked Questions</h1>
          <p className="text-xl text-muted-foreground max-w-2xl mx-auto mb-8">
            Find answers to common questions about RigCheck and PC building.
          </p>

          {/* Search */}
          <div className="max-w-xl mx-auto">
            <Input
              type="search"
              placeholder="Search for answers..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="h-12 text-lg"
            />
          </div>
        </div>

        {/* FAQ Categories */}
        {filteredFaqs.length === 0 ? (
          <Card>
            <CardContent className="py-12 text-center">
              <p className="text-muted-foreground">
                No results found for &quot;{searchQuery}&quot;
              </p>
            </CardContent>
          </Card>
        ) : (
          <div className="space-y-8">
            {filteredFaqs.map((category, catIndex) => (
              <div key={catIndex}>
                <h2 className="text-2xl font-bold mb-4">{category.category}</h2>
                <div className="space-y-3">
                  {category.questions.map((item, itemIndex) => {
                    const id = `${catIndex}-${itemIndex}`;
                    const isOpen = openItems.includes(id);

                    return (
                      <Card key={id} className="overflow-hidden">
                        <button
                          onClick={() => toggleItem(id)}
                          className="w-full px-6 py-4 flex items-center justify-between text-left hover:bg-gray-50 transition-colors"
                        >
                          <span className="font-semibold pr-4">{item.q}</span>
                          {isOpen ? (
                            <ChevronUp className="h-5 w-5 text-muted-foreground flex-shrink-0" />
                          ) : (
                            <ChevronDown className="h-5 w-5 text-muted-foreground flex-shrink-0" />
                          )}
                        </button>
                        {isOpen && (
                          <CardContent className="px-6 pb-4">
                            <p className="text-muted-foreground">{item.a}</p>
                          </CardContent>
                        )}
                      </Card>
                    );
                  })}
                </div>
              </div>
            ))}
          </div>
        )}

        {/* Still have questions */}
        <Card className="mt-12 bg-gradient-to-br from-primary to-blue-600 text-white">
          <CardContent className="py-8 text-center">
            <h3 className="text-2xl font-bold mb-2">Still have questions?</h3>
            <p className="text-blue-100 mb-6">
              Can&apos;t find what you&apos;re looking for? Our support team is here to help.
            </p>
            <div className="flex gap-4 justify-center flex-wrap">
              <a
                href="/contact"
                className="inline-flex items-center justify-center px-6 py-3 bg-white text-primary rounded-md font-medium hover:bg-blue-50 transition-colors"
              >
                Contact Support
              </a>
              <a
                href="mailto:support@rigcheck.com"
                className="inline-flex items-center justify-center px-6 py-3 bg-white/10 text-white rounded-md font-medium hover:bg-white/20 transition-colors border border-white/20"
              >
                Email Us
              </a>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
