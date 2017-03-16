CREATE PROCEDURE [dbo].[uspSTGenerateCSV]
@dtmBeginningDate datetime,
@dtmEndingDate datetime,
@strTableName nvarchar(200),
@strCSV NVARCHAR(MAX) OUTPUT
AS
BEGIN
    --SET NOCOUNT ON;
	
	--Add date range filter

	--START Insert data from tblSTTranslogRebates
	IF(@strTableName = 'tblSTstgRebatesPMMorris')
	BEGIN
		INSERT INTO dbo.tblSTstgRebatesPMMorris
(
	intManagementOrRetailNumber
	, strWeekEndingDate
	, strTransactionDate 
	, strTransactionTime
	, strTransactionIdCode 
	, strStoreNumber
	, strStoreName
	, strStoreAddress
	, strStoreCity
	, strStoreState
	, intStoreZipCode
	, strCategory
	, strManufacturerName
	, strSKUCode
	, strUpcCode
	, strSkuUpcDescription
	, strUnitOfMeasure
	, intQuantitySold
	, intConsumerUnits
	, strMultiPackIndicator
	, intMultiPackRequiredQuantity
	, dblMultiPackDiscountAmount
	, strRetailerFundedDIscountName
	, dblRetailerFundedDiscountAmount
	, strMFGDealNameONE
	, dblMFGDealDiscountAmountONE
	, strMFGDealNameTWO
	, dblMFGDealDiscountAmountTWO
	, strMFGDealNameTHREE
	, dblMFGDealDiscountAmountTHREE
	, dblFinalSalesPrice
)
SELECT
    x.intTermMsgSN
	--, x.RecordCount
	, x.dtmWeekEndingDate 
	, x.dtmTransactionDate
	, x.strTransactionTime
	, x.strTransactionIdCode 
	, x.strStoreNumber
	, x.strStoreName
	, x.strStoreAddress
	, x.strStoreCity
	, x.strStoreState
	, x.intStoreZipCode
	, x.strCategory
	, x.strManufacturerName
	, x.strSKUCode
	, x.strUpcCode
	, x.strSkuUpcDescription
	, x.strUnitOfMeasure
	, x.intQuantitySold
	, x.intConsumerUnits
	, x.strMultiPackIndicator
	, x.intMultiPackRequiredQuantity
	, x.dblMultiPackDiscountAmount
	, x.strRetailerFundedDiscountName
	, x.dblRetailerFundedDiscountAmount
	, x.strMFGDealNameONE
	, x.dblMFGDealDiscountAmountONE
	, x.strMFGDealNameTWO
	, x.dblMFGDealDiscountAmountTWO
	, x.strMFGDealNameTHREE
	, x.dblMFGDealDiscountAmountTHREE
	, x.dblFinalSalesPrice
	FROM
			(
			SELECT
				intTermMsgSN
				, FORMAT(CAST(dtmClosedTime AS DATE), 'yyyyMMdd') as dtmWeekEndingDate 
				, FORMAT(CAST(dtmDate AS DATE), 'yyyyMMdd') as dtmTransactionDate
				, FORMAT(dtmDate, 'hh:mm:ss') as strTransactionTime
				, intTermMsgSN as strTransactionIdCode
				, ST.intStoreNo as strStoreNumber
				, ST.strDescription as strStoreName
				, ST.strAddress as strStoreAddress
				, ST.strCity as strStoreCity
				, ST.strState as strStoreState
				, ST.strZipCode as intStoreZipCode
				, strTrlDept as strCategory
				, 'PM MORRIS' as strManufacturerName
				, '' as strSKUCode
				, strTrlUPC as strUpcCode
				, strTrlDesc as strSkuUpcDescription
				, 'PACK' as strUnitOfMeasure
				, CAST(CASE WHEN strTrpPaycode = 'CASH' THEN dblTrlQty ELSE 0 END as INT) as intQuantitySold
				, 1 as intConsumerUnits
				, CASE WHEN strTrpPaycode = 'CASH' AND dblTrlQty >= 2 THEN 'Y' ELSE 'N' END as strMultiPackIndicator
				, CASE WHEN strTrpPaycode = 'CASH' THEN dblTrlQty ELSE 0 END as intMultiPackRequiredQuantity
				, CASE WHEN strTrpPaycode = 'CASH' AND dblTrlQty >= 2 THEN 0.50 ELSE 0 END as dblMultiPackDiscountAmount
				, CASE WHEN strTrpPaycode = 'CASH' AND dblTrlQty >= 2 THEN 'Sale' ELSE '' END as strRetailerFundedDiscountName
				, CASE WHEN strTrpPaycode = 'CASH' AND dblTrlQty >= 2 THEN 0.50 ELSE 0 END as dblRetailerFundedDiscountAmount
				, CASE WHEN strTrpPaycode = 'COUPONS' THEN 'Coupon' ELSE '' END as strMFGDealNameONE
				, CASE WHEN strTrpPaycode = 'COUPONS' THEN 0.50 ELSE 0 END as dblMFGDealDiscountAmountONE
				, '' as strMFGDealNameTWO
				, 0 as dblMFGDealDiscountAmountTWO
				, '' as strMFGDealNameTHREE
				, 0 as dblMFGDealDiscountAmountTHREE
				, CASE WHEN strTrpPaycode = 'CASH' THEN dblTrlLineTot ELSE 0 END as dblFinalSalesPrice
			FROM dbo.tblSTTranslogRebates TR
			JOIN dbo.tblSTStore ST ON ST.intStoreId = TR.intStoreId
			) x
	END

	--ELSE IF(@strTableName = 'tblSTTransLogPMReynolds')
	--BEGIN

	--END
	--END Insert data from tblSTTranslogRebates

	--Convert table to CSV
	--Get Column names

	DECLARE @tblColumnTemp TABLE (strTableName nvarchar(50), strColumnName nvarchar(50), intOrdinalPosition int, strIsNullable nvarchar(10), strDataType nvarchar(50))

	INSERT INTO @tblColumnTemp
	(
		strTableName
		, strColumnName
		, intOrdinalPosition
		, strIsNullable
		, strDataType
	)
	SELECT TABLE_NAME
	       , COLUMN_NAME
		   , ORDINAL_POSITION
		   , IS_NULLABLE
		   , DATA_TYPE
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = @strTableName

	DECLARE @intMin int, @intMax int

	SELECT @intMin = MIN(intOrdinalPosition), @intMax = MAX(intOrdinalPosition)
	FROM @tblColumnTemp

	SET @strCSV = ''

	DECLARE @intLoopCount int = 0

	DECLARE @strTableNameVal NVARCHAR(50), @strColumnNameVal NVARCHAR(50), @intOrdinalPositionVal int, @strIsNullableVal NVARCHAR(10), @strDataTypeVal NVARCHAR(50)

	WHILE(@intMin <= @intMax)
	BEGIN
		IF EXISTS (SELECT * FROM @tblColumnTemp WHERE intOrdinalPosition = @intMin AND intOrdinalPosition <> 1 AND strIsNullable <> 'NO')
		BEGIN
			SELECT @strTableNameVal = strTableName, @strColumnNameVal = strColumnName, @intOrdinalPositionVal = intOrdinalPosition, @strIsNullableVal = strIsNullable, @strDataTypeVal = strDataType FROM @tblColumnTemp WHERE intOrdinalPosition = @intMin

			IF(@intLoopCount = 0)
			BEGIN
				SET @strCSV = @strCSV + RIGHT(@strColumnNameVal, LEN(@strColumnNameVal) - 3)
			END
			ELSE IF(@intLoopCount >= 1)
			BEGIN
				SET @strCSV = @strCSV + ', ' + RIGHT(@strColumnNameVal, LEN(@strColumnNameVal) - 3)
			END

			SET @intLoopCount = @intLoopCount + 1
		END

		SET @intMin = @intMin + 1
	END


	--GET values
	SELECT @intMin = MIN(intPMMId), @intMax = MAX(intPMMId)
	FROM dbo.tblSTstgRebatesPMMorris

	SET @intLoopCount = 0

	DECLARE @intManagementOrRetailNumber INT
			, @strWeekEndingDate nvarchar(20)
			, @strTransactionDate nvarchar(20)
			, @strTransactionTime nvarchar(10)
			, @strTransactionIdCode nvarchar(50)
			, @strStoreNumber nvarchar(10)
			, @strStoreName nvarchar(50)
			, @strStoreAddress nvarchar(60)
			, @strStoreCity nvarchar(50)
			, @strStoreState nvarchar(2)
			, @intStoreZipCode int
			, @strCategory nvarchar(20)
			, @strManufacturerName nvarchar(20)
			, @strSKUCode nvarchar(50)
			, @strUpcCode nvarchar(14)
			, @strSkuUpcDescription nvarchar(50)
			, @strUnitOfMeasure nvarchar(20)
			, @intQuantitySold numeric(10, 2)
			, @intConsumerUnits int
			, @strMultiPackIndicator nvarchar(1)
			, @intMultiPackRequiredQuantity int
			, @dblMultiPackDiscountAmount numeric(10, 2)
			, @strRetailerFundedDIscountName nvarchar(20)
			, @dblRetailerFundedDiscountAmount numeric(10, 2)
			, @strMFGDealNameONE nvarchar(20)
			, @dblMFGDealDiscountAmountONE numeric(10, 2)
			, @strMFGDealNameTWO nvarchar(20)
			, @dblMFGDealDiscountAmountTWO numeric(10, 2)
			, @strMFGDealNameTHREE nvarchar(20)
			, @dblMFGDealDiscountAmountTHREE numeric(10, 2)
			, @dblFinalSalesPrice numeric(10, 2)

	WHILE(@intMin <= @intMax)
	BEGIN
		IF EXISTS (SELECT * FROM dbo.tblSTstgRebatesPMMorris WHERE intPMMId = @intMin)
		BEGIN
			SELECT @intManagementOrRetailNumber = intManagementOrRetailNumber
				   , @strWeekEndingDate = CAST(strWeekEndingDate as NVARCHAR(20))
				   , @strTransactionDate = CAST(strTransactionDate as NVARCHAR(20))
				   , @strTransactionTime = strTransactionTime
				   , @strTransactionIdCode = strTransactionIdCode
				   , @strStoreNumber = strStoreNumber
				   , @strStoreName = strStoreName
				   , @strStoreAddress = strStoreAddress
				   , @strStoreCity = strStoreCity
				   , @strStoreState = strStoreState
				   , @intStoreZipCode = intStoreZipCode
				   , @strCategory = strCategory
				   , @strManufacturerName = strManufacturerName
				   , @strSKUCode = strSKUCode
				   , @strUpcCode = strUpcCode
				   , @strSkuUpcDescription = strSkuUpcDescription
				   , @strUnitOfMeasure = strUnitOfMeasure
				   , @intQuantitySold = intQuantitySold
				   , @intConsumerUnits = intConsumerUnits
				   , @strMultiPackIndicator = strMultiPackIndicator
				   , @intMultiPackRequiredQuantity = intMultiPackRequiredQuantity
				   , @dblMultiPackDiscountAmount = dblMultiPackDiscountAmount
				   , @strRetailerFundedDIscountName = strRetailerFundedDIscountName
				   , @dblRetailerFundedDiscountAmount = dblRetailerFundedDiscountAmount
				   , @strMFGDealNameONE = strMFGDealNameONE
				   , @dblMFGDealDiscountAmountONE = dblMFGDealDiscountAmountONE
				   , @strMFGDealNameTWO = strMFGDealNameTWO
				   , @dblMFGDealDiscountAmountTWO = dblMFGDealDiscountAmountTWO
				   , @strMFGDealNameTHREE = strMFGDealNameTHREE
				   , @dblMFGDealDiscountAmountTHREE = dblMFGDealDiscountAmountTHREE
				   , @dblFinalSalesPrice = dblFinalSalesPrice
			FROM dbo.tblSTstgRebatesPMMorris WHERE intPMMId = @intMin

			--IF(@intLoopCount = 0)
			--BEGIN
				
			--END
			--ELSE IF(@intLoopCount >= 1)
			--BEGIN
			--	SET @strCSV = @strCSV + ', ' + @strColumnNameVal
			--END

			--Removed CAST(@intManagementOrRetailNumber as NVARCHAR(20))
			--For now intManagementOrRetailNumber will be empty
			SET @strCSV = @strCSV + CHAR(13) + '' + ', ' + CAST(REPLACE(@strWeekEndingDate, '-', '') as NVARCHAR(20)) + ', ' + CAST(REPLACE(@strTransactionDate, '-', '') as NVARCHAR(50))
			                            + ', ' + @strTransactionTime + ', ' + @strTransactionIdCode + ', ' + @strStoreNumber + ', ' + @strStoreName + ', ' + @strStoreAddress + ', ' + @strStoreCity + ', ' + @strStoreState
									    + ', ' + CAST(@intStoreZipCode as NVARCHAR(50)) + ', ' + @strCategory + ', ' + @strManufacturerName + ', ' + @strSKUCode + ', ' + @strUpcCode + ', ' + @strSkuUpcDescription 
										+ ', ' + @strUnitOfMeasure + ', ' + CAST(@intQuantitySold as NVARCHAR(50)) + ', ' + CAST(@intConsumerUnits as NVARCHAR(50)) + ', ' + @strMultiPackIndicator 
										+ ', ' + CAST(@intMultiPackRequiredQuantity as NVARCHAR(50)) + ', ' + CAST(@dblMultiPackDiscountAmount as NVARCHAR(50)) + ', ' + @strRetailerFundedDIscountName 
										+ ', ' + CAST(@dblRetailerFundedDiscountAmount as NVARCHAR(50)) + ', ' + @strMFGDealNameONE + ', ' + CAST(@dblMFGDealDiscountAmountONE as NVARCHAR(50)) + ', ' + @strMFGDealNameTWO
									    + ', ' + CAST(@dblMFGDealDiscountAmountTWO as NVARCHAR(50)) + ', ' + @strMFGDealNameTHREE + ', ' + CAST(@dblMFGDealDiscountAmountTHREE as NVARCHAR(50)) + ', ' + CAST(@dblFinalSalesPrice as NVARCHAR(50))



			SET @intLoopCount = @intLoopCount + 1
		END

		SET @intMin = @intMin + 1
	END

	DECLARE @SQL NVARCHAR(MAX)
	SET @SQL = 'DELETE FROM ' + @strTableName
	EXEC sp_executesql @SQL
END