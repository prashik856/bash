checkCommandExitCode(){
    message="${1}";
    commandExitCode=${2};

    if [[ ${commandExitCode} -ne 0 ]];
    then
        printf '%s ' "$(date -u)"; echo "Error while ${message}";
        printf '%s ' "$(date -u)"; echo "Exiting...";
        exit 1;
    fi;
}

message="Reading inputs from config file";
printf '%s ' "$(date -u)"; echo "${message}";
secretsDirectory=$(jq -r '.secretsDirectory' config.json);
commandExitCode=$?; checkCommandExitCode "${message}" ${commandExitCode};
credentials=$(jq -r '.password' config.json);
commandExitCode=$?; checkCommandExitCode "${message}" ${commandExitCode};
decryptedPass=$(echo ${credentials} | base64 --decode);
commandExitCode=$?; checkCommandExitCode "${message}" ${commandExitCode};
innerZipFileName=$(jq -r '.innerZipFileName' config.json);
commandExitCode=$?; checkCommandExitCode "${message}" ${commandExitCode};
zipFileName=$(jq -r '.zipFileName' config.json);
commandExitCode=$?; checkCommandExitCode "${message}" ${commandExitCode};
currentDay=$(date '+%d');
currentDirectory=$(pwd);
zipFileName="${zipFileName}_${currentDay}.zip";
printf '%s ' "$(date -u)"; echo "Done";

message="Deleting already present zip files";
printf '%s ' "$(date -u)"; echo "${message}";
rm -f ${innerZipFileName};
rm -f ${zipFileName};
printf '%s ' "$(date -u)"; echo "Done";

message="Creating inner zip file";
printf '%s ' "$(date -u)"; echo "${message}";
zip ${innerZipFileName} -r ${secretsDirectory};
commandExitCode=$?; checkCommandExitCode "${message}" ${commandExitCode};
printf '%s ' "$(date -u)"; echo "Done";

message="Creating outer zip file";
printf '%s ' "$(date -u)"; echo "${message}";
zip --password ${decryptedPass} ${zipFileName} ${innerZipFileName};
commandExitCode=$?; checkCommandExitCode "${message}" ${commandExitCode};
printf '%s ' "$(date -u)"; echo "Done";

message="Deleting inner zip file";
printf '%s ' "$(date -u)"; echo "${message}";
rm -f ${innerZipFileName};
printf '%s ' "$(date -u)"; echo "Done";

message="Backing up secrets file to drive";
printf '%s ' "$(date -u)"; echo "${message}";
python3 -m drive.app;
commandExitCode=$?; checkCommandExitCode "${message}" ${commandExitCode};
printf '%s ' "$(date -u)"; echo "Done";

message="Deleting secrets zip file";
printf '%s ' "$(date -u)"; echo "${message}";
rm -f ${zipFileName};
printf '%s ' "$(date -u)"; echo "Done";