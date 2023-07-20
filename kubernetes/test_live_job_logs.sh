checkInput() {
  inputVar="${1}"
  if [[ "${inputVar}" == "" ]];
  then
    echo "Input error. Some inputs are missing";
    echo "run script like this: sh ./test_live_job_logs.sh KUBECONFIG namespace"
    exit 1;
  fi;
}

KUBECONFIG="${1}";
checkInput "${KUBECONFIG}";

namespace="${2}";
checkInput "${namespace}";

echo "Namespace: ${namespace}";

jobName="prashik-job-test";
jobFile="sample_job.json"

echo "Deleting existing job";
kubectl -n "${namespace}" delete -f "${jobFile}";

echo "Creating job";
kubectl -n "${namespace}" apply -f "${jobFile}";

echo "Printing job logs";
kubectl -n "${namespace}" logs -f job.batch/"${jobName}";
# We cannot get logs any longer. Either pod job succeeded or it got restarted.

echo "Getting status of the running job";
status=$(kubectl -n "${namespace}" get job "${jobName}" -o jsonpath={.status.succeeded} --ignore-not-found=true)
echo "Job Status: ${status}";

if [[ "${status}" == "" ]];
then
  echo "Kubernetes job has failed.";
  exit 1;
fi;

echo "Job succeeded";