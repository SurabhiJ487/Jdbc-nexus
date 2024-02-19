#!/bin/bash

# ANSI escape code for green color
BLUE='\033[1;34m'
# ANSI escape code for yellow color
YELLOW='\033[1;33m'
# ANSI escape code for green color
GREEN='\033[1;32m'
# ANSI escape code for yellow color
RED='\033[1;31m'
# ANSI escape code to reset the text color
RESET='\033[0m'

# up_to_date=0
skip_git_status_check=0
skip_git_up_to_date_check=0

main_options=("aws" "database" "dependencies" "github")

function check_prerequisists() {
    optional=0
    optional_failed=0
    
    mandatory=0
    mandatory_failed=0
    
    ((mandatory++))
    if [ ! -f ~/.aws/config ]; then
        echo -e "${RED}File ~/.aws/config does not exist${RESET}!"
        echo -e "${YELLOW}Speak to system administrator to enable AWS SSO and follow the steps provided by AWS documentation (https://docs.aws.amazon.com/cli/latest/userguide/sso-configure-profile-token.html)${RESET}!"
        ((mandatory_failed++))
    fi

    ((mandatory++))
    if ! command -v awk &> /dev/null
    then
        echo -e "${RED}Error:${YELLOW} 'awk' command not found. Please install awk and try again${RESET}."
        ((mandatory_failed++))
    fi    

    ((mandatory++))
    if ! command -v aws &> /dev/null
    then
        echo -e "${RED}Error:${YELLOW} 'aws' command not found. Please install AWS CLI (https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) and try again${RESET}."
        ((mandatory_failed++))
    fi    

    ((mandatory++))
    if ! command -v gh &> /dev/null
    then
        echo -e "${RED}Error:${YELLOW} 'gh' command not found. Please install GitHub CLI (https://docs.github.com/en/github-cli/github-cli/quickstart) and try again${RESET}."
        ((mandatory_failed++))
    fi    

    ((mandatory++))
    if ! command -v git &> /dev/null
    then
        echo -e "${RED}Error:${YELLOW} 'git' command not found. Please install git and try again${RESET}."
        ((mandatory_failed++))
    fi    

    ((mandatory++))
    if ! command -v mvn &> /dev/null
    then
        echo -e "${RED}Error:${YELLOW} 'mvn' command not found. Please install Apache Maven and try again${RESET}."
        ((mandatory_failed++))
    fi    

    ((optional++))
    if ! command -v mysql &> /dev/null
    then
        echo -e "${YELLOW}Warning:${RESET} 'mysql' command not found. Please install MySQL client if you wish to make use of the database functionality${RESET}."
        ((optional_failed++))

        # Remove "database" from the array
        main_options=($(echo "${main_options[@]}" | sed "s/database//"))
    fi    

    ((optional++))
    if ! command -v mysqldump &> /dev/null
    then
        echo -e "${YELLOW}Warning:${RESET} 'mysqldump' command not found. Please install MySQL client if you wish to make use of the database functionality${RESET}."
        ((optional_failed++))

        # Remove "database" from the array
        main_options=($(echo "${main_options[@]}" | sed "s/database//"))
    fi    

    ((mandatory++))
    if ! command -v sed &> /dev/null
    then        
        echo -e "${RED}Error:${YELLOW} 'sed' command not found. Please install sed and try again${RESET}."
        ((mandatory_failed++))
    fi

    if [ "$mandatory_failed" -gt 0 ]; then
        echo
        echo -e "${RED}Failed ${YELLOW}$mandatory_failed${RED} of the mandatory ${YELLOW}$mandatory${RED} prerequisists, please address them and retry${RESET}."
        exit 1
    fi
    if [ "$optional_failed" -gt 0 ]; then
        echo
        echo -e "${YELLOW}Failed ${RESET}$optional_failed${YELLOW} of the optional ${RESET}$optional${YELLOW} prerequisists, please keep in mind some functionality will not be supported${RESET}."
        echo
    fi
}

# #############################################################################
# Main actions that can be selected which break down into detailed categories
# #############################################################################

function main_actions() {
    echo
    echo
    echo -e "${BLUE}██╗██╗░░██╗██╗░░░██╗███████╗"
    echo -e "██║██║░██╔╝██║░░░██║██╔════╝"
    echo -e "██║█████═╝░██║░░░██║█████╗░░"
    echo -e "██║██╔═██╗░██║░░░██║██╔══╝░░"
    echo -e "██║██║░╚██╗╚██████╔╝███████╗"
    echo -e "╚═╝╚═╝░░╚═╝░╚═════╝░╚══════╝${RESET}"
    echo
    echo

    check_prerequisists

    PS3="What related action would you like to take? "

    select action in "${main_options[@]}"; do
        case "$action" in
            "aws")
                break
                ;;
            "database")
                break
                ;;
            "dependencies")
                break
                ;;
            "github")
                break
                ;;
            *)
                echo -e "${RED}Invalid choice. Do you want me to go cyberpunk on you${RESET}!"
                ;;
        esac
    done

    case "$action" in
        aws)
            aws_actions
            ;;
        database)
            database_actions
            ;;
        github)
            github_actions
            ;;    
        *)
            echo -e "${RED}This shouldn't happen in method main_actions${RESET}!"
            ;;
    esac   
}

# #############################################################################
#░█████╗░░██╗░░░░░░░██╗░██████╗
#██╔══██╗░██║░░██╗░░██║██╔════╝
#███████║░╚██╗████╗██╔╝╚█████╗░
#██╔══██║░░████╔═████║░░╚═══██╗
#██║░░██║░░╚██╔╝░╚██╔╝░██████╔╝
#╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░╚═════╝░
# #############################################################################

function aws_actions() {
    echo
    echo
    echo -e "${YELLOW}░█████╗░░██╗░░░░░░░██╗░██████╗"
    echo -e "██╔══██╗░██║░░██╗░░██║██╔════╝"
    echo -e "███████║░╚██╗████╗██╔╝╚█████╗░"
    echo -e "██╔══██║░░████╔═████║░░╚═══██╗"
    echo -e "██║░░██║░░╚██╔╝░╚██╔╝░██████╔╝"
    echo -e "╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░╚═════╝░${RESET}"
    echo
    echo

    PS3="What AWS action would you like to take? "
    options=("credentials" "codeartifact")

    select action in "${options[@]}"; do
        case "$action" in
            "credentials")
                break
                ;;
            "codeartifact")
                break
                ;;
            *)
                echo -e "${RED}Invalid choice. Do you want me to get Jeff Bezos${RESET}!"
                ;;
        esac
    done

    case "$action" in
        credentials)
            aws_credentials
            ;;
        codeartifact)
            maven_settings
            ;;
        *)
            echo -e "${RED}This shouldn't happen in method aws_actions${RESET}!"
            ;;
    esac   
}

# #############################################################################
# Allows the user to select one of the available SSO profiles defined in
# ~/.aws/config and generates AWS credentials into ~/.aws/credentials
# #############################################################################

function aws_credentials() {
    echo
    # Parse the file and extract profile names
    options=($(awk -F'[][]' '/^\[.*\]$/ && $2 !~ /^sso-session/ {print $2}' ~/.aws/config | sed 's/^profile //'))

    # Print the profile names
    for i in "${!options[@]}"; do
        echo "$((i+1)). ${options[i]}"
    done

    while true; do
        # Prompt the user for input
        read -p "Please select the AWS profile to use:" choice

        # Check if the choice is a valid number
        if [[ "$choice" =~ ^[0-9]+$ ]]; then
            # Check if the choice is within the valid range
            if ((choice >= 1 && choice <= ${#options[@]})); then
                action="${options[choice-1]}"
                break
            fi
        fi

        echo -e "${RED}Invalid choice. Do you want me to get Jeff Bezos${RESET}!"
    done

    generated_credentials=$(aws configure export-credentials --profile $action --format env-no-export)
    if [ $? -ne 0 ]; then
        echo -e "${YELLOW}Try the following command to refresh your SSO session:${RESET}"
        echo -e "${YELLOW} - aws sso login --sso-session mvp-dev ${RESET}"
        exit 1
    fi

    echo "[default]" > ~/.aws/credentials
    echo "region = us-east-2" >> ~/.aws/credentials
    for line in $generated_credentials; do
        echo $line | sed 's/=/ = /' | awk -F= '{print tolower($1) "=" $2}' >> ~/.aws/credentials
    done

    echo -e "${GREEN}Sucessfully exported profile ${YELLOW}$action${GREEN} as default profile to ~/.aws/credentials${RESET}"
}

# #############################################################################
# Allows the user to select one of the available SSO profiles defined in
# ~/.aws/config and generates AWS credentials into ~/.aws/credentials
# #############################################################################

function maven_settings() {
    echo
    # Parse the file and extract accounts
    sso_account_ids=($(grep -Eo 'sso_account_id = [0-9]+' ~/.aws/config | cut -d' ' -f3))
    options=($(echo "${sso_account_ids[@]}" | tr ' ' '\n' | sort -u))

    # Print the accounts
    for i in "${!options[@]}"; do
        echo "$((i+1)). ${options[i]}"
    done

    while true; do
        # Prompt the user for input
        read -p "Please select the AWS account to use: " choice

        # Check if the choice is a valid number
        if [[ "$choice" =~ ^[0-9]+$ ]]; then
            # Check if the choice is within the valid range
            if ((choice >= 1 && choice <= ${#options[@]})); then
                sso_account_id="${options[choice-1]}"
                break
            fi
        fi

        echo -e "${RED}Invalid choice. Do you want me to get Jeff Bezos${RESET}!"
    done
    
    echo
    # Parse the file and extract profile names
    options=($(awk -F'[][]' '/^\[.*\]$/ && $2 !~ /^sso-session/ {print $2}' ~/.aws/config | sed 's/^profile //'))
    
    # Print the profile names
    for i in "${!options[@]}"; do
        echo "$((i+1)). ${options[i]}"
    done

    while true; do
        # Prompt the user for input
        read -p "Please select the AWS profile to use:" choice

        # Check if the choice is a valid number
        if [[ "$choice" =~ ^[0-9]+$ ]]; then
            # Check if the choice is within the valid range
            if ((choice >= 1 && choice <= ${#options[@]})); then
                profile="${options[choice-1]}"
                break
            fi
        fi

        echo -e "${RED}Invalid choice. Do you want me to get Jeff Bezos${RESET}!"
    done


    FILE_NAME="$HOME/.m2/settings.xml"
    CODEARTIFACT_DOMAIN="ikue-codeartifact-domain"
    ACCOUNT_ID="$sso_account_id"
    REPO_NAME="ikue-codeartifact-domain-ikue-artifactrepo"
    AWS_REGION="eu-west-1"
    
    # Get CodeArtifact authorization token
    CODEARTIFACT_TOKEN=$(aws codeartifact get-authorization-token --profile $profile --domain $CODEARTIFACT_DOMAIN --domain-owner $ACCOUNT_ID --region $AWS_REGION --output text --query authorizationToken)

# Text to insert
    insert_text=$(cat <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="no"?>    
<settings xmlns="http://maven.apache.org/SETTINGS/1.2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.2.0 https://maven.apache.org/xsd/settings-1.2.0.xsd">
  <servers>
      <server>
        <id>ikue-codeartifact-domain-ikue-artifactrepo</id>
        <username>aws</username>
        <password>$CODEARTIFACT_TOKEN</password>
      </server>
  </servers>

  <profiles>
    <profile>
      <id>ikue-codeartifact-domain-ikue-artifactrepo</id>
      <activation>
        <activeByDefault>true</activeByDefault>
      </activation>
      <repositories>
        <repository>
          <id>ikue-codeartifact-domain-ikue-artifactrepo</id>
          <url>https://ikue-codeartifact-domain-712115309672.d.codeartifact.eu-west-1.amazonaws.com/maven/ikue-artifactrepo/</url>
        </repository>
      </repositories>
    </profile>
  </profiles>
</settings>
EOF
)

    # Check if the file exists
    if [ -e "$FILE_NAME" ]; then
        mv "$FILE_NAME" "$FILE_NAME.bak"
    fi

    touch "$FILE_NAME"
    echo "$insert_text" > "$FILE_NAME"
 
    echo -e "${GREEN}Sucessfully exported account ${YELLOW}$action${GREEN} as default profile to $FILE_NAME${RESET}"
}

# #############################################################################
#██████╗░░█████╗░████████╗░█████╗░██████╗░░█████╗░░██████╗███████╗
#██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔════╝
#██║░░██║███████║░░░██║░░░███████║██████╦╝███████║╚█████╗░█████╗░░
#██║░░██║██╔══██║░░░██║░░░██╔══██║██╔══██╗██╔══██║░╚═══██╗██╔══╝░░
#██████╔╝██║░░██║░░░██║░░░██║░░██║██████╦╝██║░░██║██████╔╝███████╗
#╚═════╝░╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░╚═╝╚═════╝░╚═╝░░╚═╝╚═════╝░╚══════╝
# #############################################################################

function database_actions() {
    echo
    echo
    echo -e "${RED}██████╗░░█████╗░████████╗░█████╗░██████╗░░█████╗░░██████╗███████╗"
    echo -e "██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗██╔════╝██╔════╝"
    echo -e "██║░░██║███████║░░░██║░░░███████║██████╦╝███████║╚█████╗░█████╗░░"
    echo -e "██║░░██║██╔══██║░░░██║░░░██╔══██║██╔══██╗██╔══██║░╚═══██╗██╔══╝░░"
    echo -e "██████╔╝██║░░██║░░░██║░░░██║░░██║██████╦╝██║░░██║██████╔╝███████╗"
    echo -e "╚═════╝░╚═╝░░╚═╝░░░╚═╝░░░╚═╝░░╚═╝╚═════╝░╚═╝░░╚═╝╚═════╝░╚══════╝${RESET}"
    echo
    echo

    PS3="What database action would you like to take? "
    options=("restore")

    select action in "${options[@]}"; do
        case "$action" in
            "restore")
                break
                ;;
            *)
                echo -e "${RED}Invalid choice. Do you want to unleash the oracle${RESET}!"
                ;;
        esac
    done

    case "$action" in
        restore)
            database_restore
            ;;
        *)
            echo -e "${RED}This shouldn't happen in method aws_actions${RESET}!"
            ;;
    esac   
}

# #############################################################################
# Creates a SSH tunnel and performs a backup of your database of choice
# #############################################################################

function database_restore() {
    PS3="Please select the database to restore: "
    options=("csm" "csm_analytical_db")

    select database_name in "${options[@]}"; do
        case "$database_name" in
            "csm")
                break
                ;;
            "csm_analytical_db")
                break
                ;;
            *)
                echo -e "${RED}Invalid choice. Do you even SQL${RESET}!"
                ;;
        esac
    done

    # Define variables
    mysql_host="mysql-ikue-dev-us-east-2-rds-proxy.proxy-c4kpo6s1lbh9.us-east-2.rds.amazonaws.com"
    remote_host="3.130.53.148"
    remote_user="ubuntu"
    ssh_key="../bastion-key.pem"
    remote_port=3306
    local_port=6606

    # Create SSH tunnel
    ssh -i "$ssh_key" -fN -L "$local_port:$mysql_host:$remote_port" "$remote_user"@"$remote_host"

    # Check if the tunnel was created successfully
    if [ $? -ne 0 ]; then
        echo -e "${RED}mandatory_failed to establish SSH tunnel${RESET}."
        exit 1
    fi

    # Dump MySQL database over the SSH tunnel
    echo -e "${BLUE}Dumping database.${RESET}"
    mysqldump -P $local_port -h 127.0.0.1 -u reader -p"R$e9W#xZ@6pF" $database_name > "$database_name.sql"
    
    # Restore database
    echo -e "${BLUE}Restoring database.${RESET}"
    mysql -u root -ppassword $database_name < "$database_name.sql"

    # Close the SSH tunnel
    ssh -i "$ssh_key" -o exit "$remote_user"@"$remote_host"

    echo -e "${GREEN}Database $database_name has sucessfully been restored.${RESET}"
}

# #############################################################################
#██████╗░███████╗██████╗░███████╗███╗░░██╗██████╗░███████╗███╗░░██╗░█████╗░██╗███████╗░██████╗
#██╔══██╗██╔════╝██╔══██╗██╔════╝████╗░██║██╔══██╗██╔════╝████╗░██║██╔══██╗██║██╔════╝██╔════╝
#██║░░██║█████╗░░██████╔╝█████╗░░██╔██╗██║██║░░██║█████╗░░██╔██╗██║██║░░╚═╝██║█████╗░░╚█████╗░
#██║░░██║██╔══╝░░██╔═══╝░██╔══╝░░██║╚████║██║░░██║██╔══╝░░██║╚████║██║░░██╗██║██╔══╝░░░╚═══██╗
#██████╔╝███████╗██║░░░░░███████╗██║░╚███║██████╔╝███████╗██║░╚███║╚█████╔╝██║███████╗██████╔╝
#╚═════╝░╚══════╝╚═╝░░░░░╚══════╝╚═╝░░╚══╝╚═════╝░╚══════╝╚═╝░░╚══╝░╚════╝░╚═╝╚══════╝╚═════╝░
# #############################################################################

# mvn versions:display-property-updates -DincludeProperties=io.ikue.version
# mvn versions:update-properties -DincludeProperties=io.ikue.version

# #############################################################################
#░██████╗░██╗████████╗██╗░░██╗██╗░░░██╗██████╗░
#██╔════╝░██║╚══██╔══╝██║░░██║██║░░░██║██╔══██╗
#██║░░██╗░██║░░░██║░░░███████║██║░░░██║██████╦╝
#██║░░╚██╗██║░░░██║░░░██╔══██║██║░░░██║██╔══██╗
#╚██████╔╝██║░░░██║░░░██║░░██║╚██████╔╝██████╦╝
#░╚═════╝░╚═╝░░░╚═╝░░░╚═╝░░╚═╝░╚═════╝░╚═════╝░
# #############################################################################

function github_actions() {
    echo
    echo
    echo -e "░██████╗░██╗████████╗██╗░░██╗██╗░░░██╗██████╗░"
    echo -e "██╔════╝░██║╚══██╔══╝██║░░██║██║░░░██║██╔══██╗"
    echo -e "██║░░██╗░██║░░░██║░░░███████║██║░░░██║██████╦╝"
    echo -e "██║░░╚██╗██║░░░██║░░░██╔══██║██║░░░██║██╔══██╗"
    echo -e "╚██████╔╝██║░░░██║░░░██║░░██║╚██████╔╝██████╦╝"
    echo -e "░╚═════╝░╚═╝░░░╚═╝░░░╚═╝░░╚═╝░╚═════╝░╚═════╝░"
    echo
    echo

    # Run git status and capture the output
    status_output=$(git status 2>&1)
    # Get the current branch name
    current_branch=$(git rev-parse --abbrev-ref HEAD)

    # Check the exit status of git status
    if [ $? -eq 0 ]; then
        # Check if the output contains "nothing to commit, working tree clean"
        if (echo "$status_output" | grep -q "nothing to commit, working tree clean") || [ $skip_git_status_check -eq 1 ]; then
            if [ $skip_git_status_check -eq 1 ]; then
                echo -e "${RED}Skipping ${YELLOW}dirty workspace check${RESET}"
            fi

            check_up_to_date

            # Get additional information regarding the git repository
            remote_url=$(git config --get remote.origin.url)
            repo_owner=$(echo "$remote_url" | sed -n 's/.*github.com[:/]\(.*\)\/.*/\1/p')
            repo_name=$(echo "$remote_url" | sed -n 's/.*github.com.*\/\(.*\)\.git$/\1/p')

            echo -e "Script has detected that you are on a ${YELLOW}${current_branch%%/*}${RESET} branch, please select action"

            case "$current_branch" in
                develop)
                    develop_branch_actions
                    ;;
                feature/*)
                    parent_branch="develop"
                    pr_branch_actions
                    ;;
                bugfix/*)
                    parent_branch="develop"
                    pr_branch_actions
                    ;;
                ci/*)
                    parent_branch="develop"
                    pr_branch_actions
                    ;;
                *)
                    echo -e "${RED}This shouldn't happen${RESET}!"
                    ;;
            esac        
        else
            echo -e "${RED}Workspace is dirty, please cleanup and retry again${RESET}"
            add_commit_push_changes_question
        fi
    else
        echo -e "${RED}Workspace corrupt, please fix and retry later${RESET}"
    fi
}

# #############################################################################
# Creates a new feature/hotfix branch, checkout the new branch, 
# adds hash to the version and pushes it up to GitHub.
# #############################################################################

function create_branch() {
    echo -e "${BLUE}Creating new branch${RESET}"

    git pull
    if [ $? -ne 0 ]; then
        echo -e "${RED}Workspace mandatory_failed to update to latest, please cleanup and retry again${RESET}"
        exit 1
    fi

    git branch $new_branch_name
    git checkout $new_branch_name

    case "$branch_name" in
        "feature" | "bugfix")
            hash=$((openssl rand -hex 4) | tr -d '\n' | tr -d '\r')
            mvn build-helper:parse-version versions:set -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.incrementalVersion}-$hash-SNAPSHOT
            git commit -am "Amend version"
            echo -e "${BLUE}Amend version${RESET}"
            ;;
        "release")
            mvn build-helper:parse-version versions:set -DnewVersion=\${parsedVersion.majorVersion}.\${parsedVersion.minorVersion}.\${parsedVersion.incrementalVersion}-RC
            git commit -am "Amend version"
            echo -e "${BLUE}Amend version${RESET}"
            ;;
        *)
            echo -e "${YELLOW}Skip amend version${RESET}!"
            ;;
    esac   

    git push --set-upstream origin $new_branch_name
    echo -e "${GREEN}Sucessfully created branch ${YELLOW}$new_branch_name${RESET}"
}

# #############################################################################
# Generates a new branch name based on the name and number of the
# ticket and creates the branch if the user accepts the request.
# #############################################################################

function generate_branch_name() {
    while true; do
        # Ask for the number of the user-story, task, or bug
        read -p "Enter the ticket number associated with $type: " number

        # Check if the input is a valid number
        if [[ $number =~ ^[0-9]+$ ]]; then
            break
        else
            echo -e "${RED}Invalid input. Do you even know what digitis are${RESET}!"
        fi
    done

    while true; do
        # Ask for the input string
        read -p "Enter the title of $type: " input_string
        
        # Check if input_string is not empty
        if [ -n "$input_string" ]; then
            break  # Break the loop if input is provided
        else
            echo -e "${RED}Invalid input. Do you have eyes in your skull bro${RESET}!"
        fi
    done

    # Convert the input string to lowercase using 'tr' command
    lowercase_string=$(echo "$input_string" | tr '[:upper:]' '[:lower:]')

    # Replace spaces with dashes using 'sed' command
    formatted_string=$(echo "$lowercase_string" | sed 's/ /-/g')
    new_branch_name="$branch_name/$type-$number-$formatted_string"

    echo -e "Generated branch name: ${YELLOW}$branch_name/${GREEN}$type-$number-$formatted_string${RESET}"

    while true; do
        read -p "Do you wish to continue and create branch $new_branch_name? [y/N]" response
        case $response in
            [yY])
                create_branch
                exit 1
                ;;
            [nN]|"")
                echo -e "${YELLOW}Skipping creation of branch $new_branch_name${RESET}"
                exit 1
                ;;
            *)
                echo -e "${RED}Invalid input. Do you even code bro${RESET}!"
                ;;
        esac
    done
}

# #############################################################################
# Get's ticket information and kicks of the generation of feature branch
# #############################################################################

function feature_branch_ticket() {
    # Ask for the type of the ticket
    PS3="Select the ticket type: "
    options=("user-story" "task")

    select type in "${options[@]}"; do
        case "$type" in
            "user-story" | "task")
                break
                ;;
            *)
                echo -e "${RED}Invalid choice. Do you even read bro${RESET}!"
                ;;
        esac
    done

    generate_branch_name
}

# #############################################################################
# Get's ticket information and kicks of the generation of feature branch
# #############################################################################

function hotfix_branch_ticket() {
    # Ask for the type of the ticket
    PS3="Select the ticket type: "
    options=("bug")

    select type in "${options[@]}"; do
        case "$type" in
            "bug")
                break
                ;;
            *)
                echo -e "${RED}Invalid choice. Do you even read bro${RESET}!"
                ;;
        esac
    done

    branch_name="hotfix"
    generate_branch_name
}

# #############################################################################
# Get's ticket information and kicks of the generation of feature branch
# #############################################################################

function release_branch_ticket() {
    # Ask for the type of the ticket
    PS3="Select the ticket type: "
    options=("user-story" "task")

    select type in "${options[@]}"; do
        case "$type" in
            "user-story" | "task")
                break
                ;;
            *)
                echo -e "${RED}Invalid choice. Do you even read bro${RESET}!"
                ;;
        esac
    done

    branch_name="release"
    generate_branch_name
}

# #############################################################################
# Provides the user with the option to create a hotfix branch
# #############################################################################

function main_branch_actions() {
    PS3="What would you like to do? "
    options=("hotfix")

    select action in "${options[@]}"; do
        case "$action" in
            "hotfix")
                break
                ;;
            *)
                echo -e "${RED}Invalid choice. Do you need glasses bro${RESET}!"
                ;;
        esac
    done

    case "$action" in
        hotfix)
            hotfix_branch_ticket
            ;;
        *)
            echo -e "${RED}This shouldn't happen in method main_branch_actions${RESET}!"
            ;;
    esac   
}

# #############################################################################
# Provides the user with the option to create a feature and/or release branch
# #############################################################################

function develop_branch_actions() {
    PS3="What would you like to do? "
    # options=("build" "ci" "docs" "feature" "refactor" "release" "style" "test" "clean")
    options=("feature" "bugfix" "ci" "clean")

    select action in "${options[@]}"; do
        case "$action" in
            # "build" | "ci" | "docs" | "feature" | "refactor" | "release" | "style" | "test" | "clean")
            "feature" | "bugfix" | "ci" | "clean")
                break
                ;;
            *)
                echo -e "${RED}Invalid choice. Do you need glasses bro${RESET}!"
                ;;
        esac
    done

    case "$action" in
        feature)
            branch_name="feature"
            feature_branch_ticket
            ;;
        bugfix)
            branch_name="bugfix"
            feature_branch_ticket
            ;;
        ci)
            branch_name="ci"
            feature_branch_ticket
            ;;
        clean)
            clean_branches
            ;;
        *)
            echo -e "${RED}This shouldn't happen in method develop_branch_actions${RESET}!"
            ;;
    esac   
}

# #############################################################################
# Deletes all local branches which do not exist on remote
# #############################################################################

function clean_branches() {
    while true; do
        read -p "Do you wish to delete all local branches which do not exist on remote? [y/N]" response
        case $response in
            [yY])
                git fetch -p ; git branch -r | awk '{print $1}' | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk '{print $1}' | xargs git branch -d
                echo -e "${GREEN}Obosolete branches pruned.${RESET}"
                break
                ;;
            [nN]|"")
                exit 1
                ;;
            *)
                echo -e "${RED}Invalid input. Do you even bash bro${RESET}!"
                ;;
        esac
    done
}

# #############################################################################
# Provides the user with the option to create a pull request from 
# feature, release and/or hotfix branch.
# #############################################################################

function pr_branch_actions() {
    PS3="What would you like to do? "
    options=("pr")

    select action in "${options[@]}"; do
        case "$action" in
            "pr")
                break
                ;;
            *)
                echo -e "${RED}Invalid choice. Do you need glasses bro${RESET}!"
                ;;
        esac
    done

    case "$action" in
        pr)
            pr_branch
            ;;
        *)
            echo -e "${RED}This shouldn't happen in method pr_branch_actions${RESET}!"
            ;;
    esac   
}

# #############################################################################
# Creates a pull request using GitHub CLI.  If the branch to PR is a release
# or hotfix branch then it creates a copy of that branch and prefixes it with
# auto and creates a PR to develop from the auto branch.
# #############################################################################

function pr_branch() {    
    # Remove the word before '/'
    title="${current_branch#*/}"
    # Extract ticket number
    number=$(echo "$title" | grep -oE 'task-([0-9]+)' | grep -oE '[0-9]+')
    # Capitilise the string and remove hypens 
    title=$(echo "$title" | awk -F- '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1')
    #Build DevOps Azure board link
    link="AB#$number"

    tmp_pull_request=$(mktemp)
    sed  "s/\$board_link/$link/g" .github/pull_request_template.md > $tmp_pull_request
    gh pr create --base $parent_branch --head $current_branch --repo $repo_owner/$repo_name --title "$title" --body-file $tmp_pull_request

    while true; do
        read -p "Do you wish to delete $current_branch? [y/N]" response
        case $response in
            [yY])
                git checkout develop
                git branch -d $current_branch 
                echo -e "${GREEN}Created PR, switched back to develop branch and deleted local branch $current_branch.${RESET}"
                break
                ;;
            [nN]|"")
                echo -e "${GREEN}Created PR, from local branch $current_branch.${RESET}"
                exit 1
                ;;
            *)
                echo -e "${RED}Invalid input. Do you even bash bro${RESET}!"
                ;;
        esac
    done

    echo -e "${YELLOW}PR has been created please update details${RESET}!"
}

# #############################################################################
# Asks the user if they wish to commit and push local changes before 
# the script continues with the selected action.
# #############################################################################

function add_commit_push_changes_question() {
    while true; do
        read -p "Do you want to add, commit and push all local changes before we continue on $current_branch? [y/N]" response
        case $response in
            [yY])
                add_commit_push_changes
                break
                ;;
            [nN]|"")
                echo -e "${YELLOW}Try the following commands to clean up your workspace:${RESET}"
                echo -e "${YELLOW} - git add .${RESET}"
                echo -e "${YELLOW} - git commit -am 'snapshot'${RESET}"
                exit 1
                ;;
            *)
                echo -e "${RED}Invalid input. Do you even code bro${RESET}!"
                ;;
        esac
    done
}

# #############################################################################
# Checks if the local repository is up to date with the remote, by generating
# hashes of the local and remote repository and comparing the hashes.
# #############################################################################

function check_up_to_date() {
    if [ $skip_git_up_to_date_check -eq 1 ]; then
        echo -e "${RED}Skipping ${YELLOW}checking if the repository is up to date with remote${RESET}"
        return
    fi

    echo -e "${BLUE}Please wait while checking if the repository is up to date with remote${RESET}"

    # Fetch the latest information from the remote repository
    git fetch
    
    # Get the commit hashes of the local and remote branches
    local_hash=$(git rev-parse "$current_branch")
    remote_hash=$(git rev-parse "origin/$current_branch")
    
    if [ "$local_hash" = "$remote_hash" ]; then
        echo -e "${GREEN}Local branch '$current_branch' is up to date with remote branch '$current_branch'.${RESET}\n"
    else
        echo -e "${YELLOW}Local branch '$current_branch' is ${RED}NOT${YELLOW} up to date with remote branch '$current_branch'.${RESET}\n"
        pull_changes_question
    fi
}

# #############################################################################
# Commit's and pushes the local changes to the remote. But before doing so
# asks the user for a commit message, if non is provided it defaults the message
# 'snapshot'
# #############################################################################

function add_commit_push_changes() {
    while true; do
        # Ask for commit message
        read -p "Please provide a commit message to continue on $current_branch?" response
        
        # Check if input_string is not empty
        if [ -n "$response" ]; then
            break  # Break the loop if input is provided
        else
            echo -e "${RED}Invalid input. Who allowed you to code${RESET}!"
        fi
    done

    git add .
    git commit -am "$response"

    check_up_to_date
    
    git push

    github_actions
}

# #############################################################################
# Asks the user if they wish to pull remote changes changes before the script
# continues with the selected action.
# #############################################################################

function pull_changes_question() {
    while true; do
        read -p "Do you want to pull the latest changes from remote into $current_branch? [y/N]" response
        case $response in
            [yY])
                git pull
                echo -e "${GREEN}All up to date, lets continue...${RESET}"
                break
                ;;
            [nN]|"")
                echo -e "${YELLOW}Try the following commands to clean up your workspace:${RESET}"
                echo -e "${YELLOW} - git pull${RESET}"
                exit 1
                ;;
            *)
                echo -e "${RED}Invalid input. Do you even code bro${RESET}!"
                ;;
        esac
    done
}

# #############################################################################
# Entry Point
# #############################################################################

main_actions
