#0~45 랜덤 수치 생성 후 변수별 가중치 부여하여 데이터 생성
import pandas as pd
import random
from datetime import datetime, timedelta

# 시간대 정의
# 월요일과 금요일 아침 시간대 (11개)
time_slots_special_monday_and_friday = ['07:50', '08:00', '08:10', '08:15', '08:20', '08:25', '08:30',
                                        '08:35', '08:40', '08:50', '09:05']

# 화, 수, 목 아침 시간대 (16개)
time_slots_special = ['07:50', '07:55', '08:00', '08:05', '08:10', '08:15', '08:20', '08:25', '08:30',
                      '08:35', '08:40', '08:45', '08:50', '08:55', '09:00', '09:05']

# 일반 시간대 (20개)
time_slots_regular = ["10:30", "10:40", "10:50", "11:00", "11:10", "11:20", "11:30", "12:50", "13:10",
                      "13:30", "13:40", "14:00", "14:10", "14:20", "14:30", "15:00", "16:00", "17:00",
                      "17:20", "17:40"]

# 월요일과 금요일에 제외할 시간대 (화수목에만 있는 시간대)
exclude_on_monday_and_friday = ["10:40", "13:30", "13:50", "15:00", "16:00"]

# 시간대를 숫자로 변환하는 함수
def time_to_minutes(t):
    h, m = map(int, t.split(':'))
    return h * 60 + m

# 전철 도착 여부 설정 함수
def set_train_arrival(time):
    # 전철이 도착하는 시간대
    train_arrival_times = ["07:50", "08:00", "08:05", "08:10", "08:15", "08:20", "08:25", "08:30", "08:35",
                           "08:40", "08:45", "11:10", "11:20", "14:00", "14:10", "14:20"]
    return 1 if time in train_arrival_times else 0

# 대기 인원 수 조정 함수
def adjust_waiting_passengers(time, weather, train_arrival, event):
    time_minutes = time_to_minutes(time)
    
    # 시간대별 가중치 설정
    if time_to_minutes("08:15") <= time_minutes <= time_to_minutes("08:40"):
        time_slot_weight = 1.5
    elif time_minutes in [time_to_minutes(t) for t in ["08:10", "08:05", "08:45", "14:10", "14:20"]]:
        time_slot_weight = 1.3
    elif time_minutes in [time_to_minutes(t) for t in ["11:10", "11:20", "14:10", "14:20"]]:
        time_slot_weight = 1.2
    elif time_minutes in [time_to_minutes(t) for t in ["11:00", "11:30", "14:00", "14:30"]]:
        time_slot_weight = 1.05
    else:
        time_slot_weight = 1.0
    
    # 3시에서 5시 사이에는 사람들이 몰리지않음
    if time_to_minutes("15:00") <= time_minutes <= time_to_minutes("17:00"):
        waiting_passengers = random.randint(5, 45)
        return waiting_passengers
    
    elif time in ['08:50', '11:20', '14:20']:
        base_min, base_max = 20, 50
    elif time in ['09:05', '11:30', '14:30', '17:40']:
        base_min, base_max = 10, 40
    elif time_to_minutes("08:15") <= time_minutes <= time_to_minutes("08:40"):
        base_min, base_max = 30, 80
    elif (time_to_minutes("11:00") <= time_minutes <= time_to_minutes("11:20") or
          time_to_minutes("14:00") <= time_minutes <= time_to_minutes("14:20")):
        base_min, base_max = 30, 60
    else:
        base_min, base_max = 10, 60
    
    waiting_passengers = random.randint(base_min, base_max)
    
    # 날씨 가중치
    weather_weight = {
        1: 1.15,  # 더움
        2: 1.0,   # 선선함
        3: 0.95,  # 흐림
        4: 1.18   # 비
    }
    
    # 이벤트 가중치
    event_weight = 1.2 if event == 1 else 1.0
    
    # 전철 도착 가중치
    train_arrival_weight = 1.4 if train_arrival == 1 else 1.0
    
    total_weight = weather_weight[weather] * event_weight * train_arrival_weight * time_slot_weight
    
    waiting_passengers = int(waiting_passengers * total_weight)
    waiting_passengers = max(0, min(waiting_passengers, 225))
    
    return waiting_passengers

# 데이터 생성 함수
def generate_random_data():
    data = []
    start_date = datetime.strptime('2022-03-02', '%Y-%m-%d')
    end_date = datetime.strptime('2024-10-04', '%Y-%m-%d')
    delta = timedelta(days=1)
    
    current_date = start_date
    while current_date <= end_date:
        # 방학 기간은 제외
        month = current_date.month
        if month in [1, 2, 7, 8]:
            current_date += delta
            continue  # 해당 월이면 데이터 생성 건너뜀
        if current_date.weekday() < 5:  # 월요일=0, 금요일=4
            day = current_date.weekday() + 1  # 요일 (월요일=1, 금요일=5)
            date_str = current_date.strftime('%Y-%m-%d')
            
            if day == 1 or day == 5:
                valid_time_slots = [time for time in time_slots_regular if time not in exclude_on_monday_and_friday]
                valid_time_slots += time_slots_special_monday_and_friday
            else:
                valid_time_slots = time_slots_regular + time_slots_special
            
            for time in valid_time_slots:
                weather = random.randint(1, 4)
                event = random.randint(0, 1)
                train_arrival = set_train_arrival(time)
                waiting_passengers = adjust_waiting_passengers(time, weather, train_arrival, event)
                
                data.append({
                    'Date': date_str,
                    'Day': day,
                    'Time': time,
                    'Weather': weather,
                    'Event': event,
                    'Train_Arrival': train_arrival,
                    'Waiting_Passengers': waiting_passengers
                })
        current_date += delta
    
    df = pd.DataFrame(data)
    return df

# 데이터 생성 및 저장
df = generate_random_data()
df.to_csv('data/ki.csv', index=False)
