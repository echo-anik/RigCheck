'use client';

import { useEffect, useState, Suspense } from 'react';
import { useSearchParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { Settings, User as UserIcon, Package, Edit, Share2, Trash2 } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Badge } from '@/components/ui/badge';
import { useAuth } from '@/lib/auth-context';
import { ApiClient, Build } from '@/lib/api';

const api = new ApiClient(process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8000/api/v1');

function ProfilePageContent() {
  const { user, isAuthenticated, loading: authLoading } = useAuth();
  const searchParams = useSearchParams();
  const router = useRouter();
  const activeTab = searchParams.get('tab') || 'profile';
  const [userBuilds, setUserBuilds] = useState<Build[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    if (isAuthenticated && activeTab === 'builds') {
      loadUserBuilds();
    }
  }, [isAuthenticated, activeTab]);

  const loadUserBuilds = async () => {
    setLoading(true);
    try {
      const response = await api.getBuilds({ is_public: false, per_page: 50 });
      setUserBuilds(response.data);
    } catch (error) {
      console.error('Failed to load builds:', error);
    } finally {
      setLoading(false);
    }
  };

  const formatPrice = (price: number | string | null | undefined) => {
    if (!price) return 'N/A';
    const numPrice = typeof price === 'string' ? parseFloat(price) : price;
    return `৳${numPrice.toLocaleString('en-BD')}`;
  };

  if (authLoading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">
          <div className="inline-block h-8 w-8 animate-spin rounded-full border-4 border-solid border-current border-r-transparent" />
          <p className="mt-4 text-muted-foreground">Loading...</p>
        </div>
      </div>
    );
  }

  if (!isAuthenticated) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <Card className="max-w-md mx-auto">
          <CardContent className="py-12 text-center">
            <UserIcon className="h-16 w-16 text-muted-foreground mx-auto mb-4" />
            <h2 className="text-2xl font-bold mb-2">Sign In Required</h2>
            <p className="text-muted-foreground mb-6">
              Please sign in to view your profile
            </p>
            <Button asChild>
              <Link href="/">Go to Home</Link>
            </Button>
          </CardContent>
        </Card>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {/* Profile Header */}
        <Card className="mb-8">
          <CardContent className="p-6">
            <div className="flex items-center gap-6">
              <div className="h-24 w-24 rounded-full bg-primary flex items-center justify-center">
                <span className="text-primary-foreground font-bold text-3xl">
                  {user?.name.charAt(0).toUpperCase()}
                </span>
              </div>
              <div className="flex-1">
                <div className="flex items-center gap-2 mb-2">
                  <h1 className="text-3xl font-bold">{user?.name}</h1>
                  {user?.role === 'admin' && (
                    <Badge className="bg-orange-600 hover:bg-orange-700">
                      ⚡ Admin
                    </Badge>
                  )}
                </div>
                <p className="text-muted-foreground mb-3">{user?.email}</p>
                <div className="flex gap-4 text-sm">
                  <span>Member since {new Date(user?.created_at || '').toLocaleDateString()}</span>
                  {user?.role === 'admin' && (
                    <span className="text-orange-600 font-semibold">• Administrator</span>
                  )}
                </div>
              </div>
              <div className="flex gap-2">
                {user?.role === 'admin' && (
                  <Button variant="default" className="bg-orange-600 hover:bg-orange-700" asChild>
                    <Link href="/admin">
                      <span className="mr-2">⚡</span>
                      Admin Panel
                    </Link>
                  </Button>
                )}
                <Button variant="outline">
                  <Settings className="h-4 w-4 mr-2" />
                  Edit Profile
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Tabs */}
        <div className="flex gap-4 border-b mb-6 overflow-x-auto">
          <Link
            href="/profile?tab=profile"
            className={`pb-3 px-2 border-b-2 transition-colors whitespace-nowrap ${
              activeTab === 'profile'
                ? 'border-primary text-primary font-medium'
                : 'border-transparent text-muted-foreground hover:text-foreground'
            }`}
          >
            Profile
          </Link>
          <Link
            href="/profile?tab=builds"
            className={`pb-3 px-2 border-b-2 transition-colors whitespace-nowrap ${
              activeTab === 'builds'
                ? 'border-primary text-primary font-medium'
                : 'border-transparent text-muted-foreground hover:text-foreground'
            }`}
          >
            My Builds
          </Link>
          <Link
            href="/profile?tab=activity"
            className={`pb-3 px-2 border-b-2 transition-colors whitespace-nowrap ${
              activeTab === 'activity'
                ? 'border-primary text-primary font-medium'
                : 'border-transparent text-muted-foreground hover:text-foreground'
            }`}
          >
            Activity
          </Link>
          <Link
            href="/profile?tab=notifications"
            className={`pb-3 px-2 border-b-2 transition-colors whitespace-nowrap ${
              activeTab === 'notifications'
                ? 'border-primary text-primary font-medium'
                : 'border-transparent text-muted-foreground hover:text-foreground'
            }`}
          >
            Notifications
          </Link>
          <Link
            href="/profile?tab=settings"
            className={`pb-3 px-2 border-b-2 transition-colors whitespace-nowrap ${
              activeTab === 'settings'
                ? 'border-primary text-primary font-medium'
                : 'border-transparent text-muted-foreground hover:text-foreground'
            }`}
          >
            Settings
          </Link>
        </div>

        {/* Tab Content */}
        {activeTab === 'profile' && (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <Card>
              <CardHeader>
                <CardTitle>Personal Information</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div>
                  <label className="text-sm font-medium text-muted-foreground">Name</label>
                  <Input value={user?.name} disabled className="mt-1" />
                </div>
                <div>
                  <label className="text-sm font-medium text-muted-foreground">Email</label>
                  <Input value={user?.email} disabled className="mt-1" />
                </div>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Account Statistics</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="flex justify-between py-2 border-b">
                  <span className="text-muted-foreground">Member Since</span>
                  <span className="font-semibold">{user?.created_at ? new Date(user.created_at).getFullYear() : '—'}</span>
                </div>
                <div className="flex justify-between py-2 border-b">
                  <span className="text-muted-foreground">Status</span>
                  <span className="font-semibold text-green-600">Active</span>
                </div>
                <div className="flex justify-between py-2">
                  <span className="text-muted-foreground">Verified</span>
                  <span className="font-semibold">✓</span>
                </div>
              </CardContent>
            </Card>
          </div>
        )}

        {activeTab === 'builds' && (
          <div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-2xl font-bold">My Builds</h2>
              <Button asChild>
                <Link href="/builder">
                  <Package className="h-4 w-4 mr-2" />
                  Create New Build
                </Link>
              </Button>
            </div>

            {loading ? (
              <div className="text-center py-12">
                <div className="inline-block h-8 w-8 animate-spin rounded-full border-4 border-solid border-current border-r-transparent" />
                <p className="mt-4 text-muted-foreground">Loading builds...</p>
              </div>
            ) : userBuilds.length > 0 ? (
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {userBuilds.map((build) => (
                  <Card key={build.id} className="hover:shadow-lg transition-shadow h-full">
                    <CardContent className="p-6">
                      <div className="aspect-video bg-gray-100 rounded-lg mb-4 flex items-center justify-center">
                        <span className="text-gray-400">Build Image</span>
                      </div>
                      
                      <h3 className="font-semibold mb-2 line-clamp-1">
                        {build.name}
                      </h3>
                      
                      {build.description && (
                        <p className="text-sm text-muted-foreground mb-3 line-clamp-2">
                          {build.description}
                        </p>
                      )}
                      
                      <div className="flex items-center justify-between mb-3">
                        <span className="text-lg font-bold text-primary">
                          {formatPrice(build.total_price)}
                        </span>
                        {build.visibility === 'public' ? (
                          <Badge>Public</Badge>
                        ) : (
                          <Badge variant="secondary">Private</Badge>
                        )}
                      </div>
                      
                      <div className="flex gap-4 text-sm text-muted-foreground mb-4">
                        <span>{build.is_complete ? 'Complete' : 'Incomplete'}</span>
                      </div>

                      {/* Action Buttons */}
                      <div className="flex gap-2">
                        <Button
                          variant="outline"
                          size="sm"
                          className="flex-1"
                          onClick={() => {
                            sessionStorage.setItem('editingBuildId', build.id.toString());
                            router.push('/builder');
                          }}
                        >
                          <Edit className="h-3 w-3 mr-1" />
                          Edit
                        </Button>
                        <Button
                          variant="outline"
                          size="sm"
                          className="flex-1"
                          onClick={async () => {
                            if (build.share_id) {
                              const shareUrl = `${window.location.origin}/shared/${build.share_id}`;
                              await navigator.clipboard.writeText(shareUrl);
                              const { toast } = await import('sonner');
                              toast.success('Link copied to clipboard!');
                            } else {
                              const { toast } = await import('sonner');
                              toast.info('Creating share link...', { description: 'Please save your build first to enable sharing.' });
                            }
                          }}
                        >
                          <Share2 className="h-3 w-3 mr-1" />
                          Share
                        </Button>
                        <Button
                          variant="destructive"
                          size="sm"
                          onClick={async () => {
                            if (!confirm('Are you sure you want to delete this build?')) return;
                            try {
                              await api.deleteBuild(build.id);
                              const { toast } = await import('sonner');
                              toast.success('Build deleted successfully');
                              // Refresh builds list
                              const response = await api.getBuilds({ is_public: false, per_page: 50 });
                              setUserBuilds(response.data);
                            } catch (error) {
                              const { toast } = await import('sonner');
                              toast.error('Failed to delete build');
                              console.error('Delete failed:', error);
                            }
                          }}
                        >
                          <Trash2 className="h-3 w-3" />
                        </Button>
                      </div>
                    </CardContent>
                  </Card>
                ))}
              </div>
            ) : (
              <Card>
                <CardContent className="py-12 text-center">
                  <Package className="h-16 w-16 text-muted-foreground mx-auto mb-4" />
                  <h3 className="text-xl font-semibold mb-2">No Builds Yet</h3>
                  <p className="text-muted-foreground mb-6">
                    Start building your dream PC with our PC Builder tool
                  </p>
                  <Button asChild>
                    <Link href="/builder">Create Your First Build</Link>
                  </Button>
                </CardContent>
              </Card>
            )}
          </div>
        )}

        {activeTab === 'activity' && (
          <Card>
            <CardHeader>
              <CardTitle>Recent Activity</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-center py-8 text-muted-foreground">
                <p>Your recent posts, likes, and comments will appear here.</p>
                <Button asChild className="mt-4">
                  <Link href="/feed">Go to Feed</Link>
                </Button>
              </div>
            </CardContent>
          </Card>
        )}

        {activeTab === 'notifications' && (
          <Card>
            <CardHeader>
              <CardTitle>Notifications</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="text-center py-8 text-muted-foreground">
                <p>Your notifications will appear here.</p>
              </div>
            </CardContent>
          </Card>
        )}

        {activeTab === 'settings' && (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <Card>
              <CardHeader>
                <CardTitle>Profile Settings</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div>
                  <label className="text-sm font-medium text-muted-foreground">Display Name</label>
                  <Input value={user?.name || ''} onChange={() => {}} className="mt-1" />
                </div>
                <div>
                  <label className="text-sm font-medium text-muted-foreground">Bio</label>
                  <Input placeholder="Tell us about yourself" onChange={() => {}} className="mt-1" />
                </div>
                <Button>Save Changes</Button>
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle>Account Settings</CardTitle>
              </CardHeader>
              <CardContent className="space-y-4">
                <div>
                  <label className="text-sm font-medium text-muted-foreground">Email</label>
                  <Input value={user?.email} disabled className="mt-1" />
                </div>
                <Button variant="outline">Change Password</Button>
              </CardContent>
            </Card>
          </div>
        )}
      </div>
    </div>
  );
}

export default function ProfilePage() {
  return (
    <Suspense fallback={<div className="min-h-screen bg-gray-50 flex items-center justify-center"><p>Loading...</p></div>}>
      <ProfilePageContent />
    </Suspense>
  );
}
