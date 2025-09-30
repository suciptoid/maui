defmodule Maui.Input do
  use Phoenix.Component

  attr :id, :any, default: nil
  attr :class, :string, default: ""
  attr :type, :string, default: "text"
  attr :label, :string, default: nil

  attr :field, Phoenix.HTML.FormField,
    default: nil,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
              multiple pattern placeholder readonly required rows size step name value)

  def input(%{label: label} = assigns) when label not in ["", nil] do
    assigns = map_field(assigns)

    ~H"""
    <div class="grid w-full max-w-sm items-center gap-3">
      <.label for={@id}>{@label}</.label>
      <.input id={@id} class={@class} type={@type} field={@field} {@rest} />
    </div>
    """
  end

  def input(assigns) do
    assigns = map_field(assigns)

    ~H"""
    <input
      id={@id}
      type={@type}
      class={[
        "file:text-foreground placeholder:text-muted-foreground selection:bg-primary selection:text-primary-foreground dark:bg-input/30 border-input h-9 w-full min-w-0 rounded-md border bg-transparent px-3 py-1 text-base shadow-xs transition-[color,box-shadow] outline-none file:inline-flex file:h-7 file:border-0 file:bg-transparent file:text-sm file:font-medium disabled:pointer-events-none disabled:cursor-not-allowed disabled:opacity-50 md:text-sm",
        "focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]",
        "aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive",
        @class
      ]}
      {@rest}
    />
    """
  end

  attr :class, :string, default: ""
  attr :rest, :global, include: ~w(for)
  slot :inner_block

  def label(assigns) do
    ~H"""
    <label
      class={[
        "flex items-center gap-2 text-sm leading-none font-medium select-none group-data-[disabled=true]:pointer-events-none group-data-[disabled=true]:opacity-50 peer-disabled:cursor-not-allowed peer-disabled:opacity-50",
        "peer-has-[:disabled]:opacity-50 peer-has-[:disabled]:cursor-not-allowed",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </label>
    """
  end

  attr :id, :any, default: nil
  attr :label, :string, default: nil
  attr :class, :string, default: nil

  attr :field, Phoenix.HTML.FormField,
    default: nil,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :rest, :global,
    include: ~w(accept autocomplete capture cols disabled form list max maxlength min minlength
              multiple pattern placeholder readonly required rows size step checked name value)

  slot :inner_block

  def checkbox(%{label: label} = assigns) when label != nil do
    ~H"""
      <label class="inline-flex items-center cursor-pointer">
        <.checkbox id={@id} class={@class} field={@field} {@rest} />
        <span class="text-sm text-foreground ms-3">
          {@label}
        </span>
      </label>
    """
  end

  def checkbox(assigns) do
    assigns = map_field(assigns)

    ~H"""
    <input
      id={@id}
      type="checkbox"
      class={[
        "relative size-4 shrink-0 appearance-none rounded-[4px] border border-input shadow-xs outline-none cursor-pointer",
        "before:content-[''] before:absolute before:top-0 before:left-[2px] before:w-[calc(100%-2px)] before:h-[calc(100%-2px)] before:bg-current before:opacity-0",
        "before:[clip-path:polygon(28%_100%,28%_85%,50%_85%,50%_15%,65%_15%,65%_100%)] before:rotate-45 before:origin-center",
        "before:transition-all before:duration-100",
        "focus-visible:ring-[3px] focus-visible:ring-ring/50 focus-visible:border-ring",
        "checked:bg-primary checked:text-primary-foreground checked:border-primary",
        "checked:before:opacity-100",
        "disabled:cursor-not-allowed disabled:opacity-50",
        "dark:bg-input/30 dark:checked:bg-primary",
        @class
      ]}
      {@rest}
    />
    """
  end

  attr :id, :any, default: nil
  attr :rest, :global, include: ~w(checked name value)
  attr :class, :string, default: ""

  attr :field, Phoenix.HTML.FormField,
    default: nil,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  def radio(assigns) do
    assigns = map_field(assigns)

    ~H"""
    <input
      id={@id}
      type="radio"
      class={[
        "border-input text-primary focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive dark:bg-input/30 aspect-square size-4 shrink-0 rounded-full border shadow-xs transition-[color,box-shadow] outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50 appearance-none relative after:content-[''] after:absolute after:top-1/2 after:left-1/2 after:size-2 after:-translate-x-1/2 after:-translate-y-1/2 after:rounded-full after:bg-primary after:scale-0 checked:after:scale-100 after:transition-transform",
        @class
      ]}
      {@rest}
    />
    """
  end

  attr :id, :any, default: nil
  attr :class, :string, default: ""
  attr :label, :string, default: nil

  attr :field, Phoenix.HTML.FormField,
    default: nil,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :rest, :global,
    include: ~w(accept  capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step name value)

  def switch(%{label: label} = assigns) when label != nil do
    assigns = map_field(assigns)

    ~H"""
      <label class="inline-flex items-center cursor-pointer">
        <.switch id={@id} class={@class} {@rest} />
        <span class="text-sm text-foreground ms-3">
          {@label}
        </span>
      </label>
    """
  end

  def switch(assigns) do
    assigns = map_field(assigns)

    ~H"""
    <input
      id={@id}
      type="checkbox"
      class={[
        "appearance-none checked:bg-primary bg-input focus-visible:border-ring focus-visible:ring-ring/50 dark:bg-input/80 inline-flex h-[1.15rem] w-8 shrink-0 items-center rounded-full border border-transparent shadow-xs transition-all outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50 relative after:content-[''] after:absolute after:bg-background dark:after:bg-foreground dark:checked:after:bg-primary-foreground after:pointer-events-none after:block after:size-4 after:rounded-full after:ring-0 after:transition-transform checked:after:translate-x-[calc(100%-2px)] after:translate-x-0",
        @class
      ]}
      {@rest}
    />
    """
  end

  @doc """
  """
  attr :id, :any, default: nil
  attr :class, :string, default: ""
  attr :label, :string, default: nil

  attr :field, Phoenix.HTML.FormField,
    default: nil,
    doc: "a form field struct retrieved from the form, for example: @form[:email]"

  attr :rest, :global,
    include: ~w(accept  capture cols disabled form list max maxlength min minlength
                multiple pattern placeholder readonly required rows size step name value)

  def textarea(assigns) do
    assigns =
      map_field(assigns)

    ~H"""
    <textarea
      id={@id}
      class={[
        "border-input placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-ring/50 aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive dark:bg-input/30 flex field-sizing-content min-h-16 w-full rounded-md border bg-transparent px-3 py-2 text-base shadow-xs transition-[color,box-shadow] outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50 md:text-sm",
        @class
      ]}
      {@rest}>{@rest[:value]}</textarea>
    """
  end

  def map_field(%{field: %Phoenix.HTML.FormField{} = field} = assigns) do
    rest =
      assigns
      |> Map.get(:rest, %{})
      |> Map.put(:name, field.name)
      |> then(fn rest ->
        type = Map.get(rest, :type, "text")
        rest |> Map.put(:value, Phoenix.HTML.Form.normalize_value(type, field.value))
      end)

    assigns
    |> assign(:id, assigns.id || field.id)
    |> assign(:field, nil)
    |> assign(:rest, rest)
  end

  def map_field(assigns) do
    assigns
  end

  def generate_id(prefix \\ "input"), do: "#{prefix}_#{System.unique_integer([:positive])}"
end
