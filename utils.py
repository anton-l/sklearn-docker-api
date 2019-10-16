import logging
import os


LOG_LEVELS = {
    "critical": logging.CRITICAL,
    "error": logging.ERROR,
    "warning": logging.WARNING,
    "info": logging.INFO,
    "debug": logging.DEBUG,
}


def get_logger(name: str, log_level: str):
    """
    Usage:
        logger = get_module_logger(__name__)
    """
    if isinstance(log_level, str):
        log_level = LOG_LEVELS[log_level]
    logger = logging.getLogger(name)
    handler = logging.StreamHandler()
    formatter = logging.Formatter(
        '%(asctime)s [%(name)-12s] %(levelname)-8s %(message)s')
    handler.setFormatter(formatter)
    logger.addHandler(handler)
    logger.setLevel(log_level)
    return logger


