# HowTo Set up Redmine Server Components with Supervisor on Ubuntu

This howto describes how to set up the Taskjuggler server daemon on Ubuntu. 

by Alexey Lukomskiy <lucomsky@gmail.com> and Christopher Mann <christopher@mann.fr>

{{toc}}

## Introduction

"Taskjuggler":http://www.taskjuggler.org is release-planning and budget calculation open-source software.  Once installed, Taskjuggler can be run from a command-line with the command "tj3" on Linux, Mac and Windows. TJ3 takes a Taskjuggler project file and includes as input and outputs varios reports in HTML, CSV, OpenWorkbench, and Microsoft Project.

Taskjuggler also proposes a server infrastructure for the following purposes :
- Taskjuggler project calculation as a service
- Optionally a web server for the most recent reports on a project
- Optionally timesheet and timesheet validation sending and receiving 

"Supervisor":http://supervisord.org/ is a process control and monitoring framework. Supervisor will allow the continued execution and restarting if necessary of the different daemons in the Taskjuggler server infrastructure.

Here is the infrastructure of the Taskjuggler server :

| Program   | Meaning                                                          |
| tj3d      | The Taskjuggler server daemon                                    |
| tj3client | The Taskjuggler program for interacting with tj3s over a network |
| tj3webd   | An optional webserver that publishes HTML reports from tj3d      |


Taskjuggler project files are text files with the ".tjp" extension written in a declarative "Taskjuggler syntax":http://www.taskjuggler.org/tj3/manual/Tutorial.html. A taskjuggler project file may include one or more Taskjuggler include ".tji" files. 

A classic use of taskjuggler may be typing in on the command-line ~tj3 example.tjp~. After the calculation the user may then consult HTML reports generated by the calculation, or updating dates from a CSV file into some backlog management tool.

The taskjuggler server framework can store the Taskjuggler projects in a database on a daemon instead of in a text file. This is done by communication between the ~tj3client~ (a command-line client) and ~tj3d~ (the daemon server) programs. A typical scenario consists of the tj3client registering a project on the server, sending updates, and requesting a report. In the begining, the daemon would be started on the server with ~# tj3d~ then at some point a client would register or update projects ~tj3client add example.tjp~ and request reports ~tjp3client report example alldates.csv~.

The taskjuggler server framework also proposes a web server "tj3web" to consult reports from tj3s, and an email interaction for time-sheet update and validation with specific configurations of tj3d. The scope of the current howto is the working of tj3d and tj3webd with Supervisor.

## Environment Setup & Prerequisite Steps

The system should be ready to configure with the following steps.

### Pre-requisite software

Instructions for installing Taskjuggler may be obtained from [taskjuggler.org](http://www.taskjuggler.org). The easy way is ~$ gem install taskjuggler~ from the command line.

We use Supervisor for maintaining the taskjuggler daemon live. The easy way to install supervisor on a Debian or Ubuntu machine is ~sudo apt-get install supervisor~.

Add these lines to /etc/supervisor/supervisord.conf:

    [inet_http_server]
    port=:9001
    username=[Username here]
    password=[Password here]

You now can check supervisor at http://localhost:9001/ (username and password as above).

We will also create files here :

| Config File                        | Meaning                                       |
| /etc/supervisor/conf.g/tj3d.conf   | A configuration file in Supervisor for tj3d   |
| /etc/supervisor/conf.g/tj3web.conf | A configuration file in Supervisor for tj3web |

### Creation of a taskjuggler user and working directories

We will use a new user "taskjuggler" for the execution of the taskjuggler daemon. I added it with the command-line ~adduser taskjuggler~. It has the home directory ~/home/taskjuggler~. For the rest of this documentation, we will use this home directory.

The following directories will be created for this setup. You may change them as you see fit.

| Path                            | Use                                                          |
| /home/taskjuggler/data          | The folder where the daemon will do its work                 |
| /home/taskjuggler/data/projects | Project files repository (I think)                           |
| /home/taskjuggler/data/logs     | Project execution logs tj3d\_stdout.log and tj3d\_stderr.log |


This can be done in the home directory with @mkdir tj3dvar;mkdir tj3dvar/projects;mkdir tj3dvar/logs@ or by other means. Either create them as user taskjuggler, or @chown -R taskjuggler:taskjuggler data@ afterwards.

Taskjuggler will also use a configuration file. Add the following file @/home/taskjuggler/taskjuggler.rc@:

    _global:
      authKey: [random key here]
      webServerPort: 8080
      _log:
        logLevel: 1
        outputLevel: 1

Again, if not created by taskjuggler, please @chown taskjuggler:taskjuggler taskjuggler.rc@.

### Key Ports 

Below are the different ports used in this example. You may change them as you see fit.

| Port | Service                       |
| 8080 | tj3webd server                |
| 8474 | default tj3d port             |
| 9001 | Supervisor web administration |


### Adding TaskJuggler services tj3d and tj3webd

Assume that taskjuggler version 3 or higher is installed. Working directory of *.tjp and *.tjl is /home/taskjuggler/data/projects/.  Folder should have user for taskjuggler and eventually group access for www-data.

### Setting up Supervisor

These operations can be done as root.

Add file /etc/supervisor/conf.g/tj3d.conf:
 
    [program:tj3d]
    command = tj3d -d --config /home/taskjuggler/taskjuggler.rc -p 8474
    directory = /home/taskjuggler/data/projects/
    priority = 1
    autostart = true
    autorestart = true
    exitcodes = 0
    user = taskjuggler
    redirect_stderr = true
    stdout_logfile = /home/taskjuggler/logs/tj3d_stdout.log
    stderr_logfile = /home/taskjuggler/logs/tj3d_stderr.log

Add file /etc/supervisor/conf.g/tj3web.conf:

    [program:tj3webd]
    command = tj3webd -d --config /home/taskjuggler/taskjuggler.rc
    directory = /home/taskjuggler/projects/
    priority = 2
    autostart = true
    autorestart = true
    exitcodes = 0
    user = taskjuggler
    redirect_stderr = true
    stdout_logfile = /home/taskjuggler/logs/tj3webd_stdout.log
    stderr_logfile = /home/taskjuggler/logs/tj3webd_stderr.log

Reload supervisor:

    # sudo supervisorctl reload

### Possible security precaution

Security may be reinforced by taking the shell away from the taskjuggler user. This is in the @/etc/passwd@ file.

## Bringing it all together

Check http://localhost:9001/ with supervisor tj3d and tj3webd statuses.

You now can have http://localhost:8080/taskjuggler with *«Welcome to the TaskJuggler Project Server»*

Now you can add your project file by command:

    $ tj3client add project.tjp
