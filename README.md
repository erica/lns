# Yet another lns

A rewrite in Swift of an old classic with extended functionality.

```
OVERVIEW: Create a symbolic link between two paths, regardless of order

USAGE: lns <first-path> <second-path>

ARGUMENTS:
  <first-path>            A file path. 
  <second-path>           Another file path. 

OPTIONS:
  -h, --help              Show help information.
```

for example:

```
# The last path component is used as the symbolic link name
lns . long-path-to-folder-used-regularly

# Same here but it's a file rather than a folder
lns path-to-file ~/Desktop
```

## Installation

* Install [homebrew](https://brew.sh).
* Install [mint](https://github.com/yonaskolb/Mint) with homebrew (`brew install mint`).
* From command line: `mint install erica/lns`

## Build notes

* This project includes a build phase that writes to /usr/local/bin
* Make sure your /usr/local/bin is writable: `chmod u+w /usr/local/bin`
