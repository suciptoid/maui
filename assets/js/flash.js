import { ViewHook } from "phoenix_live_view";

export default class FlashGroup extends ViewHook {
  max_flashes = 3;
  flash_timeout = 5;
  #timers = new Map();
  #pausedTimers = new Map();

  mounted() {
    this._updateFlashList();
    this.max_flashes = this.el.dataset.maxFlashes || this.max_flashes;
    this.flash_timeout = this.el.dataset.flashTimeout || this.flash_timeout;

    this.el.addEventListener(
      "mouseenter",
      this._onContainerMouseEnter.bind(this),
    );
    this.el.addEventListener(
      "mouseleave",
      this._onContainerMouseLeave.bind(this),
    );
  }

  updated() {
    this._updateFlashList();
  }

  destroyed() {
    this.#timers.forEach((timerObj) => clearTimeout(timerObj.timer));
    this.#timers.clear();

    this.el.removeEventListener(
      "mouseenter",
      this._onContainerMouseEnter.bind(this),
    );
    this.el.removeEventListener(
      "mouseleave",
      this._onContainerMouseLeave.bind(this),
    );
  }

  _onContainerMouseEnter() {
    this._pauseAllTimers();
  }

  _onContainerMouseLeave() {
    this._resumeAllTimers();
  }

  _onClose(event) {
    const flash = event.currentTarget.closest('[role="alert"]');

    if (this.liveSocket?.isConnected()) {
      this.pushEvent("lv:clear-flash", { value: flash.dataset.flashId });
    }

    this._removeFlash(flash);
  }

  _removeFlash(flash) {
    const flashId = flash.dataset.flashId;

    // Clear timer if exists
    if (this.#timers.has(flashId)) {
      const timerObj = this.#timers.get(flashId);
      clearTimeout(timerObj.timer);
      this.#timers.delete(flashId);
    }

    flash.remove();
    this._updateFlashList();
  }

  _startTimerForFlash(flash) {
    const flashId = flash.dataset.flashId;
    let duration = parseInt(flash.dataset.duration);

    if (duration === -1) {
      return;
    }

    const flashTimeout =
      (!isNaN(duration) ? duration : this.flash_timeout) * 1000;

    if (this.#timers.has(flashId)) {
      const existingTimer = this.#timers.get(flashId);
      clearTimeout(existingTimer.timer);
    }

    const remainingTime = this.#pausedTimers.has(flashId)
      ? this.#pausedTimers.get(flashId)
      : flashTimeout;

    const startTime = Date.now();

    const timer = setTimeout(() => {
      this._removeFlash(flash);
    }, remainingTime);

    this.#timers.set(flashId, { timer, startTime, timeout: flashTimeout });

    if (this.#pausedTimers.has(flashId)) {
      this.#pausedTimers.delete(flashId);
    }
  }

  _pauseAllTimers() {
    this.#timers.forEach((timerObj, flashId) => {
      clearTimeout(timerObj.timer);

      const elapsed = Date.now() - timerObj.startTime;
      const remainingTime = Math.max(0, timerObj.timeout - elapsed);

      this.#pausedTimers.set(flashId, remainingTime);
    });

    this.#timers.clear();
  }

  _resumeAllTimers() {
    this.#pausedTimers.forEach((remainingTime, flashId) => {
      const flash = this.el.querySelector(`[data-flash-id="${flashId}"]`);
      if (flash) {
        const duration = parseInt(flash.dataset.duration);

        if (duration !== -1) {
          const flashTimeout =
            (!isNaN(duration) ? duration : this.flash_timeout) * 1000;
          const startTime = Date.now();
          const timer = setTimeout(() => {
            this._removeFlash(flash);
          }, remainingTime);

          this.#timers.set(flashId, {
            timer,
            startTime,
            timeout: flashTimeout,
          });
        }
      }
    });

    this.#pausedTimers.clear();
  }

  _updateFlashList() {
    this.flash = this.el.querySelectorAll('[role="alert"]');
    const position = this.el.dataset.position;

    this.flash.forEach((flash, index) => {
      flash.dataset.index = index;
      flash.dataset.position = position;
      flash.style.setProperty("--flash-index", index);

      if (flash.phxPrivate?.["JS:ignore_attrs"] == null) {
        this.js().ignoreAttributes(flash, ["aria-*", "data-visible", "style"]);
      }

      if (index === 0 && flash.dataset.visible !== "true") {
        flash.setAttribute("aria-hidden", "true");
        flash.style.transition = "none";
        flash.style.setProperty(
          "--flash-offset-y",
          position.startsWith("bottom-") ? "200%" : "-200%",
        );
      }
      flash.dataset.visible = "true";

      const height = flash.offsetHeight;

      const offsetY = Array.from(this.flash)
        .slice(0, index)
        .reduce((acc, item) => acc + item.offsetHeight + 10, 0);

      flash.style.setProperty("--flash-height", `${height}px`);

      flash.setAttribute("aria-hidden", "false");
      requestAnimationFrame(() => {
        flash.style.transition = "";
        flash.style.setProperty(
          "--flash-offset-y",
          position.startsWith("bottom-") ? `${-offsetY}px` : `${offsetY}px`,
        );
      });

      // Flash close button
      const closeButton = flash.querySelector("button[data-close]");
      if (closeButton?.dataset.close == "") {
        closeButton?.addEventListener("click", this._onClose.bind(this));
        closeButton.dataset.close = "true";
      }

      const flashId = flash.dataset.flashId;
      if (!this.#timers.has(flashId)) {
        this._startTimerForFlash(flash);
      }
    });
  }
}
