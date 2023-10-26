--reqid
--bank
--quantity
--date requested
--requested by
--status
--last update
--updated by
--active
--checkstart
--checkend

USE Bookkeeping


EXEC dbo.spBK_DetailedItemCostBranchDept @SDate = '2023-10-18',    -- varchar(20)
                                         @EDate = '2023-10-18',    -- varchar(20)
                                         @Category = '', -- varchar(20)
                                         @BrDept = ''    -- varchar(20)

CREATE TABLE CheckBook (
	Reqid INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	Bank VARCHAR(20) DEFAULT '' NOT NULL,
	BankCode VARCHAR(20) DEFAULT '' NOT NULL,
	AcctNo VARCHAR(20) DEFAULT '' NOT NULL,
	Branch VARCHAR(50) DEFAULT '' NOT NULL,
	Quantity INT DEFAULT 0 NOT NULL,
	DateRequested DATETIME DEFAULT GETDATE() NOT NULL,
	RequestedBy VARCHAR(20) DEFAULT 'Unknown' NOT NULL,
	Status VARCHAR(20) DEFAULT 'Pending' NOT NULL,
	LastUpdated DATETIME NULL,
	UpdatedBy VARCHAR(20) DEFAULT '' NOT NULL,
	Active BIT DEFAULT 1 NOT NULL,
	CheckStart VARCHAR(20) DEFAULT '' NOT NULL,
	CheckEnd VARCHAR(20) DEFAULT '' NOT NULL
)

---------------------
INSERT INTO CheckBook
(
    Bank,
    BankCode,
    AcctNo,
    Branch,
    Quantity,
    DateRequested,
    RequestedBy,
    Status,
    LastUpdated,
    UpdatedBy,
    Active,
    CheckStart,
    CheckEnd
)
VALUES
(   
	'BDO', -- Bank - varchar(20)
    '', -- BankCode - varchar(20)
    '', -- AcctNo - varchar(20)
    '011', -- Branch - varchar(50)
    DEFAULT, -- Quantity - int
    DEFAULT, -- DateRequested - datetime
    DEFAULT, -- RequestedBy - varchar(20)
    DEFAULT, -- Status - varchar(20)
    NULL,    -- LastUpdated - datetime
    DEFAULT, -- UpdatedBy - varchar(20)
    DEFAULT, -- Active - bit
    DEFAULT, -- CheckStart - varchar(20)
    DEFAULT  -- CheckEnd - varchar(20)
)

---------------------
SELECT * FROM #CheckBook

---------------------
DROP TABLE #CheckBook


