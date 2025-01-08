from django.shortcuts import render

# views.py
from django.shortcuts import render, redirect
from django.contrib.auth import login, logout, authenticate
from django.contrib import messages
from django.core.mail import send_mail
from django.conf import settings
from .models import UserAuth
from .forms import RegistrationForm, LoginForm
import random

def register_view(request):
    if request.method == "POST":
        form = RegistrationForm(request.POST)
        if form.is_valid():
            user = form.save(commit=False)
            user.is_active = False  # Deactivate until email verification
            user.save()

            # Generate OTP
            otp = random.randint(100000, 999999)
            user.otp = str(otp)
            user.save()

            # Send OTP email
            send_mail(
                subject="Verify your email",
                message=f"Your OTP is {otp}",
                from_email=settings.EMAIL_HOST_USER,
                recipient_list=[user.email],
            )
            messages.success(request, "Registration successful! Check your email for the OTP.")
            return redirect('otp_verify')
    else:
        form = RegistrationForm()

    return render(request, 'register.html', {'form': form})

def login_view(request):
    if request.method == "POST":
        form = LoginForm(request.POST)
        if form.is_valid():
            username = form.cleaned_data['username']
            password = form.cleaned_data['password']
            user = authenticate(request, username=username, password=password)
            if user:
                if user.is_email_verified:
                    login(request, user)
                    messages.success(request, "Welcome back!")
                    return redirect('dashboard')
                else:
                    messages.error(request, "Email not verified. Check your inbox.")
            else:
                messages.error(request, "Invalid credentials.")
    else:
        form = LoginForm()

    return render(request, 'login.html', {'form': form})

def logout_view(request):
    logout(request)
    messages.success(request, "Logged out successfully.")
    return redirect('login')

def otp_verify_view(request):
    if request.method == "POST":
        otp = request.POST.get("otp")
        user = User.objects.filter(otp=otp).first()
        if user:
            user.is_email_verified = True
            user.is_active = True
            user.otp = None
            user.save()
            messages.success(request, "Email verified successfully!")
            return redirect('login')
        else:
            messages.error(request, "Invalid OTP.")
    return render(request, 'otp_verify.html')
