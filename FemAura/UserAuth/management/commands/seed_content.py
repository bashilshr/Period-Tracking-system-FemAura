from django.core.management.base import BaseCommand
from UserAuth.models import ContentRecommendation

class Command(BaseCommand):
    help = 'Seeds the database with initial content recommendations'

    def handle(self, *args, **kwargs):
        recommendations = [
    # Menstrual Phase - Detailed symptoms
    {
        'phase': 'menstrual',
        'symptom': 'cramps',
        'title': 'Yoga Flow for Menstrual Cramps Relief',
        'youtube_link': 'https://www.youtube.com/watch?v=2X78NWuRfJU',
        'description': '15-minute gentle yoga sequence specifically designed to alleviate menstrual cramps'
    },
    {
        'phase': 'menstrual',
        'symptom': 'fatigue',
        'title': 'Iron-Rich Foods for Energy',
        'youtube_link': 'https://www.youtube.com/watch?v=4rSJYxUWj5M&t=47s',
        'description': 'Nutritionist explains best foods to combat menstrual fatigue'
    },
    
    # Follicular Phase - Energy building
    {
        'phase': 'follicular',
        'title': 'High-Energy Workout Routine',
        'youtube_link': 'https://www.youtube.com/watch?v=CldEimYgd_g',
        'description': 'Take advantage of rising energy levels with this workout'
    },
    
    # Ovulation Phase - Fertility & Confidence
    {
        'phase': 'ovulation',
        'title': 'Understanding Fertility Signals',
        'youtube_link': 'https://youtu.be/example4',
        'description': 'How to recognize your most fertile days'
    },
    
    # Luteal Phase - PMS Management
    {
        'phase': 'luteal',
        'symptom': 'mood swings',
        'title': 'Managing PMS Mood Swings Naturally',
        'youtube_link': 'https://youtu.be/example5',
        'description': 'Psychologist shares coping strategies for emotional changes'
    },
    {
        'phase': 'luteal',
        'symptom': 'bloating',
        'title': 'Reducing Period Bloating',
        'youtube_link': 'https://youtu.be/example6',
        'description': 'Diet and exercise tips to minimize bloating'
    },
    
    # Irregular Cycle Support
    {
        'phase': 'menstrual',
        'title': 'Understanding Irregular Cycles',
        'youtube_link': 'https://youtu.be/example7',
        'description': 'Gynecologist explains causes and when to seek help',
        'symptom': None
    }
]
        for item in recommendations:
            ContentRecommendation.objects.get_or_create(**item)

        self.stdout.write(self.style.SUCCESS('Successfully seeded content recommendations'))