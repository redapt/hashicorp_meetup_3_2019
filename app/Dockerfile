FROM microsoft/dotnet:2.1-sdk AS build

COPY ./cu21 /builder

WORKDIR /builder

RUN dotnet build -c Release -r linux-x64 && \
    dotnet publish -c Release -o /published

FROM microsoft/dotnet:2.1-aspnetcore-runtime as runtime

ARG SQLCONNSTR_SchoolContext 

COPY --from=build /published /app
COPY ./certificate.pfx /app

WORKDIR /app

EXPOSE 80 443

ENTRYPOINT [ "dotnet", "RedaptUniversity.dll" ]