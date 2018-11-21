function fish_right_prompt
  set_color blue
  __kube_prompt
  set_color $fish_color_cwd

  set_color red
  printf ' %s ' (prompt_pwd)
  date "+%H:%M:%S"
  set_color normal
end