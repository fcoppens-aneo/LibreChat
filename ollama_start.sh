#!/bin/sh
ollama serve & 
sleep 5
ollama pull nomic-embed-text
wait $(jobs -p)
