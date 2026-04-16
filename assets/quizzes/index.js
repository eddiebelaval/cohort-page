// Quizzes module
// Owner: Allie (@allierays)
// See docs/superpowers/specs/2026-04-16-quizzes-spec.md

/**
 * Mount the quizzes feature into the given root element.
 *
 * @param {HTMLElement} rootEl - the <div id="quizzes-root"> container
 * @param {Object} ctx
 * @param {Object} ctx.supabase - pre-authenticated Supabase client
 * @param {string} ctx.memberId - current member UUID
 * @param {Function} ctx.onActivity - call with an activity type string on completion
 */
export function mount(rootEl, ctx) {
  // Placeholder scaffold — Allie, this is yours to build out.
  //
  // Starting points:
  //   1. Fetch published quizzes:  ctx.supabase.from('quizzes').select('*').eq('published', true)
  //   2. Render a list into rootEl
  //   3. On quiz selection, load questions and present the UI
  //   4. On completion: insert into quiz_attempts AND call ctx.onActivity('quiz')
  //
  // Design tokens live in index.html root styles. Scope your classes with .quiz- prefix.
  // Prefer textContent / createElement over innerHTML to avoid XSS risk when you
  // render question prompts and options from the database.

  const section = document.createElement('section');
  section.className = 'quiz-placeholder';

  const title = document.createElement('h3');
  title.className = 'quiz-placeholder-title';
  title.textContent = 'Quizzes coming soon';

  const body = document.createElement('p');
  body.className = 'quiz-placeholder-body';
  body.textContent = 'This surface is reserved for the quizzes feature. Allie is building it.';

  section.append(title, body);
  rootEl.replaceChildren(section);
}
