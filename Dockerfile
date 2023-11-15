
# Use the official .NET Core SDK image as the base image
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build-env

# Set the working directory to /app
WORKDIR /app

# Copy the .csproj file to the container
COPY *.csproj ./

# Restore the NuGet packages
RUN dotnet restore

# Copy the rest of the application code to the container
COPY . ./

# Build the application
RUN dotnet publish -c Release -o out

# Use the official .NET Core runtime image as the base image
FROM mcr.microsoft.com/dotnet/aspnet:7.0

# Set the working directory to /app
WORKDIR /app

# Copy the published output from the build environment to the container
COPY --from=build-env /app/out .

# Expose port 5094 to the outside world
EXPOSE 80

# Start the application
ENTRYPOINT ["dotnet", "Demo GH.dll"]
