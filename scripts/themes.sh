#!/usr/bin/env bash

# Get helper functions
source $(dirname $0)/functions.sh

# Setup variables
CONFIG='config.yml'
TEMP_DIR='temp'
THEME_NAME="BACKUP - LIVE - $(date +%Y/%m/%d,%H:%M:%S)"
CLEANSE=false
BACKUP_THEMES_KEEP=3
CREATE_STAGING_THEME=false
CURRENT_BRANCH="$(get_current_branch)"
IFS=','

# These variable will come out of config.yml parsing
development_api_key="$SHOPIFY_API_KEY"
development_password="$SHOPIFY_PASSWORD"
development_store="$SHOPIFY_STORE"

for i in "$@"; do
case $i in
    --config=*)
    CONFIG="${i#*=}"
    shift # past argument=value
    ;;
    --temp-dir=*)
    TEMP_DIR="${i#*=}"
    shift # past argument=value
    ;;
    --temp-theme=*)
    THEME_NAME="${i#*=}"
    shift # past argument=value
    ;;
    --cleanse)
    CLEANSE=true
    shift # past argument=value
    ;;
    --stage|--staging)
    CREATE_STAGING_THEME=true
    THEME_NAME="STAGE - $CURRENT_BRANCH"
    shift # past argument=value
    ;;
    *)
	  echo "Unknown option: ${i#*=}"
    # unknown option
    ;;
esac
done

# Print theme name
echo -e "\nTheme name: $THEME_NAME..\n"

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

# Turn ALL_THEMES_STRING into an array
IFS=','
read -r -a THEMES <<< "$ALL_THEMES_STRING"

# Attempt to find existing theme to upload to
EXISTING_THEME=$(get_existing_theme "$ALL_THEMES_JSON")

# Get the id of the published theme and download it
if ! [ "$EXISTING_THEME" ]; then
  for element in "${THEMES[@]}"
  do
    if [[ $element = *"main"* ]]; then
      download_main_theme "${element%%:*}"
    fi
  done
fi

# IF -cleanse flag is passed, delete oldest backup files, keeping some
if [ "$CLEANSE" = true ]; then

  # Parse existing JSON to find themes to delete
  THEMES_TO_DELETE_STRING=$(get_themes_to_delete_from_json "$ALL_THEMES_JSON")

  # Turn into an array
  IFS=','
  read -r -a THEMES_TO_DELETE <<< "$THEMES_TO_DELETE_STRING"

  for element in "${THEMES_TO_DELETE[@]}"
  do
    delete_theme "$element"
  done
fi

# Get all themes again
ALL_THEMES_STRING=$(get_all_themes_from_json "$ALL_THEMES_JSON")

# Turn into an array
read -r -a THEMES <<< "$ALL_THEMES_STRING"

if ! [[ "${#THEMES[@]}" < 20 ]] && ! [ "$EXISTING_THEME" ]; then
  echo -e "\nWARNING: Store is at it's 20 theme limit\n"
  exit 1;
fi

if [ "$CREATE_STAGING_THEME" = false ] || ! [ "$EXISTING_THEME" ]; then
  # Create new empty theme
  echo -e "\nCreating new empty theme: $THEME_NAME..\n"
  NEW_THEME_JSON="$(
    request \
      "$development_api_key" \
      "$development_password" \
      "$development_store/admin/themes.json" \
      "POST" \
      "{\"theme\": {\"name\": \"$THEME_NAME\"} }"
  )"
  NEW_THEME_ID=$(get_theme_id "$NEW_THEME_JSON")
  upload_theme "$NEW_THEME_ID" "$TEMP_DIR"
fi

echo -e "\nAll done!!"
