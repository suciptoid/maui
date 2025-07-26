import Popover from "./popover";
export default class Select extends Popover {
  mounted() {
    this.name = "select";
    super.mounted();

    this.log("mounted");
  }
}
