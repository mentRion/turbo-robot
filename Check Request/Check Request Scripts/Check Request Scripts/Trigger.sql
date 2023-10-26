
------check request
------column
----id
----
----date
----acctno
----branch
----branchname
----bank
----accttype
----qty
----status

------check approval
----column
----id
----date
----acctno
----branch
----branchname
----bank

----------------------------------
ALTER TRIGGER dbo.CheckRequestTrigger
ON dbo.CheckRequest
AFTER INSERT, UPDATE, DELETE
AS
SET NOCOUNT ON;

INSERT INTO dbo.CheckRequestLogs
(
    ChckId,
	DateRqstd,
    WhsCode,
    Branch,
    BankType,
    ChckAcc,
    Stat,
    Createdby,
    DateCreated,
    Modifiedby,
    DateModified,
    quantity,
    SavAcc,
    Action,
    LogDate,
    EmpCodeLog,
    BankCode
)
SELECT d.ChckId,
       d.DateRqstd,
       d.WhsCode,
       d.Branch,
       d.BankType,
       d.ChckAcc,
       d.Stat,
       d.Createdby,
       d.DateCreated,
       d.Modifiedby,
       d.DateModified,
       d.quantity,
       d.SavAcc,
		'Delete' AS Action,
		GETDATE() AS LogDate,
		(SELECT UserId FROM dbo.CheckBookUserLog WHERE LogId = (SELECT IDENT_CURRENT('CheckRequestLogs'))) as EmpCodeLog,
       d.BankCode
FROM Deleted d
    LEFT JOIN Inserted i
        ON i.ChckId = d.ChckId
UNION ALL
SELECT I.ChckId,
       I.DateRqstd,
       I.WhsCode,
       I.Branch,
       I.BankType,
       I.ChckAcc,
       I.Stat,
       I.Createdby,
       I.DateCreated,
       I.Modifiedby,
       I.DateModified,
       I.quantity,
       I.SavAcc,
	   'Insert' AS Action,
		GETDATE() AS LogDate,
		(SELECT UserId FROM dbo.CheckBookUserLog WHERE LogId = (SELECT IDENT_CURRENT('CheckRequestLogs'))) as EmpCodeLog,
       I.BankCode
FROM INSERTED I
    LEFT JOIN DELETED D
        ON D.ChckId = I.ChckId
WHERE D.ChckId IS NULL;
GO



INSERT INTO dbo.CheckBookUserLog
(
    UserId
)
VALUES
('2400000' -- UserId - varchar(20)
    )
	INSERT INTO dbo.CheckRequest
	(
	    DateRqstd,
	    WhsCode,
	    Branch,
	    BankType,
	    ChckAcc,
	    Stat,
	    Createdby,
	    DateCreated,
	    Modifiedby,
	    DateModified,
	    quantity,
	    SavAcc,
	    BankCode
	)
	VALUES
	(   DEFAULT, -- DateRqstd - datetime
	    '',      -- WhsCode - varchar(5)
	    '',      -- Branch - varchar(70)
	    '',      -- BankType - varchar(70)
	    '',      -- ChckAcc - varchar(12)
	    NULL,    -- Stat - varchar(10)
	    NULL,    -- Createdby - varchar(20)
	    DEFAULT, -- DateCreated - datetime
	    NULL,    -- Modifiedby - varchar(20)
	    NULL,    -- DateModified - datetime
	    DEFAULT, -- quantity - int
	    NULL,    -- SavAcc - varchar(17)
	    NULL     -- BankCode - varchar(5)
	    )

SELECT * FROM dbo.CheckBookUserLog INNER JOIN dbo.CheckRequest ON CheckRequest.ChckId = dbo.CheckBookUserLog.LogId
SELECT * FROM dbo.CheckRequestLogs


--log as header-------------
--logid
--date time
--userid, empcode or id

--main detail/ main table

--detail header

SELECT * FROM dbo.CheckRequest
SELECT * FROM dbo.CheckBookUserLog

CREATE TABLE CheckBook
(
	Reqid INT PRIMARY KEY IDENTITY(1,1),
	DateRequested DATETIME DEFAULT GETDATE() NOT NULL,
	Acctno VARCHAR(20) DEFAULT '' NOT NULL,
	Branch VARCHAR(20) DEFAULT '' NOT NULL,
	Branchname VARCHAR(20) DEFAULT '' NOT NULL,
	Bank VARCHAR(20) DEFAULT '' NOT NULL,
	Accttype VARCHAR(20) DEFAULT '' NOT NULL,
	Qty INT DEFAULT 0 NOT NULL,
	Status VARCHAR(20) DEFAULT 'PENDING' NOT NULL,
	DateCreated DATETIME DEFAULT GETDATE() NOT NULL
)


INSERT INTO dbo.CheckBook
(
    Acctno,
    Branch,
    Branchname,
    Bank,
    Accttype,
    Qty,
    Status,
    DateCreated
)
VALUES
(   DEFAULT, -- Acctno - varchar(20)
    DEFAULT, -- Branch - varchar(20)
    DEFAULT, -- Branchname - varchar(20)
    DEFAULT, -- Bank - varchar(20)
    DEFAULT, -- Accttype - varchar(20)
    DEFAULT, -- Qty - int
    DEFAULT, -- Status - varchar(20)
    DEFAULT  -- DateCreated - datetime
    )

SELECT * FROM dbo.CheckBook





DROP TABLE dbo.CheckBook




