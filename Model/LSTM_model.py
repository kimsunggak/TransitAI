#필요 라이브러리 호출
import pandas as pd
import numpy as np
import torch
import torch.nn as nn
from sklearn.preprocessing import MinMaxScaler
from torch.utils.data import DataLoader,TensorDataset
from sklearn.model_selection import train_test_split
from torch.utils.data import TensorDataset, DataLoader

#데이터 불러오기
df = pd.read_csv("ki.csv")
#데이터 전처리

# 시간을 분단위로 변환하는 함수 정의
def convert_time_to_minutes(time):
    hour, minute = map(int, time.split(':'))
    return hour * 60 + minute

# 각 행의 Time 값에 대해 분단위로 변환
df['Time'] = df['Time'].apply(convert_time_to_minutes)
# 뺄셈 연산을 위해 datetime 형식 변환
df['Date'] = pd.to_datetime(df['Date'], errors='coerce')
# 날짜를 일수로 변환 - 22년 3월 2일로부터 일수 차이값으로 반환
df['Days_Since'] = (df['Date'] - pd.Timestamp("2022-03-02")) // pd.Timedelta('1D')

# 요일을 사인과 코사인으로 변환 - 주기적인 특징 반
df['Day_Sin'] = np.sin(2 * np.pi * df['Day'] / 5)
df['Day_Cos'] = np.cos(2 * np.pi * df['Day'] / 5)

# 시간(분 단위)을 사인과 코사인으로 변환
df['Time_Sin'] = np.sin(2 * np.pi * df['Time'] / 1440)
df['Time_Cos'] = np.cos(2 * np.pi * df['Time'] / 1440)

#불필요한 열 제거
df = df.drop(columns=['Date','Time'])
#원-핫 인코딩
data = pd.get_dummies(df,columns=["Weather"])
# bool 값들을 0과 1로 변환
data[['Weather_1', 'Weather_2', 'Weather_3', 'Weather_4']] = data[['Weather_1', 'Weather_2', 'Weather_3', 'Weather_4']].astype(int)


feature_cols = data.columns.tolist()
feature_cols.remove("Waiting_Passengers")
#입력 특징과 예측 대상
x = data[feature_cols].values
y = data["Waiting_Passengers"].values
#대기 인원 수 스케일링
y = y.reshape(-1,1) #최대 최소 스케일링을 위해 2차원 배열로 변환
scaler_y = MinMaxScaler()
y_scaled = scaler_y.fit_transform(y) # 0과 1사이로 스케일링(정규화)

# 시퀀스 생성 함수
def create_sequences(features, target, window_size):
    Xs, ys = [], []
    for i in range(len(features) - window_size):
        Xs.append(features[i:i+window_size])
        ys.append(target[i+window_size])
    return np.array(Xs), np.array(ys)

window_size = 10
# 시퀀스 데이터 생성
X_sequences, y_sequences = create_sequences(x, y_scaled, window_size)
print(f'시퀀스 입력 데이터 형태: {X_sequences.shape}')
print(f'시퀀스 타겟 데이터 형태: {y_sequences.shape}')
print(y_sequences[0])
#데이터 로더 및 LSTM 모델 구조 생성
#학습용 테스트용 데이터 분할
train_size = int(len(X_sequences) * 0.8)
X_train, X_test = X_sequences[:train_size], X_sequences[train_size:]
y_train, y_test = y_sequences[:train_size], y_sequences[train_size:]

#텐서 형태로 변환
x_train_tensor = torch.tensor(X_train, dtype=torch.float32)
y_train_tensor = torch.tensor(y_train, dtype=torch.float32)

x_test_tensor = torch.tensor(X_test, dtype=torch.float32)
y_test_tensor = torch.tensor(y_test, dtype=torch.float32)

#데이터로더
train_dataset = TensorDataset(x_train_tensor, y_train_tensor)
test_dataset = TensorDataset(x_test_tensor, y_test_tensor)

batch_size = 64  # 배치 크기 조정
train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True)
test_loader = DataLoader(test_dataset, batch_size=batch_size, shuffle=False)
#LSTM모델 정의
class LSTMModel(nn.Module):
  # layer 초기화
    def __init__(self,input_size,hidden_size,num_layers,output_size):
        super(LSTMModel, self).__init__()
        self.hidden_size = hidden_size
        self.num_layers = num_layers
        #레이어 정의
        self.lstm = nn.LSTM(input_size, hidden_size, num_layers,batch_first = True)
        #출력 레이어
        self.fc = nn.Linear(hidden_size, output_size)
        self.activation = nn.Sigmoid()
    def forward(self,x):
      h0 = torch.zeros(self.num_layers, x.size(0), self.hidden_size).to(device)
      c0 = torch.zeros(self.num_layers, x.size(0), self.hidden_size).to(device)
      out, _ = self.lstm(x, (h0, c0))
      #마지막 시점의 출력만
      out = out[:, -1, :]
      out = self.fc(out)
      out = self.activation(out)
      return out

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
#모델 초기화
input_size = x_train_tensor.shape[2]
hidden_size = 128
num_layers = 3
output_size = 1

model = LSTMModel(input_size, hidden_size, num_layers, output_size).to(device)
#손실함수, 최적화
criterion = nn.MSELoss() #평가지표 MSE사용
optimizer = torch.optim.Adam(model.parameters(), lr=0.001) #Adam사용
#모델 학습
num_epochs = 10
for epochs in range(num_epochs):
  model.train()
  train_losses = []
  for x_batch,y_batch in train_loader:
    x_batch = x_batch.to(device)
    y_batch = y_batch.to(device)

    optimizer.zero_grad()
    #모델 예측
    outputs = model(x_batch)

    loss = criterion(outputs,y_batch)
    loss.backward()

    optimizer.step()
    train_losses.append(loss.item())
  avg_train_loss = np.mean(train_losses)

  model.eval()

  test_losses = []
  with torch.no_grad():
    for x_batch,y_batch in test_loader:
      x_batch = x_batch.to(device)
      y_batch = y_batch.to(device)

      outputs = model(x_batch)
      loss = criterion(outputs,y_batch)
      test_losses.append(loss.item())

  avg_test_loss = np.mean(test_losses)
  print(f'Epoch [{epochs+1}/{num_epochs}], Train Loss: {avg_train_loss:.4f}, Test Loss: {avg_test_loss:.4f}')
  from sklearn.preprocessing import MinMaxScaler
from sklearn.metrics import mean_squared_error

model.eval()
predictions = []
actuals = []

with torch.no_grad():
    for X_batch, y_batch in test_loader:
        X_batch = X_batch.to(device)
        y_batch = y_batch.to(device)

        outputs = model(X_batch)

        predictions.extend(outputs.cpu().numpy())
        actuals.extend(y_batch.cpu().numpy())
# 예측 값과 실제 값 리스트를 배열로 변환
predictions = np.array(predictions)
actuals = np.array(actuals)

# 배열의 차원 축소
predictions = predictions.reshape(-1, 1)
actuals = actuals.reshape(-1, 1)
# 역정규화
predictions = scaler_y.inverse_transform(predictions)
actuals = scaler_y.inverse_transform(actuals)
#모델 성능 평가
rmse = np.sqrt(mean_squared_error(actuals, predictions))
print(f'Test RMSE: {rmse:.4f}')
#결과 시각화 비교
import matplotlib.pyplot as plt

plt.figure(figsize=(12,6))
plt.plot(actuals, label='Actual Waiting Passengers')
plt.plot(predictions, label='Predicted Waiting Passengers')
plt.legend()
plt.show()
