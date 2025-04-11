from datetime import date, timedelta
from .models import Cycle

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

def get_phase(user):
    """
    Determine the current menstrual phase with adaptive logic for irregular cycles.
    Returns phase information including title, symptoms, and recommendations.
    """
    cycles = Cycle.objects.filter(user=user).order_by('-start_date')
    if not cycles.exists():
        return {
            'title': 'No data',
            'symptoms': [],
            'recommendations': [],
            'is_irregular': False,
            'confidence': 'none'
        }

    current_cycle = cycles.first()
    current_day = get_current_day(user)
    avg_cycle_length = get_average_cycle_length(user)
    
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

    return {
        'title': phase_title,
        'symptoms': symptoms,
        'recommendations': recommendations,
        'is_irregular': is_irregular,
        'confidence': 'high' if not is_irregular else 'medium'
    }

def get_period_history(user):
    """
    Returns comprehensive period history with analysis and recommendations
    """
    cycles = Cycle.objects.filter(user=user).order_by('start_date')
    if not cycles.exists():
        return None

    lengths = [c.cycle_length for c in cycles if c.cycle_length]
    avg_length = sum(lengths) / len(lengths) if lengths else 0
    variability = max(lengths) - min(lengths) if len(lengths) > 1 else 0
    is_irregular = avg_length > 35 or variability > 7
    
    return {
        'avg_cycle_length': avg_length,
        'cycle_variability': variability,
        'irregularity_level': get_irregularity_level(variability, avg_length),
        'total_cycles': len(cycles),
        'period_history': [
            {
                'start_date': c.start_date,
                'end_date': c.end_date,
                'cycle_length': c.cycle_length,
                'is_irregular': c.cycle_length > 35 if c.cycle_length else False,
                'notes': get_cycle_notes(c, avg_length)  # Now properly defined
            } for c in cycles
        ],
        'health_recommendations': get_health_recommendations(cycles, avg_length, variability)
    }

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

def get_health_recommendations(cycles, avg_length, variability):
    """
    Generate personalized health recommendations based on cycle history
    """
    recommendations = []
    lengths = [c.cycle_length for c in cycles if c.cycle_length]
    
    if not lengths:
        return ["Track more cycles for personalized recommendations"]
    
    # Irregularity recommendations
    if avg_length > 35:
        recommendations.append("Your average cycle is longer than typical")
        recommendations.append("Consider discussing with a healthcare provider")
    
    if variability > 7:
        recommendations.append(f"Your cycle length varies by {variability} days")
        if variability > 14:
            recommendations.append("Significant variation - medical consultation recommended")
    
    # General health tips
    recommendations.append("Maintain a balanced diet rich in iron and vitamins")
    recommendations.append("Track symptoms to identify patterns")
    
    # Add specific recommendations based on cycle characteristics
    if any(c.cycle_length and c.cycle_length < 21 for c in cycles):
        recommendations.append("Short cycles may indicate hormonal imbalances")
    
    if len(cycles) < 6:
        recommendations.append("Tracking more cycles will improve predictions")
    
    return recommendations

def get_irregularity_level(variability, avg_length):
    """
    Classify cycle irregularity into levels
    """
    if avg_length == 0:
        return 'unknown'
    if variability > 14 or avg_length > 40:
        return 'high'
    if variability > 7 or avg_length > 35:
        return 'moderate'
    return 'low'

def get_irregularity_level(variability, avg_length):
    if avg_length == 0:
        return 'unknown'
    if variability > 15 or avg_length > 35:
        return 'high'
    if variability > 7:
        return 'moderate'
    return 'low'

def get_health_recommendations(cycles, avg_length, variability):
    lengths = [c.cycle_length for c in cycles if c.cycle_length]
    if not lengths:
        return []
    
    variability = max(lengths) - min(lengths) if len(lengths) > 1 else 0
    avg_length = sum(lengths) / len(lengths)
    
    recommendations = []
    
    if variability > 15:
        recommendations.append("Your cycles vary significantly in length")
        recommendations.append("Consider tracking additional symptoms like temperature")
    
    if avg_length > 35:
        recommendations.append("Your average cycle is longer than typical")
        recommendations.append("Consult a healthcare provider if this persists")
    
    return recommendations