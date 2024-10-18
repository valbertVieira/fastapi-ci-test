from fastapi import FastAPI

app = FastAPI()

@app.get('/')
async def read_results():
    results = {"v":"85"}
    return results


#with same problem


