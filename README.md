# Attendance Tracker Automation

This is a Bash (Shell) script based automation software that automates the creation of a Student Attendance workspace,
the project does creation of a directory, file generation, dynamic configuration, and process management.

So what this script does in particular are
1. Create the project folder
2. Generate the required files (Python, CSV, JSON, log file)
3. It allows updating of the attendance thresholds
4. then it runs a python script to check for attendance
5. and then it logs warnings for student with no attendance

## Technologies used
Bash - for automation and file creation
Python3 - For processing attendance data
CSV- Used to store students attendance
JSON - Used for storing configuration settings

## Project Structure
This is the file that is created after i run the code

attendance_tracker_<project_name>/
│
├── attendance_checker.py
├── Helpers/
│   ├── assets.csv
│   └── config.json
└── reports/
    └── reports.log

## How it works
1. The user enters a project name
2. the script then create all the required folders and files
3. Run the python program to create:
     - Read student data from assests.csv
     - Read the settings from config.json
     - calculate the attendance percentage
     - Log warnings and alerts if the attendance is low.
     - It also showcase the how the trap signal SIGINT works.
4. The results are then saved in reports/reports.log

## How to run the program
1. First confirm python 3 is installed with
   python3 --version
2. Use the chmod +x command to make it executable
    chmod +x setup_project.sh
3.Run the script using :
  ./setup_project.sh

4.Then you follow the instructions on the terminal

## so the way it functions is that:
It shows attendance rules,
- if the attendance is below 50% : it shows URGENT as message
- if the attendance is below 75% : it throws a warning message


## Overall
this project demonstates
- Bash scripting skills
- File and directory automation
- Reading as well as writing CSV files in python
- Using JSON configuration
- And Basic logging systems










     
     
