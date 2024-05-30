import { clock } from "lib/variables";
import PanelButton from "../PanelButton";
import options from "options";

const { format, action } = options.bar.date;
const time = Utils.derive([clock, format], (c, f) => c.format(f) || "");

export default () =>
  PanelButton({
    window: "datemenu",
    on_clicked: action.bind(),
    child: Widget.Label({
      class_name: "datelabel",
      justification: "center",
      label: time.bind(),
    }),
  });
