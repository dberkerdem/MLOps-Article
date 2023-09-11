# MLOps-Article


  docker run -d --name clearml-agent-1 \
  -e CLEARML_AGENT_K8S_CPU_LIMIT="1" \
  -e CLEARML_AGENT_K8S_CPU_REQUEST="1" \
  allegroai/clearml-agent:latest