from fastapi import FastAPI

app = FastAPI()

@app.get('/')
async def read_results():
    results = {"v":"4."}
    return results


#with same problem


