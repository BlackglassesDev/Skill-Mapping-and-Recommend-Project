<script>
    import { enhance } from '$app/forms';
    import { goto, invalidateAll } from '$app/navigation';
    import { resolve } from '$app/paths';

    let message = $state('');
    let isloading = $state(false);

    const login_page = resolve('/login');
</script>

<svelte:head>
    <title>ลงทะเบียน | Skill Mapping</title>
</svelte:head>

<main
    class="flex min-h-screen items-center justify-center bg-gray-50 bg-[radial-gradient(#e5e7eb_1px,transparent_1px)] bg-[size:16px_16px] p-4 font-sans selection:bg-amber-100"
>
    <article
        class="w-full max-w-lg overflow-hidden rounded-[28px] border-2 border-gray-200/80 bg-white shadow-[0_8px_30px_rgb(0,0,0,0.06)] transition-all"
    >
        <header
            class="flex items-center justify-between gap-3 bg-[#443210] px-6 py-5"
        >
            <div class="flex items-center gap-3">
                <a
                    href={login_page}
                    class="text-white/80 transition-all duration-200 hover:scale-105 hover:text-amber-400"
                    title="กลับหน้าเข้าสู่ระบบ"
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
                <span class="text-base font-black tracking-wide text-amber-400">CPE Skill Mapping</span>
            </div>
            <span class="text-sm font-bold text-white uppercase tracking-wider">Sign Up</span>
        </header>

        {#if message}
            <div class="mx-6 mt-6 rounded-2xl border border-amber-200/70 bg-amber-50/50 px-4 py-3 text-center text-xs font-semibold text-[#443210] shadow-sm animate-fade-in">
                🔔 {message}
            </div>
        {/if}

        <form
            method="POST"
            action="?/regis"
            use:enhance={() => {
                isloading = true;
                message = 'กำลังตรวจสอบและบันทึกข้อมูลสมาชิกใหม่...';

                return async ({ result }) => {
                    if (result.type === 'success') {
                        // @ts-ignore
                        message = result.data?.message;
                        setTimeout(async () => {
                            await invalidateAll();
                            goto(login_page);
                        }, 1500);
                    } else {
                        // @ts-ignore
                        message = result.data?.message || 'เกิดข้อผิดพลาดในการลงทะเบียน กรุณาตรวจสอบข้อมูลอีกครั้ง';
                        isloading = false;
                    }
                };
            }}
            class="p-6 sm:p-8"
        >
            <section class="grid grid-cols-1 gap-4 sm:grid-cols-2">
                
                <div class="flex flex-col gap-1.5">
                    <label for="fullname" class="text-xs font-bold uppercase tracking-wider text-gray-500">ชื่อ - นามสกุล</label>
                    <input
                        id="fullname"
                        type="text"
                        placeholder="กรอกชื่อและนามสกุลของคุณ"
                        name="full_name"
                        required
                        class="w-full rounded-xl border-2 border-gray-200 bg-gray-50/50 p-3 text-sm text-gray-900 placeholder-gray-400 transition-all outline-none focus:border-[#dca11d] focus:bg-white focus:ring-4 focus:ring-amber-50"
                    />
                </div>

                <div class="flex flex-col gap-1.5">
                    <label for="username" class="text-xs font-bold uppercase tracking-wider text-gray-500">ชื่อผู้ใช้งาน (Username)</label>
                    <input
                        id="username"
                        type="text"
                        placeholder="ตั้งชื่อผู้ใช้งานระบบ"
                        name="username"
                        required
                        class="w-full rounded-xl border-2 border-gray-200 bg-gray-50/50 p-3 text-sm text-gray-900 placeholder-gray-400 transition-all outline-none focus:border-[#dca11d] focus:bg-white focus:ring-4 focus:ring-amber-50"
                    />
                </div>

                <div class="flex flex-col gap-1.5 sm:col-span-2">
                    <label for="mail" class="text-xs font-bold uppercase tracking-wider text-gray-500">อีเมลสถาบัน (Institutional Email)</label>
                    <input
                        id="mail"
                        type="email"
                        placeholder="username@live.rmutl.ac.th"
                        name="email"
                        required
                        class="w-full rounded-xl border-2 border-gray-200 bg-gray-50/50 p-3 text-sm text-gray-900 placeholder-gray-400 transition-all outline-none focus:border-[#dca11d] focus:bg-white focus:ring-4 focus:ring-amber-50"
                    />
                </div>

                <div class="flex flex-col gap-1.5 sm:col-span-2">
                    <label for="pass" class="text-xs font-bold uppercase tracking-wider text-gray-500">รหัสผ่าน (Password)</label>
                    <input
                        id="pass"
                        type="password"
                        placeholder="กำหนดรหัสผ่านเข้าใช้งานอย่างน้อย 8 ตัวอักษร"
                        name="password"
                        required
                        class="w-full rounded-xl border-2 border-gray-200 bg-gray-50/50 p-3 text-sm text-gray-900 placeholder-gray-400 transition-all outline-none focus:border-[#dca11d] focus:bg-white focus:ring-4 focus:ring-amber-50"
                    />
                </div>

                <div class="flex flex-col gap-1.5 sm:col-span-2">
                    <label for="conpass" class="text-xs font-bold uppercase tracking-wider text-gray-500">ยืนยันรหัสผ่านอีกครั้ง (Confirm Password)</label>
                    <input
                        id="conpass"
                        type="password"
                        placeholder="ป้อนรหัสผ่านให้ตรงกันอีกครั้ง"
                        name="confirmPassword"
                        required
                        class="w-full rounded-xl border-2 border-gray-200 bg-gray-50/50 p-3 text-sm text-gray-900 placeholder-gray-400 transition-all outline-none focus:border-[#dca11d] focus:bg-white focus:ring-4 focus:ring-amber-50"
                    />
                </div>

                <div class="mt-4 sm:col-span-2">
                    <button
                        type="submit"
                        disabled={isloading}
                        class="w-full rounded-xl bg-[#443210] py-3.5 text-sm font-bold text-amber-400 shadow-[0_4px_12px_rgba(68,50,16,0.15)] transition-all duration-200 hover:-translate-y-0.5 hover:bg-[#594216] hover:shadow-[0_6px_20px_rgba(68,50,16,0.25)] active:translate-y-0 disabled:translate-y-0 disabled:cursor-not-allowed disabled:opacity-50"
                    >
                        {#if isloading}
                            <span class="flex items-center justify-center gap-2">
                                <svg class="h-4 w-4 animate-spin text-amber-400" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                                    <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                                    <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                                </svg>
                                กำลังดำเนินการบันทึกข้อมูล...
                            </span>
                        {:else}
                            ยืนยันการลงทะเบียนเข้าใช้งาน
                        {/if}
                    </button>
                </div>
            </section>
        </form>
    </article>
</main>