CREATE PROCEDURE [dbo].[uspSTGenerateBasketAnalysisData]
	 @intItemId				NVARCHAR(MAX)
	,@intStoreId			NVARCHAR(MAX)
	,@strComparison			NVARCHAR(MAX)
	,@dtmBeginDate			NVARCHAR(MAX)
	,@dtmEndDate			NVARCHAR(MAX)
	,@strDistrict			NVARCHAR(MAX)
	,@strRegion				NVARCHAR(MAX)
	,@intCategoryId			NVARCHAR(MAX)
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
ON CONVERT(NUMERIC(32, 0),CAST(strTrlUPC AS FLOAT)) = uom.intUpcCode
INNER JOIN tblICItem item
ON uom.intItemId = item.intItemId
INNER JOIN tblICCategory cat
ON item.intCategoryId = cat.intCategoryId'

--DEFAULT VALUES--
DECLARE @ValueMinDate NVARCHAR(MAX) = '1000-01-01 12:00:00'
DECLARE @ValueMaxDate NVARCHAR(MAX) = '9999-12-31 23:59:59'

--CHARACTHERS--
DECLARE @CharSpace NVARCHAR(MAX) = ' '
DECLARE @CharAnd NVARCHAR(MAX) = 'AND'
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
IF(ISNULL(@intItemId,0) != 0)
BEGIN
	SET @Where = @Where + @CharSpace + @CharConjunction + @FieldItem + @CharSpace + @CharEquals + @CharSpace  + @intItemId 
	SET @CharConjunction = @CharAnd
END

IF(ISNULL(@intCategoryId,0) != 0)
BEGIN
	SET @Where = @Where + @CharSpace + @CharConjunction + @CharSpace + @FieldCategory + @CharSpace + @CharEquals + @CharSpace  + @intCategoryId 
	SET @CharConjunction = @CharAnd
END

IF(ISNULL(@intStoreId,0) != 0)
BEGIN
	SET @Where = @Where + @CharSpace + @CharConjunction + @CharSpace + @FieldStore + @CharSpace + @CharEquals + @CharSpace  + @intStoreId 
	SET @CharConjunction = @CharAnd
END


--DATE--
IF(ISNULL(@dtmBeginDate,'') != '' AND ISNULL(@dtmEndDate,'') != '')
BEGIN
	IF(@dtmBeginDate != @ValueMinDate AND @dtmEndDate != @ValueMaxDate) 
	BEGIN
		SET @Where = @Where + @CharSpace + @CharConjunction + @CharSpace + @FieldDate + @CharSpace + @CharSpace + @CharBetween + @CharSpace + @CharStartMinDate + @CharSQuote + @dtmBeginDate + @CharSQuote + @CharEndMinDate + @CharSpace + @CharAnd + @CharSpace + @CharStartMaxDate + @CharSQuote + @dtmEndDate + @CharSQuote + @CharEndMaxDate
		SET @CharConjunction = @CharAnd
	END
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
	SET @Where = @CharWhere + @CharSpace + @Where
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



--[PHASE 3] > Insert data to staging table--
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
intRank = DENSE_RANK() OVER (ORDER BY COUNT(*) DESC),
intBasketTransaction = (SELECT COUNT(*) FROM @tblIDs),
intTimeSoldTogether = COUNT(*),
CAST(COUNT(*) AS NUMERIC(18,6)) / CAST((SELECT COUNT(*) FROM @tblIDs) AS NUMERIC(18,6)),
intItemId,
strItemNo,
strItemDescription,
intCategoryId,
strCategoryCode,
strCategoryDescription
FROM (
	SELECT 
	intTermMsgSN, 
	strTrlDesc, 
	strTrlUPC, 
	COUNT(*) AS cnt2,
	item.strItemNo,
	item.intItemId,
	item.strDescription as strItemDescription,
	cat.strCategoryCode,
	cat.intCategoryId,
	cat.strDescription as strCategoryDescription
	FROM tblSTTranslogRebates
	INNER JOIN tblICItemUOM uom
		ON CONVERT(NUMERIC(32, 0),CAST(strTrlUPC AS FLOAT)) = uom.intUpcCode
	INNER JOIN tblICItem item
		ON uom.intItemId = item.intItemId
	INNER JOIN tblICCategory cat
		ON item.intCategoryId = cat.intCategoryId
	WHERE intTermMsgSN in (SELECT DISTINCT intId FROM @tblIDs)
	GROUP BY 
	intTermMsgSN, 
	strTrlDesc, 
	strTrlUPC,
	item.strItemNo,
	item.intItemId,
	item.strDescription,
	cat.strCategoryCode,
	cat.intCategoryId,
	cat.strDescription
	) AS mytable
GROUP BY 
strTrlDesc, 
strTrlUPC,
strItemNo,
intItemId,
strItemDescription,
strCategoryCode,
intCategoryId,
strCategoryDescription
ORDER BY COUNT(*) DESC



--DEBUG CODE--

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
