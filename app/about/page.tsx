import Link from 'next/link';
import { Hammer, Users, Award, TrendingUp, Shield, Zap } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';

export default function AboutPage() {
  return (
    <div className="min-h-screen bg-gray-50">
      {/* Hero Section */}
      <section className="bg-gradient-to-br from-primary to-blue-600 text-white py-20">
        <div className="max-w-7xl mx-auto px-4 text-center">
          <h1 className="text-5xl font-bold mb-6">About RigCheck</h1>
          <p className="text-xl text-blue-100 max-w-3xl mx-auto">
            Your trusted companion for building the perfect PC in Bangladesh. 
            We make PC building accessible, reliable, and fun.
          </p>
        </div>
      </section>

      {/* Mission Section */}
      <section className="py-16">
        <div className="max-w-7xl mx-auto px-4">
          <div className="grid md:grid-cols-2 gap-12 items-center">
            <div>
              <h2 className="text-3xl font-bold mb-6">Our Mission</h2>
              <p className="text-lg text-muted-foreground mb-4">
                RigCheck was founded with a simple goal: to make PC building easier for everyone in Bangladesh. 
                Whether you&apos;re a first-time builder or a seasoned enthusiast, we provide the tools and 
                information you need to make informed decisions.
              </p>
              <p className="text-lg text-muted-foreground mb-6">
                We understand the challenges of finding accurate pricing, checking compatibility, 
                and keeping up with the latest components. That&apos;s why we&apos;ve built a comprehensive 
                platform that brings everything together in one place.
              </p>
              <Button size="lg" asChild>
                <Link href="/builder">Start Building</Link>
              </Button>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <Card>
                <CardContent className="pt-6 text-center">
                  <div className="h-12 w-12 bg-primary/10 rounded-full flex items-center justify-center mx-auto mb-3">
                    <Hammer className="h-6 w-6 text-primary" />
                  </div>
                  <div className="text-3xl font-bold mb-1">19,962</div>
                  <div className="text-sm text-muted-foreground">Components</div>
                </CardContent>
              </Card>
              <Card>
                <CardContent className="pt-6 text-center">
                  <div className="h-12 w-12 bg-primary/10 rounded-full flex items-center justify-center mx-auto mb-3">
                    <Users className="h-6 w-6 text-primary" />
                  </div>
                  <div className="text-3xl font-bold mb-1">10,000+</div>
                  <div className="text-sm text-muted-foreground">Active Users</div>
                </CardContent>
              </Card>
              <Card>
                <CardContent className="pt-6 text-center">
                  <div className="h-12 w-12 bg-primary/10 rounded-full flex items-center justify-center mx-auto mb-3">
                    <Award className="h-6 w-6 text-primary" />
                  </div>
                  <div className="text-3xl font-bold mb-1">5,000+</div>
                  <div className="text-sm text-muted-foreground">Builds Created</div>
                </CardContent>
              </Card>
              <Card>
                <CardContent className="pt-6 text-center">
                  <div className="h-12 w-12 bg-primary/10 rounded-full flex items-center justify-center mx-auto mb-3">
                    <TrendingUp className="h-6 w-6 text-primary" />
                  </div>
                  <div className="text-3xl font-bold mb-1">99.9%</div>
                  <div className="text-sm text-muted-foreground">Uptime</div>
                </CardContent>
              </Card>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-16 bg-white">
        <div className="max-w-7xl mx-auto px-4">
          <h2 className="text-3xl font-bold text-center mb-12">What Makes Us Different</h2>
          <div className="grid md:grid-cols-3 gap-8">
            <Card>
              <CardContent className="pt-6">
                <div className="h-12 w-12 bg-blue-100 rounded-lg flex items-center justify-center mb-4">
                  <Shield className="h-6 w-6 text-blue-600" />
                </div>
                <h3 className="text-xl font-bold mb-3">Accurate Pricing</h3>
                <p className="text-muted-foreground">
                  Real-time pricing data from trusted retailers across Bangladesh. 
                  Get the best deals and compare prices easily.
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="pt-6">
                <div className="h-12 w-12 bg-green-100 rounded-lg flex items-center justify-center mb-4">
                  <Zap className="h-6 w-6 text-green-600" />
                </div>
                <h3 className="text-xl font-bold mb-3">Smart Compatibility</h3>
                <p className="text-muted-foreground">
                  Our advanced compatibility checker ensures all your components work together perfectly. 
                  No more guessing or compatibility issues.
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardContent className="pt-6">
                <div className="h-12 w-12 bg-purple-100 rounded-lg flex items-center justify-center mb-4">
                  <Users className="h-6 w-6 text-purple-600" />
                </div>
                <h3 className="text-xl font-bold mb-3">Community Driven</h3>
                <p className="text-muted-foreground">
                  Learn from thousands of builds shared by our community. 
                  Get inspired and share your own creations.
                </p>
              </CardContent>
            </Card>
          </div>
        </div>
      </section>

      {/* Team Section */}
      <section className="py-16">
        <div className="max-w-7xl mx-auto px-4">
          <h2 className="text-3xl font-bold text-center mb-6">Our Story</h2>
          <div className="max-w-3xl mx-auto text-center">
            <p className="text-lg text-muted-foreground mb-4">
              RigCheck was born out of frustration with the lack of reliable PC building resources 
              in Bangladesh. As PC enthusiasts ourselves, we struggled to find accurate pricing, 
              check compatibility, and compare components effectively.
            </p>
            <p className="text-lg text-muted-foreground mb-6">
              In 2024, we decided to build the solution ourselves. Today, RigCheck serves thousands 
              of users across Bangladesh, helping them build their dream PCs with confidence.
            </p>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-16 bg-gradient-to-br from-primary to-blue-600 text-white">
        <div className="max-w-4xl mx-auto px-4 text-center">
          <h2 className="text-4xl font-bold mb-6">Ready to Build Your Dream PC?</h2>
          <p className="text-xl text-blue-100 mb-8">
            Join thousands of satisfied builders and create your perfect setup today.
          </p>
          <div className="flex gap-4 justify-center">
            <Button size="lg" variant="secondary" asChild>
              <Link href="/builder">Start Building</Link>
            </Button>
            <Button size="lg" variant="outline" className="bg-white/10 hover:bg-white/20 text-white border-white" asChild>
              <Link href="/builds">View Builds</Link>
            </Button>
          </div>
        </div>
      </section>
    </div>
  );
}
