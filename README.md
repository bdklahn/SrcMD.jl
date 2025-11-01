# SrcMD

[![Build Status](https://github.com/bdklahn/SrcMD.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/bdklahn/SrcMD.jl/actions/workflows/CI.yml?query=branch%3Amain)

This collects known source code file types inside a directory (e.g. a git repo working tree directory),
based on their extensions, and writes them into a single Markdown file. This is useful to get the code into an 
LLM context window for code analysis, generation, or other tasks. The processing here uses Markdown 
headers to try and also preserve any of the semantics of directory structure. Such a file can be easily
used for simple "context stuffing". But it is also useful to make it easy to add as a source to be
processed for vector embedding generation for retrieval-augmented generation (RAG) workflows. E.g. one
can add the file as a source to NotebookLM. There, the backend will chunk the file into smaller pieces
and make the semantically indexed for retrieval from a backend vector database.
