import asyncio
import aiohttp
import time
import os

# Replace with your ALB DNS or local endpoin
ALB_DNS_NAME = os.getenv("ALB_DNS_NAME")
print(f"ALB_DNS_NAME: {ALB_DNS_NAME}", flush=True)
URL = f"http://{ALB_DNS_NAME}/api/movies/"

PAYLOAD = {
    "title": "Inception",
    "description": "A thief who steals corporate secrets through the use of dream-sharing technology."
}

CONCURRENT_REQUESTS = 40  # Keep 40 connections constantly firing
DURATION = 120            # Run for 2 minutes

async def send_request(session):
    try:
        async with session.post(URL, json=PAYLOAD) as response:
            await response.text()
            return response.status
    except Exception as e:
        return None

async def worker(session, end_time):
    while time.time() < end_time:
        await send_request(session)

async def main():
    print(f"🚀 Starting CPU Load Test against {URL}")
    end_time = time.time() + DURATION
    
    async with aiohttp.ClientSession() as session:
        tasks = [worker(session, end_time) for _ in range(CONCURRENT_REQUESTS)]
        await asyncio.gather(*tasks)

if __name__ == "__main__":
    asyncio.run(main())