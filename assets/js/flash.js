import { ViewHook } from "phoenix_live_view";
export default class FlashGroup extends ViewHook {
  max_flashes = 3;

  mounted() {
    this._updateFlashList();
    this.max_flashes = this.el.dataset.maxFlashes || this.max_flashes;
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
    // console.log("container mouse enter");
  }

  _onContainerMouseLeave() {
    // console.log("container mouse leave");
  }

  _onClose(event) {
    const flash = event.currentTarget.closest('[role="alert"]');

    if (this.liveSocket?.isConnected()) {
      this.pushEvent("lv:clear-flash", { value: flash.dataset.flashId });
    }
    flash.remove();
    this._updateFlashList();
  }

  _updateFlashList() {
    this.flash = this.el.querySelectorAll('[role="alert"]');
    const position = this.el.dataset.position;
    this.flash.forEach((flash, index) => {
      flash.dataset.index = index;
      flash.dataset.position = position;
      flash.style.setProperty("--flash-index", index);
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
    });
  }
}
