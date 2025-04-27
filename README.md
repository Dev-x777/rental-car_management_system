## Car Rental Management System

### Overview
The **Car Rental Management System** is a comprehensive solution designed to streamline and manage the operations of a car rental business. This system allows administrators to manage car listings, handle bookings, track car availability, and maintain customer records. Built with modern technologies, this solution ensures efficient and effective management of all car rental activities.

### Features
- **Car Listings Management**: Easily add, update, and remove cars from the available inventory.
- **Booking System**: Allows customers to view available cars and make bookings based on their requirements.
- **User Accounts**: Customers and administrators can create and manage accounts.
- **Car Availability Tracking**: Real-time availability status of all cars.
- **Revenue Dashboard**: Detailed insights into rental revenue for better financial tracking and decision-making.
- **Profile Photo Management**: Integration with Supabase for secure and scalable user profile photo storage.
- **Search and Filter Options**: Easily search for cars based on different criteria such as type, price, and availability.
- **Notifications**: Real-time notifications for booking confirmations, cancellations, and reminders.

### Technologies Used
- **Frontend**: Flutter
- **Backend**: Supabase
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **Storage**: Supabase Storage for profile photos and car images
- **Other**: Dart, SQL

### Installation

#### Prerequisites
Before you begin, ensure you have met the following requirements:
- [Flutter](https://flutter.dev/docs/get-started/install) installed on your local machine.
- An active Supabase account and a project created [Supabase](https://supabase.io/).
- A basic understanding of Flutter, Supabase, and SQL.

#### Steps to Set Up

1. **Clone the Repository**
   ```bash
   git clone https://github.com/Dev-x777/rental-car_management_system.git
   cd rental-car_management_system

   ### Install Flutter Dependencies
In the project root directory, run:
```bash
flutter pub get

Set Up Supabase
Go to your Supabase dashboard.

Create a new project and configure your database tables and storage buckets.

Set up your Supabase URL and Supabase API Key in your Flutter app.

Example of environment variables in .env:

ini
Copy
Edit
SUPABASE_URL=your-supabase-url
SUPABASE_ANON_KEY=your-supabase-anon-key
Run the App
Connect your device or emulator, then run:

bash
Copy
Edit
flutter run
Usage
Once the app is running, users can:

Sign up/login: Create an account or log in as an existing user.

Browse cars: View the list of cars available for rental with detailed information.

Make bookings: Select cars and book based on availability.

Track reservations: View current and past reservations.

Admin Functions:
Add new cars: Admin users can add new cars to the rental system.

View monthly revenue: Admin can track monthly revenue via the dashboard.

Manage user profiles: Admin can manage customer profiles and their bookings.

Database Schema
The system uses the following core tables in Supabase:

Cars: Contains information about each car available for rent.

Fields: id, make, model, year, price_per_day, status, created_at, updated_at.

Bookings: Stores the booking details of customers.

Fields: id, user_id, car_id, start_date, end_date, total_price, status, created_at, updated_at.

Users: User profile data.

Fields: id, email, name, profile_picture_url.

Monthly Revenue Dashboard: A view in Supabase for calculating the total revenue each month.

Contributing
If you'd like to contribute to the development of the Car Rental Management System, feel free to fork the repository and submit pull requests. Please ensure that your code follows the existing style and passes the tests before submitting.

Steps to Contribute:
Fork the repository.

Create a new branch (git checkout -b feature-xyz).

Make your changes.

Commit your changes (git commit -am 'Add new feature').

Push to the branch (git push origin feature-xyz).

Submit a pull request.

License
This project is licensed under the MIT License - see the LICENSE file for details.

Acknowledgments
Flutter for providing the framework.

Supabase for offering backend-as-a-service.

PostgreSQL for the powerful database engine.

The open-source community for their contributions.

pgsql
Copy
Edit

This version uses proper Markdown formatting with headers (`##`) and includes the setup, usage, database schema, contributing instructions, license, and acknowledgments for your `README.md` file.








