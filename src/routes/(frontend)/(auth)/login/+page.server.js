import { redirect, fail } from '@sveltejs/kit';

export async function load({ locals }) {
    if (locals.user) {
        throw redirect(302, '/home');
    }
    return {};
}

export const actions = {
    login: async ({request,fetch}) => {
        const data = await request.formData();
        const username = data.get('username');
        const password = data.get('password');

        try {
			const res = await fetch('/api/auth/login', {
				method: 'POST',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify({
					username: username,
					password: password
				})
			});

			const result = await res.json();
			if (!res.ok) {
                return fail(res.status,{
                    success: false,
                    message: result.message
                });
			}
            return{success: true, message: result.message};
		} catch (error) {
			console.error(error);
			return fail(500, {
                success: false,
                message: 'การเชื่อมต่อขัดข้อง'
            });
		}
    }
}