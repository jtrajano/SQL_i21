CREATE PROCEDURE [dbo].[uspSTGenerateBasketAnalysisData]
	 @intItemId				NVARCHAR(MAX)
	,@intStoreId			NVARCHAR(MAX)
	,@strComparison			NVARCHAR(MAX)
	,@dtmBeginDate			NVARCHAR(MAX)
	,@dtmEndDate			NVARCHAR(MAX)
	,@strDistrict			NVARCHAR(MAX) = ''
	,@strRegion				NVARCHAR(MAX) = ''
	,@intCategoryId			NVARCHAR(MAX)
	,@intBasketCategoryId	NVARCHAR(MAX)
	,@intUserId				INT
AS


	--SELECT @intItemId			
	--SELECT @intStoreId			
	--SELECT @strComparison
	--SELECT @dtmBeginDate		
	--SELECT @dtmEndDate			
	--SELECT @strDistrict		
	--SELECT @strRegion			
	--SELECT @intCategoryId		
	--SELECT @intUserId			

	



--DEBUG VALUES--
--DECLARE @strItemId NVARCHAR(MAX) = '00028200003843'
--DECLARE @dtmDateFrom NVARCHAR(MAX) = '2017-03-01 09:17:14.000' 
--DECLARE @dtmDateTo NVARCHAR(MAX) =  '2017-03-30 09:17:14.000'
--DECLARE @strDistrict NVARCHAR(MAX) = ''
--DECLARE @strRegion NVARCHAR(MAX) = ''
--DECLARE @strCategory NVARCHAR(MAX) = ''


--[PHASE 1] > Compose parameters--

--WHERE CLAUSE--
DECLARE @Where NVARCHAR(MAX) = ''

--BASE QUERY--
DECLARE @BaseQuery NVARCHAR(MAX) = 'SELECT DISTINCT intTermMsgSN
FROM tblSTTranslogRebates AS trans
INNER JOIN tblSTStore AS store
ON trans.intStoreId = store.intStoreId
INNER JOIN tblICItemUOM uom
ON CAST(strTrlUPCwithoutCheckDigit AS FLOAT) = uom.intUpcCode
INNER JOIN tblICItem item
ON uom.intItemId = item.intItemId
INNER JOIN tblICCategory cat
ON item.intCategoryId = cat.intCategoryId
WHERE ((strTransRollback IS NULL AND strTransFuelPrepay IS NULL AND strTransType NOT LIKE ''%suspended%'' AND strTransType NOT LIKE ''%void%'' AND strTrLineType<>''preFuel'' AND strTransFuelPrepayCompletion IS NULL) 
OR     (strTransRollback IS NULL AND strTransFuelPrepay IS NULL AND strTransType NOT LIKE ''%suspended%'' AND strTransType NOT LIKE ''%void%'' AND strTrLineType=''postFuel'' AND strTransFuelPrepayCompletion IS NOT NULL)) '

--DEFAULT VALUES--
DECLARE @ValueMinDate NVARCHAR(MAX) = '1000-01-01 12:00:00'
DECLARE @ValueMaxDate NVARCHAR(MAX) = '9999-12-31 23:59:59'

DECLARE @ValueItem NVARCHAR(MAX) = 'Item' 
DECLARE @ValueCategory NVARCHAR(MAX) = 'Category' 

--CHARACTHERS--
DECLARE @CharSpace NVARCHAR(MAX) = ' '
DECLARE @CharAnd NVARCHAR(MAX) = 'AND'
DECLARE @CharOr NVARCHAR(MAX) = 'OR'
DECLARE @CharSQuote NVARCHAR(MAX) = ''''
DECLARE @CharOPar NVARCHAR(MAX) = '('
DECLARE @CharCPar NVARCHAR(MAX) = ')'
DECLARE @CharEquals NVARCHAR(MAX) = '='
DECLARE @CharWhere NVARCHAR(MAX) = 'WHERE'
DECLARE @CharBetween NVARCHAR(MAX) = 'BETWEEN'

--CONDITIONAL\METHOD CHARATERS--
DECLARE @CharConjunction NVARCHAR(MAX) = ''
DECLARE @CharStartMinDate NVARCHAR(MAX) = 'DATEADD(dd, DATEDIFF(dd, 0,'
DECLARE @CharEndMinDate NVARCHAR(MAX) = '), 0)'

DECLARE @CharStartMaxDate NVARCHAR(MAX) = 'DATEADD(S, -1, DATEADD(D, 1, (DATEADD(dd, DATEDIFF(dd, 0,'
DECLARE @CharEndMaxDate NVARCHAR(MAX) = '), 0))))'

--FIELDS MAPPING--
DECLARE @FieldItem NVARCHAR(MAX) = 'item.intItemId'
DECLARE @FieldDate NVARCHAR(MAX) = 'dtmDate'
DECLARE @FieldCategory NVARCHAR(MAX) = 'cat.intCategoryId'
DECLARE @FieldStore NVARCHAR(MAX) = 'store.intStoreId'
DECLARE @FieldTranId NVARCHAR(MAX) = 'intTermMsgSN'
DECLARE @FieldRegion NVARCHAR(MAX) = 'strRegion'
DECLARE @FieldDistrict NVARCHAR(MAX) = 'strDistrict'


--INT--
IF(@strComparison = @ValueItem)
BEGIN
	IF(ISNULL(@intItemId,0) != 0)
	BEGIN
		SET @Where = @Where + @CharSpace + @CharConjunction + @FieldItem + @CharSpace + @CharEquals + @CharSpace  + @intItemId 
		SET @CharConjunction = @CharAnd
	END
END

IF(@strComparison = @ValueCategory)
BEGIN
	IF(ISNULL(@intBasketCategoryId,0) != 0)
	BEGIN
		SET @Where = @Where + @CharSpace + @CharConjunction + @FieldCategory + @CharSpace + @CharEquals + @CharSpace  + @intBasketCategoryId 
		SET @CharConjunction = @CharAnd
	END
END

--IF(ISNULL(@intCategoryId,0) != 0)
--BEGIN
--	SET @Where = @Where + @CharSpace + @CharConjunction + @CharSpace + @FieldCategory + @CharSpace + @CharEquals + @CharSpace  + @intCategoryId 
--	SET @CharConjunction = @CharAnd
--END

IF(ISNULL(@intStoreId,0) != 0)
BEGIN
	SET @Where = @Where + @CharSpace + @CharConjunction + @CharSpace + @FieldStore + @CharSpace + @CharEquals + @CharSpace  + @intStoreId 
	SET @CharConjunction = @CharAnd
END


--DATE--
IF(ISNULL(@dtmBeginDate,'') != '' AND ISNULL(@dtmEndDate,'') != '')
BEGIN
	SET @Where = @Where + @CharSpace + @CharConjunction + @CharSpace + @FieldDate + @CharSpace + @CharSpace + @CharBetween + @CharSpace + @CharStartMinDate + @CharSQuote + @dtmBeginDate + @CharSQuote + @CharEndMinDate + @CharSpace + @CharAnd + @CharSpace + @CharStartMaxDate + @CharSQuote + @dtmEndDate + @CharSQuote + @CharEndMaxDate
	SET @CharConjunction = @CharAnd
END


--STRING--
IF(ISNULL(@strDistrict,'') != '')
BEGIN
	SET @Where = @Where + @CharSpace + @CharConjunction + @CharSpace + @FieldDistrict + @CharSpace + @CharEquals + @CharSpace + @CharSQuote + @strDistrict + @CharSQuote
	SET @CharConjunction = @CharAnd
END

IF(ISNULL(@strRegion,'') != '')
BEGIN
	SET @Where = @Where + @CharSpace + @CharConjunction + @CharSpace + @FieldRegion + @CharSpace + @CharEquals + @CharSpace + @CharSQuote + @strRegion + @CharSQuote
	SET @CharConjunction = @CharAnd
END





IF(ISNULL(@Where,'') != '')
BEGIN
	SET @Where = @CharAnd + @CharSpace + @Where
END


SET @BaseQuery = @BaseQuery + @CharSpace + @Where


--[PHASE 2] 
-- > Get transaction Ids
-- > Apply filtering


--TEMP TABLE--
DECLARE @tblIDs TABLE ( intId INT ) 

--INSERT DATA FROM BASE QUERY--
INSERT INTO @tblIDs
EXEC(@BaseQuery)


DECLARE @count INT
SELECT @count = COUNT(1) FROM @tblIDs


--[PHASE 3] > Insert data to staging table--
DECLARE @tblSTGroupByUPC TABLE
(
	 intTimeSoldTogether	INT
	,strTrlDesc 			NVARCHAR(MAX)
	,strTrlUPC				NVARCHAR(MAX)
)
DECLARE @tblSTGroupByBasket TABLE
(
	 intTermMsgSN	INT
	,strTrlDesc 	NVARCHAR(MAX)
	,strTrlUPC		NVARCHAR(MAX)
)


INSERT INTO @tblSTGroupByBasket
(
	 intTermMsgSN	
	,strTrlDesc 	
	,strTrlUPC		
)
SELECT 
	intTermMsgSN, 
	strTrlDesc, 
	strTrlUPC
FROM tblSTTranslogRebates
WHERE intTermMsgSN in (SELECT DISTINCT intId FROM @tblIDs)
GROUP BY 
	intTermMsgSN, 
	strTrlDesc, 
	strTrlUPC



INSERT INTO @tblSTGroupByUPC
(
	 strTrlDesc 	
	,strTrlUPC
	,intTimeSoldTogether		
)
SELECT 
	strTrlDesc, 
	strTrlUPC,
	COUNT(*)
FROM @tblSTGroupByBasket
GROUP BY 
	strTrlDesc, 
	strTrlUPC


--FILTER BY CATEGORY--
IF(ISNULL(@intCategoryId,0) != 0)
BEGIN
	IF(@strComparison = @ValueItem)
	BEGIN
		--***DEBUG CODE***--
		--SELECT *
		--FROM @tblSTGroupByUPC 
		--INNER JOIN tblICItemUOM uom
		--	ON CONVERT(NUMERIC(32, 0),CAST(strTrlUPC AS FLOAT)) = uom.intUpcCode
		--INNER JOIN tblICItem item
		--	ON uom.intItemId = item.intItemId
		--INNER JOIN tblICCategory cat
		--	ON item.intCategoryId = cat.intCategoryId
		--WHERE cat.intCategoryId != @intCategoryId AND item.intItemId != @intItemId
		--***DEBUG CODE***--

		DELETE @tblSTGroupByUPC 
		FROM @tblSTGroupByUPC 
		INNER JOIN tblICItemUOM uom
			ON CONVERT(NUMERIC(32, 0),CAST(strTrlUPC AS FLOAT)) = uom.intUpcCode
		INNER JOIN tblICItem item
			ON uom.intItemId = item.intItemId
		INNER JOIN tblICCategory cat
			ON item.intCategoryId = cat.intCategoryId
		WHERE cat.intCategoryId != @intCategoryId AND item.intItemId != @intItemId
	END

	IF(@strComparison = @ValueCategory)
	BEGIN
		--***DEBUG CODE***--
		--SELECT *
		--FROM @tblSTGroupByUPC 
		--INNER JOIN tblICItemUOM uom
		--	ON CONVERT(NUMERIC(32, 0),CAST(strTrlUPC AS FLOAT)) = uom.intUpcCode
		--INNER JOIN tblICItem item
		--	ON uom.intItemId = item.intItemId
		--INNER JOIN tblICCategory cat
		--	ON item.intCategoryId = cat.intCategoryId
		--WHERE cat.intCategoryId != @intCategoryId AND item.intCategoryId != @intBasketCategoryId
		--***DEBUG CODE***--

		DELETE @tblSTGroupByUPC 
		FROM @tblSTGroupByUPC 
		INNER JOIN tblICItemUOM uom
			ON CONVERT(NUMERIC(32, 0),CAST(strTrlUPC AS FLOAT)) = uom.intUpcCode
		INNER JOIN tblICItem item
			ON uom.intItemId = item.intItemId
		INNER JOIN tblICCategory cat
			ON item.intCategoryId = cat.intCategoryId
		WHERE cat.intCategoryId != @intCategoryId AND item.intCategoryId != @intBasketCategoryId
	END
	

END

	
DELETE FROM tblSTBasketAnalysisStagingTable WHERE intUserId  = @intUserId
INSERT INTO tblSTBasketAnalysisStagingTable
(
	 intUserId
	,strDescription
	,strItemUPC
	,intRank
	,intTotalBasket
	,intTotalItem
	,dblBasketAverage
	,intItemId
	,strItemId
	,strItemDescription
	,intCategoryId
	,strCategoryId
	,strCategoryDescription
)
SELECT 
@intUserId,
strTrlDesc, 
strTrlUPC, 
intRank = DENSE_RANK() OVER (ORDER BY intTimeSoldTogether DESC),
intBasketTransaction = @count,
intTimeSoldTogether,
(CAST(intTimeSoldTogether AS NUMERIC(18,6)) / CAST(@count AS NUMERIC(18,6))) * 100,
item.intItemId,
strItemNo,
item.strDescription,
cat.intCategoryId,
strCategoryCode,
cat.strDescription
FROM @tblSTGroupByUPC
INNER JOIN tblICItemUOM uom
	ON CONVERT(NUMERIC(32, 0),CAST(strTrlUPC AS FLOAT)) = uom.intUpcCode
INNER JOIN tblICItem item
	ON uom.intItemId = item.intItemId
INNER JOIN tblICCategory cat
	ON item.intCategoryId = cat.intCategoryId









--DEBUG CODE--

--code block 1--

--DELETE FROM tblSTBasketAnalysisStagingTable WHERE intUserId  = @intUserId
--INSERT INTO tblSTBasketAnalysisStagingTable
--(
--	 intUserId
--	,strDescription
--	,strItemUPC
--	,intRank
--	,intTotalBasket
--	,intTotalItem
--	,dblBasketAverage
--	,intItemId
--	,strItemId
--	,strItemDescription
--	,intCategoryId
--	,strCategoryId
--	,strCategoryDescription

--)
--SELECT 
--@intUserId,
--strTrlDesc, 
--strTrlUPC, 
--intRank = DENSE_RANK() OVER (ORDER BY COUNT(*) DESC),
--intBasketTransaction = @count,
--intTimeSoldTogether = COUNT(*),
--CAST(COUNT(*) AS NUMERIC(18,6)) / CAST(@count AS NUMERIC(18,6)),
--intItemId,
--strItemNo,
--strItemDescription,
--intCategoryId,
--strCategoryCode,
--strCategoryDescription
--FROM (
--	SELECT 
--	intTermMsgSN, 
--	strTrlDesc, 
--	strTrlUPC, 
--	COUNT(*) AS cnt2,
--	item.strItemNo,
--	item.intItemId,
--	item.strDescription as strItemDescription,
--	cat.strCategoryCode,
--	cat.intCategoryId,
--	cat.strDescription as strCategoryDescription
--	FROM tblSTTranslogRebates
--	INNER JOIN tblICItemUOM uom
--		ON CONVERT(NUMERIC(32, 0),CAST(strTrlUPC AS FLOAT)) = uom.intUpcCode
--	INNER JOIN tblICItem item
--		ON uom.intItemId = item.intItemId
--	INNER JOIN tblICCategory cat
--		ON item.intCategoryId = cat.intCategoryId
--	WHERE intTermMsgSN in (SELECT DISTINCT intId FROM @tblIDs)
--	GROUP BY 
--	intTermMsgSN, 
--	strTrlDesc, 
--	strTrlUPC,
--	item.strItemNo,
--	item.intItemId,
--	item.strDescription,
--	cat.strCategoryCode,
--	cat.intCategoryId,
--	cat.strDescription
--	) AS mytable
--GROUP BY 
--strTrlDesc, 
--strTrlUPC,
--strItemNo,
--intItemId,
--strItemDescription,
--strCategoryCode,
--intCategoryId,
--strCategoryDescription
--ORDER BY COUNT(*) DESC

-- code block 2 -- 

--SELECT 
--strTrlDesc, 
--strTrlUPC, 
--intRank = DENSE_RANK() OVER (ORDER BY COUNT(*) DESC),
--intBasketTransaction = (SELECT COUNT(*) FROM @tblIDs),
--intTimeSoldTogether = COUNT(*),
--COUNT(*) / (SELECT COUNT(*) FROM @tblIDs)
--FROM (
--	SELECT 
--	intTermMsgSN, 
--	strTrlDesc, 
--	strTrlUPC, 
--	COUNT(*) AS cnt2
--	FROM tblSTTranslogRebates
--	WHERE intTermMsgSN in (SELECT DISTINCT intId FROM @tblIDs)
--	GROUP BY 
--	intTermMsgSN, 
--	strTrlDesc, 
--	strTrlUPC
--	) AS mytable
--GROUP BY 
--strTrlDesc, 
--strTrlUPC
--ORDER BY COUNT(*) DESC
