ALTER PROCEDURE dbo.spBK_CheckRequest
    @Mode varchar(20),
	@ChckId int = 0,
    @WhsCode varchar(5) = '',
    @Branch varchar(70) = '',
    @BankType varchar(70) = '',
    @ChckAcc varchar(12) = '',
    @SavAcc varchar(12) = '',
    @Quantity varchar(12) = 0,
    @Stat varchar(10) = '',
	@EmpCodeLog varchar(20) = NULL,
    @Createdby varchar(20) = '',
    @Modifiedby varchar(20) = NULL,
	@DateModified datetime = NULL,
	@StartDate DATETIME = NULL,
	@EndDate DATETIME = NULL,
	@BankCode VARCHAR(5) = NULL
AS
	BEGIN
		IF @Mode = 'GetRequest'--------------------------------------------------------------------------
		BEGIN
			--validation
			--check id cant be null
			--check id parameter
			--for fetching single row
			SELECT ChckId, DateRqstd, WhsCode, Branch, BankType, ChckAcc, Stat, 
					Createdby, DateCreated, Modifiedby, DateModified, quantity,	SavAcc, BankCode
			FROM dbo.CheckRequest 
			WHERE ChckId = @ChckId
		END

	IF @Mode = 'GetRequests'--------------------------------------------------------------------------
		BEGIN
			--validation
			--startdate parameter
			--enddate parameter
			--status parameter 
			--whscode parameter
			--if start and end date is blank generate all
			SELECT ChckId, DateRqstd, WhsCode, Branch, BankType, ChckAcc, Stat, Createdby,
					DateCreated, Modifiedby, DateModified, quantity, SavAcc, BankCode
			FROM dbo.CheckRequest 
			WHERE
				--check startdate if null and len is 0
				CAST(DateCreated AS DATE) >= CASE WHEN CAST(@StartDate AS DATE) IS NULL OR LEN(@StartDate) <= 0 THEN '2000-01-01' ELSE 
				CAST(@StartDate AS DATE) END 
				AND 
				--check enddate if null and len is 0
				CAST(DateCreated AS DATE) <= CASE WHEN CAST(@EndDate AS DATE) IS NULL OR LEN(@EndDate) <= 0 THEN GETDATE() ELSE 
				CAST(@EndDate AS DATE) END
				AND
				--check whscode/branch if null or len is 0
				--when null or blank accept all WhsCode/Branch
				WhsCode = CASE WHEN @WhsCode IS NULL OR LEN(@WhsCode) <= 0 OR @WhsCode = 'all' OR @WhsCode = '0' THEN WhsCode ELSE @WhsCode END
				AND
				--check branch if null or len is 0
				--when null or blank accept all Stat/Status
				Stat = CASE WHEN @Stat IS NULL OR LEN(@Stat) <= 0  OR @Stat = 'all' OR @Stat = '0' THEN Stat ELSE @Stat END
		END
	
	IF @Mode = 'CreateRequest'--------------------------------------------------------------------------
		BEGIN
		--validation
		--whscode/branch cant be blank
		--banktype can be blank
		--check account can be blank
		--savacc account can be blank
		--quantity must be at least 1
		--stat can be blank
		--createdby required
		INSERT INTO Bookkeeping.dbo.CheckRequest
			(DateRqstd, WhsCode, Branch, BankType, ChckAcc, SavAcc, Quantity, Stat, Createdby, DateCreated, BankCode)
		VALUES
		(   
			DEFAULT,
			@WhsCode, @Branch, ISNULL(@BankType, ''), ISNULL(@ChckAcc, ''), 
			ISNULL(@SavAcc,''), @Quantity, ISNULL(@Stat,'') , @Createdby,
			DEFAULT, @BankCode
		)
	   END

	IF @Mode = 'UpdateRequest'--------------------------------------------------------------------------

	   BEGIN
		   --validation
			--whscode/branch cant be blank
			--banktype can be blank
			--check account can be blank
			--savacc account can be blank
			--quantity must be at least 1
			--stat can be blank
			--modifiedby cant be null
			--quantity must be atleat 1

			--log check request update
			
			UPDATE dbo.CheckRequest SET
				WhsCode	= @WhsCode,
				Branch = @Branch,
				BankType = @BankType,
				ChckAcc = @ChckAcc,
				SavAcc = @SavAcc,
				Stat = @Stat,
				Modifiedby = @Modifiedby,
				DateModified = (CASE WHEN DateCreated IS NOT NULL THEN GETDATE() ELSE DateCreated END),
				quantity = @Quantity,
				BankCode = @BankCode
			WHERE ChckId = @ChckId
       END

	IF @Mode = 'DeleteRequest'--------------------------------------------------------------------------
	   BEGIN
			
			--log checkrequest update
			INSERT INTO dbo.CheckRequestLogs
			SELECT t0.ChckId, t0.DateRqstd, t0.WhsCode, t0.Branch, t0.BankType,
					t0.ChckAcc, t0.Stat, t0.Createdby, t0.DateCreated, t0.Modifiedby,
					t0.DateModified, t0.quantity, t0.SavAcc, 'Delete' AS Action,
					GETDATE() AS LogDate,
					@EmpCodeLog AS EmpCodeLog,
					t0.BankCode
			FROM dbo.CheckRequest t0 WHERE ChckId = @ChckId
			
			DELETE 
			FROM dbo.CheckRequest 
			WHERE ChckId = @ChckId

	   END
	END
GO
