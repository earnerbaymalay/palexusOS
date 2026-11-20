#!/usr/bin/env python
"""PalexusOS core modules setup.

Provides:
- TokenRegistry: Design system (colors, typography, spacing)
- GateRegistry: Quality verification gates
- DesktopEnvironment: Boot sequence orchestration
- TestOrchestrator: Unified testing framework
"""

from setuptools import setup, find_packages

setup(
    name="palexus",
    version="0.1.0",
    description="PalexusOS: AI-native Linux distribution core modules (TokenRegistry, GateRegistry, DesktopEnvironment, TestOrchestrator)",
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    author="earnerbaymalay",
    author_email="earnerbaymalay@gmail.com",
    url="https://github.com/earnerbaymalay/palexusOS",
    license="MIT",
    packages=find_packages(exclude=["tests", "docs", "build", "overlay", "packages", "scripts"]),
    python_requires=">=3.9",
    install_requires=[],
    extras_require={
        "dev": ["pytest>=7.0", "black", "mypy", "ruff"],
        "test": ["pytest>=7.0"],
    },
    classifiers=[
        "Development Status :: 3 - Alpha",
        "Environment :: Console",
        "Intended Audience :: Developers",
        "Intended Audience :: System Administrators",
        "License :: OSI Approved :: MIT License",
        "Operating System :: Linux",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Topic :: Software Development :: Libraries :: Python Modules",
        "Topic :: System :: Operating System Kernels :: Linux",
    ],
    entry_points={
        "console_scripts": [
            "palexus-design=palexus.design.cli:main",
            "palexus-build=palexus.build.cli:main",
            "palexus-test=palexus.test.cli:main",
        ],
    },
)
