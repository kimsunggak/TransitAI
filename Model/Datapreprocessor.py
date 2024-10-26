import pandas as pd

class DataPreprocessor:
    def __init__(self, reference_date="2022-03-02"):
        # 기준 날짜 초기화
        self.reference_date = reference_date
        # Weather의 모든 카테고리 정의
        self.expected_weather_categories = [1, 2, 3, 4]
        # 모델이 기대하는 전체 컬럼 리스트 정의
        self.expected_columns = ['Day', 'Time', 'Event', 'Train_Arrival', 'Days_Since',
                                 'Weather_1', 'Weather_2', 'Weather_3', 'Weather_4']

    def convert_time_to_minutes(self, df):
        # 'Time' 열을 분 단위로 변환하는 함수
        df['Time'] = df['Time'].apply(lambda time_str: int(time_str.split(':')[0]) * 60 + int(time_str.split(':')[1]))
        return df

    def convert_date_to_days(self, df):
        # 'Date' 열을 일수 차이로 변환
        df['Date'] = pd.to_datetime(df['Date'], errors='coerce')
        df['Days_Since'] = (df['Date'] - pd.Timestamp(self.reference_date)) // pd.Timedelta('1D')
        return df

    def one_hot_encode(self, df):
        # Weather 열 원-핫 인코딩
        df = pd.get_dummies(df, columns=["Weather"])
        # 모든 Weather 컬럼을 포함하도록 보장
        expected_weather_columns = [f'Weather_{category}' for category in self.expected_weather_categories]
        for col in expected_weather_columns:
            if col not in df.columns:
                df[col] = 0  # 해당 컬럼이 없으면 0으로 추가
        return df

    def preprocess(self, df):
        df = self.convert_time_to_minutes(df)
        df = self.convert_date_to_days(df)
        df = self.one_hot_encode(df)
        
        # 불필요한 열 제거
        if 'Date' in df.columns:
            df = df.drop(columns=['Date'])
        
        # 모델이 기대하는 컬럼 순서로 재정렬
        df = df.reindex(columns=self.expected_columns, fill_value=0)
        
        # 모든 열을 정수형 또는 부동소수점형으로 변환 (필요에 따라)
        df[self.expected_columns] = df[self.expected_columns].astype(int)

        return df
