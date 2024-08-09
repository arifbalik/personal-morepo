#!/bin/sh

repo_settings='{
  "name": "self-monorepo",
  "description": "Personal monorepo playground",
  "homepage": "arifbalik.github.io/self-monorepo/",
  "private": false,
  "visibility": "public",
  "security_and_analysis": {
    "secret_scanning": {
      "status": "enabled"
    },
    "secret_scanning_push_protection": {
      "status": "enabled"
    },
    "secret_scanning_non_provider_patterns": {
      "status": "enabled"
    },
    "dependabot_security_updates": {
      "status": "enabled"
    },
    "secret_scanning_non_provider_patterns": {
      "status": "enabled"
    },
    "secret_scanning_validity_checks": {
      "status": "enabled"
    }
  },
  "has_issues": true,
  "has_projects": true,
  "has_wiki": true,
  "is_template": false,
  "default_branch": "main",
  "allow_squash_merge": true,
  "allow_merge_commit": false,
  "allow_rebase_merge": false,
  "allow_auto_merge": false,
  "delete_branch_on_merge": true,
  "allow_update_branch": true,
  "squash_merge_commit_title": "COMMIT_OR_PR_TITLE",
  "squash_merge_commit_message": "COMMIT_MESSAGES",
  "archived": false,
  "web_commit_signoff_required": true
}'

ruleset_name="default ruleset"
rulesets=$(gh api 'repos/{owner}/{repo}/rulesets')
ruleset_id=$(echo "$rulesets" | jq -r ".[] | select(.name == \"$ruleset_name\") | .id")
# shellcheck disable=SC2089
rules='{
  "name": "'$ruleset_name'",
  "target": "branch",
  "enforcement": "active",
  "conditions": {
    "ref_name": {
      "exclude": [],
      "include": [
        "~DEFAULT_BRANCH"
      ]
    }
  },
  "rules": [
    {
      "type": "deletion"
    },
    {
      "type": "non_fast_forward"
    },
    {
      "type": "required_signatures"
    },
    {
      "type": "pull_request",
      "parameters": {
        "required_approving_review_count": 1,
        "dismiss_stale_reviews_on_push": true,
        "require_code_owner_review": false,
        "require_last_push_approval": true,
        "required_review_thread_resolution": true
      }
    },
    {
      "type": "required_status_checks",
      "parameters": {
        "strict_required_status_checks_policy": false,
        "do_not_enforce_on_create": false,
        "required_status_checks": [
          {
            "context": "check-pr-size"
          },
          {
            "context": "MegaLinter"
          },
          {
            "context": "commitlint"
          }
        ]
      }
    }
  ],
  "bypass_actors": [
    {
      "actor_id": 5,
      "actor_type": "RepositoryRole",
      "bypass_mode": "always"
    }
  ]
}'

gh api \
  --method PATCH \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  'repos/{owner}/{repo}' --input - <<< "$repo_settings"

gh api \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  repos/{owner}/{repo}/pages > /dev/null 2>&1

if [ $? -eq 0 ]; then
  gh api \
    --method DELETE \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    'repos/{owner}/{repo}/pages'
fi

gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  'repos/{owner}/{repo}/pages' \
   -f "source[branch]=main" -f "source[path]=/"

if [ -n "$ruleset_id" ]; then
  gh api \
  --method DELETE \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  'repos/{owner}/{repo}/rulesets/'"$ruleset_id"
fi

gh api \
  --method POST \
  -H "Accept: application/vnd.github+json" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  'repos/{owner}/{repo}/rulesets' --input - <<< "$rules"
