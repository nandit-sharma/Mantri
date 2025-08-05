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

# Initialize database tables
try:
    print("Creating database tables...")
    Base.metadata.create_all(bind=engine)
    print("Database tables created successfully")
except Exception as e:
    print(f"Error creating database tables: {str(e)}")
    import traceback
    traceback.print_exc()

from config import settings
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Hello from FastAPI"}

@app.get("/health")
def health_check():
    return {"status": "healthy", "message": "Backend is running"}

@app.get("/db-test")
def test_database():
    try:
        from database import engine
        with engine.connect() as connection:
            result = connection.execute("SELECT 1")
            return {"status": "success", "message": "Database connection successful"}
    except Exception as e:
        return {"status": "error", "message": f"Database connection failed: {str(e)}"}

@app.get("/tables-test")
def test_tables():
    try:
        from database import engine
        with engine.connect() as connection:
            # Test if tables exist
            tables = []
            for table_name in ["users", "gangs", "gang_members", "daily_saves", "chat_messages"]:
                try:
                    result = connection.execute(f"SELECT 1 FROM {table_name} LIMIT 1")
                    tables.append(f"{table_name}: exists")
                except Exception as e:
                    tables.append(f"{table_name}: {str(e)}")
            return {"status": "success", "tables": tables}
    except Exception as e:
        return {"status": "error", "message": f"Database test failed: {str(e)}"}

@app.get("/simple-gang-test/{gang_id}")
def simple_gang_test(gang_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    try:
        print(f"Simple gang test for gang_id: {gang_id}")
        
        # Test basic gang query
        gang = db.query(Gang).filter(Gang.gang_id == gang_id).first()
        if not gang:
            return {"error": "Gang not found"}
        
        # Test member query
        member = db.query(GangMember).filter(
            GangMember.user_id == current_user.id,
            GangMember.gang_id == gang.id
        ).first()
        if not member:
            return {"error": "Not a member"}
        
        # Test user query
        user = db.query(User).filter(User.id == current_user.id).first()
        if not user:
            return {"error": "User not found"}
        
        return {
            "success": True,
            "gang": {
                "id": gang.id,
                "name": gang.name,
                "gang_id": gang.gang_id
            },
            "member": {
                "id": member.id,
                "role": member.role
            },
            "user": {
                "id": user.id,
                "username": user.username
            }
        }
    except Exception as e:
        print(f"Error in simple gang test: {str(e)}")
        import traceback
        traceback.print_exc()
        return {"error": f"Test failed: {str(e)}"}

@app.get("/ping")
def ping():
    return {"status": "pong", "timestamp": datetime.now().isoformat()}

# app = FastAPI(
#     title=settings.PROJECT_NAME,
#     version=settings.VERSION,
#     openapi_url=f"{settings.API_V1_STR}/openapi.json"
# )

# Parse CORS origins
origins = settings.BACKEND_CORS_ORIGINS.split(",") if settings.BACKEND_CORS_ORIGINS != "*" else ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
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

def reset_weekly_data():
    while True:
        now = datetime.now()
        next_monday = now + timedelta(days=(7 - now.weekday()))
        next_monday = next_monday.replace(hour=0, minute=0, second=0, microsecond=0)
        
        time.sleep((next_monday - now).total_seconds())
        
        with get_db() as db:
            print("Weekly reset: Clearing weekly save data")
            db.query(DailySave).filter(
                DailySave.save_date < date.today()
            ).delete()
            db.commit()

def reset_monthly_data():
    while True:
        now = datetime.now()
        next_month = now.replace(day=1) + timedelta(days=32)
        next_month = next_month.replace(day=1, hour=0, minute=0, second=0, microsecond=0)
        
        time.sleep((next_month - now).total_seconds())
        
        with get_db() as db:
            print("Monthly reset: Clearing monthly save data")
            db.query(DailySave).filter(
                DailySave.save_date < date.today()
            ).delete()
            db.commit()

weekly_thread = threading.Thread(target=reset_weekly_data, daemon=True)
monthly_thread = threading.Thread(target=reset_monthly_data, daemon=True)
weekly_thread.start()
monthly_thread.start()

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

@app.post("/gangs", response_model=GangSchema, status_code=201)
def create_gang(gang: GangCreate, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    try:
        print(f"Creating gang: {gang.name} by user {current_user.id}")
        
        # Test database connection first
        try:
            from sqlalchemy import text
            db.execute(text("SELECT 1"))
            print("Database connection test successful")
        except Exception as db_error:
            print(f"Database connection error: {str(db_error)}")
            raise HTTPException(status_code=500, detail=f"Database connection failed: {str(db_error)}")
        
        gang_id = generate_gang_id()
        while db.query(Gang).filter(Gang.gang_id == gang_id).first():
            gang_id = generate_gang_id()
        
        print(f"Generated gang_id: {gang_id}")
        
        db_gang = Gang(
            name=gang.name,
            description=gang.description,
            is_public=gang.is_public,
            gang_id=gang_id,
            host_id=current_user.id
        )
        db.add(db_gang)
        db.commit()
        db.refresh(db_gang)
        
        print(f"Created gang with ID: {db_gang.id}")
        
        # Add creator as host
        member = GangMember(user_id=current_user.id, gang_id=db_gang.id, role="host")
        db.add(member)
        db.commit()
        
        print(f"Added user as host to gang")
        
        return db_gang
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        print(f"Error creating gang: {str(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Failed to create gang: {str(e)}")

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
    try:
        print(f"Getting gang home for gang_id: {gang_id}, user_id: {current_user.id}")
        
        # Test database connection first
        try:
            from sqlalchemy import text
            db.execute(text("SELECT 1"))
            print("Database connection test successful")
        except Exception as db_error:
            print(f"Database connection error: {str(db_error)}")
            raise HTTPException(status_code=500, detail=f"Database connection failed: {str(db_error)}")
        
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
        
        # Get all members with users in a single query
        try:
            members_with_users = db.query(GangMember, User).join(
                User, GangMember.user_id == User.id
            ).filter(GangMember.gang_id == gang.id).all()
            print(f"Found {len(members_with_users)} members for gang {gang.id}")
        except Exception as e:
            print(f"Error querying members: {str(e)}")
            # Fallback to simple query
            members_with_users = []
            gang_members = db.query(GangMember).filter(GangMember.gang_id == gang.id).all()
            for member in gang_members:
                user = db.query(User).filter(User.id == member.user_id).first()
                if user:
                    members_with_users.append((member, user))
            print(f"Fallback query found {len(members_with_users)} members")
        
        # Get weekly records for all members
        week_start = get_week_start_date()
        week_end = get_week_end_date()
        weekly_dates = get_weekly_record_dates()
        today = date.today()
        
        weekly_records = []
        try:
            for member, user in members_with_users:
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
        except Exception as e:
            print(f"Error creating weekly records: {str(e)}")
            # Create empty weekly records as fallback
            weekly_records = []
            for member, user in members_with_users:
                weekly_records.append(WeeklyRecord(
                    user_id=user.id,
                    username=user.username,
                    week_saves=0,
                    weekly_record=[False] * len(weekly_dates),
                    role=member.role
                ))
        
        # Sort weekly records by week_saves (descending)
        weekly_records.sort(key=lambda x: x.week_saves, reverse=True)
        
        # Get current user's weekly record
        user_weekly_record = []
        try:
            for save_date in weekly_dates:
                if save_date > today:
                    user_weekly_record.append(None)
                else:
                    save = db.query(DailySave).filter(
                        DailySave.user_id == current_user.id,
                        DailySave.gang_id == gang.id,
                        DailySave.save_date == save_date
                    ).first()
                    user_weekly_record.append(save.saved if save else False)
        except Exception as e:
            print(f"Error getting user weekly record: {str(e)}")
            user_weekly_record = [False] * len(weekly_dates)
        
        # Get today's save status
        try:
            today_save = db.query(DailySave).filter(
                DailySave.user_id == current_user.id,
                DailySave.gang_id == gang.id,
                DailySave.save_date == date.today()
            ).first()
            user_today_save = today_save.saved if today_save else False
        except Exception as e:
            print(f"Error getting today's save status: {str(e)}")
            user_today_save = False
        
        # Convert members_with_users back to just members for the response
        members = []
        for member, user in members_with_users:
            member.user = user
            members.append(member)
        
        result = GangHomeData(
            gang=gang,
            members=members,
            weekly_records=weekly_records,
            user_weekly_record=user_weekly_record,
            user_today_save=user_today_save
        )
        print(f"Returning data with {len(members)} members, {len(weekly_records)} weekly records")
        return result
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error in get_gang_home: {str(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Failed to get gang home: {str(e)}")

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

@app.delete("/gangs/{gang_id}/chat")
def clear_chat(gang_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    print(f"Clearing chat for gang: {gang_id}")
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
    
    # Delete all chat messages for this gang
    db.query(ChatMessage).filter(ChatMessage.gang_id == gang.id).delete()
    db.commit()
    
    print(f"Chat cleared successfully for gang {gang_id}")
    return {"message": "Chat cleared successfully"}

@app.put("/users/profile")
def update_profile(request: dict, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    print(f"Updating profile for user: {current_user.id}")
    
    username = request.get('username')
    if not username:
        raise HTTPException(status_code=400, detail="Username is required")
    
    if len(username) < 3:
        raise HTTPException(status_code=400, detail="Username must be at least 3 characters")
    
    existing_user = db.query(User).filter(User.username == username, User.id != current_user.id).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Username already exists")
    
    current_user.username = username
    db.commit()
    
    print(f"Profile updated successfully for user {current_user.id}")
    return {"message": "Profile updated successfully"}

@app.get("/gangs/{gang_id}/members")
def get_gang_members(gang_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
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
    
    members = db.query(GangMember).filter(GangMember.gang_id == gang.id).all()
    return members

@app.delete("/gangs/{gang_id}/members/{user_id}")
def remove_member(gang_id: str, user_id: int, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    gang = db.query(Gang).filter(Gang.gang_id == gang_id).first()
    if not gang:
        raise HTTPException(status_code=404, detail="Gang not found")
    
    # Check if current user is host
    current_member = db.query(GangMember).filter(
        GangMember.user_id == current_user.id,
        GangMember.gang_id == gang.id
    ).first()
    if not current_member or current_member.role != "host":
        raise HTTPException(status_code=403, detail="Only host can remove members")
    
    # Remove the member
    member_to_remove = db.query(GangMember).filter(
        GangMember.user_id == user_id,
        GangMember.gang_id == gang.id
    ).first()
    if not member_to_remove:
        raise HTTPException(status_code=404, detail="Member not found")
    
    db.delete(member_to_remove)
    db.commit()
    return {"message": "Member removed successfully"}

@app.post("/gangs/{gang_id}/leave")
def leave_gang(gang_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
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
    
    # If user is host, check if there are other members
    if member.role == "host":
        other_members = db.query(GangMember).filter(
            GangMember.gang_id == gang.id,
            GangMember.user_id != current_user.id
        ).count()
        if other_members > 0:
            raise HTTPException(status_code=400, detail="Host cannot leave gang with other members. Transfer ownership first.")
    
    db.delete(member)
    db.commit()
    return {"message": "Successfully left gang"}

@app.get("/gangs/{gang_id}/monthly-leaderboard")
def get_monthly_leaderboard(gang_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
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
    
    # Get current month start and end dates
    today = date.today()
    month_start = date(today.year, today.month, 1)
    if today.month == 12:
        month_end = date(today.year + 1, 1, 1) - timedelta(days=1)
    else:
        month_end = date(today.year, today.month + 1, 1) - timedelta(days=1)
    
    # Get all members with their monthly saves
    members = db.query(GangMember).filter(GangMember.gang_id == gang.id).all()
    monthly_records = []
    
    for member in members:
        user = db.query(User).filter(User.id == member.user_id).first()
        monthly_saves = db.query(DailySave).filter(
            DailySave.user_id == member.user_id,
            DailySave.gang_id == gang.id,
            DailySave.save_date >= month_start,
            DailySave.save_date <= month_end,
            DailySave.saved == True
        ).count()
        
        monthly_records.append({
            "user_id": user.id,
            "username": user.username,
            "monthly_saves": monthly_saves,
            "role": member.role
        })
    
    # Sort by monthly saves (descending)
    monthly_records.sort(key=lambda x: x["monthly_saves"], reverse=True)
    
    # Find the Mantri (person with least saves)
    mantri = None
    if monthly_records:
        mantri = monthly_records[-1]
    
    return {
        "monthly_records": monthly_records,
        "mantri": mantri
    }

@app.put("/users/change-password")
def change_password(request: dict, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    print(f"Changing password for user: {current_user.id}")
    
    current_password = request.get('current_password')
    new_password = request.get('new_password')
    
    if not current_password or not new_password:
        raise HTTPException(status_code=400, detail="Current password and new password are required")
    
    if len(new_password) < 6:
        raise HTTPException(status_code=400, detail="New password must be at least 6 characters")
    
    # Verify current password
    if not verify_password(current_password, current_user.hashed_password):
        raise HTTPException(status_code=400, detail="Current password is incorrect")
    
    # Hash new password
    current_user.hashed_password = get_password_hash(new_password)
    db.commit()
    
    print(f"Password changed successfully for user {current_user.id}")
    return {"message": "Password changed successfully"}

@app.delete("/users/account")
def delete_account(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    print(f"Deleting account for user: {current_user.id}")
    
    # Delete all user's data
    db.query(DailySave).filter(DailySave.user_id == current_user.id).delete()
    db.query(ChatMessage).filter(ChatMessage.user_id == current_user.id).delete()
    db.query(GangMember).filter(GangMember.user_id == current_user.id).delete()
    
    # Delete gangs where user is host (if no other members)
    user_gangs = db.query(Gang).filter(Gang.host_id == current_user.id).all()
    for gang in user_gangs:
        member_count = db.query(GangMember).filter(GangMember.gang_id == gang.id).count()
        if member_count <= 1:  # Only host or no members
            db.query(ChatMessage).filter(ChatMessage.gang_id == gang.id).delete()
            db.query(GangMember).filter(GangMember.gang_id == gang.id).delete()
            db.delete(gang)
    
    # Delete the user
    db.delete(current_user)
    db.commit()
    
    print(f"Account deleted successfully for user {current_user.id}")
    return {"message": "Account deleted successfully"}

@app.get("/gangs/{gang_id}/activity")
def get_gang_activity(gang_id: str, current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    print(f"Getting activity for gang: {gang_id}")
    
    # Check if gang exists
    gang = db.query(Gang).filter(Gang.id == gang_id).first()
    if not gang:
        raise HTTPException(status_code=404, detail="Gang not found")
    
    # Check if user is a member
    member = db.query(GangMember).filter(
        GangMember.user_id == current_user.id,
        GangMember.gang_id == gang.id
    ).first()
    if not member:
        raise HTTPException(status_code=403, detail="Not a member of this gang")
    
    # For now, return mock activity data
    # In a real implementation, you would store activity logs in the database
    activities = [
        {
            "id": 1,
            "type": "save",
            "message": f"{current_user.username} saved today",
            "username": current_user.username,
            "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M"),
        },
        {
            "id": 2,
            "type": "join",
            "message": f"{current_user.username} joined the gang",
            "username": current_user.username,
            "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M"),
        },
        {
            "id": 3,
            "type": "mantri",
            "message": f"{current_user.username} became the Mantri",
            "username": current_user.username,
            "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M"),
        },
    ]
    
    return {"activities": activities}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000) 