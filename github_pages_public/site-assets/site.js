(() => {
  const root = document.body.dataset.root || "";
  const menuButton = document.querySelector("[data-menu-toggle]");
  const menu = document.getElementById("mobile-menu");
  menuButton?.addEventListener("click", () => {
    const open = menu.classList.toggle("open");
    menuButton.setAttribute("aria-expanded", String(open));
    menuButton.setAttribute("aria-label", open ? "Close menu" : "Open menu");
  });
  menu?.querySelectorAll("a").forEach(link => link.addEventListener("click", () => {
    menu.classList.remove("open");
    menuButton?.setAttribute("aria-expanded", "false");
  }));

  const progress = document.getElementById("reading-progress");
  let ticking = false;
  const updateProgress = () => {
    const available = document.documentElement.scrollHeight - innerHeight;
    progress.style.width = (available > 0 ? Math.min(100, scrollY / available * 100) : 0) + "%";
    ticking = false;
  };
  addEventListener("scroll", () => {
    if (!ticking) {
      requestAnimationFrame(updateProgress);
      ticking = true;
    }
  }, {passive:true});
  updateProgress();

  const sidebarLinks = [...document.querySelectorAll(".reader-sidebar nav a")];
  if (sidebarLinks.length && "IntersectionObserver" in window) {
    const observer = new IntersectionObserver(entries => {
      for (const entry of entries) {
        if (entry.isIntersecting) {
          sidebarLinks.forEach(link => link.classList.toggle("active", link.hash === "#" + entry.target.id));
        }
      }
    }, {rootMargin:"-110px 0px -70% 0px"});
    sidebarLinks.forEach(link => {
      const heading = document.getElementById(link.hash.slice(1));
      if (heading) observer.observe(heading);
    });
  }

  const dialog = document.getElementById("site-search");
  const input = document.getElementById("site-search-input");
  const results = document.getElementById("search-results");
  const count = document.getElementById("search-count");
  let searchIndex = window.PORTFOLIO_SEARCH_INDEX;

  function escapeHtml(value) {
    return String(value).replace(/[&<>"']/g, char => ({"&":"&amp;","<":"&lt;",">":"&gt;","\"":"&quot;","'":"&#39;"})[char]);
  }

  function snippet(text, query) {
    const lower = text.toLocaleLowerCase();
    const at = lower.indexOf(query);
    const start = at > 90 ? at - 75 : 0;
    const end = Math.min(text.length, start + 205);
    let value = (start ? "…" : "") + text.slice(start, end) + (end < text.length ? "…" : "");
    value = escapeHtml(value);
    const safeQuery = query.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
    return value.replace(new RegExp("(" + safeQuery + ")", "ig"), "<mark>$1</mark>");
  }

  function renderSearch() {
    const query = input.value.trim().toLocaleLowerCase();
    if (!query) {
      count.textContent = "Search story, projects, writing, and skills.";
      results.innerHTML = "";
      return;
    }
    if (!searchIndex) return;
    const words = query.split(/\s+/).filter(Boolean);
    const matches = searchIndex.map(item => {
      const title = item.title.toLocaleLowerCase();
      const body = item.text.toLocaleLowerCase();
      const includesAll = words.every(word => title.includes(word) || body.includes(word));
      const score = words.reduce((total, word) => total + (title.includes(word) ? 7 : 0) + (body.includes(word) ? 1 : 0), 0);
      return {item, score, includesAll};
    }).filter(result => result.includesAll).sort((a,b) => b.score - a.score);
    count.textContent = matches.length + (matches.length === 1 ? " matching entry" : " matching entries") + " · showing the first 12";
    results.innerHTML = matches.length ? matches.slice(0,12).map(({item}) => {
      const url = root + item.url;
      return `<a href="${escapeHtml(url)}"><strong>${escapeHtml(item.title)}</strong><small>${escapeHtml(item.group)}</small><p>${snippet(item.text, words.find(w => item.text.toLocaleLowerCase().includes(w)) || words[0])}</p></a>`;
    }).join("") : '<div class="search-empty">No matching entry. Try a product, task, or skill name.</div>';
  }

  async function openSearch() {
    dialog.showModal();
    input.focus();
    if (!searchIndex) {
      try {
        const response = await fetch(root + "site-assets/search.json");
        if (!response.ok) throw new Error("Search index unavailable");
        searchIndex = await response.json();
        renderSearch();
      } catch {
        count.textContent = "Search is unavailable in this preview. Browse the chapter index instead.";
      }
    }
  }
  document.querySelectorAll("[data-search-open]").forEach(button => button.addEventListener("click", openSearch));
  document.querySelector("[data-search-close]")?.addEventListener("click", () => dialog.close());
  dialog?.addEventListener("click", event => { if (event.target === dialog) dialog.close(); });
  input?.addEventListener("input", renderSearch);
  document.addEventListener("keydown", event => {
    if (event.key === "/" && !dialog.open && !["INPUT","TEXTAREA"].includes(document.activeElement.tagName)) {
      event.preventDefault(); openSearch();
    }
  });
})();
