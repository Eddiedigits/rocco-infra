FROM ubuntu:noble

# Define build arguments and environment variables
# You can override the default user by passing --build-arg user=your_username when building the image
ARG user=act
ENV USER=${user}

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv sudo git nano netcat-traditional

# Create user and assign sudo privileges
RUN groupadd -r ${USER} && useradd -r -g ${USER} ${USER} && usermod -aG sudo ${USER}

# Switch to the created user
USER ${USER}

# Set working directory
WORKDIR /home/${USER}

# Expose necessary ports
EXPOSE 8080

# Create virtual environment and install Python packages
RUN python3 -m venv venv
COPY --chown=${USER}:${USER} requirements.txt .
RUN venv/bin/pip install -r requirements.txt

# Setup py4web
RUN venv/bin/py4web setup --yes apps && \
    ls -d apps/*/ | grep -v '__' | grep -v '_dashboard' | while read dir; do rm -rf "$dir"; done

# Clone Rocco application from GitHub
RUN git clone https://github.com/Eddiedigits/rocco.git apps/_default

# Copy sensitive or config files
COPY --chown=${USER}:${USER} settings_private.py apps/_default/settings_private.py
COPY --chown=${USER}:${USER} password.txt .

# Git config (safe.directory only)
RUN git config --global --add safe.directory /home/${USER}/apps/_default

# Copy and set permissions for entrypoint
COPY --chown=${USER}:${USER} entrypoint.sh .
RUN chmod +x entrypoint.sh

ENTRYPOINT ["/home/${USER}/entrypoint.sh"]
