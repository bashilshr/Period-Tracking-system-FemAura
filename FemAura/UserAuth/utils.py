from datetime import date, timedelta
from .models import Symptom, Mood, ContentRecommendation, Cycle,DailyLog, DailySymptom, DailyMood
from django.utils import timezone
from django.db.models import Count, Case, When, IntegerField, Q, F
import logging
from django.db import IntegrityError

logger = logging.getLogger(__name__)

def get_average_cycle_length(user):
    """
    Calculate the average length of the cycle for a user.
    """
    cycles = Cycle.objects.filter(user=user)
    if not cycles.exists():
        return 0

    # Filter out cycles with None cycle_length
    valid_cycles = [cycle for cycle in cycles if cycle.cycle_length is not None]
    if not valid_cycles:
        return 0

    total_length = sum(cycle.cycle_length for cycle in valid_cycles)
    return total_length // len(valid_cycles)

def get_current_day(user):
    """
    Calculate the current day of the cycle.
    """
    try:
        latest_cycle = Cycle.objects.filter(user=user).latest('start_date')
    except Cycle.DoesNotExist:
        return 0  # No cycles found

    # Ensure start_date is a date object
    if isinstance(latest_cycle.start_date, str):
        from datetime import datetime
        latest_start_date = datetime.strptime(latest_cycle.start_date, '%Y-%m-%d').date()
    else:
        latest_start_date = latest_cycle.start_date

    return (date.today() - latest_start_date).days + 1

def get_ovulation_status(user):
    """
    Improved ovulation prediction for irregular cycles
    """
    cycles = Cycle.objects.filter(user=user).order_by('-start_date')
    if not cycles.exists():
        return "No data available"
    
    # Get the 3 most recent cycles for pattern detection
    recent_cycles = list(cycles[:3])
    
    # If only one cycle exists
    if len(recent_cycles) == 1:
        return "Not enough data for prediction (need at least 2 cycles)"
    
    # Calculate variability
    lengths = [c.cycle_length for c in recent_cycles if c.cycle_length]
    avg_length = sum(lengths) / len(lengths)
    variability = max(lengths) - min(lengths)
    
    # Highly irregular classification
    if variability > 15 or any(l > 45 for l in lengths):
        return "Highly irregular cycle detected - predictions may be inaccurate"
    
def get_cycle_day(user, date=None):
    """Calculate day of current cycle"""
    date = date or timezone.now().date()
    cycle = get_current_cycle(user, date)
    
    if not cycle:
        return None
        
    return (date - cycle.start_date).days + 1

def get_phase(user,date = None):
    """
    Determine the current menstrual phase with adaptive logic for irregular cycles.
    Returns phase information including title, symptoms, and recommendations.
    """
    date = date or timezone.now().date()
    cycle = get_current_cycle(user, date)
    cycles = Cycle.objects.filter(user=user).order_by('-start_date')

    if not cycles.exists():
        return {
            'title': 'No data',
            'symptoms': [],
            'recommendations': [],
            'is_irregular': False,
            'confidence': 'none'
        }

    current_day = get_current_day(user)
    avg_cycle_length = get_average_cycle_length(user)
    
    daily_log = DailyLog.objects.filter(user=user, date=date).first()
    if daily_log:
        todays_symptoms = list(daily_log.symptoms.values_list('symptom', flat=True))
        todays_moods = list(daily_log.moods.values_list('mood', flat=True))
    else:
        todays_symptoms = []
        todays_moods = []

    # Default values
    phase_title = "Unknown Phase"
    symptoms = []
    recommendations = []
    is_irregular = avg_cycle_length > 35 or len(cycles) < 3

    
    # For irregular cycles, use relative percentages
    if is_irregular:
        menstrual_end = int(avg_cycle_length * 0.15)  # First 15% of cycle
        follicular_end = int(avg_cycle_length * 0.4)   # Next 25%
        ovulation_end = int(avg_cycle_length * 0.6)    # Next 20%
        
        if current_day <= menstrual_end:
            phase_title = 'Menstrual Phase (Irregular)'
            symptoms = [
                'Cramps (possibly more intense)',
                'Fatigue',
                'Irregular bleeding patterns',
                'Mood swings'
            ]
            recommendations = [
                'Track bleeding patterns carefully',
                'Consider medical consultation for irregular cycles',
                'Use heating pads for cramp relief',
                'Maintain iron-rich diet'
            ]
            
        elif current_day <= follicular_end:
            phase_title = 'Follicular Phase (Irregular)'
            symptoms = [
                'Variable energy levels',
                'Unpredictable cervical mucus changes',
                'Inconsistent basal body temperature'
            ]
            recommendations = [
                'Monitor multiple fertility signs',
                'Be prepared for early ovulation',
                'Maintain consistent sleep patterns'
            ]
            
        elif current_day <= ovulation_end:
            phase_title = 'Ovulation Phase (Irregular)'
            symptoms = [
                'Possible multiple ovulation attempts',
                'Unpredictable ovulation pain',
                'Variable libido changes'
            ]
            recommendations = [
                'Track ovulation with multiple methods',
                'Have ovulation tests available',
                'Be aware of possible anovulatory cycles'
            ]
            
        else:  # Luteal phase
            phase_title = 'Luteal Phase (Irregular)'
            symptoms = [
                'Variable PMS symptoms',
                'Unpredictable mood changes',
                'Inconsistent cycle length'
            ]
            recommendations = [
                'Track symptom patterns carefully',
                'Practice stress management techniques',
                'Be prepared for early or late period'
            ]
            
    else:  # Regular cycles
        if current_day <= 7:
            phase_title = 'Menstrual Phase'
            symptoms = [
                'Menstrual bleeding',
                'Cramps',
                'Fatigue',
                'Lower back pain'
            ]
            recommendations = [
                'Use period tracking',
                'Stay hydrated',
                'Consider pain relief if needed'
            ]
            
        elif current_day <= 14:
            phase_title = 'Follicular Phase'
            symptoms = [
                'Increasing energy',
                'Dry cervical mucus becoming creamy',
                'Rising estrogen levels'
            ]
            recommendations = [
                'Good time for exercise',
                'Focus on nutrition',
                'Track cervical mucus changes'
            ]
            
        elif current_day <= 21:
            phase_title = 'Ovulation Phase'
            symptoms = [
                'Egg-white cervical mucus',
                'Increased libido',
                'Mild ovulation pain (mittelschmerz)'
            ]
            recommendations = [
                'Fertility awareness if trying to conceive',
                'Stay hydrated',
                'Monitor basal body temperature'
            ]
            
        else:
            phase_title = 'Luteal Phase'
            symptoms = [
                'PMS symptoms',
                'Breast tenderness',
                'Bloating',
                'Mood changes'
            ]
            recommendations = [
                'Reduce salt intake',
                'Practice relaxation techniques',
                'Track PMS symptoms'
            ]
    all_symptoms = list(set(todays_symptoms + symptoms))
    return {
        'title': phase_title,
        'symptoms': all_symptoms,
        "Moods": todays_moods,
        'recommendations': recommendations,
        'is_irregular': is_irregular,
        'confidence': 'high' if not is_irregular else 'medium'
    }

def get_period_history(user):
    """
    Returns comprehensive period history with analysis and personalized recommendations.
    Excludes single-day cycles from calculations.
    
    Args:
        user: User model instance
    
    Returns:
        dict: Contains cycle history, analysis, and recommendations
        None: If no cycles exist
    """
    try:
        if not hasattr(user, 'id'):
            raise ValueError("Expected User object but got something else")
            
        # Get multi-day cycles only
        cycles = Cycle.objects.filter(
            user_id=user.id,
            start_date__lt=F('end_date')
        ).order_by('start_date')

        if not cycles.exists():
            return None

        # Calculate cycle statistics
        lengths = [c.cycle_length for c in cycles if c.cycle_length is not None]
        
        if not lengths:
            avg_length = 0
            variability = 0
        else:
            avg_length = round(sum(lengths) / len(lengths), 1)
            variability = max(lengths) - min(lengths) if len(lengths) > 1 else 0
        
        is_irregular = avg_length > 35 or variability > 7
        
        # Get health insights
        common_symptoms = (
            DailySymptom.objects.filter(daily_log__user=user)
            .values('symptom')
            .annotate(count=Count('id'))
            .order_by('-count')[:5]  # Increased to top 5 symptoms
        )
        
        common_moods = (
            DailyMood.objects.filter(daily_log__user=user)
            .values('mood')
            .annotate(count=Count('id'))
            .order_by('-count')[:3]
        )

        # ===== Enhanced Recommendations Engine =====
        recommendations = []
        
        # 1. Cycle Pattern Recommendations
        if avg_length < 24:
            recommendations.append("Short cycles detected - consider iron-rich foods to compensate for frequent blood loss")
        elif avg_length > 35:
            recommendations.append("Long cycles detected - track basal body temperature to confirm ovulation")
        
        if variability > 7:
            rec = f"Your cycle varies by {variability} days. "
            rec += "Consult a healthcare provider" if variability > 14 else "Stress management may help regulate cycles"
            recommendations.append(rec)

        # 2. Symptom-Based Recommendations
        symptom_advice = {
            'cramps': ["Try magnesium supplements", "Use heating pads for relief"],
            'bloating': ["Reduce salt intake before period", "Increase water consumption"],
            'headache': ["Monitor caffeine intake", "Ensure proper hydration"],
            'fatigue': ["Increase iron-rich foods", "Consider vitamin B complex"]
        }
        
        for symptom in common_symptoms:
            symptom_name = symptom['symptom'].lower()
            if symptom_name in symptom_advice:
                recommendations.extend(symptom_advice[symptom_name])

        # 3. Mood-Based Recommendations
        mood_advice = {
            'irritable': ["Practice mindfulness meditation", "Reduce caffeine intake"],
            'anxious': ["Try breathing exercises", "Consider magnesium supplements"],
            'depressed': ["Increase omega-3 intake", "Ensure adequate sunlight exposure"]
        }
        
        for mood in common_moods:
            mood_name = mood['mood'].lower()
            if mood_name in mood_advice:
                recommendations.extend(mood_advice[mood_name])

        # 4. General Health Recommendations
        general_advice = [
            "Track symptoms daily for better pattern recognition",
            "Aim for 7-9 hours of sleep for hormonal balance",
            "Consider cycle syncing your exercise routine"
        ]
        
        if is_irregular:
            general_advice.append("Maintain a consistent sleep schedule to help regulate cycles")

        recommendations.extend(general_advice)

        # Prepare history data
        history_data = []
        for cycle in cycles:
            try:
                cycle_length = (cycle.end_date - cycle.start_date).days + 1
                symptoms = DailySymptom.objects.filter(
                    daily_log__cycle=cycle
                ).values_list('symptom', flat=True).distinct()
                
                history_data.append({
                    'start_date': cycle.start_date,
                    'end_date': cycle.end_date,
                    'days': cycle_length,
                    'symptoms': list(symptoms),
                    'is_irregular': cycle_length > 35
                })
            except Exception as e:
                logger.error(f"Error processing cycle {cycle.id}: {str(e)}")
                continue

        return {
            'avg_cycle_length': avg_length,
            'cycle_variability': variability,
            'is_irregular': is_irregular,
            'total_cycles': cycles.count(),
            'common_symptoms': [s['symptom'] for s in common_symptoms],
            'common_moods': [m['mood'] for m in common_moods],
            'period_history': history_data,
            'recommendations': general_advice[:2], 
            
        }

    except Exception as e:
        logger.error(f"Error in get_period_history: {str(e)}")
        raise

def get_irregularity_level(variability, avg_length):
    """Classify cycle irregularity"""
    if avg_length == 0:
        return 'unknown'
    if variability > 15 or avg_length > 35:
        return 'high'
    if variability > 7:
        return 'moderate'
    return 'low'

def get_health_recommendations(cycles, avg_length, variability):
    """Generate personalized health recommendations"""
    recommendations = []
    
    if not cycles:
        return ["Track more cycles for personalized recommendations"]
    
    if avg_length > 35:
        recommendations.append("Your average cycle is longer than typical")
        recommendations.append("Consider discussing with a healthcare provider")
    
    if variability > 7:
        recommendations.append(f"Your cycle length varies by {variability} days")
        if variability > 14:
            recommendations.append("Significant variation - medical consultation recommended")
    
    # Add recommendations based on daily logs
    frequent_symptoms = (
        DailySymptom.objects.filter(daily_log__user=cycles[0].user)
        .values('symptom')
        .annotate(count=Count('id'))
        .filter(count__gte=3)
    )
    
    for symptom in frequent_symptoms:
        rec = {
            'cramps': "Consider magnesium supplements for frequent cramps",
            'headache': "Stay hydrated and monitor caffeine intake for headaches",
            'bloating': "Reduce salt and processed foods to minimize bloating"
        }.get(symptom['symptom'].lower())
        if rec:
            recommendations.append(rec)
    
    return recommendations or [
        "Maintain a balanced diet rich in iron and vitamins",
        "Track symptoms to identify patterns"
    ]

def get_cycle_notes(cycle, avg_length):
    """
    Generate custom notes for each cycle based on its characteristics
    """
    notes = []
    
    if not cycle.cycle_length:
        return ["Cycle length not calculated"]
    
    # Length analysis
    if cycle.cycle_length > 35:
        notes.append(f"Long cycle ({cycle.cycle_length} days)")
    elif cycle.cycle_length < 21:
        notes.append(f"Short cycle ({cycle.cycle_length} days)")
    
    # Comparison to average
    if avg_length and abs(cycle.cycle_length - avg_length) > 5:
        diff = cycle.cycle_length - avg_length
        notes.append(f"{abs(diff)} days {'longer' if diff > 0 else 'shorter'} than average")
    
    # Flow analysis (if you track this)
    if hasattr(cycle, 'flow_intensity'):
        if cycle.flow_intensity == 'heavy':
            notes.append("Heavy flow noted")
        elif cycle.flow_intensity == 'light':
            notes.append("Light flow noted")
    
    return notes if notes else ["Normal cycle characteristics"]



# This code is a utility module for a Django application that deals with menstrual cycle tracking and health recommendations.
def get_personalized_recommendations(user):
    try:
        today = timezone.now().date()
        phase_info = get_phase(user)
        current_phase = phase_info['title'].lower()
        is_irregular = phase_info['is_irregular']
        
        # ===== NEW: Get today's data from DailyLog =====
        daily_log = DailyLog.objects.filter(user=user, date=today).first()
        
        # Get symptoms (from daily log or fallback to recent)
        if daily_log:
            todays_symptoms = list(daily_log.dailysymptom_set.values_list('symptom', flat=True))
            todays_moods = list(daily_log.dailymood_set.values_list('mood', flat=True))
        else:
            # Fallback to recent symptoms/moods if no daily log
            todays_symptoms = Symptom.objects.filter(
                cycle__user=user,
                date__gte=today-timedelta(days=7)
            ).values_list('symptom', flat=True).distinct()
            
            todays_moods = Mood.objects.filter(
                cycle__user=user,
                date__gte=today-timedelta(days=7)
            ).values_list('mood', flat=True).distinct()

        # Base query - phase matching first
        recommendations = ContentRecommendation.objects.filter(
            phase=current_phase.split()[0],
            is_active=True
        )

        # ===== IMPROVEMENT 1: Group symptom recommendations =====
        symptom_groups = {}
        for symptom in todays_symptoms:
            best_match = recommendations.filter(
                symptom=symptom
            ).order_by('?').first()
            if best_match:
                symptom_groups[symptom] = best_match
        symptom_recs = list(symptom_groups.values())

        # ===== IMPROVEMENT 2: Enhanced mood matching =====
        mood_recs = []
        mood_content_map = {
            'stressed': ['stress', 'relax', 'calm'],
            'anxious': ['anxiety', 'peace', 'mindful'],
            'happy': ['energy', 'joy', 'vitality'],
            'tired': ['energy boost', 'fatigue relief'],
            'irritable': ['calm', 'patience', 'mood balance']
        }
        
        for mood in todays_moods:
            mood_query = Q()
            for keyword in mood_content_map.get(mood.lower(), []):
                mood_query |= Q(title__icontains=keyword) | Q(description__icontains=keyword)
            
            best_mood_match = recommendations.filter(mood_query)\
                                           .exclude(id__in=[r.id for r in symptom_recs])\
                                           .order_by('?').first()
            if best_mood_match:
                mood_recs.append(best_mood_match)

        # ===== IMPROVEMENT 3: Content diversity =====
        content_types = {
            'educational': ['guide', 'explainer', 'science'],
            'actionable': ['exercise', 'recipe', 'practice'],
            'supportive': ['meditation', 'self-care', 'tips']
        }
        
        diverse_recs = []
        for content_type, keywords in content_types.items():
            type_query = Q()
            for keyword in keywords:
                type_query |= Q(description__icontains=keyword)
            match = recommendations.filter(type_query)\
                                 .exclude(id__in=[r.id for r in symptom_recs + mood_recs])\
                                 .order_by('?').first()
            if match:
                diverse_recs.append(match)

        # ===== IMPROVEMENT 4: View history consideration =====
        fresh_content = recommendations.annotate(
            viewed_count=Count(
                Case(
                    When(user_interactions__user=user, then=1),
                    output_field=IntegerField()
                )
            )
        ).order_by('viewed_count')[:2]

        # ===== NEW: Irregular cycle specific content =====
        irregular_recs = []
        if is_irregular:
            irregular_recs = recommendations.filter(
                Q(title__icontains='irregular') | 
                Q(description__icontains='irregular')
            ).exclude(id__in=[r.id for r in symptom_recs + mood_recs])\
             .order_by('?')[:1]

        # ===== Combine all recommendations =====
        all_recs = (
            symptom_recs[:3] +          # Max 3 symptom matches
            mood_recs[:2] +             # Max 2 mood matches
            irregular_recs +            # Irregular cycle content
            diverse_recs +              # Content variety
            list(fresh_content)         # Less-seen content
        )

        # Final fallback if we don't have enough
        if len(all_recs) < 6:
            remaining = 6 - len(all_recs)
            all_recs += list(recommendations.exclude(
                id__in=[r.id for r in all_recs]
            ).order_by('?')[:remaining])

        # Remove duplicates while preserving order
        seen = set()
        unique_recs = []
        for rec in all_recs:
            if rec.id not in seen:
                seen.add(rec.id)
                unique_recs.append(rec)

        return unique_recs[:6]

    except Exception as e:
        # Fallback to general recommendations
        return ContentRecommendation.objects.filter(
            is_active=True
        ).order_by('?')[:6]
        
def get_current_cycle(user, date=None):
    """Get active cycle for a specific date (defaults to today)"""
    date = date or timezone.now().date()
    return Cycle.objects.filter(
        user=user,
        start_date__lte=date,
        end_date__gte=date
    ).first()

def get_daily_data(user, date=None):
    """Get consolidated daily data for recommendations"""
    date = date or timezone.now().date()
    daily_log = DailyLog.objects.filter(user=user, date=date).first()
    
    if not daily_log:
        return {
            'symptoms': [],
            'moods': []
        }
    return {
        'symptoms': list(daily_log.symptoms.values_list('symptom', flat=True)),
        'moods': list(daily_log.moods.values_list('mood', flat=True)),
        'experience': daily_log.experience
    }


def get_phase_prediction(user):
    """Predict next menstrual phase and days remaining"""
    # Get current phase data
    phase_info = get_phase(user)
    current_phase = phase_info['title'].split()[0].lower()  # "Follicular Phase" -> "follicular"
    current_day = get_cycle_day(user)
    
    # Phase transition rules
    phase_sequence = {
        'menstrual': {'next': 'follicular', 'typical_duration': 7},
        'follicular': {'next': 'ovulation', 'typical_duration': 7},
        'ovulation': {'next': 'luteal', 'typical_duration': 7}, 
        'luteal': {'next': 'menstrual', 'typical_duration': 7}
    }
    
    # Calculate prediction
    phase_data = phase_sequence.get(current_phase, {})
    if not phase_data:
        return None
    
    days_remaining = max(0, phase_data['typical_duration'] - (current_day % 7))
    
    return {
        'current_phase': current_phase,
        'current_day': current_day,
        'next_phase': phase_data['next'],
        'days_remaining': days_remaining,
        'estimated_date': (timezone.now() + timedelta(days=days_remaining)).date()
    }