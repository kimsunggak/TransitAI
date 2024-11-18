import pickle
from fastapi import FastAPI
import xgboost as xgb
from Datapreprocessor import DataPreprocessor
import pandas as pd
from pydantic import BaseModel
from chatbot import chatbot_response
from fastapi.responses import JSONResponse
from firebase_setup import db
from firebase_admin import firestore
from fastapi.middleware.cors import CORSMiddleware

# 요청 받을 데이터의 구조 정의
class ChatRequest(BaseModel):
    user_id: str
    message: str

# FastAPI 앱 생성
app = FastAPI()

# CORS 설정 추가
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 모든 도메인에서의 요청을 허용 (보안을 위해 필요한 도메인만 설정하는 것이 좋습니다)
    allow_credentials=True,
    allow_methods=["*"],  # 모든 HTTP 메서드 허용 (GET, POST, OPTIONS 등)
    allow_headers=["*"],  # 모든 헤더 허용
)

# 전처리 객체 생성
preprocessor = DataPreprocessor()

# 저장된 XGBoost 모델 로드
with open("xgboost_model.pkl", "rb") as f:
    model = pickle.load(f)

# 요청 데이터를 받기 위한 Pydantic 모델 생성
class PredictionInput(BaseModel):
    Date: str
    Day: int
    Time: str
    Weather: int
    Event: int
    Train_Arrival: int

@app.get("/")
async def read_root():
    return {"message": "Server is running!"}

@app.post("/predict")
async def predict(request: PredictionInput):
    # 요청 데이터 확인
    request_data = request.dict()
    
    # 요청 데이터를 데이터프레임으로 변환
    df = pd.DataFrame([request_data])
    print("데이터프레임 형성 후:")
    print(df)
    
    # 입력 데이터 전처리 수행
    df = preprocessor.preprocess(df)
    print("전처리된 데이터프레임:")
    print(df)
    
    # 예측 수행
    prediction = model.predict(df)
    print("예측 결과:", int(prediction[0]))
    
    # 예측 결과 반환
    return {"prediction": int(prediction[0])}

@app.post("/chat")
async def chat(request: ChatRequest):
    try:
        user_id = request.user_id
        user_message = request.message

        # Firebase에서 해당 사용자의 데이터 가져오기
        chat_ref = db.collection("chats").document(user_id)
        chat_data = chat_ref.get().to_dict()

        # 데이터가 없으면 초기화
        if not chat_data:
            chat_data = {
                "messages": [],
                "collected_info": {
                    "departure": "미정",
                    "arrival": "미정",
                    "time": "미정"
                }
            }

        # 수집된 정보와 대화 내역 가져오기
        collected_info = chat_data.get("collected_info", {})
        history_messages = chat_data["messages"]

        # 대화 내역 문자열 생성
        history = ""
        for msg in history_messages:
            history += f"사용자: {msg['user']}\n챗봇: {msg['bot']}\n"

        # 챗봇 응답 생성
        bot_response, collected_info = chatbot_response(user_message, history, collected_info,current_user_id=user_id)

        # 대화 내역에 현재 대화 추가
        history_messages.append({"user": user_message, "bot": bot_response})
        
        #대화 내역 길어지면 혼란 가능 -> 최근 10개만 유지
        history_messages = history_messages[-10:]
        # 업데이트된 데이터를 Firebase에 저장
        chat_data["messages"] = history_messages
        chat_data["collected_info"] = collected_info
        chat_ref.set(chat_data)

        # JSON 응답 반환
        return JSONResponse(
            content={"response": bot_response},
            media_type="application/json; charset=utf-8"
        )
    except Exception as e:
        print(f"챗봇 오류: {str(e)}")
        return JSONResponse(
            content={"error": "서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요."},
            media_type="application/json; charset=utf-8"
        )

