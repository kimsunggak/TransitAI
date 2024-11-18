# chatbot.py
import os
from dotenv import load_dotenv
from langchain_openai import ChatOpenAI
from langchain.prompts import PromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_core.runnables import RunnableSequence, RunnablePassthrough
from firebase_setup import db
from typing import Dict, List
from matching_users import get_all_collected_info,find_matching_users
from datetime import datetime
class TaxiMatchingChatBot:
    def __init__(self, api_key: str):

        self.llm = ChatOpenAI(
            model_name = "gpt-4o",
            openai_api_key = api_key,
            temperature = 0.7
        )
        
        self.prompt = PromptTemplate(
    #프롬프트에서 사용될 변수들
    input_variables=["history", "user_input", "collected_info","recommendations","num_recommendations"],
    template="""
당신은 택시 동승 매칭 서비스의 챗봇입니다.
사용자와 대화를 통해 다음 정보를 수집하고, 매칭 가능한 사용자들을 추천하세요.:

- 원하는 탑승 위치 (departure)
- 도착 위치 (arrival)
- 원하는 탑승 시간 (time)

현재까지 수집된 정보:
{collected_info}

추천된 사용자:
{recommendations}

매칭된 사용자가 {num_recommendations}명 있습니다. 매칭을 도와드릴까요? (예/아니오)

친절하고 공손한 말투로 답변하세요.

**응답 형식:**

[응답]
<사용자에게 보여줄 응답>

[정보]
원하는 탑승 위치: <departure 또는 '미정'>
도착 위치: <arrival 또는 '미정'>
원하는 탑승 시간: <time 또는 '미정'> 
[매칭 상태]
pending_match: <True 또는 'False'>

주의사항:
- 응답은 [응답] 섹션에 작성합니다.
- 추출된 정보는 [정보] 섹션에 작성합니다.
- 상태는 [상태] 섹션에 작성합니다.
- 값이 없을 경우 '미정'으로 표시합니다.
- 시간을 항상 "HH:MM" 형식으로 표시합니다.
대화 내역:
{history}
사용자: {user_input}
챗봇:
"""
)

        #LLM 출력을 문자열로 파싱
        self.output_parser = StrOutputParser()

        # RunnableSequence를 사용하여 전체 체인 구성
        self.chain = RunnableSequence(
            {
                "history": RunnablePassthrough(),
                "user_input": RunnablePassthrough(),
                "collected_info": RunnablePassthrough(),
                "recommendations": RunnablePassthrough(),
                "num_recommendations": RunnablePassthrough()
            }
            #체인 연산자
            #앞서 정의한 프롬프트 템플릿 적용
            | self.prompt
            #OpenAI GPT-4o 모델을 사용하여 응답 생성
            | self.llm
            | self.output_parser
        )
    def parse_response(self, response: str):
        try:
            # 응답과 정보를 분리
            response_parts = response.split('[정보]')
            bot_reply = response_parts[0].replace('[응답]', '').strip()
            info_section = response_parts[1].strip() if len(response_parts) > 1 else ''
            status_section = ""
            if '[매칭 상태]' in response:
                status_section = response.split('[매칭 상태]')[1].split('\n')[0].strip()

            #원하는 정보 추출
            extracted_info = {}
            for line in info_section.split('\n'):
                if ':' in line:
                    key, value = line.split(':', 1)
                    key = key.strip()
                    value = value.strip()
                    if key == '원하는 탑승 위치':
                        extracted_info['departure'] = value
                    elif key == '도착 위치':
                        extracted_info['arrival'] = value
                    elif key == '원하는 탑승 시간':
                         # 시간 형식 검증 및 정리
                        if value != '미정':
                            try:
                                # "HH:MM" 형식인지 확인
                                datetime.strptime(value, "%H:%M")
                                extracted_info['time'] = value
                            except ValueError:
                                print(f"잘못된 시간 형식: {value}")
                                extracted_info['time'] = '미정'
                        else:
                            extracted_info['time'] = value
            # 상태 추출
            if status_section:
                if 'True' in status_section:
                    extracted_info['pending_match'] = True
                else:
                    extracted_info['pending_match'] = False
            return bot_reply, extracted_info
        except Exception as e:
            print(f"응답 파싱 오류: {str(e)}")
            return response, {}
        
    #사용자 입력을 받아 응답 생성
    def get_response(self, user_input: str, history: str = "",collected_info: dict = None,current_user_id:str = ""):
        if collected_info is None:
            collected_info = {"departure": "미정", "arrival": "미정", "time": "미정"}
        # 수집된 정보를 문자열로 변환
        collected_info_str = '\n'.join([f"{key}:{value}" for key, value in collected_info.items()])
        #다른 사용자들의 정보 가져오기
        all_users_info = get_all_collected_info(current_user_id)
        print("다른 사용자들의 정보:", all_users_info)
        
        recommendations = find_matching_users(collected_info, all_users_info)
        print("추천된 사용자:", recommendations)
        # 매칭된 사용자 수 계산
        num_recommendations = len(recommendations)
        try:
            #정의된 체인을 실행하여 최종적인 응답 생성
            response = self.chain.invoke({
                "history": history,
                "user_input": user_input,
                "collected_info": collected_info_str,
                "recommendations": recommendations,
                "num_recommendations": num_recommendations
            })
            bot_response, extracted_info = self.parse_response(response)
            # 매칭 동의 상태 확인 ??
            if extracted_info.get('pending_match'):
                # 매칭 정보 저장
                matched_user = recommendations[0] if recommendations else None
                if matched_user:
                    # 매칭된 사용자의 정보 가져오기
                    matched_user_info = all_users_info.get(matched_user, {})
                    collected_info['pending_match_info'] = {
                        "departure": collected_info.get("departure", "미정"),
                        "arrival": collected_info.get("arrival", "미정"),
                        "user_time": collected_info.get("time", "미정"),
                        "matched_user_time": matched_user_info.get("time", "미정")
                    }
                collected_info['pending_match'] = True
            else:
                collected_info['pending_match'] = False

            # 수집된 정보 업데이트
            for key in ["departure", "arrival", "time"]:
                #해당 값이 존재하고 미정이 아닌지 확인
                if extracted_info.get(key) and extracted_info[key] != '미정':
                    collected_info[key] = extracted_info[key]
            # 매칭 대기 상태인 경우 응답 검증
            if collected_info.get('pending_match'):
                agree_keywords = ["예", "네", "동의", "좋아요"]
                disagree_keywords = ["아니오", "아니", "취소"]

                if user_input.strip() in agree_keywords:
                    # 매칭을 완료하고, 시간의 평균을 계산
                    match_info = collected_info.get("pending_match_info", {})
                    if match_info:
                        departure = match_info["departure"]
                        arrival = match_info["arrival"]
                        user_time = match_info["user_time"]
                        matched_user_time = match_info["matched_user_time"]
                        
                        # 시간 형식 "HH:MM"을 datetime 객체로 변환
                        time_format = "%H:%M"
                        try:
                            # 두 시간 모두 '미정'이 아닌 경우에만 변환 시도
                            if user_time != '미정' and matched_user_time != '미정':
                                user_time_dt = datetime.strptime(user_time, time_format)
                                matched_user_time_dt = datetime.strptime(matched_user_time, time_format)

                            # 두 시간 모두 유효한지 확인
                            if user_time_dt and matched_user_time_dt:
                                average_time_dt = user_time_dt + (matched_user_time_dt - user_time_dt) / 2
                                average_time = average_time_dt.strftime(time_format)
                                
                                # 매칭 완료 메시지 생성
                                bot_response = (f"서로에게 출발지: {departure}으로 시간: {average_time}으로 오시면 됩니다!! "
                                               f"매칭이 완료되었습니다. 즐거운 여행 되세요!")
                            
                                # 매칭 완료 후 상태 초기화
                                collected_info['pending_match'] = False
                                collected_info.pop('pending_match_info', None)
                            else:
                                bot_response = "매칭된 사용자 중 하나의 시간이 '미정'입니다. 매칭을 완료할 수 없습니다."
                        except ValueError as ve:
                            bot_response = f"시간 형식 오류: {ve}. 시간을 'HH:MM' 형식으로 입력해 주세요."
                    else:
                        bot_response = "매칭 정보를 처리하는 중 오류가 발생했습니다. 다시 시도해주세요."
                elif user_input.strip() in disagree_keywords:
                    bot_response = "매칭을 취소하셨습니다. 다른 도움을 원하시면 말씀해주세요."
                    collected_info['pending_match'] = False
                    collected_info.pop('pending_match_info', None)
                else:
                    # 유효하지 않은 응답일 경우 다시 입력 요청
                    bot_response = "매칭을 도와드리기 위해 '예' 또는 '아니오'로만 응답해 주세요."
            
            return bot_response, collected_info
        except Exception as e:
            return f"죄송합니다, 오류가 발생했습니다: {str(e)}", collected_info
            
load_dotenv()
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

# 챗봇 인스턴스 생성
chatbot_instance = TaxiMatchingChatBot(api_key=OPENAI_API_KEY)

def chatbot_response(user_input: str, history: str = "", collected_info: dict = None,current_user_id:str="") -> str:
    bot_response, updated_info = chatbot_instance.get_response(user_input, history, collected_info,current_user_id)
    # 필요하다면 collected_info를 업데이트할 수 있습니다.
    return bot_response, updated_info

"""
# 예시로 직접 실행할 때만 챗봇을 테스트
if __name__ == "__main__":
    print("챗봇 테스트를 시작합니다. 종료하려면 '종료', 'exit', 또는 'quit'을 입력하세요.")
    while True:
        user_input = input("사용자: ")
        if user_input.lower() in ['종료', 'exit', 'quit']:
            print("챗봇을 종료합니다.")
            break
        response = chatbot_response(user_input)
        print(f"챗봇: {response}")
"""
