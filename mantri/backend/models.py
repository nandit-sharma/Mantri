from sqlalchemy import Column, Integer, String, Boolean, DateTime, ForeignKey, Text, Date, Index
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
    
    # Relationships
    gang_members = relationship("GangMember", back_populates="user")
    daily_saves = relationship("DailySave", back_populates="user")
    chat_messages = relationship("ChatMessage", back_populates="user")

class Gang(Base):
    __tablename__ = "gangs"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    description = Column(Text)
    gang_id = Column(String, unique=True, index=True)
    host_id = Column(Integer, ForeignKey("users.id"), index=True)
    is_public = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    members = relationship("GangMember", back_populates="gang")
    daily_saves = relationship("DailySave", back_populates="gang")
    chat_messages = relationship("ChatMessage", back_populates="gang")

class GangMember(Base):
    __tablename__ = "gang_members"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), index=True)
    gang_id = Column(Integer, ForeignKey("gangs.id"), index=True)
    role = Column(String, default="member")
    joined_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    user = relationship("User", back_populates="gang_members")
    gang = relationship("Gang", back_populates="members")

class DailySave(Base):
    __tablename__ = "daily_saves"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), index=True)
    gang_id = Column(Integer, ForeignKey("gangs.id"), index=True)
    saved = Column(Boolean, default=False)
    save_date = Column(Date, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    user = relationship("User", back_populates="daily_saves")
    gang = relationship("Gang", back_populates="daily_saves")

class ChatMessage(Base):
    __tablename__ = "chat_messages"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), index=True)
    gang_id = Column(Integer, ForeignKey("gangs.id"), index=True)
    message = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    user = relationship("User", back_populates="chat_messages")
    gang = relationship("Gang", back_populates="chat_messages")

# Create composite indexes for better performance
Index('idx_gang_member_user_gang', GangMember.user_id, GangMember.gang_id)
Index('idx_daily_save_user_gang_date', DailySave.user_id, DailySave.gang_id, DailySave.save_date)
Index('idx_chat_message_gang_created', ChatMessage.gang_id, ChatMessage.created_at) 