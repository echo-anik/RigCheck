<header class="bg-white shadow">
    <div class="flex items-center justify-between px-8 py-4">
        <div class="flex items-center">
            <h1 class="text-2xl font-bold text-blue-600">RigCheck Admin</h1>
        </div>
        <div class="flex items-center space-x-4">
            <a href="/" target="_blank" class="text-gray-600 hover:text-gray-900">
                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                </svg>
            </a>
            <form action="{{ route('admin.logout') }}" method="POST">
                @csrf
                <button type="submit" class="text-gray-600 hover:text-gray-900">Logout</button>
            </form>
        </div>
    </div>
</header>
