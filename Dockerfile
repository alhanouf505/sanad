# ---- build stage ----
FROM golang:1.23-alpine AS build
WORKDIR /src
COPY backend/go.mod backend/go.sum ./
RUN go mod download
COPY backend/ ./
# glebarez/sqlite is pure-Go → no CGO needed
RUN CGO_ENABLED=0 go build -o /server .

# ---- run stage ----
FROM alpine:3.20
WORKDIR /app
COPY --from=build /server /app/server
COPY backend/seed.json /app/seed.json
COPY frontend/ /app/frontend/
ENV FRONTEND_DIR=/app/frontend
ENV DB_PATH=/app/sanad.db
# Render يحقن متغيّر PORT تلقائيًا؛ الكود يقرأه من config
CMD ["/app/server"]
