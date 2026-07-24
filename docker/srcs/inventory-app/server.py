from dotenv import load_dotenv
import logging
from waitress import serve
from paste.translogger import TransLogger

load_dotenv()

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)

from app import create_app, get_env_variable

INVENTORY_APP_PORT = get_env_variable("INVENTORY_APP_PORT")

app = create_app()

if __name__ == "__main__":
    logged_app = TransLogger(app, setup_console_handler=True)

    logging.info(f"Starting Waitress server on 0.0.0.0:{INVENTORY_APP_PORT}...")

    serve(
        logged_app,
        host='0.0.0.0',
        port=int(INVENTORY_APP_PORT),
        threads=8
    )