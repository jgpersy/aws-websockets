import logging


def log_config(filename: str, log_level="INFO"):
    log_level = str.upper(log_level)
    log_levels = ['DEBUG', 'INFO', 'WARN', 'ERROR']

    if log_level not in log_levels:
        raise (ValueError(f"Invalid log level: {log_level}"))

    logger = logging.getLogger(filename)
    logger.setLevel(log_level)
    return logger
