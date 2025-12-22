import Link from "next/link";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { ArrowRight, Cpu, Wrench, Shield, TrendingUp, Search } from "lucide-react";

export default function Home() {
  return (
    <div className="flex flex-col">
      {/* Hero Section */}
      <section className="relative py-20 md:py-32 px-4 bg-gradient-to-b from-primary/10 to-background">
        <div className="container max-w-6xl mx-auto">
          <div className="flex flex-col items-center text-center space-y-8">
            <div className="space-y-4 max-w-3xl">
              <h1 className="text-4xl md:text-6xl font-bold tracking-tight">
                Build Your Dream PC
                <span className="block text-primary mt-2">with Confidence</span>
              </h1>
              <p className="text-lg md:text-xl text-muted-foreground max-w-2xl mx-auto">
                Browse 20,000+ components, check compatibility in real-time, 
                and compare prices from top retailers in Bangladesh.
              </p>
            </div>

            {/* Search Bar */}
            <div className="w-full max-w-2xl">
              <div className="flex gap-2">
                <div className="relative flex-1">
                  <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-5 w-5 text-muted-foreground" />
                  <Input
                    placeholder="Search for components (CPU, GPU, RAM...)"
                    className="pl-10 h-12"
                  />
                </div>
                <Button size="lg" className="h-12 px-8">
                  Search
                </Button>
              </div>
            </div>

            {/* CTA Buttons */}
            <div className="flex flex-col sm:flex-row gap-4">
              <Button size="lg" asChild>
                <Link href="/builder">
                  Start Building <ArrowRight className="ml-2 h-4 w-4" />
                </Link>
              </Button>
              <Button size="lg" variant="outline" asChild>
                <Link href="/components">
                  Browse Components
                </Link>
              </Button>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 px-4 bg-muted/50">
        <div className="container max-w-6xl mx-auto">
          <div className="text-center mb-12">
            <h2 className="text-3xl md:text-4xl font-bold mb-4">
              Why Choose RigCheck?
            </h2>
            <p className="text-lg text-muted-foreground max-w-2xl mx-auto">
              The most comprehensive PC building platform in Bangladesh
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <Card>
              <CardHeader>
                <div className="h-12 w-12 rounded-lg bg-primary/10 flex items-center justify-center mb-4">
                  <Cpu className="h-6 w-6 text-primary" />
                </div>
                <CardTitle>20,000+ Components</CardTitle>
                <CardDescription>
                  Massive database of CPUs, GPUs, motherboards, and more
                </CardDescription>
              </CardHeader>
            </Card>

            <Card>
              <CardHeader>
                <div className="h-12 w-12 rounded-lg bg-primary/10 flex items-center justify-center mb-4">
                  <Shield className="h-6 w-6 text-primary" />
                </div>
                <CardTitle>Compatibility Check</CardTitle>
                <CardDescription>
                  Real-time validation ensures all parts work together
                </CardDescription>
              </CardHeader>
            </Card>

            <Card>
              <CardHeader>
                <div className="h-12 w-12 rounded-lg bg-primary/10 flex items-center justify-center mb-4">
                  <TrendingUp className="h-6 w-6 text-primary" />
                </div>
                <CardTitle>Price Comparison</CardTitle>
                <CardDescription>
                  Find the best deals from retailers across Bangladesh
                </CardDescription>
              </CardHeader>
            </Card>

            <Card>
              <CardHeader>
                <div className="h-12 w-12 rounded-lg bg-primary/10 flex items-center justify-center mb-4">
                  <Wrench className="h-6 w-6 text-primary" />
                </div>
                <CardTitle>Expert Tools</CardTitle>
                <CardDescription>
                  Compare specs, estimate power, and plan your budget
                </CardDescription>
              </CardHeader>
            </Card>
          </div>
        </div>
      </section>

      {/* Categories Section */}
      <section className="py-20 px-4">
        <div className="container max-w-6xl mx-auto">
          <div className="text-center mb-12">
            <h2 className="text-3xl md:text-4xl font-bold mb-4">
              Browse by Category
            </h2>
            <p className="text-lg text-muted-foreground">
              Explore our extensive component database
            </p>
          </div>

          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {[
              { name: "CPUs", count: "961", icon: "🔷", category: "cpu" },
              { name: "Motherboards", count: "4,950", icon: "🔲", category: "motherboard" },
              { name: "GPUs", count: "3,038", icon: "🎮", category: "gpu" },
              { name: "RAM", count: "1,500", icon: "💾", category: "ram" },
              { name: "Storage", count: "1,870", icon: "💿", category: "storage" },
              { name: "Power Supplies", count: "2,123", icon: "⚡", category: "psu" },
              { name: "Cases", count: "3,208", icon: "📦", category: "case" },
              { name: "Coolers", count: "2,312", icon: "❄️", category: "cooler" },
            ].map((category) => (
              <Link
                key={category.category}
                href={`/components?category=${category.category}`}
                className="group"
              >
                <Card className="h-full hover:border-primary transition-colors">
                  <CardHeader className="text-center">
                    <div className="text-4xl mb-2">{category.icon}</div>
                    <CardTitle className="text-lg">{category.name}</CardTitle>
                    <CardDescription className="text-sm">
                      {category.count} products
                    </CardDescription>
                  </CardHeader>
                </Card>
              </Link>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 px-4 bg-primary text-primary-foreground">
        <div className="container max-w-4xl mx-auto text-center">
          <h2 className="text-3xl md:text-4xl font-bold mb-4">
            Ready to Build Your PC?
          </h2>
          <p className="text-lg opacity-90 mb-8 max-w-2xl mx-auto">
            Join thousands of PC enthusiasts who trust RigCheck for their builds.
            Start building your dream setup today!
          </p>
          <div className="flex flex-col sm:flex-row gap-4 justify-center">
            <Button size="lg" variant="secondary" asChild>
              <Link href="/builder">
                Launch PC Builder <ArrowRight className="ml-2 h-4 w-4" />
              </Link>
            </Button>
            <Button size="lg" variant="outline" className="bg-transparent border-primary-foreground text-primary-foreground hover:bg-primary-foreground hover:text-primary" asChild>
              <Link href="/builds">
                Browse Build Gallery
              </Link>
            </Button>
          </div>
        </div>
      </section>
    </div>
  );
}
