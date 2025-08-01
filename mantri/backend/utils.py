import random
import string
from datetime import datetime, timedelta, date
from typing import List

def generate_gang_id() -> str:
    return ''.join(random.choices(string.digits, k=5))

def get_week_start_date(target_date: date = None) -> date:
    if target_date is None:
        target_date = date.today()
    return target_date - timedelta(days=target_date.weekday())

def get_week_end_date(target_date: date = None) -> date:
    if target_date is None:
        target_date = date.today()
    week_start = get_week_start_date(target_date)
    return week_start + timedelta(days=6)

def get_weekly_record_dates(target_date: date = None) -> List[date]:
    if target_date is None:
        target_date = date.today()
    week_start = get_week_start_date(target_date)
    return [week_start + timedelta(days=i) for i in range(7)]

def is_current_week(target_date: date) -> bool:
    today = date.today()
    week_start = get_week_start_date(today)
    week_end = get_week_end_date(today)
    return week_start <= target_date <= week_end

def get_day_of_week_index(target_date: date = None) -> int:
    if target_date is None:
        target_date = date.today()
    return target_date.weekday()

def should_reset_daily() -> bool:
    now = datetime.now()
    return now.hour == 1 and now.minute == 0

def should_reset_weekly() -> bool:
    now = datetime.now()
    return now.weekday() == 0 and now.hour == 1 and now.minute == 0 