from setuptools import setup, find_packages

setup(
    name='mini-plugin',
    packages=find_packages(),
    install_requires=['kubernetes'],
    version='0.1.0',
)