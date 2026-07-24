import asyncio
import time
import aiohttp
import os

ALB_DNS_NAME = os.getenv("ALB_DNS_NAME")
TARGET_URL = f"http://{ALB_DNS_NAME}/health"

CONCURRENT_REQUESTS = 50 
DURATION_SECONDS = 300 

stats = {"success": 0, "failed": 0}

async def fetch(session):
    try:
        async with session.get(TARGET_URL, timeout=5) as response:
            if response.status == 200:
                stats["success"] += 1
            else:
                stats["failed"] += 1
    except Exception:
        stats["failed"] += 1

async def worker(session, end_time):
    while time.time() < end_time:
        await fetch(session)
        await asyncio.sleep(0.01)

async def logger(end_time):
    while time.time() < end_time:
        await asyncio.sleep(10)
        elapsed = int(DURATION_SECONDS - (end_time - time.time()))
        print(f"[{elapsed}s] Sent requests -> Success: {stats['success']}, Failed: {stats['failed']}")

async def main():
    print(f"🚀 Starting load test against {TARGET_URL}")
    print(f"⏱️ Running for {DURATION_SECONDS} seconds with {CONCURRENT_REQUESTS} concurrent connections...")
    
    end_time = time.time() + DURATION_SECONDS
    
    async with aiohttp.ClientSession() as session:
        # 1. Create worker tasks (they start running immediately in the background)
        worker_tasks = [asyncio.create_task(worker(session, end_time)) for _ in range(CONCURRENT_REQUESTS)]
        
        # 2. Run the logger in parallel
        await logger(end_time)
        
        # 3. Ensure all worker tasks complete
        await asyncio.gather(*worker_tasks)

    print("\nLoad test finished!")
    print(f"Total Successful Requests: {stats['success']}")
    print(f"Total Failed Requests:     {stats['failed']}")

if __name__ == "__main__":
    asyncio.run(main())