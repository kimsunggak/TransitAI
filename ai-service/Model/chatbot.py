# chatbot.py
import os
from dotenv import load_dotenv
from langchain_community.llms import OpenAI
from langchain.prompts import PromptTemplate
from langchain.chains import LLMChain
from langchain.memory import ConversationBufferMemory

class TaxiMatchingChatBot:
    def __init__(self, api_key: str, temperature: float = 0.7, verbose: bool = False):
        """
        챗봇을 초기화합니다.
        
        :param api_key: OpenAI API 키
        :param temperature: 생성 텍스트의 창의성 정도
        :param verbose: 체인의 디버깅 정보 출력 여부
        """
        self.llm = OpenAI(
            openai_api_key=api_key,
            temperature=temperature
        )
        
        self.prompt = PromptTemplate(
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
        
        self.memory = ConversationBufferMemory(memory_key="history")
        
        self.chain = LLMChain(
            llm=self.llm,
            prompt=self.prompt,
            memory=self.memory,
            verbose=verbose
        )
    
    def get_response(self, user_input: str) -> str:
        """
        사용자 입력에 대한 챗봇의 응답을 생성합니다.
        
        :param user_input: 사용자의 입력 텍스트
        :return: 챗봇의 응답 텍스트
        """
        try:
            response = self.chain.invoke({"user_input": user_input})
            return response['text']
        except Exception as e:
            return f"죄송합니다, 오류가 발생했습니다: {str(e)}"

# 모듈이 임포트될 때 챗봇 인스턴스를 생성하고 chatbot_response 함수를 정의합니다.
load_dotenv()
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

# 챗봇 인스턴스 생성
chatbot_instance = TaxiMatchingChatBot(api_key=OPENAI_API_KEY, verbose=True)

def chatbot_response(user_input: str) -> str:
    """
    전역 챗봇 인스턴스를 사용하여 사용자 입력에 대한 응답을 생성합니다.
    
    :param user_input: 사용자의 입력 텍스트
    :return: 챗봇의 응답 텍스트
    """
    return chatbot_instance.get_response(user_input)
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
