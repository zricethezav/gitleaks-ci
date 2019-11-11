<p align="center">
  <img alt="gitleaks-ci" src="https://raw.githubusercontent.com/zricethezav/gifs/master/gitleaks-ci.png" height="140" />
</p>

## Audit PRs on github before you hit that merge button
### What is?
[Gitleaks](https://github.com/zricethezav/gitleaks) is great for doing thorough audits on repos, organizations, and/or users but 
not so great for hooking into CI pipelines. **Gitleaks-CI** is 50 lines of bash code that checks your PRs for secrets you probably shouldn't be commiting. Gitleaks-CI will do a simple regex check for each line of your PR diff. Fork this project if you want to add/remove regexes.

### Alternatives?
Review the PR like a good human.


### How to?
Gitleaks-CI is a single line of code placed in whatever CI service you or your organization uses.
```
bash <(curl -s https://raw.githubusercontent.com/Zaulao/gitleaks-ci/master/gitleaks.sh)
```
**You should fork this repo and use the `gitleaks.sh` script you own rather than assuming my trust.**

#### PR logs
Sample PR with a leak [here](https://github.com/zricethezav/gitleaks-ci/pull/15)
##### CircleCI

<p align="left">
  <img alt="gitleaks-ci" src="https://raw.githubusercontent.com/zricethezav/gifs/master/circle_fail.png" />
</p>

##### Travis

<p align="left">
  <img alt="gitleaks-ci" src="https://raw.githubusercontent.com/zricethezav/gifs/master/travis_fail.png" height="240" />
</p>


---

### Accessing Private Repos
Gitleaks-CI requires the owner's credentials to access private repos
#### Travis
If you are using Travis read [this](https://docs.travis-ci.com/user/environment-variables/#Defining-encrypted-variables-in-.travis.yml) to add `GITHUB_USERNAME` and `GITHUB_API_TOKEN` environment variables.

#### CircleCI
TODO

#### Jenkins
TODO


### If you find leaks in your PR
Please read the [Github article on removing sensitive data from a repository](https://help.github.com/articles/removing-sensitive-data-from-a-repository/) to remove the sensitive information from your history.

