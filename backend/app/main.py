import asyncio
import logging

from fastapi import FastAPI, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from app.config import settings
from app.routers import missioncontrol

logger = logging.getLogger(__name__)

app = FastAPI(
    title="Mission Control Backend",
    version="2.0.0",
    description="Monitoring Backend für Mission Control App (Home Lab)",
)

HEALTH_PATHS = {"/api/health", "/docs", "/openapi.json", "/redoc"}


@app.middleware("http")
async def api_key_middleware(request: Request, call_next):
    path = request.url.path
    if path in HEALTH_PATHS or path.startswith("/static"):
        return await call_next(request)
    if settings.api_key and request.headers.get("X-API-Key") != settings.api_key:
        return Response(status_code=401, content="Unauthorized")
    return await call_next(request)


app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.mount("/static", StaticFiles(directory="static"), name="static")

app.include_router(missioncontrol.router, prefix="/api")


@app.on_event("startup")
async def startup():
    asyncio.create_task(_periodic_service_history())


async def _periodic_service_history():
    """Collect service response times every 5 minutes for the history chart."""
    while True:
        try:
            missioncontrol._collect_service_history()
        except Exception as e:
            logger.warning("Service history collection failed: %s", e)
        await asyncio.sleep(300)


@app.get("/api/health")
async def health():
    return {"status": "ok", "service": "mission-control-backend"}
