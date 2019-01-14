workflow "on review approve, tag as ready to land" {
    on = "pull_request"
    resolves = ["tag on approve"]
}

action "tag on approve" {
    uses = "nicwise/tag-on-review@master"
    secrets = ["GITHUB_TOKEN"]
}