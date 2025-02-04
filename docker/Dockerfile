FROM python:3.8-slim

WORKDIR /app

# Install git and build dependencies
RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

# Clone the repository
RUN git clone https://github.com/Mukosame/Anime2Sketch.git .

# Install PyTorch CPU version (to keep image size smaller)
RUN pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu

# Install other requirements
RUN pip install -r requirements.txt

# Install conversion dependencies
RUN pip install tensorflow onnx onnx-tf tensorflow-probability

# Create directories
RUN mkdir -p weights

# Copy the conversion script and weights
COPY convert_to_tflite.py .
COPY ./weights/weights.pt ./weights/netG.pth

# Convert model to TFLite
RUN python convert_to_tflite.py

# Copy the model to a known location
RUN cp model.tflite /app/model.tflite
