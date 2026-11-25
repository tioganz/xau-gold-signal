from flask import Flask, request, jsonify, send_from_directory
from datetime import datetime, timezone
import os
app=Flask(__name__, static_folder='web')
state={"signal":"WAIT","reason":"Belum menerima data dari EA MT5","updated_at":None}
@app.get("/")
def home(): return send_from_directory("web","index.html")
@app.get("/manifest.json")
def manifest(): return send_from_directory("web","manifest.json")
@app.get("/sw.js")
def sw(): return send_from_directory("web","sw.js")
@app.get("/api/state")
def get_state(): return jsonify(state)
@app.post("/api/mt5")
def mt5():
    global state
    data=request.get_json(silent=True)
    if not isinstance(data,dict): return jsonify(error="JSON invalid"),400
    # EA mengirim sinyal terhitung dari candle M5 yang sudah tutup.
    allowed={"signal","reason","price","entry","sl","tp","rsi","ema9","ema21","bar_time","lot"}
    state={k:v for k,v in data.items() if k in allowed}
    state["updated_at"]=datetime.now().astimezone().strftime("%Y-%m-%d %H:%M:%S %Z")
    return jsonify(ok=True)
if __name__=="__main__":
    # Untuk penggunaan nyata, jalankan di VPS dengan HTTPS/reverse proxy.
    app.run(host="0.0.0.0",port=int(os.environ.get("PORT",8080)))
