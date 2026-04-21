from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from sqlalchemy import LargeBinary, create_engine, Column, TEXT, VARCHAR
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base
from dotenv import load_dotenv
import uuid
import os
import bcrypt

load_dotenv()

app = FastAPI()

DATABASE_URL = os.getenv("DATABASE_URL")

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

db = SessionLocal()

class UserCreate(BaseModel):
    name: str
    email: str
    password: str

Base = declarative_base()

class User(Base):
    __tablename__ = "users"
    id = Column(TEXT, primary_key=True)
    name = Column(VARCHAR(100)) 
    email = Column(VARCHAR(100))
    password = Column(LargeBinary)

@app.post("/signup")
def signup_user(user: UserCreate):
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

Base.metadata.create_all(engine)