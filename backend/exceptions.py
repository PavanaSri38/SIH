from fastapi import Request
from fastapi.responses import JSONResponse

async def not_found_handler(request: Request, exc):
    return JSONResponse(status_code=404, content={"detail": "Resource not found"})

async def validation_error_handler(request: Request, exc):
    return JSONResponse(status_code=422, content={"detail": str(exc)})
