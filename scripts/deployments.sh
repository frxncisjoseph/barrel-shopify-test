#!/usr/bin/env bash

# Get helper functions
source $(dirname $0)/functions.sh

# Setup variables
CONFIG='config.yml'
LIVE_THEME_NAME="LIVE - v$(npm version | grep -o  '[0-9.]\+' | head -n1) $(date +%Y/%m/%d,%H:%M:%S)"
CURRENT_BRANCH="$(get_current_brach)"
IFS=','

# These variable will come out of config.yml parsing
development_api_key="$SHOPIFY_API_KEY"
development_password="$SHOPIFY_PASSWORD"
development_store="$SHOPIFY_STORE"
production_theme_id="$SHOPIFY_PRODUCTION_THEME"

echo "Checking to see if NPM is available.."
if [ ! -x "$(command -v npm)" ]; then
  echo "npm must be available"
  exit 1;
fi

npm set progress=false

echo -e "\nInstalling node modules..\n"
if [ ! -d "node_modules" ]; then
  npm i --quiet
fi

# Makes sure that themekit is installed
echo -e "\nDownloading themekit..\n"
download_themekit

# Create an empty yaml file if doesn't exit
if ! [ -f "$CONFIG" ]; then
  cp "$(pwd)/config-example.yml" "$CONFIG"
fi

# Parse the config.yml file
if ! [ "$GITLAB_CI" = true ]; then
  eval $(parse_yaml "$CONFIG")
fi

# Get all active themes
ALL_THEMES_JSON="$(
  request \
    "$development_api_key" \
    "$development_password" \
    "$development_store/admin/themes.json" \
    "GET"
)"

# Parse out JSON and turn it into a nice clean string
# with following format: <id>:<role>,<id>:<role>
ALL_THEMES_STRING=$(get_all_themes_from_json "$ALL_THEMES_JSON")

if [ "$CURRENT_BRANCH" = 'master' ]; then
  THEME_TO_DEPLOY_TO="$production_theme_id"
else
  THEME_TO_DEPLOY_TO=$(get_existing_theme "$ALL_THEMES_JSON")
fi

if ! [ "$THEME_TO_DEPLOY_TO" ]; then
  echo -e "\nNo theme found!!"
fi

# Build current theme
npm run build

# Deploy current theme
upload_theme "$THEME_TO_DEPLOY_TO" "dist"

#If Master, change name
if [ "$CURRENT_BRANCH" = 'master' ]; then
  NEW_THEME_JSON="$(
    request \
      "$development_api_key" \
      "$development_password" \
      "$development_store/admin/themes/$THEME_TO_DEPLOY_TO.json" \
      "PUT" \
      "{\"theme\": {\"name\": \"$LIVE_THEME_NAME\"} }"
  )"
fi

echo -e "\nAll done!!"
