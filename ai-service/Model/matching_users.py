from datetime import datetime,timedelta
from typing import List,Dict
from firebase_setup import db
import re
#firebase에서 모든 사용자 정보 불러오기
def get_all_collected_info(current_user_id: str):
    other_users_info = [
        {
            "user_id": doc.id,
            "collected_info": doc.to_dict().get("collected_info", {})
        }
        for doc in db.collection("chats").stream()
        if doc.id != current_user_id
    ]
    return other_users_info

def parse_time(time_str: str):
    # 숫자만 추출
    match = re.findall(r'\d+', time_str)
    if not match:
        return None
    hour = int(match[0])
    minute = int(match[1]) if len(match) > 1 else 0
    try:
        return datetime.strptime(f"{hour:02d}:{minute:02d}", "%H:%M")
    except ValueError:
        return None
#사용자 매칭 함수
def find_matching_users(current_user_info: Dict,all_users_info:List[Dict]):
    matches = []
    #현재 사용자 정보
    current_departure = current_user_info.get('departure', "미정")
    current_arrival = current_user_info.get('arrival', "미정")
    current_time_str = current_user_info.get('time', "미정")
    # 시간 파싱
    current_time = parse_time(current_time_str)
    #다른 사용자 정보
    for user in all_users_info:
        match = False
        # 다른 사용자의 출발 시간을 datetime 객체로 변환
        user_time = parse_time(user['collected_info'].get('time', "미정"))
        # 다른 사용자의 출발지와 도착지가 입력되어 있는 경우만 매칭
        if user['collected_info'].get('departure') and user['collected_info'].get('arrival'):
            if current_time is not None and user_time is not None:
                # 시간 차이 계산 (초 단위)
                time_diff = abs((user_time - current_time).total_seconds())
                if time_diff <= 1200:
                    matches.append({
                        'user_id': user['user_id'],
                        'user_departure': user['collected_info'].get('departure', "미정"),
                        'user_arrival': user['collected_info'].get('arrival', "미정"),
                        'user_time': user['collected_info'].get('time', "미정")
                        })
    return matches
