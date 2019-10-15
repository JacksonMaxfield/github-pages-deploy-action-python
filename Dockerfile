FROM python:latest

LABEL "com.github.actions.name"="Deploy to GitHub Pages"
LABEL "com.github.actions.description"="This action will handle the building and deploying process of your project to GitHub Pages."
LABEL "com.github.actions.icon"="git-commit"
LABEL "com.github.actions.color"="orange"

LABEL "repository"="http://github.com/JacksonMaxfield/gh-pages-github-action-python"
LABEL "homepage"="http://github.com/JacksonMaxfield/gh-pages-github-action-python"
LABEL "maintainer"="Jackson Maxfield Brown <jmaxfieldbrown@gmail.com>"

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
