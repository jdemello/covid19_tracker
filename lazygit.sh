function lazygit() {
  git add .
  git commit -a -m "$1"
  git push origin https://github.com/jdemello/covid19_tracker.git
}

lazygit "data update"