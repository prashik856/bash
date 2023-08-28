log() {
    printf '%s ' "$(date -u)"; echo "${1}";
}

checkInput() {
  message="${1}";
  var="${2}";

  if [[ "${var}" == "" ]];
  then
    log "Input Error. ${message} not found.";
    exit 1;
  else
    log "${message} : ${var}";
  fi;
}

# wallet file location
checkInput "walletFileLocation" "${1}";
checkInput "secretName" "${2}";
checkInput "targetCluster" "${3}";
checkInput "targetNamespace" "${4}";

walletFileLocation="${1}"; # We need zip file
secretName="${2}";
targetCluster="${3}";
targetNamespace="${4}";
walletDirectory="tempWallet";

read -n 1 -s -r -p "Press any key to continue"

log "Removing and recreating wallet directory";
[[ -d "${walletDirectory}" ]] && rm -r "${walletDirectory}";
mkdir "${walletDirectory}" || exit 1;

log "Unzip wallet file into ${walletDirectory}";
unzip "${walletFileLocation}" -d "${walletDirectory}" || exit 1;

log "Create kubernetes secret json";
cd "${walletDirectory}";
kubectl create secret generic "${secretName}" --from-file=. --dry-run=client --output=json > ../wallet.json;
cd ..;

export KUBECONFIG="${targetCluster}";

log "Checking if secret is already present.";
kubectl -n "${targetNamespace}" get secret "${secretName}" || exit 1;

log "checking if wallet file is present and updating secret";
[[ -f wallet.json ]] || exit 1;
kubectl -n "${targetNamespace}" apply -f wallet.json || exit 1;