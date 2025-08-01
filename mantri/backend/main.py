from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from datetime import datetime, timedelta, date
from typing import List
import asyncio
import threading
import time

from database import engine, get_db
from models import Base, User, Gang, GangMember, DailySave, ChatMessage
from schemas import UserCreate, User as UserSchema, Token, GangCreate, Gang as GangSchema, GangMemberCreate, DailySaveCreate, GangHomeData, WeeklyRecord, SaveRequest, ChatMessageCreate, ChatMessage as ChatMessageSchema
from auth import get_password_hash, verify_password, create_access_token, get_current_user
from utils import generate_gang_id, get_week_start_date, get_week_end_date, get_weekly_record_dates, get_day_of_week_index

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Mantri API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Background task for daily/weekly resets
def reset_scheduler():
    while True:
        now = datetime.now()
        if now.hour == 1 and now.minute == 0:
            # Daily reset logic
            with Session(engine) as db:
                # Reset daily saves for new day
                pass
        time.sleep(60)  # Check every minute

# Start background thread
reset_thread = threading.Thread(target=reset_scheduler, daemon=True)
reset_thread.start()

@app.post("/register", response_model=UserSchema)
def register(user: UserCreate, db: Session = Depends(get_db)):
    db_user = db.query(User).filter(User.email == user.email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    
    db_username = db.query(User).filter(User.username == user.username).first()
    if db_username:
        raise HTTPException(status_code=400, detail="Username already taken")
    
    hashed_password = get_password_hash(user.password)
    db_user = User(email=user.email, username=user.username, hashed_password=hashed_password)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

@app.post("/login", response_model=Token)
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == form_data.username).first()
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token_expires = timedelta(minutes=30)
    access_token = create_access_token(
        data={"sub": user.email}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

@app.get("/me")
def read_users_me(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    # Get user statistics
    total_saves = db.query(DailySave).filter(
        DailySave.user_id == current_user.id,
        DailySave.saved == True
    ).count()
    
    gangs_joined = db.query(GangMember).filter(
        GangMember.user_id == current_user.id
    ).count()
    
    # Calculate current streak (simplified for now)
    current_streak = 0
    best_streak = 0
    
    # Get achievements (placeholder for now)
    achievements = []
    
    return {
        "id": current_user.id,
        "email": current_user.email,
        "username": current_user.username,
        "total_saves": total_saves,
        "current_streak": current_streak,
        "best_streak": best_streak,
        "gangs_joined": gangs_joined,
        "achievements": achievements
    }

@app.post("/gangs", response_model=GangSchema)
def create_gang(gang: GangCreate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    gang_id = generate_gang_id()
    while db.query(Gang).filter(Gang.gang_id == gang_id).first():
        gang_id = generate_gang_id()
    
    db_gang = Gang(
        name=gang.name,
        description=gang.description,
        is_public=gang.is_public,
        gang_id=gang_id,
        created_by=current_user.id
    )
    db.add(db_gang)
    db.commit()
    db.refresh(db_gang)
    
    # Add creator as host
    member = GangMember(user_id=current_user.id, gang_id=db_gang.id, role="host")
    db.add(member)
    db.commit()
    
    return db_gang

@app.get("/gangs/{gang_id}", response_model=GangSchema)
def get_gang(gang_id: str, db: Session = Depends(get_db)):
    gang = db.query(Gang).filter(Gang.gang_id == gang_id).first()
    if not gang:
        raise HTTPException(status_code=404, detail="Gang not found")
    return gang

@app.post("/gangs/{gang_id}/join")
def join_gang(gang_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    gang = db.query(Gang).filter(Gang.gang_id == gang_id).first()
    if not gang:
        raise HTTPException(status_code=404, detail="Gang not found")
    
    existing_member = db.query(GangMember).filter(
        GangMember.user_id == current_user.id,
        GangMember.gang_id == gang.id
    ).first()
    
    if existing_member:
        raise HTTPException(status_code=400, detail="Already a member of this gang")
    
    member = GangMember(user_id=current_user.id, gang_id=gang.id, role="member")
    db.add(member)
    db.commit()
    
    return {"message": "Successfully joined gang"}

@app.get("/gangs/{gang_id}/home", response_model=GangHomeData)
def get_gang_home(gang_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    print(f"Getting gang home for gang_id: {gang_id}, user_id: {current_user.id}")
    
    gang = db.query(Gang).filter(Gang.gang_id == gang_id).first()
    if not gang:
        print(f"Gang not found: {gang_id}")
        raise HTTPException(status_code=404, detail="Gang not found")
    
    print(f"Found gang: {gang.name}")
    
    # Check if user is member
    member = db.query(GangMember).filter(
        GangMember.user_id == current_user.id,
        GangMember.gang_id == gang.id
    ).first()
    if not member:
        print(f"User {current_user.id} is not a member of gang {gang.id}")
        raise HTTPException(status_code=403, detail="Not a member of this gang")
    
    print(f"User is member with role: {member.role}")
    
    # Get all members
    members = db.query(GangMember).filter(GangMember.gang_id == gang.id).all()
    
    # Get weekly records for all members
    week_start = get_week_start_date()
    week_end = get_week_end_date()
    weekly_dates = get_weekly_record_dates()
    today = date.today()
    
    weekly_records = []
    for member in members:
        user = db.query(User).filter(User.id == member.user_id).first()
        week_saves = db.query(DailySave).filter(
            DailySave.user_id == member.user_id,
            DailySave.gang_id == gang.id,
            DailySave.save_date >= week_start,
            DailySave.save_date <= week_end,
            DailySave.saved == True
        ).count()
        
        weekly_record = []
        for save_date in weekly_dates:
            if save_date > today:
                weekly_record.append(None)
            else:
                save = db.query(DailySave).filter(
                    DailySave.user_id == member.user_id,
                    DailySave.gang_id == gang.id,
                    DailySave.save_date == save_date
                ).first()
                weekly_record.append(save.saved if save else False)
        
        weekly_records.append(WeeklyRecord(
            user_id=user.id,
            username=user.username,
            week_saves=week_saves,
            weekly_record=weekly_record,
            role=member.role
        ))
    
    # Sort weekly records by week_saves (descending)
    weekly_records.sort(key=lambda x: x.week_saves, reverse=True)
    
    # Get current user's weekly record
    user_weekly_record = []
    today = date.today()
    for i, save_date in enumerate(weekly_dates):
        if save_date > today:
            user_weekly_record.append(None)
        else:
            save = db.query(DailySave).filter(
                DailySave.user_id == current_user.id,
                DailySave.gang_id == gang.id,
                DailySave.save_date == save_date
            ).first()
            user_weekly_record.append(save.saved if save else False)
    
    # Get today's save status
    today_save = db.query(DailySave).filter(
        DailySave.user_id == current_user.id,
        DailySave.gang_id == gang.id,
        DailySave.save_date == date.today()
    ).first()
    user_today_save = today_save.saved if today_save else False
    
    result = GangHomeData(
        gang=gang,
        members=members,
        weekly_records=weekly_records,
        user_weekly_record=user_weekly_record,
        user_today_save=user_today_save
    )
    print(f"Returning data with {len(members)} members, {len(weekly_records)} weekly records")
    return result

@app.post("/gangs/{gang_id}/save")
def save_today(gang_id: str, save_request: SaveRequest, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    gang = db.query(Gang).filter(Gang.gang_id == gang_id).first()
    if not gang:
        raise HTTPException(status_code=404, detail="Gang not found")
    
    # Check if user is member
    member = db.query(GangMember).filter(
        GangMember.user_id == current_user.id,
        GangMember.gang_id == gang.id
    ).first()
    if not member:
        raise HTTPException(status_code=403, detail="Not a member of this gang")
    
    # Check if already saved today
    existing_save = db.query(DailySave).filter(
        DailySave.user_id == current_user.id,
        DailySave.gang_id == gang.id,
        DailySave.save_date == date.today()
    ).first()
    
    if existing_save:
        existing_save.saved = save_request.saved
        db.commit()
    else:
        new_save = DailySave(
            user_id=current_user.id,
            gang_id=gang.id,
            saved=save_request.saved,
            save_date=date.today()
        )
        db.add(new_save)
        db.commit()
    
    return {"message": "Save status updated", "saved": save_request.saved}

@app.get("/user/gangs")
def get_user_gangs(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    user_gangs = db.query(GangMember).filter(GangMember.user_id == current_user.id).all()
    gangs = []
    for member in user_gangs:
        gang = db.query(Gang).filter(Gang.id == member.gang_id).first()
        if gang:
            gangs.append({
                "id": gang.id,
                "name": gang.name,
                "description": gang.description,
                "gang_id": gang.gang_id,
                "role": member.role,
                "member_count": db.query(GangMember).filter(GangMember.gang_id == gang.id).count()
            })
    return gangs

@app.get("/gangs/{gang_id}/chat", response_model=List[ChatMessageSchema])
def get_chat_messages(gang_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    print(f"Getting chat messages for gang: {gang_id}")
    gang = db.query(Gang).filter(Gang.gang_id == gang_id).first()
    if not gang:
        print(f"Gang not found: {gang_id}")
        raise HTTPException(status_code=404, detail="Gang not found")
    
    # Check if user is member
    member = db.query(GangMember).filter(
        GangMember.user_id == current_user.id,
        GangMember.gang_id == gang.id
    ).first()
    if not member:
        print(f"User {current_user.id} not a member of gang {gang.id}")
        raise HTTPException(status_code=403, detail="Not a member of this gang")
    
    messages = db.query(ChatMessage).filter(
        ChatMessage.gang_id == gang.id
    ).order_by(ChatMessage.created_at.desc()).limit(50).all()
    
    print(f"Found {len(messages)} messages for gang {gang_id}")
    return list(reversed(messages))

@app.post("/gangs/{gang_id}/chat", response_model=ChatMessageSchema)
def send_message(gang_id: str, message: ChatMessageCreate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    print(f"Sending message to gang: {gang_id}, message: {message.message}")
    gang = db.query(Gang).filter(Gang.gang_id == gang_id).first()
    if not gang:
        print(f"Gang not found: {gang_id}")
        raise HTTPException(status_code=404, detail="Gang not found")
    
    # Check if user is member
    member = db.query(GangMember).filter(
        GangMember.user_id == current_user.id,
        GangMember.gang_id == gang.id
    ).first()
    if not member:
        print(f"User {current_user.id} not a member of gang {gang.id}")
        raise HTTPException(status_code=403, detail="Not a member of this gang")
    
    chat_message = ChatMessage(
        user_id=current_user.id,
        gang_id=gang.id,
        message=message.message
    )
    db.add(chat_message)
    db.commit()
    db.refresh(chat_message)
    
    print(f"Message sent successfully: {chat_message.id}")
    return chat_message

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 