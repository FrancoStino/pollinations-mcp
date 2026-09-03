# Pollinations Multimodal MCP Server

Pollinations MCP is a Model Context Protocol (MCP) server for the [Pollinations AI APIs](https://pollinations.ai) that enables AI assistants and tools (such as Zed or Claude) to generate images, text, audio, video, 3D models, and embeddings directly. This server follows the "thin proxy" design principle, focusing on minimal data transformation and direct communication through stdio.

This extension integrates the `@pollinations/mcp` package into the [Zed](https://zed.dev) code editor, providing seamless access to Pollinations AI features directly within your development environment.

## Features

- Generate and edit images
- Generate text responses, search-capable models, and multimodal input handling
- Generate audio (speech, music, or sound) and transcribe audio
- Generate video content
- Generate GLB 3D models
- Create text and multimodal embeddings
- List live models, aliases, capabilities, voices, endpoints, and pricing
- Inspect model status (recent requests, errors, latency) and check Pollen balance
- STDIO transport for easy integration with MCP clients
- Simple and lightweight
- Compatible with the Model Context Protocol (MCP)
- **Context Server Integration:** Registers a context server in Zed that communicates with `@pollinations/mcp` via a Node.js process.
- **Zero Configuration:** Works out-of-the-box with Zed, requiring minimal setup.


## Available Tools

The MCP server provides the following tools:

- **listModels**
  List live canonical names, aliases, modalities, capabilities, voices, supported endpoints, agent status, and pricing.

- **getModelStatus**
  Return recent per-model request counts, errors, and latency.

- **generateText**
  Run completions through text models or agents. Supports search, multimodal input, tool calling, structured output, reasoning, and audio output.

- **generateImage**
  Generate or edit images and return an unlisted `media.pollinations.ai` resource link.

- **generateVideo**
  Generate video content and return an unlisted `media.pollinations.ai` resource link.

- **generateAudio**
  Generate speech, music, or sound and return an unlisted `media.pollinations.ai` resource link.

- **transcribeAudio**
  Transcribe spoken audio from a public HTTPS URL.

- **generate3D**
  Generate a GLB 3D model and return an unlisted `media.pollinations.ai` resource link.

- **createEmbeddings**
  Create OpenAI-compatible text or multimodal embeddings.

- **getBalance**
  Get current Pollen balance for the authenticated API key.

- **setApiKey**, **getKeyInfo**, **clearApiKey**
  Manage API key authentication state for pollinations.ai requests.

## Usage

Once installed and enabled in Zed:
- The extension checks for the latest version of the Pollinations MCP Node.js package.
- It installs or updates the package if necessary.
- It launches the Pollinations MCP server as a Node.js process when required by Zed.

No manual configuration is required. The extension is designed to be plug-and-play.

---

## Author

Davide Ladisa (<info@davideladisa.it>)

---
