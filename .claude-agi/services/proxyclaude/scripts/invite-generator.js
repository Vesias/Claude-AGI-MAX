/**
 * Invite Generator für ProxyClaude
 * Erstellt private Einladungs-Links mit speziellen Token
 */

const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

// Konfiguration
const INVITES_COUNT = 6; // Anzahl der zu erstellenden Einladungen
const INVITES_DIR = path.join(__dirname, '..', 'invites');
const BASE_URL = 'http://localhost:4001'; // Aktualisiert auf Port 4001

// Sicherstellen, dass das Invites-Verzeichnis existiert
if (!fs.existsSync(INVITES_DIR)) {
  fs.mkdirSync(INVITES_DIR, { recursive: true });
  console.log(`Erstelle Verzeichnis: ${INVITES_DIR}`);
}

// Zuvor generierte Invites auflisten
console.log('Bestehende Einladungen:');
if (fs.existsSync(INVITES_DIR)) {
  const existing = fs.readdirSync(INVITES_DIR);
  if (existing.length > 0) {
    existing.forEach(file => console.log(`- ${file}`));
  } else {
    console.log('Keine bestehenden Einladungen gefunden.');
  }
}

// Neue Invites generieren
console.log(`\nGeneriere ${INVITES_COUNT} neue Einladungen...`);

for (let i = 1; i <= INVITES_COUNT; i++) {
  // Eindeutiges Token generieren
  const token = crypto.randomBytes(16).toString('hex');
  
  // Invite-Link erstellen
  const inviteUrl = `${BASE_URL}/payment/checkout?invite=${token}`;
  
  // Discount-Code für dieses Token (optional)
  const discountCode = `EARLY${i}`;
  
  // Invite-Daten als JSON
  const inviteData = {
    token,
    url: inviteUrl,
    discountCode,
    created: new Date().toISOString(),
    used: false
  };
  
  // In Datei speichern
  const fileName = `invite-${i}-${token.substring(0, 6)}.json`;
  const filePath = path.join(INVITES_DIR, fileName);
  
  fs.writeFileSync(filePath, JSON.stringify(inviteData, null, 2));
  fs.chmodSync(filePath, 0o600); // Berechtigungen einschränken
  
  // Ausgabe für Email/Discord
  console.log(`\n--- Invite ${i} ---`);
  console.log(`URL: ${inviteUrl}`);
  console.log(`Code: ${discountCode}`);
  console.log(`Token: ${token}`);
}

console.log('\nEinladungen wurden generiert und in', INVITES_DIR, 'gespeichert');
console.log('Diese Einladungs-Links können direkt an Benutzer gesendet werden.');
console.log('WICHTIG: Links sind einmalig verwendbar!');