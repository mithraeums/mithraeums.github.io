#!/usr/bin/env sh
# Mithraeum installer proxy — hakm (the hako engine).
# Short URL: curl -fsSL https://mithraeums.github.io/hakm.sh | sh
# Fetches a release for this OS/arch, or builds from source on iSh (32-bit).
# No ollama. Weights come afterwards: hakm pull hako-sho
exec curl -fsSL "https://raw.githubusercontent.com/mithraeums/hako/main/install.sh" | sh
