<script>
    import { enhance } from '$app/forms';
    import { goto, invalidateAll } from '$app/navigation';
    import { resolve } from '$app/paths';

    const home = resolve('/home');
    const regis = resolve('/register');
    const resetpass = resolve('/reset-password');
    let message = $state('');
    let isloading = $state(false);
</script>

<svelte:head>
    <title>เข้าสู่ระบบ | Skill Mapping</title>
</svelte:head>

<main
    class="flex min-h-screen items-center justify-center bg-gray-50 bg-[radial-gradient(#e5e7eb_1px,transparent_1px)] bg-[size:16px_16px] p-4 font-sans selection:bg-amber-100"
>
    <article
        class="w-full max-w-md overflow-hidden rounded-[28px] border-2 border-gray-200/80 bg-white shadow-[0_8px_30px_rgb(0,0,0,0.06)] transition-all"
    >
        <header
            class="flex items-center justify-between gap-3 bg-[#443210] px-6 py-5"
        >
            <div class="flex items-center gap-3">
                <a
                    href={home}
                    class="text-white/80 transition-all duration-200 hover:scale-105 hover:text-amber-400"
                    title="กลับหน้าหลัก"
                >
                    <svg
                        xmlns="http://www.w3.org/2000/svg"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke-width="2.5"
                        stroke="currentColor"
                        class="h-5 w-5"
                    >
                        <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            d="M10.5 19.5 3 12m0 0 7.5-7.5M3 12h18"
                        />
                    </svg>
                </a>
                <span class="text-base font-black tracking-wide text-amber-400">RMUTL | Skill Mapping</span>
            </div>
            <span class="text-sm font-bold text-white uppercase tracking-wider">Sign In</span>
        </header>

        {#if message}
            <div class="mx-6 mt-6 rounded-2xl border border-amber-200/70 bg-amber-50/50 px-4 py-3 text-center text-xs font-semibold text-[#443210] shadow-sm animate-fade-in">
                🔔 {message}
            </div>
        {/if}

        <form
            method="POST"
            action="?/login"
            use:enhance={() => {
                isloading = true;
                message = 'กำลังเข้าสู่ระบบ';

                return async ({ result }) => {
                    if (result.type === 'success') {
                        // @ts-ignore
                        message = result.data?.message;

                        setTimeout(async () => {
                            await invalidateAll();
                            goto(home);
                        }, 1000);
                    } else {
                        // @ts-ignore
                        message = result.data?.message || 'เกิดข้อผิดพลาดในการเชื่อมต่อระบบ';
                        isloading = false;
                    }
                };
            }}
            class="p-6 sm:p-8"
        >
            <div class="space-y-4">
                <div>
                    <label for="user" class="text-xs font-bold uppercase tracking-wider text-gray-500">ชื่อผู้ใช้งาน (Username)</label>
                    <input
                        type="text"
                        placeholder="กรุณากรอกชื่อผู้ใช้งาน"
                        id="user"
                        name="username"
                        required
                        class="mt-1.5 w-full rounded-xl border-2 border-gray-200 bg-gray-50/50 p-3 text-sm text-gray-900 placeholder-gray-400 transition-all outline-none focus:border-[#dca11d] focus:bg-white focus:ring-4 focus:ring-amber-50"
                    />
                </div>
                
                <div>
                    <label for="pass" class="text-xs font-bold uppercase tracking-wider text-gray-500">รหัสผ่าน (Password)</label>
                    <input
                        type="password"
                        placeholder="กรุณากรอกรหัสผ่าน"
                        id="pass"
                        name="password"
                        required
                        class="mt-1.5 w-full rounded-xl border-2 border-gray-200 bg-gray-50/50 p-3 text-sm text-gray-900 placeholder-gray-400 transition-all outline-none focus:border-[#dca11d] focus:bg-white focus:ring-4 focus:ring-amber-50"
                    />
                </div>
            </div>

            <button
                type="submit"
                disabled={isloading}
                class="mt-6 w-full rounded-xl bg-[#443210] py-3.5 text-sm font-bold text-amber-400 shadow-[0_4px_12px_rgba(68,50,16,0.15)] transition-all duration-200 hover:-translate-y-0.5 hover:bg-[#594216] hover:shadow-[0_6px_20px_rgba(68,50,16,0.25)] active:translate-y-0 disabled:translate-y-0 disabled:cursor-not-allowed disabled:opacity-50"
            >
                {#if isloading}
                    <span class="flex items-center justify-center gap-2">
                        <svg class="h-4 w-4 animate-spin text-amber-400" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                        </svg>
                        กำลังประมวลผลข้อมูล...
                    </span>
                {:else}
                    เข้าสู่ระบบ
                {/if}
            </button>

            <div class="mt-6 flex items-center justify-between text-xs">
                <a
                    href={regis}
                    class="font-bold text-[#443210] underline decoration-amber-600/30 underline-offset-4 transition hover:text-[#dca11d] hover:decoration-[#dca11d]"
                >
                    ลงทะเบียนเข้าใช้งานใหม่
                </a>

                <button
                    type="button"
                    onclick={() => goto(resetpass)}
                    class="flex items-center gap-1.5 font-bold text-gray-500 transition hover:text-[#443210]"
                >
                    <svg
                        xmlns="http://www.w3.org/2000/svg"
                        fill="none"
                        viewBox="0 0 24 24"
                        stroke-width="2.5"
                        stroke="currentColor"
                        class="h-4 w-4 text-gray-400"
                    >
                        <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            d="M9.879 7.519c1.171-1.025 3.071-1.025 4.242 0 1.172 1.025 1.172 2.687 0 3.712-.203.179-.43.326-.67.442-.745.361-1.45.999-1.45 1.827v.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9 5.25h.008v.008H12v-.008Z"
                        />
                    </svg>
                    ลืมรหัสผ่าน?
                </button>
            </div>
        </form>
    </article>
</main>