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
  placement = "top-center";
  #clear_floating;

  mounted() {
    this.trigger = this.el.querySelector(':scope > :not([role="tooltip"])');
    this.tooltip = this.el.querySelector(':scope > [role="tooltip"]');
    this.arrow = this.el.querySelector(
      ':scope > [role="tooltip"] > [data-arrow]',
    );

    this.placement = this.el.dataset.placement || this.placement;
    this.#clear_floating = autoUpdate(this.trigger, this.tooltip, () => {
      this._calculatePosition();
    });
  }

  destroyed() {
    if (this.#clear_floating) {
      this.#clear_floating();
    }
  }

  _calculatePosition() {
    computePosition(this.trigger, this.tooltip, {
      placement: this.placement,
      strategy: "fixed",
      middleware: [offset(8), flip(), shift(), arrow({ element: this.arrow })],
    }).then(({ x, y, strategy, middlewareData }) => {
      Object.assign(this.tooltip.style, {
        left: `${x}px`,
        top: `${y}px`,
        position: strategy,
      });
      if (middlewareData.arrow) {
        const { x, y } = middlewareData.arrow;

        Object.assign(this.arrow.style, {
          left: x != null ? `${x}px` : "",
          top: y != null ? `${y}px` : "",
        });
      }
    });
  }
}
