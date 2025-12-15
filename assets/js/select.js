import Popover from "./popover";
export default class Select extends Popover {
  placement = "bottom-start";
  expand_popover = true;
  focus_selected = false;

  #searchInputHandler;
  mounted() {
    this.name = "select";
    super.mounted();

    this.search = this.el.querySelector("input[type='text'][role='combobox']");
    this.hiddenInput = this.el.querySelector("input[type='hidden']");

    // Search input handler
    // this.search?.addEventListener("input", this.handleSearchInput.bind(this));
    this.popup.addEventListener("click", this.handlePopupClick.bind(this));

    this.#searchInputHandler = this.handleSearchInput.bind(this);

    this.selectDefaultValue();
  }

  updated() {
    super.updated();
    this.selectDefaultValue();
  }

  selectDefaultValue() {
    const defaultValue = this.el.dataset.value;
    if (defaultValue) {
      const defaultItem = Array.from(this.items).find(
        (item) => item.dataset.value === defaultValue,
      );
      if (defaultItem) {
        this.selectItem(defaultItem);
      }
    }
  }

  selectItem(itemEl) {
    if (this.hiddenInput) {
      if (itemEl.dataset.value) {
        this.hiddenInput.value = itemEl.dataset.value;
        this.hiddenInput.dispatchEvent(new Event("change", { bubbles: true }));
      }
    }
    this.updatePlaceholder();
    this.closePopover();
  }

  updatePlaceholder() {
    const items = Array.from(this.items).find(
      (item) => item.dataset.value === this.hiddenInput.value,
    );
    this.placeholder = items ? items.textContent : "";

    const label = this.el.querySelector(`[data-maui="selected-label"]`);
    if (label) {
      label.textContent = items ? items.textContent : "";
    }
  }

  handlePopupClick(event) {
    // handle item click
    const item = event.target?.closest("[role='menuitem']");
    if (item && this.popup.contains(item)) {
      this.selectItem(item);
    }
  }

  handleKeyEnter(event) {
    event.preventDefault();
    if (this.currentIndex >= 0) {
      const visibleItems = Array.from(this.items).filter(
        (item) => item.getAttribute("aria-hidden") !== "true",
      );
      const currentItem = visibleItems[this.currentIndex];
      if (currentItem) {
        this.selectItem(currentItem);
      }
    }
  }

  handleSearchInput(event) {
    // Prevent liveview form trigger phx-change
    // event.preventDefault();
    event.stopPropagation();

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

  clearSearch() {
    this.search.value = "";
    this.items.forEach((item) => {
      item.removeAttribute("aria-hidden");
    });
  }

  // @override
  onPopupClosed() {
    super.onPopupClosed();
    if (this.search) {
      this.clearSearch();
    }
  }

  // @override
  openPopover() {
    super.openPopover();

    if (this.search) {
      this.search.focus();
      this.search.addEventListener("input", this.#searchInputHandler);
    }
  }
  // @override
  closePopover() {
    super.closePopover();
    if (this.search) {
      this.search.removeEventListener("input", this.#searchInputHandler);
    }
  }
}
