"""
SHAHEEN-YS — Celery application entry point
============================================
This module creates the shared Celery app instance for the `pequeroku`
Django project.  It is imported by pequeroku/__init__.py so that
``@shared_task`` decorators in any Django app can discover the broker.

Worker command (from docker-compose.yml):
    celery -A pequeroku worker --loglevel=info

Beat command:
    celery -A pequeroku beat --loglevel=info \
           --scheduler django_celery_beat.schedulers:DatabaseScheduler
"""

import os

from celery import Celery

# Tell Celery which Django settings module to use.
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "pequeroku.settings")

#: The shared Celery application.  All tasks discovered via autodiscover
#: will be registered here.
app = Celery("pequeroku")

# Pull CELERY_* settings from Django settings (namespace avoids clashes).
app.config_from_object("django.conf:settings", namespace="CELERY")

# Automatically discover tasks.py modules in every INSTALLED_APP.
app.autodiscover_tasks()


@app.task(bind=True, ignore_result=True)
def debug_task(self):
    """Utility task: prints the request info.  Useful for smoke-testing the worker."""
    print(f"Request: {self.request!r}")
