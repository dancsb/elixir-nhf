defmodule Nhf1 do

  @moduledoc """
  Sátrak
  @author "Dancs Balázs <dancs.balazs01@gmail.com>"
  @date   "2023-10-12"
  ...
  """

  @type row   :: integer    # sor száma (1-től n-ig)
  @type col   :: integer    # oszlop száma (1-től m-ig)
  @type field :: {row, col} # egy parcella koordinátái

  @type tents_count_rows :: [integer] # a sátrak száma soronként
  @type tents_count_cols :: [integer] # a sátrak száma oszloponként

  @type trees       :: [field]   # a fákat tartalmazó parcellák koordinátái lexikálisan rendezve
  @type puzzle_desc :: {tents_count_rows, tents_count_cols, trees} # a feladványleíró hármas

  @type dir       :: :n | :e | :s | :w # a sátorpozíciók iránya: north, east, south, west
  @type tent_dirs :: [dir]             # a sátorpozíciók irányának listája a fákhoz képest

  defp check_selection({nx, ny}, selected) do
    !Enum.any?(selected, fn {x, y, _d} -> abs(x - nx) <= 1 and abs(y - ny) <= 1 end)
  end

  defp solve([possible_tents | rest], selected, tents_count_rows, tents_count_cols, solutions) do
    Enum.flat_map(possible_tents, fn {x, y, d} ->
      if Enum.at(tents_count_rows, x - 1) != 0 and Enum.at(tents_count_cols, y - 1) != 0 and check_selection({x, y}, selected) do
        new_tents_count_rows = List.update_at(tents_count_rows, x - 1, &(&1 - 1))
        new_tents_count_cols = List.update_at(tents_count_cols, y - 1, &(&1 - 1))
        solve(rest, [{x, y, d} | selected], new_tents_count_rows, new_tents_count_cols, solutions)
      else
        []
      end
    end)
  end

  defp solve([], selected, tents_count_rows, tents_count_cols, solutions) do
    if Enum.any?(tents_count_rows, fn x -> x > 0 end) or Enum.any?(tents_count_cols, fn y -> y > 0 end) do
      solutions
    else
      [Enum.map(selected, fn {_x, _y, d} -> d end) |> Enum.reverse() | solutions]
    end
  end

  @spec satrak(pd::puzzle_desc) :: tss::[tent_dirs]
  # tss a pd feladványleíróval megadott feladvány összes megoldásának listája, tetszőleges sorrendben
  def satrak(pd) do
    possible_tents = elem(pd, 2) |> Enum.map(fn {row, col} ->
      xd = if row - 1 > 0 and row - 1 <= length(elem(pd, 0)) and !Enum.member?(elem(pd, 2), {row - 1, col}) do [{row - 1, col, :n}] else [] end
      xd = if col + 1 > 0 and col + 1 <= length(elem(pd, 1)) and !Enum.member?(elem(pd, 2), {row, col + 1}) do [{row, col + 1, :e} | xd] else xd end
      xd = if row + 1 > 0 and row + 1 <= length(elem(pd, 0)) and !Enum.member?(elem(pd, 2), {row + 1, col}) do [{row + 1, col, :s} | xd] else xd end
           if col - 1 > 0 and col - 1 <= length(elem(pd, 1)) and !Enum.member?(elem(pd, 2), {row, col - 1}) do [{row, col - 1, :w} | xd] else xd end
    end)
    solve(possible_tents, [], elem(pd, 0), elem(pd, 1), [])
  end

end
