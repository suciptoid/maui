defmodule AppWeb.Live.DemoSelect do
  use AppWeb, :live_view
  use Maui

  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(count: 0, results: %{"hello" => "world"})
     |> assign(:form, to_form(%{"select" => "event"}))}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("incr", _, socket) do
    {:noreply, socket |> assign(count: socket.assigns.count + 1)}
  end

  def handle_event("validate", params, socket) do
    select = Map.get(params, "select-comp", "")
    {:noreply, socket |> assign(form: to_form(%{params | "select" => select}), results: params)}
  end

  def handle_event("submit", params, socket) do
    dbg(params)
    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.docs flash={@flash} live_action={@live_action}>
      <.form
        :let={f}
        for={@form}
        phx-change="validate"
        phx-submit="submit"
        class="grid grid-cols-2 gap-2"
      >
        <.select label="Select Food" id="select-dmeo" name="select-comp">
          <.select_item value="makan-value">
            <.icon name="hero-arrow-path" class="size-4" /> Makan
          </.select_item>
          <.select_item value="makan-value-2">
            <.icon name="hero-check" class="size-4" /> Makan Dua
          </.select_item>
        </.select>
        <.select label="Select Drink" id="select-dmeo-2" name="select-comp-2">
          <.select_item value="minum-value">
            <.icon name="hero-arrow-path" class="size-4" /> Minum
          </.select_item>
          <.select_item value="minum-value-2">
            <.icon name="hero-check" class="size-4" /> Minum Dua
          </.select_item>
        </.select>
        <.select
        label="Select with options"
          id="with-options"
          name="with-options"
          placeholder="Select with @options"
          searchable={true}
          options={["Option 1", "Option 2"]}
        />
        <.select
        label="Select with default"
          id="with-default-value"
          name="with-default-value"
          placeholder="Select with default"
          searchable={true}
          value="Option 3"
          options={["Option 1", "Option 2", "Option 3"]}
        />
        <.select
        label="Select from strings"
          id="with-options-strings"
          name="with-options-strings"
          placeholder="Select from strings"
          options={["Option A", "Option B", "Option C"]}
        />
        <.select
        label="Select from tuples"
          id="with-options-tuples"
          name="with-options-tuples"
          placeholder="Select from tuples"
          options={[{"val1", "Value One"}, {"val2", "Value Two"}]}
        />
        <.select
          id="with-options-groups"
          label="Select grouped"
          name="with-options-groups"
          placeholder="Select grouped"
          value="carrot"
          searchable={true}
          class="w-full"
          options={[
            {"Fruits", ["Apple", "Banana"]},
            {"Vegetables", [{"carrot", "Carrot"}, {"lettuce", "Lettuce"}]}
          ]}
        />
        <.select
          id="with-options-ints"
          label="Select numbers"
          name="with-options-ints"
          placeholder="Select numbers"
          value="1"
          class="w-full"
          options={[1, 2, 3]}
        />
        <.input type="text" field={f[:select]} />
      </.form>
      <code class="whitespace-pre-line font-mono">
        {inspect(@results)}
      </code>
    </Layouts.docs>
    """
  end
end
