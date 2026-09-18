/* Galeria de Viajes CRM - Dashboard Redesign V3
   Visual layer only. Does not replace CRM business logic or Supabase calls. */
(function () {
  "use strict";

  const $ = (s, root = document) => root.querySelector(s);

  function icon(name) {
    const icons = {
      search: '<svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="11" cy="11" r="6.5"></circle><path d="m16 16 5 5"></path></svg>',
      calendar: '<svg viewBox="0 0 24 24" aria-hidden="true"><rect x="3.5" y="5" width="17" height="15" rx="2"></rect><path d="M7 3v4M17 3v4M3.5 9h17"></path></svg>',
      plus: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M12 5v14M5 12h14"></path></svg>',
      users: '<svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="9" cy="8" r="3"></circle><circle cx="17" cy="9" r="2.3"></circle><path d="M3.5 19c.5-3.1 2.4-4.8 5.5-4.8s5 1.7 5.5 4.8M15 14.5c2.7-.1 4.4 1.3 5 3.8"></path></svg>',
      lead: '<svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="8" r="3.2"></circle><path d="M5 20c.7-4 3-6 7-6s6.3 2 7 6"></path><path d="M18 5.5h3M19.5 4v3"></path></svg>',
      opportunity: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 5h16l-6 7v5l-4 2v-7z"></path></svg>',
      quote: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M6 3.5h9l3 3V20H6z"></path><path d="M15 3.5V7h3M9 11h6M9 15h6"></path></svg>',
      followup: '<svg viewBox="0 0 24 24" aria-hidden="true"><rect x="3.5" y="5" width="17" height="15" rx="2"></rect><path d="M7 3v4M17 3v4M3.5 9h17M12 12v3l2 1"></path></svg>',
      sale: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M5 7h14v13H5z"></path><path d="M8 7V5h8v2M9 12h6M9 16h4"></path></svg>',
      plane: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="m3 11 18-6-6 18-3-8z"></path><path d="M12 15 7 21"></path></svg>',
      campaign: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 11v2h3l9 5V6l-9 5z"></path><path d="M7 13v5M19 9v6"></path></svg>',
      report: '<svg viewBox="0 0 24 24" aria-hidden="true"><path d="M4 19V5M4 19h16"></path><path d="M8 16v-4M12 16V8M16 16v-7"></path></svg>',
      settings: '<svg viewBox="0 0 24 24" aria-hidden="true"><circle cx="12" cy="12" r="3"></circle><path d="M19 12a7 7 0 0 0-.1-1.2l2-1.5-2-3.4-2.3.9a7 7 0 0 0-2-1.2L14.3 3h-4.6l-.3 2.6a7 7 0 0 0-2 1.2l-2.3-.9-2 3.4 2 1.5A7 7 0 0 0 5 12c0 .4 0 .8.1 1.2l-2 1.5 2 3.4 2.3-.9a7 7 0 0 0 2 1.2l.3 2.6h4.6l.3-2.6a7 7 0 0 0 2-1.2l2.3.9 2-3.4-2-1.5c.1-.4.1-.8.1-1.2z"></path></svg>'
    };
    return icons[name] || icons.report;
  }

  const navIcons = {
    dashboard: 'report',
    contactos: 'users',
    leads: 'lead',
    oportunidades: 'opportunity',
    cotizaciones: 'quote',
    seguimientos: 'followup',
    ventas: 'sale',
    viajes: 'plane',
    campanas: 'campaign',
    reportes: 'report',
    configuracion: 'settings'
  };

  function decorateSidebar() {
    document.querySelectorAll('.crm-nav-item[data-module]').forEach((button) => {
      const module = button.dataset.module;
      const target = $('.crm-nav-icon', button);
      if (!target) return;
      const name = navIcons[module] || 'report';
      target.innerHTML = icon(name);
      target.setAttribute('aria-hidden', 'true');
      target.classList.add('crm-redesign-nav-icon');
    });
  }

  function greeting() {
    const h = new Date().getHours();
    if (h < 12) return 'Buenos dias';
    if (h < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  function formatDate() {
    return new Intl.DateTimeFormat('es-CR', {
      weekday: 'long', day: '2-digit', month: 'long', year: 'numeric'
    }).format(new Date());
  }

  function decorateTopbar() {
    const topbar = $('.crm-topbar');
    if (!topbar || $('#crmGlobalSearch')) return;
    const right = $('.crm-topbar-right', topbar);
    if (!right) return;

    const search = document.createElement('label');
    search.className = 'crm-redesign-search';
    search.id = 'crmGlobalSearchWrap';
    search.innerHTML = `${icon('search')}<input id="crmGlobalSearch" type="search" placeholder="Buscar contactos, oportunidades, viajes..." autocomplete="off">`;
    right.insertBefore(search, right.firstChild);

    const input = $('#crmGlobalSearch');
    input?.addEventListener('keydown', (e) => {
      if (e.key !== 'Enter') return;
      const q = input.value.trim().toLowerCase();
      if (!q) return;
      const buttons = [...document.querySelectorAll('.crm-nav-item[data-module]')];
      const match = buttons.find(b => (b.textContent || '').toLowerCase().includes(q));
      match?.click();
    });
  }

  function decorateDashboardHeader(module) {
    if (module !== 'dashboard') return;
    const header = $('.crm-page-header');
    if (!header || header.dataset.redesigned === '1') return;
    header.dataset.redesigned = '1';
    const h2 = $('h2', header);
    const p = $('p', header);
    if (!h2) return;

    const actions = document.createElement('div');
    actions.className = 'crm-redesign-header-actions';
    actions.innerHTML = `
      <div class="crm-redesign-date">${icon('calendar')}<span>${formatDate()}</span></div>
      <button type="button" class="crm-redesign-primary" id="crmNewOpportunityRedesign">${icon('plus')}<span>Nueva oportunidad</span></button>
    `;
    header.appendChild(actions);
    h2.innerHTML = `${greeting()} <span class="crm-greeting-sun">*</span>`;
    if (p) p.textContent = 'Aqui tienes el resumen comercial y operativo de Galeria de Viajes.';
    $('#crmNewOpportunityRedesign')?.addEventListener('click', () => {
      document.querySelector('.crm-nav-item[data-module="oportunidades"]')?.click();
    });
  }

  function decorateStats() {
    const cards = [...document.querySelectorAll('.crm-stat-card')];
    const names = ['users', 'opportunity', 'quote', 'sale'];
    cards.forEach((card, i) => {
      if (card.dataset.redesigned !== '1') {
        card.dataset.redesigned = '1';
        card.classList.add(`crm-kpi-${i + 1}`);
      }
      const header = $('.crm-stat-header', card);
      if (header && !$('.crm-kpi-icon', header)) {
        const wrap = document.createElement('span');
        wrap.className = 'crm-kpi-icon';
        wrap.innerHTML = icon(names[i] || 'report');
        header.appendChild(wrap);
      }
      $('.crm-kpi-trend', card)?.remove();
    });
  }

  function decoratePipeline() {
    const stages = [...document.querySelectorAll('.crm-pipeline-stage')];
    if (stages.length !== 4) return;
    stages.forEach((stage, i) => {
      stage.classList.add(`crm-stage-${i + 1}`);
      const small = $('small', stage);
      if (small) {
        small.textContent = 'Sin monto';
        small.classList.add('crm-pipeline-no-amount');
      } else {
        const value = $('strong', stage);
        if (!value) return;
        const amount = document.createElement('small');
        amount.textContent = 'Sin monto';
        amount.className = 'crm-pipeline-no-amount';
        value.insertAdjacentElement('afterend', amount);
      }
    });
  }

  function addChart() {
    const dashboardGrid = $('.crm-dashboard-grid');
    const recent = $('.crm-recent-panel');
    if (!dashboardGrid || !recent || $('#crmLeadsSalesChart')) return;
    const panel = document.createElement('section');
    panel.id = 'crmLeadsSalesChart';
    panel.className = 'crm-panel crm-chart-panel';
    panel.innerHTML = `
      <div class="crm-panel-header">
        <div>
          <span class="crm-panel-eyebrow">ACTIVIDAD</span>
          <h3>Leads y ventas</h3>
          <p class="crm-chart-subtitle">Vista preliminar. Se conectara a datos historicos reales.</p>
        </div>
        <div class="crm-chart-legend"><span><i class="lead"></i> Leads</span><span><i class="sale"></i> Ventas</span></div>
      </div>
      <div class="crm-chart" aria-label="Vista preliminar del grafico de leads y ventas">
        ${['Abr','May','Jun','Jul','Ago','Sep'].map((m, i) => `<div class="crm-chart-col"><div class="crm-bars"><span class="crm-bar lead" style="height:${24 + i * 7}px"></span><span class="crm-bar sale" style="height:${8 + (i % 3) * 7}px"></span></div><small>${m}</small></div>`).join('')}
      </div>`;
    recent.parentNode.insertBefore(panel, recent);
  }

  function improveEmptyStates() {
    document.querySelectorAll('.crm-empty-icon').forEach(el => el.classList.add('crm-redesign-empty-icon'));
  }

  function apply() {
    decorateSidebar();
    decorateTopbar();
    const active = document.querySelector('.crm-nav-item.active[data-module]');
    const module = active?.dataset.module || document.querySelector('[data-content].crm-module:not([hidden])')?.dataset.content;
    if (module === 'dashboard') {
      decorateDashboardHeader('dashboard');
      decorateStats();
      decoratePipeline();
      addChart();
      improveEmptyStates();
    }
  }

  let scheduled = false;
  const observer = new MutationObserver(() => {
    if (scheduled) return;
    scheduled = true;
    requestAnimationFrame(() => { scheduled = false; apply(); });
  });

  function start() {
    apply();
    observer.observe(document.body, { childList: true, subtree: true, attributes: true, attributeFilter: ['class', 'hidden'] });
  }

  if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start);
  else start();
})();
