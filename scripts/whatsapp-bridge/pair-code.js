#!/usr/bin/env node
import { makeWASocket, useMultiFileAuthState, fetchLatestBaileysVersion, DisconnectReason } from "@whiskeysockets/baileys";
import path from "path";
import { mkdirSync } from "fs";
const phone = process.argv[2];
if (!phone) { console.log("Usage: node pair-code.js +855..."); process.exit(1); }
const SESSION_DIR = path.join(process.env.HOME, ".hermes", "whatsapp", "session");
mkdirSync(SESSION_DIR, { recursive: true });
async function start() {
  const { version } = await fetchLatestBaileysVersion();
  const { state, saveCreds } = await useMultiFileAuthState(SESSION_DIR);
  const sock = makeWASocket({ version, auth: state, printQRInTerminal: false,
    logger: { info(){}, warn(){}, error(){}, child(){ return this; } } });
  sock.ev.on("creds.update", saveCreds);
  sock.ev.on("connection.update", async (update) => {
    const { connection, lastDisconnect, qr } = update;
    if (qr && !state.creds?.registered) {
      try {
        const code = await sock.requestPairingCode(phone);
        console.log("=== PAIRING CODE ===");
        console.log("Kode: " + code.match(/.{1,4}/g).join("-"));
        console.log("Cara: WhatsApp -> Linked Devices -> Link with Phone Number");
      } catch(e) { console.log("QR fallback: " + e.message); }
    }
    if (connection === "open") { console.log("TERHUBUNG!"); process.exit(0); }
    if (connection === "close") {
      const reason = lastDisconnect?.error?.output?.statusCode;
      if (reason !== DisconnectReason.loggedOut) { start(); }
      else process.exit(1);
    }
  });
}
start();
