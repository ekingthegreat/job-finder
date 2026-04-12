💼 Job Finder Web Application

A simple and responsive Job Finder Web Application built using PHP and MySQL. This system allows users to browse available job listings, view job details, and apply for jobs efficiently.

🚀 Features
👤 User Registration and Login system
🔎 Browse and search job listings
📄 View detailed job descriptions
📝 Apply for jobs online
🗂 Admin panel for managing job posts (if included)
💾 MySQL database integration
🛠️ Tech Stack
Frontend: HTML, CSS, JavaScript, Bootstrap (if used)
Backend: PHP
Database: MySQL
Server: Apache (XAMPP / WAMP / LAMP)
📁 Project Structure
job-finder/
│
├── assets/            # CSS, JS, Images
├── includes/         # DB connection, reusable PHP files
├── admin/            # Admin dashboard (if available)
├── user/             # User dashboard
├── jobs/             # Job listing pages
├── index.php         # Main homepage
└── database.sql      # Database file
⚙️ Installation
Clone the repository:
git clone https://github.com/ekingthegreat/job-finder.git
Move project to your server directory:
XAMPP → htdocs/
Import the database:
Open phpMyAdmin
Create a database (e.g. job_finder)
Import database.sql
Configure database connection:
Edit includes/db.php (or similar file):
$host = "localhost";
$user = "root";
$pass = "";
$db   = "job_finder";
Run the project:
http://localhost/job-finder
📌 Future Improvements
Advanced job filtering system
Email notifications for job applications
Resume upload feature
Employer dashboard
API integration for job listings
🤝 Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

📄 License

This project is open-source and free to use for learning purposes.

👨‍💻 Author

Developed by Michael Martinez
