# The-Smart-Apples

Installation Procedures.

Install Command line tools for Mac
https://osxdaily.com/2014/02/12/install-command-line-tools-mac-os-x/

Clone Repo
git clone https://github.com/dcm026/The-Smart-Apples.git

Install Homebrew
'mkdir homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew'

Install Cocoapods (do not install with ruby)
'brew install cocoapods'

Navigate to project directory

Install Pods to project (frameworks, really just mailgun and it's dependency)
'pod install'

Run workspace file in Xcode and build

If you get a permission error, go to parent directory
'chmod -R 777 The-Smart-Apples'

This gives all subfiles and folders all read-write-execute permissions (overkill, but we need to get this working).

If it's working you should get a clean build and the watch app demo will execute.
