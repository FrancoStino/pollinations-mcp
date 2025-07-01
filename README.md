# Pollinations Multimodal MCP Server

Pollinations MCP is a Model Context Protocol (MCP) server for the [Pollinations AI APIs](https://pollinations.ai) that enables AI assistants and tools (such as Zed or Claude) to generate images, text, and audio directly. This server follows the "thin proxy" design principle, focusing on minimal data transformation and direct communication through stdio.

This extension integrates the MCP server into the [Zed](https://zed.dev) code editor, providing seamless access to Pollinations AI features directly within your development environment.

## Features

- Generate image URLs from text prompts
- Generate actual images and return them as base64-encoded data
- Generate text responses from text prompts
- Generate audio (text-to-speech) from text prompts
- List available image and text generation models
- STDIO transport for easy integration with MCP clients
- Simple and lightweight
- Compatible with the Model Context Protocol (MCP)
- **Context Server Integration:** Registers a context server in Zed that communicates with Pollinations MCP via a Node.js process.
- **Zero Configuration:** Works out-of-the-box with Zed, requiring minimal setup.


## Available Tools

The MCP server provides the following tools:

### Content Generation

- **generateImageUrl**
  Generates an image URL from a text prompt.

- **generateImage**
  Generates an image and returns it as base64-encoded data.

- **respondAudio**
  Generates an audio response to a text prompt.

- **sayText**
  Generates speech that says the provided text verbatim.

- **generateText**
  Generates text from a prompt using text models.

- **listModels**
  Lists available models for image or text generation.

## Usage

Once installed and enabled in Zed:
- The extension checks for the latest version of the Pollinations MCP Node.js package.
- It installs or updates the package if necessary.
- It launches the Pollinations MCP server as a Node.js process when required by Zed.

No manual configuration is required. The extension is designed to be plug-and-play.

## Project Structure

- `src/pollinations-mcp.rs` — Main Rust source file implementing the extension logic.
- `Cargo.toml` — Rust project manifest and dependencies.
- `extension.toml` — Zed extension manifest and metadata.
- `.gitignore` — Standard ignore file for build artifacts.
- `extension.wasm` — Compiled WebAssembly binary for Zed (generated).
- `target/` — Build output directory (generated).


## Author

Davide Ladisa (<info@davideladisa.it>)

---

For more information, visit the [repository](https://github.com/FrancoStino/pollinations_mpc).
