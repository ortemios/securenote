from django.db import models

class Note(models.Model):
    id = models.AutoField(primary_key=True)
    title = models.CharField(max_length=100)
    content = models.TextField()

    class Meta:
        app_label = 'backend'

