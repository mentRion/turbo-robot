----------------------------------

USE bookkeeping

ALTER PROCEDURE dbo.spBK_CheckBook
	@Mode VARCHAR(50) = '',
	@DateFrom DATE = NULL,
	@DateTo DATE = NULL,
	@Bank VARCHAR(20) = '',
	@BankCode VARCHAR(20) = '',
	@AcctNo VARCHAR(20) = '',
	@Branch VARCHAR(20) = '',
	@Quantity INT = 1,
	@DateRequested DATE = NULL,
	@RequestedBy VARCHAR(20) = 'Unknown',
	@Status VARCHAR(20) = 'Pending',
	@LastUpdated DATE = NULL,
	@UpdatedBy VARCHAR(20) = '',
	@Active INT = 1,
	@CheckStart VARCHAR(20) = '',
	@CheckEnd VARCHAR(20) = '',
	@Reqid INT = NULL,
	@AcctType VARCHAR(5) = '',
	@CheckNum VARCHAR(20) = '',
	@EmpCode VARCHAR(20) = ''
AS
	IF @Mode = 'GetCheckBook'
	BEGIN
		SELECT Reqid, Bank, BankCode, AcctNo, Branch, Quantity,
				DateRequested, RequestedBy, Status, LastUpdated, UpdatedBy,
				Active, CheckStart, CheckEnd, AcctType, CheckNum,
			   Blk AS BranchName
			   FROM dbo.CheckBook INNER JOIN dbo.SAPSet ON dbo.SAPSet.Code = dbo.CheckBook.Branch
			   WHERE Reqid = @Reqid AND Active = 1
	END
	-----------------------------------
	ELSE IF @Mode = 'GetCheckBookList'
	BEGIN
		SELECT Reqid, Bank, BankCode, AcctNo, Branch, Quantity,
				DateRequested, (SELECT EmpName FROM HPCOMMON.dbo.ScEmp WHERE EmpCode = RequestedBy) as RequestedBy,
				Status, LastUpdated, UpdatedBy, Active, AcctType, CheckStart, CheckEnd, CheckNum,
			   (SELECT Blk FROM dbo.SAPSet WHERE dbo.SAPSet.Code = Branch) AS BranchName
			   FROM dbo.CheckBook
			   WHERE 
		CAST(DateRequested AS DATE) >= CASE WHEN CAST(@DateFrom AS DATE) IS NULL OR LEN(@DateFrom) <= 0 THEN '2000-01-01' ELSE 
		CAST(@DateFrom AS DATE) END 
		AND
		--check enddate if null and len is 0
		CAST(DateRequested AS DATE) <= CASE WHEN CAST(@DateTo AS DATE) IS NULL OR LEN(@DateTo) <= 0 THEN GETDATE() ELSE 
		CAST(@DateTo AS DATE) END
		AND
		--check whscode/branch if null or len is 0
		--when null or blank accept all WhsCode/Branch
		Branch = CASE WHEN @Branch IS NULL OR LEN(@Branch) <= 0 OR @Branch = 'all' OR @Branch = '0' THEN Branch ELSE @Branch END
		AND
		--check branch if null or len is 0
		--when null or blank accept all Stat/Status
		Status = CASE WHEN @Status IS NULL OR LEN(@Status) <= 0  OR @Status = 'all' OR @Status = '0' THEN Status ELSE @Status END
		AND 
		Active = 1
	END
	-----------------------------------
    ELSE IF @Mode = 'CreateRequest'
	BEGIN
		--receive pieces
		DECLARE @pieces INT = CASE WHEN @Quantity <= 0 OR @Quantity = NULL THEN 1 ELSE @Quantity end;
		--starting check
		--check for existing latest transaction bankcode as basis
		DECLARE @_checkstart VARCHAR(10) = (SELECT CheckEnd FROM dbo.CheckBook WHERE BankCode = @BankCode and Reqid = (SELECT (MAX(Reqid)) FROM dbo.CheckBook));
		--check structure
		DECLARE @checkstruct VARCHAR(10) = '000000000';
		
		DECLARE @_checkend VARCHAR(10) = '';

		--SELECT (left(@checkstruct, LEN(@checkstruct) - LEN(CAST(@_checkstart AS int))) + '' + 
		--		CAST(CAST(@checkstart AS int) AS VARCHAR(10))) AS [CheckStart], 
		--		(left(@checkstruct, LEN(@checkstruct) - LEN(CAST(@_checkstart AS int))) + '' + 
		--		CAST(CAST(@_checkstart AS int) + @pieces AS VARCHAR(10))) AS [CheckEnd]

		
		DECLARE @countSelected INT = (SELECT COUNT(Reqid) FROM dbo.CheckBook WHERE BankCode = @BankCode)

		IF @countSelected <= 0
			BEGIN
				set @_checkstart = RIGHT('0000000000' + CAST(1 AS VARCHAR(6)), 10)
			END

		set @_checkend = RIGHT('0000000000' + CAST(CAST(@_checkstart AS int) + @pieces AS VARCHAR(6)), 10)

		INSERT INTO dbo.CheckBook
		(
		    Bank, BankCode, AcctNo, Branch, Quantity,
			DateRequested, RequestedBy, Status, LastUpdated, 
			UpdatedBy, Active, CheckStart, CheckEnd, AcctType, CheckNum
		)
		--creating logs/history
		OUTPUT Inserted.Reqid, Inserted.Bank, Inserted.BankCode, Inserted.AcctNo, Inserted.Branch,
				Inserted.Quantity, Inserted.DateRequested, Inserted.RequestedBy, Inserted.Status,
				Inserted.LastUpdated, Inserted.UpdatedBy, Inserted.Active,
				Inserted.CheckStart, Inserted.CheckEnd, Inserted.AcctType,
               Inserted.CheckNum, 'Insert', @EmpCode, GETDATE() INTO dbo.CheckBookLogs
		VALUES
		(   
			ISNULL(@Bank,''), ISNULL(@BankCode,''), ISNULL(@AcctNo,'') , 
		    @Branch, @Quantity, DEFAULT, @RequestedBy, 
		    (CASE WHEN @Quantity < 5 THEN 'Approved' ELSE 'Pending' END), 
		    @LastUpdated, @UpdatedBy, 1, ISNULL(@_checkstart, ''),
		    ISNULL(@_checkend, ''), @AcctType, @CheckNum
		)

	END
	-----------------------------------
	--update request
	ELSE IF @Mode = 'UpdateRequest'
	BEGIN
		--quantity
		--status
		--reqid
		UPDATE dbo.CheckBook SET 
			Quantity = @Quantity, 
			Status = @Status
			--creating logs/history
			OUTPUT Inserted.Reqid, Inserted.Bank, Inserted.BankCode, Inserted.AcctNo, Inserted.Branch,
					Inserted.Quantity, Inserted.DateRequested, Inserted.RequestedBy, Inserted.Status,
					Inserted.LastUpdated, Inserted.UpdatedBy, Inserted.Active, Inserted.CheckStart,
					Inserted.CheckEnd, Inserted.AcctType,
                   Inserted.CheckNum, 'Update', @EmpCode, GETDATE() INTO dbo.CheckBookLogs
			WHERE Reqid = @Reqid
		
	END
	--deactivate request
	ELSE IF @Mode = 'DeactivateRequest'
	BEGIN
		--active
		--reqid
		UPDATE dbo.CheckBook SET
			Active = 0
			--creating logs/history
			OUTPUT Inserted.Reqid, Inserted.Bank, Inserted.BankCode, Inserted.AcctNo, Inserted.Branch,
					Inserted.Quantity, Inserted.DateRequested, Inserted.RequestedBy, Inserted.Status,
					Inserted.LastUpdated, Inserted.UpdatedBy, Inserted.Active, Inserted.CheckStart,
					Inserted.CheckEnd, Inserted.AcctType,
                   Inserted.CheckNum, 'Deactivate', @EmpCode, GETDATE() INTO dbo.CheckBookLogs
			WHERE Reqid = @Reqid
	END
	--activate request
	ELSE IF @Mode = 'ReactivateRequest'
	BEGIN
		--active
		--reqid
		UPDATE dbo.CheckBook SET
			Active = 1
			--creating logs/history
			OUTPUT Inserted.Reqid, Inserted.Bank, Inserted.BankCode, Inserted.AcctNo, Inserted.Branch,
					Inserted.Quantity, Inserted.DateRequested, Inserted.RequestedBy, Inserted.Status,
					Inserted.LastUpdated, Inserted.UpdatedBy, Inserted.Active, Inserted.CheckStart,
					Inserted.CheckEnd, Inserted.AcctType,
                   Inserted.CheckNum, 'Activate', @EmpCode, GETDATE() INTO dbo.CheckBookLogs
			WHERE Reqid = @Reqid
	END
	--approving check
	ELSE IF @Mode = 'ApproveCheck'
	BEGIN
		--empcode
		--reqid
		UPDATE dbo.CheckBook SET
			Status = 'Approved'
			--creating logs/history
			OUTPUT Inserted.Reqid, Inserted.Bank, Inserted.BankCode, Inserted.AcctNo, Inserted.Branch,
					Inserted.Quantity, Inserted.DateRequested, Inserted.RequestedBy, Inserted.Status,
					Inserted.LastUpdated, Inserted.UpdatedBy, Inserted.Active, Inserted.CheckStart,
					Inserted.CheckEnd, Inserted.AcctType,
                   Inserted.CheckNum, 'Approved', @EmpCode, GETDATE() INTO dbo.CheckBookLogs
			WHERE Reqid = @Reqid
	END
	--cancelling check
	ELSE IF @Mode = 'CancelCheck'
	BEGIN
		--empcode
		--reqid
		UPDATE dbo.CheckBook SET
			Status = 'Cancelled'
			--creating logs/history
			OUTPUT Inserted.Reqid, Inserted.Bank, Inserted.BankCode, Inserted.AcctNo,
					Inserted.Branch, Inserted.Quantity, Inserted.DateRequested, Inserted.RequestedBy,
					Inserted.Status, Inserted.LastUpdated, Inserted.UpdatedBy,
					Inserted.Active, Inserted.CheckStart, Inserted.CheckEnd, Inserted.AcctType,
                   Inserted.CheckNum, 'Cancelled', @EmpCode, GETDATE() INTO dbo.CheckBookLogs
			WHERE Reqid = @Reqid
	END
	--returning check
	ELSE IF @Mode = 'ReturnCheck'
	BEGIN
		--empcode
		--reqid
		UPDATE dbo.CheckBook SET
			Status = 'Returned'
			--creating logs/history
			OUTPUT Inserted.Reqid, Inserted.Bank, Inserted.BankCode, Inserted.AcctNo,
					Inserted.Branch, Inserted.Quantity, Inserted.DateRequested, Inserted.RequestedBy,
					Inserted.Status, Inserted.LastUpdated, Inserted.UpdatedBy, Inserted.Active,
					Inserted.CheckStart, Inserted.CheckEnd, Inserted.AcctType,
                   Inserted.CheckNum, 'Returned', @EmpCode, GETDATE() INTO dbo.CheckBookLogs
			WHERE Reqid = @Reqid
	END
GO

------------------------------------------------------------------





SELECT * FROM dbo.CheckBook

ALTER TABLE dbo.CheckBook ADD CheckNum VARCHAR(20) DEFAULT ''

EXEC dbo.spBK_CheckBook @Mode = 'CreateRequest',			-- varchar(50)
                        @Bank = 'UBP',						-- varchar(20)
                        @BankCode = '11005',                -- varchar(20)
                        @AcctNo = '2150004945',             -- varchar(20)
                        @Branch = '004',					-- varchar(20)
                        @Quantity = 1,						-- int
                        @RequestedBy = '23074577',          -- varchar(20)
						@AcctType = 'OA'
                        --@Status = '',						-- varchar(20)
                        --@UpdatedBy = ''					-- varchar(20)

EXEC dbo.spBK_CheckBook @Mode = 'GetCheckBook',                            -- varchar(20)
						@Reqid = 27

EXEC dbo.spBK_CheckBook @Mode = 'GetCheckBookList', -- varchar(50)
                        @DateFrom = '2023-10-01',   -- varchar(20)
                        @DateTo = '2023-10-17',		-- varchar(20)
                        @Branch = '',
                        @Status = ''

EXEC dbo.spBK_CheckBook @Mode = 'UpdateRequest',                    -- varchar(50)
						@Reqid = 27,
                        @Quantity = 0,                 -- int
                        @Status = 'Returned',                  -- varchar(20)
                        @CheckStart = '',              -- varchar(20)
                        @CheckEnd = ''                 -- varchar(20)

						SELECT * FROM dbo.CheckBookLogs

EXEC dbo.spBK_CheckBook @Mode = 'DeactivateRequest',                    -- varchar(50)
						@Reqid = 1
						SELECT * FROM dbo.CheckBook

EXEC dbo.spBK_CheckBook @Mode = 'ReactivateRequest',                    -- varchar(50)
						@Reqid = 1
						SELECT * FROM dbo.CheckBook

EXEC dbo.spBK_CheckBook @Mode = 'UpdateStatus',                    -- varchar(50)
                        @Status = 'Returned',                  -- varchar(20)
                        @UpdatedBy = '23074577',               -- varchar(20)
                        @Reqid = 1							-- int

EXEC dbo.spBK_CheckBook @Mode = 'ReturnCheck',                    -- varchar(50)
                        @EmpCode = '23074577',               -- varchar(20)
                        @Reqid = 27					-- int

EXEC dbo.spBK_CheckBook @Mode = 'ApproveCheck',                    -- varchar(50)
                        @EmpCode = '23074577',               -- varchar(20)
                        @Reqid = 27						-- int

EXEC dbo.spBK_CheckBook @Mode = 'CancelCheck',                    -- varchar(50)
                        @EmpCode = '23074577',               -- varchar(20)
                        @Reqid = 27						-- int

SELECT * FROM dbo.CheckBookLogs
                 
SELECT * FROM dbo.CheckBook

ALTER TABLE dbo.CheckBook ADD BranchName  VARCHAR(50) NOT NULL DEFAULT ''

EXEC HPCOMMON..sp_GetUserCred @EmpName = N'karen ivy' -- nvarchar(50)
EXEC HPCOMMON..sp_GetUserCred @EmpName = N'rechelle' -- nvarchar(50)

CREATE TABLE [dbo].[CheckBookLogs]
(

[Reqid] [int] NULL,
[Bank] [varchar] (20)  DEFAULT (''),
[BankCode] [varchar] (20)  DEFAULT (''),
[AcctNo] [varchar] (20) DEFAULT (''),
[Branch] [varchar] (50) DEFAULT (''),
[Quantity] [int] NULL DEFAULT ((0)),
[DateRequested] [datetime] NULL DEFAULT (getdate()),
[RequestedBy] [varchar] (20) DEFAULT (''),
[Status] [varchar] (20) DEFAULT (''),
[LastUpdated] [datetime] NULL,
[UpdatedBy] [varchar] (20) DEFAULT (''),
[Active] [bit]  NULL DEFAULT ((1)),
[CheckStart] [varchar] (20) DEFAULT (''),
[CheckEnd] [varchar] (20) DEFAULT (''),
[AcctType] [varchar] (5) DEFAULT (''),
[CheckNum] [varchar] (20) DEFAULT (''),
LogId INT PRIMARY KEY IDENTITY(1,1),
Action VARCHAR(20),
EmpCode VARCHAR(20),
LogDate DATETIME DEFAULT GETDATE()
)

SELECT * FROM dbo.CheckBookLogs


EXEC dbo.spBK_DetailedItemCostBranchDept @SDate = '2023-9-22',    -- varchar(20)
                                         @EDate = '2023-10-22',    -- varchar(20)
                                         @Category = 108, -- varchar(20)
                                         @BrDept = '011'    -- varchar(20)

										 SELECT O.Warehouse FROM HPDI.dbo.OINM O


										 SELECT DATEADD(DAY, 1, CAST(GETDATE() AS DATE))
										 SELECT  DATEDIFF(DAY, 3, CAST(GETDATE() AS DATE))

--receive pieces
DECLARE @pieces INT = 16;
--starting check

DECLARE @checkstart VARCHAR(10) = (SELECT CheckEnd FROM dbo.CheckBook WHERE Reqid = (SELECT (MAX(Reqid)) FROM dbo.CheckBook));
--check structure
DECLARE @checkstruct VARCHAR(10) = '000000000';

DECLARE @checkend VARCHAR(10) = '';

SELECT (left(@checkstruct, LEN(@checkstruct) - LEN(CAST(@checkstart AS int))) + '' + 
		CAST(CAST(@checkstart AS int) AS VARCHAR(10))) AS [CheckStart], 
		(left(@checkstruct, LEN(@checkstruct) - LEN(CAST(@checkstart AS int))) + '' + 
		CAST(CAST(@checkstart AS int) + @pieces AS VARCHAR(10))) AS [CheckEnd]

set @checkstart = (SELECT (left(@checkstruct, LEN(@checkstruct) - LEN(CAST(@checkstart AS int))) + '' + CAST(CAST(@checkstart AS int) AS VARCHAR(10))))
set @checkend = (SELECT (left(@checkstruct, LEN(@checkstruct) - LEN(CAST(@checkstart AS int))) + '' + CAST(CAST(@checkstart + @pieces AS int) AS VARCHAR(10))))

EXEC dbo.spBK_CheckBook @Mode = 'CreateRequest',                    -- varchar(50)
                        @DateFrom = '2023-10-21',      -- date
                        @DateTo = '2023-10-21',        -- date
                        @Bank = '',                    -- varchar(20)
                        @BankCode = '00000',                -- varchar(20)
                        @AcctNo = '',                  -- varchar(20)
                        @Branch = '',                  -- varchar(20)
                        @Quantity = 100,                 -- int
                        @DateRequested = '2023-10-21', -- date
                        @RequestedBy = '',             -- varchar(20)
                        @Status = '',                  -- varchar(20)
                        @LastUpdated = '2023-10-21',   -- date
                        @UpdatedBy = '',               -- varchar(20)
                        @Active = 0,                   -- int
                        @Reqid = 0,                    -- int
                        @AcctType = '',                -- varchar(5)
                        @CheckNum = '',                -- varchar(20)
                        @EmpCode = ''                  -- varchar(20)

						SELECT * FROM dbo.CheckBook
						SELECT * FROM dbo.CheckBookLogs
						
						EXEC Bookkeeping.dbo.spBK_DetailedItemCostMain @SDate='5/1/2011',@EDate='5/31/2011', @Category='108'
						
						EXEC dbo.spBK_DetailedItemCostBranchDept @SDate = '2022-10-21',    -- varchar(20)
						                                         @EDate = '2023-10-21',    -- varchar(20)
						                                         @Category = 0, -- varchar(20)
						                                         @BrDept = 0    -- varchar(20)
						
						EXEC dbo.spBK_DetailedItemCostMain @SDate = '2023-10-21',  -- varchar(20)
						                                   @EDate = '2023-10-21',  -- varchar(20)
						                                   @Category = 0 -- smallint


						EXEC dbo.spBK_CheckBook @Mode = 'GetCheckBookList',                    -- varchar(50)
						                        @DateFrom = '2023-10-23',      -- date
						                        @DateTo = '2023-10-23',        -- date
						                        @Bank = '',                    -- varchar(20)
						                        @BankCode = '',                -- varchar(20)
						                        @AcctNo = '',                  -- varchar(20)
						                        @Branch = '',                  -- varchar(20)
						                        @Quantity = 0,                 -- int
						                        @DateRequested = '2023-10-23', -- date
						                        @RequestedBy = '',             -- varchar(20)
						                        @Status = '',                  -- varchar(20)
						                        @LastUpdated = '2023-10-23',   -- date
						                        @UpdatedBy = '',               -- varchar(20)
						                        @Active = 0,                   -- int
						                        @CheckStart = '',              -- varchar(20)
						                        @CheckEnd = '',                -- varchar(20)
						                        @Reqid = 0,                    -- int
						                        @AcctType = '',                -- varchar(5)
						                        @CheckNum = '',                -- varchar(20)
						                        @EmpCode = ''                  -- varchar(20)
						
						SELECT * FROM dbo.CheckBookLogs


						SELECT RIGHT('000000' + CAST(2139 AS VARCHAR(6)), 6) AS formatted_number
						
						
						SELECT * FROM dbo.CheckBook

						INSERT INTO dbo.CheckBook
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
						    CheckEnd,
						    AcctType,
						    CheckNum
						)
						VALUES
						(   'BDO', -- Bank - varchar(20)
						    '10000', -- BankCode - varchar(20)
						    '1234567899', -- AcctNo - varchar(20)
						    '011', -- Branch - varchar(50)
						    16, -- Quantity - int
						    GETDATE(), -- DateRequested - datetime
							'23074577', -- RequestedBy - varchar(20)
						    'Active', -- Status - varchar(20)
						    NULL,    -- LastUpdated - datetime
						    DEFAULT, -- UpdatedBy - varchar(20)
						    1, -- Active - bit
						    DEFAULT, -- CheckStart - varchar(20)
						    '00011', -- CheckEnd - varchar(20)
						    DEFAULT, -- AcctType - varchar(5)
						    DEFAULT  -- CheckNum - varchar(20)
						    )


							SELECT * FROM dbo.CheckBook
							
							--DECLARE @AcctNo VARCHAR(10) = '1234567890'
							DECLARE @AcctNo VARCHAR(10) = '1234567890'
							DECLARE @Quantity INT = 100
							DECLARE @Reqid INT = 1
							SELECT * FROM dbo.CheckBook
							SELECT Reqid, CheckEnd FROM dbo.CheckBook WHERE AcctNo = @AcctNo AND CheckEnd IS NULL OR CheckEnd = '' AND Reqid = (SELECT MAX(Reqid)-1 FROM dbo.CheckBook)
							SELECT Reqid, CheckEnd FROM dbo.CheckBook WHERE AcctNo = @AcctNo AND CheckEnd IS NULL OR CheckEnd = ''

							--SELECT Reqid, Quantity, AcctNo, CheckStart, CheckEnd FROM dbo.CheckBook

							DECLARE @PrevCheckEnd VARCHAR(10) = (SELECT CheckEnd FROM dbo.CheckBook	WHERE AcctNo = @AcctNo AND CheckEnd IS NULL OR CheckEnd = '' AND Reqid = (SELECT MAX(Reqid) FROM dbo.CheckBook))

							--check previous checkending if null or blank
							IF @PrevCheckEnd IS NULL OR @PrevCheckEnd = ''
							BEGIN
								--UPDATE dbo.CheckBook SET CheckEnd = (RIGHT('000000' + CAST(1 AS VARCHAR(6)), 6)), CheckStart = (RIGHT('000000' + CAST(@Quantity AS VARCHAR(6)), 6))
								SELECT * FROM dbo.CheckBook
							END

							
							EXEC dbo.spBK_CheckBook @Mode = 'CreateRequest',                    -- varchar(50)
							                        @DateFrom = '2023-10-25',      -- date
							                        @DateTo = '2023-10-25',        -- date
							                        @Bank = 'BDO',                    -- varchar(20)
							                        @BankCode = '10000',                -- varchar(20)
							                        @AcctNo = '123456789',                  -- varchar(20)
							                        @Branch = '',                  -- varchar(20)
							                        @Quantity = 0,                 -- int
							                        @DateRequested = '2023-10-25', -- date
							                        @RequestedBy = '',             -- varchar(20)
							                        @Status = '',                  -- varchar(20)
							                        @LastUpdated = '2023-10-25',   -- date
							                        @UpdatedBy = '',               -- varchar(20)
							                        @Active = 0,                   -- int
							                        @CheckStart = '',              -- varchar(20)
							                        @CheckEnd = '',                -- varchar(20)
							                        @Reqid = 0,                    -- int
							                        @AcctType = '',                -- varchar(5)
							                        @CheckNum = '',                -- varchar(20)
							                        @EmpCode = ''                  -- varchar(20)

													SELECT * FROM dbo.CheckBook
							
							DELETE FROM dbo.CheckBook
							

		DECLARE @BankCode VARCHAR(10) = '1173423'
		DECLARE @RequestedBy VARCHAR(20) = '23074577'
		DECLARE @EmpCode VARCHAR(20) = '23074577'
		DECLARE @Bank VARCHAR(20) = '1234567890'
		DECLARE @LastUpdated DATE = NULL
		DECLARE @UpdatedBy VARCHAR(20) = ''
		DECLARE @AcctType VARCHAR(20) = 'OA'
		DECLARE @CheckNum VARCHAR(20) = ''
		DECLARE @AcctNo VARCHAR(20) = '1234567890'
		DECLARE @Branch VARCHAR(20) = '011'
		DECLARE @Quantity INT = 10

		DECLARE @pieces INT = 16;
		--starting check
		--check for existing latest transaction bankcode as basis
		DECLARE @_checkstart VARCHAR(10) = (SELECT CheckEnd FROM dbo.CheckBook WHERE BankCode = @BankCode and Reqid = (SELECT (MAX(Reqid)) FROM dbo.CheckBook));
		--check structure
		DECLARE @checkstruct VARCHAR(10) = '000000000';
		
		DECLARE @_checkend VARCHAR(10) = '';

		--SELECT (left(@checkstruct, LEN(@checkstruct) - LEN(CAST(@_checkstart AS int))) + '' + 
		--		CAST(CAST(@checkstart AS int) AS VARCHAR(10))) AS [CheckStart], 
		--		(left(@checkstruct, LEN(@checkstruct) - LEN(CAST(@_checkstart AS int))) + '' + 
		--		CAST(CAST(@_checkstart AS int) + @pieces AS VARCHAR(10))) AS [CheckEnd]

		DECLARE @countSelected INT = (SELECT COUNT(Reqid) FROM dbo.CheckBook WHERE BankCode = @BankCode)

		IF @countSelected <= 0
			BEGIN
				set @_checkstart = RIGHT('0000000000' + CAST(1 AS VARCHAR(6)), 10)
			END
		
		set @_checkend = RIGHT('0000000000' + CAST(CAST(@_checkstart AS int) + @Quantity AS VARCHAR(6)), 10)

		INSERT INTO dbo.CheckBook
		(
		    Bank, BankCode, AcctNo, Branch, Quantity,
			DateRequested, RequestedBy, Status, LastUpdated, 
			UpdatedBy, Active, CheckStart, CheckEnd, AcctType, CheckNum
		)
		--creating logs/history
		OUTPUT Inserted.Reqid, Inserted.Bank, Inserted.BankCode, Inserted.AcctNo, Inserted.Branch,
				Inserted.Quantity, Inserted.DateRequested, Inserted.RequestedBy, Inserted.Status,
				Inserted.LastUpdated, Inserted.UpdatedBy, Inserted.Active,
				Inserted.CheckStart, Inserted.CheckEnd, Inserted.AcctType,
               Inserted.CheckNum, 'Insert', @EmpCode, GETDATE() INTO dbo.CheckBookLogs
		VALUES
		(   
			ISNULL(@Bank,''), ISNULL(@BankCode,''), ISNULL(@AcctNo,'') , 
		    @Branch, @Quantity, DEFAULT, @RequestedBy, 
		    (CASE WHEN @Quantity < 5 THEN 'Approved' ELSE 'Pending' END), 
		    @LastUpdated, @UpdatedBy, 1, ISNULL(@_checkstart, ''),
		    ISNULL(@_checkend, ''), @AcctType, @CheckNum
		)

		SELECT  FROM dbo.CheckBook





		 

		CREATE TABLE #list
		(
			id INT PRIMARY KEY IDENTITY(1,1),
			itempointer VARCHAR(20)
		)

		INSERT INTO #list
		SELECT 'a10000' UNION ALL
		SELECT 'a20000' UNION ALL
		SELECT 'a30000'	UNION ALL
		SELECT 'b10000' UNION ALL
		SELECT 'b20000' UNION ALL
		SELECT 'b30000' UNION ALL
		SELECT 'c10000' UNION ALL
		SELECT 'c20000' UNION ALL
		SELECT 'c30000'

		SELECT CHAR(ASCII(itempointer)) FROM #list

		DROP TABLE #list






		SELECT DateAdd(YEAR, 0, GETDATE());




