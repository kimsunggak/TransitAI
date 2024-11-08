# chatbot.py
import os
from dotenv import load_dotenv
from langchain.llms import OpenAI
from langchain.prompts import PromptTemplate
from langchain.chains import LLMChain
from langchain.memory import ConversationBufferMemory

# 환경 변수 로드
load_dotenv()
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

# LLM 초기화
llm = OpenAI(
    openai_api_key=OPENAI_API_KEY,
    temperature=0.7
)

# 프롬프트 템플릿 정의
prompt = PromptTemplate(
    input_variables=["history", "user_input"],
    template="""
당신은 택시 동승 매칭 서비스의 챗봇입니다.
사용자와 대화를 통해 다음 정보를 수집하세요:

- 픽업 위치
- 도착 위치
- 탑승 시간

수집한 정보를 바탕으로 사용자에게 매칭 결과를 제공하세요.
친절하고 공손한 말투로 답변하세요.

대화 내역:
{history}
사용자: {user_input}
챗봇:
"""
)

# 메모리 생성
memory = ConversationBufferMemory(memory_key="history")

# LLMChain 생성
chain = LLMChain(
    llm=llm,
    prompt=prompt,
    memory=memory,
    verbose=True  # 디버깅을 위해 활성화
)

# 챗봇 응답 함수
def chatbot_response(user_input):
    try:
        response = chain.invoke({"user_input": user_input})
        return response['text']
    except Exception as e:
        return f"죄송합니다, 오류가 발생했습니다: {str(e)}"
