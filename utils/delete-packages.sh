#!/bin/bash

# Prompt the user for their GitHub token
echo -n "Enter your GitHub token: "
read -s GITHUB_TOKEN
echo

# Function to delete package versions
delete_package_versions() {
    local package_name=$1
    versions=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/users/$REPO_OWNER/packages/container/$package_name/versions" | jq -r '.[].id')

    for version in $versions; do
        echo "Deleting version $version of package $package_name"
        response=$(curl -X DELETE -s -H "Authorization: token $GITHUB_TOKEN" \
            -H "Accept: application/vnd.github.v3+json" \
            "https://api.github.com/users/$REPO_OWNER/packages/container/$package_name/versions/$version")
        if echo "$response" | grep -q "You cannot delete the last tagged version of a package"; then
            echo "Cannot delete the last tagged version. Deleting the entire package $package_name."
            delete_entire_package $package_name
            break
        fi
    done
}

# Function to delete entire package
delete_entire_package() {
    local package_name=$1
    echo "Deleting the entire package $package_name"
    curl -X DELETE -s -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/users/$REPO_OWNER/packages/container/$package_name"
}

# List all packages for the user
response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/users/$REPO_OWNER/packages?package_type=container")

# Debug: Print the response to understand its structure
echo "API Response:"
echo "$response"

# Extract package names from the response
packages=$(echo "$response" | jq -r '.[].name')

# Loop through each package and delete all versions
for package in $packages; do
    echo "Processing package $package"
    delete_package_versions $package
done

echo "All packages deleted."
