import Link from 'next/link';
import { Card, CardContent, CardFooter, CardHeader } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Eye, Heart, Share2, Cpu, MemoryStick } from 'lucide-react';
import type { Build } from '@/lib/api';

const DEMO_IMAGES = Array.from({ length: 26 }, (_, i) => `/demo-images/image (${i + 1}).jpg`);

const pickDemoImage = (seed?: string | number | null) => {
  if (!seed || DEMO_IMAGES.length === 0) return undefined;
  const str = String(seed);
  let hash = 0;
  for (let i = 0; i < str.length; i++) {
    hash = (hash * 31 + str.charCodeAt(i)) >>> 0;
  }
  return DEMO_IMAGES[hash % DEMO_IMAGES.length];
};

interface BuildCardProps {
  build: Build;
}

export function BuildCard({ build }: BuildCardProps) {
  const formatPrice = (price: number | string | null | undefined) => {
    if (!price) return 'N/A';
    const numPrice = typeof price === 'string' ? parseFloat(price) : price;
    return `৳${numPrice.toLocaleString('en-BD')}`;
  };

  const previewImage = build.components?.[0]?.image_urls?.[0]
    || build.components?.[0]?.primary_image_url
    || pickDemoImage(build.id ?? build.name);

  const getCompatibilityColor = (status?: string) => {
    switch (status) {
      case 'valid':
        return 'bg-green-500';
      case 'warnings':
        return 'bg-yellow-500';
      case 'errors':
        return 'bg-red-500';
      default:
        return 'bg-gray-500';
    }
  };

  const getCompatibilityText = (status?: string) => {
    switch (status) {
      case 'valid':
        return 'Compatible';
      case 'warnings':
        return 'Minor Issues';
      case 'errors':
        return 'Incompatible';
      default:
        return 'Unknown';
    }
  };

  return (
    <Card className="group hover:shadow-xl transition-all duration-300 overflow-hidden h-full flex flex-col">
      <Link href={`/builds/${build.id}`} className="flex-1 flex flex-col">
        {/* Build Image/Preview */}
        <div className="relative aspect-video bg-gradient-to-br from-primary/20 to-primary/5 overflow-hidden">
          {previewImage ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img
              src={previewImage}
              alt={build.name}
              className="absolute inset-0 h-full w-full object-cover"
            />
          ) : (
            <div className="absolute inset-0 flex items-center justify-center">
              <div className="text-center">
                <Cpu className="h-16 w-16 mx-auto mb-2 text-primary/40" />
                <p className="text-sm text-muted-foreground">Build Preview</p>
              </div>
            </div>
          )}
          
          {/* Compatibility Badge */}
          <div className="absolute top-3 right-3">
            <Badge className={`${getCompatibilityColor(build.compatibility_status)} text-white`}>
              {getCompatibilityText(build.compatibility_status)}
            </Badge>
          </div>

        </div>

        <CardHeader className="pb-3">
          <div className="flex items-start justify-between gap-2">
            <h3 className="font-bold text-lg line-clamp-2 group-hover:text-primary transition-colors">
              {build.name}
            </h3>
          </div>
          
          {build.description && (
            <p className="text-sm text-muted-foreground line-clamp-2 mt-2">
              {build.description}
            </p>
          )}
        </CardHeader>

        <CardContent className="pb-3 flex-1">
          {/* Component Summary */}
          <div className="space-y-2">
            <div className="flex items-center gap-2 text-sm">
              <MemoryStick className="h-4 w-4 text-muted-foreground" />
              <span className="text-muted-foreground">
                {build.components?.length || 0} Components
              </span>
            </div>
          </div>

          {/* Price */}
          <div className="mt-4">
            <div className="text-sm text-muted-foreground">Total Price</div>
            <div className="text-2xl font-bold text-primary">
              {formatPrice(build.total_price)}
            </div>
          </div>
        </CardContent>

        <CardFooter className="pt-3 flex items-center justify-between border-t">
          {/* Stats */}
          <div className="flex items-center gap-4 text-sm text-muted-foreground">
            <div className="flex items-center gap-1">
              <Eye className="h-4 w-4" />
              <span>{build.is_complete ? 'Complete' : 'Incomplete'}</span>
            </div>
            <div className="flex items-center gap-1">
              <Heart className="h-4 w-4" />
              <span>{build.visibility === 'public' ? 'Public' : 'Private'}</span>
            </div>
          </div>

          {/* Share Button */}
          <Button
            variant="ghost"
            size="sm"
            onClick={(e) => {
              e.preventDefault();
              e.stopPropagation();
              const url = build.share_url || `${window.location.origin}/builds/${build.id}`;
              if (navigator.share) {
                navigator.share({ title: build.name, url }).catch(() => navigator.clipboard.writeText(url));
              } else {
                navigator.clipboard.writeText(url);
              }
            }}
            className="group-hover:bg-primary group-hover:text-primary-foreground transition-colors"
          >
            <Share2 className="h-4 w-4 mr-1" />
            Share
          </Button>
        </CardFooter>
      </Link>
    </Card>
  );
}
