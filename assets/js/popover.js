import { ViewHook } from "phoenix_live_view";
import {
  computePosition,
  offset,
  flip,
  shift,
  autoUpdate,
} from "@floating-ui/dom";

export default class Popover extends ViewHook {
  expanded = false;
  name = "popover";
  placement = "bottom-start";
  strategy = "absolute"; // floating-ui strategy
  event_trigger = "click"; // "click" | "hover" | "focus"
  currentIndex = -1;

  #outside_listener;
  #clear_floating;

  mounted() {
    // Initialize trigger and popup elements
    this.trigger = this.el.querySelector("[aria-haspopup],[role='combobox']");
    this.popup = this.el.querySelector("[role='menu'],[role='listbox']");
    this.search = this.el.querySelector("input[type='text'][role='combobox']");

    this.placement = this.el.dataset.placement || this.placement;
    this.strategy = this.el.dataset.strategy || this.strategy;
    this.event_trigger = this.el.dataset.trigger || this.event_trigger;

    this.items = this.popup.querySelectorAll(
      "[role='option'],[role='menuitem']",
    );

    this.refreshExpanded();

    if (this.event_trigger === "click") {
      // Trigger click handler
      this.trigger?.addEventListener("click", () => {
        if (this.expanded) {
          this.closePopover();
        } else {
          this.openPopover();
        }

        this.refreshExpanded();
      });
    } else if (this.event_trigger === "hover") {
      // Trigger hover handler
      this.trigger?.addEventListener("mouseenter", () => {
        this.openPopover();
        this.refreshExpanded();
      });

      this.trigger?.addEventListener("mouseleave", () => {
        this.closePopover();
        this.refreshExpanded();
      });
    } else if (this.event_trigger === "focus") {
      // Trigger focus handler
      this.trigger?.addEventListener("focus", () => {
        this.openPopover();
        this.refreshExpanded();
      });

      this.trigger?.addEventListener("blur", () => {
        this.closePopover();
        this.refreshExpanded();
      });
    }

    // Keydown handler
    this.el.addEventListener("keydown", this.handleContainerKeyDown.bind(this));
    this.trigger?.addEventListener(
      "keydown",
      this.handleTriggerKeyDown.bind(this),
    );

    // Search input handler
    this.search?.addEventListener("input", this.handleSearchInput.bind(this));

    // Click outside
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
      const itemText = (item.dataset.label || item.textContent)
        .trim()
        .toLowerCase();
      const matches = itemText.includes(query);
      item.setAttribute("aria-hidden", String(!matches));
    });
  }

  handleTriggerKeyDown(event) {
    if (event.key === "ArrowDown" && !this.expanded) {
      event.preventDefault();
      this.openPopover();
    }
    // if (event.key === "Enter" && !this.expanded) {
    //   event.preventDefault();
    //   this.closePopover();
    // }
  }

  handleContainerKeyDown(event) {
    if (!this.expanded) return;

    switch (event.key) {
      case "Escape":
        event.preventDefault();
        this.closePopover();
        this.trigger?.focus();
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
            (item) => item.style.display !== "none",
          );
          const currentItem = visibleItems[this.currentIndex];
          if (currentItem) {
            // event.preventDefault();
            // currentItem.click();
            // this.toggle(false);
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
      (item) =>
        item.style.display !== "none" &&
        item.getAttribute("aria-disabled") !== "true" &&
        item.getAttribute("aria-hidden") !== "true",
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
          // use another dataset for active state
          item.setAttribute("tabindex", "0");
          item.focus();
        }
        // item.setAttribute("data-highlighted", "true");
        item.scrollIntoView({ block: "nearest" });
      } else {
        item.removeAttribute("aria-selected");
        // item.removeAttribute("data-highlighted");
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
    computePosition(this.trigger, this.popup, {
      placement: this.placement,
      strategy: this.strategy,
      middleware: [offset(8), flip(), shift()],
    }).then(({ x, y, strategy }) => {
      Object.assign(this.popup.style, {
        left: `${x}px`,
        top: `${y}px`,
        position: strategy,
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
}
