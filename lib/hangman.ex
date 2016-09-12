defmodule Hangman do
  use GenStateMachine

  # Client

  def start_link(word, letters \\ []) do
    GenStateMachine.start_link(Hangman, {:start, %{word: word, letters: letters}})
  end

  def get_puzzle(pid) do
    GenStateMachine.call(pid, :get_puzzle)
  end

  def get_hangman(pid) do
    GenStateMachine.call(pid, :get_hangman)
  end

  def guess(pid, letter) do
    GenStateMachine.cast(pid, {:guess, letter})
  end

  # Server

  def handle_event(:cast, {:guess, letter}, state, data = %{word: word, letters: letters}) do
    # TODO: Skip if letter already guessed

    data = %{data | letters: letters ++ [letter]}

    if String.contains?(word, letter) do
      # success, add valuable letter
      {:next_state, state, data}
    else
      # failure, add to hangman
      {:next_state, advance(state), data}
    end
  end

  def handle_event({:call, from}, :get_puzzle, state, data = %{word: word, letters: letters}) do
    hidden_letters = Enum.map(String.graphemes(word), fn letter ->
      if Enum.member?(letters, letter) do
        letter
      else
        "_"
      end
    end)
    puzzle = Enum.join(hidden_letters, " ")

    {:next_state, state, data, [{:reply, from, puzzle}]}
  end

  def handle_event({:call, from}, :get_hangman, state, data) do
    hangman = case state do
      :start -> ""
      :finish -> "Hangman X-("
      {:playing, gallows} -> gallows
    end

    {:next_state, state, data, [{:reply, from, hangman}]}
  end

  def handle_event(event_type, event_content, state, data) do
    # Call the default implementation from GenStateMachine
    super(event_type, event_content, state, data)
  end

  defp advance(:start) do
    {:playing, "h"}
  end
  defp advance({:playing, "hangma"}) do
    :finish
  end
  defp advance({:playing, gallows}) do
    {:playing, String.slice("hangman", 0, String.length(gallows)+1)}
  end
end
