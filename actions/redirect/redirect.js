/*
 @param {Object} params
 @param {Object} params.state
 @param {string} [params.state.redirect_uri] - target location
 @param {string} [params.session_cookie]     - name of the session cookie.
 */
function main(params) {
    if (params.state && params.state.redirect_uri) {
        // TODO: should only allow some URI for security reason.

        const payload = {
            statusCode: 302,
            headers: {
                location: params.state.redirect_uri
            }
        };

        if (params.session_cookie) {
            const cookie = {
                provider: params.provider,
                access_token: params.access_token,
                id: params.id,
                idRecord: params.idRecord
            };
            payload.headers["Set-Cookie"] = `${params.session_cookie}=${JSON.stringify(cookie)}; Path=/;`
        }

        return payload;
    } else {
        return params;
    }
}
