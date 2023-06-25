#!/usr/bin/env python3
import argparse
import subprocess


def main():
    region, image, uri, dockerfile = parse_flags()

    subprocess.run(
        f'aws ecr get-login-password --region {region} | docker login --username AWS --password-stdin {uri}', shell=True)
    subprocess.run(f'docker build -t {image} {dockerfile}', shell=True)
    subprocess.run(f'docker tag {image} {uri}/{image}', shell=True)
    subprocess.run(f'docker push {uri}/{image}', shell=True)
 

def parse_flags():
    """
    Parse the flags required to push the image to ECR.

    Function returns a tuple of the form:
    (region, image, remote_image, dockerfile)
    """

    parser = argparse.ArgumentParser(description="""
    Shell script to push docker image to ECR.
    """)

    parser.add_argument('-u', '-aws-user', dest='aws_user',
                        help='aws user', required=True)
    parser.add_argument('-r', '-region', dest='region',
                        help='aws region', default='eu-west-2')
    parser.add_argument('-n', '-name', dest='name',
                        help='name of docker image', required=True)
    parser.add_argument('-t', '-tag', dest='tag',
                        help='tag of docker image', default='latest')
    parser.add_argument('dockerfile', help='dockerfile directory', default='.')
    flags = parser.parse_args()

    aws_user: str = getattr(flags, 'aws_user')
    region: str = getattr(flags, 'region')
    image_name: str = getattr(flags, 'name')
    image_tag: str = getattr(flags, 'tag')
    dockerfile: str = getattr(flags, 'dockerfile')

    return (region, f'{image_name}:{image_tag}', f'{aws_user}.dkr.ecr.{region}.amazonaws.com', dockerfile)


if __name__ == "__main__":
    main()
