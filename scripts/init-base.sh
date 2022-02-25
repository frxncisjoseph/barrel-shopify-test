#!/bin/bash

####################################################################
# This initialize script is used for restructuring a vanilla Shopify
# theme from an existing `dist` folder into base-friendly `src`
# folder structure.
#
# Assumptions:
# 1. Note that this will empty your current `src` folder
# 2. `dist` folder should already exist and contain all files,
#   usually pulled from `theme download`
# 3. After running this script, the `dist` folder should be hollowed
#   out, except for the config.yml and theme/lock file. You will need
#   to use your own judgment to move the remaining files into their
#   proper place
# 4. Make sure there's build mechanism in place to move files from
#   ./src/assets/legacy to /dist/assets to ensure backward
#   compatibility
#

IMG_EXTENSIONS=(jpg jpeg gif png)
FONT_EXTENSIONS=(eot svg ttf otf woff)
LEGACY_JS_DEST="./src/assets/legacy/js"
LEGACY_CSS_DEST="./src/assets/legacy/css"
LEGACY_MISC_DEST="./src/assets/legacy/misc"

# Only run this at the root path of the Shopify project
if [ ! -d .git ]; then
  printf "Need to run this at the root path of the project"
  exit 1
fi

# Remove all existing files in src
rm -rf ./src

# Create basic folder structure
mkdir -p ./src/assets/images
mkdir -p ./src/assets/fonts
mkdir -p ./src/assets/css
mkdir -p ./src/assets/js

mkdir -p ./src/config/lib

mkdir -p ./src/functions

# Copy files and folders
if [ -d ./dist/locales ]; then
    mv ./dist/locales ./src/locales
fi

if [ -d ./dist/layout ]; then
    mv ./dist/layout  ./src/layout
fi

if [ -d ./dist/templates ]; then
    mv ./dist/templates ./src/templates
fi

if [ -d ./dist/sections ]; then
    mv ./dist/sections ./src/sections
fi

if [ -f ./dist/config/settings_schema.json ];then
    mv ./dist/config/settings_schema.json  ./src/config/
fi

if [ -f ./dist/config/settings_data.json ]; then
    mv ./dist/config/settings_data.json  ./src/config
fi

# Move images over to src
for ext in ${IMG_EXTENSIONS[@]}; do
    for image in ./dist/assets/*.${ext}; do
        [ -f "$image" ] || break
        mv ${image} ./src/assets/images
    done
done

# Move fonts over to src
for font in ./dist/assets/*.woff; do
    [ -f "$font" ] || break
    filename="${font%.*}"
    for ext in ${FONT_EXTENSIONS[@]}; do
        filename_ext="${filename}.${ext}"
        [ -f "$filename_ext" ] || continue
        mv ${filename_ext} ./src/assets/fonts
    done
done

# Now that all font-related files are out of the way, move svg over to images
for vector in ./dist/assets/*.svg; do
    [ -f "$vector" ] || break
    mv ${vector} ./src/assets/images
done

# Move scripts over
mkdir -p ${LEGACY_JS_DEST}
find ./dist/assets -type f \( -name "*.js" -or -name "*.js.liquid" \) -exec mv {} ${LEGACY_JS_DEST}/ \;

# Move styles over
mkdir -p ${LEGACY_CSS_DEST}
find ./dist/assets -type f \( -name "*.css" -or -name "*.css.liquid" -or -name "*.scss.liquid" -or -name "*.scss" \) -exec mv {} ${LEGACY_CSS_DEST}/ \;

# Move everything else, most likely files that apps created
if [ ! -z "$(ls -A ./dist/assets)" ]; then
    mkdir -p ${LEGACY_MISC_DEST}
    mv ./dist/assets/* ${LEGACY_MISC_DEST}
fi

# Put all snippets into relative folders in modules
for snippet in ./dist/snippets/*; do
    basename="$(basename ${snippet})"
    module_dir="./src/modules/${basename%.*}"
    mkdir -p ${module_dir}
    mv ${snippet} ${module_dir}
done
