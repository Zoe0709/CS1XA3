# Generated by Django 2.2 on 2019-04-28 03:01

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('myklotskiapp', '0001_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='userinfo',
            name='highscore',
            field=models.IntegerField(default=999),
        ),
    ]
