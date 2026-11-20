#!/usr/bin/env python
"""PalexusOS core modules setup."""

from setuptools import setup, find_packages

setup(
    name="palexus",
    version="0.1.0",
    description="PalexusOS: AI-native Linux distribution core modules",
    author="earnerbaymalay",
    author_email="earnerbaymalay@gmail.com",
    packages=find_packages(exclude=["tests", "docs", "build", "overlay", "packages", "scripts"]),
    python_requires=">=3.9",
    install_requires=[],
    extras_require={
        "dev": ["pytest>=7.0", "black", "mypy", "ruff"],
    },
    entry_points={
        "console_scripts": [
            "palexus-design=palexus.design.cli:main",
            "palexus-build=palexus.build.cli:main",
            "palexus-test=palexus.test.cli:main",
        ],
    },
)
