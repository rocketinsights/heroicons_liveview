defmodule Mix.Tasks.Heroicons.Generate do
  use Mix.Task

  @shortdoc "Convert source SVG files into Phoenix LiveView components"
  def run(_) do
    Enum.each(
      [{"24/outline", "outline"}, {"24/solid", "solid"}, {"20/solid", "mini"}],
      &loop_directory/1
    )

    Mix.Task.run("format")
  end

  defp loop_directory({folder, mod_name}) do
    src_path = "./priv/heroicons/src/#{folder}/"
    dest_path = "./lib/heroicons/#{String.downcase(mod_name)}.ex"
    module_name = "Heroicons.#{String.capitalize(mod_name)}"

    File.rm(dest_path)

    content =
      src_path
      |> File.ls!()
      |> Enum.filter(&(Path.extname(&1) == ".svg"))
      |> Enum.map(&build_component(mod_name, src_path, &1))
      |> build_module(module_name)

    File.write!(dest_path, content)
  end

  defp build_component(folder, src_path, filename) do
    svg_filepath = Path.join(src_path, filename)
    docs = "#{folder}/#{filename}"

    svg_content = File.read!(svg_filepath) |> String.trim()
    [{_, attributes, children} | _] = Floki.parse_document!(svg_content)
    attributes = Map.new(attributes)

    assigns = %{
      class: Map.get(attributes, "class", ""),
      fill: Map.get(attributes, "fill", "none"),
      stroke: Map.get(attributes, "stroke", "none")
    }

    attributes =
      attributes
      |> Map.delete("class")
      |> Map.delete("fill")
      |> Map.delete("stroke")
      |> Enum.map(fn {k, v} -> "#{k}=\"#{v}\"" end)
      |> Enum.join(" ")

    svg_content = """
    <svg class={@class} fill={@fill} stroke={@stroke} #{attributes}>
      #{Floki.raw_html(children)}
    </svg>
    """

    filename |> function_name() |> build_function(docs, svg_content, assigns)
  end

  defp function_name(current_filename) do
    current_filename
    |> Path.basename(".svg")
    |> String.split("-")
    |> Enum.join("_")
  end

  defp build_module(functions, module_name) do
    """
    defmodule #{module_name} do
      @moduledoc \"\"\"
      Icon name can be the function or passed in as a icon eg.
      <#{module_name}.search class="w-6 h-6" />
      <#{module_name}.render icon={:search} class="w-6 h-6" />

      <#{module_name}.search class="w-6 h-6" />
      <#{module_name}.render icon={:search} class="w-6 h-6" />
      \"\"\"

      use Phoenix.Component

      def render(%{icon: icon} = assigns) when is_bitstring(icon) do
        # load the function names into the atom table
        __MODULE__.module_info(:functions) |> Keyword.keys()
        icon_atom = icon |> String.replace("-", "_") |> String.downcase() |> String.to_existing_atom()

        apply(__MODULE__, icon_atom, [assigns])
      end

      def render(%{icon: icon} = assigns), do: apply(__MODULE__, icon, [assigns])

      #{Enum.join(functions, "\n")}
    end
    """
  end

  defp build_function(function_name, docs, svg, assigns) do
    """
    @doc "#{docs}"
    def #{function_name}(assigns) do
      assigns =
        assigns
        |> assign_new(:class, fn -> \"#{Map.get(assigns, :class)}\" end)
        |> assign_new(:fill, fn -> \"#{Map.get(assigns, :fill)}\" end)
        |> assign_new(:stroke, fn -> \"#{Map.get(assigns, :stroke)}\" end)

      ~H\"\"\"
      #{svg}\
      \"\"\"
    end
    """
  end
end
