defmodule AssignmentWeb.Contexts.UtilityContext do
  @moduledoc false

  alias Ecto.Changeset

  def handle_errors(fun) do
    fn source, args, info ->
      case Absinthe.Resolution.call(fun, source, args, info) do
        {:error, %Changeset{} = changeset} -> format_changeset(changeset)
        val -> val
      end
    end
  end

  def format_changeset(changeset) do
    errors =
      changeset
      |> Changeset.traverse_errors(fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      end)
      |> Enum.map(fn {field, message} ->
        field_name = Inflex.camelize(field, :lower)

        transform_error_message(field_name, message, field)
      end)

    {:error, errors}
  end

  def transform_error_message(field_name, ["is invalid"], field) do
    field = transform_atom(field)
    %{message: "Invalid #{field}", field: field_name}
  end
  def transform_error_message(field_name, message, _), do: %{message: "#{message}", field: field_name}

  defp transform_atom(key) do
    key
    |> atom_to_string()
    |> String.split("_")
    |> Enum.join(" ")
  end

  defp atom_to_string(data) do
    data
    |> Atom.to_string()
  rescue
    _ ->
      data
  end

  def transform_unix_to_date(unix) do
    unix
    |> Timex.from_unix()
    |> Timex.format!("{0M}-{0D}-{0YYYY}")
  end

  def transform_unix_to_datetime(unix) do
    unix
    |> Timex.from_unix()
    |> Timex.format!("{0M}-{0D}-{0YYYY} {h24}:{m}:{s}")
  end

end
