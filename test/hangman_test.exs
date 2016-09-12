defmodule HangmanTest do
  use ExUnit.Case
  doctest Hangman

  describe "for a normal game" do
    setup do
      {:ok, game} = Hangman.start_link("pumpkin", ["p"])

      %{game: game}
    end

    test "initial state", %{game: game} do
      assert Hangman.get_puzzle(game) == "p _ _ p _ _ _"
      assert Hangman.get_hangman(game) == ""
    end

    test "after a valid guess", %{game: game} do
      Hangman.guess(game, "k")

      assert Hangman.get_puzzle(game) == "p _ _ p k _ _"
      assert Hangman.get_hangman(game) == ""
    end

    test "after a bad guess", %{game: game} do
      Hangman.guess(game, "z")

      assert Hangman.get_puzzle(game) == "p _ _ p _ _ _"
      assert Hangman.get_hangman(game) == "h"
    end
  end

  describe "for a terminal game" do
    setup do
      {:ok, game} = Hangman.start_link("pumpkin")
      Enum.each(["h","a","nn","g","mm","a"], fn letter ->
        Hangman.guess(game, letter)
      end)

      %{game: game}
    end

    test "initial state", %{game: game} do
      assert Hangman.get_puzzle(game) == "_ _ _ _ _ _ _"
      assert Hangman.get_hangman(game) == "hangma"
    end

    test "after a valid guess", %{game: game} do
      Hangman.guess(game, "p")

      assert Hangman.get_puzzle(game) == "p _ _ p _ _ _"
      assert Hangman.get_hangman(game) == "hangma"
    end

    test "after a bad guess", %{game: game} do
      Hangman.guess(game, "z")

      assert Hangman.get_puzzle(game) == "_ _ _ _ _ _ _"
      assert Hangman.get_hangman(game) == "Hangman X-("
    end
  end
end
