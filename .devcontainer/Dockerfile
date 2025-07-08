FROM ghcr.io/dbt-labs/dbt-core:1.9.1

ENV _LINUX_USER=devcontainer
RUN apt-get update &&\
    apt-get install apt-transport-https ca-certificates gnupg curl sudo git -y --no-install-recommends --no-install-suggests &&\
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list &&\
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg &&\
    apt-get update -y && apt-get install google-cloud-sdk -y --no-install-recommends --no-install-suggests &&\
    apt-get clean && rm -rf /var/lib/apt/lists/* &&\
    adduser ${_LINUX_USER} && passwd -d ${_LINUX_USER} && usermod -aG sudo ${_LINUX_USER}

# non-root stuff:
USER ${_LINUX_USER}

ENV _DOCKER_BUILD_TMP_FOLDER=/tmp/docker_build
RUN mkdir -p ${_DOCKER_BUILD_TMP_FOLDER}
COPY requirements.txt ${_DOCKER_BUILD_TMP_FOLDER}/requirements.txt
RUN pip install --no-cache-dir --user -r \
    ${_DOCKER_BUILD_TMP_FOLDER}/requirements.txt &&\
    rm -r ${_DOCKER_BUILD_TMP_FOLDER}

# Make sure the /workspaces folder is owned by the correct user
ENV _DEVCONTAINER_MOUNT_FOLDER=/workspaces
USER root
RUN mkdir -p ${_DEVCONTAINER_MOUNT_FOLDER} &&\
    chown -R ${_LINUX_USER} ${_DEVCONTAINER_MOUNT_FOLDER}

# Switch back to intended user
USER ${_LINUX_USER}
