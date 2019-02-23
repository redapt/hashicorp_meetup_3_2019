FROM microsoft/dotnet:2.1-sdk AS build

COPY ./cu21 /app

WORKDIR /app

RUN dotnet build -c Release -r linux-x64 && \
    dotnet publish -c Release -o published

FROM microsoft/dotnet:2.1-aspnetcore-runtime as runtime

COPY --from=build published /app

RUN dotnet app/RedaptUniversity.dll