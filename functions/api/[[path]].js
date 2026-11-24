const BACKEND = "https://challengeus-api.onrender.com";
const COOKIE = "__Host-larecocha_session";

const COOKIE_OPTIONS =
  "Path=/; HttpOnly; Secure; SameSite=Strict";

const ALLOWED_ROUTES = [
  ["POST", /^\/api\/auth\/(login|register)$/],
  ["GET", /^\/api\/me$/],
  ["GET", /^\/api\/bonches\/user\/[^/]+$/],
  ["GET", /^\/api\/bonches\/[^/]+\/challenges\/(today|status)$/],
  ["GET", /^\/api\/bonches\/[^/]+\/ranking$/],
  ["POST", /^\/api\/bonches(\/join)?$/],
  ["PUT", /^\/api\/bonches\/[^/]+\/config$/],
  ["POST", /^\/api\/bonches\/[^/]+\/leave$/],
  ["DELETE", /^\/api\/bonches\/[^/]+$/],
  ["POST", /^\/api\/evidences$/],
  ["GET", /^\/api\/votes\/pending$/],
  ["POST", /^\/api\/votes$/],
  ["GET", /^\/api\/rewards\/unseen$/],
  ["POST", /^\/api\/rewards\/seen$/],
  ["GET", /^\/api\/notifications$/],
  ["POST", /^\/api\/notifications\/(read|read-all)$/],
  ["GET", /^\/api\/store\/items$/],
  ["GET", /^\/api\/inventory$/],
  ["POST", /^\/api\/store\/purchase$/]
];

function json(data, status = 200, cookie = null) {
  const headers = new Headers({
    "Content-Type": "application/json; charset=utf-8",
    "Cache-Control": "no-store",
    "X-Content-Type-Options": "nosniff"
  });

  if (cookie) headers.set("Set-Cookie", cookie);

  return new Response(JSON.stringify(data), {
    status,
    headers
  });
}

function readSession(request) {
  const cookies = request.headers.get("Cookie") || "";

  for (const part of cookies.split(";")) {
    const value = part.trim();

    if (value.startsWith(COOKIE + "=")) {
      return value.slice(COOKIE.length + 1);
    }
  }

  return null;
}

function expiredCookie() {
  return `${COOKIE}=; ${COOKIE_OPTIONS}; Max-Age=0`;
}

export async function onRequest({ request }) {
  const url = new URL(request.url);
  const path = url.pathname;
  const method = request.method;

  const origin = request.headers.get("Origin");
  const fetchSite = request.headers.get("Sec-Fetch-Site");

  if (
    (origin && origin !== url.origin) ||
    fetchSite === "cross-site"
  ) {
    return json({ detail: "Origen no autorizado." }, 403);
  }

  if (
    method !== "GET" &&
    origin !== url.origin
  ) {
    return json({ detail: "Origen no autorizado." }, 403);
  }

  if (path === "/api/auth/logout" && method === "POST") {
    return json({ ok: true }, 200, expiredCookie());
  }

  const allowed = ALLOWED_ROUTES.some(
    ([verb, pattern]) =>
      verb === method && pattern.test(path)
  );

  if (!allowed) {
    return json({ detail: "Ruta no disponible." }, 404);
  }

  const isAuth =
    path === "/api/auth/login" ||
    path === "/api/auth/register";

  const token = readSession(request);

  if (!isAuth && !token) {
    return json({ detail: "Inicia sesion para continuar." }, 401);
  }

  const headers = new Headers();

  const contentType = request.headers.get("Content-Type");

  if (contentType) {
    headers.set("Content-Type", contentType);
  }

  if (!isAuth && token) {
    headers.set("Authorization", `Bearer ${token}`);
  }

  try {
    const upstream = await fetch(
      BACKEND + path + url.search,
      {
        method,
        headers,
        body: method === "GET" ? undefined : request.body,
        redirect: "manual"
      }
    );

    if (upstream.status >= 300 && upstream.status < 400) {
      return json({ detail: "Redireccion inesperada del servidor." }, 502);
    }

    if (isAuth && upstream.ok) {
      const data = await upstream.json();

      if (
        typeof data.token !== "string" ||
        !/^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$/.test(data.token)
      ) {
        return json({ detail: "Sesion no valida." }, 502);
      }

      const cookie =
        `${COOKIE}=${data.token}; ${COOKIE_OPTIONS}; Max-Age=2592000`;

      return json(
        { user: data.user },
        upstream.status,
        cookie
      );
    }

    const responseHeaders = new Headers({
      "Content-Type":
        upstream.headers.get("Content-Type") ||
        "application/json",
      "Cache-Control": "no-store",
      "X-Content-Type-Options": "nosniff"
    });

    if (upstream.status === 401) {
      responseHeaders.set("Set-Cookie", expiredCookie());
    }

    return new Response(upstream.body, {
      status: upstream.status,
      headers: responseHeaders
    });

  } catch (error) {
    console.error("PROXY_ERROR", error.name, error.message);
    return json(
      { detail: "No pudimos conectar con el servidor." },
      502
    );
  }
}
