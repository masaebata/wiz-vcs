# unsafe_app.py
import sqlite3
import os

# ハードコードされた資格情報（NG）
DB_PASSWORD = "SuperSecretPassword123!"   # ← テスト用に固定

def connect_db():
    # ここでは平文のパスワード使用（実運用ではNG）
    conn = sqlite3.connect("example.db")
    return conn

def login(username, password):
    conn = connect_db()
    cur = conn.cursor()
    # 単純な文字列結合によるSQL（SQLiに弱い）
    query = "SELECT * FROM users WHERE username = '%s' AND password = '%s'" % (username, password)
    cur.execute(query)
    result = cur.fetchone()
    return result

def run_user_code(user_input):
    # 危険: ユーザー入力をevalで直接実行（RCEの危険）
    return eval(user_input)

if __name__ == "__main__":
    # テスト用途の呼び出し（実行は隔離環境で）
    print(login("alice", "pw"))
