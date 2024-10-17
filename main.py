from fastapi import FastAPI

app = FastAPI()

@app.get('/')
async def read_results():
    
    return {"hello": "world"}
