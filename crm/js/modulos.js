import { supabase } from "./auth.js";

const escapeHtml = value => String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");

const escapeAttr = escapeHtml;
const isAdmin = () => window.crm?.rol === "ADMIN";
const canWriteCommercial = () => ["ADMIN", "SUPERVISOR", "ASESOR"].includes(window.crm?.rol);
const canWriteOperations = () => ["ADMIN", "SUPERVISOR", "OPERACIONES"].includes(window.crm?.rol);
const canWriteAccounting = () => ["ADMIN", "OPERACIONES", "CONTABILIDAD"].includes(window.crm?.rol);

const today = () => new Date().toISOString().slice(0,10);

const definitions = {
    oportunidades: {
        eyebrow: "COMERCIAL", title: "Oportunidades", description: "Gestiona oportunidades comerciales y su pipeline.",
        table: "oportunidades", key: "id", order: "created_at", orderAsc: false,
        columns: ["nombre","etapa","vendedor","valor_estimado","probabilidad","fecha_cierre_estimada"],
        canCreate: () => canWriteCommercial(),
        canEdit: () => canWriteCommercial(), canDelete: () => isAdmin()
    },
    cotizaciones: {
        eyebrow: "COMERCIAL", title: "Cotizaciones", description: "Crea, envía y controla las cotizaciones de las oportunidades.",
        table: "cotizaciones", key: "id", order: "created_at", orderAsc: false,
        columns: ["numero","oportunidad","total","moneda","fecha_emision","fecha_vencimiento","estado"],
        canCreate: () => canWriteCommercial(), canEdit: () => canWriteCommercial(), canDelete: () => isAdmin()
    },
    seguimientos: {
        eyebrow: "COMERCIAL", title: "Seguimientos", description: "Agenda llamadas, WhatsApp, correos y reuniones.",
        table: "seguimientos", key: "id", order: "fecha_programada", orderAsc: true,
        columns: ["tipo","asunto","lead","oportunidad","fecha_programada","completado"],
        canCreate: () => canWriteCommercial(), canEdit: () => canWriteCommercial(), canDelete: () => isAdmin()
    },
    ventas: {
        eyebrow: "COMERCIAL", title: "Ventas", description: "Registra ventas y controla el estado de pago.",
        table: "ventas", key: "id", order: "fecha_venta", orderAsc: false,
        columns: ["numero","contacto","oportunidad","monto_total","monto_pagado","moneda","estado_pago","fecha_venta"],
        canCreate: () => canWriteAccounting(), canEdit: () => canWriteAccounting(), canDelete: () => isAdmin()
    },
    viajes: {
        eyebrow: "OPERACIÓN", title: "Viajes", description: "Administra los productos turísticos publicados en el sitio.",
        table: "viajes", key: "id", order: "created_at", orderAsc: false,
        columns: ["nombre","destino","duracion","precio","moneda","activo"],
        canCreate: () => canWriteOperations(), canEdit: () => canWriteOperations(), canDelete: () => isAdmin()
    },
    campanas: {
        eyebrow: "OPERACIÓN", title: "Campañas", description: "Administra campañas y sus fuentes de captación.",
        table: "campanas", key: "id", order: "created_at", orderAsc: false,
        columns: ["nombre","codigo","origen","fecha_inicio","fecha_fin","presupuesto","activa"],
        canCreate: () => canWriteCommercial(), canEdit: () => canWriteCommercial(), canDelete: () => isAdmin()
    }
};

let cache = {};
let lookups = {};

export function renderModuloCRM(module) {
    if (module === "reportes") return renderReportes();
    if (module === "configuracion") return renderConfiguracion();
    if (!definitions[module]) return false;
    renderCrud(module);
    return true;
}

async function renderCrud(module) {
    const def = definitions[module];
    const app = document.getElementById("crmContent");
    if (!app) return;
    app.innerHTML = `
      <div class="crm-content">
        <div class="crm-page-header">
          <div><span class="crm-eyebrow">${def.eyebrow}</span><h1>${def.title}</h1><p>${def.description}</p></div>
          ${def.canCreate() ? `<button class="crm-btn crm-btn-primary" id="crmGenericNew">+ Nuevo registro</button>` : ""}
        </div>
        <section class="crm-panel">
          <div class="crm-toolbar"><div class="crm-search"><span>⌕</span><input id="crmGenericSearch" type="search" placeholder="Buscar..." /></div></div>
          <div id="crmGenericContainer"><div class="crm-loading">Cargando...</div></div>
        </section>
        <div id="crmGenericModal"></div>
      </div>`;
    document.getElementById("crmGenericSearch")?.addEventListener("input", e => renderGenericTable(module, e.target.value));
    document.getElementById("crmGenericNew")?.addEventListener("click", () => openGenericModal(module));
    await loadGeneric(module);
}

async function loadGeneric(module) {
    const def = definitions[module];
    let q = supabase.from(def.table).select("*").order(def.order, {ascending:def.orderAsc});
    const {data,error} = await q;
    if (error) { showGenericError(error); return; }
    cache[module] = data || [];
    await loadLookups(module);
    renderGenericTable(module, "");
}

async function loadLookups(module) {
    const need = {
      oportunidades:["vendedores","leads","contactos"], cotizaciones:["oportunidades"], seguimientos:["leads","oportunidades","vendedores","contactos"],
      ventas:["oportunidades","contactos"], viajes:["destinos"], campanas:[]
    }[module] || [];
    for (const table of need) {
      if (lookups[table]) continue;
      let q = supabase.from(table).select("*").limit(1000);
      if (["vendedores"].includes(table)) q=q.eq("activo",true).order("nombre");
      if (["destinos"].includes(table)) q=q.eq("activo",true).order("nombre");
      const {data,error}=await q;
      if (!error) lookups[table]=data||[];
    }
}

function label(id, table, field="nombre") {
    const row=(lookups[table]||[]).find(x=>x.id===id);
    if (!row) return "—";
    if (table === "leads") {
        const c=(lookups.contactos||[]).find(x=>x.id===row.contacto_id);
        return c ? [c.nombre,c.apellido].filter(Boolean).join(" ") : `Lead ${String(id).slice(0,8)}`;
    }
    return row[field] || row.nombre || row.email || id;
}

function rowText(module,row,key) {
    switch(key) {
      case "nombre": return row.nombre;
      case "etapa": return row.etapa;
      case "vendedor": return label(row.vendedor_id,"vendedores");
      case "valor_estimado": return money(row.valor_estimado,row.moneda);
      case "probabilidad": return `${row.probabilidad ?? 0}%`;
      case "fecha_cierre_estimada": return row.fecha_cierre_estimada || "—";
      case "numero": return row.numero;
      case "oportunidad": return label(row.oportunidad_id,"oportunidades");
      case "total": return money(row.total,row.moneda);
      case "moneda": return row.moneda;
      case "fecha_emision": return row.fecha_emision || "—";
      case "fecha_vencimiento": return row.fecha_vencimiento || "—";
      case "estado": return row.estado;
      case "tipo": return row.tipo;
      case "asunto": return row.asunto || "—";
      case "lead": return label(row.lead_id,"leads","id");
      case "fecha_programada": return row.fecha_programada ? new Date(row.fecha_programada).toLocaleString("es-CR") : "—";
      case "completado": return row.completado ? "Completado" : "Pendiente";
      case "contacto": return label(row.contacto_id,"contactos","email");
      case "monto_total": return money(row.monto_total,row.moneda);
      case "monto_pagado": return money(row.monto_pagado,row.moneda);
      case "estado_pago": return row.estado_pago;
      case "fecha_venta": return row.fecha_venta || "—";
      case "destino": return label(row.destino_id,"destinos");
      case "duracion": return row.duracion_dias ? `${row.duracion_dias} días${row.duracion_noches != null ? ` / ${row.duracion_noches} noches` : ""}` : "—";
      case "precio": return money(row.precio_desde,row.moneda);
      case "activo": return row.activo ? "Activo" : "Inactivo";
      case "codigo": return row.codigo || "—";
      case "origen": return row.origen || "—";
      case "fecha_inicio": return row.fecha_inicio || "—";
      case "fecha_fin": return row.fecha_fin || "—";
      case "presupuesto": return money(row.presupuesto,row.moneda);
      case "activa": return row.activa ? "Activa" : "Inactiva";
      default: return row[key] ?? "—";
    }
}

function header(key) { return ({nombre:"Nombre",etapa:"Etapa",vendedor:"Vendedor",valor_estimado:"Valor",probabilidad:"Probabilidad",fecha_cierre_estimada:"Cierre",numero:"Número",oportunidad:"Oportunidad",total:"Total",moneda:"Moneda",fecha_emision:"Emisión",fecha_vencimiento:"Vencimiento",estado:"Estado",tipo:"Tipo",asunto:"Asunto",lead:"Lead",fecha_programada:"Programada",completado:"Estado",contacto:"Contacto",monto_total:"Total",monto_pagado:"Pagado",estado_pago:"Pago",fecha_venta:"Fecha",destino:"Destino",duracion:"Duración",precio:"Precio",activo:"Estado",codigo:"Código",origen:"Origen",fecha_inicio:"Inicio",fecha_fin:"Fin",presupuesto:"Presupuesto",activa:"Estado"}[key]||key); }
function money(value,currency="USD") { if(value===null||value===undefined||value==="") return "—"; return new Intl.NumberFormat("es-CR",{style:"currency",currency:currency||"USD"}).format(Number(value)); }

function renderGenericTable(module, search="") {
    const def=definitions[module], container=document.getElementById("crmGenericContainer"); if(!container)return;
    const q=String(search||"").toLowerCase().trim();
    const rows=(cache[module]||[]).filter(row=>!q||Object.values(row).some(v=>String(v??"").toLowerCase().includes(q)));
    if(!rows.length){container.innerHTML=`<div class="crm-empty-state crm-empty-state-small"><div class="crm-empty-icon">○</div><strong>No hay registros</strong><p>No encontramos información para este módulo.</p></div>`;return;}
    container.innerHTML=`<div class="crm-table-wrapper"><table class="crm-table"><thead><tr>${def.columns.map(header).map(h=>`<th>${h}</th>`).join("")}<th></th></tr></thead><tbody>${rows.map(row=>`<tr>${def.columns.map(k=>`<td>${escapeHtml(rowText(module,row,k))}</td>`).join("")}<td>${def.canEdit()?`<button class="crm-table-action" data-edit="${row.id}">Editar</button>`:""}${def.canDelete()?` <button class="crm-table-action" data-delete="${row.id}">Eliminar</button>`:""}</td></tr>`).join("")}</tbody></table></div><div class="crm-table-footer">${rows.length} registro${rows.length===1?"":"s"}</div>`;
    container.querySelectorAll("[data-edit]").forEach(b=>b.addEventListener("click",()=>openGenericModal(module,cache[module].find(x=>x.id===b.dataset.edit))));
    container.querySelectorAll("[data-delete]").forEach(b=>b.addEventListener("click",()=>deleteGeneric(module,b.dataset.delete)));
}

function fieldsFor(module,row={}) {
    const sel=(id,opts,value)=>`<select class="crm-select" id="${id}">${opts.map(o=>`<option value="${escapeAttr(o.value)}" ${String(value??"")===String(o.value)?"selected":""}>${escapeHtml(o.label)}</option>`).join("")}</select>`;
    const options=(arr,placeholder="Sin asignar")=>[{value:"",label:placeholder},...(arr||[]).map(x=>({value:x.id,label:x.nombre||x.email||x.id}))];
    if(module==="oportunidades") return `
      <div class="crm-form-grid"><div class="crm-form-group"><label>Nombre *</label><input id="f_nombre" required value="${escapeAttr(row.nombre)}"></div>
      <div class="crm-form-group"><label>Lead *</label>${sel("f_lead",options(lookups.leads,"Seleccionar lead"),row.lead_id)}</div>
      <div class="crm-form-group"><label>Vendedor</label>${sel("f_vendedor",options(lookups.vendedores),row.vendedor_id)}</div>
      <div class="crm-form-group"><label>Etapa</label>${sel("f_etapa",["NUEVA","CONTACTADA","CALIFICADA","COTIZACION","NEGOCIACION","SEGUIMIENTO","GANADA","PERDIDA"].map(x=>({value:x,label:x})),row.etapa||"NUEVA")}</div>
      <div class="crm-form-group"><label>Valor estimado</label><input id="f_valor" type="number" step="0.01" min="0" value="${escapeAttr(row.valor_estimado)}"></div>
      <div class="crm-form-group"><label>Moneda</label>${sel("f_moneda",["USD","CRC","EUR"].map(x=>({value:x,label:x})),row.moneda||"USD")}</div>
      <div class="crm-form-group"><label>Probabilidad %</label><input id="f_prob" type="number" min="0" max="100" value="${escapeAttr(row.probabilidad ?? 10)}"></div>
      <div class="crm-form-group"><label>Fecha cierre estimada</label><input id="f_fecha" type="date" value="${escapeAttr(row.fecha_cierre_estimada)}"></div></div>`;
    if(module==="cotizaciones") return `<div class="crm-form-grid"><div class="crm-form-group"><label>Oportunidad *</label>${sel("f_oportunidad",options(lookups.oportunidades,"Seleccionar oportunidad"),row.oportunidad_id)}</div><div class="crm-form-group"><label>Número *</label><input id="f_numero" required value="${escapeAttr(row.numero||`COT-${new Date().getFullYear()}-${Date.now().toString().slice(-6)}`)}"></div><div class="crm-form-group"><label>Subtotal</label><input id="f_subtotal" type="number" step="0.01" min="0" value="${escapeAttr(row.subtotal??0)}"></div><div class="crm-form-group"><label>Impuestos</label><input id="f_impuestos" type="number" step="0.01" min="0" value="${escapeAttr(row.impuestos??0)}"></div><div class="crm-form-group"><label>Descuentos</label><input id="f_descuentos" type="number" step="0.01" min="0" value="${escapeAttr(row.descuentos??0)}"></div><div class="crm-form-group"><label>Total</label><input id="f_total" type="number" step="0.01" min="0" value="${escapeAttr(row.total??0)}"></div><div class="crm-form-group"><label>Moneda</label>${sel("f_moneda",["USD","CRC","EUR"].map(x=>({value:x,label:x})),row.moneda||"USD")}</div><div class="crm-form-group"><label>Vencimiento</label><input id="f_venc" type="date" value="${escapeAttr(row.fecha_vencimiento)}"></div><div class="crm-form-group"><label>Estado</label>${sel("f_estado",["BORRADOR","ENVIADA","ACEPTADA","RECHAZADA","VENCIDA","CANCELADA"].map(x=>({value:x,label:x})),row.estado||"BORRADOR")}</div></div><div class="crm-form-group"><label>Notas</label><textarea id="f_notas" rows="4">${escapeHtml(row.notas)}</textarea></div>`;
    if(module==="seguimientos") return `<div class="crm-form-grid"><div class="crm-form-group"><label>Tipo *</label>${sel("f_tipo",["LLAMADA","WHATSAPP","CORREO","REUNION","OTRO"].map(x=>({value:x,label:x})),row.tipo||"LLAMADA")}</div><div class="crm-form-group"><label>Vendedor</label>${sel("f_vendedor",options(lookups.vendedores),row.vendedor_id)}</div><div class="crm-form-group"><label>Lead</label>${sel("f_lead",options(lookups.leads),row.lead_id)}</div><div class="crm-form-group"><label>Oportunidad</label>${sel("f_oportunidad",options(lookups.oportunidades),row.oportunidad_id)}</div><div class="crm-form-group"><label>Fecha programada</label><input id="f_fecha" type="datetime-local" value="${escapeAttr(row.fecha_programada?new Date(row.fecha_programada).toISOString().slice(0,16):"")}"></div><div class="crm-form-group"><label>Completado</label>${sel("f_completado",[{value:"false",label:"Pendiente"},{value:"true",label:"Completado"}],String(row.completado??false))}</div></div><div class="crm-form-group"><label>Asunto</label><input id="f_asunto" value="${escapeAttr(row.asunto)}"></div><div class="crm-form-group"><label>Descripción</label><textarea id="f_descripcion" rows="4">${escapeHtml(row.descripcion)}</textarea></div>`;
    if(module==="ventas") return `<div class="crm-form-grid"><div class="crm-form-group"><label>Oportunidad *</label>${sel("f_oportunidad",options(lookups.oportunidades,"Seleccionar oportunidad"),row.oportunidad_id)}</div><div class="crm-form-group"><label>Contacto *</label>${sel("f_contacto",options(lookups.contactos,"Seleccionar contacto"),row.contacto_id)}</div><div class="crm-form-group"><label>Número *</label><input id="f_numero" required value="${escapeAttr(row.numero||`VTA-${new Date().getFullYear()}-${Date.now().toString().slice(-6)}`)}"></div><div class="crm-form-group"><label>Fecha</label><input id="f_fecha" type="date" value="${escapeAttr(row.fecha_venta||today())}"></div><div class="crm-form-group"><label>Total *</label><input id="f_total" type="number" step="0.01" min="0" required value="${escapeAttr(row.monto_total??0)}"></div><div class="crm-form-group"><label>Pagado</label><input id="f_pagado" type="number" step="0.01" min="0" value="${escapeAttr(row.monto_pagado??0)}"></div><div class="crm-form-group"><label>Moneda</label>${sel("f_moneda",["USD","CRC","EUR"].map(x=>({value:x,label:x})),row.moneda||"USD")}</div><div class="crm-form-group"><label>Estado de pago</label>${sel("f_estado",["PENDIENTE","PARCIAL","PAGADO","CANCELADO"].map(x=>({value:x,label:x})),row.estado_pago||"PENDIENTE")}</div></div><div class="crm-form-group"><label>Notas</label><textarea id="f_notas" rows="4">${escapeHtml(row.notas)}</textarea></div>`;
    if(module==="viajes") return `<div class="crm-form-grid"><div class="crm-form-group"><label>Nombre *</label><input id="f_nombre" required value="${escapeAttr(row.nombre)}"></div><div class="crm-form-group"><label>Slug *</label><input id="f_slug" required value="${escapeAttr(row.slug)}"></div><div class="crm-form-group"><label>Destino</label>${sel("f_destino",options(lookups.destinos),row.destino_id)}</div><div class="crm-form-group"><label>Días</label><input id="f_dias" type="number" min="1" value="${escapeAttr(row.duracion_dias)}"></div><div class="crm-form-group"><label>Noches</label><input id="f_noches" type="number" min="0" value="${escapeAttr(row.duracion_noches)}"></div><div class="crm-form-group"><label>Precio desde</label><input id="f_precio" type="number" min="0" step="0.01" value="${escapeAttr(row.precio_desde)}"></div><div class="crm-form-group"><label>Moneda</label>${sel("f_moneda",["USD","CRC","EUR"].map(x=>({value:x,label:x})),row.moneda||"USD")}</div><div class="crm-form-group"><label>Estado</label>${sel("f_activo",[{value:"true",label:"Activo"},{value:"false",label:"Inactivo"}],String(row.activo??true))}</div></div><div class="crm-form-group"><label>Descripción</label><textarea id="f_descripcion" rows="4">${escapeHtml(row.descripcion)}</textarea></div>`;
    if(module==="campanas") return `<div class="crm-form-grid"><div class="crm-form-group"><label>Nombre *</label><input id="f_nombre" required value="${escapeAttr(row.nombre)}"></div><div class="crm-form-group"><label>Código</label><input id="f_codigo" value="${escapeAttr(row.codigo)}"></div><div class="crm-form-group"><label>Origen</label><input id="f_origen" value="${escapeAttr(row.origen)}"></div><div class="crm-form-group"><label>Inicio</label><input id="f_inicio" type="date" value="${escapeAttr(row.fecha_inicio)}"></div><div class="crm-form-group"><label>Fin</label><input id="f_fin" type="date" value="${escapeAttr(row.fecha_fin)}"></div><div class="crm-form-group"><label>Presupuesto</label><input id="f_presupuesto" type="number" min="0" step="0.01" value="${escapeAttr(row.presupuesto)}"></div><div class="crm-form-group"><label>Moneda</label>${sel("f_moneda",["USD","CRC","EUR"].map(x=>({value:x,label:x})),row.moneda||"USD")}</div><div class="crm-form-group"><label>Estado</label>${sel("f_activa",[{value:"true",label:"Activa"},{value:"false",label:"Inactiva"}],String(row.activa??true))}</div></div><div class="crm-form-group"><label>Descripción</label><textarea id="f_descripcion" rows="4">${escapeHtml(row.descripcion)}</textarea></div>`;
}

function openGenericModal(module,row=null) {
    const container=document.getElementById("crmGenericModal"); if(!container)return;
    const singular = {oportunidades:"oportunidad",cotizaciones:"cotización",seguimientos:"seguimiento",ventas:"venta",viajes:"viaje",campanas:"campaña"}[module] || "registro";
    container.innerHTML=`<div class="crm-modal-backdrop" id="crmGenericBackdrop"><div class="crm-modal"><div class="crm-modal-header"><div><span class="crm-eyebrow">${definitions[module].eyebrow}</span><h2>${row?"Editar":"Nueva"} ${singular}</h2></div><button class="crm-modal-close" id="crmGenericClose">×</button></div><form id="crmGenericForm">${fieldsFor(module,row||{})}<div id="crmGenericMessage" class="crm-form-message"></div><div class="crm-modal-footer"><button type="button" class="crm-btn crm-btn-secondary" id="crmGenericCancel">Cancelar</button><button class="crm-btn crm-btn-primary" type="submit">Guardar</button></div></form></div></div>`;
    const close=()=>container.innerHTML="";
    document.getElementById("crmGenericClose")?.addEventListener("click",close);
    document.getElementById("crmGenericCancel")?.addEventListener("click",close);
    document.getElementById("crmGenericBackdrop")?.addEventListener("click",e=>{if(e.target.id==="crmGenericBackdrop")close();});
    document.getElementById("crmGenericForm")?.addEventListener("submit",async e=>{e.preventDefault();await saveGeneric(module,row);});
}

async function saveGeneric(module,row) {
    const message=document.getElementById("crmGenericMessage"), form=document.getElementById("crmGenericForm");
    const val=id=>document.getElementById(id)?.value || null;
    let payload={};
    if(module==="oportunidades") payload={nombre:val("f_nombre"),lead_id:val("f_lead"),vendedor_id:val("f_vendedor") || window.crm?.perfil?.vendedor_id || null,etapa:val("f_etapa"),valor_estimado:num("f_valor"),moneda:val("f_moneda")||"USD",probabilidad:Number(val("f_prob")||10),fecha_cierre_estimada:val("f_fecha")||null};
    if(module==="cotizaciones") { const sub=num("f_subtotal")||0,imp=num("f_impuestos")||0,des=num("f_descuentos")||0; payload={oportunidad_id:val("f_oportunidad"),numero:val("f_numero"),subtotal:sub,impuestos:imp,descuentos:des,total:num("f_total") ?? sub+imp-des,moneda:val("f_moneda")||"USD",fecha_vencimiento:val("f_venc")||null,estado:val("f_estado"),notas:val("f_notas")}; }
    if(module==="seguimientos") payload={tipo:val("f_tipo"),vendedor_id:val("f_vendedor")||null,lead_id:val("f_lead")||null,oportunidad_id:val("f_oportunidad")||null,fecha_programada:val("f_fecha")?new Date(val("f_fecha")).toISOString():null,completado:val("f_completado")==="true",asunto:val("f_asunto")||null,descripcion:val("f_descripcion")||null};
    if(module==="ventas") payload={oportunidad_id:val("f_oportunidad"),contacto_id:val("f_contacto"),numero:val("f_numero"),fecha_venta:val("f_fecha")||today(),monto_total:num("f_total")||0,monto_pagado:num("f_pagado")||0,moneda:val("f_moneda")||"USD",estado_pago:val("f_estado"),notas:val("f_notas")||null};
    if(module==="viajes") payload={nombre:val("f_nombre"),slug:val("f_slug"),destino_id:val("f_destino")||null,duracion_dias:int("f_dias"),duracion_noches:int("f_noches"),precio_desde:num("f_precio"),moneda:val("f_moneda")||"USD",activo:val("f_activo")==="true",descripcion:val("f_descripcion")||null};
    if(module==="campanas") payload={nombre:val("f_nombre"),codigo:val("f_codigo")||null,origen:val("f_origen")||null,fecha_inicio:val("f_inicio")||null,fecha_fin:val("f_fin")||null,presupuesto:num("f_presupuesto"),moneda:val("f_moneda")||"USD",activa:val("f_activa")==="true",descripcion:val("f_descripcion")||null};
    const button=form?.querySelector("button[type=submit]"); if(button){button.disabled=true;button.textContent="Guardando...";}
    const query=row?.id ? supabase.from(definitions[module].table).update(payload).eq("id",row.id) : supabase.from(definitions[module].table).insert(payload);
    const {error}=await query;
    if(error){console.error(error);if(message){message.textContent=error.message;message.className="crm-form-message crm-form-message-error";}if(button){button.disabled=false;button.textContent="Guardar";}return;}
    document.getElementById("crmGenericModal").innerHTML="";
    await loadGeneric(module);
}
function num(id){const v=document.getElementById(id)?.value;return v===""||v==null?null:Number(v);}
function int(id){const v=document.getElementById(id)?.value;return v===""||v==null?null:Number.parseInt(v,10);}
async function deleteGeneric(module,id){if(!confirm("¿Eliminar este registro?"))return;const {error}=await supabase.from(definitions[module].table).delete().eq("id",id);if(error){alert(error.message);return;}await loadGeneric(module);}
function showGenericError(error){const c=document.getElementById("crmGenericContainer");if(c)c.innerHTML=`<div class="crm-empty-state"><strong>No fue posible cargar el módulo</strong><p>${escapeHtml(error.message)}</p></div>`;}

async function renderReportes(){
 const app=document.getElementById("crmContent"); if(!app)return true;
 app.innerHTML=`<div class="crm-content"><div class="crm-page-header"><div><span class="crm-eyebrow">ANÁLISIS</span><h1>Reportes</h1><p>Indicadores comerciales y operativos del CRM.</p></div></div><div class="crm-report-grid" id="crmReportGrid"><div class="crm-loading">Calculando indicadores...</div></div></div>`;
 const tables=["contactos","leads","oportunidades","cotizaciones","seguimientos","ventas"];
 const counts={}; for(const t of tables){const {count,error}=await supabase.from(t).select("*",{count:"exact",head:true});counts[t]=error?null:count??0;}
 document.getElementById("crmReportGrid").innerHTML=Object.entries(counts).map(([k,v])=>`<section class="crm-panel"><span class="crm-panel-eyebrow">CRM</span><h3>${k[0].toUpperCase()+k.slice(1)}</h3><strong class="crm-report-number">${v??"—"}</strong><p>Registros actuales</p></section>`).join("");
 return true;
}

async function renderConfiguracion(){
 const app=document.getElementById("crmContent"); if(!app)return true;
 app.innerHTML=`<div class="crm-content"><div class="crm-page-header"><div><span class="crm-eyebrow">SISTEMA</span><h1>Configuración</h1><p>Usuarios CRM, roles y estado de acceso.</p></div></div><section class="crm-panel"><div id="crmUsersContainer" class="crm-loading">Cargando usuarios...</div></section></div>`;
 const {data,error}=await supabase.from("crm_usuarios").select("id,vendedor_id,rol,activo,created_at,updated_at").order("created_at");
 const c=document.getElementById("crmUsersContainer"); if(error){c.innerHTML=`<div class="crm-empty-state"><strong>No fue posible cargar usuarios</strong><p>${escapeHtml(error.message)}</p></div>`;return true;}
 const vendors=lookups.vendedores || (await loadVendors());
 c.innerHTML=`<div class="crm-table-wrapper"><table class="crm-table"><thead><tr><th>Usuario</th><th>Rol</th><th>Vendedor</th><th>Activo</th><th></th></tr></thead><tbody>${(data||[]).map(u=>`<tr><td>${escapeHtml(u.id)}</td><td>${escapeHtml(u.rol)}</td><td>${escapeHtml(label(u.vendedor_id,"vendedores"))}</td><td>${u.activo?"Activo":"Inactivo"}</td><td>${isAdmin()?`<button class="crm-table-action" data-user="${u.id}">Editar</button>`:""}</td></tr>`).join("")}</tbody></table></div>`;
 c.querySelectorAll("[data-user]").forEach(b=>b.addEventListener("click",()=>editUser(b.dataset.user,data||[])));
 return true;
}
async function loadVendors(){const {data}=await supabase.from("vendedores").select("*").eq("activo",true).order("nombre");lookups.vendedores=data||[];return lookups.vendedores;}
async function editUser(id,users){const u=users.find(x=>x.id===id);if(!u)return;const role=prompt("Rol (ADMIN, SUPERVISOR, ASESOR, OPERACIONES, CONTABILIDAD):",u.rol);if(!role)return;const active=confirm("¿Usuario activo?");const {error}=await supabase.from("crm_usuarios").update({rol:role,activo:active}).eq("id",id);if(error){alert(error.message);return;}await renderConfiguracion();}
