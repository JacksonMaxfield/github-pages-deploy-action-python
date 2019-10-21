# The dockerfile for this image can be found at _docker/Dockerfile
# It lives separately from this Dockerfile because it has a lot of dependencies already installed that
# are common for python projects to need and use. Having it separate and live on dockerhub means the
# time to run this action is drastically reduced.
FROM jacksonmaxfield/python-git-commit-action

# GH Actions labels
LABEL "com.github.actions.name"="Deploy to GitHub Pages"
LABEL "com.github.actions.description"="This action will handle the building and deploying process of your project to GitHub Pages."
LABEL "com.github.actions.icon"="git-commit"
LABEL "com.github.actions.color"="orange"

LABEL "repository"="http://github.com/JacksonMaxfield/gh-pages-github-action-python"
LABEL "homepage"="http://github.com/JacksonMaxfield/gh-pages-github-action-python"
LABEL "maintainer"="Jackson Maxfield Brown <jmaxfieldbrown@gmail.com>"

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
