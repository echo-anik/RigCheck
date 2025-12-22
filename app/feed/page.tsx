'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { useAuth } from '@/lib/auth-context';
import { ApiClient, Build } from '@/lib/api';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Eye, Heart, MessageSquare, Share2, User } from 'lucide-react';

const api = new ApiClient(process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8000/api/v1');

export default function FeedPage() {
  const { user, isAuthenticated, loading: authLoading } = useAuth();
  const router = useRouter();
  const [builds, setBuilds] = useState<Build[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Require authentication to view feed
    if (!authLoading && !isAuthenticated) {
      router.push('/login?redirect=/feed');
      return;
    }
    
    if (isAuthenticated) {
      fetchSharedBuilds();
    }
  }, [isAuthenticated, authLoading, router]);

  const fetchSharedBuilds = async () => {
    setLoading(true);
    try {
      // Fetch all builds and filter to show only publicly shared ones
      const response = await api.getBuilds({ 
        per_page: 50,
      });
      // Only show public/shared builds in the feed (builds with share_token)
      const sharedBuilds = response.data.filter((build: Build) => {
        return build.share_token && build.share_token.length > 0;
      });
      // Sort by most recent
      sharedBuilds.sort((a, b) => {
        return new Date(b.created_at || 0).getTime() - new Date(a.created_at || 0).getTime();
      });
      setBuilds(sharedBuilds);
    } catch (error) {
      console.error('Failed to fetch builds:', error);
    } finally {
      setLoading(false);
    }
  };

  const formatPrice = (price: number | string | null | undefined) => {
    if (!price) return 'N/A';
    const numPrice = typeof price === 'string' ? parseFloat(price) : price;
    return `৳${numPrice.toLocaleString('en-BD')}`;
  };

  const getCompatibilityBadge = (status?: string) => {
    if (!status || status === 'valid') {
      return <Badge className="bg-green-500">Compatible</Badge>;
    } else if (status === 'warnings') {
      return <Badge className="bg-yellow-500">Warnings</Badge>;
    } else {
      return <Badge className="bg-red-500">Errors</Badge>;
    }
  };

  if (authLoading || loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <p>Loading shared builds...</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 py-8">
      <div className="max-w-5xl mx-auto px-4">
        {/* Header */}
        <div className="mb-6">
          <h1 className="text-3xl font-bold mb-2">Community Builds Feed</h1>
          <p className="text-gray-600">Discover PC builds shared by the RigCheck community</p>
        </div>

        {/* Shared Builds Feed */}
        {builds.length === 0 ? (
          <Card>
            <CardContent className="text-center py-12">
              <Share2 className="h-16 w-16 text-muted-foreground mx-auto mb-4" />
              <h2 className="text-xl font-semibold mb-2">No Shared Builds Yet</h2>
              <p className="text-muted-foreground mb-4">
                Be the first to share your PC build with the community!
              </p>
              <Button asChild>
                <Link href="/builder">Create a Build</Link>
              </Button>
            </CardContent>
          </Card>
        ) : (
          <div className="grid gap-6 md:grid-cols-2">
            {builds.map((build) => (
              <Card key={build.id} className="hover:shadow-lg transition-shadow">
                <CardHeader>
                  <div className="flex items-start justify-between">
                    <div className="flex-1">
                      <CardTitle className="text-xl mb-2">
                        <Link 
                          href={`/builds/${build.id}`}
                          className="hover:text-blue-600 transition-colors"
                        >
                          {build.name || 'Unnamed Build'}
                        </Link>
                      </CardTitle>
                      <div className="flex items-center gap-2 text-sm text-muted-foreground mb-2">
                        <User className="h-4 w-4" />
                        <span>Shared by user</span>
                      </div>
                    </div>
                    {getCompatibilityBadge(build.compatibility_status)}
                  </div>
                </CardHeader>
                <CardContent>
                  {build.description && (
                    <p className="text-sm text-gray-600 mb-4 line-clamp-2">
                      {build.description}
                    </p>
                  )}

                  {/* Build Stats */}
                  <div className="grid grid-cols-2 gap-4 mb-4">
                    <div>
                      <div className="text-sm text-muted-foreground">Total Cost</div>
                      <div className="text-lg font-bold text-green-600">
                        {formatPrice(build.total_price)}
                      </div>
                    </div>
                    <div>
                      <div className="text-sm text-muted-foreground">Components</div>
                      <div className="text-lg font-bold">
                        {build.components?.length || 0}
                      </div>
                    </div>
                  </div>

                  {/* Social Stats */}
                  <div className="flex items-center gap-4 text-sm text-muted-foreground border-t pt-4">
                    <div className="flex items-center gap-1">
                      <Eye className="h-4 w-4" />
                      <span>{build.view_count || 0} views</span>
                    </div>
                    <div className="flex items-center gap-1">
                      <Heart className="h-4 w-4" />
                      <span>{build.like_count || 0} likes</span>
                    </div>
                    <div className="flex items-center gap-1">
                      <MessageSquare className="h-4 w-4" />
                      <span>{build.comment_count || 0} comments</span>
                    </div>
                  </div>

                  {/* Use Case Badge */}
                  {build.use_case && (
                    <div className="mt-4">
                      <Badge variant="outline" className="capitalize">
                        {build.use_case}
                      </Badge>
                    </div>
                  )}

                  {/* View Details Button */}
                  <Button asChild className="w-full mt-4">
                    <Link href={`/builds/${build.id}`}>
                      View Build Details
                    </Link>
                  </Button>
                </CardContent>
              </Card>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
