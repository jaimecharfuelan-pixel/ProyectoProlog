const API_BASE = '';
const STORAGE_SESSION = 'cinegold_session';
const STORAGE_USER = 'cinegold_user';

const SECCIONES = [
  { containerId: 'sec-continuar', tipo: 'continuar' },
  { containerId: 'sec-recomendadas', tipo: 'recomendadas' },
  { containerId: 'sec-populares', tipo: 'populares' },
  { containerId: 'sec-accion', tipo: 'accion' },
  { containerId: 'sec-terror', tipo: 'terror' },
  { containerId: 'sec-ciencia', tipo: 'ciencia_ficcion' }
];

let searchTimeout = null;

function getSessionId() {
  return localStorage.getItem(STORAGE_SESSION) || '';
}

function getUsername() {
  return localStorage.getItem(STORAGE_USER) || '';
}

function saveSession(sessionId, username) {
  localStorage.setItem(STORAGE_SESSION, sessionId);
  localStorage.setItem(STORAGE_USER, username);
}

function clearSession() {
  localStorage.removeItem(STORAGE_SESSION);
  localStorage.removeItem(STORAGE_USER);
}

function requireAuth() {
  if (!getSessionId()) {
    window.location.href = 'login.html';
    return false;
  }
  return true;
}

async function apiFetch(path, options = {}) {
  const headers = {
    'Content-Type': 'application/json',
    ...(options.headers || {})
  };
  const sid = getSessionId();

  let finalPath = path;
  if (sid) {
    headers['X-Session-Id'] = sid;
    const sep = path.includes('?') ? '&' : '?';
    finalPath = path + sep + 'sid=' + encodeURIComponent(sid);
  }

  try {
    const res = await fetch(`${API_BASE}${finalPath}`, { ...options, headers });
    return await res.json();
  } catch {
    return { ok: false, error: 'No se pudo conectar con el servidor Prolog (puerto 9000)' };
  }
}

async function apiGet(path) {
  return apiFetch(path, { method: 'GET' });
}

async function apiPost(path, body) {
  return apiFetch(path, { method: 'POST', body: JSON.stringify(body) });
}

function showAlert(id, msg, type = '') {
  const el = document.getElementById(id);
  if (!el) return;
  el.textContent = msg;
  el.className = 'alert' + (type ? ` ${type}` : '');
  if (msg) el.classList.add('show');
  else el.classList.remove('show');
}

function initLoginPage() {
  const form = document.getElementById('login-form');
  if (!form) return;

  if (getSessionId()) {
    window.location.href = 'index.html';
    return;
  }

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const username = document.getElementById('username').value.trim();
    const password = document.getElementById('password').value;
    showAlert('login-alert', '');

    const data = await apiPost('/api/login', { username, password });
    if (data.ok) {
      saveSession(data.sessionId, data.username);
      window.location.href = 'index.html';
    } else {
      showAlert('login-alert', data.error || 'Credenciales incorrectas', 'error');
    }
  });
}

function initRegisterPage() {
  const form = document.getElementById('register-form');
  if (!form) return;

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const username = document.getElementById('username').value.trim();
    const password = document.getElementById('password').value;
    const confirm = document.getElementById('confirm').value;
    showAlert('register-alert', '');

    if (password !== confirm) {
      showAlert('register-alert', 'Las contrasenas no coinciden', 'error');
      return;
    }

    const data = await apiPost('/api/register', { username, password });
    if (data.ok) {
      showAlert('register-alert', 'Cuenta creada. Redirigiendo...', 'success');
      setTimeout(() => { window.location.href = 'login.html'; }, 1500);
    } else {
      showAlert('register-alert', data.error || 'Error al registrar', 'error');
    }
  });
}

async function initHomePage() {
  if (!requireAuth()) return;

  const userEl = document.getElementById('user-name');
  if (userEl) userEl.textContent = getUsername();

  document.getElementById('btn-logout')?.addEventListener('click', logout);
  document.getElementById('search-input')?.addEventListener('input', onSearchInput);
  document.getElementById('modal-close')?.addEventListener('click', closeModal);

  await cargarPerfil();
  await cargarSecciones();
}

async function logout() {
  await apiPost('/api/logout', {});
  clearSession();
  window.location.href = 'login.html';
}

async function cargarPerfil() {
  const data = await apiGet('/api/perfil');
  const panel = document.getElementById('perfil-generos');
  if (!panel || !data.ok) return;

  const generos = data.perfil?.generos || [];
  if (generos.length === 0) {
    panel.innerHTML =
      '<h4>Tus gustos</h4><p class="card-meta">Marca peliculas como vistas, like o favoritas para personalizar tus recomendaciones.</p>';
    return;
  }

  const tags = generos
    .map((g) => '<span class="genero-tag">' + g.label + ': <span>' + Math.round(g.score) + '</span> pts</span>')
    .join('');

  panel.innerHTML = '<h4>Preferencias por genero</h4><div class="genero-tags">' + tags + '</div>';
}

async function cargarSecciones() {
  for (const sec of SECCIONES) {
    const row = document.getElementById(sec.containerId);
    if (!row) continue;

    row.innerHTML = '<p class="card-meta">Cargando...</p>';
    const data = await apiGet('/api/seccion?tipo=' + sec.tipo);

    if (!data.ok || !data.peliculas?.length) {
      row.innerHTML = '<p class="card-meta">Sin titulos por ahora.</p>';
      continue;
    }

    row.innerHTML = '';
    data.peliculas.forEach((p) => row.appendChild(crearCard(p)));
  }
}

function onSearchInput(e) {
  const q = e.target.value.trim();
  clearTimeout(searchTimeout);
  searchTimeout = setTimeout(() => ejecutarBusqueda(q), 350);
}

async function ejecutarBusqueda(query) {
  const section = document.getElementById('search-results');
  const mainSections = document.getElementById('main-sections');

  if (!section) return;

  if (!query) {
    section.classList.add('hidden');
    section.innerHTML = '';
    mainSections?.classList.remove('hidden');
    return;
  }

  mainSections?.classList.add('hidden');
  section.classList.remove('hidden');
  section.innerHTML =
    '<h3 style="padding:0 2rem;color:var(--gold-light)">Resultados de busqueda</h3>' +
    '<div class="row-scroll" id="search-row"><p class="card-meta">Buscando...</p></div>';

  const row = document.getElementById('search-row');
  if (!row) return;

  const data = await apiGet('/api/buscar?q=' + encodeURIComponent(query));

  if (!data.ok || !data.peliculas?.length) {
    row.innerHTML = '<p class="empty-msg">No se encontraron peliculas.</p>';
    return;
  }

  row.innerHTML = '';
  data.peliculas.forEach((p) => row.appendChild(crearCard(p)));
}

function crearCard(pelicula) {
  const card = document.createElement('article');
  card.className = 'movie-card' + (pelicula.visto ? ' vista' : '');
  card.dataset.id = pelicula.id;

  const inicial = (pelicula.nombre || '?').charAt(0).toUpperCase();
  let posterInner;

  if (pelicula.poster) {
    posterInner =
      '<img src="' + pelicula.poster + '" alt="' + escapeHtml(pelicula.nombre) + '" ' +
      "onerror=\"this.style.display='none';this.nextElementSibling.style.display='flex'\">" +
      '<div class="poster-placeholder" style="display:none">' + inicial + '</div>';
  } else {
    posterInner = '<div class="poster-placeholder">' + inicial + '</div>';
  }

  const likeCls  = pelicula.like     ? 'active' : '';
  const favCls   = pelicula.favorita ? 'active' : '';
  const disCls   = pelicula.dislike  ? 'active' : '';

  card.innerHTML =
    '<div class="poster-wrap">' +
      posterInner +
      '<span class="badge-pop">★ ' + pelicula.popularidad + '</span>' +
      '<div class="progress-bar"></div>' +
    '</div>' +
    '<div class="card-body">' +
      '<h4>' + escapeHtml(pelicula.nombre) + '</h4>' +
      '<p class="card-meta">' + escapeHtml(pelicula.genero_label) + ' · ' + escapeHtml(pelicula.duracion_label) + '</p>' +
      '<div class="card-actions">' +
        '<button type="button" class="btn btn-sm btn-ver"     data-action="visto">Ver</button>' +
        '<button type="button" class="btn btn-sm btn-outline btn-like '    + likeCls + '" data-action="like">Me gusta</button>' +
        '<button type="button" class="btn btn-sm btn-outline btn-fav '     + favCls  + '" data-action="favorita">Favorita</button>' +
        '<button type="button" class="btn btn-sm btn-outline btn-dislike ' + disCls  + '" data-action="dislike">No me gusta</button>' +
      '</div>' +
    '</div>';

  card.querySelectorAll('[data-action]').forEach((btn) => {
    btn.addEventListener('click', async () => {
      const action = btn.dataset.action;
      if (action === 'visto') mostrarModalVer(pelicula);
      await registrarInteraccion(pelicula.id, action, card, btn);
    });
  });

  return card;
}

function escapeHtml(text) {
  const el = document.createElement('div');
  el.textContent = text || '';
  return el.innerHTML;
}

async function registrarInteraccion(peliculaId, tipo, card, btn) {
  const data = await apiPost('/api/interaccion', { pelicula: peliculaId, tipo });

  if (!data.ok) {
    alert(data.error || 'Error al guardar interaccion');
    return;
  }

  if (tipo === 'visto' || tipo === 'like' || tipo === 'favorita') {
    card.classList.add('vista');
  }
  if (tipo === 'like') btn.classList.add('active');
  if (tipo === 'favorita') {
    card.querySelector('[data-action="favorita"]')?.classList.add('active');
    card.querySelector('[data-action="like"]')?.classList.add('active');
    card.classList.add('vista');
  }
  if (tipo === 'dislike') btn.classList.add('active');

  await cargarPerfil();
  await cargarSecciones();
}

function mostrarModalVer(pelicula) {
  const modal = document.getElementById('view-modal');
  const title = document.getElementById('modal-title');
  if (!modal || !title) return;
  title.textContent = 'Viendo: ' + pelicula.nombre;
  modal.classList.add('show');
}

function closeModal() {
  document.getElementById('view-modal')?.classList.remove('show');
}

document.addEventListener('DOMContentLoaded', () => {
  const page = document.body.dataset.page;
  if (page === 'login')    initLoginPage();
  else if (page === 'register') initRegisterPage();
  else if (page === 'home')     initHomePage();
});