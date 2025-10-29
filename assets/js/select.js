import Popover from "./popover";
export default class Select extends Popover {
  mounted() {
    this.name = "select";
    super.mounted();

    this.search = this.el.querySelector("input[type='text'][role='combobox']");

    // Search input handler
    this.search?.addEventListener("input", this.handleSearchInput.bind(this));
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
}
