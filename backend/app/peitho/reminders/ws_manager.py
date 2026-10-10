"""
WebSocket connection manager for pushing reminder events to active call copilot sessions.
"""
from __future__ import annotations

import asyncio
from typing import Dict, Set, Optional, Any
from fastapi import WebSocket
import structlog

logger = structlog.get_logger(__name__)


class ReminderWSManager:
    """Tracks active WebSockets for sessions and users to push live reminder notifications."""

    def __init__(self):
        # session_id -> Set of WebSocket connections
        self._session_sockets: Dict[str, Set[WebSocket]] = {}
        # user_id -> Set of session_ids
        self._user_sessions: Dict[int, Set[str]] = {}
        self._lock = asyncio.Lock()

    async def register(self, session_id: str, websocket: WebSocket, user_id: Optional[int] = None) -> None:
        async with self._lock:
            if session_id not in self._session_sockets:
                self._session_sockets[session_id] = set()
            self._session_sockets[session_id].add(websocket)

            if user_id is not None:
                if user_id not in self._user_sessions:
                    self._user_sessions[user_id] = set()
                self._user_sessions[user_id].add(session_id)

    async def unregister(self, session_id: str, websocket: WebSocket, user_id: Optional[int] = None) -> None:
        async with self._lock:
            if session_id in self._session_sockets:
                self._session_sockets[session_id].discard(websocket)
                if not self._session_sockets[session_id]:
                    del self._session_sockets[session_id]

            if user_id is not None and user_id in self._user_sessions:
                if session_id not in self._session_sockets:
                    self._user_sessions[user_id].discard(session_id)
                if not self._user_sessions[user_id]:
                    del self._user_sessions[user_id]

    async def broadcast_session(self, session_id: str, message: dict) -> None:
        """Send message to all sockets connected to this session."""
        sockets: Set[WebSocket] = set()
        async with self._lock:
            if session_id in self._session_sockets:
                sockets = set(self._session_sockets[session_id])

        for ws in sockets:
            try:
                await ws.send_json(message)
            except Exception as e:
                logger.debug("reminder_ws_broadcast_failed", error_type=type(e).__name__)

    async def broadcast_user(self, user_id: int, message: dict) -> None:
        """Broadcast message to all active call sessions owned by this user."""
        sessions: Set[str] = set()
        async with self._lock:
            if user_id in self._user_sessions:
                sessions = set(self._user_sessions[user_id])

        for s_id in sessions:
            await self.broadcast_session(s_id, message)


reminder_ws_manager = ReminderWSManager()
