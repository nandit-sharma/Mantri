from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime, date

class UserBase(BaseModel):
    email: EmailStr
    username: str

class UserCreate(UserBase):
    password: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class User(UserBase):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: Optional[str] = None

class GangBase(BaseModel):
    name: str
    description: str
    is_public: bool = True

class GangCreate(GangBase):
    pass

class Gang(GangBase):
    id: int
    gang_id: str
    created_by: int
    created_at: datetime
    member_count: Optional[int] = None

    class Config:
        from_attributes = True

class GangMemberBase(BaseModel):
    role: str = "member"

class GangMemberCreate(GangMemberBase):
    gang_id: int

class GangMember(GangMemberBase):
    id: int
    user_id: int
    gang_id: int
    joined_at: datetime
    user: User

    class Config:
        from_attributes = True

class DailySaveBase(BaseModel):
    saved: bool
    save_date: date

class DailySaveCreate(DailySaveBase):
    gang_id: int

class DailySave(DailySaveBase):
    id: int
    user_id: int
    gang_id: int
    created_at: datetime

    class Config:
        from_attributes = True

class WeeklyRecord(BaseModel):
    user_id: int
    username: str
    week_saves: int
    weekly_record: List[Optional[bool]]
    role: str

class SaveRequest(BaseModel):
    saved: bool

class ChatMessageBase(BaseModel):
    message: str

class ChatMessageCreate(ChatMessageBase):
    gang_id: int

class ChatMessage(ChatMessageBase):
    id: int
    user_id: int
    gang_id: int
    created_at: datetime
    user: User

    class Config:
        from_attributes = True

class GangHomeData(BaseModel):
    gang: Gang
    members: List[GangMember]
    weekly_records: List[WeeklyRecord]
    user_weekly_record: List[Optional[bool]]
    user_today_save: bool 