# cellphone
cellphone is an experiment automation web application desiged to automate a specific cell fluourescence based experiment performed at Tufts University.

## Requirements
To use cellphone you must be running a Windows computer connected to a microscope with a working TWAIN interface, have a working installation of the free ImageMagick software, and Ruby version 1.9.3+. It is highly advised that Windows computers install the application using Cygwin and run all commands through Cygwin.


## Install
1. Clone the git repository in a directory of your choice:

    $ git clone https://github.com/theck01/cellphone

  All following commands assume that the current directory is the cellphone directory created by the clone operation.

2. Ensure that there is a valid connection to the TWAIN interface using TWAINCom command line utility, found in the lib subdirectory
  
    $ ./lib/TWAINCom test.jpg -fjpg -grayscale -h -o

  The command should capture and image from the microscope and save it as test.jpg in the current directory

3. Install bundler, and then gems required by application

    $ gem install bundler
    $ bundle install


## Run
To run the experiment you must run two servers, one is the main application server and another is the image processing server. Start these servers with the commands:
    
    $ ./start_histogrammer.sh
    $ ./start_app.sh

The application can be used by visiting the following address in your browser:

130.78.84.73:4567

If you are not a Tufts researcher you may need to change the IP addresses in the start\_app.sh script and start\_histogrammer.sh script to an address on your network.
