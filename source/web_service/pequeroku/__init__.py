# Make the Celery app available at package level so that
# ``@shared_task`` and ``celery -A pequeroku`` both find it.
from .celery import app as celery_app

__all__ = ("celery_app",)
