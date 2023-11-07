checkInput() {
  message="${1}";
  var="${2}";

  if [[ "${var}" == "" ]];
  then
    echo "Input Error. ${message} not found.";
    exit 1;
  else
    echo "${message} : ${var}";
  fi;
}

checkInput "targetCluster" "$1";
checkInput "configmapName" "$2";
checkInput "namespace" "$3";
checkInput "targetNamespace" "$4";

targetCluster=$1
configmapName=$2
namespace=$3
targetNamespace=$4

export KUBECONFIG=${targetCluster};

echo "Getting configmap from cluster";
kubectl -n "${namespace}" get cm "${configmapName}" -o json || exit 1;
kubectl -n "${namespace}" get cm "${configmapName}" -o json > temp.json;

echo "Removing unnecessary values";
jq '{apiVersion,data,kind,metadata} | .metadata |= {"name"}' temp.json || exit 1;
jq '{apiVersion,data,kind,metadata} | .metadata |= {"name"}' temp.json > jqResult.json;

echo "Deploying updated configmap";
kubectl -n "${targetNamespace}" apply -f jqResult.json || exit 1;
kubectl -n "${targetNamespace}" get cm "${configmapName}" || exit 1;

echo "Removing unnecessary files";
rm temp.json || exit 1;
rm jqResult.json || exit 1;

echo "Done";