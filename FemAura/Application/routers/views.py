from django.shortcuts import render, redirect
from django.contrib import messages
from django.core.mail import send_mail
from django.conf import settings
from rest_framework.views import APIView
from rest_framework.response import Response

class ExampleView(APIView):
    def get(self, request):
        return Response({"message": "Hello, world!"})
