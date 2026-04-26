# syntax=docker/dockerfile:1

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

# TODO
# Create a stage named "restore" based on the .NET 8 SDK image.
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS restore
WORKDIR /src
COPY ["TaskHub.csproj", "./"]
RUN dotnet restore "TaskHub.csproj"

# TODO
# Create a stage named "build" that starts FROM the "restore" stage.
FROM restore AS build
COPY . .
RUN dotnet build "TaskHub.csproj" -c Release --no-restore

FROM build AS migrations
RUN dotnet tool install --global dotnet-ef --version 8.0.13
ENV PATH="${PATH}:/root/.dotnet/tools"
ENTRYPOINT ["dotnet", "ef", "database", "update", "--project", "TaskHub.csproj", "--startup-project", "TaskHub.csproj", "--configuration", "Release", "--no-build"]

# TODO
# Create a stage named "publish" that starts FROM the "build" stage.
FROM build AS publish
RUN dotnet publish "TaskHub.csproj" -c Release -o /app/publish --no-build /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
USER app
ENTRYPOINT ["dotnet", "TaskHub.dll"]
