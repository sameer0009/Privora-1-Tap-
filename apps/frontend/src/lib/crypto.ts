export async function generateIdentityKeys() {
  const keyPair = await window.crypto.subtle.generateKey(
    { name: "ECDH", namedCurve: "P-256" },
    true, // extractable (so we can save it to idb, though non-extractable is better, we need persistence for this demo unless we generate per session)
    ["deriveKey", "deriveBits"]
  );
  
  const publicKeyRaw = await window.crypto.subtle.exportKey("raw", keyPair.publicKey);
  const publicKeyHex = Array.from(new Uint8Array(publicKeyRaw))
    .map(b => b.toString(16).padStart(2, '0')).join('');
    
  return { keyPair, publicKeyHex };
}

export async function computeSharedSecret(privateKey: CryptoKey, peerPublicKeyHex: string) {
  // Convert hex to Uint8Array
  const peerKeyBytes = new Uint8Array(
    peerPublicKeyHex.match(/.{1,2}/g)!.map(byte => parseInt(byte, 16))
  );

  const peerPublicKey = await window.crypto.subtle.importKey(
    "raw",
    peerKeyBytes,
    { name: "ECDH", namedCurve: "P-256" },
    true,
    []
  );

  return window.crypto.subtle.deriveKey(
    { name: "ECDH", public: peerPublicKey },
    privateKey,
    { name: "AES-GCM", length: 256 },
    true,
    ["encrypt", "decrypt"]
  );
}

export async function encryptPayload(aesKey: CryptoKey, plaintext: string) {
  const iv = window.crypto.getRandomValues(new Uint8Array(12));
  const encoded = new TextEncoder().encode(plaintext);
  
  const ciphertext = await window.crypto.subtle.encrypt(
    { name: "AES-GCM", iv },
    aesKey,
    encoded
  );
  
  return {
    ciphertext: Array.from(new Uint8Array(ciphertext)).map(b => b.toString(16).padStart(2, '0')).join(''),
    iv: Array.from(iv).map(b => b.toString(16).padStart(2, '0')).join('')
  };
}

export async function decryptPayload(aesKey: CryptoKey, ciphertextHex: string, ivHex: string) {
  const ciphertext = new Uint8Array(ciphertextHex.match(/.{1,2}/g)!.map(byte => parseInt(byte, 16)));
  const iv = new Uint8Array(ivHex.match(/.{1,2}/g)!.map(byte => parseInt(byte, 16)));
  
  const decrypted = await window.crypto.subtle.decrypt(
    { name: "AES-GCM", iv },
    aesKey,
    ciphertext
  );
  
  return new TextDecoder().decode(decrypted);
}
