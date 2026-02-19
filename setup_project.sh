#!/bin/bash

# Prompt the user to enter a project name
read -p "Enter project name: " input

echo "Project will be created as: attendance_tracker_$input"

# Create the main directory and subdirectories
mkdir -p attendance_tracker_$input
mkdir -p attendance_tracker_$input/Helpers
mkdir -p attendance_tracker_$input/reports

# Create the required files
touch attendance_tracker_$input/attendance_checker.py
touch attendance_tracker_$input/Helpers/assets.csv
touch attendance_tracker_$input/Helpers/config.json
touch attendance_tracker_$input/reports/reports.log

echo "Directory structure created successfully!"

# Write content to attendance_checker.py
cat > attendance_tracker_$input/attendance_checker.py << 'EOF'
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            
            attendance_pct = (attended / total_sessions) * 100
            
            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF

# Write content to assets.csv
cat > attendance_tracker_$input/Helpers/assets.csv << 'EOF'
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF

# Write content to config.json
cat > attendance_tracker_$input/Helpers/config.json << 'EOF'
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF

# Write content to reports.log
cat > attendance_tracker_$input/reports/reports.log << 'EOF'
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.
EOF

echo "All files populated successfully!"


# Ask user if they want to update thresholds
read -p "Do you want to update attendance thresholds? (yes/no): " update_choice

if [ "$update_choice" == "yes" ] || ["$update_choice" == "y"]; then
    read -p "Enter new Warning threshold (default 75): " warning
    read -p "Enter new Failure threshold (default 50): " failure

    # Validate that inputs are numbers
    if ! [[ "$warning" =~ ^[0-9]+$ ]] || ! [[ "$failure" =~ ^[0-9]+$ ]]; then
        echo "Invalid input! Thresholds must be numbers. Keeping defaults."
    else
        # Use sed to update config.json in place
        sed -i "s/\"warning\": [0-9]*/\"warning\": $warning/" attendance_tracker_$input/Helpers/config.json
        sed -i "s/\"failure\": [0-9]*/\"failure\": $failure/" attendance_tracker_$input/Helpers/config.json

        echo "Thresholds updated successfully!"
        cat attendance_tracker_$input/Helpers/config.json
    fi
else
    echo "Keeping default thresholds."
fi


# Run the python script
echo "Running attendance checker..."

cd attendance_tracker_$input
python3 attendance_checker.py
cd ..

echo "Attendance check complete! Check reports/reports.log for results."



# Trap function - runs when user presses Ctrl+C
cleanup() {
    echo ""
    echo "Script interrupted! Archiving current state..."
    
    # Bundle the directory into an archive
    tar -czf attendance_tracker_${input}_archive.tar.gz attendance_tracker_$input
    
    # Delete the incomplete directory
    rm -rf attendance_tracker_$input
    
    echo "Archive created: attendance_tracker_${input}_archive.tar.gz"
    echo "Incomplete directory deleted. Exiting cleanly."
    exit 1
}


# Register the trap - listen for Ctrl+C (SIGINT)
trap cleanup SIGINT



echo ""
echo "Running Health Check..."

if python3 --version 2>/dev/null; then
    echo "python3 is installed and ready!"
else
    echo "WARNING: python3 is not installed on this system!"
fi
