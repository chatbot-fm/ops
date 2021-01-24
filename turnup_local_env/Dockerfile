FROM ubuntu:20.10
ENV USER=root

RUN \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y apt-utils less
    
RUN echo "resolvconf resolvconf/linkify-resolvconf boolean false" | debconf-set-selections

RUN \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
	apt-get install -y bash tmux fonts-powerline wget rsync git curl jq wireguard \
	iputils-ping emacs iproute2 net-tools traceroute wireguard-dkms lsof resolvconf tar \
	pkg-config zip g++ zlib1g-dev unzip python \
        make libssl-dev

RUN \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y resolvconf

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get purge && apt-get autoremove -y && apt-get clean -y

# prepare opt dirs
RUN mkdir -p /root/opt/app
RUN mkdir -p /root/opt/bin

# setup generic tools
COPY ./apps/powerline-go /root/opt/bin/
COPY ./conf/.tmux.conf /root/
COPY ./conf/.bash_profile /root/
RUN touch /root/.bashrc
RUN echo "source /root/.bash_profile" >> /root/.bashrc

# setup terraform with providers
COPY ./apps/terraform /root/opt/bin/
RUN mkdir -p /root/.terraform.d/plugins/linux_amd64
COPY ./providers/terraform-provider-rke_linux-amd64 /root/terraform.d/plugins/linux_amd64/

# setup kubectl
COPY ./apps/kubectl /root/opt/bin/

# setup packer
COPY ./apps/packer_1.6.6_linux_amd64.zip /root/opt/bin
RUN unzip /root/opt/bin/packer_1.6.6_linux_amd64.zip -d /root/opt/bin
RUN rm /root/opt/bin/packer_1.6.6_linux_amd64.zip

# setup ansible
RUN \
    DEBIAN_FRONTEND=noninteractive \
    apt install -y python3 python3-pip python3-argcomplete ssh && \
    pip3 install --user ansible


# setup clang
#COPY ./apps/clang+llvm-11.0.0-x86_64-linux-gnu-ubuntu-20.04.tar.xz /root/opt/app/
#RUN tar -xvf /root/opt/app/clang+llvm-11.0.0-x86_64-linux-gnu-ubuntu-20.04.tar.xz -C /root/opt/app
#RUN ln -s /root/opt/app/clang+llvm-11.0.0-x86_64-linux-gnu-ubuntu-20.04 /root/opt/app/clang

# setup bazel
COPY ./apps/bazel-4.0.0-linux-x86_64 /root/opt/bin/bazel

# setup rust
RUN mkdir -p /root/.cargo/bin
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

# setup zola
COPY ./apps/zola-v0.13.0-x86_64-unknown-linux-gnu.tar.gz /root/opt/app
RUN tar -xf /root/opt/app/zola-v0.13.0-x86_64-unknown-linux-gnu.tar.gz -C /root/opt/bin

# make custom binaries executable
RUN chmod +x /root/opt/bin/*

# Volume for SRC
VOLUME /root/src

# Volume for secrets
RUN mkdir /root/shadow
VOLUME /root/shadow

# Google Cloud specific vars
ENV GCLOUD_KEYFILE_JSON "/root/shadow/credentials.json"

WORKDIR /root

ENTRYPOINT ["/bin/systemd", "--system", "--unit=basic.target"]
