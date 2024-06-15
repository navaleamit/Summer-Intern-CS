-- Create Database
CREATE DATABASE BankingSystem;
GO
USE BankingSystem;
GO

-- Create Table: Customers
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    PhoneNumber NVARCHAR(15) UNIQUE NOT NULL,
    Address NVARCHAR(255),
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

-- Create Table: Accounts
CREATE TABLE Accounts (
    AccountID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT,
    AccountType NVARCHAR(10) CHECK (AccountType IN ('Savings', 'Checking')) NOT NULL,
    Balance DECIMAL(15, 2) DEFAULT 0.00,
    CreatedAt DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
GO

-- Create Table: Transactions
CREATE TABLE Transactions (
    TransactionID INT IDENTITY(1,1) PRIMARY KEY,
    AccountID INT,
    TransactionType NVARCHAR(10) CHECK (TransactionType IN ('Deposit', 'Withdrawal', 'Transfer')) NOT NULL,
    Amount DECIMAL(15, 2) NOT NULL,
    TransactionDate DATETIME DEFAULT GETDATE(),
    FOREIGN KEY (AccountID) REFERENCES Accounts(AccountID)
);
GO

-- Stored Procedure: CreateCustomer
CREATE PROCEDURE CreateCustomer
    @FirstName NVARCHAR(50),
    @LastName NVARCHAR(50),
    @DateOfBirth DATE,
    @Email NVARCHAR(100),
    @PhoneNumber NVARCHAR(15),
    @Address NVARCHAR(255)
AS
BEGIN
    INSERT INTO Customers (FirstName, LastName, DateOfBirth, Email, PhoneNumber, Address)
    VALUES (@FirstName, @LastName, @DateOfBirth, @Email, @PhoneNumber, @Address);
END;
GO

-- Stored Procedure: OpenAccount
CREATE PROCEDURE OpenAccount
    @CustomerID INT,
    @AccountType NVARCHAR(10)
AS
BEGIN
    INSERT INTO Accounts (CustomerID, AccountType)
    VALUES (@CustomerID, @AccountType);
END;
GO

-- Stored Procedure: DepositMoney
CREATE PROCEDURE DepositMoney
    @AccountID INT,
    @Amount DECIMAL(15, 2)
AS
BEGIN
    UPDATE Accounts
    SET Balance = Balance + @Amount
    WHERE AccountID = @AccountID;
    
    INSERT INTO Transactions (AccountID, TransactionType, Amount)
    VALUES (@AccountID, 'Deposit', @Amount);
END;
GO

-- Stored Procedure: WithdrawMoney
CREATE PROCEDURE WithdrawMoney
    @AccountID INT,
    @Amount DECIMAL(15, 2)
AS
BEGIN
    DECLARE @Balance DECIMAL(15, 2);
    
    SELECT @Balance = Balance
    FROM Accounts
    WHERE AccountID = @AccountID;
    
    IF @Balance >= @Amount
    BEGIN
        UPDATE Accounts
        SET Balance = Balance - @Amount
        WHERE AccountID = @AccountID;
        
        INSERT INTO Transactions (AccountID, TransactionType, Amount)
        VALUES (@AccountID, 'Withdrawal', @Amount);
    END
    ELSE
    BEGIN
        RAISERROR ('Insufficient funds', 16, 1);
    END
END;
GO

-- Stored Procedure: TransferMoney
CREATE PROCEDURE TransferMoney
    @FromAccountID INT,
    @ToAccountID INT,
    @Amount DECIMAL(15, 2)
AS
BEGIN
    DECLARE @FromBalance DECIMAL(15, 2);
    
    SELECT @FromBalance = Balance
    FROM Accounts
    WHERE AccountID = @FromAccountID;
    
    IF @FromBalance >= @Amount
    BEGIN
        UPDATE Accounts
        SET Balance = Balance - @Amount
        WHERE AccountID = @FromAccountID;
        
        UPDATE Accounts
        SET Balance = Balance + @Amount
        WHERE AccountID = @ToAccountID;
        
        INSERT INTO Transactions (AccountID, TransactionType, Amount)
        VALUES (@FromAccountID, 'Transfer', @Amount);
        
        INSERT INTO Transactions (AccountID, TransactionType, Amount)
        VALUES (@ToAccountID, 'Transfer', @Amount);
    END
    ELSE
    BEGIN
        RAISERROR ('Insufficient funds', 16, 1);
    END
END;
GO

-- Stored Procedure: ViewTransactionHistory
CREATE PROCEDURE ViewTransactionHistory
    @AccountID INT
AS
BEGIN
    SELECT *
    FROM Transactions
    WHERE AccountID = @AccountID
    ORDER BY TransactionDate DESC;
END;
GO
