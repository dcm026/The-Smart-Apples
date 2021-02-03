# The-Smart-Apples

## Installation Procedures.

### 1. Install Command line tools for Mac
https://osxdaily.com/2014/02/12/install-command-line-tools-mac-os-x/

### 2. Clone Repo
git clone https://github.com/dcm026/The-Smart-Apples.git

### 3. Install Homebrew
'mkdir homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew'

### 4. Install Cocoapods (do not install with ruby)
'brew install cocoapods'

### 5. Navigate to project directory

### 6. Install Pods to project (frameworks, really just mailgun and it's dependency)
'pod install'

### 7. Run workspace file in Xcode and build

### 8. If you get a permission error, go to parent directory
'chmod -R 777 The-Smart-Apples'

### 9. This gives all subfiles and folders all read-write-execute permissions (overkill, but we need to get this working).

### 10. If it's working you should get a clean build and the watch app demo will execute.
