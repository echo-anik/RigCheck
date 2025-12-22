'use client';

import { useEffect, useState } from 'react';
import { Users, FileText, Package, Cpu } from 'lucide-react';
import Link from 'next/link';
import { Button } from '@/components/ui/button';

interface Stats {
  total_users: number;
  total_components: number;
  total_builds: number;
  total_posts: number;
  components_by_category: { [key: string]: number };
  recent_users: any[];
  recent_builds: any[];
  recent_posts: any[];
}

export default function AdminDashboard() {
  const [stats, setStats] = useState<Stats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    try {
      const token = localStorage.getItem('auth_token');
      const response = await fetch(`${process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8002/api/v1'}/admin/stats`, {
        headers: {
          ...(token ? { 'Authorization': `Bearer ${token}` } : {}),
          'Accept': 'application/json',
        },
      });

      if (response.status === 401 || response.status === 403) {
        setError('Access denied. Please sign in with an admin account.');
        return;
      }

      if (!response.ok) {
        throw new Error(`Failed to load admin stats (${response.status})`);
      }

      const data = await response.json();
      setStats(data.data);
    } catch (error) {
      console.error('Failed to fetch stats:', error);
      setError(error instanceof Error ? error.message : 'Failed to load statistics');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div className="text-center py-8">Loading statistics...</div>;
  }

  if (error) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
        <div className="max-w-md w-full bg-white shadow rounded p-6 text-center space-y-4">
          <div className="text-lg font-semibold">Admin Access Required</div>
          <p className="text-muted-foreground text-sm">{error}</p>
          <Button asChild className="w-full">
            <Link href="/auth/signin">Sign in</Link>
          </Button>
        </div>
      </div>
    );
  }

  if (!stats) {
    return <div className="text-center py-8">Failed to load statistics</div>;
  }
  const statCards = [
    {
      title: 'Total Users',
      value: stats.total_users,
      icon: Users,
      color: 'bg-blue-500',
    },
    {
      title: 'Total Components',
      value: stats.total_components.toLocaleString(),
      icon: Cpu,
      color: 'bg-green-500',
    },
    {
      title: 'Total Builds',
      value: stats.total_builds,
      icon: Package,
      color: 'bg-purple-500',
    },
    {
      title: 'Total Posts',
      value: stats.total_posts,
      icon: FileText,
      color: 'bg-orange-500',
    },
  ];

  return (
    <div>
      <h1 className="text-3xl font-bold mb-8">Dashboard</h1>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        {statCards.map((stat) => {
          const Icon = stat.icon;
          return (
            <div
              key={stat.title}
              className="bg-white rounded-lg shadow p-6 flex items-center gap-4"
            >
              <div className={`${stat.color} text-white p-4 rounded-lg`}>
                <Icon size={32} />
              </div>
              <div>
                <div className="text-gray-500 text-sm">{stat.title}</div>
                <div className="text-2xl font-bold">{stat.value}</div>
              </div>
            </div>
          );
        })}
      </div>

      {/* Components by Category */}
      <div className="bg-white rounded-lg shadow p-6 mb-8">
        <h2 className="text-xl font-bold mb-4">Components by Category</h2>
        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
          {Object.entries(stats.components_by_category).map(([category, count]) => (
            <div key={category} className="border rounded p-4">
              <div className="text-sm text-gray-500 capitalize">
                {category.replace('-', ' ')}
              </div>
              <div className="text-xl font-bold">{count}</div>
            </div>
          ))}
        </div>
      </div>

      {/* Recent Activity */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Recent Users */}
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-xl font-bold mb-4">Recent Users</h2>
          <div className="space-y-3">
            {stats.recent_users.map((user) => (
              <div key={user.id} className="flex items-center justify-between border-b pb-2">
                <div>
                  <div className="font-medium">{user.name}</div>
                  <div className="text-sm text-gray-500">{user.email}</div>
                </div>
                <div className={`text-xs px-2 py-1 rounded ${user.role === 'admin' ? 'bg-red-100 text-red-800' : 'bg-gray-100 text-gray-800'}`}>
                  {user.role}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Recent Posts */}
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-xl font-bold mb-4">Recent Posts</h2>
          <div className="space-y-3">
            {stats.recent_posts.map((post) => (
              <div key={post.id} className="border-b pb-2">
                <div className="font-medium line-clamp-2">{post.content}</div>
                <div className="text-sm text-gray-500 flex items-center gap-2 mt-1">
                  <span>{post.user.name}</span>
                  <span>•</span>
                  <span>{post.likes_count} likes</span>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Recent Builds */}
        <div className="bg-white rounded-lg shadow p-6">
          <h2 className="text-xl font-bold mb-4">Recent Builds</h2>
          <div className="space-y-3">
            {stats.recent_builds.map((build) => (
              <div key={build.id} className="border-b pb-2">
                <div className="font-medium">{build.name || 'Unnamed Build'}</div>
                <div className="text-sm text-gray-500">
                  {build.user?.name || 'Unknown'} • ${build.total_price}
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}
