from fastapi import FastAPI

app = FastAPI()

@app.get('/')
async def read_results():
    results = {"v":"2"}
    return results


