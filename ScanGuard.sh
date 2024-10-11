#!/bin/bash

# Banner with ScanGuard name
echo "*************************************************"
echo "*                                               *"
echo "*     ███████╗ ██████╗  █████╗ ███╗   ██╗       *"
echo "*     ██╔════╝██╔════╝ ██╔══██╗████╗  ██║       *"
echo "*     ███████╗██║  ███╗███████║██╔██╗ ██║       *"
echo "*     ╚════██║██║   ██║██╔══██║██║╚██╗██║       *"
echo "*     ███████║╚██████╔╝██║  ██║██║ ╚████║       *"
echo "*     ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝       *"
echo "*                                               *"
echo "*       [+] Welcome to ScanGuard Tool [+]       *"
echo "*               Developed by Yaswanth B         *"
echo "*                                               *"
echo "*************************************************"
echo ""

# Add sleep time with progressive stars
echo "***"
sleep 1
echo "*****"
sleep 1
echo "*******"
sleep 1

# Main log file
log_file="scanguard_report.txt"

# Function to display the scan options
show_menu() {
    echo "[+] Choose an option for scanning:"
    echo ""
    echo "1. Host Discovery"
    echo "   "
    echo "2. Full TCP Port Scan"
    echo "   "
    echo "3. Full UDP Port Scan"
    echo "   "
    echo "4. Detailed Scan with OS and Service Detection"
    echo "   "
    echo "5. Vulnerability Scan with CVE checks"
    echo "   "
    echo "6. Generate Network Topology Map"
    echo "   "
    echo "7. Custom Scan Profile"
    echo "   "
    echo "8. SSH Brute Force Detection"
    echo "   "
    echo "9. Real-Time Network Traffic Analysis"
    echo "   "
    echo "10. Exit"
    echo ""
}

# Perform scan and save report in multiple formats
save_report() {
    scan_command=$1
    output_prefix=$2

    # Run the scan and append all output to the log file
    echo "[+] Running scan: $scan_command" | tee -a $log_file
    # Use stdbuf -oL to disable buffering so that output shows in real-time
    stdbuf -oL $scan_command | tee -a "${output_prefix}.txt" >> $log_file
    echo "[+] Scan results appended to ${log_file}" | tee -a $log_file
}

# Function to email the scan results
email_report() {
    echo "[+] Sending report via email..." | tee -a $log_file
    # Dummy email command (requires `mail` command or sendmail configured)
    echo "Scan completed" | mail -s "ScanGuard Report" recipient@example.com
    echo "[+] Report sent!" | tee -a $log_file
}

# Execute chosen option
run_scan() {
    case $1 in
        1)
            echo "[+] Starting Host Discovery..." | tee -a $log_file
            save_report "nmap -sn $ip_address" "discovery_scan"
            ;;
        2)
            echo "[+] Starting Full TCP Port Scan..." | tee -a $log_file
            save_report "nmap -p- -T4 $ip_address" "tcp_full_scan"
            ;;
        3)
            echo "[+] Starting Full UDP Port Scan..." | tee -a $log_file
            save_report "nmap -sU -T4 $ip_address" "udp_full_scan"
            ;;
        4)
            echo "[+] Starting Detailed Scan with OS and Service Detection..." | tee -a $log_file
            save_report "nmap -A -T4 $ip_address" "detailed_scan"
            ;;
        5)
            echo "[+] Starting Vulnerability Scan with CVE checks..." | tee -a $log_file
            save_report "nmap --script vuln --script-args=unsafe=1 $ip_address" "vuln_scan"
            ;;
        6)
            echo "[+] Generating Network Topology Map..." | tee -a $log_file
            nmap -A --top-ports 100 $ip_address --traceroute -oX topology_scan.xml | tee -a $log_file
            echo "[+] Topology map saved in topology_scan.xml. Convert to a visual graph using Graphviz." | tee -a $log_file
            ;;
        7)
            echo "[+] Starting Custom Scan Profile..." | tee -a $log_file
            read -p "[+] Enter custom nmap options: " custom_options
            save_report "nmap $custom_options $ip_address" "custom_scan"
            ;;
        8)
            echo "[+] Starting SSH Brute Force Detection..." | tee -a $log_file
            echo "[*] Using hydra to detect SSH brute force on port 22..." | tee -a $log_file
            hydra -l admin -P /path/to/passwords.txt $ip_address ssh | tee -a $log_file
            ;;
        9)
            echo "[+] Starting Real-Time Network Traffic Capture..." | tee -a $log_file
            echo "[*] Capturing traffic, press Ctrl+C to stop..." | tee -a $log_file
            sudo tcpdump -i any -w traffic_capture.pcap | tee -a $log_file
            echo "[+] Traffic capture saved to traffic_capture.pcap" | tee -a $log_file
            ;;
        10)
            echo "[+] Exiting the script. Goodbye!" | tee -a $log_file
            exit 0
            ;;
        *)
            echo "Invalid option! Please choose a valid option." | tee -a $log_file
            ;;
    esac
}

# Input the IP address or range for scanning
read -p "[+] Enter the IP address or range to scan: " ip_address

# Loop to show the menu until the user exits
while true
do
    show_menu
    read -p "[+] Enter your choice: " choice
    run_scan $choice

    # Optional: Send email report after each scan
    read -p "[+] Do you want to email the report? (y/n): " email_choice
    if [ "$email_choice" == "y" ]; then
        email_report
    fi

    echo ""
done
