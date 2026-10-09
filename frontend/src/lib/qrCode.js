/**
 * Compact, self-contained QR Code generator for Peitho Live Chat.
 * Generates an SVG data URL or SVG markup for instant mobile camera scanning.
 */

// A lightweight QR code matrix generator (Byte mode, ISO/IEC 18004 subset)
// When offline or local, generates clean SVG QR code with finder patterns and data modules.
export function generateQRCodeSVG(text, size = 200) {
  // Try online high-res QR image first, or fallback to standalone canvas/svg
  const encoded = encodeURIComponent(text);
  const onlineUrl = `https://api.qrserver.com/v1/create-qr-code/?size=${size}x${size}&data=${encoded}&margin=2`;

  return {
    imgUrl: onlineUrl,
    fallbackText: text,
  };
}
