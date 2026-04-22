from fastapi import Depends, HTTPException
from models.user import User
from pydantic_schema.user_create import UserCreate
import uuid
import bcrypt
from fastapi import APIRouter
from database import get_db
from sqlalchemy.orm import Session

router = APIRouter()

@router.post("/signup")
def signup_user(user: UserCreate, db: Session=Depends(get_db)):
    user_db = db.query(User).filter(User.email == user.email).first()
    if user_db:
        raise HTTPException(400, 'User with this email already exists!')
    
    # 1. Buat data
    hashed_pw = bcrypt.hashpw(user.password.encode(), bcrypt.gensalt())
    user_db = User(id=str(uuid.uuid4()), name=user.name, email=user.email, password=hashed_pw)
    
    # 2. Add data & 3. Commit data agar di proses ke DB 
    db.add(user_db)
    db.commit()
    
    # 4. refresh db dengan data yang dimodelkan agar semua field dapat di peroses dan di return kan
    db.refresh(user_db)
    
    return user_db