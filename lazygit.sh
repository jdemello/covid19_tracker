function lazygit() {
  git add .
  git commit -a -m "$1"
  git push origin git@github.com:jdemello/covid19_tracker.git
}

lazygit "data update"