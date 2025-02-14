import json

with open('iam.json', 'r') as f:
    users = json.load(f)

findings = set()  # Use a set to store unique project names

for user in users:
    project_id = user['cloud_vendor_id']
    findings.add(project_id)

# Convert the set to a list for JSON serialization
project_names = list(findings)

# Save the list of project names to a JSON file
with open('project_names.json', 'w') as output_file:
    json.dump(project_names, output_file)

print(f"Total project names found: {len(project_names)}")

# Need to add more documentation