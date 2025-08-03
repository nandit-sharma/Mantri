import uvicorn
from main import app
from database import engine
from models import Base

# Create all tables
Base.metadata.create_all(bind=engine)

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000) 