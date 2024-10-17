from fastapi import FastAPI

app = FastAPI()

@app.get('/')
async def read_results():
    results = {"FOO":"BAR"}
    return results


