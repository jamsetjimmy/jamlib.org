#!/usr/bin/env bash
# deploys jekyll to github gh-pages branch

buildtime=`date +'%s'`
branchname=`git rev-parse --abbrev-ref HEAD`
baseurl=''
baseurl_set=false
cname=''
name=''
remote='origin'

printUsage () {
  echo -e "\nUsage: ./deploy-gh-pages.sh [options]\n"
  echo -e "  -h, --help: display usage"
  echo -e "  -n, --name: github repository name"
  echo -e "  -b, --baseurl: change _config.yml baseurl from default of --name"
  echo -e "  -c, --cname: include CNAME specifying domain name"
  echo -e "  -r, --remote: change git remote from default 'origin'\n"
}

setOption () {
  case $1 in
    -r|--remote) remote="$2";;
    -c|--cname) cname="$2";;
    -n|--name) name="$2";;
    -b|--baseurl)
      baseurl_set=true
      # regexp format
      if [[ "$2" =~ ^\/ ]]; then
        # started with /: prepend \
        baseurl="\\$2"
      elif [ "$2" == "" ]; then
        baseurl="" # allow empty string
      else
        # did not start with /: prepend \/
        baseurl="\\/$2"
      fi
      ;;
  esac
}

createGhPagesBranch () {
  git checkout --orphan gh-pages
  git rm --cached -r .
  git add .gitignore
  git clean -f -d
  git commit -m 'initial gh-pages branch'
}

buildJekyll () {
  # replace baseurl in _config.yml
  sed -e "s/baseurl: \"\\/$name\"/baseurl: \"$baseurl\"/" _config.yml > "/tmp/_config.yml-$buildtime"
  mv -f "/tmp/_config.yml-$buildtime" _config.yml

  # include versioninfo.txt
  commitID=`git log --format="%H" -n 1`
  echo -e "Branch: $branchname\nCommit: $commitID" > versioninfo.txt

  # build, then forget build modifications
  bundle exec jekyll build
  rm versioninfo.txt
  git reset --hard
}

# MAIN PROCESS

# print usage for -h or --help
if [ "$1" == "-h" -o "$1" == "--help" ]; then
  printUsage; exit 0
fi

# parse options
args=( "$@" )
for i in "${!args[@]}"; do
  if [[ ${args[$i]} =~ ^-- ]] && [[ ${args[$i]} =~ = ]]; then
    # --option=value
    setOption "${args[$i]%=*}" "${args[$i]#*=}"
  elif [[ ${args[$i]} =~ ^- ]]; then
    # -o value
    x=$((i+1))
    setOption "${args[$i]}" "${args[$x]}"
  fi
done

# ensure repo name is set
if [ "$name" == "" ]; then
  echo -e "Error: Must specify repo name with --name. Exiting.\n"
  exit 1
fi

# check for pending changes
if [ "$(git status --porcelain | sed -n '/[:alnum:]*/p')" != "" ]; then
  echo -e "Error: Please commit or stash all changes before deploying. Exiting.\n"
  exit 1
fi

# default baseurl is repo name
if [ $baseurl_set == false ]; then
  baseurl="\\/$name"
fi

buildJekyll

# copy build to tmp
mkdir /tmp/_site_$buildtime
cp -r _site/* /tmp/_site_$buildtime/

# checkout or create gh-pages branch
if [ "$(git checkout gh-pages 2>&1 | sed -n '/^error\: pathspec/p')" == "" ]; then
  git checkout gh-pages
else
  echo -e "Branch 'gh-pages' not found. Creating...\n"
  createGhPagesBranch
fi

# remove old build; copy new
git ls-files -z | xargs -0 rm -f
git checkout .gitignore
cp -r /tmp/_site_$buildtime/* $PWD/

# include CNAME
if [ "$cname" != "" ]; then
  echo -e "$cname" > CNAME
fi

# add, commit, deploy branch (only if changes)
if [ "$(git status | sed -n '/^nothing to commit/p')" == "" ]; then
  git add .
  git commit -m 'new gh-pages build'
  git push -f "$remote" gh-pages
fi

# cleanup
git checkout "$branchname"
rm -r /tmp/_site_$buildtime

echo -e "\ndeploy-gh-pages success.\n"