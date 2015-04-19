@Story:testJIRAid
Feature: OAuth authentication

  Background: null
    Given I am in "dotfiles" git repo

  Scenario: Ask for username & password, create authorization
    Given the GitHub API server:
    When I run `hub create` interactively
    When I type "mislav"
    And I type "kitty"
    Then the output should contain "github.com username:"
    And the output should contain "github.com password for mislav (never stored):"
    And the exit status should be 0
    And the file "../home/.config/hub" should contain "user: MiSlAv"
    And the file "../home/.config/hub" should contain "oauth_token: OTOKEN"
    And the file "../home/.config/hub" should have mode "0600"

  Scenario: Rename & retry creating authorization if there's a token name collision
    Given the GitHub API server:
    When I run `hub create` interactively
    When I type "mislav"
    And I type "kitty"
    Then the output should contain "github.com username:"
    And the exit status should be 0
    And the file "../home/.config/hub" should contain "oauth_token: OTOKEN"

  Scenario: Avoid getting caught up in infinite recursion while retrying token names
    Given the GitHub API server:
    When I run `hub create` interactively
    When I type "mislav"
    And I type "kitty"
    Then the output should contain:
    And the exit status should be 1
    And the file "../home/.config/hub" should not exist

  Scenario: Credentials from GITHUB_USER & GITHUB_PASSWORD
    Given the GitHub API server:
    Given $GITHUB_USER is "mislav"
    And $GITHUB_PASSWORD is "kitty"
    When I successfully run `hub create`
    Then the output should not contain "github.com password for mislav"
    And the file "../home/.config/hub" should contain "oauth_token: OTOKEN"

  Scenario: Wrong password
    Given the GitHub API server:
    When I run `hub create` interactively
    When I type "mislav"
    And I type "WRONG"
    Then the stderr should contain exactly:
    And the exit status should be 1
    And the file "../home/.config/hub" should not exist

  Scenario: Personal access token used instead of password
    Given the GitHub API server:
    When I run `hub create` interactively
    When I type "mislav"
    And I type "PERSONALACCESSTOKEN"
    Then the stderr should contain exactly:
    And the exit status should be 1
    And the file "../home/.config/hub" should not exist

  Scenario: Two-factor authentication, create authorization
    Given the GitHub API server:
    When I run `hub create` interactively
    When I type "mislav"
    And I type "kitty"
    And I type "112233"
    Then the output should contain "github.com password for mislav (never stored):"
    Then the output should contain "two-factor authentication code:"
    And the output should not contain "warning: invalid two-factor code"
    And the exit status should be 0
    And the file "../home/.config/hub" should contain "oauth_token: OTOKEN"

  Scenario: Retry entering two-factor authentication code
    Given the GitHub API server:
    When I run `hub create` interactively
    When I type "mislav"
    And I type "kitty"
    And I type "666"
    And I type "112233"
    Then the output should contain "warning: invalid two-factor code"
    And the exit status should be 0
    And the file "../home/.config/hub" should contain "oauth_token: OTOKEN"

  Scenario: Special characters in username & password
    Given the GitHub API server:
    When I run `hub create` interactively
    When I type "mislav@example.com"
    And I type "my pass@phrase ok?"
    Then the output should contain "github.com password for mislav@example.com (never stored):"
    And the exit status should be 0
    And the file "../home/.config/hub" should contain "user: mislav"
    And the file "../home/.config/hub" should contain "oauth_token: OTOKEN"

  Scenario: Enterprise fork authentication with username & password, re-using existing authorization
    Given the GitHub API server:
    And "git.my.org" is a whitelisted Enterprise host
    And the "origin" remote has url "git@git.my.org:evilchelu/dotfiles.git"
    When I run `hub fork` interactively
    And I type "mislav"
    And I type "kitty"
    Then the output should contain "git.my.org password for mislav (never stored):"
    And the exit status should be 0
    And the file "../home/.config/hub" should contain "git.my.org"
    And the file "../home/.config/hub" should contain "user: mislav"
    And the file "../home/.config/hub" should contain "oauth_token: OTOKEN"
    And the url for "mislav" should be "git@git.my.org:mislav/dotfiles.git"

