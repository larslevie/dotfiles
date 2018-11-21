function fish_prompt
  set -l last_command_status $status

  if test -n "$SSH_CONNECTION"
    printf '%s ' $HOSTNAME
  end

  if test $last_command_status -eq 0
    set_color green
  else
    set_color red
  end
  
  printf "⊨"
  set_color normal
  printf " "

  if git_is_repo
    set -l ahead    "↑"
    set -l behind   "↓"
    set -l diverged "⥄ "
    set -l dirty    "⨯"
    set -l none     "◦"

    echo -n -s "[ " $repository_color (git_branch_name) $normal_color " "

    if git_is_touched
      set_color red
      echo -n -s $dirty
    else
      set_color yellow
      echo -n -s (git_ahead $ahead $behind $diverged '')
      set_color green
      echo -n -s (git_ahead '' '' '' $none)
    end
      set_color normal
      echo -n -s " ] "
  end
end
