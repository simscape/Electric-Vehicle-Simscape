(function () {
  "use strict";

  const breadcrumbBar = document.querySelector(".crumb-bar");
  const breadcrumbs = document.querySelector(".breadcrumbs");
  const categoryNavigation = document.querySelector(".category-nav nav");
  if (breadcrumbBar && breadcrumbs && categoryNavigation) {
    // Collapse ancestor links that resolve to the same page so the sidebar
    // does not show two identical "« " entries (e.g. Documentation Home and
    // Electric Vehicle Design both pointing at index.html).
    const seenAncestors = new Set();
    Array.from(breadcrumbs.querySelectorAll("a")).forEach(function (link) {
      const target = link.getAttribute("href") || "";
      if (seenAncestors.has(target)) {
        link.remove();
      } else {
        seenAncestors.add(target);
      }
    });
    breadcrumbs.classList.add("nav-ancestors");
    categoryNavigation.insertBefore(breadcrumbs, categoryNavigation.firstChild);
    breadcrumbBar.remove();
  }

  const referenceTabs = Array.from(document.querySelectorAll(".reference-tabs a[href^='#']"));
  if (referenceTabs.length) {
    function setActiveReferenceTab(sectionId) {
      referenceTabs.forEach(function (link) {
        if (link.getAttribute("href") === "#" + sectionId) {
          link.setAttribute("aria-current", "location");
        } else {
          link.removeAttribute("aria-current");
        }
      });
    }

    const initialSection = window.location.hash.replace(/^#/, "") || "description";
    setActiveReferenceTab(initialSection);
    window.addEventListener("hashchange", function () {
      setActiveReferenceTab(window.location.hash.replace(/^#/, "") || "description");
    });

    referenceTabs.forEach(function (link) {
      link.addEventListener("click", function () {
        setActiveReferenceTab(link.getAttribute("href").slice(1));
      });
    });

    if ("IntersectionObserver" in window) {
      const observer = new IntersectionObserver(function (entries) {
        const visible = entries
          .filter(function (entry) { return entry.isIntersecting; })
          .sort(function (a, b) { return b.intersectionRatio - a.intersectionRatio; });
        if (visible.length && visible[0].target.id) setActiveReferenceTab(visible[0].target.id);
      }, { rootMargin: "-18% 0px -62% 0px", threshold: [0.05, 0.25, 0.5] });
      referenceTabs.forEach(function (link) {
        const target = document.querySelector(link.getAttribute("href"));
        if (target) observer.observe(target);
      });
    }
  }

  const menuButton = document.querySelector("[data-menu-button]");
  const nav = document.querySelector("[data-main-nav]");
  if (menuButton && nav) {
    menuButton.addEventListener("click", function () {
      const open = nav.classList.toggle("open");
      menuButton.setAttribute("aria-expanded", String(open));
    });
  }

  document.querySelectorAll("[data-copy-command]").forEach(function (button) {
    button.addEventListener("click", function () {
      const command = button.getAttribute("data-copy-command");
      if (!navigator.clipboard) return;
      navigator.clipboard.writeText(command).then(function () {
        const oldText = button.textContent;
        button.textContent = "Copied";
        window.setTimeout(function () { button.textContent = oldText; }, 1300);
      });
    });
  });

  /* Build in-page navigation from content headings.
     - Redesigned sub-pages list every h2 in their "On this page" panel.
     - Landing-style pages list only h2 headings explicitly marked data-nav.
     Existing HTML links remain in the source as a no-JavaScript fallback. */
  function headingTargetId(heading) {
    if (heading.id) return heading.id;

    var section = heading.closest("section[id]");
    if (section) return section.id;

    var base = (heading.textContent || "section")
      .trim()
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-+|-+$/g, "") || "section";
    var candidate = base;
    var suffix = 2;
    while (document.getElementById(candidate)) {
      candidate = base + "-" + suffix;
      suffix += 1;
    }
    heading.id = candidate;
    return candidate;
  }

  var onPageList = document.querySelector(".on-page-list");
  var documentationMain = document.querySelector(".doc-main");
  if (onPageList && documentationMain) {
    var documentationHeadings = Array.from(documentationMain.querySelectorAll("h2"))
      .filter(function (heading) { return !heading.hasAttribute("data-nav-ignore"); });

    if (documentationHeadings.length) {
      onPageList.innerHTML = "";
      documentationHeadings.forEach(function (heading) {
        var item = document.createElement("li");
        var link = document.createElement("a");
        link.href = "#" + headingTargetId(heading);
        link.textContent = heading.textContent.trim();
        item.appendChild(link);
        onPageList.appendChild(item);
      });
    }
  }

  var landingNavigation = document.querySelector(".sidebar > ul");
  var landingMain = document.querySelector("main.content");
  if (landingNavigation && landingMain) {
    landingNavigation.querySelectorAll("[data-auto-nav-fallback], [data-auto-nav-generated]")
      .forEach(function (item) { item.remove(); });

    var currentMainHeadingId = "";
    var insertionPoints = {};
    Array.from(landingMain.querySelectorAll("h1[id], h2[data-nav]")).forEach(function (heading) {
      if (heading.tagName === "H1") {
        currentMainHeadingId = heading.id;
        return;
      }
      if (!currentMainHeadingId) return;

      var mainLink = Array.from(landingNavigation.querySelectorAll("a[href^='#']"))
        .filter(function (link) {
          return link.getAttribute("href") === "#" + currentMainHeadingId;
        })[0];
      if (!mainLink) return;

      var item = document.createElement("li");
      var link = document.createElement("a");
      item.className = "sub";
      item.setAttribute("data-auto-nav-generated", "");
      link.href = "#" + headingTargetId(heading);
      link.textContent = heading.textContent.trim();
      item.appendChild(link);

      var insertionPoint = insertionPoints[currentMainHeadingId] || mainLink.parentElement;
      insertionPoint.parentElement.insertBefore(item, insertionPoint.nextSibling);
      insertionPoints[currentMainHeadingId] = item;
    });
  }

  /* Scroll-spy for "On this page" rail links */
  var onPageLinks = Array.from(document.querySelectorAll(
    ".on-page-list a[href^='#'], .on-page .category-tree a[href^='#']"
  ));
  if (onPageLinks.length && "IntersectionObserver" in window) {
    var onPageObserver = new IntersectionObserver(function (entries) {
      var visible = entries
        .filter(function (e) { return e.isIntersecting; })
        .sort(function (a, b) { return b.intersectionRatio - a.intersectionRatio; });
      if (visible.length && visible[0].target.id) {
        onPageLinks.forEach(function (link) {
          if (link.getAttribute("href") === "#" + visible[0].target.id) {
            link.classList.add("active");
          } else {
            link.classList.remove("active");
          }
        });
      }
    }, { rootMargin: "-20% 0px -60% 0px", threshold: [0.05, 0.25, 0.5] });
    onPageLinks.forEach(function (link) {
      var target = document.querySelector(link.getAttribute("href"));
      if (target) onPageObserver.observe(target);
    });
  }

  /* Keyboard navigation for reference tabs (arrow keys) */
  var tabList = document.querySelector(".reference-tabs");
  if (tabList) {
    tabList.setAttribute("role", "tablist");
    referenceTabs.forEach(function (tab) { tab.setAttribute("role", "tab"); });
    tabList.addEventListener("keydown", function (e) {
      if (e.key === "ArrowRight" || e.key === "ArrowLeft") {
        var idx = referenceTabs.indexOf(document.activeElement);
        if (idx === -1) return;
        var next = e.key === "ArrowRight" ? (idx + 1) % referenceTabs.length : (idx - 1 + referenceTabs.length) % referenceTabs.length;
        referenceTabs[next].focus();
        e.preventDefault();
      }
    });
  }

  /* Copy button on code blocks */
  document.querySelectorAll(".code-block").forEach(function (block) {
    var btn = document.createElement("button");
    btn.className = "code-copy-btn";
    btn.textContent = "Copy";
    btn.type = "button";
    btn.addEventListener("click", function () {
      var text = block.textContent.replace(/^Copy/, "").trim();
      if (navigator.clipboard) {
        navigator.clipboard.writeText(text).then(function () {
          btn.textContent = "Copied";
          setTimeout(function () { btn.textContent = "Copy"; }, 1300);
        });
      }
    });
    block.style.position = "relative";
    block.appendChild(btn);
  });

  /* Collapsible headings (for index.html and component pages) */
  document.querySelectorAll(".collapsible-heading").forEach(function (heading) {
    heading.setAttribute("aria-expanded", "false");
    var body = heading.nextElementSibling;
    if (body && body.classList.contains("collapsible-body")) {
      body.setAttribute("aria-hidden", "true");
    }
    heading.addEventListener("click", function () {
      var expanded = heading.getAttribute("aria-expanded") === "true";
      heading.setAttribute("aria-expanded", String(!expanded));
      if (body) body.setAttribute("aria-hidden", String(expanded));
    });
    heading.addEventListener("keydown", function (e) {
      if (e.key === "Enter" || e.key === " ") { e.preventDefault(); heading.click(); }
    });
  });

  /* Expand-all toggle */
  document.querySelectorAll(".expand-all-toggle").forEach(function (toggle) {
    toggle.addEventListener("click", function () {
      var allHeadings = document.querySelectorAll(".collapsible-heading");
      var anyCollapsed = Array.from(allHeadings).some(function (h) { return h.getAttribute("aria-expanded") !== "true"; });
      allHeadings.forEach(function (h) {
        h.setAttribute("aria-expanded", String(anyCollapsed));
        var b = h.nextElementSibling;
        if (b && b.classList.contains("collapsible-body")) b.setAttribute("aria-hidden", String(!anyCollapsed));
      });
      toggle.textContent = anyCollapsed ? "collapse all" : "expand all in page";
    });
  });

  /* Sidebar toggle — MathWorks-style. On narrow screens the left nav collapses
     and a docked panel-toggle icon opens it as an overlay (with a backdrop).
     The button and backdrop are not in the page markup, so create them. */
  var categoryNav = document.querySelector(".category-nav");
  if (categoryNav) {
    var sidebarIcon =
      '<svg viewBox="0 0 20 20" width="18" height="18" aria-hidden="true">' +
        '<rect x="1.5" y="3" width="17" height="14" rx="1.5" fill="none" stroke="currentColor" stroke-width="1.6"/>' +
        '<line x1="7" y1="3" x2="7" y2="17" stroke="currentColor" stroke-width="1.6"/>' +
      '</svg>';
    var navToggle = document.querySelector(".nav-toggle");
    if (!navToggle) {
      navToggle = document.createElement("button");
      navToggle.type = "button";
      navToggle.className = "nav-toggle";
      navToggle.setAttribute("aria-label", "Show navigation");
      navToggle.setAttribute("aria-expanded", "false");
      navToggle.innerHTML = sidebarIcon;
      document.body.insertBefore(navToggle, document.body.firstChild);
    }
    var navBackdrop = document.createElement("div");
    navBackdrop.className = "nav-backdrop";
    document.body.appendChild(navBackdrop);

    function setNav(open) {
      categoryNav.classList.toggle("open", open);
      navBackdrop.classList.toggle("open", open);
      navToggle.setAttribute("aria-expanded", String(open));
      navToggle.setAttribute("aria-label", open ? "Hide navigation" : "Show navigation");
    }
    navToggle.addEventListener("click", function () {
      setNav(!categoryNav.classList.contains("open"));
    });
    navBackdrop.addEventListener("click", function () { setNav(false); });
    /* close after choosing a nav link, or on Escape */
    categoryNav.addEventListener("click", function (e) {
      if (e.target.closest("a") && window.matchMedia("(max-width: 1023px)").matches) setNav(false);
    });
    document.addEventListener("keydown", function (e) {
      if (e.key === "Escape" && categoryNav.classList.contains("open")) setNav(false);
    });
  }

  const filterInput = document.querySelector("[data-filter-input]");
  const filterItems = Array.from(document.querySelectorAll("[data-search-item]"));
  const resultsCount = document.querySelector("[data-results-count]");
  let activePersona = "all";

  function applyFilters() {
    const query = filterInput ? filterInput.value.trim().toLowerCase() : "";
    let visible = 0;
    filterItems.forEach(function (item) {
      const text = (item.getAttribute("data-search-item") || item.textContent).toLowerCase();
      const personas = (item.getAttribute("data-personas") || "all").split(" ");
      const matchesText = !query || text.indexOf(query) !== -1;
      const matchesPersona = activePersona === "all" || personas.indexOf(activePersona) !== -1 || personas.indexOf("all") !== -1;
      item.hidden = !(matchesText && matchesPersona);
      if (!item.hidden) visible += 1;
    });
    if (resultsCount) resultsCount.textContent = visible + " result" + (visible === 1 ? "" : "s");
  }

  if (filterInput) filterInput.addEventListener("input", applyFilters);
  document.querySelectorAll("[data-persona]").forEach(function (button) {
    button.addEventListener("click", function () {
      activePersona = button.getAttribute("data-persona");
      document.querySelectorAll("[data-persona]").forEach(function (candidate) {
        candidate.setAttribute("aria-pressed", String(candidate === button));
      });
      applyFilters();
    });
  });
  applyFilters();

  const builder = document.querySelector("[data-project-builder]");
  if (builder) {
    const preview = builder.querySelector("[data-project-preview]");
    const fileCount = builder.querySelector("[data-file-count]");
    const size = builder.querySelector("[data-project-size]");
    const checks = Array.from(builder.querySelectorAll("input[type='checkbox']"));
    const experienceSelect = builder.querySelector("[data-experience-select]");

    const experiences = {
      "motorDrive.thermalDurability": {
        folder: "MotorDriveThermalDurability",
        workflow: "Workflow/MotorDrive/ThermalDurability/",
        component: "Components/MotorDrive/",
        model: "Model/VehicleTemplate/VehicleElectroThermal.slx"
      },
      "battery.sizing": {
        folder: "BatterySizing",
        workflow: "Workflow/Battery/BatterySizing/",
        component: "Components/BatteryHV/",
        model: "Model/VehicleTemplate/VehicleElectric.slx"
      },
      "vehicle.rangeEstimation": {
        folder: "VehicleRangeEstimation",
        workflow: "Workflow/Vehicle/RangeEstimation/",
        component: "Components/{BatteryHV,MotorDrive,Driveline}/",
        model: "Model/VehicleTemplate/VehicleElectric.slx"
      }
    };

    const hash = window.location.hash.replace(/^#/, "");
    const params = new URLSearchParams(hash);
    const requested = params.get("experience");
    if (requested && experiences[requested]) experienceSelect.value = requested;

    function renderBuilder() {
      const exp = experiences[experienceSelect.value];
      const include = Object.fromEntries(checks.map(function (c) { return [c.value, c.checked]; }));
      const tree = [exp.folder + "/"];
      if (include.workflow) tree.push("├── " + exp.workflow);
      if (include.components) tree.push("├── " + exp.component);
      if (include.vehicle) tree.push("├── " + exp.model);
      if (include.data) tree.push("├── Data/");
      if (include.docs) tree.push("├── Documentation/");
      tree.push("├── setupProject.m");
      tree.push("├── project-manifest.json");
      tree.push("└── " + exp.folder + ".prj");
      preview.textContent = tree.join("\n");
      const selected = checks.filter(function (c) { return c.checked; }).length;
      fileCount.textContent = String(18 + selected * 11);
      size.textContent = String(6 + selected * 8) + " MB";
    }

    checks.forEach(function (checkbox) { checkbox.addEventListener("change", renderBuilder); });
    experienceSelect.addEventListener("change", renderBuilder);
    renderBuilder();
  }
}());
