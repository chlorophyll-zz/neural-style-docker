FROM nvidia/cuda:7.5-cudnn5-devel
MAINTAINER "Álvaro Barbero Jiménez, https://github.com/albarji"

# Install git and other system dependencies
RUN apt-get update && apt-get install -y \
	git \
	libprotobuf-dev \
	protobuf-compiler \
	wget

# Install torch
RUN git clone https://github.com/torch/distro.git /torch --recursive && \
	cd /torch && \ 
	bash install-deps && \
	./install.sh
# Add torch to path
ENV PATH /torch/install/bin:$PATH

# Install loadcaffe and other torch dependencies
RUN luarocks install loadcaffe

# Clone neural-style app
RUN git clone https://github.com/jcjohnson/neural-style.git
WORKDIR neural-style

# Download precomputed network weights
RUN bash models/download_models.sh
RUN mkdir /models

# Declare volume for storing network weights
VOLUME ["/neural-style/models"]

# Install python miniconda
RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-4.0.5-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
	rm ~/miniconda.sh
ENV PATH /opt/conda/bin:$PATH

# Install python dependencies
RUN conda install scikit-image
RUN pip install connexion

# Copy server app
COPY server /neural-style
ENTRYPOINT python app.py