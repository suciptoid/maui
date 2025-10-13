import { ViewHook } from "phoenix_live_view";

State = {
  IDLE: 0,
  STARTING: 1,
};

export default class LoadingBar extends ViewHook {
  progress = 0;

  #delay = 500;
  #delayTimer = null;
  #raf = null;
  #state = State.IDLE;
  #boundShow = null;
  #boundHide = null;

  mounted() {
    this.progressEl = this.el.querySelector("#loadingbar-progress");
    this.#delay = parseInt(this.el.dataset.delay || "0") || this.#delay;

    this.#boundShow = this._show.bind(this);
    this.#boundHide = this._hide.bind(this);
    this.#state = State.IDLE;

    window.addEventListener("phx:page-loading-start", this.#boundShow);
    window.addEventListener("phx:page-loading-stop", this.#boundHide);
  }

  _show(info) {
    this._reset();
    this.#state = State.STARTING;

    this.#delayTimer = setTimeout(() => {
      if (this.#state === State.STARTING) {
        this._start();
      }
    }, this.#delay);
  }

  _start() {
    let lastTime = performance.now();

    const step = (now) => {
      const dt = now - lastTime;
      lastTime = now;
      if (this.progress < 50) {
        const delta = (100 - this.progress) * 0.01 * (dt / 16);
        this.progress = Math.min(this.progress + delta, 50);
      } else if (this.progress < 90) {
        const delta = (100 - this.progress) * 0.0025 * (dt / 16);
        this.progress = Math.min(this.progress + delta, 90);
      } else if (this.progress < 99) {
        const delta = (100 - this.progress) * 0.0005 * (dt / 16);
        this.progress = Math.min(this.progress + delta, 99);
      }

      this.progressEl.style.width = `${this.progress}%`;
      this.#raf = requestAnimationFrame(step);
    };

    this.#raf = requestAnimationFrame(step);
  }

  _reset() {
    this.progressEl.style.transition = "none";
    this.progressEl.style.width = "0%";
    this.progressEl.offsetHeight; // force reflow
    this.progressEl.style.transition = "";
    this.progress = 0;

    if (this.#delayTimer) {
      clearTimeout(this.#delayTimer);
      this.#delayTimer = null;
    }

    this.#state = State.IDLE;

    cancelAnimationFrame(this.#raf);
  }

  _hide(info) {
    this.#state = State.IDLE;

    if (this.progress > 0) {
      this.progress = 100;
      this.progressEl.style.width = "100%";
    }

    setTimeout(() => {
      this._reset();
    }, 500);
  }

  destroyed() {
    window.removeEventListener("phx:page-loading-start", this.#boundShow);
    window.removeEventListener("phx:page-loading-stop", this.#boundHide);
    this._reset();
  }
}
