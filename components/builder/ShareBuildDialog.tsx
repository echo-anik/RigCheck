'use client';

import { useState } from 'react';
import { Copy, Facebook, Twitter, MessageCircle, Check, Link as LinkIcon, Code, Download } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';

interface ShareBuildDialogProps {
  buildId: string;
  buildName: string;
  buildUrl: string;
  onClose: () => void;
  onExportPDF: () => void;
  onExportExcel: () => void;
}

export function ShareBuildDialog({ 
  buildId, 
  buildName, 
  buildUrl, 
  onClose,
  onExportPDF,
  onExportExcel
}: ShareBuildDialogProps) {
  const [copied, setCopied] = useState(false);
  const [embedCopied, setEmbedCopied] = useState(false);

  const embedCode = `<iframe src="${buildUrl}/embed" width="600" height="400" frameborder="0"></iframe>`;

  const handleCopyLink = async () => {
    try {
      await navigator.clipboard.writeText(buildUrl);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch (error) {
      console.error('Failed to copy:', error);
    }
  };

  const handleCopyEmbed = async () => {
    try {
      await navigator.clipboard.writeText(embedCode);
      setEmbedCopied(true);
      setTimeout(() => setEmbedCopied(false), 2000);
    } catch (error) {
      console.error('Failed to copy embed code:', error);
    }
  };

  const handleShareFacebook = () => {
    const url = `https://www.facebook.com/sharer/sharer.php?u=${encodeURIComponent(buildUrl)}`;
    window.open(url, '_blank', 'width=600,height=400');
  };

  const handleShareTwitter = () => {
    const text = `Check out my PC build: ${buildName}`;
    const url = `https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}&url=${encodeURIComponent(buildUrl)}`;
    window.open(url, '_blank', 'width=600,height=400');
  };

  const handleShareWhatsApp = () => {
    const text = `Check out my PC build: ${buildName} - ${buildUrl}`;
    const url = `https://wa.me/?text=${encodeURIComponent(text)}`;
    window.open(url, '_blank');
  };

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
      <Card className="w-full max-w-2xl max-h-[90vh] overflow-y-auto">
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle className="text-2xl">Share Your Build</CardTitle>
              <p className="text-muted-foreground mt-1">{buildName}</p>
            </div>
            <Button variant="ghost" onClick={onClose}>
              ✕
            </Button>
          </div>
        </CardHeader>
        <CardContent className="space-y-6">
          {/* Share Link */}
          <div>
            <h3 className="font-semibold mb-3 flex items-center gap-2">
              <LinkIcon className="h-4 w-4" />
              Share Link
            </h3>
            <div className="flex gap-2">
              <Input
                value={buildUrl}
                readOnly
                className="flex-1"
              />
              <Button
                variant={copied ? "default" : "outline"}
                onClick={handleCopyLink}
                className="flex-shrink-0"
              >
                {copied ? (
                  <>
                    <Check className="h-4 w-4 mr-2" />
                    Copied!
                  </>
                ) : (
                  <>
                    <Copy className="h-4 w-4 mr-2" />
                    Copy
                  </>
                )}
              </Button>
            </div>
            <p className="text-xs text-muted-foreground mt-2">
              Anyone with this link can view your build
            </p>
          </div>

          {/* Social Media Sharing */}
          <div>
            <h3 className="font-semibold mb-3">Share on Social Media</h3>
            <div className="grid grid-cols-3 gap-3">
              <Button
                variant="outline"
                onClick={handleShareFacebook}
                className="w-full"
              >
                <Facebook className="h-4 w-4 mr-2 text-blue-600" />
                Facebook
              </Button>
              <Button
                variant="outline"
                onClick={handleShareTwitter}
                className="w-full"
              >
                <Twitter className="h-4 w-4 mr-2 text-sky-500" />
                Twitter
              </Button>
              <Button
                variant="outline"
                onClick={handleShareWhatsApp}
                className="w-full"
              >
                <MessageCircle className="h-4 w-4 mr-2 text-green-600" />
                WhatsApp
              </Button>
            </div>
          </div>

          {/* Export Options */}
          <div>
            <h3 className="font-semibold mb-3 flex items-center gap-2">
              <Download className="h-4 w-4" />
              Export Build
            </h3>
            <div className="grid grid-cols-2 gap-3">
              <Button
                variant="outline"
                onClick={onExportPDF}
                className="w-full"
              >
                <Download className="h-4 w-4 mr-2" />
                Export as PDF
              </Button>
              <Button
                variant="outline"
                onClick={onExportExcel}
                className="w-full"
              >
                <Download className="h-4 w-4 mr-2" />
                Export as Excel
              </Button>
            </div>
            <p className="text-xs text-muted-foreground mt-2">
              Download your build specifications for offline viewing
            </p>
          </div>

          {/* Embed Code */}
          <div>
            <h3 className="font-semibold mb-3 flex items-center gap-2">
              <Code className="h-4 w-4" />
              Embed on Your Website
            </h3>
            <div className="space-y-2">
              <div className="bg-gray-50 p-3 rounded-lg border">
                <code className="text-xs break-all">{embedCode}</code>
              </div>
              <Button
                variant={embedCopied ? "default" : "outline"}
                onClick={handleCopyEmbed}
                className="w-full"
              >
                {embedCopied ? (
                  <>
                    <Check className="h-4 w-4 mr-2" />
                    Embed Code Copied!
                  </>
                ) : (
                  <>
                    <Copy className="h-4 w-4 mr-2" />
                    Copy Embed Code
                  </>
                )}
              </Button>
              <p className="text-xs text-muted-foreground">
                Paste this code into your website or blog to embed your build
              </p>
            </div>
          </div>

          {/* Build Stats */}
          <div className="border-t pt-4">
            <h3 className="font-semibold mb-3">Build Details</h3>
            <div className="grid grid-cols-2 gap-3">
              <div>
                <p className="text-sm text-muted-foreground">Build ID</p>
                <p className="font-mono text-sm">{buildId}</p>
              </div>
              <div>
                <p className="text-sm text-muted-foreground">Share Status</p>
                <Badge variant="default">Public</Badge>
              </div>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
