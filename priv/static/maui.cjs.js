var __defProp = Object.defineProperty;
var __getOwnPropDesc = Object.getOwnPropertyDescriptor;
var __getOwnPropNames = Object.getOwnPropertyNames;
var __hasOwnProp = Object.prototype.hasOwnProperty;
var __export = (target, all) => {
  for (var name in all)
    __defProp(target, name, { get: all[name], enumerable: true });
};
var __copyProps = (to, from, except, desc) => {
  if (from && typeof from === "object" || typeof from === "function") {
    for (let key of __getOwnPropNames(from))
      if (!__hasOwnProp.call(to, key) && key !== except)
        __defProp(to, key, { get: () => from[key], enumerable: !(desc = __getOwnPropDesc(from, key)) || desc.enumerable });
  }
  return to;
};
var __toCommonJS = (mod) => __copyProps(__defProp({}, "__esModule", { value: true }), mod);

// js/index.js
var index_exports = {};
__export(index_exports, {
  Hooks: () => Hooks2
});
module.exports = __toCommonJS(index_exports);

// ../deps/phoenix_live_view/priv/static/phoenix_live_view.esm.js
var PHX_EVENT_CLASSES = [
  "phx-click-loading",
  "phx-change-loading",
  "phx-submit-loading",
  "phx-keydown-loading",
  "phx-keyup-loading",
  "phx-blur-loading",
  "phx-focus-loading",
  "phx-hook-loading"
];
var PHX_COMPONENT = "data-phx-component";
var PHX_VIEW_REF = "data-phx-view";
var PHX_REF_LOADING = "data-phx-ref-loading";
var PHX_REF_SRC = "data-phx-ref-src";
var PHX_REF_LOCK = "data-phx-ref-lock";
var PHX_UPLOAD_REF = "data-phx-upload-ref";
var PHX_PREFLIGHTED_REFS = "data-phx-preflighted-refs";
var PHX_DONE_REFS = "data-phx-done-refs";
var PHX_ACTIVE_ENTRY_REFS = "data-phx-active-refs";
var PHX_LIVE_FILE_UPDATED = "phx:live-file:updated";
var PHX_PARENT_ID = "data-phx-parent-id";
var PHX_MAIN = "data-phx-main";
var PHX_ROOT_ID = "data-phx-root-id";
var PHX_HAS_FOCUSED = "phx-has-focused";
var FOCUSABLE_INPUTS = [
  "text",
  "textarea",
  "number",
  "email",
  "password",
  "search",
  "tel",
  "url",
  "date",
  "time",
  "datetime-local",
  "color",
  "range"
];
var CHECKABLE_INPUTS = ["checkbox", "radio"];
var PHX_HAS_SUBMITTED = "phx-has-submitted";
var PHX_SESSION = "data-phx-session";
var PHX_VIEW_SELECTOR = `[${PHX_SESSION}]`;
var PHX_STICKY = "data-phx-sticky";
var PHX_STATIC = "data-phx-static";
var PHX_STREAM = "stream";
var PHX_PORTAL = "data-phx-portal";
var PHX_TELEPORTED_REF = "data-phx-teleported";
var PHX_PRIVATE = "phxPrivate";
var DEBOUNCE_TRIGGER = "debounce-trigger";
var THROTTLED = "throttled";
var DEBOUNCE_PREV_KEY = "debounce-prev-key";
var PHX_PENDING_ATTRS = [PHX_REF_LOADING, PHX_REF_SRC, PHX_REF_LOCK];
var EntryUploader = class {
  constructor(entry, config, liveSocket) {
    const { chunk_size, chunk_timeout } = config;
    this.liveSocket = liveSocket;
    this.entry = entry;
    this.offset = 0;
    this.chunkSize = chunk_size;
    this.chunkTimeout = chunk_timeout;
    this.chunkTimer = null;
    this.errored = false;
    this.uploadChannel = liveSocket.channel(`lvu:${entry.ref}`, {
      token: entry.metadata()
    });
  }
  error(reason) {
    if (this.errored) {
      return;
    }
    this.uploadChannel.leave();
    this.errored = true;
    clearTimeout(this.chunkTimer);
    this.entry.error(reason);
  }
  upload() {
    this.uploadChannel.onError((reason) => this.error(reason));
    this.uploadChannel.join().receive("ok", (_data) => this.readNextChunk()).receive("error", (reason) => this.error(reason));
  }
  isDone() {
    return this.offset >= this.entry.file.size;
  }
  readNextChunk() {
    const reader = new window.FileReader();
    const blob = this.entry.file.slice(
      this.offset,
      this.chunkSize + this.offset
    );
    reader.onload = (e) => {
      if (e.target.error === null) {
        this.offset += /** @type {ArrayBuffer} */
        e.target.result.byteLength;
        this.pushChunk(
          /** @type {ArrayBuffer} */
          e.target.result
        );
      } else {
        return logError("Read error: " + e.target.error);
      }
    };
    reader.readAsArrayBuffer(blob);
  }
  pushChunk(chunk) {
    if (!this.uploadChannel.isJoined()) {
      return;
    }
    this.uploadChannel.push("chunk", chunk, this.chunkTimeout).receive("ok", () => {
      this.entry.progress(this.offset / this.entry.file.size * 100);
      if (!this.isDone()) {
        this.chunkTimer = setTimeout(
          () => this.readNextChunk(),
          this.liveSocket.getLatencySim() || 0
        );
      }
    }).receive("error", ({ reason }) => this.error(reason));
  }
};
var logError = (msg, obj) => console.error && console.error(msg, obj);
var channelUploader = function(entries, onError, resp, liveSocket) {
  entries.forEach((entry) => {
    const entryUploader = new EntryUploader(entry, resp.config, liveSocket);
    entryUploader.upload();
  });
};
var DOM = {
  byId(id) {
    return document.getElementById(id) || logError(`no id found for ${id}`);
  },
  removeClass(el, className) {
    el.classList.remove(className);
    if (el.classList.length === 0) {
      el.removeAttribute("class");
    }
  },
  all(node, query, callback) {
    if (!node) {
      return [];
    }
    const array = Array.from(node.querySelectorAll(query));
    if (callback) {
      array.forEach(callback);
    }
    return array;
  },
  childNodeLength(html) {
    const template = document.createElement("template");
    template.innerHTML = html;
    return template.content.childElementCount;
  },
  isUploadInput(el) {
    return el.type === "file" && el.getAttribute(PHX_UPLOAD_REF) !== null;
  },
  isAutoUpload(inputEl) {
    return inputEl.hasAttribute("data-phx-auto-upload");
  },
  findUploadInputs(node) {
    const formId = node.id;
    const inputsOutsideForm = this.all(
      document,
      `input[type="file"][${PHX_UPLOAD_REF}][form="${formId}"]`
    );
    return this.all(node, `input[type="file"][${PHX_UPLOAD_REF}]`).concat(
      inputsOutsideForm
    );
  },
  findComponentNodeList(viewId, cid, doc2 = document) {
    return this.all(
      doc2,
      `[${PHX_VIEW_REF}="${viewId}"][${PHX_COMPONENT}="${cid}"]`
    );
  },
  isPhxDestroyed(node) {
    return node.id && DOM.private(node, "destroyed") ? true : false;
  },
  wantsNewTab(e) {
    const wantsNewTab = e.ctrlKey || e.shiftKey || e.metaKey || e.button && e.button === 1;
    const isDownload = e.target instanceof HTMLAnchorElement && e.target.hasAttribute("download");
    const isTargetBlank = e.target.hasAttribute("target") && e.target.getAttribute("target").toLowerCase() === "_blank";
    const isTargetNamedTab = e.target.hasAttribute("target") && !e.target.getAttribute("target").startsWith("_");
    return wantsNewTab || isTargetBlank || isDownload || isTargetNamedTab;
  },
  isUnloadableFormSubmit(e) {
    const isDialogSubmit = e.target && e.target.getAttribute("method") === "dialog" || e.submitter && e.submitter.getAttribute("formmethod") === "dialog";
    if (isDialogSubmit) {
      return false;
    } else {
      return !e.defaultPrevented && !this.wantsNewTab(e);
    }
  },
  isNewPageClick(e, currentLocation) {
    const href = e.target instanceof HTMLAnchorElement ? e.target.getAttribute("href") : null;
    let url;
    if (e.defaultPrevented || href === null || this.wantsNewTab(e)) {
      return false;
    }
    if (href.startsWith("mailto:") || href.startsWith("tel:")) {
      return false;
    }
    if (e.target.isContentEditable) {
      return false;
    }
    try {
      url = new URL(href);
    } catch {
      try {
        url = new URL(href, currentLocation);
      } catch {
        return true;
      }
    }
    if (url.host === currentLocation.host && url.protocol === currentLocation.protocol) {
      if (url.pathname === currentLocation.pathname && url.search === currentLocation.search) {
        return url.hash === "" && !url.href.endsWith("#");
      }
    }
    return url.protocol.startsWith("http");
  },
  markPhxChildDestroyed(el) {
    if (this.isPhxChild(el)) {
      el.setAttribute(PHX_SESSION, "");
    }
    this.putPrivate(el, "destroyed", true);
  },
  findPhxChildrenInFragment(html, parentId) {
    const template = document.createElement("template");
    template.innerHTML = html;
    return this.findPhxChildren(template.content, parentId);
  },
  isIgnored(el, phxUpdate) {
    return (el.getAttribute(phxUpdate) || el.getAttribute("data-phx-update")) === "ignore";
  },
  isPhxUpdate(el, phxUpdate, updateTypes) {
    return el.getAttribute && updateTypes.indexOf(el.getAttribute(phxUpdate)) >= 0;
  },
  findPhxSticky(el) {
    return this.all(el, `[${PHX_STICKY}]`);
  },
  findPhxChildren(el, parentId) {
    return this.all(el, `${PHX_VIEW_SELECTOR}[${PHX_PARENT_ID}="${parentId}"]`);
  },
  findExistingParentCIDs(viewId, cids) {
    const parentCids = /* @__PURE__ */ new Set();
    const childrenCids = /* @__PURE__ */ new Set();
    cids.forEach((cid) => {
      this.all(
        document,
        `[${PHX_VIEW_REF}="${viewId}"][${PHX_COMPONENT}="${cid}"]`
      ).forEach((parent) => {
        parentCids.add(cid);
        this.all(parent, `[${PHX_VIEW_REF}="${viewId}"][${PHX_COMPONENT}]`).map((el) => parseInt(el.getAttribute(PHX_COMPONENT))).forEach((childCID) => childrenCids.add(childCID));
      });
    });
    childrenCids.forEach((childCid) => parentCids.delete(childCid));
    return parentCids;
  },
  private(el, key) {
    return el[PHX_PRIVATE] && el[PHX_PRIVATE][key];
  },
  deletePrivate(el, key) {
    el[PHX_PRIVATE] && delete el[PHX_PRIVATE][key];
  },
  putPrivate(el, key, value) {
    if (!el[PHX_PRIVATE]) {
      el[PHX_PRIVATE] = {};
    }
    el[PHX_PRIVATE][key] = value;
  },
  updatePrivate(el, key, defaultVal, updateFunc) {
    const existing = this.private(el, key);
    if (existing === void 0) {
      this.putPrivate(el, key, updateFunc(defaultVal));
    } else {
      this.putPrivate(el, key, updateFunc(existing));
    }
  },
  syncPendingAttrs(fromEl, toEl) {
    if (!fromEl.hasAttribute(PHX_REF_SRC)) {
      return;
    }
    PHX_EVENT_CLASSES.forEach((className) => {
      fromEl.classList.contains(className) && toEl.classList.add(className);
    });
    PHX_PENDING_ATTRS.filter((attr) => fromEl.hasAttribute(attr)).forEach(
      (attr) => {
        toEl.setAttribute(attr, fromEl.getAttribute(attr));
      }
    );
  },
  copyPrivates(target, source) {
    if (source[PHX_PRIVATE]) {
      target[PHX_PRIVATE] = source[PHX_PRIVATE];
    }
  },
  putTitle(str) {
    const titleEl = document.querySelector("title");
    if (titleEl) {
      const { prefix, suffix, default: defaultTitle } = titleEl.dataset;
      const isEmpty2 = typeof str !== "string" || str.trim() === "";
      if (isEmpty2 && typeof defaultTitle !== "string") {
        return;
      }
      const inner = isEmpty2 ? defaultTitle : str;
      document.title = `${prefix || ""}${inner || ""}${suffix || ""}`;
    } else {
      document.title = str;
    }
  },
  debounce(el, event, phxDebounce, defaultDebounce, phxThrottle, defaultThrottle, asyncFilter, callback) {
    let debounce = el.getAttribute(phxDebounce);
    let throttle = el.getAttribute(phxThrottle);
    if (debounce === "") {
      debounce = defaultDebounce;
    }
    if (throttle === "") {
      throttle = defaultThrottle;
    }
    const value = debounce || throttle;
    switch (value) {
      case null:
        return callback();
      case "blur":
        this.incCycle(el, "debounce-blur-cycle", () => {
          if (asyncFilter()) {
            callback();
          }
        });
        if (this.once(el, "debounce-blur")) {
          el.addEventListener(
            "blur",
            () => this.triggerCycle(el, "debounce-blur-cycle")
          );
        }
        return;
      default:
        const timeout = parseInt(value);
        const trigger = () => throttle ? this.deletePrivate(el, THROTTLED) : callback();
        const currentCycle = this.incCycle(el, DEBOUNCE_TRIGGER, trigger);
        if (isNaN(timeout)) {
          return logError(`invalid throttle/debounce value: ${value}`);
        }
        if (throttle) {
          let newKeyDown = false;
          if (event.type === "keydown") {
            const prevKey = this.private(el, DEBOUNCE_PREV_KEY);
            this.putPrivate(el, DEBOUNCE_PREV_KEY, event.key);
            newKeyDown = prevKey !== event.key;
          }
          if (!newKeyDown && this.private(el, THROTTLED)) {
            return false;
          } else {
            callback();
            const t = setTimeout(() => {
              if (asyncFilter()) {
                this.triggerCycle(el, DEBOUNCE_TRIGGER);
              }
            }, timeout);
            this.putPrivate(el, THROTTLED, t);
          }
        } else {
          setTimeout(() => {
            if (asyncFilter()) {
              this.triggerCycle(el, DEBOUNCE_TRIGGER, currentCycle);
            }
          }, timeout);
        }
        const form = el.form;
        if (form && this.once(form, "bind-debounce")) {
          form.addEventListener("submit", () => {
            Array.from(new FormData(form).entries(), ([name]) => {
              const input = form.querySelector(`[name="${name}"]`);
              this.incCycle(input, DEBOUNCE_TRIGGER);
              this.deletePrivate(input, THROTTLED);
            });
          });
        }
        if (this.once(el, "bind-debounce")) {
          el.addEventListener("blur", () => {
            clearTimeout(this.private(el, THROTTLED));
            this.triggerCycle(el, DEBOUNCE_TRIGGER);
          });
        }
    }
  },
  triggerCycle(el, key, currentCycle) {
    const [cycle, trigger] = this.private(el, key);
    if (!currentCycle) {
      currentCycle = cycle;
    }
    if (currentCycle === cycle) {
      this.incCycle(el, key);
      trigger();
    }
  },
  once(el, key) {
    if (this.private(el, key) === true) {
      return false;
    }
    this.putPrivate(el, key, true);
    return true;
  },
  incCycle(el, key, trigger = function() {
  }) {
    let [currentCycle] = this.private(el, key) || [0, trigger];
    currentCycle++;
    this.putPrivate(el, key, [currentCycle, trigger]);
    return currentCycle;
  },
  // maintains or adds privately used hook information
  // fromEl and toEl can be the same element in the case of a newly added node
  // fromEl and toEl can be any HTML node type, so we need to check if it's an element node
  maintainPrivateHooks(fromEl, toEl, phxViewportTop, phxViewportBottom) {
    if (fromEl.hasAttribute && fromEl.hasAttribute("data-phx-hook") && !toEl.hasAttribute("data-phx-hook")) {
      toEl.setAttribute("data-phx-hook", fromEl.getAttribute("data-phx-hook"));
    }
    if (toEl.hasAttribute && (toEl.hasAttribute(phxViewportTop) || toEl.hasAttribute(phxViewportBottom))) {
      toEl.setAttribute("data-phx-hook", "Phoenix.InfiniteScroll");
    }
  },
  putCustomElHook(el, hook) {
    if (el.isConnected) {
      el.setAttribute("data-phx-hook", "");
    } else {
      console.error(`
        hook attached to non-connected DOM element
        ensure you are calling createHook within your connectedCallback. ${el.outerHTML}
      `);
    }
    this.putPrivate(el, "custom-el-hook", hook);
  },
  getCustomElHook(el) {
    return this.private(el, "custom-el-hook");
  },
  isUsedInput(el) {
    return el.nodeType === Node.ELEMENT_NODE && (this.private(el, PHX_HAS_FOCUSED) || this.private(el, PHX_HAS_SUBMITTED));
  },
  resetForm(form) {
    Array.from(form.elements).forEach((input) => {
      this.deletePrivate(input, PHX_HAS_FOCUSED);
      this.deletePrivate(input, PHX_HAS_SUBMITTED);
    });
  },
  isPhxChild(node) {
    return node.getAttribute && node.getAttribute(PHX_PARENT_ID);
  },
  isPhxSticky(node) {
    return node.getAttribute && node.getAttribute(PHX_STICKY) !== null;
  },
  isChildOfAny(el, parents) {
    return !!parents.find((parent) => parent.contains(el));
  },
  firstPhxChild(el) {
    return this.isPhxChild(el) ? el : this.all(el, `[${PHX_PARENT_ID}]`)[0];
  },
  isPortalTemplate(el) {
    return el.tagName === "TEMPLATE" && el.hasAttribute(PHX_PORTAL);
  },
  closestViewEl(el) {
    const portalOrViewEl = el.closest(
      `[${PHX_TELEPORTED_REF}],${PHX_VIEW_SELECTOR}`
    );
    if (!portalOrViewEl) {
      return null;
    }
    if (portalOrViewEl.hasAttribute(PHX_TELEPORTED_REF)) {
      return this.byId(portalOrViewEl.getAttribute(PHX_TELEPORTED_REF));
    } else if (portalOrViewEl.hasAttribute(PHX_SESSION)) {
      return portalOrViewEl;
    }
    return null;
  },
  dispatchEvent(target, name, opts = {}) {
    let defaultBubble = true;
    const isUploadTarget = target.nodeName === "INPUT" && target.type === "file";
    if (isUploadTarget && name === "click") {
      defaultBubble = false;
    }
    const bubbles = opts.bubbles === void 0 ? defaultBubble : !!opts.bubbles;
    const eventOpts = {
      bubbles,
      cancelable: true,
      detail: opts.detail || {}
    };
    const event = name === "click" ? new MouseEvent("click", eventOpts) : new CustomEvent(name, eventOpts);
    target.dispatchEvent(event);
  },
  cloneNode(node, html) {
    if (typeof html === "undefined") {
      return node.cloneNode(true);
    } else {
      const cloned = node.cloneNode(false);
      cloned.innerHTML = html;
      return cloned;
    }
  },
  // merge attributes from source to target
  // if an element is ignored, we only merge data attributes
  // including removing data attributes that are no longer in the source
  mergeAttrs(target, source, opts = {}) {
    const exclude = new Set(opts.exclude || []);
    const isIgnored = opts.isIgnored;
    const sourceAttrs = source.attributes;
    for (let i = sourceAttrs.length - 1; i >= 0; i--) {
      const name = sourceAttrs[i].name;
      if (!exclude.has(name)) {
        const sourceValue = source.getAttribute(name);
        if (target.getAttribute(name) !== sourceValue && (!isIgnored || isIgnored && name.startsWith("data-"))) {
          target.setAttribute(name, sourceValue);
        }
      } else {
        if (name === "value" && target.value === source.value) {
          target.setAttribute("value", source.getAttribute(name));
        }
      }
    }
    const targetAttrs = target.attributes;
    for (let i = targetAttrs.length - 1; i >= 0; i--) {
      const name = targetAttrs[i].name;
      if (isIgnored) {
        if (name.startsWith("data-") && !source.hasAttribute(name) && !PHX_PENDING_ATTRS.includes(name)) {
          target.removeAttribute(name);
        }
      } else {
        if (!source.hasAttribute(name)) {
          target.removeAttribute(name);
        }
      }
    }
  },
  mergeFocusedInput(target, source) {
    if (!(target instanceof HTMLSelectElement)) {
      DOM.mergeAttrs(target, source, { exclude: ["value"] });
    }
    if (source.readOnly) {
      target.setAttribute("readonly", true);
    } else {
      target.removeAttribute("readonly");
    }
  },
  hasSelectionRange(el) {
    return el.setSelectionRange && (el.type === "text" || el.type === "textarea");
  },
  restoreFocus(focused, selectionStart, selectionEnd) {
    if (focused instanceof HTMLSelectElement) {
      focused.focus();
    }
    if (!DOM.isTextualInput(focused)) {
      return;
    }
    const wasFocused = focused.matches(":focus");
    if (!wasFocused) {
      focused.focus();
    }
    if (this.hasSelectionRange(focused)) {
      focused.setSelectionRange(selectionStart, selectionEnd);
    }
  },
  isFormInput(el) {
    if (el.localName && customElements.get(el.localName)) {
      return customElements.get(el.localName)[`formAssociated`];
    }
    return /^(?:input|select|textarea)$/i.test(el.tagName) && el.type !== "button";
  },
  syncAttrsToProps(el) {
    if (el instanceof HTMLInputElement && CHECKABLE_INPUTS.indexOf(el.type.toLocaleLowerCase()) >= 0) {
      el.checked = el.getAttribute("checked") !== null;
    }
  },
  isTextualInput(el) {
    return FOCUSABLE_INPUTS.indexOf(el.type) >= 0;
  },
  isNowTriggerFormExternal(el, phxTriggerExternal) {
    return el.getAttribute && el.getAttribute(phxTriggerExternal) !== null && document.body.contains(el);
  },
  cleanChildNodes(container, phxUpdate) {
    if (DOM.isPhxUpdate(container, phxUpdate, ["append", "prepend", PHX_STREAM])) {
      const toRemove = [];
      container.childNodes.forEach((childNode) => {
        if (!childNode.id) {
          const isEmptyTextNode = childNode.nodeType === Node.TEXT_NODE && childNode.nodeValue.trim() === "";
          if (!isEmptyTextNode && childNode.nodeType !== Node.COMMENT_NODE) {
            logError(
              `only HTML element tags with an id are allowed inside containers with phx-update.

removing illegal node: "${(childNode.outerHTML || childNode.nodeValue).trim()}"

`
            );
          }
          toRemove.push(childNode);
        }
      });
      toRemove.forEach((childNode) => childNode.remove());
    }
  },
  replaceRootContainer(container, tagName, attrs) {
    const retainedAttrs = /* @__PURE__ */ new Set([
      "id",
      PHX_SESSION,
      PHX_STATIC,
      PHX_MAIN,
      PHX_ROOT_ID
    ]);
    if (container.tagName.toLowerCase() === tagName.toLowerCase()) {
      Array.from(container.attributes).filter((attr) => !retainedAttrs.has(attr.name.toLowerCase())).forEach((attr) => container.removeAttribute(attr.name));
      Object.keys(attrs).filter((name) => !retainedAttrs.has(name.toLowerCase())).forEach((attr) => container.setAttribute(attr, attrs[attr]));
      return container;
    } else {
      const newContainer = document.createElement(tagName);
      Object.keys(attrs).forEach(
        (attr) => newContainer.setAttribute(attr, attrs[attr])
      );
      retainedAttrs.forEach(
        (attr) => newContainer.setAttribute(attr, container.getAttribute(attr))
      );
      newContainer.innerHTML = container.innerHTML;
      container.replaceWith(newContainer);
      return newContainer;
    }
  },
  getSticky(el, name, defaultVal) {
    const op = (DOM.private(el, "sticky") || []).find(
      ([existingName]) => name === existingName
    );
    if (op) {
      const [_name, _op, stashedResult] = op;
      return stashedResult;
    } else {
      return typeof defaultVal === "function" ? defaultVal() : defaultVal;
    }
  },
  deleteSticky(el, name) {
    this.updatePrivate(el, "sticky", [], (ops) => {
      return ops.filter(([existingName, _]) => existingName !== name);
    });
  },
  putSticky(el, name, op) {
    const stashedResult = op(el);
    this.updatePrivate(el, "sticky", [], (ops) => {
      const existingIndex = ops.findIndex(
        ([existingName]) => name === existingName
      );
      if (existingIndex >= 0) {
        ops[existingIndex] = [name, op, stashedResult];
      } else {
        ops.push([name, op, stashedResult]);
      }
      return ops;
    });
  },
  applyStickyOperations(el) {
    const ops = DOM.private(el, "sticky");
    if (!ops) {
      return;
    }
    ops.forEach(([name, op, _stashed]) => this.putSticky(el, name, op));
  },
  isLocked(el) {
    return el.hasAttribute && el.hasAttribute(PHX_REF_LOCK);
  }
};
var dom_default = DOM;
var UploadEntry = class {
  static isActive(fileEl, file) {
    const isNew = file._phxRef === void 0;
    const activeRefs = fileEl.getAttribute(PHX_ACTIVE_ENTRY_REFS).split(",");
    const isActive = activeRefs.indexOf(LiveUploader.genFileRef(file)) >= 0;
    return file.size > 0 && (isNew || isActive);
  }
  static isPreflighted(fileEl, file) {
    const preflightedRefs = fileEl.getAttribute(PHX_PREFLIGHTED_REFS).split(",");
    const isPreflighted = preflightedRefs.indexOf(LiveUploader.genFileRef(file)) >= 0;
    return isPreflighted && this.isActive(fileEl, file);
  }
  static isPreflightInProgress(file) {
    return file._preflightInProgress === true;
  }
  static markPreflightInProgress(file) {
    file._preflightInProgress = true;
  }
  constructor(fileEl, file, view, autoUpload) {
    this.ref = LiveUploader.genFileRef(file);
    this.fileEl = fileEl;
    this.file = file;
    this.view = view;
    this.meta = null;
    this._isCancelled = false;
    this._isDone = false;
    this._progress = 0;
    this._lastProgressSent = -1;
    this._onDone = function() {
    };
    this._onElUpdated = this.onElUpdated.bind(this);
    this.fileEl.addEventListener(PHX_LIVE_FILE_UPDATED, this._onElUpdated);
    this.autoUpload = autoUpload;
  }
  metadata() {
    return this.meta;
  }
  progress(progress) {
    this._progress = Math.floor(progress);
    if (this._progress > this._lastProgressSent) {
      if (this._progress >= 100) {
        this._progress = 100;
        this._lastProgressSent = 100;
        this._isDone = true;
        this.view.pushFileProgress(this.fileEl, this.ref, 100, () => {
          LiveUploader.untrackFile(this.fileEl, this.file);
          this._onDone();
        });
      } else {
        this._lastProgressSent = this._progress;
        this.view.pushFileProgress(this.fileEl, this.ref, this._progress);
      }
    }
  }
  isCancelled() {
    return this._isCancelled;
  }
  cancel() {
    this.file._preflightInProgress = false;
    this._isCancelled = true;
    this._isDone = true;
    this._onDone();
  }
  isDone() {
    return this._isDone;
  }
  error(reason = "failed") {
    this.fileEl.removeEventListener(PHX_LIVE_FILE_UPDATED, this._onElUpdated);
    this.view.pushFileProgress(this.fileEl, this.ref, { error: reason });
    if (!this.isAutoUpload()) {
      LiveUploader.clearFiles(this.fileEl);
    }
  }
  isAutoUpload() {
    return this.autoUpload;
  }
  //private
  onDone(callback) {
    this._onDone = () => {
      this.fileEl.removeEventListener(PHX_LIVE_FILE_UPDATED, this._onElUpdated);
      callback();
    };
  }
  onElUpdated() {
    const activeRefs = this.fileEl.getAttribute(PHX_ACTIVE_ENTRY_REFS).split(",");
    if (activeRefs.indexOf(this.ref) === -1) {
      LiveUploader.untrackFile(this.fileEl, this.file);
      this.cancel();
    }
  }
  toPreflightPayload() {
    return {
      last_modified: this.file.lastModified,
      name: this.file.name,
      relative_path: this.file.webkitRelativePath,
      size: this.file.size,
      type: this.file.type,
      ref: this.ref,
      meta: typeof this.file.meta === "function" ? this.file.meta() : void 0
    };
  }
  uploader(uploaders) {
    if (this.meta.uploader) {
      const callback = uploaders[this.meta.uploader] || logError(`no uploader configured for ${this.meta.uploader}`);
      return { name: this.meta.uploader, callback };
    } else {
      return { name: "channel", callback: channelUploader };
    }
  }
  zipPostFlight(resp) {
    this.meta = resp.entries[this.ref];
    if (!this.meta) {
      logError(`no preflight upload response returned with ref ${this.ref}`, {
        input: this.fileEl,
        response: resp
      });
    }
  }
};
var liveUploaderFileRef = 0;
var LiveUploader = class _LiveUploader {
  static genFileRef(file) {
    const ref = file._phxRef;
    if (ref !== void 0) {
      return ref;
    } else {
      file._phxRef = (liveUploaderFileRef++).toString();
      return file._phxRef;
    }
  }
  static getEntryDataURL(inputEl, ref, callback) {
    const file = this.activeFiles(inputEl).find(
      (file2) => this.genFileRef(file2) === ref
    );
    callback(URL.createObjectURL(file));
  }
  static hasUploadsInProgress(formEl) {
    let active = 0;
    dom_default.findUploadInputs(formEl).forEach((input) => {
      if (input.getAttribute(PHX_PREFLIGHTED_REFS) !== input.getAttribute(PHX_DONE_REFS)) {
        active++;
      }
    });
    return active > 0;
  }
  static serializeUploads(inputEl) {
    const files = this.activeFiles(inputEl);
    const fileData = {};
    files.forEach((file) => {
      const entry = { path: inputEl.name };
      const uploadRef = inputEl.getAttribute(PHX_UPLOAD_REF);
      fileData[uploadRef] = fileData[uploadRef] || [];
      entry.ref = this.genFileRef(file);
      entry.last_modified = file.lastModified;
      entry.name = file.name || entry.ref;
      entry.relative_path = file.webkitRelativePath;
      entry.type = file.type;
      entry.size = file.size;
      if (typeof file.meta === "function") {
        entry.meta = file.meta();
      }
      fileData[uploadRef].push(entry);
    });
    return fileData;
  }
  static clearFiles(inputEl) {
    inputEl.value = null;
    inputEl.removeAttribute(PHX_UPLOAD_REF);
    dom_default.putPrivate(inputEl, "files", []);
  }
  static untrackFile(inputEl, file) {
    dom_default.putPrivate(
      inputEl,
      "files",
      dom_default.private(inputEl, "files").filter((f) => !Object.is(f, file))
    );
  }
  /**
   * @param {HTMLInputElement} inputEl
   * @param {Array<File|Blob>} files
   * @param {DataTransfer} [dataTransfer]
   */
  static trackFiles(inputEl, files, dataTransfer) {
    if (inputEl.getAttribute("multiple") !== null) {
      const newFiles = files.filter(
        (file) => !this.activeFiles(inputEl).find((f) => Object.is(f, file))
      );
      dom_default.updatePrivate(
        inputEl,
        "files",
        [],
        (existing) => existing.concat(newFiles)
      );
      inputEl.value = null;
    } else {
      if (dataTransfer && dataTransfer.files.length > 0) {
        inputEl.files = dataTransfer.files;
      }
      dom_default.putPrivate(inputEl, "files", files);
    }
  }
  static activeFileInputs(formEl) {
    const fileInputs = dom_default.findUploadInputs(formEl);
    return Array.from(fileInputs).filter(
      (el) => el.files && this.activeFiles(el).length > 0
    );
  }
  static activeFiles(input) {
    return (dom_default.private(input, "files") || []).filter(
      (f) => UploadEntry.isActive(input, f)
    );
  }
  static inputsAwaitingPreflight(formEl) {
    const fileInputs = dom_default.findUploadInputs(formEl);
    return Array.from(fileInputs).filter(
      (input) => this.filesAwaitingPreflight(input).length > 0
    );
  }
  static filesAwaitingPreflight(input) {
    return this.activeFiles(input).filter(
      (f) => !UploadEntry.isPreflighted(input, f) && !UploadEntry.isPreflightInProgress(f)
    );
  }
  static markPreflightInProgress(entries) {
    entries.forEach((entry) => UploadEntry.markPreflightInProgress(entry.file));
  }
  constructor(inputEl, view, onComplete) {
    this.autoUpload = dom_default.isAutoUpload(inputEl);
    this.view = view;
    this.onComplete = onComplete;
    this._entries = Array.from(
      _LiveUploader.filesAwaitingPreflight(inputEl) || []
    ).map((file) => new UploadEntry(inputEl, file, view, this.autoUpload));
    _LiveUploader.markPreflightInProgress(this._entries);
    this.numEntriesInProgress = this._entries.length;
  }
  isAutoUpload() {
    return this.autoUpload;
  }
  entries() {
    return this._entries;
  }
  initAdapterUpload(resp, onError, liveSocket) {
    this._entries = this._entries.map((entry) => {
      if (entry.isCancelled()) {
        this.numEntriesInProgress--;
        if (this.numEntriesInProgress === 0) {
          this.onComplete();
        }
      } else {
        entry.zipPostFlight(resp);
        entry.onDone(() => {
          this.numEntriesInProgress--;
          if (this.numEntriesInProgress === 0) {
            this.onComplete();
          }
        });
      }
      return entry;
    });
    const groupedEntries = this._entries.reduce((acc, entry) => {
      if (!entry.meta) {
        return acc;
      }
      const { name, callback } = entry.uploader(liveSocket.uploaders);
      acc[name] = acc[name] || { callback, entries: [] };
      acc[name].entries.push(entry);
      return acc;
    }, {});
    for (const name in groupedEntries) {
      const { callback, entries } = groupedEntries[name];
      callback(entries, onError, resp, liveSocket);
    }
  }
};
var ARIA = {
  anyOf(instance, classes) {
    return classes.find((name) => instance instanceof name);
  },
  isFocusable(el, interactiveOnly) {
    return el instanceof HTMLAnchorElement && el.rel !== "ignore" || el instanceof HTMLAreaElement && el.href !== void 0 || !el.disabled && this.anyOf(el, [
      HTMLInputElement,
      HTMLSelectElement,
      HTMLTextAreaElement,
      HTMLButtonElement
    ]) || el instanceof HTMLIFrameElement || el.tabIndex >= 0 && el.getAttribute("aria-hidden") !== "true" || !interactiveOnly && el.getAttribute("tabindex") !== null && el.getAttribute("aria-hidden") !== "true";
  },
  attemptFocus(el, interactiveOnly) {
    if (this.isFocusable(el, interactiveOnly)) {
      try {
        el.focus();
      } catch {
      }
    }
    return !!document.activeElement && document.activeElement.isSameNode(el);
  },
  focusFirstInteractive(el) {
    let child = el.firstElementChild;
    while (child) {
      if (this.attemptFocus(child, true) || this.focusFirstInteractive(child)) {
        return true;
      }
      child = child.nextElementSibling;
    }
  },
  focusFirst(el) {
    let child = el.firstElementChild;
    while (child) {
      if (this.attemptFocus(child) || this.focusFirst(child)) {
        return true;
      }
      child = child.nextElementSibling;
    }
  },
  focusLast(el) {
    let child = el.lastElementChild;
    while (child) {
      if (this.attemptFocus(child) || this.focusLast(child)) {
        return true;
      }
      child = child.previousElementSibling;
    }
  }
};
var aria_default = ARIA;
var Hooks = {
  LiveFileUpload: {
    activeRefs() {
      return this.el.getAttribute(PHX_ACTIVE_ENTRY_REFS);
    },
    preflightedRefs() {
      return this.el.getAttribute(PHX_PREFLIGHTED_REFS);
    },
    mounted() {
      this.preflightedWas = this.preflightedRefs();
    },
    updated() {
      const newPreflights = this.preflightedRefs();
      if (this.preflightedWas !== newPreflights) {
        this.preflightedWas = newPreflights;
        if (newPreflights === "") {
          this.__view().cancelSubmit(this.el.form);
        }
      }
      if (this.activeRefs() === "") {
        this.el.value = null;
      }
      this.el.dispatchEvent(new CustomEvent(PHX_LIVE_FILE_UPDATED));
    }
  },
  LiveImgPreview: {
    mounted() {
      this.ref = this.el.getAttribute("data-phx-entry-ref");
      this.inputEl = document.getElementById(
        this.el.getAttribute(PHX_UPLOAD_REF)
      );
      LiveUploader.getEntryDataURL(this.inputEl, this.ref, (url) => {
        this.url = url;
        this.el.src = url;
      });
    },
    destroyed() {
      URL.revokeObjectURL(this.url);
    }
  },
  FocusWrap: {
    mounted() {
      this.focusStart = this.el.firstElementChild;
      this.focusEnd = this.el.lastElementChild;
      this.focusStart.addEventListener("focus", (e) => {
        if (!e.relatedTarget || !this.el.contains(e.relatedTarget)) {
          const nextFocus = e.target.nextElementSibling;
          aria_default.attemptFocus(nextFocus) || aria_default.focusFirst(nextFocus);
        } else {
          aria_default.focusLast(this.el);
        }
      });
      this.focusEnd.addEventListener("focus", (e) => {
        if (!e.relatedTarget || !this.el.contains(e.relatedTarget)) {
          const nextFocus = e.target.previousElementSibling;
          aria_default.attemptFocus(nextFocus) || aria_default.focusLast(nextFocus);
        } else {
          aria_default.focusFirst(this.el);
        }
      });
      if (!this.el.contains(document.activeElement)) {
        this.el.addEventListener("phx:show-end", () => this.el.focus());
        if (window.getComputedStyle(this.el).display !== "none") {
          aria_default.focusFirst(this.el);
        }
      }
    }
  }
};
var findScrollContainer = (el) => {
  if (["HTML", "BODY"].indexOf(el.nodeName.toUpperCase()) >= 0)
    return null;
  if (["scroll", "auto"].indexOf(getComputedStyle(el).overflowY) >= 0)
    return el;
  return findScrollContainer(el.parentElement);
};
var scrollTop = (scrollContainer) => {
  if (scrollContainer) {
    return scrollContainer.scrollTop;
  } else {
    return document.documentElement.scrollTop || document.body.scrollTop;
  }
};
var bottom = (scrollContainer) => {
  if (scrollContainer) {
    return scrollContainer.getBoundingClientRect().bottom;
  } else {
    return window.innerHeight || document.documentElement.clientHeight;
  }
};
var top = (scrollContainer) => {
  if (scrollContainer) {
    return scrollContainer.getBoundingClientRect().top;
  } else {
    return 0;
  }
};
var isAtViewportTop = (el, scrollContainer) => {
  const rect = el.getBoundingClientRect();
  return Math.ceil(rect.top) >= top(scrollContainer) && Math.ceil(rect.left) >= 0 && Math.floor(rect.top) <= bottom(scrollContainer);
};
var isAtViewportBottom = (el, scrollContainer) => {
  const rect = el.getBoundingClientRect();
  return Math.ceil(rect.bottom) >= top(scrollContainer) && Math.ceil(rect.left) >= 0 && Math.floor(rect.bottom) <= bottom(scrollContainer);
};
var isWithinViewport = (el, scrollContainer) => {
  const rect = el.getBoundingClientRect();
  return Math.ceil(rect.top) >= top(scrollContainer) && Math.ceil(rect.left) >= 0 && Math.floor(rect.top) <= bottom(scrollContainer);
};
Hooks.InfiniteScroll = {
  mounted() {
    this.scrollContainer = findScrollContainer(this.el);
    let scrollBefore = scrollTop(this.scrollContainer);
    let topOverran = false;
    const throttleInterval = 500;
    let pendingOp = null;
    const onTopOverrun = this.throttle(
      throttleInterval,
      (topEvent, firstChild) => {
        pendingOp = () => true;
        this.liveSocket.js().push(this.el, topEvent, {
          value: { id: firstChild.id, _overran: true },
          callback: () => {
            pendingOp = null;
          }
        });
      }
    );
    const onFirstChildAtTop = this.throttle(
      throttleInterval,
      (topEvent, firstChild) => {
        pendingOp = () => firstChild.scrollIntoView({ block: "start" });
        this.liveSocket.js().push(this.el, topEvent, {
          value: { id: firstChild.id },
          callback: () => {
            pendingOp = null;
            window.requestAnimationFrame(() => {
              if (!isWithinViewport(firstChild, this.scrollContainer)) {
                firstChild.scrollIntoView({ block: "start" });
              }
            });
          }
        });
      }
    );
    const onLastChildAtBottom = this.throttle(
      throttleInterval,
      (bottomEvent, lastChild) => {
        pendingOp = () => lastChild.scrollIntoView({ block: "end" });
        this.liveSocket.js().push(this.el, bottomEvent, {
          value: { id: lastChild.id },
          callback: () => {
            pendingOp = null;
            window.requestAnimationFrame(() => {
              if (!isWithinViewport(lastChild, this.scrollContainer)) {
                lastChild.scrollIntoView({ block: "end" });
              }
            });
          }
        });
      }
    );
    this.onScroll = (_e) => {
      const scrollNow = scrollTop(this.scrollContainer);
      if (pendingOp) {
        scrollBefore = scrollNow;
        return pendingOp();
      }
      const rect = this.el.getBoundingClientRect();
      const topEvent = this.el.getAttribute(
        this.liveSocket.binding("viewport-top")
      );
      const bottomEvent = this.el.getAttribute(
        this.liveSocket.binding("viewport-bottom")
      );
      const lastChild = this.el.lastElementChild;
      const firstChild = this.el.firstElementChild;
      const isScrollingUp = scrollNow < scrollBefore;
      const isScrollingDown = scrollNow > scrollBefore;
      if (isScrollingUp && topEvent && !topOverran && rect.top >= 0) {
        topOverran = true;
        onTopOverrun(topEvent, firstChild);
      } else if (isScrollingDown && topOverran && rect.top <= 0) {
        topOverran = false;
      }
      if (topEvent && isScrollingUp && isAtViewportTop(firstChild, this.scrollContainer)) {
        onFirstChildAtTop(topEvent, firstChild);
      } else if (bottomEvent && isScrollingDown && isAtViewportBottom(lastChild, this.scrollContainer)) {
        onLastChildAtBottom(bottomEvent, lastChild);
      }
      scrollBefore = scrollNow;
    };
    if (this.scrollContainer) {
      this.scrollContainer.addEventListener("scroll", this.onScroll);
    } else {
      window.addEventListener("scroll", this.onScroll);
    }
  },
  destroyed() {
    if (this.scrollContainer) {
      this.scrollContainer.removeEventListener("scroll", this.onScroll);
    } else {
      window.removeEventListener("scroll", this.onScroll);
    }
  },
  throttle(interval, callback) {
    let lastCallAt = 0;
    let timer;
    return (...args) => {
      const now = Date.now();
      const remainingTime = interval - (now - lastCallAt);
      if (remainingTime <= 0 || remainingTime > interval) {
        if (timer) {
          clearTimeout(timer);
          timer = null;
        }
        lastCallAt = now;
        callback(...args);
      } else if (!timer) {
        timer = setTimeout(() => {
          lastCallAt = Date.now();
          timer = null;
          callback(...args);
        }, remainingTime);
      }
    };
  }
};
var DOCUMENT_FRAGMENT_NODE = 11;
function morphAttrs(fromNode, toNode) {
  var toNodeAttrs = toNode.attributes;
  var attr;
  var attrName;
  var attrNamespaceURI;
  var attrValue;
  var fromValue;
  if (toNode.nodeType === DOCUMENT_FRAGMENT_NODE || fromNode.nodeType === DOCUMENT_FRAGMENT_NODE) {
    return;
  }
  for (var i = toNodeAttrs.length - 1; i >= 0; i--) {
    attr = toNodeAttrs[i];
    attrName = attr.name;
    attrNamespaceURI = attr.namespaceURI;
    attrValue = attr.value;
    if (attrNamespaceURI) {
      attrName = attr.localName || attrName;
      fromValue = fromNode.getAttributeNS(attrNamespaceURI, attrName);
      if (fromValue !== attrValue) {
        if (attr.prefix === "xmlns") {
          attrName = attr.name;
        }
        fromNode.setAttributeNS(attrNamespaceURI, attrName, attrValue);
      }
    } else {
      fromValue = fromNode.getAttribute(attrName);
      if (fromValue !== attrValue) {
        fromNode.setAttribute(attrName, attrValue);
      }
    }
  }
  var fromNodeAttrs = fromNode.attributes;
  for (var d = fromNodeAttrs.length - 1; d >= 0; d--) {
    attr = fromNodeAttrs[d];
    attrName = attr.name;
    attrNamespaceURI = attr.namespaceURI;
    if (attrNamespaceURI) {
      attrName = attr.localName || attrName;
      if (!toNode.hasAttributeNS(attrNamespaceURI, attrName)) {
        fromNode.removeAttributeNS(attrNamespaceURI, attrName);
      }
    } else {
      if (!toNode.hasAttribute(attrName)) {
        fromNode.removeAttribute(attrName);
      }
    }
  }
}
var range;
var NS_XHTML = "http://www.w3.org/1999/xhtml";
var doc = typeof document === "undefined" ? void 0 : document;
var HAS_TEMPLATE_SUPPORT = !!doc && "content" in doc.createElement("template");
var HAS_RANGE_SUPPORT = !!doc && doc.createRange && "createContextualFragment" in doc.createRange();
function createFragmentFromTemplate(str) {
  var template = doc.createElement("template");
  template.innerHTML = str;
  return template.content.childNodes[0];
}
function createFragmentFromRange(str) {
  if (!range) {
    range = doc.createRange();
    range.selectNode(doc.body);
  }
  var fragment = range.createContextualFragment(str);
  return fragment.childNodes[0];
}
function createFragmentFromWrap(str) {
  var fragment = doc.createElement("body");
  fragment.innerHTML = str;
  return fragment.childNodes[0];
}
function toElement(str) {
  str = str.trim();
  if (HAS_TEMPLATE_SUPPORT) {
    return createFragmentFromTemplate(str);
  } else if (HAS_RANGE_SUPPORT) {
    return createFragmentFromRange(str);
  }
  return createFragmentFromWrap(str);
}
function compareNodeNames(fromEl, toEl) {
  var fromNodeName = fromEl.nodeName;
  var toNodeName = toEl.nodeName;
  var fromCodeStart, toCodeStart;
  if (fromNodeName === toNodeName) {
    return true;
  }
  fromCodeStart = fromNodeName.charCodeAt(0);
  toCodeStart = toNodeName.charCodeAt(0);
  if (fromCodeStart <= 90 && toCodeStart >= 97) {
    return fromNodeName === toNodeName.toUpperCase();
  } else if (toCodeStart <= 90 && fromCodeStart >= 97) {
    return toNodeName === fromNodeName.toUpperCase();
  } else {
    return false;
  }
}
function createElementNS(name, namespaceURI) {
  return !namespaceURI || namespaceURI === NS_XHTML ? doc.createElement(name) : doc.createElementNS(namespaceURI, name);
}
function moveChildren(fromEl, toEl) {
  var curChild = fromEl.firstChild;
  while (curChild) {
    var nextChild = curChild.nextSibling;
    toEl.appendChild(curChild);
    curChild = nextChild;
  }
  return toEl;
}
function syncBooleanAttrProp(fromEl, toEl, name) {
  if (fromEl[name] !== toEl[name]) {
    fromEl[name] = toEl[name];
    if (fromEl[name]) {
      fromEl.setAttribute(name, "");
    } else {
      fromEl.removeAttribute(name);
    }
  }
}
var specialElHandlers = {
  OPTION: function(fromEl, toEl) {
    var parentNode = fromEl.parentNode;
    if (parentNode) {
      var parentName = parentNode.nodeName.toUpperCase();
      if (parentName === "OPTGROUP") {
        parentNode = parentNode.parentNode;
        parentName = parentNode && parentNode.nodeName.toUpperCase();
      }
      if (parentName === "SELECT" && !parentNode.hasAttribute("multiple")) {
        if (fromEl.hasAttribute("selected") && !toEl.selected) {
          fromEl.setAttribute("selected", "selected");
          fromEl.removeAttribute("selected");
        }
        parentNode.selectedIndex = -1;
      }
    }
    syncBooleanAttrProp(fromEl, toEl, "selected");
  },
  /**
   * The "value" attribute is special for the <input> element since it sets
   * the initial value. Changing the "value" attribute without changing the
   * "value" property will have no effect since it is only used to the set the
   * initial value.  Similar for the "checked" attribute, and "disabled".
   */
  INPUT: function(fromEl, toEl) {
    syncBooleanAttrProp(fromEl, toEl, "checked");
    syncBooleanAttrProp(fromEl, toEl, "disabled");
    if (fromEl.value !== toEl.value) {
      fromEl.value = toEl.value;
    }
    if (!toEl.hasAttribute("value")) {
      fromEl.removeAttribute("value");
    }
  },
  TEXTAREA: function(fromEl, toEl) {
    var newValue = toEl.value;
    if (fromEl.value !== newValue) {
      fromEl.value = newValue;
    }
    var firstChild = fromEl.firstChild;
    if (firstChild) {
      var oldValue = firstChild.nodeValue;
      if (oldValue == newValue || !newValue && oldValue == fromEl.placeholder) {
        return;
      }
      firstChild.nodeValue = newValue;
    }
  },
  SELECT: function(fromEl, toEl) {
    if (!toEl.hasAttribute("multiple")) {
      var selectedIndex = -1;
      var i = 0;
      var curChild = fromEl.firstChild;
      var optgroup;
      var nodeName;
      while (curChild) {
        nodeName = curChild.nodeName && curChild.nodeName.toUpperCase();
        if (nodeName === "OPTGROUP") {
          optgroup = curChild;
          curChild = optgroup.firstChild;
          if (!curChild) {
            curChild = optgroup.nextSibling;
            optgroup = null;
          }
        } else {
          if (nodeName === "OPTION") {
            if (curChild.hasAttribute("selected")) {
              selectedIndex = i;
              break;
            }
            i++;
          }
          curChild = curChild.nextSibling;
          if (!curChild && optgroup) {
            curChild = optgroup.nextSibling;
            optgroup = null;
          }
        }
      }
      fromEl.selectedIndex = selectedIndex;
    }
  }
};
var ELEMENT_NODE = 1;
var DOCUMENT_FRAGMENT_NODE$1 = 11;
var TEXT_NODE = 3;
var COMMENT_NODE = 8;
function noop() {
}
function defaultGetNodeKey(node) {
  if (node) {
    return node.getAttribute && node.getAttribute("id") || node.id;
  }
}
function morphdomFactory(morphAttrs2) {
  return function morphdom2(fromNode, toNode, options) {
    if (!options) {
      options = {};
    }
    if (typeof toNode === "string") {
      if (fromNode.nodeName === "#document" || fromNode.nodeName === "HTML" || fromNode.nodeName === "BODY") {
        var toNodeHtml = toNode;
        toNode = doc.createElement("html");
        toNode.innerHTML = toNodeHtml;
      } else {
        toNode = toElement(toNode);
      }
    } else if (toNode.nodeType === DOCUMENT_FRAGMENT_NODE$1) {
      toNode = toNode.firstElementChild;
    }
    var getNodeKey = options.getNodeKey || defaultGetNodeKey;
    var onBeforeNodeAdded = options.onBeforeNodeAdded || noop;
    var onNodeAdded = options.onNodeAdded || noop;
    var onBeforeElUpdated = options.onBeforeElUpdated || noop;
    var onElUpdated = options.onElUpdated || noop;
    var onBeforeNodeDiscarded = options.onBeforeNodeDiscarded || noop;
    var onNodeDiscarded = options.onNodeDiscarded || noop;
    var onBeforeElChildrenUpdated = options.onBeforeElChildrenUpdated || noop;
    var skipFromChildren = options.skipFromChildren || noop;
    var addChild = options.addChild || function(parent, child) {
      return parent.appendChild(child);
    };
    var childrenOnly = options.childrenOnly === true;
    var fromNodesLookup = /* @__PURE__ */ Object.create(null);
    var keyedRemovalList = [];
    function addKeyedRemoval(key) {
      keyedRemovalList.push(key);
    }
    function walkDiscardedChildNodes(node, skipKeyedNodes) {
      if (node.nodeType === ELEMENT_NODE) {
        var curChild = node.firstChild;
        while (curChild) {
          var key = void 0;
          if (skipKeyedNodes && (key = getNodeKey(curChild))) {
            addKeyedRemoval(key);
          } else {
            onNodeDiscarded(curChild);
            if (curChild.firstChild) {
              walkDiscardedChildNodes(curChild, skipKeyedNodes);
            }
          }
          curChild = curChild.nextSibling;
        }
      }
    }
    function removeNode(node, parentNode, skipKeyedNodes) {
      if (onBeforeNodeDiscarded(node) === false) {
        return;
      }
      if (parentNode) {
        parentNode.removeChild(node);
      }
      onNodeDiscarded(node);
      walkDiscardedChildNodes(node, skipKeyedNodes);
    }
    function indexTree(node) {
      if (node.nodeType === ELEMENT_NODE || node.nodeType === DOCUMENT_FRAGMENT_NODE$1) {
        var curChild = node.firstChild;
        while (curChild) {
          var key = getNodeKey(curChild);
          if (key) {
            fromNodesLookup[key] = curChild;
          }
          indexTree(curChild);
          curChild = curChild.nextSibling;
        }
      }
    }
    indexTree(fromNode);
    function handleNodeAdded(el) {
      onNodeAdded(el);
      var curChild = el.firstChild;
      while (curChild) {
        var nextSibling = curChild.nextSibling;
        var key = getNodeKey(curChild);
        if (key) {
          var unmatchedFromEl = fromNodesLookup[key];
          if (unmatchedFromEl && compareNodeNames(curChild, unmatchedFromEl)) {
            curChild.parentNode.replaceChild(unmatchedFromEl, curChild);
            morphEl(unmatchedFromEl, curChild);
          } else {
            handleNodeAdded(curChild);
          }
        } else {
          handleNodeAdded(curChild);
        }
        curChild = nextSibling;
      }
    }
    function cleanupFromEl(fromEl, curFromNodeChild, curFromNodeKey) {
      while (curFromNodeChild) {
        var fromNextSibling = curFromNodeChild.nextSibling;
        if (curFromNodeKey = getNodeKey(curFromNodeChild)) {
          addKeyedRemoval(curFromNodeKey);
        } else {
          removeNode(
            curFromNodeChild,
            fromEl,
            true
            /* skip keyed nodes */
          );
        }
        curFromNodeChild = fromNextSibling;
      }
    }
    function morphEl(fromEl, toEl, childrenOnly2) {
      var toElKey = getNodeKey(toEl);
      if (toElKey) {
        delete fromNodesLookup[toElKey];
      }
      if (!childrenOnly2) {
        var beforeUpdateResult = onBeforeElUpdated(fromEl, toEl);
        if (beforeUpdateResult === false) {
          return;
        } else if (beforeUpdateResult instanceof HTMLElement) {
          fromEl = beforeUpdateResult;
          indexTree(fromEl);
        }
        morphAttrs2(fromEl, toEl);
        onElUpdated(fromEl);
        if (onBeforeElChildrenUpdated(fromEl, toEl) === false) {
          return;
        }
      }
      if (fromEl.nodeName !== "TEXTAREA") {
        morphChildren(fromEl, toEl);
      } else {
        specialElHandlers.TEXTAREA(fromEl, toEl);
      }
    }
    function morphChildren(fromEl, toEl) {
      var skipFrom = skipFromChildren(fromEl, toEl);
      var curToNodeChild = toEl.firstChild;
      var curFromNodeChild = fromEl.firstChild;
      var curToNodeKey;
      var curFromNodeKey;
      var fromNextSibling;
      var toNextSibling;
      var matchingFromEl;
      outer:
        while (curToNodeChild) {
          toNextSibling = curToNodeChild.nextSibling;
          curToNodeKey = getNodeKey(curToNodeChild);
          while (!skipFrom && curFromNodeChild) {
            fromNextSibling = curFromNodeChild.nextSibling;
            if (curToNodeChild.isSameNode && curToNodeChild.isSameNode(curFromNodeChild)) {
              curToNodeChild = toNextSibling;
              curFromNodeChild = fromNextSibling;
              continue outer;
            }
            curFromNodeKey = getNodeKey(curFromNodeChild);
            var curFromNodeType = curFromNodeChild.nodeType;
            var isCompatible = void 0;
            if (curFromNodeType === curToNodeChild.nodeType) {
              if (curFromNodeType === ELEMENT_NODE) {
                if (curToNodeKey) {
                  if (curToNodeKey !== curFromNodeKey) {
                    if (matchingFromEl = fromNodesLookup[curToNodeKey]) {
                      if (fromNextSibling === matchingFromEl) {
                        isCompatible = false;
                      } else {
                        fromEl.insertBefore(matchingFromEl, curFromNodeChild);
                        if (curFromNodeKey) {
                          addKeyedRemoval(curFromNodeKey);
                        } else {
                          removeNode(
                            curFromNodeChild,
                            fromEl,
                            true
                            /* skip keyed nodes */
                          );
                        }
                        curFromNodeChild = matchingFromEl;
                        curFromNodeKey = getNodeKey(curFromNodeChild);
                      }
                    } else {
                      isCompatible = false;
                    }
                  }
                } else if (curFromNodeKey) {
                  isCompatible = false;
                }
                isCompatible = isCompatible !== false && compareNodeNames(curFromNodeChild, curToNodeChild);
                if (isCompatible) {
                  morphEl(curFromNodeChild, curToNodeChild);
                }
              } else if (curFromNodeType === TEXT_NODE || curFromNodeType == COMMENT_NODE) {
                isCompatible = true;
                if (curFromNodeChild.nodeValue !== curToNodeChild.nodeValue) {
                  curFromNodeChild.nodeValue = curToNodeChild.nodeValue;
                }
              }
            }
            if (isCompatible) {
              curToNodeChild = toNextSibling;
              curFromNodeChild = fromNextSibling;
              continue outer;
            }
            if (curFromNodeKey) {
              addKeyedRemoval(curFromNodeKey);
            } else {
              removeNode(
                curFromNodeChild,
                fromEl,
                true
                /* skip keyed nodes */
              );
            }
            curFromNodeChild = fromNextSibling;
          }
          if (curToNodeKey && (matchingFromEl = fromNodesLookup[curToNodeKey]) && compareNodeNames(matchingFromEl, curToNodeChild)) {
            if (!skipFrom) {
              addChild(fromEl, matchingFromEl);
            }
            morphEl(matchingFromEl, curToNodeChild);
          } else {
            var onBeforeNodeAddedResult = onBeforeNodeAdded(curToNodeChild);
            if (onBeforeNodeAddedResult !== false) {
              if (onBeforeNodeAddedResult) {
                curToNodeChild = onBeforeNodeAddedResult;
              }
              if (curToNodeChild.actualize) {
                curToNodeChild = curToNodeChild.actualize(fromEl.ownerDocument || doc);
              }
              addChild(fromEl, curToNodeChild);
              handleNodeAdded(curToNodeChild);
            }
          }
          curToNodeChild = toNextSibling;
          curFromNodeChild = fromNextSibling;
        }
      cleanupFromEl(fromEl, curFromNodeChild, curFromNodeKey);
      var specialElHandler = specialElHandlers[fromEl.nodeName];
      if (specialElHandler) {
        specialElHandler(fromEl, toEl);
      }
    }
    var morphedNode = fromNode;
    var morphedNodeType = morphedNode.nodeType;
    var toNodeType = toNode.nodeType;
    if (!childrenOnly) {
      if (morphedNodeType === ELEMENT_NODE) {
        if (toNodeType === ELEMENT_NODE) {
          if (!compareNodeNames(fromNode, toNode)) {
            onNodeDiscarded(fromNode);
            morphedNode = moveChildren(fromNode, createElementNS(toNode.nodeName, toNode.namespaceURI));
          }
        } else {
          morphedNode = toNode;
        }
      } else if (morphedNodeType === TEXT_NODE || morphedNodeType === COMMENT_NODE) {
        if (toNodeType === morphedNodeType) {
          if (morphedNode.nodeValue !== toNode.nodeValue) {
            morphedNode.nodeValue = toNode.nodeValue;
          }
          return morphedNode;
        } else {
          morphedNode = toNode;
        }
      }
    }
    if (morphedNode === toNode) {
      onNodeDiscarded(fromNode);
    } else {
      if (toNode.isSameNode && toNode.isSameNode(morphedNode)) {
        return;
      }
      morphEl(morphedNode, toNode, childrenOnly);
      if (keyedRemovalList) {
        for (var i = 0, len = keyedRemovalList.length; i < len; i++) {
          var elToRemove = fromNodesLookup[keyedRemovalList[i]];
          if (elToRemove) {
            removeNode(elToRemove, elToRemove.parentNode, false);
          }
        }
      }
    }
    if (!childrenOnly && morphedNode !== fromNode && fromNode.parentNode) {
      if (morphedNode.actualize) {
        morphedNode = morphedNode.actualize(fromNode.ownerDocument || doc);
      }
      fromNode.parentNode.replaceChild(morphedNode, fromNode);
    }
    return morphedNode;
  };
}
var morphdom = morphdomFactory(morphAttrs);
var focusStack = [];
var default_transition_time = 200;
var JS = {
  // private
  exec(e, eventType, phxEvent, view, sourceEl, defaults) {
    const [defaultKind, defaultArgs] = defaults || [
      null,
      { callback: defaults && defaults.callback }
    ];
    const commands = phxEvent.charAt(0) === "[" ? JSON.parse(phxEvent) : [[defaultKind, defaultArgs]];
    commands.forEach(([kind, args]) => {
      if (kind === defaultKind) {
        args = { ...defaultArgs, ...args };
        args.callback = args.callback || defaultArgs.callback;
      }
      this.filterToEls(view.liveSocket, sourceEl, args).forEach((el) => {
        this[`exec_${kind}`](e, eventType, phxEvent, view, sourceEl, el, args);
      });
    });
  },
  isVisible(el) {
    return !!(el.offsetWidth || el.offsetHeight || el.getClientRects().length > 0);
  },
  // returns true if any part of the element is inside the viewport
  isInViewport(el) {
    const rect = el.getBoundingClientRect();
    const windowHeight = window.innerHeight || document.documentElement.clientHeight;
    const windowWidth = window.innerWidth || document.documentElement.clientWidth;
    return rect.right > 0 && rect.bottom > 0 && rect.left < windowWidth && rect.top < windowHeight;
  },
  // private
  // commands
  exec_exec(e, eventType, phxEvent, view, sourceEl, el, { attr, to }) {
    const encodedJS = el.getAttribute(attr);
    if (!encodedJS) {
      throw new Error(`expected ${attr} to contain JS command on "${to}"`);
    }
    view.liveSocket.execJS(el, encodedJS, eventType);
  },
  exec_dispatch(e, eventType, phxEvent, view, sourceEl, el, { event, detail, bubbles, blocking }) {
    detail = detail || {};
    detail.dispatcher = sourceEl;
    if (blocking) {
      const promise = new Promise((resolve, _reject) => {
        detail.done = resolve;
      });
      view.liveSocket.asyncTransition(promise);
    }
    dom_default.dispatchEvent(el, event, { detail, bubbles });
  },
  exec_push(e, eventType, phxEvent, view, sourceEl, el, args) {
    const {
      event,
      data,
      target,
      page_loading,
      loading,
      value,
      dispatcher,
      callback
    } = args;
    const pushOpts = {
      loading,
      value,
      target,
      page_loading: !!page_loading,
      originalEvent: e
    };
    const targetSrc = eventType === "change" && dispatcher ? dispatcher : sourceEl;
    const phxTarget = target || targetSrc.getAttribute(view.binding("target")) || targetSrc;
    const handler = (targetView, targetCtx) => {
      if (!targetView.isConnected()) {
        return;
      }
      if (eventType === "change") {
        let { newCid, _target } = args;
        _target = _target || (dom_default.isFormInput(sourceEl) ? sourceEl.name : void 0);
        if (_target) {
          pushOpts._target = _target;
        }
        targetView.pushInput(
          sourceEl,
          targetCtx,
          newCid,
          event || phxEvent,
          pushOpts,
          callback
        );
      } else if (eventType === "submit") {
        const { submitter } = args;
        targetView.submitForm(
          sourceEl,
          targetCtx,
          event || phxEvent,
          submitter,
          pushOpts,
          callback
        );
      } else {
        targetView.pushEvent(
          eventType,
          sourceEl,
          targetCtx,
          event || phxEvent,
          data,
          pushOpts,
          callback
        );
      }
    };
    if (args.targetView && args.targetCtx) {
      handler(args.targetView, args.targetCtx);
    } else {
      view.withinTargets(phxTarget, handler);
    }
  },
  exec_navigate(e, eventType, phxEvent, view, sourceEl, el, { href, replace }) {
    view.liveSocket.historyRedirect(
      e,
      href,
      replace ? "replace" : "push",
      null,
      sourceEl
    );
  },
  exec_patch(e, eventType, phxEvent, view, sourceEl, el, { href, replace }) {
    view.liveSocket.pushHistoryPatch(
      e,
      href,
      replace ? "replace" : "push",
      sourceEl
    );
  },
  exec_focus(e, eventType, phxEvent, view, sourceEl, el) {
    aria_default.attemptFocus(el);
    window.requestAnimationFrame(() => {
      window.requestAnimationFrame(() => aria_default.attemptFocus(el));
    });
  },
  exec_focus_first(e, eventType, phxEvent, view, sourceEl, el) {
    aria_default.focusFirstInteractive(el) || aria_default.focusFirst(el);
    window.requestAnimationFrame(() => {
      window.requestAnimationFrame(
        () => aria_default.focusFirstInteractive(el) || aria_default.focusFirst(el)
      );
    });
  },
  exec_push_focus(e, eventType, phxEvent, view, sourceEl, el) {
    focusStack.push(el || sourceEl);
  },
  exec_pop_focus(_e, _eventType, _phxEvent, _view, _sourceEl, _el) {
    const el = focusStack.pop();
    if (el) {
      el.focus();
      window.requestAnimationFrame(() => {
        window.requestAnimationFrame(() => el.focus());
      });
    }
  },
  exec_add_class(e, eventType, phxEvent, view, sourceEl, el, { names, transition, time, blocking }) {
    this.addOrRemoveClasses(el, names, [], transition, time, view, blocking);
  },
  exec_remove_class(e, eventType, phxEvent, view, sourceEl, el, { names, transition, time, blocking }) {
    this.addOrRemoveClasses(el, [], names, transition, time, view, blocking);
  },
  exec_toggle_class(e, eventType, phxEvent, view, sourceEl, el, { names, transition, time, blocking }) {
    this.toggleClasses(el, names, transition, time, view, blocking);
  },
  exec_toggle_attr(e, eventType, phxEvent, view, sourceEl, el, { attr: [attr, val1, val2] }) {
    this.toggleAttr(el, attr, val1, val2);
  },
  exec_ignore_attrs(e, eventType, phxEvent, view, sourceEl, el, { attrs }) {
    this.ignoreAttrs(el, attrs);
  },
  exec_transition(e, eventType, phxEvent, view, sourceEl, el, { time, transition, blocking }) {
    this.addOrRemoveClasses(el, [], [], transition, time, view, blocking);
  },
  exec_toggle(e, eventType, phxEvent, view, sourceEl, el, { display, ins, outs, time, blocking }) {
    this.toggle(eventType, view, el, display, ins, outs, time, blocking);
  },
  exec_show(e, eventType, phxEvent, view, sourceEl, el, { display, transition, time, blocking }) {
    this.show(eventType, view, el, display, transition, time, blocking);
  },
  exec_hide(e, eventType, phxEvent, view, sourceEl, el, { display, transition, time, blocking }) {
    this.hide(eventType, view, el, display, transition, time, blocking);
  },
  exec_set_attr(e, eventType, phxEvent, view, sourceEl, el, { attr: [attr, val] }) {
    this.setOrRemoveAttrs(el, [[attr, val]], []);
  },
  exec_remove_attr(e, eventType, phxEvent, view, sourceEl, el, { attr }) {
    this.setOrRemoveAttrs(el, [], [attr]);
  },
  ignoreAttrs(el, attrs) {
    dom_default.putPrivate(el, "JS:ignore_attrs", {
      apply: (fromEl, toEl) => {
        Array.from(fromEl.attributes).forEach((attr) => {
          if (attrs.some(
            (toIgnore) => attr.name == toIgnore || toIgnore.includes("*") && attr.name.match(toIgnore) != null
          )) {
            toEl.setAttribute(attr.name, attr.value);
          }
        });
      }
    });
  },
  onBeforeElUpdated(fromEl, toEl) {
    const ignoreAttrs = dom_default.private(fromEl, "JS:ignore_attrs");
    if (ignoreAttrs) {
      ignoreAttrs.apply(fromEl, toEl);
    }
  },
  // utils for commands
  show(eventType, view, el, display, transition, time, blocking) {
    if (!this.isVisible(el)) {
      this.toggle(
        eventType,
        view,
        el,
        display,
        transition,
        null,
        time,
        blocking
      );
    }
  },
  hide(eventType, view, el, display, transition, time, blocking) {
    if (this.isVisible(el)) {
      this.toggle(
        eventType,
        view,
        el,
        display,
        null,
        transition,
        time,
        blocking
      );
    }
  },
  toggle(eventType, view, el, display, ins, outs, time, blocking) {
    time = time || default_transition_time;
    const [inClasses, inStartClasses, inEndClasses] = ins || [[], [], []];
    const [outClasses, outStartClasses, outEndClasses] = outs || [[], [], []];
    if (inClasses.length > 0 || outClasses.length > 0) {
      if (this.isVisible(el)) {
        const onStart = () => {
          this.addOrRemoveClasses(
            el,
            outStartClasses,
            inClasses.concat(inStartClasses).concat(inEndClasses)
          );
          window.requestAnimationFrame(() => {
            this.addOrRemoveClasses(el, outClasses, []);
            window.requestAnimationFrame(
              () => this.addOrRemoveClasses(el, outEndClasses, outStartClasses)
            );
          });
        };
        const onEnd = () => {
          this.addOrRemoveClasses(el, [], outClasses.concat(outEndClasses));
          dom_default.putSticky(
            el,
            "toggle",
            (currentEl) => currentEl.style.display = "none"
          );
          el.dispatchEvent(new Event("phx:hide-end"));
        };
        el.dispatchEvent(new Event("phx:hide-start"));
        if (blocking === false) {
          onStart();
          setTimeout(onEnd, time);
        } else {
          view.transition(time, onStart, onEnd);
        }
      } else {
        if (eventType === "remove") {
          return;
        }
        const onStart = () => {
          this.addOrRemoveClasses(
            el,
            inStartClasses,
            outClasses.concat(outStartClasses).concat(outEndClasses)
          );
          const stickyDisplay = display || this.defaultDisplay(el);
          window.requestAnimationFrame(() => {
            this.addOrRemoveClasses(el, inClasses, []);
            window.requestAnimationFrame(() => {
              dom_default.putSticky(
                el,
                "toggle",
                (currentEl) => currentEl.style.display = stickyDisplay
              );
              this.addOrRemoveClasses(el, inEndClasses, inStartClasses);
            });
          });
        };
        const onEnd = () => {
          this.addOrRemoveClasses(el, [], inClasses.concat(inEndClasses));
          el.dispatchEvent(new Event("phx:show-end"));
        };
        el.dispatchEvent(new Event("phx:show-start"));
        if (blocking === false) {
          onStart();
          setTimeout(onEnd, time);
        } else {
          view.transition(time, onStart, onEnd);
        }
      }
    } else {
      if (this.isVisible(el)) {
        window.requestAnimationFrame(() => {
          el.dispatchEvent(new Event("phx:hide-start"));
          dom_default.putSticky(
            el,
            "toggle",
            (currentEl) => currentEl.style.display = "none"
          );
          el.dispatchEvent(new Event("phx:hide-end"));
        });
      } else {
        window.requestAnimationFrame(() => {
          el.dispatchEvent(new Event("phx:show-start"));
          const stickyDisplay = display || this.defaultDisplay(el);
          dom_default.putSticky(
            el,
            "toggle",
            (currentEl) => currentEl.style.display = stickyDisplay
          );
          el.dispatchEvent(new Event("phx:show-end"));
        });
      }
    }
  },
  toggleClasses(el, classes, transition, time, view, blocking) {
    window.requestAnimationFrame(() => {
      const [prevAdds, prevRemoves] = dom_default.getSticky(el, "classes", [[], []]);
      const newAdds = classes.filter(
        (name) => prevAdds.indexOf(name) < 0 && !el.classList.contains(name)
      );
      const newRemoves = classes.filter(
        (name) => prevRemoves.indexOf(name) < 0 && el.classList.contains(name)
      );
      this.addOrRemoveClasses(
        el,
        newAdds,
        newRemoves,
        transition,
        time,
        view,
        blocking
      );
    });
  },
  toggleAttr(el, attr, val1, val2) {
    if (el.hasAttribute(attr)) {
      if (val2 !== void 0) {
        if (el.getAttribute(attr) === val1) {
          this.setOrRemoveAttrs(el, [[attr, val2]], []);
        } else {
          this.setOrRemoveAttrs(el, [[attr, val1]], []);
        }
      } else {
        this.setOrRemoveAttrs(el, [], [attr]);
      }
    } else {
      this.setOrRemoveAttrs(el, [[attr, val1]], []);
    }
  },
  addOrRemoveClasses(el, adds, removes, transition, time, view, blocking) {
    time = time || default_transition_time;
    const [transitionRun, transitionStart, transitionEnd] = transition || [
      [],
      [],
      []
    ];
    if (transitionRun.length > 0) {
      const onStart = () => {
        this.addOrRemoveClasses(
          el,
          transitionStart,
          [].concat(transitionRun).concat(transitionEnd)
        );
        window.requestAnimationFrame(() => {
          this.addOrRemoveClasses(el, transitionRun, []);
          window.requestAnimationFrame(
            () => this.addOrRemoveClasses(el, transitionEnd, transitionStart)
          );
        });
      };
      const onDone = () => this.addOrRemoveClasses(
        el,
        adds.concat(transitionEnd),
        removes.concat(transitionRun).concat(transitionStart)
      );
      if (blocking === false) {
        onStart();
        setTimeout(onDone, time);
      } else {
        view.transition(time, onStart, onDone);
      }
      return;
    }
    window.requestAnimationFrame(() => {
      const [prevAdds, prevRemoves] = dom_default.getSticky(el, "classes", [[], []]);
      const keepAdds = adds.filter(
        (name) => prevAdds.indexOf(name) < 0 && !el.classList.contains(name)
      );
      const keepRemoves = removes.filter(
        (name) => prevRemoves.indexOf(name) < 0 && el.classList.contains(name)
      );
      const newAdds = prevAdds.filter((name) => removes.indexOf(name) < 0).concat(keepAdds);
      const newRemoves = prevRemoves.filter((name) => adds.indexOf(name) < 0).concat(keepRemoves);
      dom_default.putSticky(el, "classes", (currentEl) => {
        currentEl.classList.remove(...newRemoves);
        currentEl.classList.add(...newAdds);
        return [newAdds, newRemoves];
      });
    });
  },
  setOrRemoveAttrs(el, sets, removes) {
    const [prevSets, prevRemoves] = dom_default.getSticky(el, "attrs", [[], []]);
    const alteredAttrs = sets.map(([attr, _val]) => attr).concat(removes);
    const newSets = prevSets.filter(([attr, _val]) => !alteredAttrs.includes(attr)).concat(sets);
    const newRemoves = prevRemoves.filter((attr) => !alteredAttrs.includes(attr)).concat(removes);
    dom_default.putSticky(el, "attrs", (currentEl) => {
      newRemoves.forEach((attr) => currentEl.removeAttribute(attr));
      newSets.forEach(([attr, val]) => currentEl.setAttribute(attr, val));
      return [newSets, newRemoves];
    });
  },
  hasAllClasses(el, classes) {
    return classes.every((name) => el.classList.contains(name));
  },
  isToggledOut(el, outClasses) {
    return !this.isVisible(el) || this.hasAllClasses(el, outClasses);
  },
  filterToEls(liveSocket, sourceEl, { to }) {
    const defaultQuery = () => {
      if (typeof to === "string") {
        return document.querySelectorAll(to);
      } else if (to.closest) {
        const toEl = sourceEl.closest(to.closest);
        return toEl ? [toEl] : [];
      } else if (to.inner) {
        return sourceEl.querySelectorAll(to.inner);
      }
    };
    return to ? liveSocket.jsQuerySelectorAll(sourceEl, to, defaultQuery) : [sourceEl];
  },
  defaultDisplay(el) {
    return { tr: "table-row", td: "table-cell" }[el.tagName.toLowerCase()] || "block";
  },
  transitionClasses(val) {
    if (!val) {
      return null;
    }
    let [trans, tStart, tEnd] = Array.isArray(val) ? val : [val.split(" "), [], []];
    trans = Array.isArray(trans) ? trans : trans.split(" ");
    tStart = Array.isArray(tStart) ? tStart : tStart.split(" ");
    tEnd = Array.isArray(tEnd) ? tEnd : tEnd.split(" ");
    return [trans, tStart, tEnd];
  }
};
var js_default = JS;
var js_commands_default = (liveSocket, eventType) => {
  return {
    exec(el, encodedJS) {
      liveSocket.execJS(el, encodedJS, eventType);
    },
    show(el, opts = {}) {
      const owner = liveSocket.owner(el);
      js_default.show(
        eventType,
        owner,
        el,
        opts.display,
        js_default.transitionClasses(opts.transition),
        opts.time,
        opts.blocking
      );
    },
    hide(el, opts = {}) {
      const owner = liveSocket.owner(el);
      js_default.hide(
        eventType,
        owner,
        el,
        null,
        js_default.transitionClasses(opts.transition),
        opts.time,
        opts.blocking
      );
    },
    toggle(el, opts = {}) {
      const owner = liveSocket.owner(el);
      const inTransition = js_default.transitionClasses(opts.in);
      const outTransition = js_default.transitionClasses(opts.out);
      js_default.toggle(
        eventType,
        owner,
        el,
        opts.display,
        inTransition,
        outTransition,
        opts.time,
        opts.blocking
      );
    },
    addClass(el, names, opts = {}) {
      const classNames = Array.isArray(names) ? names : names.split(" ");
      const owner = liveSocket.owner(el);
      js_default.addOrRemoveClasses(
        el,
        classNames,
        [],
        js_default.transitionClasses(opts.transition),
        opts.time,
        owner,
        opts.blocking
      );
    },
    removeClass(el, names, opts = {}) {
      const classNames = Array.isArray(names) ? names : names.split(" ");
      const owner = liveSocket.owner(el);
      js_default.addOrRemoveClasses(
        el,
        [],
        classNames,
        js_default.transitionClasses(opts.transition),
        opts.time,
        owner,
        opts.blocking
      );
    },
    toggleClass(el, names, opts = {}) {
      const classNames = Array.isArray(names) ? names : names.split(" ");
      const owner = liveSocket.owner(el);
      js_default.toggleClasses(
        el,
        classNames,
        js_default.transitionClasses(opts.transition),
        opts.time,
        owner,
        opts.blocking
      );
    },
    transition(el, transition, opts = {}) {
      const owner = liveSocket.owner(el);
      js_default.addOrRemoveClasses(
        el,
        [],
        [],
        js_default.transitionClasses(transition),
        opts.time,
        owner,
        opts.blocking
      );
    },
    setAttribute(el, attr, val) {
      js_default.setOrRemoveAttrs(el, [[attr, val]], []);
    },
    removeAttribute(el, attr) {
      js_default.setOrRemoveAttrs(el, [], [attr]);
    },
    toggleAttribute(el, attr, val1, val2) {
      js_default.toggleAttr(el, attr, val1, val2);
    },
    push(el, type, opts = {}) {
      liveSocket.withinOwners(el, (view) => {
        const data = opts.value || {};
        delete opts.value;
        let e = new CustomEvent("phx:exec", { detail: { sourceElement: el } });
        js_default.exec(e, eventType, type, view, el, ["push", { data, ...opts }]);
      });
    },
    navigate(href, opts = {}) {
      const customEvent = new CustomEvent("phx:exec");
      liveSocket.historyRedirect(
        customEvent,
        href,
        opts.replace ? "replace" : "push",
        null,
        null
      );
    },
    patch(href, opts = {}) {
      const customEvent = new CustomEvent("phx:exec");
      liveSocket.pushHistoryPatch(
        customEvent,
        href,
        opts.replace ? "replace" : "push",
        null
      );
    },
    ignoreAttributes(el, attrs) {
      js_default.ignoreAttrs(el, Array.isArray(attrs) ? attrs : [attrs]);
    }
  };
};
var HOOK_ID = "hookId";
var viewHookID = 1;
var ViewHook = class _ViewHook {
  static makeID() {
    return viewHookID++;
  }
  static elementID(el) {
    return dom_default.private(el, HOOK_ID);
  }
  constructor(view, el, callbacks) {
    this.el = el;
    this.__attachView(view);
    this.__listeners = /* @__PURE__ */ new Set();
    this.__isDisconnected = false;
    dom_default.putPrivate(this.el, HOOK_ID, _ViewHook.makeID());
    if (callbacks) {
      const protectedProps = /* @__PURE__ */ new Set([
        "el",
        "liveSocket",
        "__view",
        "__listeners",
        "__isDisconnected",
        "constructor",
        // Standard object properties
        // Core ViewHook API methods
        "js",
        "pushEvent",
        "pushEventTo",
        "handleEvent",
        "removeHandleEvent",
        "upload",
        "uploadTo",
        // Internal lifecycle callers
        "__mounted",
        "__updated",
        "__beforeUpdate",
        "__destroyed",
        "__reconnected",
        "__disconnected",
        "__cleanup__"
      ]);
      for (const key in callbacks) {
        if (Object.prototype.hasOwnProperty.call(callbacks, key)) {
          this[key] = callbacks[key];
          if (protectedProps.has(key)) {
            console.warn(
              `Hook object for element #${el.id} overwrites core property '${key}'!`
            );
          }
        }
      }
      const lifecycleMethods = [
        "mounted",
        "beforeUpdate",
        "updated",
        "destroyed",
        "disconnected",
        "reconnected"
      ];
      lifecycleMethods.forEach((methodName) => {
        if (callbacks[methodName] && typeof callbacks[methodName] === "function") {
          this[methodName] = callbacks[methodName];
        }
      });
    }
  }
  /** @internal */
  __attachView(view) {
    if (view) {
      this.__view = () => view;
      this.liveSocket = view.liveSocket;
    } else {
      this.__view = () => {
        throw new Error(
          `hook not yet attached to a live view: ${this.el.outerHTML}`
        );
      };
      this.liveSocket = null;
    }
  }
  // Default lifecycle methods
  mounted() {
  }
  beforeUpdate() {
  }
  updated() {
  }
  destroyed() {
  }
  disconnected() {
  }
  reconnected() {
  }
  // Internal lifecycle callers - called by the View
  /** @internal */
  __mounted() {
    this.mounted();
  }
  /** @internal */
  __updated() {
    this.updated();
  }
  /** @internal */
  __beforeUpdate() {
    this.beforeUpdate();
  }
  /** @internal */
  __destroyed() {
    this.destroyed();
    dom_default.deletePrivate(this.el, HOOK_ID);
  }
  /** @internal */
  __reconnected() {
    if (this.__isDisconnected) {
      this.__isDisconnected = false;
      this.reconnected();
    }
  }
  /** @internal */
  __disconnected() {
    this.__isDisconnected = true;
    this.disconnected();
  }
  js() {
    return {
      ...js_commands_default(this.__view().liveSocket, "hook"),
      exec: (encodedJS) => {
        this.__view().liveSocket.execJS(this.el, encodedJS, "hook");
      }
    };
  }
  pushEvent(event, payload, onReply) {
    const promise = this.__view().pushHookEvent(
      this.el,
      null,
      event,
      payload || {}
    );
    if (onReply === void 0) {
      return promise.then(({ reply }) => reply);
    }
    promise.then(({ reply, ref }) => onReply(reply, ref)).catch(() => {
    });
    return;
  }
  pushEventTo(selectorOrTarget, event, payload, onReply) {
    if (onReply === void 0) {
      const targetPair = [];
      this.__view().withinTargets(selectorOrTarget, (view, targetCtx) => {
        targetPair.push({ view, targetCtx });
      });
      const promises = targetPair.map(({ view, targetCtx }) => {
        return view.pushHookEvent(this.el, targetCtx, event, payload || {});
      });
      return Promise.allSettled(promises);
    }
    this.__view().withinTargets(selectorOrTarget, (view, targetCtx) => {
      view.pushHookEvent(this.el, targetCtx, event, payload || {}).then(({ reply, ref }) => onReply(reply, ref)).catch(() => {
      });
    });
    return;
  }
  handleEvent(event, callback) {
    const callbackRef = {
      event,
      callback: (customEvent) => callback(customEvent.detail)
    };
    window.addEventListener(
      `phx:${event}`,
      callbackRef.callback
    );
    this.__listeners.add(callbackRef);
    return callbackRef;
  }
  removeHandleEvent(ref) {
    window.removeEventListener(
      `phx:${ref.event}`,
      ref.callback
    );
    this.__listeners.delete(ref);
  }
  upload(name, files) {
    return this.__view().dispatchUploads(null, name, files);
  }
  uploadTo(selectorOrTarget, name, files) {
    return this.__view().withinTargets(selectorOrTarget, (view, targetCtx) => {
      view.dispatchUploads(targetCtx, name, files);
    });
  }
  /** @internal */
  __cleanup__() {
    this.__listeners.forEach(
      (callbackRef) => this.removeHandleEvent(callbackRef)
    );
  }
};

// vendor/floating-ui.js
var min = Math.min;
var max = Math.max;
var round = Math.round;
var floor = Math.floor;
var createCoords = (v) => ({
  x: v,
  y: v
});
var oppositeSideMap = {
  left: "right",
  right: "left",
  bottom: "top",
  top: "bottom"
};
var oppositeAlignmentMap = {
  start: "end",
  end: "start"
};
function clamp(start, value, end) {
  return max(start, min(value, end));
}
function evaluate(value, param) {
  return typeof value === "function" ? value(param) : value;
}
function getSide(placement) {
  return placement.split("-")[0];
}
function getAlignment(placement) {
  return placement.split("-")[1];
}
function getOppositeAxis(axis) {
  return axis === "x" ? "y" : "x";
}
function getAxisLength(axis) {
  return axis === "y" ? "height" : "width";
}
function getSideAxis(placement) {
  return ["top", "bottom"].includes(getSide(placement)) ? "y" : "x";
}
function getAlignmentAxis(placement) {
  return getOppositeAxis(getSideAxis(placement));
}
function getAlignmentSides(placement, rects, rtl) {
  if (rtl === void 0) {
    rtl = false;
  }
  const alignment = getAlignment(placement);
  const alignmentAxis = getAlignmentAxis(placement);
  const length = getAxisLength(alignmentAxis);
  let mainAlignmentSide = alignmentAxis === "x" ? alignment === (rtl ? "end" : "start") ? "right" : "left" : alignment === "start" ? "bottom" : "top";
  if (rects.reference[length] > rects.floating[length]) {
    mainAlignmentSide = getOppositePlacement(mainAlignmentSide);
  }
  return [mainAlignmentSide, getOppositePlacement(mainAlignmentSide)];
}
function getExpandedPlacements(placement) {
  const oppositePlacement = getOppositePlacement(placement);
  return [
    getOppositeAlignmentPlacement(placement),
    oppositePlacement,
    getOppositeAlignmentPlacement(oppositePlacement)
  ];
}
function getOppositeAlignmentPlacement(placement) {
  return placement.replace(
    /start|end/g,
    (alignment) => oppositeAlignmentMap[alignment]
  );
}
function getSideList(side, isStart, rtl) {
  const lr = ["left", "right"];
  const rl = ["right", "left"];
  const tb = ["top", "bottom"];
  const bt = ["bottom", "top"];
  switch (side) {
    case "top":
    case "bottom":
      if (rtl) return isStart ? rl : lr;
      return isStart ? lr : rl;
    case "left":
    case "right":
      return isStart ? tb : bt;
    default:
      return [];
  }
}
function getOppositeAxisPlacements(placement, flipAlignment, direction, rtl) {
  const alignment = getAlignment(placement);
  let list = getSideList(getSide(placement), direction === "start", rtl);
  if (alignment) {
    list = list.map((side) => side + "-" + alignment);
    if (flipAlignment) {
      list = list.concat(list.map(getOppositeAlignmentPlacement));
    }
  }
  return list;
}
function getOppositePlacement(placement) {
  return placement.replace(
    /left|right|bottom|top/g,
    (side) => oppositeSideMap[side]
  );
}
function expandPaddingObject(padding) {
  return {
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
    ...padding
  };
}
function getPaddingObject(padding) {
  return typeof padding !== "number" ? expandPaddingObject(padding) : {
    top: padding,
    right: padding,
    bottom: padding,
    left: padding
  };
}
function rectToClientRect(rect) {
  const { x, y, width, height } = rect;
  return {
    width,
    height,
    top: y,
    left: x,
    right: x + width,
    bottom: y + height,
    x,
    y
  };
}
function computeCoordsFromPlacement(_ref, placement, rtl) {
  let { reference, floating } = _ref;
  const sideAxis = getSideAxis(placement);
  const alignmentAxis = getAlignmentAxis(placement);
  const alignLength = getAxisLength(alignmentAxis);
  const side = getSide(placement);
  const isVertical = sideAxis === "y";
  const commonX = reference.x + reference.width / 2 - floating.width / 2;
  const commonY = reference.y + reference.height / 2 - floating.height / 2;
  const commonAlign = reference[alignLength] / 2 - floating[alignLength] / 2;
  let coords;
  switch (side) {
    case "top":
      coords = {
        x: commonX,
        y: reference.y - floating.height
      };
      break;
    case "bottom":
      coords = {
        x: commonX,
        y: reference.y + reference.height
      };
      break;
    case "right":
      coords = {
        x: reference.x + reference.width,
        y: commonY
      };
      break;
    case "left":
      coords = {
        x: reference.x - floating.width,
        y: commonY
      };
      break;
    default:
      coords = {
        x: reference.x,
        y: reference.y
      };
  }
  switch (getAlignment(placement)) {
    case "start":
      coords[alignmentAxis] -= commonAlign * (rtl && isVertical ? -1 : 1);
      break;
    case "end":
      coords[alignmentAxis] += commonAlign * (rtl && isVertical ? -1 : 1);
      break;
  }
  return coords;
}
var computePosition = async (reference, floating, config) => {
  const {
    placement = "bottom",
    strategy = "absolute",
    middleware = [],
    platform: platform2
  } = config;
  const validMiddleware = middleware.filter(Boolean);
  const rtl = await (platform2.isRTL == null ? void 0 : platform2.isRTL(floating));
  let rects = await platform2.getElementRects({
    reference,
    floating,
    strategy
  });
  let { x, y } = computeCoordsFromPlacement(rects, placement, rtl);
  let statefulPlacement = placement;
  let middlewareData = {};
  let resetCount = 0;
  for (let i = 0; i < validMiddleware.length; i++) {
    const { name, fn } = validMiddleware[i];
    const {
      x: nextX,
      y: nextY,
      data,
      reset
    } = await fn({
      x,
      y,
      initialPlacement: placement,
      placement: statefulPlacement,
      strategy,
      middlewareData,
      rects,
      platform: platform2,
      elements: {
        reference,
        floating
      }
    });
    x = nextX != null ? nextX : x;
    y = nextY != null ? nextY : y;
    middlewareData = {
      ...middlewareData,
      [name]: {
        ...middlewareData[name],
        ...data
      }
    };
    if (reset && resetCount <= 50) {
      resetCount++;
      if (typeof reset === "object") {
        if (reset.placement) {
          statefulPlacement = reset.placement;
        }
        if (reset.rects) {
          rects = reset.rects === true ? await platform2.getElementRects({
            reference,
            floating,
            strategy
          }) : reset.rects;
        }
        ({ x, y } = computeCoordsFromPlacement(rects, statefulPlacement, rtl));
      }
      i = -1;
    }
  }
  return {
    x,
    y,
    placement: statefulPlacement,
    strategy,
    middlewareData
  };
};
async function detectOverflow(state, options) {
  var _await$platform$isEle;
  if (options === void 0) {
    options = {};
  }
  const { x, y, platform: platform2, rects, elements, strategy } = state;
  const {
    boundary = "clippingAncestors",
    rootBoundary = "viewport",
    elementContext = "floating",
    altBoundary = false,
    padding = 0
  } = evaluate(options, state);
  const paddingObject = getPaddingObject(padding);
  const altContext = elementContext === "floating" ? "reference" : "floating";
  const element = elements[altBoundary ? altContext : elementContext];
  const clippingClientRect = rectToClientRect(
    await platform2.getClippingRect({
      element: ((_await$platform$isEle = await (platform2.isElement == null ? void 0 : platform2.isElement(element))) != null ? _await$platform$isEle : true) ? element : element.contextElement || await (platform2.getDocumentElement == null ? void 0 : platform2.getDocumentElement(elements.floating)),
      boundary,
      rootBoundary,
      strategy
    })
  );
  const rect = elementContext === "floating" ? {
    x,
    y,
    width: rects.floating.width,
    height: rects.floating.height
  } : rects.reference;
  const offsetParent = await (platform2.getOffsetParent == null ? void 0 : platform2.getOffsetParent(elements.floating));
  const offsetScale = await (platform2.isElement == null ? void 0 : platform2.isElement(offsetParent)) ? await (platform2.getScale == null ? void 0 : platform2.getScale(offsetParent)) || {
    x: 1,
    y: 1
  } : {
    x: 1,
    y: 1
  };
  const elementClientRect = rectToClientRect(
    platform2.convertOffsetParentRelativeRectToViewportRelativeRect ? await platform2.convertOffsetParentRelativeRectToViewportRelativeRect({
      elements,
      rect,
      offsetParent,
      strategy
    }) : rect
  );
  return {
    top: (clippingClientRect.top - elementClientRect.top + paddingObject.top) / offsetScale.y,
    bottom: (elementClientRect.bottom - clippingClientRect.bottom + paddingObject.bottom) / offsetScale.y,
    left: (clippingClientRect.left - elementClientRect.left + paddingObject.left) / offsetScale.x,
    right: (elementClientRect.right - clippingClientRect.right + paddingObject.right) / offsetScale.x
  };
}
var flip = function(options) {
  if (options === void 0) {
    options = {};
  }
  return {
    name: "flip",
    options,
    async fn(state) {
      var _middlewareData$arrow, _middlewareData$flip;
      const {
        placement,
        middlewareData,
        rects,
        initialPlacement,
        platform: platform2,
        elements
      } = state;
      const {
        mainAxis: checkMainAxis = true,
        crossAxis: checkCrossAxis = true,
        fallbackPlacements: specifiedFallbackPlacements,
        fallbackStrategy = "bestFit",
        fallbackAxisSideDirection = "none",
        flipAlignment = true,
        ...detectOverflowOptions
      } = evaluate(options, state);
      if ((_middlewareData$arrow = middlewareData.arrow) != null && _middlewareData$arrow.alignmentOffset) {
        return {};
      }
      const side = getSide(placement);
      const initialSideAxis = getSideAxis(initialPlacement);
      const isBasePlacement = getSide(initialPlacement) === initialPlacement;
      const rtl = await (platform2.isRTL == null ? void 0 : platform2.isRTL(elements.floating));
      const fallbackPlacements = specifiedFallbackPlacements || (isBasePlacement || !flipAlignment ? [getOppositePlacement(initialPlacement)] : getExpandedPlacements(initialPlacement));
      const hasFallbackAxisSideDirection = fallbackAxisSideDirection !== "none";
      if (!specifiedFallbackPlacements && hasFallbackAxisSideDirection) {
        fallbackPlacements.push(
          ...getOppositeAxisPlacements(
            initialPlacement,
            flipAlignment,
            fallbackAxisSideDirection,
            rtl
          )
        );
      }
      const placements2 = [initialPlacement, ...fallbackPlacements];
      const overflow = await detectOverflow(state, detectOverflowOptions);
      const overflows = [];
      let overflowsData = ((_middlewareData$flip = middlewareData.flip) == null ? void 0 : _middlewareData$flip.overflows) || [];
      if (checkMainAxis) {
        overflows.push(overflow[side]);
      }
      if (checkCrossAxis) {
        const sides2 = getAlignmentSides(placement, rects, rtl);
        overflows.push(overflow[sides2[0]], overflow[sides2[1]]);
      }
      overflowsData = [
        ...overflowsData,
        {
          placement,
          overflows
        }
      ];
      if (!overflows.every((side2) => side2 <= 0)) {
        var _middlewareData$flip2, _overflowsData$filter;
        const nextIndex = (((_middlewareData$flip2 = middlewareData.flip) == null ? void 0 : _middlewareData$flip2.index) || 0) + 1;
        const nextPlacement = placements2[nextIndex];
        if (nextPlacement) {
          var _overflowsData$;
          const ignoreCrossAxisOverflow = checkCrossAxis === "alignment" ? initialSideAxis !== getSideAxis(nextPlacement) : false;
          const hasInitialMainAxisOverflow = ((_overflowsData$ = overflowsData[0]) == null ? void 0 : _overflowsData$.overflows[0]) > 0;
          if (!ignoreCrossAxisOverflow || hasInitialMainAxisOverflow) {
            return {
              data: {
                index: nextIndex,
                overflows: overflowsData
              },
              reset: {
                placement: nextPlacement
              }
            };
          }
        }
        let resetPlacement = (_overflowsData$filter = overflowsData.filter((d) => d.overflows[0] <= 0).sort((a, b) => a.overflows[1] - b.overflows[1])[0]) == null ? void 0 : _overflowsData$filter.placement;
        if (!resetPlacement) {
          switch (fallbackStrategy) {
            case "bestFit": {
              var _overflowsData$filter2;
              const placement2 = (_overflowsData$filter2 = overflowsData.filter((d) => {
                if (hasFallbackAxisSideDirection) {
                  const currentSideAxis = getSideAxis(d.placement);
                  return currentSideAxis === initialSideAxis || // Create a bias to the `y` side axis due to horizontal
                  // reading directions favoring greater width.
                  currentSideAxis === "y";
                }
                return true;
              }).map((d) => [
                d.placement,
                d.overflows.filter((overflow2) => overflow2 > 0).reduce((acc, overflow2) => acc + overflow2, 0)
              ]).sort((a, b) => a[1] - b[1])[0]) == null ? void 0 : _overflowsData$filter2[0];
              if (placement2) {
                resetPlacement = placement2;
              }
              break;
            }
            case "initialPlacement":
              resetPlacement = initialPlacement;
              break;
          }
        }
        if (placement !== resetPlacement) {
          return {
            reset: {
              placement: resetPlacement
            }
          };
        }
      }
      return {};
    }
  };
};
async function convertValueToCoords(state, options) {
  const { placement, platform: platform2, elements } = state;
  const rtl = await (platform2.isRTL == null ? void 0 : platform2.isRTL(elements.floating));
  const side = getSide(placement);
  const alignment = getAlignment(placement);
  const isVertical = getSideAxis(placement) === "y";
  const mainAxisMulti = ["left", "top"].includes(side) ? -1 : 1;
  const crossAxisMulti = rtl && isVertical ? -1 : 1;
  const rawValue = evaluate(options, state);
  let { mainAxis, crossAxis, alignmentAxis } = typeof rawValue === "number" ? {
    mainAxis: rawValue,
    crossAxis: 0,
    alignmentAxis: null
  } : {
    mainAxis: rawValue.mainAxis || 0,
    crossAxis: rawValue.crossAxis || 0,
    alignmentAxis: rawValue.alignmentAxis
  };
  if (alignment && typeof alignmentAxis === "number") {
    crossAxis = alignment === "end" ? alignmentAxis * -1 : alignmentAxis;
  }
  return isVertical ? {
    x: crossAxis * crossAxisMulti,
    y: mainAxis * mainAxisMulti
  } : {
    x: mainAxis * mainAxisMulti,
    y: crossAxis * crossAxisMulti
  };
}
var offset = function(options) {
  if (options === void 0) {
    options = 0;
  }
  return {
    name: "offset",
    options,
    async fn(state) {
      var _middlewareData$offse, _middlewareData$arrow;
      const { x, y, placement, middlewareData } = state;
      const diffCoords = await convertValueToCoords(state, options);
      if (placement === ((_middlewareData$offse = middlewareData.offset) == null ? void 0 : _middlewareData$offse.placement) && (_middlewareData$arrow = middlewareData.arrow) != null && _middlewareData$arrow.alignmentOffset) {
        return {};
      }
      return {
        x: x + diffCoords.x,
        y: y + diffCoords.y,
        data: {
          ...diffCoords,
          placement
        }
      };
    }
  };
};
var shift = function(options) {
  if (options === void 0) {
    options = {};
  }
  return {
    name: "shift",
    options,
    async fn(state) {
      const { x, y, placement } = state;
      const {
        mainAxis: checkMainAxis = true,
        crossAxis: checkCrossAxis = false,
        limiter = {
          fn: (_ref) => {
            let { x: x2, y: y2 } = _ref;
            return {
              x: x2,
              y: y2
            };
          }
        },
        ...detectOverflowOptions
      } = evaluate(options, state);
      const coords = {
        x,
        y
      };
      const overflow = await detectOverflow(state, detectOverflowOptions);
      const crossAxis = getSideAxis(getSide(placement));
      const mainAxis = getOppositeAxis(crossAxis);
      let mainAxisCoord = coords[mainAxis];
      let crossAxisCoord = coords[crossAxis];
      if (checkMainAxis) {
        const minSide = mainAxis === "y" ? "top" : "left";
        const maxSide = mainAxis === "y" ? "bottom" : "right";
        const min2 = mainAxisCoord + overflow[minSide];
        const max2 = mainAxisCoord - overflow[maxSide];
        mainAxisCoord = clamp(min2, mainAxisCoord, max2);
      }
      if (checkCrossAxis) {
        const minSide = crossAxis === "y" ? "top" : "left";
        const maxSide = crossAxis === "y" ? "bottom" : "right";
        const min2 = crossAxisCoord + overflow[minSide];
        const max2 = crossAxisCoord - overflow[maxSide];
        crossAxisCoord = clamp(min2, crossAxisCoord, max2);
      }
      const limitedCoords = limiter.fn({
        ...state,
        [mainAxis]: mainAxisCoord,
        [crossAxis]: crossAxisCoord
      });
      return {
        ...limitedCoords,
        data: {
          x: limitedCoords.x - x,
          y: limitedCoords.y - y,
          enabled: {
            [mainAxis]: checkMainAxis,
            [crossAxis]: checkCrossAxis
          }
        }
      };
    }
  };
};
function hasWindow() {
  return typeof window !== "undefined";
}
function getNodeName(node) {
  if (isNode(node)) {
    return (node.nodeName || "").toLowerCase();
  }
  return "#document";
}
function getWindow(node) {
  var _node$ownerDocument;
  return (node == null || (_node$ownerDocument = node.ownerDocument) == null ? void 0 : _node$ownerDocument.defaultView) || window;
}
function getDocumentElement(node) {
  var _ref;
  return (_ref = (isNode(node) ? node.ownerDocument : node.document) || window.document) == null ? void 0 : _ref.documentElement;
}
function isNode(value) {
  if (!hasWindow()) {
    return false;
  }
  return value instanceof Node || value instanceof getWindow(value).Node;
}
function isElement(value) {
  if (!hasWindow()) {
    return false;
  }
  return value instanceof Element || value instanceof getWindow(value).Element;
}
function isHTMLElement(value) {
  if (!hasWindow()) {
    return false;
  }
  return value instanceof HTMLElement || value instanceof getWindow(value).HTMLElement;
}
function isShadowRoot(value) {
  if (!hasWindow() || typeof ShadowRoot === "undefined") {
    return false;
  }
  return value instanceof ShadowRoot || value instanceof getWindow(value).ShadowRoot;
}
function isOverflowElement(element) {
  const { overflow, overflowX, overflowY, display } = getComputedStyle2(element);
  return /auto|scroll|overlay|hidden|clip/.test(overflow + overflowY + overflowX) && !["inline", "contents"].includes(display);
}
function isTableElement(element) {
  return ["table", "td", "th"].includes(getNodeName(element));
}
function isTopLayer(element) {
  return [":popover-open", ":modal"].some((selector) => {
    try {
      return element.matches(selector);
    } catch (e) {
      return false;
    }
  });
}
function isContainingBlock(elementOrCss) {
  const webkit = isWebKit();
  const css = isElement(elementOrCss) ? getComputedStyle2(elementOrCss) : elementOrCss;
  return ["transform", "translate", "scale", "rotate", "perspective"].some(
    (value) => css[value] ? css[value] !== "none" : false
  ) || (css.containerType ? css.containerType !== "normal" : false) || !webkit && (css.backdropFilter ? css.backdropFilter !== "none" : false) || !webkit && (css.filter ? css.filter !== "none" : false) || ["transform", "translate", "scale", "rotate", "perspective", "filter"].some(
    (value) => (css.willChange || "").includes(value)
  ) || ["paint", "layout", "strict", "content"].some(
    (value) => (css.contain || "").includes(value)
  );
}
function getContainingBlock(element) {
  let currentNode = getParentNode(element);
  while (isHTMLElement(currentNode) && !isLastTraversableNode(currentNode)) {
    if (isContainingBlock(currentNode)) {
      return currentNode;
    } else if (isTopLayer(currentNode)) {
      return null;
    }
    currentNode = getParentNode(currentNode);
  }
  return null;
}
function isWebKit() {
  if (typeof CSS === "undefined" || !CSS.supports) return false;
  return CSS.supports("-webkit-backdrop-filter", "none");
}
function isLastTraversableNode(node) {
  return ["html", "body", "#document"].includes(getNodeName(node));
}
function getComputedStyle2(element) {
  return getWindow(element).getComputedStyle(element);
}
function getNodeScroll(element) {
  if (isElement(element)) {
    return {
      scrollLeft: element.scrollLeft,
      scrollTop: element.scrollTop
    };
  }
  return {
    scrollLeft: element.scrollX,
    scrollTop: element.scrollY
  };
}
function getParentNode(node) {
  if (getNodeName(node) === "html") {
    return node;
  }
  const result = (
    // Step into the shadow DOM of the parent of a slotted node.
    node.assignedSlot || // DOM Element detected.
    node.parentNode || // ShadowRoot detected.
    isShadowRoot(node) && node.host || // Fallback.
    getDocumentElement(node)
  );
  return isShadowRoot(result) ? result.host : result;
}
function getNearestOverflowAncestor(node) {
  const parentNode = getParentNode(node);
  if (isLastTraversableNode(parentNode)) {
    return node.ownerDocument ? node.ownerDocument.body : node.body;
  }
  if (isHTMLElement(parentNode) && isOverflowElement(parentNode)) {
    return parentNode;
  }
  return getNearestOverflowAncestor(parentNode);
}
function getOverflowAncestors(node, list, traverseIframes) {
  var _node$ownerDocument2;
  if (list === void 0) {
    list = [];
  }
  if (traverseIframes === void 0) {
    traverseIframes = true;
  }
  const scrollableAncestor = getNearestOverflowAncestor(node);
  const isBody = scrollableAncestor === ((_node$ownerDocument2 = node.ownerDocument) == null ? void 0 : _node$ownerDocument2.body);
  const win = getWindow(scrollableAncestor);
  if (isBody) {
    const frameElement = getFrameElement(win);
    return list.concat(
      win,
      win.visualViewport || [],
      isOverflowElement(scrollableAncestor) ? scrollableAncestor : [],
      frameElement && traverseIframes ? getOverflowAncestors(frameElement) : []
    );
  }
  return list.concat(
    scrollableAncestor,
    getOverflowAncestors(scrollableAncestor, [], traverseIframes)
  );
}
function getFrameElement(win) {
  return win.parent && Object.getPrototypeOf(win.parent) ? win.frameElement : null;
}
function getCssDimensions(element) {
  const css = getComputedStyle2(element);
  let width = parseFloat(css.width) || 0;
  let height = parseFloat(css.height) || 0;
  const hasOffset = isHTMLElement(element);
  const offsetWidth = hasOffset ? element.offsetWidth : width;
  const offsetHeight = hasOffset ? element.offsetHeight : height;
  const shouldFallback = round(width) !== offsetWidth || round(height) !== offsetHeight;
  if (shouldFallback) {
    width = offsetWidth;
    height = offsetHeight;
  }
  return {
    width,
    height,
    $: shouldFallback
  };
}
function unwrapElement(element) {
  return !isElement(element) ? element.contextElement : element;
}
function getScale(element) {
  const domElement = unwrapElement(element);
  if (!isHTMLElement(domElement)) {
    return createCoords(1);
  }
  const rect = domElement.getBoundingClientRect();
  const { width, height, $ } = getCssDimensions(domElement);
  let x = ($ ? round(rect.width) : rect.width) / width;
  let y = ($ ? round(rect.height) : rect.height) / height;
  if (!x || !Number.isFinite(x)) {
    x = 1;
  }
  if (!y || !Number.isFinite(y)) {
    y = 1;
  }
  return {
    x,
    y
  };
}
var noOffsets = /* @__PURE__ */ createCoords(0);
function getVisualOffsets(element) {
  const win = getWindow(element);
  if (!isWebKit() || !win.visualViewport) {
    return noOffsets;
  }
  return {
    x: win.visualViewport.offsetLeft,
    y: win.visualViewport.offsetTop
  };
}
function shouldAddVisualOffsets(element, isFixed, floatingOffsetParent) {
  if (isFixed === void 0) {
    isFixed = false;
  }
  if (!floatingOffsetParent || isFixed && floatingOffsetParent !== getWindow(element)) {
    return false;
  }
  return isFixed;
}
function getBoundingClientRect(element, includeScale, isFixedStrategy, offsetParent) {
  if (includeScale === void 0) {
    includeScale = false;
  }
  if (isFixedStrategy === void 0) {
    isFixedStrategy = false;
  }
  const clientRect = element.getBoundingClientRect();
  const domElement = unwrapElement(element);
  let scale = createCoords(1);
  if (includeScale) {
    if (offsetParent) {
      if (isElement(offsetParent)) {
        scale = getScale(offsetParent);
      }
    } else {
      scale = getScale(element);
    }
  }
  const visualOffsets = shouldAddVisualOffsets(
    domElement,
    isFixedStrategy,
    offsetParent
  ) ? getVisualOffsets(domElement) : createCoords(0);
  let x = (clientRect.left + visualOffsets.x) / scale.x;
  let y = (clientRect.top + visualOffsets.y) / scale.y;
  let width = clientRect.width / scale.x;
  let height = clientRect.height / scale.y;
  if (domElement) {
    const win = getWindow(domElement);
    const offsetWin = offsetParent && isElement(offsetParent) ? getWindow(offsetParent) : offsetParent;
    let currentWin = win;
    let currentIFrame = getFrameElement(currentWin);
    while (currentIFrame && offsetParent && offsetWin !== currentWin) {
      const iframeScale = getScale(currentIFrame);
      const iframeRect = currentIFrame.getBoundingClientRect();
      const css = getComputedStyle2(currentIFrame);
      const left = iframeRect.left + (currentIFrame.clientLeft + parseFloat(css.paddingLeft)) * iframeScale.x;
      const top2 = iframeRect.top + (currentIFrame.clientTop + parseFloat(css.paddingTop)) * iframeScale.y;
      x *= iframeScale.x;
      y *= iframeScale.y;
      width *= iframeScale.x;
      height *= iframeScale.y;
      x += left;
      y += top2;
      currentWin = getWindow(currentIFrame);
      currentIFrame = getFrameElement(currentWin);
    }
  }
  return rectToClientRect({
    width,
    height,
    x,
    y
  });
}
function getWindowScrollBarX(element, rect) {
  const leftScroll = getNodeScroll(element).scrollLeft;
  if (!rect) {
    return getBoundingClientRect(getDocumentElement(element)).left + leftScroll;
  }
  return rect.left + leftScroll;
}
function getHTMLOffset(documentElement, scroll, ignoreScrollbarX) {
  if (ignoreScrollbarX === void 0) {
    ignoreScrollbarX = false;
  }
  const htmlRect = documentElement.getBoundingClientRect();
  const x = htmlRect.left + scroll.scrollLeft - (ignoreScrollbarX ? 0 : (
    // RTL <body> scrollbar.
    getWindowScrollBarX(documentElement, htmlRect)
  ));
  const y = htmlRect.top + scroll.scrollTop;
  return {
    x,
    y
  };
}
function convertOffsetParentRelativeRectToViewportRelativeRect(_ref) {
  let { elements, rect, offsetParent, strategy } = _ref;
  const isFixed = strategy === "fixed";
  const documentElement = getDocumentElement(offsetParent);
  const topLayer = elements ? isTopLayer(elements.floating) : false;
  if (offsetParent === documentElement || topLayer && isFixed) {
    return rect;
  }
  let scroll = {
    scrollLeft: 0,
    scrollTop: 0
  };
  let scale = createCoords(1);
  const offsets = createCoords(0);
  const isOffsetParentAnElement = isHTMLElement(offsetParent);
  if (isOffsetParentAnElement || !isOffsetParentAnElement && !isFixed) {
    if (getNodeName(offsetParent) !== "body" || isOverflowElement(documentElement)) {
      scroll = getNodeScroll(offsetParent);
    }
    if (isHTMLElement(offsetParent)) {
      const offsetRect = getBoundingClientRect(offsetParent);
      scale = getScale(offsetParent);
      offsets.x = offsetRect.x + offsetParent.clientLeft;
      offsets.y = offsetRect.y + offsetParent.clientTop;
    }
  }
  const htmlOffset = documentElement && !isOffsetParentAnElement && !isFixed ? getHTMLOffset(documentElement, scroll, true) : createCoords(0);
  return {
    width: rect.width * scale.x,
    height: rect.height * scale.y,
    x: rect.x * scale.x - scroll.scrollLeft * scale.x + offsets.x + htmlOffset.x,
    y: rect.y * scale.y - scroll.scrollTop * scale.y + offsets.y + htmlOffset.y
  };
}
function getClientRects(element) {
  return Array.from(element.getClientRects());
}
function getDocumentRect(element) {
  const html = getDocumentElement(element);
  const scroll = getNodeScroll(element);
  const body = element.ownerDocument.body;
  const width = max(
    html.scrollWidth,
    html.clientWidth,
    body.scrollWidth,
    body.clientWidth
  );
  const height = max(
    html.scrollHeight,
    html.clientHeight,
    body.scrollHeight,
    body.clientHeight
  );
  let x = -scroll.scrollLeft + getWindowScrollBarX(element);
  const y = -scroll.scrollTop;
  if (getComputedStyle2(body).direction === "rtl") {
    x += max(html.clientWidth, body.clientWidth) - width;
  }
  return {
    width,
    height,
    x,
    y
  };
}
function getViewportRect(element, strategy) {
  const win = getWindow(element);
  const html = getDocumentElement(element);
  const visualViewport = win.visualViewport;
  let width = html.clientWidth;
  let height = html.clientHeight;
  let x = 0;
  let y = 0;
  if (visualViewport) {
    width = visualViewport.width;
    height = visualViewport.height;
    const visualViewportBased = isWebKit();
    if (!visualViewportBased || visualViewportBased && strategy === "fixed") {
      x = visualViewport.offsetLeft;
      y = visualViewport.offsetTop;
    }
  }
  return {
    width,
    height,
    x,
    y
  };
}
function getInnerBoundingClientRect(element, strategy) {
  const clientRect = getBoundingClientRect(element, true, strategy === "fixed");
  const top2 = clientRect.top + element.clientTop;
  const left = clientRect.left + element.clientLeft;
  const scale = isHTMLElement(element) ? getScale(element) : createCoords(1);
  const width = element.clientWidth * scale.x;
  const height = element.clientHeight * scale.y;
  const x = left * scale.x;
  const y = top2 * scale.y;
  return {
    width,
    height,
    x,
    y
  };
}
function getClientRectFromClippingAncestor(element, clippingAncestor, strategy) {
  let rect;
  if (clippingAncestor === "viewport") {
    rect = getViewportRect(element, strategy);
  } else if (clippingAncestor === "document") {
    rect = getDocumentRect(getDocumentElement(element));
  } else if (isElement(clippingAncestor)) {
    rect = getInnerBoundingClientRect(clippingAncestor, strategy);
  } else {
    const visualOffsets = getVisualOffsets(element);
    rect = {
      x: clippingAncestor.x - visualOffsets.x,
      y: clippingAncestor.y - visualOffsets.y,
      width: clippingAncestor.width,
      height: clippingAncestor.height
    };
  }
  return rectToClientRect(rect);
}
function hasFixedPositionAncestor(element, stopNode) {
  const parentNode = getParentNode(element);
  if (parentNode === stopNode || !isElement(parentNode) || isLastTraversableNode(parentNode)) {
    return false;
  }
  return getComputedStyle2(parentNode).position === "fixed" || hasFixedPositionAncestor(parentNode, stopNode);
}
function getClippingElementAncestors(element, cache) {
  const cachedResult = cache.get(element);
  if (cachedResult) {
    return cachedResult;
  }
  let result = getOverflowAncestors(element, [], false).filter(
    (el) => isElement(el) && getNodeName(el) !== "body"
  );
  let currentContainingBlockComputedStyle = null;
  const elementIsFixed = getComputedStyle2(element).position === "fixed";
  let currentNode = elementIsFixed ? getParentNode(element) : element;
  while (isElement(currentNode) && !isLastTraversableNode(currentNode)) {
    const computedStyle = getComputedStyle2(currentNode);
    const currentNodeIsContaining = isContainingBlock(currentNode);
    if (!currentNodeIsContaining && computedStyle.position === "fixed") {
      currentContainingBlockComputedStyle = null;
    }
    const shouldDropCurrentNode = elementIsFixed ? !currentNodeIsContaining && !currentContainingBlockComputedStyle : !currentNodeIsContaining && computedStyle.position === "static" && !!currentContainingBlockComputedStyle && ["absolute", "fixed"].includes(
      currentContainingBlockComputedStyle.position
    ) || isOverflowElement(currentNode) && !currentNodeIsContaining && hasFixedPositionAncestor(element, currentNode);
    if (shouldDropCurrentNode) {
      result = result.filter((ancestor) => ancestor !== currentNode);
    } else {
      currentContainingBlockComputedStyle = computedStyle;
    }
    currentNode = getParentNode(currentNode);
  }
  cache.set(element, result);
  return result;
}
function getClippingRect(_ref) {
  let { element, boundary, rootBoundary, strategy } = _ref;
  const elementClippingAncestors = boundary === "clippingAncestors" ? isTopLayer(element) ? [] : getClippingElementAncestors(element, this._c) : [].concat(boundary);
  const clippingAncestors = [...elementClippingAncestors, rootBoundary];
  const firstClippingAncestor = clippingAncestors[0];
  const clippingRect = clippingAncestors.reduce(
    (accRect, clippingAncestor) => {
      const rect = getClientRectFromClippingAncestor(
        element,
        clippingAncestor,
        strategy
      );
      accRect.top = max(rect.top, accRect.top);
      accRect.right = min(rect.right, accRect.right);
      accRect.bottom = min(rect.bottom, accRect.bottom);
      accRect.left = max(rect.left, accRect.left);
      return accRect;
    },
    getClientRectFromClippingAncestor(element, firstClippingAncestor, strategy)
  );
  return {
    width: clippingRect.right - clippingRect.left,
    height: clippingRect.bottom - clippingRect.top,
    x: clippingRect.left,
    y: clippingRect.top
  };
}
function getDimensions(element) {
  const { width, height } = getCssDimensions(element);
  return {
    width,
    height
  };
}
function getRectRelativeToOffsetParent(element, offsetParent, strategy) {
  const isOffsetParentAnElement = isHTMLElement(offsetParent);
  const documentElement = getDocumentElement(offsetParent);
  const isFixed = strategy === "fixed";
  const rect = getBoundingClientRect(element, true, isFixed, offsetParent);
  let scroll = {
    scrollLeft: 0,
    scrollTop: 0
  };
  const offsets = createCoords(0);
  function setLeftRTLScrollbarOffset() {
    offsets.x = getWindowScrollBarX(documentElement);
  }
  if (isOffsetParentAnElement || !isOffsetParentAnElement && !isFixed) {
    if (getNodeName(offsetParent) !== "body" || isOverflowElement(documentElement)) {
      scroll = getNodeScroll(offsetParent);
    }
    if (isOffsetParentAnElement) {
      const offsetRect = getBoundingClientRect(
        offsetParent,
        true,
        isFixed,
        offsetParent
      );
      offsets.x = offsetRect.x + offsetParent.clientLeft;
      offsets.y = offsetRect.y + offsetParent.clientTop;
    } else if (documentElement) {
      setLeftRTLScrollbarOffset();
    }
  }
  if (isFixed && !isOffsetParentAnElement && documentElement) {
    setLeftRTLScrollbarOffset();
  }
  const htmlOffset = documentElement && !isOffsetParentAnElement && !isFixed ? getHTMLOffset(documentElement, scroll) : createCoords(0);
  const x = rect.left + scroll.scrollLeft - offsets.x - htmlOffset.x;
  const y = rect.top + scroll.scrollTop - offsets.y - htmlOffset.y;
  return {
    x,
    y,
    width: rect.width,
    height: rect.height
  };
}
function isStaticPositioned(element) {
  return getComputedStyle2(element).position === "static";
}
function getTrueOffsetParent(element, polyfill) {
  if (!isHTMLElement(element) || getComputedStyle2(element).position === "fixed") {
    return null;
  }
  if (polyfill) {
    return polyfill(element);
  }
  let rawOffsetParent = element.offsetParent;
  if (getDocumentElement(element) === rawOffsetParent) {
    rawOffsetParent = rawOffsetParent.ownerDocument.body;
  }
  return rawOffsetParent;
}
function getOffsetParent(element, polyfill) {
  const win = getWindow(element);
  if (isTopLayer(element)) {
    return win;
  }
  if (!isHTMLElement(element)) {
    let svgOffsetParent = getParentNode(element);
    while (svgOffsetParent && !isLastTraversableNode(svgOffsetParent)) {
      if (isElement(svgOffsetParent) && !isStaticPositioned(svgOffsetParent)) {
        return svgOffsetParent;
      }
      svgOffsetParent = getParentNode(svgOffsetParent);
    }
    return win;
  }
  let offsetParent = getTrueOffsetParent(element, polyfill);
  while (offsetParent && isTableElement(offsetParent) && isStaticPositioned(offsetParent)) {
    offsetParent = getTrueOffsetParent(offsetParent, polyfill);
  }
  if (offsetParent && isLastTraversableNode(offsetParent) && isStaticPositioned(offsetParent) && !isContainingBlock(offsetParent)) {
    return win;
  }
  return offsetParent || getContainingBlock(element) || win;
}
var getElementRects = async function(data) {
  const getOffsetParentFn = this.getOffsetParent || getOffsetParent;
  const getDimensionsFn = this.getDimensions;
  const floatingDimensions = await getDimensionsFn(data.floating);
  return {
    reference: getRectRelativeToOffsetParent(
      data.reference,
      await getOffsetParentFn(data.floating),
      data.strategy
    ),
    floating: {
      x: 0,
      y: 0,
      width: floatingDimensions.width,
      height: floatingDimensions.height
    }
  };
};
function isRTL(element) {
  return getComputedStyle2(element).direction === "rtl";
}
var platform = {
  convertOffsetParentRelativeRectToViewportRelativeRect,
  getDocumentElement,
  getClippingRect,
  getOffsetParent,
  getElementRects,
  getClientRects,
  getDimensions,
  getScale,
  isElement,
  isRTL
};
function rectsAreEqual(a, b) {
  return a.x === b.x && a.y === b.y && a.width === b.width && a.height === b.height;
}
function observeMove(element, onMove) {
  let io = null;
  let timeoutId;
  const root = getDocumentElement(element);
  function cleanup() {
    var _io;
    clearTimeout(timeoutId);
    (_io = io) == null || _io.disconnect();
    io = null;
  }
  function refresh(skip, threshold) {
    if (skip === void 0) {
      skip = false;
    }
    if (threshold === void 0) {
      threshold = 1;
    }
    cleanup();
    const elementRectForRootMargin = element.getBoundingClientRect();
    const { left, top: top2, width, height } = elementRectForRootMargin;
    if (!skip) {
      onMove();
    }
    if (!width || !height) {
      return;
    }
    const insetTop = floor(top2);
    const insetRight = floor(root.clientWidth - (left + width));
    const insetBottom = floor(root.clientHeight - (top2 + height));
    const insetLeft = floor(left);
    const rootMargin = -insetTop + "px " + -insetRight + "px " + -insetBottom + "px " + -insetLeft + "px";
    const options = {
      rootMargin,
      threshold: max(0, min(1, threshold)) || 1
    };
    let isFirstUpdate = true;
    function handleObserve(entries) {
      const ratio = entries[0].intersectionRatio;
      if (ratio !== threshold) {
        if (!isFirstUpdate) {
          return refresh();
        }
        if (!ratio) {
          timeoutId = setTimeout(() => {
            refresh(false, 1e-7);
          }, 1e3);
        } else {
          refresh(false, ratio);
        }
      }
      if (ratio === 1 && !rectsAreEqual(
        elementRectForRootMargin,
        element.getBoundingClientRect()
      )) {
        refresh();
      }
      isFirstUpdate = false;
    }
    try {
      io = new IntersectionObserver(handleObserve, {
        ...options,
        // Handle <iframe>s
        root: root.ownerDocument
      });
    } catch (_e) {
      io = new IntersectionObserver(handleObserve, options);
    }
    io.observe(element);
  }
  refresh(true);
  return cleanup;
}
function autoUpdate(reference, floating, update, options) {
  if (options === void 0) {
    options = {};
  }
  const {
    ancestorScroll = true,
    ancestorResize = true,
    elementResize = typeof ResizeObserver === "function",
    layoutShift = typeof IntersectionObserver === "function",
    animationFrame = false
  } = options;
  const referenceEl = unwrapElement(reference);
  const ancestors = ancestorScroll || ancestorResize ? [
    ...referenceEl ? getOverflowAncestors(referenceEl) : [],
    ...getOverflowAncestors(floating)
  ] : [];
  ancestors.forEach((ancestor) => {
    ancestorScroll && ancestor.addEventListener("scroll", update, {
      passive: true
    });
    ancestorResize && ancestor.addEventListener("resize", update);
  });
  const cleanupIo = referenceEl && layoutShift ? observeMove(referenceEl, update) : null;
  let reobserveFrame = -1;
  let resizeObserver = null;
  if (elementResize) {
    resizeObserver = new ResizeObserver((_ref) => {
      let [firstEntry] = _ref;
      if (firstEntry && firstEntry.target === referenceEl && resizeObserver) {
        resizeObserver.unobserve(floating);
        cancelAnimationFrame(reobserveFrame);
        reobserveFrame = requestAnimationFrame(() => {
          var _resizeObserver;
          (_resizeObserver = resizeObserver) == null || _resizeObserver.observe(floating);
        });
      }
      update();
    });
    if (referenceEl && !animationFrame) {
      resizeObserver.observe(referenceEl);
    }
    resizeObserver.observe(floating);
  }
  let frameId;
  let prevRefRect = animationFrame ? getBoundingClientRect(reference) : null;
  if (animationFrame) {
    frameLoop();
  }
  function frameLoop() {
    const nextRefRect = getBoundingClientRect(reference);
    if (prevRefRect && !rectsAreEqual(prevRefRect, nextRefRect)) {
      update();
    }
    prevRefRect = nextRefRect;
    frameId = requestAnimationFrame(frameLoop);
  }
  update();
  return () => {
    var _resizeObserver2;
    ancestors.forEach((ancestor) => {
      ancestorScroll && ancestor.removeEventListener("scroll", update);
      ancestorResize && ancestor.removeEventListener("resize", update);
    });
    cleanupIo == null || cleanupIo();
    (_resizeObserver2 = resizeObserver) == null || _resizeObserver2.disconnect();
    resizeObserver = null;
    if (animationFrame) {
      cancelAnimationFrame(frameId);
    }
  };
}
var offset2 = offset;
var shift2 = shift;
var flip2 = flip;
var computePosition2 = (reference, floating, options) => {
  const cache = /* @__PURE__ */ new Map();
  const mergedOptions = {
    platform,
    ...options
  };
  const platformWithCache = {
    ...mergedOptions.platform,
    _c: cache
  };
  return computePosition(reference, floating, {
    ...mergedOptions,
    platform: platformWithCache
  });
};

// js/popover.js
var Popover = class extends ViewHook {
  expanded = false;
  name = "popover";
  placement = "bottom-start";
  currentIndex = -1;
  #outside_listener;
  #clear_floating;
  mounted() {
    this.trigger = this.el.querySelector(
      "[aria-haspopup='menu'],[aria-haspopup='listbox'],[role='combobox']"
    );
    this.popup = this.el.querySelector("[role='menu'],[role='listbox']");
    this.search = this.el.querySelector("input[type='text'][role='combobox']");
    this.placement = this.el.dataset.placement || this.placement;
    this.items = this.popup.querySelectorAll(
      "[role='option'],[role='menuitem']"
    );
    this.refreshExpanded();
    this.trigger.addEventListener("click", () => {
      if (this.expanded) {
        this.closePopover();
      } else {
        this.openPopover();
      }
      this.refreshExpanded();
    });
    this.el.addEventListener("keydown", this.handleContainerKeyDown.bind(this));
    this.trigger.addEventListener(
      "keydown",
      this.handleTriggerKeyDown.bind(this)
    );
    this.search?.addEventListener("input", this.handleSearchInput.bind(this));
    this.#outside_listener = document.addEventListener("click", (event) => {
      if (!this.el.contains(event.target)) {
        this.closePopover();
      }
    });
    this.initFloatingUI();
  }
  updated() {
    this.restoreExpanded();
    this.refreshFloatingUI();
  }
  destroyed() {
    if (this.#outside_listener) {
      this.#outside_listener();
    }
    if (this.#clear_floating) {
      this.#clear_floating();
    }
  }
  handleSearchInput(event) {
    const query = event.target.value.toLowerCase();
    this.currentIndex = -1;
    this.items.forEach((item) => {
      const itemText = (item.dataset.label || item.textContent).trim().toLowerCase();
      const matches = itemText.includes(query);
      item.setAttribute("aria-hidden", String(!matches));
    });
  }
  handleTriggerKeyDown(event) {
    if (event.key === "ArrowDown" && !this.expanded) {
      event.preventDefault();
      this.openPopover();
    }
  }
  handleContainerKeyDown(event) {
    if (!this.expanded) return;
    switch (event.key) {
      case "Escape":
        event.preventDefault();
        this.closePopover();
        this.trigger.focus();
        break;
      case "ArrowDown":
      case "ArrowUp":
      case "Home":
      case "End":
        this.handleArrowNavigation(event);
        break;
      case "Enter":
        if (this.currentIndex >= 0) {
          const visibleItems = Array.from(this.items).filter(
            (item) => item.style.display !== "none"
          );
          const currentItem = visibleItems[this.currentIndex];
          if (currentItem) {
          }
        }
        break;
      case "Tab":
        this.closePopover();
        break;
    }
  }
  handleArrowNavigation(event) {
    if (!this.expanded) return;
    const visibleItems = Array.from(this.items).filter(
      (item) => item.style.display !== "none" && item.getAttribute("aria-disabled") !== "true" && item.getAttribute("aria-hidden") !== "true"
    );
    const itemCount = visibleItems.length;
    if (itemCount === 0) return;
    event.preventDefault();
    let newIndex = this.currentIndex;
    switch (event.key) {
      case "ArrowDown":
        newIndex = (this.currentIndex + 1) % itemCount;
        break;
      case "ArrowUp":
        newIndex = (this.currentIndex - 1 + itemCount) % itemCount;
        break;
      case "Home":
        newIndex = 0;
        break;
      case "End":
        newIndex = itemCount - 1;
        break;
    }
    visibleItems.forEach((item, index) => {
      if (index === newIndex) {
        item.setAttribute("aria-selected", "true");
        if (!this.search || true) {
          item.setAttribute("tabindex", "0");
          item.focus();
        }
        item.scrollIntoView({ block: "nearest" });
      } else {
        item.removeAttribute("aria-selected");
        if (!this.search || true) {
          item.setAttribute("tabindex", "-1");
        }
      }
    });
    this.currentIndex = newIndex;
  }
  initFloatingUI() {
    if (this.#clear_floating) {
      this.#clear_floating();
    }
    if (!this.trigger || !this.popup) {
      return;
    }
    this.#clear_floating = autoUpdate(this.trigger, this.popup, () => {
      this.refreshFloatingUI();
    });
  }
  refreshFloatingUI() {
    computePosition2(this.trigger, this.popup, {
      placement: this.placement,
      middleware: [offset2(8), flip2(), shift2()]
    }).then(({ x, y }) => {
      Object.assign(this.popup.style, {
        left: `${x}px`,
        top: `${y}px`
      });
    });
  }
  closePopover() {
    this.trigger?.setAttribute("aria-expanded", "false");
    this.popup?.setAttribute("aria-hidden", "true");
    if (this.search) {
      this.search.value = "";
    }
    this.expanded = false;
    this.currentIndex = -1;
  }
  openPopover() {
    this.trigger?.setAttribute("aria-expanded", "true");
    this.popup?.setAttribute("aria-hidden", "false");
    if (this.search) {
      this.search.focus();
    }
    this.expanded = true;
  }
  log(msg, data) {
    console.log(`${this.name}: ${msg}`, data);
  }
  refreshExpanded() {
    this.expanded = this.trigger?.getAttribute("aria-expanded") == "true";
  }
  restoreExpanded() {
    if (this.expanded) {
      this.openPopover();
    } else {
      this.closePopover();
    }
  }
};

// js/select.js
var Select = class extends Popover {
  mounted() {
    this.name = "select";
    super.mounted();
    this.log("mounted");
  }
};

// js/index.js
var Hooks2 = {
  Popover,
  Select
};
//# sourceMappingURL=maui.cjs.js.map
