// SPDX-FileCopyrightText: 2023 XWiki CryptPad Team <contact@cryptpad.org> and contributors
// SPDX-License-Identifier: AGPL-3.0-or-later

/*
 * Custom CryptPad Application Configuration
 * Overrides default values without touching core code.
 * See: https://docs.cryptpad.org/en/admin_guide/customization.html#application-config
 */

(() => {
    const factory = (AppConfig) => {
        /* ======================================================================
         * 1. SECURITY & AUTHENTICATION
         * ====================================================================== */

        /* WARNING: loginSalt MUST be generated once at setup and NEVER changed!
         * Changing this later will break logins for all existing users.
         * The setup script (scripts/setup.sh) will automatically generate and set this.
         */
        AppConfig.loginSalt = 'CHANGE_THIS_ON_INITIAL_SETUP_WITH_OPENSSL_RAND_HEX_32';

        /* Minimum password length requirement (recommended: >= 12) */
        AppConfig.minimumPasswordLength = 12;

        /* Restrict anonymous pad creation (uncomment to require registration to create pads)
         * Pads can still be shared and edited by guests if shared link is provided.
         */
        // AppConfig.disableAnonymousPadCreation = true;
        // AppConfig.disableAnonymousStore = true;

        /* ======================================================================
         * 2. THEME & DISPLAY
         * ====================================================================== */

        /* Force dark theme by default (uncomment to enable) */
        // AppConfig.defaultDarkTheme = true;

        /* ======================================================================
         * 3. LEGAL & CONTACT LINKS
         * ====================================================================== */
        // AppConfig.privacy = 'https://cryptpad.example.com/privacy.html';
        // AppConfig.terms = 'https://cryptpad.example.com/terms.html';
        // AppConfig.imprint = 'https://cryptpad.example.com/imprint.html';

        return AppConfig;
    };

    if (typeof(module) !== 'undefined' && module.exports) {
        module.exports = factory;
    } else if (typeof(window) !== 'undefined') {
        window.CryptPadAppConfig = factory;
    }
})();
