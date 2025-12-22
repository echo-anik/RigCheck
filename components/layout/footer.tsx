import Link from "next/link";

export function Footer() {
  return (
    <footer className="border-t bg-muted/50">
      <div className="container py-12">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
          {/* About */}
          <div>
            <h3 className="font-semibold mb-4">About RigCheck</h3>
            <p className="text-sm text-muted-foreground">
              The ultimate PC building platform for Bangladesh. Compare components, 
              check compatibility, and build your dream PC.
            </p>
          </div>

          {/* Quick Links */}
          <div>
            <h3 className="font-semibold mb-4">Quick Links</h3>
            <ul className="space-y-2 text-sm">
              <li>
                <Link href="/components" className="text-muted-foreground hover:text-primary transition-colors">
                  Browse Components
                </Link>
              </li>
              <li>
                <Link href="/builds" className="text-muted-foreground hover:text-primary transition-colors">
                  Build Gallery
                </Link>
              </li>
              <li>
                <Link href="/builder" className="text-muted-foreground hover:text-primary transition-colors">
                  PC Builder Tool
                </Link>
              </li>
              <li>
                <Link href="/compare" className="text-muted-foreground hover:text-primary transition-colors">
                  Compare Components
                </Link>
              </li>
              <li>
                <Link href="/wishlist" className="text-muted-foreground hover:text-primary transition-colors">
                  Wishlist
                </Link>
              </li>
            </ul>
          </div>

          {/* Resources */}
          <div>
            <h3 className="font-semibold mb-4">Resources</h3>
            <ul className="space-y-2 text-sm">
              <li>
                <Link href="/about" className="text-muted-foreground hover:text-primary transition-colors">
                  About Us
                </Link>
              </li>
              <li>
                <Link href="/faq" className="text-muted-foreground hover:text-primary transition-colors">
                  FAQ
                </Link>
              </li>
              <li>
                <Link href="/contact" className="text-muted-foreground hover:text-primary transition-colors">
                  Contact Us
                </Link>
              </li>
            </ul>
          </div>

          {/* Legal */}
          <div>
            <h3 className="font-semibold mb-4">Legal</h3>
            <ul className="space-y-2 text-sm">
              <li>
                <Link href="/privacy" className="text-muted-foreground hover:text-primary transition-colors">
                  Privacy Policy
                </Link>
              </li>
              <li>
                <Link href="/terms" className="text-muted-foreground hover:text-primary transition-colors">
                  Terms of Service
                </Link>
              </li>
            </ul>
          </div>
        </div>

        <div className="mt-8 pt-8 border-t text-center text-sm text-muted-foreground">
          <p>© {new Date().getFullYear()} RigCheck. All rights reserved.</p>
        </div>
      </div>
    </footer>
  );
}
