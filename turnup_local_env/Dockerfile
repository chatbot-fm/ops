FROM ubuntu:20.10

############################################################################## root setup
RUN \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y apt-utils less
    
RUN echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections

####### Since docker doesn't support comments in the middle of a command, here is the
####### list of what is getting installed by apt line-by-line:
####### system critical services & utils
####### useful utils
####### vpn client, networking
####### c++/llvm dev
####### rust language server dependency
####### python dev
####### frontend dev
####### X11 server & appearence

RUN \
    apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y \
	pkg-config bash ssh \
	tmux wget rsync git curl jq emacs tar unzip zip htop apache2-utils \
	wireguard iproute2 net-tools traceroute wireguard-dkms lsof resolvconf iputils-ping \
	g++ zlib1g-dev make libssl-dev \
	libssl-dev \
	python python3 python3-pip python3-argcomplete \
	nodejs npm \
	xserver-xorg-core xinit x11-apps xfonts-terminus fonts-powerline

# cleanup apt
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get purge && apt-get autoremove -y && apt-get clean -y

# Configure system ssh: disable ssh password
RUN echo "PasswordAuthentication no" >> /etc/ssh/sshd_config

# Configure system: create admin user
RUN groupadd -r admin --gid 1000 && useradd -d /home/admin -m -s /bin/bash -r -g admin admin --uid 1000
RUN echo "admin ALL=(ALL)     NOPASSWD:ALL" >> /etc/sudoers
ENV ADMIN_HOME=/home/admin

############################################################################## regular user setup
USER admin

# prepare opt dirs
RUN mkdir -p $ADMIN_HOME/opt/app
RUN mkdir -p $ADMIN_HOME/opt/bin

# setup generic tools
COPY --chown=admin ./apps/powerline-go $ADMIN_HOME/opt/bin/
COPY --chown=admin ./conf/.tmux.conf $ADMIN_HOME
COPY --chown=admin ./conf/.bash_profile $ADMIN_HOME

# setup terraform with providers
COPY --chown=admin ./apps/terraform $ADMIN_HOME/opt/bin/
RUN mkdir -p $ADMIN_HOME/.terraform.d/plugins/linux_amd64
COPY --chown=admin ./providers/terraform-provider-rke_linux-amd64 $ADMIN_HOME/terraform.d/plugins/linux_amd64/

# setup ansible
RUN pip3 install --user ansible

# setup kubectl
COPY --chown=admin ./apps/kubectl $ADMIN_HOME/opt/bin/

# setup packer
COPY --chown=admin ./apps/packer_1.7.0_linux_amd64.zip $ADMIN_HOME/opt/bin
RUN unzip $ADMIN_HOME/opt/bin/packer_1.7.0_linux_amd64.zip -d $ADMIN_HOME/opt/bin
RUN rm $ADMIN_HOME/opt/bin/packer_1.7.0_linux_amd64.zip

# setup bazel
COPY --chown=admin ./apps/bazel-4.0.0-linux-x86_64 $ADMIN_HOME/opt/bin/bazel

# setup zola
COPY --chown=admin ./apps/zola-v0.13.0-x86_64-unknown-linux-gnu.tar.gz $ADMIN_HOME/opt/app
RUN tar -xf $ADMIN_HOME/opt/app/zola-v0.13.0-x86_64-unknown-linux-gnu.tar.gz -C $ADMIN_HOME/opt/bin

# setup rust
RUN mkdir -p $ADMIN_HOME/.cargo/bin
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# setup Rust Language Server - emacs autocomplition dependency
RUN . $ADMIN_HOME/.cargo/env && cargo install cargo-rls-install
RUN . $ADMIN_HOME/.cargo/env && rustup component add rls

# make custom binaries executable
RUN chmod +x $ADMIN_HOME/opt/bin/*

# configure emacs: temporary use local configuration
VOLUME $ADMIN_HOME/.emacs.d
#COPY ./conf/.emacs.d.zip $ADMIN_HOME
#RUN unzip $ADMIN_HOME/.emacs.d.zip -d $ADMIN_HOME
#RUN rm $ADMIN_HOME/.emacs.d.zip

# Volume for SRC
VOLUME $ADMIN_HOME/src

# Volume for secrets
RUN mkdir $ADMIN_HOME/shadow
VOLUME $ADMIN_HOME/shadow

# Configure ssh
RUN mkdir $ADMIN_HOME/.ssh
COPY --chown=admin ./conf/id_rsa.pub $ADMIN_HOME/.ssh/
RUN touch $ADMIN_HOME/.ssh/authorized_keys
RUN cat $ADMIN_HOME/.ssh/id_rsa.pub >> $ADMIN_HOME/.ssh/authorized_keys

# Expose ssh port
EXPOSE 22

# needed for systemd
VOLUME "/sys/fs/cgroup"

# X11 appearance config: emacs font setup
RUN mkdir $ADMIN_HOME/.fonts
COPY --chown=admin ./conf/fonts.zip $ADMIN_HOME/.fonts
RUN unzip $ADMIN_HOME/.fonts/fonts.zip -d $ADMIN_HOME/.fonts
RUN rm $ADMIN_HOME/.fonts/fonts.zip
RUN mv $ADMIN_HOME/.fonts/fonts/* $ADMIN_HOME/.fonts/
RUN rmdir $ADMIN_HOME/.fonts/fonts
RUN fc-cache -f -v

# setup angular
RUN sudo npm install -g @angular/cli || true
# expose angular http dev server's port
EXPOSE 4200
# port for zola dev server
EXPOSE 1111

# setup git
RUN git config --global user.email "admin@gmail.com" && git config --global user.name "admin"

# Configure remote X11 server
VOLUME "$ADMIN_HOME/.Xauthority"
VOLUME "/tmp/.X11-unix"

# Google Cloud specific vars
# ENV GCLOUD_KEYFILE_JSON "$ADMIN_HOME/shadow/credentials.json"

WORKDIR $ADMIN_HOME

ENTRYPOINT ["/bin/systemd", "--system", "--unit=basic.target"]

