#!/bin/bash
set -e
set -o pipefail

# This is populated by our secret from the Workflow file.
if [[ -z "$GITHUB_TOKEN" ]]; then
	echo "Set the GITHUB_TOKEN env variable."
	exit 1
fi

# This one is populated by GitHub for free :)
if [[ -z "$GITHUB_REPOSITORY" ]]; then
	echo "Set the GITHUB_REPOSITORY env variable."
	exit 1
fi

URI=https://api.github.com
API_VERSION=v3
API_HEADER="Accept: application/vnd.github.${API_VERSION}+json"
AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"

main(){
    # In every runtime environment for an Action you have the GITHUB_EVENT_PATH 
    # populated. This file holds the JSON data for the event that was triggered.
    # From that we can get the status of the pull request and if it was merged.
    # In this case we only care if it was closed and it was merged.

    cat $GITHUB_EVENT_PATH

	action=$(jq --raw-output .action "$GITHUB_EVENT_PATH")
	pr_url=$(jq --raw-output .pull_request.url "$GITHUB_EVENT_PATH")

	echo "DEBUG -> action: $action merged: $pr_url"

    if [[ "$action" == "dismissed" ]] ; then
      echo "DEBUG: do dismissed later"
    fi

    

	if [[ "$action" == "submitted" ]] ; then
        ref=$(jq --raw-output .pull_request.head.ref "$GITHUB_EVENT_PATH")
		owner=$(jq --raw-output .pull_request.head.repo.owner.login "$GITHUB_EVENT_PATH")
		repo=$(jq --raw-output .pull_request.head.repo.name "$GITHUB_EVENT_PATH")
        issue_url=$(jq --raw-output .pull_request._links.issue.href "$GITHUB_EVENT_PATH")

        curl -XDELETE -sSL \
            -H "${AUTH_HEADER}" \
			-H "${API_HEADER}" \
            "${issue_url}/labels/ready+for+review"

         curl -XPOST -sSL \
            -H "${AUTH_HEADER}" \
			-H "${API_HEADER}" \
            --data '{"labels": "ready to land"}' \
            "${issue_url}/labels"

        echo "all done"
	fi
}

main "$@"