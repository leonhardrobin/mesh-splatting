# Use a production-grade NGC PyTorch image as base
FROM nvcr.io/nvidia/pytorch:24.03-py3

# Install system dependencies
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN pip install torch==2.7.1 torchvision==0.22.1 \
    && pip install -r requirements.txt --no-build-isolation

RUN /bin/bash -c "compile.sh"

RUN cd /submodules/simple-knn \
    && pip install . --no-build-isolation

RUN cd ../submodules/effrdel \
    && pip install -e . --no-build-isolation

# Set the working directory for the code
WORKDIR /workspace