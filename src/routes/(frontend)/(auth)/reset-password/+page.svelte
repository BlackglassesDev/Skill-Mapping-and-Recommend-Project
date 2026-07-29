<script>
    import { enhance } from '$app/forms';
    import { goto } from '$app/navigation';
    import { resolve } from '$app/paths';
    import { onMount } from 'svelte';

    let message = $state('');
    let isloading = $state(false);

    const login_page = resolve('/login');

    let identifier = $state('');
    let identifierTouched = $state(false);
    let otp = $state('');
    let otpTouched = $state(false);
    let newPassword = $state('');
    let confirmPassword = $state('');
    let showPassword = $state(false);
    let showConfirmPassword = $state(false);
    let passwordTouched = $state(false);
    let otpRequested = $state(false);
    let resolvedEmail = $state('');

    // Cooldown สำหรับปุ่มขอรหัส OTP (5 นาที) โดยเก็บเวลาหมดอายุไว้ใน localStorage
    // เพื่อให้นับเวลาต่อได้แม้รีเฟรชหน้า
    const COOLDOWN_MS = 5 * 60 * 1000;
    const COOLDOWN_KEY = 'resetpw_otp_cooldown_end';
    let cooldownEnd = $state(0);
    let remaining = $state(0);

    const countdownLabel = $derived(
        remaining > 0
            ? `${String(Math.floor(remaining / 60)).padStart(2, '0')}:${String(remaining % 60).padStart(2, '0')}`
            : ''
    );

    onMount(() => {
        const stored = Number(localStorage.getItem(COOLDOWN_KEY));
        if (stored && stored > Date.now()) {
            cooldownEnd = stored;
            remaining = Math.max(0, Math.ceil((stored - Date.now()) / 1000));
        } else if (stored) {
            localStorage.removeItem(COOLDOWN_KEY);
        }

        const interval = setInterval(() => {
            if (cooldownEnd > 0) {
                remaining = Math.max(0, Math.ceil((cooldownEnd - Date.now()) / 1000));
                if (remaining <= 0) {
                    cooldownEnd = 0;
                    localStorage.removeItem(COOLDOWN_KEY);
                }
            }
        }, 1000);

        return () => clearInterval(interval);
    });

    const rules = $derived([
        { label: 'อย่างน้อย 8 ตัวอักษร', valid: newPassword.length >= 8 },
        { label: 'ตัวอักษรเล็ก (a-z)', valid: /[a-z]/.test(newPassword) },
        { label: 'ตัวอักษรใหญ่ (A-Z)', valid: /[A-Z]/.test(newPassword) },
        { label: 'ตัวเลข (0-9)', valid: /[0-9]/.test(newPassword) },
        { label: 'อักขระพิเศษ เช่น !@#$%', valid: /[^A-Za-z0-9]/.test(newPassword) }
    ]);

    const allRulesValid = $derived(rules.every((r) => r.valid));
    const passwordMatch = $derived(confirmPassword.length > 0 && newPassword === confirmPassword);
    const identifierValid = $derived(identifier.trim().length > 0);
    const otpValid = $derived(/^\d{6}$/.test(otp));
    const canReset = $derived(identifierValid && otpValid && allRulesValid && passwordMatch);

    const identifierBorderClass = $derived(
        identifierTouched
            ? identifierValid
                ? 'border-green-400 focus:border-green-500 focus:ring-green-50'
                : 'border-red-300 focus:border-red-400 focus:ring-red-50'
            : 'border-gray-200 focus:border-[#dca11d] focus:ring-amber-50'
    );

    const otpBorderClass = $derived(
        otpTouched
            ? otpValid
                ? 'border-green-400 focus:border-green-500 focus:ring-green-50'
                : 'border-red-300 focus:border-red-400 focus:ring-red-50'
            : 'border-gray-200 focus:border-[#dca11d] focus:ring-amber-50'
    );

    const passwordBorderClass = $derived(
        passwordTouched
            ? allRulesValid
                ? 'border-green-400 focus:border-green-500 focus:ring-green-50'
                : 'border-red-300 focus:border-red-400 focus:ring-red-50'
            : 'border-gray-200 focus:border-[#dca11d] focus:ring-amber-50'
    );

    const confirmBorderClass = $derived(
        confirmPassword.length > 0
            ? passwordMatch
                ? 'border-green-400 focus:border-green-500 focus:ring-green-50'
                : 'border-red-300 focus:border-red-400 focus:ring-red-50'
            : 'border-gray-200 focus:border-[#dca11d] focus:ring-amber-50'
    );

    /** @param {any} e */
    function handleOtpInput(e) {
        otpTouched = true;
        otp = e.currentTarget.value.replace(/\D/g, '').slice(0, 6);
    }
</script>

<svelte:head>
    <title>ตั้งรหัสผ่านใหม่ | Skill Mapping</title>
</svelte:head>

<main
    class="flex min-h-screen items-center justify-center bg-gray-50 bg-[radial-gradient(#e5e7eb_1px,transparent_1px)] bg-[size:16px_16px] p-4 font-sans selection:bg-amber-100"
>
    <article
        class="w-full max-w-lg overflow-hidden rounded-[28px] border-2 border-gray-200/80 bg-white shadow-[0_8px_30px_rgb(0,0,0,0.06)] transition-all"
    >
        <header class="flex items-center justify-between gap-3 bg-[#443210] px-6 py-5">
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
                <span class="text-base font-black tracking-wide text-amber-400"
                    >RMUTL | Skill Mapping</span
                >
            </div>
            <span class="text-sm font-bold text-white uppercase tracking-wider">Reset Password</span>
        </header>

        <div
            class="mx-6 mt-6 flex items-center gap-2 rounded-2xl border border-amber-200/70 bg-amber-50/50 px-4 py-3 text-[11px] font-medium text-[#443210] shadow-sm"
        >
            <span>🔐</span>
            <span
                >กรอกชื่อผู้ใช้หรืออีเมล ขอรหัส OTP แล้วตั้งรหัสผ่านใหม่เพื่อกู้คืนบัญชีของคุณ</span
            >
        </div>

        {#if message}
            <div
                class="mx-6 mt-3 rounded-2xl border border-amber-200/70 bg-amber-50/50 px-4 py-3 text-center text-xs font-semibold text-[#443210] shadow-sm animate-fade-in"
            >
                🔔 {message}
            </div>
        {/if}

        <form
            method="POST"
            action="?/reset"
            use:enhance={({ action }) => {
                const isOtp = action.search.includes('/sendotp');
                isloading = true;
                message = isOtp ? 'กำลังส่งรหัส OTP...' : 'กำลังตั้งรหัสผ่านใหม่...';

                return async ({ result }) => {
                    isloading = false;
                    if (result.type === 'success') {
                        const data = /** @type {any} */ (result.data);
                        message = data?.boxinfo || data?.message || 'สำเร็จ';
                        if (data?.otpSent) {
                            otpRequested = true;
                            resolvedEmail = data?.resolvedEmail || '';
                            cooldownEnd = Date.now() + COOLDOWN_MS;
                            localStorage.setItem(COOLDOWN_KEY, String(cooldownEnd));
                            remaining = Math.ceil(COOLDOWN_MS / 1000);
                        }
                        if (data?.done) {
                            setTimeout(() => goto(login_page), 1800);
                        }
                    } else if (result.type === 'failure') {
                        const data = /** @type {any} */ (result.data);
                        message = data?.boxinfo || data?.message || 'เกิดข้อผิดพลาด กรุณาลองอีกครั้ง';
                        // หากเซิร์ฟเวอร์ยังคงห้ามขอซ้ำ ให้ซิงค์ตัวนับเวลาฝั่ง client ตามค่าที่เซิร์ฟเวอร์ส่งกลับ
                        const cooldown = Number(data?.cooldown);
                        if (cooldown > 0) {
                            cooldownEnd = Date.now() + cooldown * 1000;
                            localStorage.setItem(COOLDOWN_KEY, String(cooldownEnd));
                            remaining = cooldown;
                        }
                    } else {
                        message = 'เกิดข้อผิดพลาด กรุณาลองอีกครั้ง';
                    }
                };
            }}
            class="p-6 sm:p-8"
        >
            <section class="grid grid-cols-1 gap-4 sm:grid-cols-2">
                <div class="flex flex-col gap-1.5 sm:col-span-2">
                    <label
                        for="identifier"
                        class="text-xs font-bold uppercase tracking-wider text-gray-500"
                        >ชื่อผู้ใช้งาน หรือ อีเมล (Username / Email)</label
                    >
                    <div class="flex gap-2">
                        <input
                            id="identifier"
                            type="text"
                            placeholder="เช่น Somchai_Ja67 หรือ username@live.rmutl.ac.th"
                            name="identifier"
                            bind:value={identifier}
                            oninput={() => (identifierTouched = true)}
                            class="w-full rounded-xl border-2 {identifierBorderClass} bg-gray-50/50 p-3 text-sm text-gray-900 placeholder-gray-400 transition-all outline-none focus:bg-white focus:ring-4"
                        />
                        <button
                            type="submit"
                            formaction="?/sendotp"
                            formnovalidate
                            disabled={isloading || !identifierValid || remaining > 0}
                            class="flex-none rounded-xl border-2 border-[#dca11d] bg-amber-50 px-4 text-xs font-bold text-[#443210] transition-all hover:bg-amber-100 active:scale-[0.98] disabled:cursor-not-allowed disabled:opacity-50"
                        >
                            {#if isloading && otpRequested === false}
                                รอสักครู่...
                            {:else if remaining > 0}
                                ขอใหม่ ({countdownLabel})
                            {:else}
                                ขอรหัส OTP
                            {/if}
                        </button>
                    </div>
                    {#if otpRequested && resolvedEmail}
                        <p class="text-[11px] font-semibold text-green-600">
                            ✅ ส่งรหัส OTP ไปยัง {resolvedEmail} แล้ว (ตรวจสอบกล่องอีเมล)
                        </p>
                    {/if}
                    {#if remaining > 0}
                        <div
                            class="mt-2 flex items-center gap-2 rounded-xl border border-amber-200 bg-amber-50/70 px-3 py-2 text-[11px] font-semibold text-[#443210] shadow-sm animate-fade-in"
                        >
                            <svg
                                xmlns="http://www.w3.org/2000/svg"
                                fill="none"
                                viewBox="0 0 24 24"
                                stroke-width="2"
                                stroke="currentColor"
                                class="h-4 w-4 flex-none text-[#dca11d]"
                            >
                                <path
                                    stroke-linecap="round"
                                    stroke-linejoin="round"
                                    d="M12 6v6h4.5m4.5 0a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
                                />
                            </svg>
                            <span>
                                ปุ่มขอรหัสถูกล็อกชั่วคราว กรุณารอ
                                <span class="font-black tabular-nums">{countdownLabel}</span>
                                ก่อนขอรหัส OTP ใหม่
                            </span>
                        </div>
                    {/if}
                </div>

                <div class="flex flex-col gap-1.5 sm:col-span-2">
                    <label for="otp" class="text-xs font-bold uppercase tracking-wider text-gray-500"
                        >รหัสยืนยัน (OTP 6 หลัก)</label
                    >
                    <div class="relative">
                        <input
                            id="otp"
                            type="text"
                            inputmode="numeric"
                            maxlength="6"
                            placeholder="เช่น 123456"
                            name="otp"
                            value={otp}
                            oninput={handleOtpInput}
                            class="w-full rounded-xl border-2 {otpBorderClass} bg-gray-50/50 p-3 pr-10 text-center text-lg font-black tracking-[0.5em] text-gray-900 placeholder-gray-300 placeholder:tracking-normal placeholder:font-medium placeholder:text-sm transition-all outline-none focus:bg-white focus:ring-4"
                        />
                        {#if otpTouched}
                            <span
                                class="pointer-events-none absolute inset-y-0 right-0 flex items-center pr-3 {otpValid
                                    ? 'text-green-500'
                                    : 'text-red-500'}"
                            >
                                {#if otpValid}
                                    <svg
                                        xmlns="http://www.w3.org/2000/svg"
                                        fill="none"
                                        viewBox="0 0 24 24"
                                        stroke-width="3"
                                        stroke="currentColor"
                                        class="h-4 w-4"
                                    >
                                        <path
                                            stroke-linecap="round"
                                            stroke-linejoin="round"
                                            d="m4.5 12.75 6 6 9-13.5"
                                        />
                                    </svg>
                                {:else}
                                    <svg
                                        xmlns="http://www.w3.org/2000/svg"
                                        fill="none"
                                        viewBox="0 0 24 24"
                                        stroke-width="3"
                                        stroke="currentColor"
                                        class="h-4 w-4"
                                    >
                                        <path
                                            stroke-linecap="round"
                                            stroke-linejoin="round"
                                            d="M6 18 18 6M6 6l12 12"
                                        />
                                    </svg>
                                {/if}
                            </span>
                        {/if}
                    </div>
                    {#if otpTouched && !otpValid}
                        <p class="text-[11px] font-semibold text-red-500">❌ รหัส OTP ต้องเป็นตัวเลข 6 หลัก</p>
                    {/if}
                </div>

                <div class="flex flex-col gap-1.5 sm:col-span-2">
                    <label for="pass" class="text-xs font-bold uppercase tracking-wider text-gray-500"
                        >รหัสผ่านใหม่ (New Password)</label
                    >
                    <div class="relative">
                        <input
                            id="pass"
                            type={showPassword ? 'text' : 'password'}
                            bind:value={newPassword}
                            oninput={() => (passwordTouched = true)}
                            placeholder="รหัสผ่านอย่างน้อย 8 ตัวอักษร"
                            name="newPassword"
                            class="w-full rounded-xl border-2 {passwordBorderClass} bg-gray-50/50 p-3 pr-11 text-sm text-gray-900 placeholder-gray-400 transition-all outline-none focus:bg-white focus:ring-4"
                        />
                        <div class="absolute inset-y-0 right-0 flex items-center gap-1 pr-3">
                            {#if allRulesValid}
                                <span class="text-green-500">
                                    <svg
                                        xmlns="http://www.w3.org/2000/svg"
                                        fill="none"
                                        viewBox="0 0 24 24"
                                        stroke-width="3"
                                        stroke="currentColor"
                                        class="h-4 w-4"
                                    >
                                        <path
                                            stroke-linecap="round"
                                            stroke-linejoin="round"
                                            d="m4.5 12.75 6 6 9-13.5"
                                        />
                                    </svg>
                                </span>
                            {/if}
                            <button
                                type="button"
                                onclick={() => (showPassword = !showPassword)}
                                tabindex="-1"
                                title={showPassword ? 'ซ่อนรหัสผ่าน' : 'แสดงรหัสผ่าน'}
                                class="text-gray-400 transition hover:text-[#443210]"
                            >
                                {#if showPassword}
                                    <svg
                                        xmlns="http://www.w3.org/2000/svg"
                                        fill="none"
                                        viewBox="0 0 24 24"
                                        stroke-width="2"
                                        stroke="currentColor"
                                        class="h-5 w-5"
                                    >
                                        <path
                                            stroke-linecap="round"
                                            stroke-linejoin="round"
                                            d="M3.98 8.223A10.477 10.477 0 0 0 1.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.451 10.451 0 0 1 12 4.5c4.756 0 8.773 3.162 10.065 7.498a10.522 10.522 0 0 1-4.293 5.774M6.228 6.228 3 3m3.228 3.228 3.65 3.65m7.894 7.894L21 21m-3.228-3.228-3.65-3.65m0 0a3 3 0 1 0-4.243-4.243m4.242 4.242L9.88 9.88"
                                        />
                                    </svg>
                                {:else}
                                    <svg
                                        xmlns="http://www.w3.org/2000/svg"
                                        fill="none"
                                        viewBox="0 0 24 24"
                                        stroke-width="2"
                                        stroke="currentColor"
                                        class="h-5 w-5"
                                    >
                                        <path
                                            stroke-linecap="round"
                                            stroke-linejoin="round"
                                            d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z"
                                        />
                                        <path
                                            stroke-linecap="round"
                                            stroke-linejoin="round"
                                            d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"
                                        />
                                    </svg>
                                {/if}
                            </button>
                        </div>
                    </div>

                    {#if passwordTouched && !allRulesValid}
                        <div class="mt-2 rounded-xl border border-gray-100 bg-gray-50/60 p-3">
                            <p class="mb-2 text-[10px] font-bold uppercase tracking-wider text-gray-400">
                                ข้อกำหนดความปลอดภัยของรหัสผ่าน
                            </p>
                            <ul class="grid grid-cols-1 gap-1.5 sm:grid-cols-2">
                                {#each rules as rule}
                                    <li class="flex items-center gap-1.5 text-[11px] font-medium">
                                        {#if rule.valid}
                                            <span
                                                class="flex h-4 w-4 flex-none items-center justify-center rounded-full bg-green-100 text-green-600"
                                            >
                                                <svg
                                                    xmlns="http://www.w3.org/2000/svg"
                                                    fill="none"
                                                    viewBox="0 0 24 24"
                                                    stroke-width="3"
                                                    stroke="currentColor"
                                                    class="h-3 w-3"
                                                >
                                                    <path
                                                        stroke-linecap="round"
                                                        stroke-linejoin="round"
                                                        d="m4.5 12.75 6 6 9-13.5"
                                                    />
                                                </svg>
                                            </span>
                                            <span class="text-green-600">{rule.label}</span>
                                        {:else}
                                            <span
                                                class="flex h-4 w-4 flex-none items-center justify-center rounded-full bg-red-100 text-red-500"
                                            >
                                                <svg
                                                    xmlns="http://www.w3.org/2000/svg"
                                                    fill="none"
                                                    viewBox="0 0 24 24"
                                                    stroke-width="3"
                                                    stroke="currentColor"
                                                    class="h-3 w-3"
                                                >
                                                    <path
                                                        stroke-linecap="round"
                                                        stroke-linejoin="round"
                                                        d="M6 18 18 6M6 6l12 12"
                                                    />
                                                </svg>
                                            </span>
                                            <span class="text-gray-500">{rule.label}</span>
                                        {/if}
                                    </li>
                                {/each}
                            </ul>
                        </div>
                    {/if}
                </div>

                <div class="flex flex-col gap-1.5 sm:col-span-2">
                    <label for="conpass" class="text-xs font-bold uppercase tracking-wider text-gray-500"
                        >ยืนยันรหัสผ่านใหม่ (Confirm Password)</label
                    >
                    <div class="relative">
                        <input
                            id="conpass"
                            type={showConfirmPassword ? 'text' : 'password'}
                            bind:value={confirmPassword}
                            placeholder="ระบุรหัสผ่านใหม่อีกครั้ง"
                            name="confirmPassword"
                            class="w-full rounded-xl border-2 {confirmBorderClass} bg-gray-50/50 p-3 pr-11 text-sm text-gray-900 placeholder-gray-400 transition-all outline-none focus:bg-white focus:ring-4"
                        />
                        <div class="absolute inset-y-0 right-0 flex items-center gap-1 pr-3">
                            {#if confirmPassword.length > 0}
                                <span class={passwordMatch ? 'text-green-500' : 'text-red-500'}>
                                    {#if passwordMatch}
                                        <svg
                                            xmlns="http://www.w3.org/2000/svg"
                                            fill="none"
                                            viewBox="0 0 24 24"
                                            stroke-width="3"
                                            stroke="currentColor"
                                            class="h-4 w-4"
                                        >
                                            <path
                                                stroke-linecap="round"
                                                stroke-linejoin="round"
                                                d="m4.5 12.75 6 6 9-13.5"
                                            />
                                        </svg>
                                    {:else}
                                        <svg
                                            xmlns="http://www.w3.org/2000/svg"
                                            fill="none"
                                            viewBox="0 0 24 24"
                                            stroke-width="3"
                                            stroke="currentColor"
                                            class="h-4 w-4"
                                        >
                                            <path
                                                stroke-linecap="round"
                                                stroke-linejoin="round"
                                                d="M6 18 18 6M6 6l12 12"
                                            />
                                        </svg>
                                    {/if}
                                </span>
                            {/if}
                            <button
                                type="button"
                                onclick={() => (showConfirmPassword = !showConfirmPassword)}
                                tabindex="-1"
                                title={showConfirmPassword ? 'ซ่อนรหัสผ่าน' : 'แสดงรหัสผ่าน'}
                                class="text-gray-400 transition hover:text-[#443210]"
                            >
                                {#if showConfirmPassword}
                                    <svg
                                        xmlns="http://www.w3.org/2000/svg"
                                        fill="none"
                                        viewBox="0 0 24 24"
                                        stroke-width="2"
                                        stroke="currentColor"
                                        class="h-5 w-5"
                                    >
                                        <path
                                            stroke-linecap="round"
                                            stroke-linejoin="round"
                                            d="M3.98 8.223A10.477 10.477 0 0 0 1.934 12C3.226 16.338 7.244 19.5 12 19.5c.993 0 1.953-.138 2.863-.395M6.228 6.228A10.451 10.451 0 0 1 12 4.5c4.756 0 8.773 3.162 10.065 7.498a10.522 10.522 0 0 1-4.293 5.774M6.228 6.228 3 3m3.228 3.228 3.65 3.65m7.894 7.894L21 21m-3.228-3.228-3.65-3.65m0 0a3 3 0 1 0-4.243-4.243m4.242 4.242L9.88 9.88"
                                        />
                                    </svg>
                                {:else}
                                    <svg
                                        xmlns="http://www.w3.org/2000/svg"
                                        fill="none"
                                        viewBox="0 0 24 24"
                                        stroke-width="2"
                                        stroke="currentColor"
                                        class="h-5 w-5"
                                    >
                                        <path
                                            stroke-linecap="round"
                                            stroke-linejoin="round"
                                            d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z"
                                        />
                                        <path
                                            stroke-linecap="round"
                                            stroke-linejoin="round"
                                            d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"
                                        />
                                    </svg>
                                {/if}
                            </button>
                        </div>
                    </div>
                    {#if confirmPassword.length > 0 && !passwordMatch}
                        <p class="mt-1.5 text-[11px] font-semibold text-red-500">
                            ❌ รหัสผ่านไม่ตรงกัน กรุณาตรวจสอบอีกครั้ง
                        </p>
                    {/if}
                </div>

                <div class="mt-4 sm:col-span-2">
                    <button
                        type="submit"
                        formaction="?/reset"
                        disabled={isloading || !canReset}
                        class="w-full rounded-xl bg-[#443210] py-3.5 text-sm font-bold text-amber-400 shadow-[0_4px_12px_rgba(68,50,16,0.15)] transition-all duration-200 hover:-translate-y-0.5 hover:bg-[#594216] hover:shadow-[0_6px_20px_rgba(68,50,16,0.25)] active:translate-y-0 disabled:translate-y-0 disabled:cursor-not-allowed disabled:opacity-50"
                    >
                        {#if isloading}
                            <span class="flex items-center justify-center gap-2">
                                <svg
                                    class="h-4 w-4 animate-spin text-amber-400"
                                    xmlns="http://www.w3.org/2000/svg"
                                    fill="none"
                                    viewBox="0 0 24 24"
                                >
                                    <circle
                                        class="opacity-25"
                                        cx="12"
                                        cy="12"
                                        r="10"
                                        stroke="currentColor"
                                        stroke-width="4"
                                    ></circle>
                                    <path
                                        class="opacity-75"
                                        fill="currentColor"
                                        d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                                    ></path>
                                </svg>
                                กำลังดำเนินการ...
                            </span>
                        {:else}
                            ยืนยันการตั้งรหัสผ่านใหม่
                        {/if}
                    </button>
                </div>
            </section>
        </form>
    </article>
</main>
