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
count=0;
while [[ ${count} -lt 20 ]];
do
  # This command always exits with 0 regardless if job failed or passed.
  # If we are not able to get job logs, that means that job did not start.
  kubectl -n "${namespace}" logs -f job.batch/"${jobName}";
  exitCode=$?;
  if [[ ${exitCode} -ne 0 ]];
  then
    count=$((count+1));
    log "Trying again to get logs again: ${count}..."
    sleep 6;
  else
    break;
  fi;
done;

if [[ ${count} -ge 20 ]];
then
  kubectl -n "${namespace}" get job "${jobName}";
  log "Count not start job. Exiting...";
  exit 255;
fi;

sleep 10;

# We cannot get logs any longer. Either pod job succeeded or it got restarted.
echo "Getting status of the running job";
kubectl -n "${namespace}" get job "${jobName}";
status=$(kubectl -n "${namespace}" get job "${jobName}" -o jsonpath={.status.succeeded} --ignore-not-found=true)
echo "Job Status: ${status}";

if [[ "${status}" == "" ]];
then
  echo "Kubernetes job has failed.";
  exit 1;
fi;

echo "Job succeeded";