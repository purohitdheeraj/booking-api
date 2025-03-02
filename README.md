# Booking API

A simple event booking API built with Ruby on Rails, supporting role-based access control, event management, and booking features.

## ER diagram
![database schema](/ER.png)

## Prerequisites

- Ruby 3.3.7
- Rails 7.1.5.1
- PostgreSQL
- Redis (for background jobs)

## Setup & Installation

### Clone the repository

```sh
git clone https://github.com/purohitdheeraj/booking_api.git
cd booking_api
```

### Install dependencies

```sh
bundle install
```

### Set up environment variables

Create a `.env` file and configure:

```sh
DATABASE_URL=your_postgres_url
SECRET_KEY_BASE=your_secret_key
```

### Set up the database

```sh
rails db:create db:migrate db:seed
```

### Run the server

```sh
rails s
```

## API Documentation

When deployed, API documentation is available at:
[🔗 API Docs](https://booking-api-production-5822.up.railway.app/)


## Deployment

Ensure `SECRET_KEY_BASE` and `DATABASE_URL` are set in the production environment. Deploy using Railway or any preferred platform.