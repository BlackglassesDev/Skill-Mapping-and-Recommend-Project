<script>
    import './layout.css';
    import { resolve } from '$app/paths';
    import { slide } from 'svelte/transition';
    import { page } from '$app/state';
    import favicon from '$lib/assets/favicon.svg';
    import { goto, invalidateAll } from '$app/navigation';
    import { enhance } from '$app/forms';

    let { children, data } = $props();
    let sid = $derived(data?.user);

    const isPageNoNav = $derived(page.url.pathname === '/login' || page.url.pathname === '/register');

    // ตั้งค่า Path ทั่วไป
    const homePath = resolve('/home');
    const loginPath = resolve('/login');
    const curriculum = resolve('/curriculum');
    //flooter
    const about = resolve('/about');
    const contact = resolve('/contact');
    const help = resolve('/help');
    //student
    const grade_users = resolve('/grade_users');
    const assess_skills = resolve('/assess_skills');
    //teacher
    const manage_course = resolve('/manage_course');
    const manage_skill = resolve('/manage_skill');
    const overview = resolve('/overview');

    // Logic สำหรับเมนูมือถือ
    let isMenuOpen = $state(false);
    function toggleMenu() {
        isMenuOpen = !isMenuOpen;
    }
</script>

<svelte:head><link rel="icon" href={favicon} /></svelte:head>

{#if isPageNoNav}
    {@render children()}
{:else if sid}
    <nav class="sticky top-0 z-50 bg-[#443210] p-4 text-white shadow-md">
        <div class="mx-auto flex max-w-7xl items-center justify-between">
            <a href={homePath} class="flex items-center">
                <span class="text-xl font-bold text-[#dca11d] md:text-2xl">CPE - Skill Mapping</span>
            </a>

            <div class="hidden items-center gap-8 md:flex">
                <div class="flex items-center gap-6 text-sm font-light">
                    {#if sid.role === 'student'}
                        <a href={homePath} class="transition-colors hover:text-[#dca11d]">หน้าหลัก</a>
                        <a href={grade_users} class="transition-colors hover:text-[#dca11d]">ปรับปรุงเกรด</a>
                        <a href={assess_skills} class="transition-colors hover:text-[#dca11d]">ประเมินทักษะ</a>
                    {/if}

                    {#if sid.role === 'teacher'}
                        <a href={overview} class="transition-colors hover:text-[#dca11d]">ภาพรวมหลักสูตร</a>
                        <a href={manage_course} class="transition-colors hover:text-[#dca11d]">จัดการรายวิชา</a>
                        <a href={manage_skill} class="transition-colors hover:text-[#dca11d]">จัดการทักษะ</a>
                    {/if}

                    {#if sid.role === 'admin'}
                        <a href={homePath} class="transition-colors hover:text-[#dca11d]">แอด</a>
                        <a href={curriculum} class="transition-colors hover:text-[#dca11d]">ข้อมูลหลักสูตร</a>
                    {/if}

                    <form
                        method="POST"
                        action="/api/auth/logout"
                        use:enhance={() => {
                            return async ({ result }) => {
                                // @ts-ignore
                                if (result && result.success === true) {
                                    await invalidateAll();
                                    goto(homePath);
                                }
                            };
                        }}
                    >
                        <button
                            type="submit"
                            class="flex items-center gap-1 transition-colors hover:text-[#dca11d]"
                            aria-label="ออกจากระบบ"
                            title="ออกจากระบบ"
                            >ออกจากระบบ<svg
                                xmlns="http://www.w3.org/2000/svg"
                                height="20"
                                width="20"
                                viewBox="0 0 640 640"
                            >
                                <path
                                    fill="currentColor"
                                    d="M569 337C578.4 327.6 578.4 312.4 569 303.1L425 159C418.1 152.1 407.8 150.1 398.8 153.8C389.8 157.5 384 166.3 384 176L384 256L272 256C245.5 256 224 277.5 224 304L224 336C224 362.5 245.5 384 272 384L384 384L384 464C384 473.7 389.8 482.5 398.8 486.2C407.8 489.9 418.1 487.9 425 481L569 337zM224 160C241.7 160 256 145.7 256 128C256 110.3 241.7 96 224 96L160 96C107 96 64 139 64 192L64 448C64 501 107 544 160 544L224 544C241.7 544 256 529.7 256 512C256 494.3 241.7 480 224 480L160 480C142.3 480 128 465.7 128 448L128 192C128 174.3 142.3 160 160 160L224 160z"
                                /></svg
                            >
                        </button>
                    </form>
                </div>
            </div>

            <button class="p-2 text-[#dca11d] md:hidden" onclick={toggleMenu} aria-label="Toggle Menu">
                <svg
                    xmlns="http://www.w3.org/2000/svg"
                    class="h-8 w-8"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                >
                    <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d={isMenuOpen ? 'M6 18L18 6M6 6l12 12' : 'M4 6h16M4 12h16M4 18h16'}
                    />
                </svg>
            </button>
        </div>

        {#if isMenuOpen}
            <div
                transition:slide
                class="space-y-4 border-t border-[#dca11d]/20 bg-[#443210] px-6 py-4 md:hidden"
            >
                {#if sid.role === 'student'}
                    <a href={homePath} class="block text-sm hover:text-[#dca11d]" onclick={toggleMenu}>หน้าหลัก</a>
                    <a href={grade_users} class="block text-sm hover:text-[#dca11d]" onclick={toggleMenu}>ปรับปรุงเกรด</a>
                    <a href={assess_skills} class="block text-sm hover:text-[#dca11d]" onclick={toggleMenu}>ประเมินทักษะ</a>
                {/if}

                {#if sid.role === 'teacher'}
                    <a href={overview} class="block text-sm hover:text-[#dca11d]" onclick={toggleMenu}>ภาพรวมหลักสูตร</a>
                    <a href={manage_course} class="block text-sm hover:text-[#dca11d]" onclick={toggleMenu}>จัดการรายวิชา</a>
                    <a href={manage_skill} class="block text-sm hover:text-[#dca11d]" onclick={toggleMenu}>จัดการทักษะ</a>
                {/if}

                {#if sid.role === 'admin'}
                    <a href={homePath} class="block text-sm hover:text-[#dca11d]" onclick={toggleMenu}>แอด</a>
                    <a href={curriculum} class="block text-sm hover:text-[#dca11d]" onclick={toggleMenu}>ข้อมูลหลักสูตร</a>
                {/if}

                <form
                    method="POST"
                    action="/api/auth/logout"
                    use:enhance={() => {
                        return async ({ result }) => {
                            // @ts-ignore
                            if (result && result.success === true) {
                                await invalidateAll();
                                goto(homePath);
                            }
                        };
                    }}
                >
                    <button
                        type="submit"
                        class="flex items-center gap-2 text-sm hover:text-[#dca11d]"
                        aria-label="ออกจากระบบ"
                        title="ออกจากระบบ"
                        >ออกจากระบบ
                        <svg xmlns="http://www.w3.org/2000/svg" height="30" width="30" viewBox="0 0 640 640">
                            <path
                                fill="currentColor"
                                d="M569 337C578.4 327.6 578.4 312.4 569 303.1L425 159C418.1 152.1 407.8 150.1 398.8 153.8C389.8 157.5 384 166.3 384 176L384 256L272 256C245.5 256 224 277.5 224 304L224 336C224 362.5 245.5 384 272 384L384 384L384 464C384 473.7 389.8 482.5 398.8 486.2C407.8 489.9 418.1 487.9 425 481L569 337zM224 160C241.7 160 256 145.7 256 128C256 110.3 241.7 96 224 96L160 96C107 96 64 139 64 192L64 448C64 501 107 544 160 544L224 544C241.7 544 256 529.7 256 512C256 494.3 241.7 480 224 480L160 480C142.3 480 128 465.7 128 448L128 192C128 174.3 142.3 160 160 160L224 160z"
                            /></svg
                        >
                    </button>
                </form>
            </div>
        {/if}
    </nav>

    <main class="min-h-screen bg-[#fcfcfc]">
        {@render children()}
    </main>

    <footer class="mt-12 bg-[#443210] px-8 py-10 text-white md:px-16">
        <div class="mx-auto flex max-w-7xl flex-col items-center justify-between gap-6 md:flex-row">
            <div class="text-lg font-bold md:text-xl">Create by 3 smart</div>

            <div class="flex items-center gap-6 text-sm font-light md:gap-10 md:text-base">
                <a href={about} class="transition-colors hover:text-[#dca11d]">เกี่ยวกับ</a>
                <a href={contact} class="transition-colors hover:text-[#dca11d]">ติดต่อเรา</a>
                <a href={help} class="transition-colors hover:text-[#dca11d]">ช่วยเหลือ</a>
            </div>
        </div>
    </footer>
{:else}
    <nav class="sticky top-0 z-50 bg-[#443210] p-4 text-white shadow-md">
        <div class="mx-auto flex max-w-7xl items-center justify-between">
            <a href={homePath} class="flex items-center">
                <span class="text-xl font-bold text-[#dca11d] md:text-2xl">CPE - Skill Mapping</span>
            </a>

            <div class="hidden items-center gap-8 md:flex">
                <div class="flex items-center gap-6 text-sm font-light">
                    <a href={homePath} class="transition-colors hover:text-[#dca11d]">หน้าหลัก</a>
                    <a href={assess_skills} class="transition-colors hover:text-[#dca11d]">ประเมินทักษะ</a>
                    <a href={curriculum} class="transition-colors hover:text-[#dca11d]">ข้อมูลหลักสูตร</a>
                </div>
                <a
                    href={loginPath}
                    class="rounded-lg bg-[#dca11d] px-6 py-2 text-sm font-bold text-black transition-all hover:brightness-110"
                >
                    เข้าสู่ระบบ
                </a>
            </div>

            <button class="p-2 text-[#dca11d] md:hidden" onclick={toggleMenu} aria-label="Toggle Menu">
                <svg
                    xmlns="http://www.w3.org/2000/svg"
                    class="h-8 w-8"
                    fill="none"
                    viewBox="0 0 24 24"
                    stroke="currentColor"
                >
                    <path
                        stroke-linecap="round"
                        stroke-linejoin="round"
                        stroke-width="2"
                        d={isMenuOpen ? 'M6 18L18 6M6 6l12 12' : 'M4 6h16M4 12h16M4 18h16'}
                    />
                </svg>
            </button>
        </div>

        {#if isMenuOpen}
            <div
                transition:slide
                class="space-y-4 border-t border-[#dca11d]/20 bg-[#443210] px-6 py-4 md:hidden"
            >
                <a href={homePath} class="block text-sm hover:text-[#dca11d]" onclick={toggleMenu}>หน้าหลัก</a>
                <a href={assess_skills} class="block text-sm hover:text-[#dca11d]" onclick={toggleMenu}>ประเมินทักษะ</a>
                <a href={curriculum} class="block text-sm hover:text-[#dca11d]" onclick={toggleMenu}>ข้อมูลหลักสูตร</a>
                <a
                    href={loginPath}
                    class="block rounded bg-[#dca11d] py-2 text-center font-bold text-black"
                    onclick={toggleMenu}>เข้าสู่ระบบ</a
                >
            </div>
        {/if}
    </nav>

    <main class="min-h-screen bg-[#fcfcfc]">
        {@render children()}
    </main>

    <footer class="mt-12 bg-[#443210] px-8 py-10 text-white md:px-16">
        <div class="mx-auto flex max-w-7xl flex-col items-center justify-between gap-6 md:flex-row">
            <div class="text-lg font-bold md:text-xl">Create by 3 smart</div>

            <div class="flex items-center gap-6 text-sm font-light md:gap-10 md:text-base">
                <a href={about} class="transition-colors hover:text-[#dca11d]">เกี่ยวกับ</a>
                <a href={contact} class="transition-colors hover:text-[#dca11d]">ติดต่อเรา</a>
                <a href={help} class="transition-colors hover:text-[#dca11d]">ช่วยเหลือ</a>
            </div>
        </div>
    </footer>
{/if}