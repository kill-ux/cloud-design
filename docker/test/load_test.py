import asyncio
import time
import aiohttp
import os

# Grab environment variable
ALB_DNS_NAME = os.getenv("ALB_DNS_NAME")

# IMPORTANT: Python uses f"{ALB_DNS_NAME}", NOT f"${ALB_DNS_NAME}"
if not ALB_DNS_NAME:
    print(" ERROR: ALB_DNS_NAME environment variable is not set!")
    exit(1)

TARGET_URL = f"http://{ALB_DNS_NAME}/api/movies/"

CONCURRENT_REQUESTS = 50 
DURATION_SECONDS = 300 

stats = {"success": 0, "failed": 0}
last_error = None

async def fetch(session):
    global last_error
    try:
        # Posting data to test CPU load on inventory service
        payload = {"title": "Test Movie", "description": "Stress testing CPU"}
        async with session.post(TARGET_URL, json=payload, timeout=5) as response:
            if response.status in (200, 201):
                stats["success"] += 1
            else:
                stats["failed"] += 1
                last_error = f"HTTP {response.status}"
    except Exception as e:
        stats["failed"] += 1
        last_error = str(e)

async def worker(session, end_time):
    while time.time() < end_time:
        await fetch(session)
        await asyncio.sleep(0.01)

async def logger(end_time):
    while time.time() < end_time:
        # Print progress every 3 seconds instead of 10
        await asyncio.sleep(3)
        elapsed = int(DURATION_SECONDS - (end_time - time.time()))
        err_msg = f" (Last Error: {last_error})" if last_error else ""
        print(f"[{elapsed}s] Success: {stats['success']} | Failed: {stats['failed']}{err_msg}")

async def main():
    print(f"🚀 Starting CPU Load Test against {TARGET_URL}")
    print(f"⏱️ Running for {DURATION_SECONDS} seconds with {CONCURRENT_REQUESTS} connections...\n")
    
    end_time = time.time() + DURATION_SECONDS
    
    async with aiohttp.ClientSession() as session:
        worker_tasks = [asyncio.create_task(worker(session, end_time)) for _ in range(CONCURRENT_REQUESTS)]
        
        await logger(end_time)
        await asyncio.gather(*worker_tasks)

    print("\nLoad test finished!")
    print(f"Total Successful Requests: {stats['success']}")
    print(f"Total Failed Requests:     {stats['failed']}")

if __name__ == "__main__":
    asyncio.run(main())