# Copyright © 2024, Oracle and/or its affiliates.
# All rights reserved. Licensed under the Universal Permissive License (UPL), Version 1.0 as shown at https://oss.oracle.com/licenses/upl.

#!/bin/bash

# Variables Section

Oracle_Analytics_Instance_Name=${Oracle_Analytics_Instance_Name}
Tenancy_Name=${Tenancy_Name}
bucket=${bucket}
home_region_for_oac=${home_region_for_oac}

# Provide the Authorization Token to access the Analytics Instance API - maximum expiration time in the console it's: 604,800 s
# Please provide the token without ""  -> example: Authorization_Token=eyJ4NXQjUzI1NiI6ImFhN2lZUXFRSEluR
Authorization_Token=${Authorization_Token}

# OCI CLI Authentification Credentials
ociRegion=${ociRegion}
ociTenancyId=${ociTenancyId}
ociUserId=${ociUserId}
ociKeyFingerprint=${ociKeyFingerprint}

# You must pass this signing key in the payload for some snapshot APIs. Before you add it to the payload, you must Base64 encode the private key (ociPrivateKeyWrapped). For example, to generate a Base64 encoded string from your private key:
#
# On Mac: cat myprivate-key.pem | base64 -o mywrapped-private-key.pem
# On Linux: cat myprivate-key.pem | base64 -w 0 > mywrapped-private-key.pem
#
# Note: Ensure that the private key file that you encode includes -----BEGIN and -----END tags.
#
# Please provice the private key wrapped:
ociPrivateKeyWrapped=${ociPrivateKeyWrapped}

# Finished variables

export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

echo "-- Getting Started"

mkdir TowerAsset
cd TowerAsset
echo "-- Retrive the original bar file from the shared object storage"
wget -q https://objectstorage.us-ashburn-1.oraclecloud.com/p/e5v5yR0V_id-BlUrOERyrh_UqzmF-ZFVZx-EE22y-IGwvuCZBzq2z5x24ZZwclGT/n/oradbclouducm/b/DataModelsTelco/o/TowerAsset.bar
echo "-- Fixing the bar file"
unzip -qq TowerAsset.bar
rm -rf TowerAsset.bar
echo "-- Modify the links for using the current hostname of OAC, tenancy name and region key"
echo "-- Create new bar file for OAC with the custom configuration"
zip -fz TowerAsset_modified.bar -r -qq *
echo "-- Upload the snapshot to the object storage in our tenancy"
oci os object put -ns $Tenancy_Name -bn $bucket --force --file TowerAsset_modified.bar > /dev/null
cd ..
rm -rf TowerAsset
echo "-- Get details of an Analytics instance"
curl -i --header "Authorization: Bearer $Authorization_Token" --request GET https://$Oracle_Analytics_Instance_Name-$Tenancy_Name-$home_region_for_oac.analytics.ocp.oraclecloud.com/api/20210901/system 2>&1 | grep HTTP/1.1
echo "-- Create the Register Snapshot New Json File"
cat registermy_snapshot.json | jq --arg bucket $bucket --arg ociRegion $ociRegion --arg ociTenancyId $ociTenancyId --arg ociUserId $ociUserId --arg ociKeyFingerprint $ociKeyFingerprint --arg ociPrivateKeyWrapped $ociPrivateKeyWrapped '{"type":.type, "name":.name, "description":.description,"storage": { "type":"OCI_NATIVE", "bucket":$bucket, "auth": {"type":"OSS_AUTH_OCI_USER_ID", "ociRegion":$ociRegion, "ociTenancyId":$ociTenancyId, "ociUserId":$ociUserId, "ociKeyFingerprint":$ociKeyFingerprint, "ociPrivateKeyWrapped":$ociPrivateKeyWrapped}}, "bar":{"uri":"file:///TowerAsset_modified.bar"}}' > registermy_snapshot_new.json 
echo "-- Register an existing snapshot using the new json file created with all the variables based on your environment"
curl -i --header "Authorization: Bearer $Authorization_Token" --header "Content-Type: application/json" --request POST https://$Oracle_Analytics_Instance_Name-$Tenancy_Name-$home_region_for_oac.analytics.ocp.oraclecloud.com/api/20210901/snapshots -d @registermy_snapshot_new.json 2>&1 | grep HTTP/1.1
echo "-- Get all snapshots available for your OAC already registered"
curl -i --header "Authorization: Bearer $Authorization_Token" --request GET https://$Oracle_Analytics_Instance_Name-$Tenancy_Name-$home_region_for_oac.analytics.ocp.oraclecloud.com/api/20210901/snapshots 2>&1 | grep HTTP/1.1
echo "-- Get the ID of your registered snapshoot and use it in the next step"
id=`curl --silent --header "Authorization: Bearer $Authorization_Token" --request GET https://$Oracle_Analytics_Instance_Name-$Tenancy_Name-$home_region_for_oac.analytics.ocp.oraclecloud.com/api/20210901/snapshots | jq -r '.items[0].id'`
echo "-- Create the Restore Snapshot New Json File with your registered ID of the snapshot"
cat restore_mysnapshot.json | jq --arg id $id '{"snapshot": { "id":$id, "password":"TowerAssetAdmin123"}}' > restore_mysnapshot_new.json
echo ""
echo "-- Restore a snapshot in an Analytics instance"
curl -i --header "Authorization: Bearer $Authorization_Token" --header "Content-Type: application/json" --request POST https://$Oracle_Analytics_Instance_Name-$Tenancy_Name-$home_region_for_oac.analytics.ocp.oraclecloud.com/api/20210901/system/actions/restoreSnapshot -d @restore_mysnapshot_new.json 2>&1 | grep HTTP/1.1
sleep 120
rm -rf registermy_snapshot_new.json
rm -rf restore_mysnapshot_new.json
oci os object delete --bucket-name $bucket --force --object-name TowerAsset_modified.bar
echo "-- Restore Done!"
