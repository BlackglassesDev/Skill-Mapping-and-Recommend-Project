export async function load({ locals }) {
	if (!locals.user) {
		return { user: null};
	}

    return{
        user:{
            username: locals.user.username,
            role: locals.user.role || 'student',
        }
    };
}
