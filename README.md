# Real-Time FastAPI & Flutter Chat App

A full-stack, real-time chat application built with a **FastAPI (Python)** backend and a **Flutter (Dart)** mobile frontend. This project features secure user authentication, persistent chat history using PostgreSQL, and instant bidirectional messaging powered by WebSockets.

---

## 🚀 Features

* **Secure Authentication:** User registration and login with password hashing (Bcrypt) and JWT (JSON Web Tokens).
* **Real-Time Messaging:** Instant, bidirectional communication using WebSockets.
* **Persistent Storage:** Relational database (PostgreSQL + SQLAlchemy) to safely store users, conversations, and chat history.
* **Cross-Platform UI:** A sleek, responsive mobile frontend built with Flutter for iOS and Android.
* **Session Management:** Secure local storage of authentication tokens on the device.

---

## 🛠️ Tech Stack

### Backend (Python)
* **Framework:** [FastAPI](https://fastapi.tiangolo.com/)
* **Database:** PostgreSQL
* **ORM:** SQLAlchemy
* **Authentication:** JWT (JSON Web Tokens) & Passlib (Bcrypt)
* **Real-Time:** WebSockets

### Frontend (Dart)
* **Framework:** [Flutter](https://flutter.dev/)
* **Networking:** `http` package (REST) & `web_socket_channel` (WebSockets)
* **Storage:** `shared_preferences` (Local Token Storage)

---
# 📋 Prerequisites

Before you begin, ensure you have the following installed on your machine:

- Python 3.9+
- PostgreSQL
- Flutter SDK
- An Android Emulator, iOS Simulator, or a physical mobile device.

---

# ⚙️ Backend Setup (FastAPI)

1. **Navigate to the backend directory:**

   ```bash
   cd backend
   ```

2. **Create and activate a virtual environment:**

   ```bash
   # Windows
   python -m venv .venv
   .venv\Scripts\activate

   # Mac/Linux
   python3 -m venv .venv
   source .venv/bin/activate
   ```

3. **Install dependencies:**

   ```bash
   pip install fastapi uvicorn sqlalchemy psycopg2-binary passlib bcrypt python-jose
   ```

4. **Set up the Database:**
   - Open your PostgreSQL instance and create a database named `chat_app_db`.
   - Update the `SQLALCHEMY_DATABASE_URL` in your `database.py` file with your PostgreSQL credentials.

5. **Run the server:** To allow mobile devices on your Wi-Fi network to connect, you must run the server on `0.0.0.0`.

   ```bash
   uvicorn main:app --host 0.0.0.0 --port 8000 --reload
   ```

---

# 📱 Frontend Setup (Flutter)

1. **Navigate to the frontend directory:**

   ```bash
   cd frontend
   ```

2. **Install Flutter packages:**

   ```bash
   flutter pub get
   ```

3. **Configure the Network IP:** Because the app runs on a mobile device/emulator, it cannot use `localhost`. You must update the backend URL to match your computer's local Wi-Fi IP address.

   Update the `baseUrl` and WebSocket `wsUrl` in the following files:
   - `lib/services/auth_service.dart`
   - `lib/services/chat_service.dart`
   - `lib/screens/chat_screen.dart`

   Example: `http://192.168.1.69:8000/api`

4. **Run the application:**

   ```bash
   flutter run
   ```

---

# 🛣️ API Endpoints

### Authentication

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/auth/register` | Create a new user account. |
| `POST` | `/api/auth/login` | Authenticate and receive a JWT. |

### Chat & History

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/conversations` | Create a new chat room. |
| `GET` | `/api/conversations` | Fetch all available chat rooms (Inbox). |
| `GET` | `/api/conversations/{id}/messages` | Fetch the persistent chat history for a specific room. |

### Real-Time

| Method | Endpoint | Description |
|--------|----------|-------------|
| `WS` | `/ws/chat/{id}?token={jwt}` | Open a bidirectional WebSocket connection for live messaging. |

---

# 📝 License

This project is licensed under the [MIT License](LICENSE).