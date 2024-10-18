#!/bin/bash

# Function to install the latest LTS version of Java
install_java() {
    echo "Installing the latest LTS version of Java..."
    
    if [[ "$os" == "debian" || "$os" == "ubuntu" ]]; then
        sudo apt update
        sudo apt install -y openjdk-17-jdk  # Java 17 is the latest LTS as of now
    elif [[ "$os" == "rhel" || "$os" == "fedora" || "$os" == "centos" ]]; then
        sudo yum install -y java-17-openjdk
    elif [[ "$os" == "mac" ]]; then
        brew install openjdk@17
    fi
    
    echo "Java 17 (LTS) installed."
}

# Function to install the latest LTS version of Jenkins
install_jenkins() {
    echo "Installing the latest LTS version of Jenkins..."

    if [[ "$os" == "debian" || "$os" == "ubuntu" ]]; then
        sudo apt update
        sudo apt install -y wget
        wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
        sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
        sudo apt update
        sudo apt install -y jenkins
    elif [[ "$os" == "rhel" || "$os" == "fedora" || "$os" == "centos" ]]; then
        sudo yum install -y wget
        sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
        sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
        sudo yum upgrade
        sudo yum install -y jenkins
    elif [[ "$os" == "mac" ]]; then
        brew install jenkins-lts
    fi
    
    echo "Jenkins latest LTS installed."
}

# Function to check Jenkins status
check_jenkins_status() {
    echo "Checking Jenkins status..."
    
    if ! systemctl is-active --quiet jenkins; then
        echo "Jenkins is not running. Starting Jenkins..."
        sudo systemctl start jenkins
    fi

    echo "Jenkins is running."
}

# Function to display access instructions
display_access_instructions() {
    echo "Jenkins should now be accessible from your browser."
    echo "1. Find the IP address of your AlmaLinux VM or Linux machine:"
    echo "   - Run: ip a"
    echo "   - Look for an IP address associated with your network interface."
    echo "2. Open a web browser on your Windows machine."
    echo "3. Enter the following URL, replacing <VM_IP_ADDRESS> with your VM's IP address:"
    echo "   http://<VM_IP_ADDRESS>:8080"
    echo "4. Retrieve the Jenkins initial admin password with:"
    echo "   sudo cat /var/lib/jenkins/secrets/initialAdminPassword"
    echo "5. Paste the password into the web browser when prompted."
    echo ""
    echo "If you cannot access Jenkins, you may need to adjust your firewall settings:"
    echo "   - On Debian/Ubuntu, use: sudo ufw allow 8080/tcp"
    echo "   - On RHEL/CentOS/Fedora, use: sudo firewall-cmd --zone=public --add-port=8080/tcp --permanent && sudo firewall-cmd --reload"
    echo "   - On other systems, consult your firewall documentation for how to open port 8080."
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt &> /dev/null; then
            os="debian"
        elif command -v yum &> /dev/null; then
            os="rhel"
        elif command -v dnf &> /dev/null; then
            os="fedora"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        os="mac"
    else
        echo "Unsupported OS."
        exit 1
    fi
}

# Main script logic
main() {
    detect_os
    install_java
    install_jenkins
    check_jenkins_status
    display_access_instructions
    echo "Jenkins and Java setup completed!"
}

# Run the main function
main
