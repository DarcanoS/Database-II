"""
Logging configuration for the application.
Sets up Python logging with proper formatting and levels.
"""

import logging
import sys
from app.core.config import settings


def setup_logging():
    """
    Configure application logging.

    Sets up:
    - Log level from settings
    - Log format from settings
    - Console handler for stdout
    """

    # Get log level from settings
    log_level = getattr(logging, settings.LOG_LEVEL.upper(), logging.INFO)

    # Configure root logger
    # Support a special value 'colorlog' in settings to enable colored output
    if isinstance(settings.LOG_FORMAT, str) and settings.LOG_FORMAT.lower() == "colorlog":
        try:
            import colorlog

            handler = colorlog.StreamHandler()
            formatter = colorlog.ColoredFormatter(
                "%(log_color)s%(asctime)s - %(name)s - %(levelname)s - %(message)s"
            )
            handler.setFormatter(formatter)
            logging.root.handlers = [handler]
            logging.root.setLevel(log_level)
        except Exception:
            # If colorlog is not available, fallback to a sensible format
            fallback = "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
            logging.basicConfig(level=log_level, format=fallback, handlers=[logging.StreamHandler(sys.stdout)])
    else:
        logging.basicConfig(
            level=log_level,
            format=settings.LOG_FORMAT,
            handlers=[
                logging.StreamHandler(sys.stdout)
            ]
        )

    # Set SQLAlchemy logging to WARNING to reduce noise
    logging.getLogger("sqlalchemy.engine").setLevel(logging.WARNING)

    # Create application logger
    logger = logging.getLogger("air_quality_api")
    logger.setLevel(log_level)

    return logger


# Initialize logger
logger = setup_logging()

