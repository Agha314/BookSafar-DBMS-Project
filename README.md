# BookSafar

A JSP-based travel package booking portal with user booking flows and an admin back office.

## Features
- Travellers: browse, search, and sort live packages; view details, seats, and availability windows; book and pay; leave reviews after trips; cancel with reasons.
- Admins: dashboard with totals and revenue, package CRUD, booking/review moderation, user list, add co-admins, and visibility into their own package performance.
- Data model: admins, users, packages, bookings, payments, and reviews with referential checks (see schema).

## Tech Stack
- Java (JSP), JDBC, Apache Tomcat.
- Oracle Database (sample user `webuser`).
- Plain CSS in `assets/css`.

## Prerequisites
- Java 8+ runtime.
- Apache Tomcat 9+ (or compatible servlet container).
- Oracle Database (XE or higher).
- Oracle JDBC driver (e.g., `ojdbc8.jar`) placed in Tomcat's `lib` directory.

## Setup
1) **Database**
   - Create a DB user (adjust names/passwords as needed):
     ```sql
     CREATE USER webuser IDENTIFIED BY web123;
     GRANT CONNECT, RESOURCE TO webuser;
     ALTER USER webuser QUOTA UNLIMITED ON USERS;
     ```
   - Run the schema script to create tables and seed the admin: `schema.sql`.
   - Default admin seeded: `admin@booksafar.local` / `admin123`.

2) **App configuration**
   - Connection settings live in [config.jspf](config.jspf#L1-L19). Update `DB_URL`, `DB_USER`, and `DB_PASS` to match your Oracle instance.
   - Ensure `oracle.jdbc.driver.OracleDriver` is available (place the JDBC jar in Tomcat's `lib`).

3) **Deploy & run**
   - Drop this folder into Tomcat's `webapps` (already structured as a WAR directory).
   - Start Oracle, then start Tomcat.
   - Visit `http://localhost:8080/BookSafar/` for the user UI and `http://localhost:8080/BookSafar/admin/login.jsp` for admin.

## Usage Notes
- Package browsing with search and price sorting is in [index.jsp](index.jsp).
- Admin metrics and package overview live in [admin/dashboard.jsp](admin/dashboard.jsp).
- Update styles in `assets/css/style.css`; images go in `assets/images/`.

## Testing ideas
- Create sample packages as admin; verify search/sort and availability filters.
- Book a package as a user, complete payment, and leave a review to exercise Booking/Payment/Review tables.
- Cancel a booking and confirm status transitions and counts on the admin dashboard.

## Troubleshooting
- If you see Oracle driver errors, confirm `ojdbc` jar is in Tomcat `lib` and restart.
- For DB auth issues, double-check the credentials and service name in `DB_URL`.
- Review server logs for stack traces; the app logs ignored close failures via `logIgnoredException`.
