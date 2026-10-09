"""
Gemini Direct Client — Async non-blocking HTTP client for Google Gemini 2.0 Flash.
Calls Gemini REST API directly using httpx with native JSON structured output.
"""
import os
import json
from typing import Dict, Any, Optional
import httpx
import structlog

logger = structlog.get_logger(__name__)

GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"


class GeminiDirectClient:
    """Ultra-fast, direct async client for Gemini 2.0 Flash with JSON structured response."""

    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key or os.getenv("GEMINI_API_KEY", "").strip()
        self.timeout = 8.0

    @property
    def is_configured(self) -> bool:
        return bool(self.api_key)

    async def generate_json(self, system_instruction: str, prompt: str) -> Optional[Dict[str, Any]]:
        """Call Gemini 2.0 Flash with JSON mode for structured negotiation intelligence."""
        if not self.is_configured:
            return None

        url = f"{GEMINI_API_URL}?key={self.api_key}"
        payload = {
            "contents": [
                {
                    "parts": [{"text": f"SYSTEM INSTRUCTION: {system_instruction}\n\nUSER PROMPT: {prompt}"}]
                }
            ],
            "generationConfig": {
                "temperature": 0.6,
                "maxOutputTokens": 600,
                "responseMimeType": "application/json",
            },
        }

        try:
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                res = await client.post(url, json=payload)
                if res.status_code != 200:
                    logger.warning("gemini_api_error", status_code=res.status_code, body=res.text[:200])
                    return None

                data = res.json()
                candidates = data.get("candidates", [])
                if not candidates:
                    return None

                text_content = candidates[0].get("content", {}).get("parts", [{}])[0].get("text", "")
                if not text_content:
                    return None

                return json.loads(text_content)
        except Exception as e:
            logger.warning("gemini_request_failed", error=str(e))
            return None
