from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, Text, Date
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from database import Base
import datetime

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    username = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    gangs = relationship("GangMember", back_populates="user")
    daily_saves = relationship("DailySave", back_populates="user")
    chat_messages = relationship("ChatMessage", back_populates="user")

class Gang(Base):
    __tablename__ = "gangs"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    description = Column(Text)
    is_public = Column(Boolean, default=True)
    gang_id = Column(String, unique=True, index=True)
    created_by = Column(Integer, ForeignKey("users.id"))
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    members = relationship("GangMember", back_populates="gang")
    daily_saves = relationship("DailySave", back_populates="gang")
    chat_messages = relationship("ChatMessage", back_populates="gang")

class GangMember(Base):
    __tablename__ = "gang_members"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    gang_id = Column(Integer, ForeignKey("gangs.id"))
    role = Column(String, default="member")
    joined_at = Column(DateTime(timezone=True), server_default=func.now())
    
    user = relationship("User", back_populates="gangs")
    gang = relationship("Gang", back_populates="members")

class DailySave(Base):
    __tablename__ = "daily_saves"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    gang_id = Column(Integer, ForeignKey("gangs.id"))
    saved = Column(Boolean, default=False)
    save_date = Column(Date, default=datetime.date.today)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    user = relationship("User", back_populates="daily_saves")
    gang = relationship("Gang", back_populates="daily_saves")

class ChatMessage(Base):
    __tablename__ = "chat_messages"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    gang_id = Column(Integer, ForeignKey("gangs.id"))
    message = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    user = relationship("User", back_populates="chat_messages")
    gang = relationship("Gang", back_populates="chat_messages") 