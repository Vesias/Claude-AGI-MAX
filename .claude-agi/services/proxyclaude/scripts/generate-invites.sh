#!/bin/bash
# Generate invites for ProxyClaude

# Ensure we're in the right directory
cd "$(dirname "$0")/.."

# Create invites directory if it doesn't exist
mkdir -p invites

# Make sure it's not readable by others
chmod 700 invites

# Run the invite generator
node scripts/invite-generator.js

# Output sample email template
echo ""
echo "=========================================="
echo "Email Template für Beta-Zugang:"
echo "=========================================="
echo "Subject: Claude Pro MAX - Exklusiver Beta-Zugang"
echo ""
echo "Hey [Name],"
echo ""
echo "ich habe einen privaten Service für Claude Pro MAX Sharing aufgesetzt."
echo "Nur 6 Plätze verfügbar, komplett under-the-radar."
echo ""
echo "Zugang für 30€ statt 90€."
echo "Link: [INVITE_URL aus der Liste oben einfügen]"
echo ""
echo "Diskret und schnell handeln - Plätze sind limitiert."
echo "=========================================="