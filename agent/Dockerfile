# Stage 1
FROM allegroai/clearml-agent:latest AS builder

RUN apt-get install -y --no-install-recommends wget && \
    apt-key del 7fa2af80 && \
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb && \
    dpkg -i cuda-keyring_1.0-1_all.deb && \
    sed -i '/nvidia/d' /etc/apt/sources.list.d/*

# Install build dependencies and Python 3.10
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential wget libssl-dev zlib1g-dev libncurses5-dev libreadline-dev libffi-dev libbz2-dev liblzma-dev && \
    wget https://www.python.org/ftp/python/3.10.0/Python-3.10.0.tgz && \
    tar -xzf Python-3.10.0.tgz && \
    cd Python-3.10.0 && \
    ./configure --enable-optimizations && \
    make altinstall && \
    cd .. && \
    rm -rf Python-3.10.0 Python-3.10.0.tgz

# Install Python packages
COPY requirements.txt .
RUN python3.10 -m pip install --no-cache-dir -r requirements.txt

# Stage 2
FROM allegroai/clearml-agent:latest

# Remove Python3.6
RUN apt-get remove -y --autoremove python3.6 && \
    apt-get clean

# Copy Python 3.10 from builder
COPY --from=builder /usr/local/bin/python3.10 /usr/local/bin/python3.10
COPY --from=builder /usr/local/lib/python3.10 /usr/local/lib/python3.10

# Make Python 3.10 the default Python version
RUN ln -sf /usr/local/bin/python3.10 /usr/bin/python3

# Set environment variables
ENV CLEARML_AGENT_UPDATE_VERSION="==1.5.3rc2" \
    CLEARML_AGENT_K8S_CPU_LIMIT="1" \
    CLEARML_AGENT_K8S_CPU_REQUEST="1" \
    CLEARML_AGENT_DEFAULT_QUEUE="default" \
    CLEARML_DOCKER_SKIP_GPUS_FLAG=1 \
    PIP_UPDATE_VERSION="==23.2.1"

COPY clearml.conf /root/clearml.conf
COPY entrypoint.sh /usr/agent/entrypoint.sh
RUN chmod +x /usr/agent/entrypoint.sh

# Set the new entrypoint
ENTRYPOINT ["/usr/agent/entrypoint.sh"]
