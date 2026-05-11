from models.song import Song
import uuid
from middleware.auth_middleware import auth_middleware
from database import get_db
from fastapi import APIRouter, UploadFile, File, Form, Depends
from sqlalchemy.orm import Session
from dotenv import load_dotenv
import os

import cloudinary
import cloudinary.uploader

load_dotenv()

router = APIRouter()

CLOUDINARY_CLOUD_NAME = os.getenv('CLOUDINARY_CLOUD_NAME')
CLOUDINARY_API_KEY = os.getenv('CLOUDINARY_API_KEY')
CLOUDINARY_API_SECRET = os.getenv('CLOUDINARY_API_SECRET')

cloudinary.config( 
  cloud_name = CLOUDINARY_CLOUD_NAME, 
  api_key = CLOUDINARY_API_KEY, 
  api_secret = CLOUDINARY_API_SECRET,
  secure = True
)

@router.post('/upload', status_code=201)
def upload_song(song: UploadFile = File(...), 
                thumbnail: UploadFile = File(...), 
                artist: str = Form(...), 
                song_name: str = Form(...), 
                hex_code: str = Form(...),
                db: Session = Depends(get_db),
                auth_dict = Depends(auth_middleware)):
    song_id = str(uuid.uuid4())
    # store data in cloudinary
    song_result = cloudinary.uploader.upload(song.file, resource_type='auto', folder=f'songs/{song_id}')
    thumbnail_result = cloudinary.uploader.upload(thumbnail.file, resource_type='image', folder=f'songs/{song_id}')
    
    # store data in db
    new_song = Song(
      id=song_id,
      song_name= song_name,
      artist = artist,
      hex_code=hex_code,
      song_url =song_result['url'],
      thumbnail_url = thumbnail_result['url']
    )

    db.add(new_song)
    db.commit()
    db.refresh(new_song)
    return new_song
