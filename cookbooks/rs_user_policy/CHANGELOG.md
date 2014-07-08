# CHANGELOG for rs_user_policy

This file is used to list changes made in each version of rs_user_policy.

## 0.1.0:

* Initial release of rs_user_policy

## 0.1.1

* Retry password generation until one is sufficiently strong. The random generator sometimes excludes required character types.

## 0.1.2

* Fix regex which validates that randomly generated password is sufficiently strong.

## 0.1.3

* Added the cookbook

## 0.1.7

* Update to right_api_client 1.5.10 and refactor accordingly.

## 0.1.8

* Update to right_api_client 1.5.12
* Add server_superuser permission

## 0.1.9

* Tweaks to the multi_client functionality to include the actual child account resource.

## 0.1.10

* Allow specifying audit directory
* Added flag to fail fatally if user assignments are provided, but invalid

- - -
Check the [Markdown Syntax Guide](http://daringfireball.net/projects/markdown/syntax) for help with Markdown.

The [Github Flavored Markdown page](http://github.github.com/github-flavored-markdown/) describes the differences between markdown on github and standard markdown.
