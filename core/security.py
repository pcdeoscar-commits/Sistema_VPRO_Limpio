import bcrypt

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

