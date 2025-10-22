import { ViewHook } from "phoenix_live_view";
import {
  computePosition,
  offset,
  flip,
  shift,
  autoUpdate,
  arrow,
} from "@floating-ui/dom";

export default class Tooltip extends ViewHook {
  placement = "top";
  delay = 300;
  hovering = false;
  #clear_floating;

  #enterBind;
  #leaveBind;
  leaveTimeout = null;

  mounted() {
    this.trigger = this.el.querySelector(':scope > :not([role="tooltip"])');
    this.tooltip = this.el.querySelector(':scope > [role="tooltip"]');
    this.arrow = this.el.querySelector(
      ':scope > [role="tooltip"] > [data-arrow]',
    );

    this.placement = this.el.dataset.placement || this.placement;
    this.delay = this.el.dataset.delay || this.delay;
    this.#clear_floating = autoUpdate(this.trigger, this.tooltip, () => {
      this._calculatePosition();
    });

    this.#enterBind = this._onMouseEnter.bind(this);
    this.#leaveBind = this._onMouseLeave.bind(this);

    this.el?.addEventListener("mouseenter", this.#enterBind);
    this.el?.addEventListener("mouseleave", this.#leaveBind);
  }

  updated() {
    this.setHidden(this.hovering ? false : true);

    this._calculatePosition();
  }

  destroyed() {
    if (this.#clear_floating) {
      this.#clear_floating();
    }

    this.el?.removeEventListener("mouseenter", this.#enterBind);
    this.el?.removeEventListener("mouseleave", this.#leaveBind);
  }

  setHidden(hidden) {
    requestAnimationFrame(() => {
      this.tooltip?.setAttribute("aria-hidden", hidden ? "true" : "false");
    });
  }

  _onMouseEnter(e) {
    this.hovering = true;
    if (this.leaveTimeout) clearTimeout(this.leaveTimeout);
    this.setHidden(false);
  }

  _onMouseLeave(e) {
    if (this.leaveTimeout) clearTimeout(this.leaveTimeout);
    this.hovering = false;
    this.leaveTimeout = setTimeout(() => {
      this.setHidden(true);
    }, this.delay);
  }

  _calculatePosition(data) {
    computePosition(this.trigger, this.tooltip, {
      placement: this.placement,
      strategy: "fixed",
      middleware: [offset(8), flip(), shift(), arrow({ element: this.arrow })],
    }).then(({ x, y, strategy, middlewareData, placement }) => {
      Object.assign(this.tooltip.style, {
        left: `${x}px`,
        top: `${y}px`,
        position: strategy,
      });
      if (middlewareData.arrow) {
        const { x, y } = middlewareData.arrow;

        const p = placement.split("-").at(0) ?? null;
        const arrowPlacement = {
          top: "bottom",
          left: "right",
          right: "left",
          bottom: "top",
        };

        const style = {
          left: x != null ? `${x}px` : "",
          top: y != null ? `${y}px` : "",
        };

        style[arrowPlacement[p]] = "-4px";

        Object.assign(this.arrow.style, style);
      }
    });
  }
}
