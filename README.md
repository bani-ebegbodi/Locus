# Locus
Locus is an immersive language learning application for the Apple Vision Pro that adjusts AI conversational topics based on the virtual environment the user is in. Created on SwiftUI, the app takes in voice input from the user using OpenAI Whisper for filtering, then the input is sent to OpenAI GPT-4o to generate a response. Finally, Google Cloud Text-to-Speech API reads out the generated response using the Chrip3-HD-Kore voice in a 3D virtual environment created in Blender and Reality Composer Pro. The app is meant for users who wish to practice their language speaking skills in a virtual environment with environment specific language (ie. café lingo in a café, retail lingo in a clothing store, etc).

# What is needed
- OpenAI Package Dependancy: https://github.com/MacPaw/OpenAI 
- OpenAI API Key: Used for OpenAI Whisper and GPT-4o prompt in ChatController 
- Google Cloud Text-to-Speech API Key: Used for Google Text-to-Speech in ChatController
