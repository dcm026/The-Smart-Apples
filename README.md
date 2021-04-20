# The-Smart-Apples

## Installation Procedures.

### 1. Install Command line tools for Mac
https://osxdaily.com/2014/02/12/install-command-line-tools-mac-os-x/

### 2. Clone Repo
git clone https://github.com/dcm026/The-Smart-Apples.git

### 3. Install Homebrew
'mkdir homebrew && curl -L https://github.com/Homebrew/brew/tarball/master | tar xz --strip 1 -C homebrew'
***
if the above command does not work try:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
***

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


## Installing via virtualbox on Windows 10 with AMD chipset

### 1. Install Mac OS Catalina virtual machine using VMware Workstation 15.0.3
Follow the video: https://www.youtube.com/watch?v=9MUi00wiHWI&list=LL&index=6&t=0s step by step (NOTE: this only works for AMD chips).

### 2. Follow the Installation Procedures steps 1 to 6 above

### 3. Install Xcode
Download the Xcode 12.4 XIP file at https://xcodereleases.com/. I initially tried downloading it multiple times on the guest Mac OS via through the site and through the apple store but it failed each time. What worked for me was downloading it via the xcodereleases.com site and transfering it to the guest OS when the download is finished.
Use the command to extract the xip file once you place it in the guest OS: xip -x ~/Desktop/Xcode_12.4.xip (if the xip file was not placed in the Desktop replace Desktop with the path you placed the file in). Navigate to the extracted folder and click the executable to install Xcode.

### 4. Follow the Installation Procedures steps 7 to 10.

## Paired Device Simulation Setup.

### Navigate to Window>Devices and Simulators>Simulators
Select a device and ensure that on the right side of the screen under "Paired Watches" a watch is selected.

### Verify build settings
Select the project file "proj4" and go to General Settings.  Ensure that "Supports Running Without iOS App Installation" is unchecked.

### Build your test scheme.
On first build you will need to let the devices pair on the phone by going to the Watch App then you can start up the test application.

### Swift Documentation 

### What is Swift ?
Swift is a general-purpose programming language that primarily follows the OOP. It was created and released by Apple in 2014. Many products made at Apple now entirely support Swift. While Apple is working to make Swift more accessible to different operating systems, it is primarily used on macOS.
Find out more about Swift: https://developer.apple.com/swift/

### Programming Tips
1. Improve the readability of constants by creating a file consisting of constant structs in the application.

2. Avoid NSObject and @objc as it can have negative impact on performance.

3. Be cautious of using optionals because they can result in nil values and cause an application to crash.

### Testing Documentation

### Soak Test
The application ran for approximately ten minutes. When the screen was turned off or the app was minimized, the accelerometer stopped. Besides the accelerometer not working properly in the background, everything worked as intended.

### iWatch Experiments
The goal of the iWatch experiments was to determine how the watch knows that it is being worn. This experiment was important because it was initially thought that the iWatch uses heartbeat for user detection, but results proved otherwise. The results showed that the unworn watch still reads a heartbeat value that is not zero on solid 
surfaces like tables. David Milam, primary designer of experiment, concluded the watch uses conductivity and a light sensor to determine whether it is being worn or not.

