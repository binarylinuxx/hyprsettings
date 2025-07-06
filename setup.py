#!/usr/bin/env python3
from setuptools import setup

setup(
    name="hyprsettings",
    version="0.2.1",
    description="GTK4/Libadwaita settings manager for Hyprland",
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    author="Nir Rudov",
    author_email="aar58384@gmail.com",
    url="https://github.com/binarylinuxx/hyprsettings",
    license="GPL-3.0-or-later",
    py_modules=["hyprsettings"],  # Use the .py file as a module
    entry_points={
        "console_scripts": [
            "hyprsettings=hyprsettings:main",
        ],
    },
    install_requires=[
        "PyGObject>=3.42.0",
    ],
    python_requires=">=3.6",
    classifiers=[
        "Development Status :: 4 - Beta",
        "Environment :: X11 Applications :: GTK",
        "Intended Audience :: End Users/Desktop",
        "License :: OSI Approved :: GNU General Public License v3 or later (GPLv3+)",
        "Operating System :: POSIX :: Linux",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.6",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Topic :: Desktop Environment",
        "Topic :: System :: Systems Administration",
    ],
    keywords="hyprland wayland settings gtk4 libadwaita",
)
