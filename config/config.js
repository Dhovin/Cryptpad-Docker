// SPDX-FileCopyrightText: 2023 XWiki CryptPad Team <contact@cryptpad.org> and contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

/**
 * Production CryptPad Configuration
 * Dynamically configurable via environment variables with safe defaults.
 */

const mainDomain = process.env.CPAD_MAIN_DOMAIN || 'cryptpad.example.com';
const sandboxDomain = process.env.CPAD_SANDBOX_DOMAIN || 'cryptpad-sandbox.example.com';

module.exports = {
    /*  httpUnsafeOrigin is the URL that clients will enter to load your instance.
     *  In production this should be available ONLY over HTTPS.
     */
    httpUnsafeOrigin: mainDomain.startsWith('http') ? mainDomain : `https://${mainDomain}`,

    /*  httpSafeOrigin is the URL used for the sandbox domain.
     *  Hosts sandboxed iframes with strict CSP to isolate user documents.
     */
    httpSafeOrigin: sandboxDomain.startsWith('http') ? sandboxDomain : `https://${sandboxDomain}`,

    /*  httpAddress specifies the address on which the nodejs server listens.
     *  In Docker, 0.0.0.0 is required to accept connections from the host/proxy.
     */
    httpAddress: process.env.CPAD_HTTP_ADDRESS || '0.0.0.0',

    /*  httpPort specifies on which port the nodejs server listens. */
    httpPort: parseInt(process.env.CPAD_HTTP_PORT || '3000', 10),

    /*  Websockets need to be exposed on a separate port from HTTP traffic.
     *  In production, the reverse proxy forwards /cryptpad_websocket to this port.
     */
    websocketPort: parseInt(process.env.CPAD_WEBSOCKET_PORT || '3003', 10),

    /*  CryptPad installation method metadata */
    installMethod: 'docker',

    /* =====================
     *       Storage
     * ===================== */
    filePath: './datastore/',
    archivePath: './data/archive',
    pinPath: './data/pins',
    taskPath: './data/tasks',
    blockPath: './block',
    blobPath: './blob',
    blobStagingPath: './data/blobstage',
    decreePath: './data/decrees',
    logPath: './data/logs',

    /* Data retention default limits */
    inactiveTime: 90, // days before unpinned pads are eligible for eviction
    archiveRetentionTime: 15, // days before archived files are permanently removed

    /* Logging level: 'error', 'warn', 'info', 'debug' */
    logLevel: process.env.CPAD_LOG_LEVEL || 'info',

    /* Admin Public Signing Keys (Deprecated in favor of the /admin setup panel,
     * but can still be specified if desired)
     */
    adminKeys: [
        // "[cryptpad-user1@my.awesome.website/YZgXQxKR0Rcb6r6CmxHPdAGLVludrAF2lEnkbx1vVOo=]",
    ],
};
