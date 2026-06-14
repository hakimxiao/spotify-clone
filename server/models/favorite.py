from sqlalchemy import Column, ForeignKey, Text
from sqlalchemy.orm import relationship

from models.base import Base


class Favorite(Base):
    __tablename__ = "favorites"
    
    id = Column(Text, primary_key=True)
    song_id = Column(Text, ForeignKey("songs.id"))
    user_id = Column(Text, ForeignKey("users.id"))
    
    song = relationship('Song')