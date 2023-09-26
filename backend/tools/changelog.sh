#!/usr/bin/bash

function writeToChangelog() {
    echo $1 >> "CHANGELOG.md"
}

function getCardName() {
    sed -E "s/([a-z]+\/)//g" <<< "$1" | sed -E "s/\/.*//g"
}

function getBranchName() {
    sed -E "s/(.*Merged in )//g" <<< "$1" | sed -E "s/ .*//g"
}

function getPullRequestNumber() {
    sed -E "s/(.*#)//g" <<< "$1" | sed -E "s/(\))//g"
}

if [[ -f "CHANGELOG.md" ]]; then rm -f "CHANGELOG.md"; fi
touch "CHANGELOG.md"

writeToChangelog "# Changelog"
writeToChangelog ""

currentBranch="$(git branch --show-current)"
if [[ "$currentBranch" == "release"* ]]; then
    releaseTag="${currentBranch//release\//}"
    writeToChangelog "## Release - $releaseTag"
else
    writeToChangelog "## Unreleased"
fi

merges="$(git log --oneline --grep='Merged in')"
while IFS= read -r line; do
    branch="$(getBranchName "$line")"
    cardName="$(getCardName "$branch")"

    if [[ $branch == "release"* ]]; then
        releaseTag="${branch//release\//}"
        writeToChangelog ""
        writeToChangelog "## Release - $releaseTag"
        continue
    fi

    pullRequestNumber="$(getPullRequestNumber "$line")"

    changelogLine="- [$cardName](https://study-projects.atlassian.net/browse/$cardName)"
    changelogLine+=" - [$branch](https://bitbucket.org/pedrobneto/firebase-functions/pull-requests/$pullRequestNumber)"
    writeToChangelog "$changelogLine"
done <<<"${merges[@]}"

echo "Changelog created"
echo ""
