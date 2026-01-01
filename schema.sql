
CREATE TABLE Admin (
  adminid NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name VARCHAR2(100) NOT NULL,
  email VARCHAR2(100) NOT NULL UNIQUE,
  password VARCHAR2(255) NOT NULL,
  phone VARCHAR2(20),
  createdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  CONSTRAINT chk_admin_name CHECK (LENGTH(TRIM(name)) > 0),
  CONSTRAINT chk_admin_password CHECK (LENGTH(password) >= 6)
);

CREATE TABLE Users (
  userid NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name VARCHAR2(100) NOT NULL,
  email VARCHAR2(100) NOT NULL UNIQUE,
  password VARCHAR2(255) NOT NULL,
  phone VARCHAR2(20),
  createdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  CONSTRAINT chk_users_name CHECK (LENGTH(TRIM(name)) > 0),
  CONSTRAINT chk_users_password CHECK (LENGTH(password) >= 6)
);

CREATE TABLE Package (
  packageid NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  title VARCHAR2(200) NOT NULL,
  location VARCHAR2(200) NOT NULL,
  price NUMBER(10,2) NOT NULL,
  duration VARCHAR2(50),
  seats NUMBER NOT NULL,
  description CLOB,
  imageurl VARCHAR2(500),
  traveldate DATE NOT NULL,
  startpoint VARCHAR2(200),
  endpoint VARCHAR2(200),
  availabletill DATE,
  createdby NUMBER,
  createdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  deletedby NUMBER,
  deletedate TIMESTAMP,
  CONSTRAINT chk_package_title CHECK (LENGTH(TRIM(title)) > 0),
  CONSTRAINT chk_package_location CHECK (LENGTH(TRIM(location)) > 0),
  CONSTRAINT chk_package_price CHECK (price > 0),
  CONSTRAINT chk_package_seats CHECK (seats >= 0),
  CONSTRAINT chk_delete_logic CHECK ((deletedby IS NULL AND deletedate IS NULL) OR (deletedby IS NOT NULL AND deletedate IS NOT NULL)),
  CONSTRAINT fk_package_createdby FOREIGN KEY (createdby) REFERENCES Admin(adminid) ON DELETE SET NULL,
  CONSTRAINT fk_package_deletedby FOREIGN KEY (deletedby) REFERENCES Admin(adminid) ON DELETE SET NULL
);

CREATE TABLE Booking (
  bookingid NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  userid NUMBER NOT NULL,
  packageid NUMBER NOT NULL,
  bookingdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  status VARCHAR2(50) DEFAULT 'Booked' NOT NULL,
  cancelreason CLOB,
  canceldate TIMESTAMP,
  CONSTRAINT chk_booking_status CHECK (status IN ('Booked', 'Cancelled', 'Completed')),
  CONSTRAINT fk_booking_userid FOREIGN KEY (userid) REFERENCES Users(userid) ON DELETE CASCADE,
  CONSTRAINT fk_booking_packageid FOREIGN KEY (packageid) REFERENCES Package(packageid)
);

CREATE TABLE Payment (
  payid NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  bookingid NUMBER NOT NULL UNIQUE,
  paydate TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  paymethod VARCHAR2(50) NOT NULL,
  amount NUMBER(10,2) NOT NULL,
  paystatus VARCHAR2(50) NOT NULL,
  CONSTRAINT chk_payment_amount CHECK (amount > 0),
  CONSTRAINT chk_payment_status CHECK (paystatus IN ('Completed', 'Refunded')),
  CONSTRAINT fk_payment_bookingid FOREIGN KEY (bookingid) REFERENCES Booking(bookingid)
);

CREATE TABLE Review (
  reviewid NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  userid NUMBER NOT NULL,
  packageid NUMBER NOT NULL,
  bookingid NUMBER NOT NULL UNIQUE,
  rating NUMBER NOT NULL,
  reviewcomment CLOB,
  reviewdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  CONSTRAINT chk_review_rating CHECK (rating BETWEEN 1 AND 5),
  CONSTRAINT fk_review_userid FOREIGN KEY (userid) REFERENCES Users(userid) ON DELETE CASCADE,
  CONSTRAINT fk_review_packageid FOREIGN KEY (packageid) REFERENCES Package(packageid) ON DELETE CASCADE,
  CONSTRAINT fk_review_bookingid FOREIGN KEY (bookingid) REFERENCES Booking(bookingid) ON DELETE CASCADE
);


CREATE INDEX idx_booking_user ON Booking(userid);
CREATE INDEX idx_booking_package ON Booking(packageid);
CREATE INDEX idx_review_package ON Review(packageid);
CREATE INDEX idx_package_location ON Package(location);


INSERT INTO Admin(name,email,password,phone) VALUES('Super Admin','admin@booksafar.local','admin123','+10000000000');
COMMIT;
