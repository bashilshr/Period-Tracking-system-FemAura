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
    Determine the ovulation status.
    """
    cycles = Cycle.objects.filter(user=user)
    if not cycles.exists():
        return "No data"

    current_day = get_current_day(user)
    avg_cycle_length = get_average_cycle_length(user)
    ovulation_day = avg_cycle_length - 14

    if current_day < ovulation_day:
        return f"Ovulation in {ovulation_day - current_day} days"
    elif current_day == ovulation_day:
        return "Ovulation today"
    elif current_day <= ovulation_day + 2:
        return "Ovulation possible"
    else:
        return "Ovulation finished"

def get_phase(user):
    """
    Determine the current phase of the cycle and provide symptoms and recommendations.
    """
    cycles = Cycle.objects.filter(user=user)
    if not cycles.exists():
        return {'title': 'No data', 'symptoms': [], 'recommendations': []}

    current_day = get_current_day(user)
    avg_cycle_length = get_average_cycle_length(user)

    # Check if the cycle is irregular
    is_irregular = avg_cycle_length > 28

    if current_day <= 7:
        phase_title = 'Menstrual Phase'
        symptoms = ['Cramps', 'Fatigue', 'Mood swings']
        recommendations = [
            'Stay hydrated',
            'Use a heating pad for cramps',
            'Rest if you feel fatigued',
        ]
    elif current_day <= 14:
        phase_title = 'Follicular Phase'
        symptoms = ['Increased energy', 'Improved mood']
        recommendations = [
            'Engage in light exercise',
            'Eat a balanced diet',
            'Plan creative or productive tasks',
        ]
    elif current_day <= 21:
        phase_title = 'Ovulation Phase'
        symptoms = ['Increased libido', 'Mild abdominal pain']
        recommendations = [
            'Track ovulation if planning pregnancy',
            'Stay hydrated',
            'Avoid strenuous activities if experiencing pain',
        ]
    else:
        phase_title = 'Luteal Phase'
        symptoms = ['Bloating', 'Breast tenderness', 'Mood swings']
        recommendations = [
            'Reduce salt intake to avoid bloating',
            'Wear comfortable clothing',
            'Practice relaxation techniques for mood swings',
        ]

    # Add irregular cycle symptoms and recommendations
    if is_irregular:
        symptoms.append('Irregular cycle detected')
        recommendations.append('Consult a healthcare provider for irregular cycles')

    return {
        'title': phase_title,
        'symptoms': symptoms,
        'recommendations': recommendations,
        'is_irregular': is_irregular,
    }

def get_period_history(user):
    """
    Fetch period history for a user and detect irregular cycles.
    """
    cycles = Cycle.objects.filter(user=user).order_by('start_date')
    if not cycles.exists():
        return None

    # Calculate average cycle length
    total_cycles = cycles.count()
    total_cycle_length = sum(cycle.cycle_length for cycle in cycles if cycle.cycle_length is not None)
    avg_cycle_length = total_cycle_length / total_cycles if total_cycles > 0 else 0

    # Check if the cycle is irregular
    is_irregular = avg_cycle_length > 28

    # Prepare period history
    period_history = []
    for cycle in cycles:
        period_history.append({
            'start_date': cycle.start_date,
            'end_date': cycle.end_date,
            'cycle_length': cycle.cycle_length,
            'is_irregular': cycle.cycle_length > 28 if cycle.cycle_length else False,
        })

    return {
        'avg_cycle_length': avg_cycle_length,
        'total_cycles': total_cycles,
        'period_history': period_history,
        'is_irregular': is_irregular,
    }