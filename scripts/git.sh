#!/bin/bash
#
# The $COMMITS is always compared with master
#
# The $PATTERN should contain one pattern per line, e.g:
# line, e.g:
#
# ^.*@domain.com$
# ^allowed@example.com$
#

COMMITS=$(git --no-pager log master.. --pretty="%h %ae" --no-merges)
PATTERN="^.*@barrelny.com$
^.*@barreldev.com$"

# Terminal colors
DEFAULT=$(tput setaf 7 -T xterm)
RED=$(tput setaf 1 -T xterm)
GREEN=$(tput setaf 2 -T xterm)
YELLOW=$(tput setaf 3 -T xterm)
BLUE=$(tput setaf 4 -T xterm)
OK="${GREEN}PASS${DEFAULT}"
FAIL="${RED}FAIL${DEFAULT}"

if [[ -z "$COMMITS" ]]; then
  echo "$FAIL"
  echo "${YELLOW}No commits, this is not normal, exiting...${DEFAULT}"
  exit 1
fi

for COMMIT in "$COMMITS"; do
  data=( $COMMIT )
  sha=${data[0]}
  email=${data[1]}

  echo "Validating user email ${YELLOW}$email${DEFAULT}, commit (${YELLOW}$sha${DEFAULT})..."
  if [[ ! $sha ]]; then
    continue
  fi
  grep -q "$PATTERN" <<< "$email"
  MATCH="$?"
  if [ "$MATCH" -ne 0 ]; then
    echo "Email address ${YELLOW}$email${DEFAULT} in commit ${YELLOW}$sha${DEFAULT} does not match the expected pattern."
    echo "$FAIL"
    exit 1
  fi

done

echo "$OK"
exit
