CREATE PROCEDURE [dbo].[uspSTRebatePreviewSubmission]
@strStoreIdList NVARCHAR(MAX),
@dtmBeginningDate DATETIME,
@dtmEndingDate DATETIME,
@strStatusMsg NVARCHAR(1000) OUTPUT,
@intCountRows int OUTPUT
AS
BEGIN
	BEGIN TRY
		
		DECLARE @tempTable TABLE (
			--intTranslogId INT
			dtmDate DATETIME
			, dtmTime NVARCHAR(20)
			, strCashier NVARCHAR(150)
			, intTermMsgSN INT
			, intScanTransactionId INT
			, intDuration FLOAT
			, dblTrlQty DECIMAL(18, 2)
			, dblTrlUnitPrice DECIMAL(18, 2)
			, dblTrlLineTot DECIMAL(18, 2)
			, strTrlDept NVARCHAR(100)
			, strTrlDesc NVARCHAR(250)
			--, strTrpPaycode NVARCHAR(100)
			--, dblTrpAmt DECIMAL(18, 2)
		)

		----START Insert StoreId to table
		--DECLARE @strCharacter CHAR(1)
		--SET @strCharacter = ','

		--DECLARE @tblStoreIdList TABLE (intCount int,intStoreId int)

		--DECLARE @intCount int = 1

		--DECLARE @StartIndex INT, @EndIndex INT
 
		--SET @StartIndex = 1
		--IF SUBSTRING(@strStoreIdList, LEN(@strStoreIdList) - 1, LEN(@strStoreIdList)) <> @strCharacter
		--BEGIN
		--	 SET @strStoreIdList = @strStoreIdList + @strCharacter
		--END

		--WHILE CHARINDEX(@strCharacter, @strStoreIdList) > 0
		--BEGIN
		--	 SET @EndIndex = CHARINDEX(@strCharacter, @strStoreIdList)
           
		--	 INSERT INTO @tblStoreIdList
		--	 SELECT 
		--			@intCount,
		--			CAST(SUBSTRING(@strStoreIdList, @StartIndex, @EndIndex - 1) AS INT)
           
		--	 SET @intCount = @intCount + 1
		--	 SET @strStoreIdList = SUBSTRING(@strStoreIdList, @EndIndex + 1, LEN(@strStoreIdList))
		--END
		----END Insert StoreId to table

		----START Loop to all store Id
		--DECLARE @intStoreIdMin int, @intStoreIdMax int
		--SELECT @intStoreIdMin = MIN(intStoreId), @intStoreIdMax = MAX(intStoreId)
		--FROM @tblStoreIdList

		--WHILE(@intStoreIdMin <= @intStoreIdMax)
		--BEGIN
		--	INSERT INTO @tempTable
		--	SELECT DISTINCT 
		--	   TR.intTranslogId
  --             , TR.dtmDate
		--	   , CAST(CAST(TR.dtmDate AS TIME) AS NVARCHAR(10)) dtmTime
		--	   , (CASE WHEN TR.strCashier IS NULL THEN TR.strOriginalCashier ELSE TR.strCashier END) AS strCashier
		--		, TR.intTermMsgSN
		--		, TR.intScanTransactionId
		--		, TR.intDuration
		--		, TR.dblTrlUnitPrice
		--		, TR.dblTrlQty
		--		, TR.strTrlDept
		--		, TR.strTrlDesc
		--		, TR.strTrpPaycode
		--		, TR.dblTrpAmt
		--	FROM tblSTTranslogRebates TR
		--	JOIN tblSTStore ST ON ST.intStoreId = TR.intStoreId
		--	WHERE ST.intStoreId = @intStoreIdMin
		--	AND TR.ysnSubmitted = 0
		--	AND TR.strTrlDept COLLATE DATABASE_DEFAULT IN (SELECT strDepartment FROM dbo.fnSTRebateDepartment(@intStoreIdMin))
		--	AND CAST(TR.dtmDate as DATE) >= @dtmBeginningDate
		--	AND CAST(TR.dtmDate as DATE) <= @dtmEndingDate

		--	SET @intStoreIdMin = @intStoreIdMin + 1
		--END


		INSERT INTO @tempTable
			SELECT DISTINCT
			   --TR.intTranslogId
               TR.dtmDate
			   , CAST(CAST(TR.dtmDate AS TIME) AS NVARCHAR(10)) dtmTime
			   , (CASE WHEN TR.strCashier IS NULL THEN TR.strOriginalCashier ELSE TR.strCashier END) AS strCashier
				, TR.intTermMsgSN
				, TR.intScanTransactionId
				, TR.intDuration
				, TR.dblTrlQty
				, TR.dblTrlUnitPrice
				, TR.dblTrlLineTot
				, TR.strTrlDept
				, TR.strTrlDesc
				--, TR.strTrpPaycode
				--, TR.dblTrpAmt
			FROM tblSTTranslogRebates TR
			JOIN tblSTStore ST ON ST.intStoreId = TR.intStoreId
			WHERE ST.intStoreId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strStoreIdList)) --@intStoreIdMin
			AND TR.ysnSubmitted = 0
			AND TR.strTrlDept COLLATE DATABASE_DEFAULT IN (SELECT strDepartment FROM dbo.fnSTRebateDepartment(ST.intStoreId))
			AND CAST(TR.dtmDate as DATE) >= @dtmBeginningDate
			AND CAST(TR.dtmDate as DATE) <= @dtmEndingDate

		SELECT @intCountRows = COUNT(*) FROM @tempTable

		--This select will return to server side
		SELECT * FROM @tempTable
	END TRY

	BEGIN CATCH
		SET @intCountRows = 0
		SET @strStatusMsg = ERROR_MESSAGE()
	END CATCH
END