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

log "Getting script working directory";
cwd=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd );
log "Script Working Directory: ${cwd}";


configDirectory="${cwd}/config.json";
log "Reading inputs from config file";

secretsDirectory=$(jq -r '.secretsDirectory' ${configDirectory});
commandExitCode=$?; checkCommandExitCode "${message}" ${commandExitCode};
log "Secrets Directory: ${secretsDirectory}";

credentials=$(jq -r '.password' ${configDirectory});
commandExitCode=$?; checkCommandExitCode "${message}" ${commandExitCode};

decryptedPass=$(echo ${credentials} | base64 --decode);
commandExitCode=$?; checkCommandExitCode "${message}" ${commandExitCode};
log "Zip file password: ${decryptedPass}";

innerZipFileName=$(jq -r '.innerZipFileName' ${configDirectory});
commandExitCode=$?; checkCommandExitCode "${message}" ${commandExitCode};
log "Inner Zip file name: ${innerZipFileName}";

zipFileName=$(jq -r '.zipFileName' ${configDirectory});
commandExitCode=$?; checkCommandExitCode "${message}" ${commandExitCode};
log "zip file name: ${zipFileName}";

syncDirectory=$(jq -r '.syncDirectory' ${configDirectory});
commandExitCode=$?; checkCommandExitCode "${message}" ${commandExitCode};
log "Sync Directory: ${syncDirectory}";

log "Creating inner zip file";
zip ${innerZipFileName} -r ${secretsDirectory};
commandExitCode=$?; checkCommandExitCode "${message}" ${commandExitCode};
log "Done";

log "Creating outer zip file";
zip --password ${decryptedPass} ${zipFileName} ${innerZipFileName};
commandExitCode=$?; checkCommandExitCode "${message}" ${commandExitCode};
log "Done";

log "Deleting inner zip file";
rm -f ${innerZipFileName};
log "Done";

log "Moving zip file to sync directory";
mv -f ${zipFileName} ${syncDirectory}/${zipFileName};
log "Done";
