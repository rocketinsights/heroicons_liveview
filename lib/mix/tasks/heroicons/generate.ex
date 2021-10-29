defmodule Mix.Tasks.Heroicons.Generate do
  use Mix.Task

  @shortdoc "Convert source SVG files into Phoenix LiveView components"
  def run(_) do
    Enum.each(["outline", "solid"], &loop_directory/1)

    Mix.Task.run("format")
  end

  defp loop_directory(folder) do
    src_path = "./priv/heroicons/src/#{folder}/"
    dest_path = "./lib/heroicons/#{String.downcase(folder)}.ex"
    module_name = "Heroicons.#{String.capitalize(folder)}"

    File.rm(dest_path)

    content =
      src_path
      |> File.ls!()
      |> Enum.filter(&(Path.extname(&1) == ".svg"))
      |> Enum.map(&build_component(folder, src_path, &1))
      |> build_module(module_name)

    File.write!(dest_path, content)
  end

  defp build_component(folder, src_path, filename) do
    svg_filepath = Path.join(src_path, filename)
    docs = "#{folder}/#{filename}"

    svg_content =
      File.read!(svg_filepath)
      |> String.trim()
      |> String.replace(~r/<svg /, "<svg class={@class} ")

    filename |> function_name() |> build_function(docs, svg_content)
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
      use Phoenix.Component

      #{Enum.join(functions, "\n")}
    end
    """
  end

  defp build_function(function_name, docs, svg) do
    """
    @doc "#{docs}"
    def #{function_name}(assigns) do
      ~H\"\"\"
      #{svg}
      \"\"\"
    end
    """
  end
end
