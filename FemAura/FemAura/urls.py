from django.urls import path, include
from drf_yasg.views import get_schema_view
from drf_yasg import openapi
from rest_framework.permissions import AllowAny

schema_view = get_schema_view(
    openapi.Info(
        title="FemAura API",
        default_version="3.1.0",
        description="API documentation for the FemAura project",
    ),
    public=True,
    permission_classes=(AllowAny,),
)

urlpatterns = [
    path("api-docs/", schema_view.with_ui("swagger", cache_timeout=0), name="api-docs"),
    path("api/", include("Application.routers.urls")),
]
