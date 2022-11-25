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

log () {
  message="${1}";
  printf '%s ' "$(date -u)"; echo "${message}";
}

log "Reading inputs from config file";

secretsDirectory=$(jq -r '.secretsDirectory' config.json);
commandExitCode=$?; checkCommandExitCode "${message}" ${commandExitCode};
log "Secrets Directory: ${secretsDirectory}";

credentials=$(jq -r '.password' config.json);
commandExitCode=$?; checkCommandExitCode "${message}" ${commandExitCode};

decryptedPass=$(echo ${credentials} | base64 --decode);
commandExitCode=$?; checkCommandExitCode "${message}" ${commandExitCode};
log "Zip file password: ${decryptedPass}";

innerZipFileName=$(jq -r '.innerZipFileName' config.json);
commandExitCode=$?; checkCommandExitCode "${message}" ${commandExitCode};
log "Inner Zip file name: ${innerZipFileName}";

zipFileName=$(jq -r '.zipFileName' config.json);
commandExitCode=$?; checkCommandExitCode "${message}" ${commandExitCode};
log "zip file name: ${zipFileName}";

log "Done";

log "Deleting already present zip files";
rm -f ${innerZipFileName};
rm -f ${zipFileName};
log "Done";

log "Creating inner zip file";
zip ${innerZipFileName} -r ${secretsDirectory};
commandExitCode=$?; checkCommandExitCode "${message}" ${commandExitCode};
log "Done";

log "Creating outer zip file";
zip --password ${decryptedPass} ${zipFileName} ${innerZipFileName};
commandExitCode=$?; checkCommandExitCode "${message}" ${commandExitCode};
log "Done";

# Zip file creation completed
log "Deleting inner zip file";
rm -f ${innerZipFileName};
log "Done";
