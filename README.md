<p align="center">
  <a href="https://mithraeums.github.io">
    <img src="assets/banner-mithraeum-dark.svg" alt="Mithraeum — tools for the inner chamber" width="100%"/>
  </a>
</p>

<p align="center">
  <em>Tools for the inner chamber. Quiet software for people who write code by hand.</em>
</p>

<p align="center">
  <a href="https://mithraeums.github.io"><img src="https://img.shields.io/badge/site-mithraeums.github.io-b89656?style=flat-square&labelColor=14130f" alt="site"/></a>
  <a href="https://github.com/mithraeums"><img src="https://img.shields.io/badge/org-github.com%2Fmithraeums-c8c2b2?style=flat-square&labelColor=14130f" alt="org"/></a>
  <img src="https://img.shields.io/badge/license-GPL--3.0-c8c2b2?style=flat-square&labelColor=14130f" alt="GPL-3.0"/>
  <img src="https://img.shields.io/badge/year-MMXXVI-c8c2b2?style=flat-square&labelColor=14130f" alt="MMXXVI"/>
</p>

<br>

<p align="center"><sub><b>—— I ——</b></sub></p>

## Suite

<table>
  <tr>
    <td width="40" align="center"><sub><b>I</b></sub></td>
    <td width="200"><b><a href="https://github.com/mithraeums/hako-edit">hako-edit</a></b><br/><sub>箱 · the box · <code>hake</code></sub></td>
    <td>Modal text editor in a single C file. Vim-bound, language-aware, 18 themes. <code>:rei</code> answers from inside.</td>
    <td align="right"><sub>v0.1.6</sub></td>
  </tr>
  <tr>
    <td align="center"><sub><b>II</b></sub></td>
    <td><b><a href="https://github.com/mithraeums/hako-code">hako-code</a></b><br/><sub>箱 · the agent · <code>hako</code></sub></td>
    <td>Standalone terminal AI agent. Same C99 stack. 13+ providers, persistent sessions, sha-verified self-update.</td>
    <td align="right"><sub>v0.2.1</sub></td>
  </tr>
  <tr>
    <td align="center"><sub><b>III</b></sub></td>
    <td><b><a href="https://github.com/mithraeums/hako">hako</a></b><br/><sub>· in officina · <code>hakm</code></sub></td>
    <td>Local models for the cursor on a from-scratch C engine. <code>hako-sho</code> (3B) + <code>hako-koi</code> (7B) live on HuggingFace; larger fine-tunes queued.</td>
    <td align="right"><sub><em>v0 live</em></sub></td>
  </tr>
  <tr>
    <td align="center"><sub><b>·</b></sub></td>
    <td><b><a href="https://github.com/mithraeums/skills">skills</a></b><br/><sub>箱 · behaviors</sub></td>
    <td>Markdown skills for hako-code and hako-edit. PR-driven catalog. corp is the inaugural entry.</td>
    <td align="right"><sub>pre-1.0</sub></td>
  </tr>
</table>

<p align="center"><sub><b>—— II ——</b></sub></p>

## Install

### hako · the agent

```sh
curl -fsSL https://mithraeums.github.io/hako.sh | sh
```

### hake · the editor

```sh
curl -fsSL https://mithraeums.github.io/hake.sh | sh
```

### hakm · the models suite — native C engine (no ollama, no llama.cpp)

```sh
git clone https://github.com/mithraeums/hako && cd hako && make
```

<p align="center">
  <sub><b>macOS</b> universal2 &nbsp;·&nbsp; <b>Linux</b> x86_64 / arm64 &nbsp;·&nbsp; <b>FreeBSD</b> x86_64 &nbsp;·&nbsp; <b>Windows</b> MinGW &nbsp;·&nbsp; <b>iSh</b></sub>
</p>

<p align="center"><sub><b>—— III ——</b></sub></p>

## Motive

<table>
  <tr>
    <td width="33%" valign="top"><b>I · Local first.</b><br/><sub>Your text, your keys, your weights. No telemetry. No silent network. The cursor is a private place.</sub></td>
    <td width="33%" valign="top"><b>II · Single binary.</b><br/><sub>One file. One C source. No JavaScript runtime to swallow your editor. The tool fits in a head.</sub></td>
    <td width="33%" valign="top"><b>III · Bring your own model.</b><br/><sub>Any model. Any provider. Any prompt. The agent is a peer at your terminal, not a stranger in the cloud.</sub></td>
  </tr>
</table>

<p align="center"><sub><b>—— IV ——</b></sub></p>

## Site

`index.html` is the whole interactive site — one hand-written static file: inline CSS, inline vanilla JS, **no build step, no framework, no third-party script, no web font, no tracker**. It's a pane-switcher (terminal home view; nav tabs slide between Suite / Install / Skills / Releases).

**One source of truth.** A single `MITH` object at the top of `index.html` holds every version, repo URL, the product copy, releases, and skills. Everything dynamic renders from it — bump a version *there*, once. No version string is hardcoded anywhere else.

**Plain mirror.** `html/index.html` is a **generated**, JavaScript-free mirror for emacs `eww`, lynx/w3m, screen readers, and offline reading — live at [`/html`](https://mithraeums.github.io/html). Do **not** hand-edit it:

```sh
node tools/build-mirror.mjs    # reads MITH out of index.html, rewrites html/index.html
```

`.github/workflows/mirror.yml` runs this on every push that touches `index.html`, so the mirror can't go stale. Custom domain `mithraeum.studio` points at this same Pages site, so `/html` is served on both.

`install.sh` is a thin proxy to the canonical hako-code installer in [`mithraeums/hako-code`](https://github.com/mithraeums/hako-code). `hake.sh` / `hako.sh` / `hakm.sh` are per-product proxies. Banner SVGs in `assets/` are referenced by every project README.

<p align="center"><sub><a href="LICENSE">— SEE LICENSE —</a> &nbsp;·&nbsp; GPL-3.0 &nbsp;·&nbsp; copyleft</sub></p>

<p align="center"><sub><em>— deus sol invictus mithras —</em></sub></p>
