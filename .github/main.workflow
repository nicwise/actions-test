workflow "on review approve, tag as ready to land" {
    on = "pull_request_review"
    resolves = ["tag on approve"]
}

action "tag on approve" {
    uses = "./tag-on-review/"
    secrets = ["GITHUB_TOKEN"]
}