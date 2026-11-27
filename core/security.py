import os
import hmac
import json
import time
import base64
import hashlib
from typing import Optional, Callable
import bcrypt
from fastapi import Request, HTTPException, Depends

JWT_SECRET = os.getenv("JWT_SECRET", "vpro-erp-clave-maestra-jwt-2026-culiacan")


def verificar_password(plain_password: str, hashed_password: str) -> bool:
    """Verifica si la clave coincide. Soporta el formato plano histórico y el encriptado bcrypt."""
    plain = str(plain_password).strip()
    hashed = str(hashed_password).strip()

    if not hashed.startswith("$2b$"):
        return plain == hashed
    try:
        return bcrypt.checkpw(plain.encode("utf-8"), hashed.encode("utf-8"))
    except Exception:
        return False


def encriptar_password(password: str) -> str:
    """Convierte el texto en un hash seguro con bcrypt."""
    salt = bcrypt.gensalt()
    hashed_bytes = bcrypt.hashpw(password.encode("utf-8"), salt)
    return hashed_bytes.decode("utf-8")


def _b64url_encode(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode("ascii")


def _b64url_decode(data: str) -> bytes:
    padding = "=" * (-len(data) % 4)
    return base64.urlsafe_b64decode(data + padding)


def crear_token_jwt(datos: dict, expira_horas: int = 168) -> str:
    """Genera un token JWT firmado con HS256 usando librería estándar de Python."""
    header = {"alg": "HS256", "typ": "JWT"}
    ahora = int(time.time())
    payload = {
        **datos,
        "iat": ahora,
        "exp": ahora + (expira_horas * 3600),
    }
    seg_header = _b64url_encode(json.dumps(header, separators=(",", ":")).encode("utf-8"))
    seg_payload = _b64url_encode(json.dumps(payload, separators=(",", ":")).encode("utf-8"))
    signing_input = f"{seg_header}.{seg_payload}".encode("ascii")
    firma = hmac.new(JWT_SECRET.encode("utf-8"), signing_input, hashlib.sha256).digest()
    return f"{seg_header}.{seg_payload}.{_b64url_encode(firma)}"


def verificar_token_jwt(token: str) -> Optional[dict]:
    """Verifica firma HS256 y vigencia del JWT. Retorna payload dict o None."""
    try:
        partes = token.strip().split(".")
        if len(partes) != 3:
            return None
        seg_header, seg_payload, seg_firma = partes
        signing_input = f"{seg_header}.{seg_payload}".encode("ascii")
        firma_esperada = hmac.new(JWT_SECRET.encode("utf-8"), signing_input, hashlib.sha256).digest()
        firma_recibida = _b64url_decode(seg_firma)
        if not hmac.compare_digest(firma_esperada, firma_recibida):
            return None
        payload = json.loads(_b64url_decode(seg_payload).decode("utf-8"))
        if payload.get("exp") and int(time.time()) > int(payload["exp"]):
            return None
        return payload
    except Exception:
        return None


def obtener_usuario_opcional(request: Request) -> Optional[dict]:
    """Extrae y valida el JWT del header Authorization si viene presente."""
    auth_header = request.headers.get("Authorization", "")
    if auth_header.startswith("Bearer "):
        token = auth_header[7:].strip()
        if token:
            return verificar_token_jwt(token)
    return None


def obtener_usuario_actual(request: Request) -> dict:
    """Exige un JWT válido en el header Authorization; de lo contrario retorna 401."""
    usuario = obtener_usuario_opcional(request)
    if not usuario:
        raise HTTPException(
            status_code=401,
            detail="Sesión no autenticada o token expirado. Inicia sesión nuevamente."
        )
    return usuario


def requerir_roles(*roles_permitidos: str) -> Callable:
    """Dependencia FastAPI que exige un JWT válido y que el rol del usuario esté autorizado."""
    roles_upper = {r.upper().strip() for r in roles_permitidos}

    def _verificar_rol(usuario: dict = Depends(obtener_usuario_actual)) -> dict:
        rol_actual = str(usuario.get("rol") or "").upper().strip()
        if rol_actual not in roles_upper and not any(r in rol_actual for r in roles_upper):
            raise HTTPException(
                status_code=403,
                detail=f"Acceso denegado: se requiere rol {', '.join(sorted(roles_upper))}."
            )
        return usuario

    return _verificar_rol
