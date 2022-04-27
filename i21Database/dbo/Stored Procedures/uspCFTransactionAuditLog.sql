CREATE PROCEDURE [dbo].[uspCFTransactionAuditLog]
	@processName					AS NVARCHAR(100),
	@keyValue						AS NVARCHAR(MAX),
	@entityId						AS INT,
	@action							AS NVARCHAR(50),
	@dblFromOriginalTotalPrice	    NVARCHAR(MAX) = 0.000000,
	@dblFromOriginalGrossPrice		NVARCHAR(MAX) = 0.000000,
	@dblFromOriginalNetPrice		NVARCHAR(MAX) = 0.000000,
	@dblFromCalculatedTotalPrice	NVARCHAR(MAX) = 0.000000,
	@dblFromCalculatedGrossPrice	NVARCHAR(MAX) = 0.000000,
	@dblFromCalculatedNetPrice		NVARCHAR(MAX) = 0.000000,
	@dblFromCalculatedTotalTax		NVARCHAR(MAX) = 0.000000,
	@dblFromOriginalTotalTax		NVARCHAR(MAX) = 0.000000,
	@strFromPriceMethod				NVARCHAR(MAX) = '',
	@strFromPriceBasis				NVARCHAR(MAX) = '',
	@strFromPriceProfileId			NVARCHAR(MAX) = '',
	@strFromPriceIndexId			NVARCHAR(MAX) = ''

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

--=====================================================================================================================================
-- 	VARIABLE DECLARATIONS
---------------------------------------------------------------------------------------------------------------------------------------

DECLARE @children AS NVARCHAR(MAX) = ''
DECLARE @jsonData AS NVARCHAR(MAX) = ''
DECLARE @singleValue AS NVARCHAR(MAX) = ''
DECLARE @count AS INT = 0

DECLARE @screenName NVARCHAR(MAX) =  'CardFueling.view.Transaction'

--=====================================================================================================================================
-- 	DECLARE TEMPORARY TABLES
---------------------------------------------------------------------------------------------------------------------------------------
--CREATE TABLE #tmpCardNumbers (
--	[strCardNumber] NVARCHAR(150)
--);



--=====================================================================================================================================
-- 	INSERT AUDIT ENTRY
---------------------------------------------------------------------------------------------------------------------------------------


--INSERT INTO #tmpCardNumbers
--SELECT Record FROM [fnCFSplitString](@cardnumbers,'|^|')
--SELECT @count = Count(*) FROM #tmpCardNumbers


--=====================================================================================================================================
-- 	COMPOSE JSON DATA
---------------------------------------------------------------------------------------------------------------------------------------


--DECLARE @counter INT
--SET @counter = 0
--WHILE EXISTS (SELECT TOP (1) 1 FROM #tmpCardNumbers)
--BEGIN

--	SET @counter += 1
--	SELECT TOP 1 @singleValue = [strCardNumber] FROM #tmpCardNumbers

--	SET @children += '{' + '"change":' +'"'+ @singleValue +'"'+ ', "iconCls": "small-gear"}'
--	IF(@counter != @count)
--	BEGIN
--	SET @children += ','
--	END

--	DELETE TOP (1) FROM #tmpCardNumbers where strCardNumber = @singleValue
--END

--DROP TABLE #tmpCardNumbers

DECLARE @tblCFTransactionToLog TABLE 
(
	 dblOriginalTotalPrice				NUMERIC(18,6)
	,dblCalculatedTotalPrice			NUMERIC(18,6)
	,dblOriginalGrossPrice				NUMERIC(18,6)
	,dblCalculatedGrossPrice			NUMERIC(18,6)
	,dblCalculatedNetPrice				NUMERIC(18,6)
	,dblOriginalNetPrice				NUMERIC(18,6)
	,dblCalculatedPumpPrice				NUMERIC(18,6)
	,dblOriginalPumpPrice				NUMERIC(18,6)
	,dblCalculatedTotalTax				NUMERIC(18,6)
	,dblOriginalTotalTax				NUMERIC(18,6)
	,strPriceMethod						NVARCHAR(MAX)
	,strPriceBasis						NVARCHAR(MAX)
	,strPriceProfileId					NVARCHAR(MAX)
	,strPriceIndexId					NVARCHAR(MAX)
)

DECLARE @dynamicSQL NVARCHAR(MAX)
SET @dynamicSQL = '

SELECT TOP 1
 dblOriginalTotalPrice	  =		ISNULL(dblOriginalTotalPrice,0)		
,dblCalculatedTotalPrice  =		ISNULL(dblCalculatedTotalPrice,0)
,dblOriginalGrossPrice	  =		ISNULL(dblOriginalGrossPrice,0)
,dblCalculatedGrossPrice  =		ISNULL(dblCalculatedGrossPrice,0)
,dblCalculatedNetPrice	  =		ISNULL(dblCalculatedNetPrice,0)
,dblOriginalNetPrice	  =		ISNULL(dblOriginalNetPrice,0)
,dblCalculatedPumpPrice	  =		ISNULL(dblCalculatedPumpPrice,0)
,dblOriginalPumpPrice	  =		ISNULL(dblOriginalPumpPrice,0)
,dblCalculatedTotalTax	  =		ISNULL(dblCalculatedTotalTax,0)
,dblOriginalTotalTax	  =		ISNULL(dblOriginalTotalTax,0)
,strPriceMethod			  =		ISNULL(strPriceMethod,'''')
,strPriceBasis			  =		ISNULL(strPriceBasis,'''')
,strPriceProfileId		  =		ISNULL(strPriceProfileId,'''')
,strPriceIndexId		  =		ISNULL(strPriceIndexId,'''')
FROM tblCFTransaction
WHERE intTransactionId = ' + @keyValue 


INSERT INTO @tblCFTransactionToLog
(
 dblOriginalTotalPrice		
,dblCalculatedTotalPrice	
,dblOriginalGrossPrice		
,dblCalculatedGrossPrice	
,dblCalculatedNetPrice		
,dblOriginalNetPrice		
,dblCalculatedPumpPrice		
,dblOriginalPumpPrice		
,dblCalculatedTotalTax		
,dblOriginalTotalTax		
,strPriceMethod				
,strPriceBasis				
,strPriceProfileId			
,strPriceIndexId			
)
EXEC(@dynamicSQL)


DECLARE @dblOriginalTotalPrice		NUMERIC(18,6)
DECLARE @dblCalculatedTotalPrice	NUMERIC(18,6)
DECLARE @dblOriginalGrossPrice		NUMERIC(18,6)
DECLARE @dblCalculatedGrossPrice	NUMERIC(18,6)
DECLARE @dblCalculatedNetPrice		NUMERIC(18,6)
DECLARE @dblOriginalNetPrice		NUMERIC(18,6)
DECLARE @dblCalculatedPumpPrice		NUMERIC(18,6)
DECLARE @dblOriginalPumpPrice		NUMERIC(18,6)
DECLARE @dblCalculatedTotalTax		NUMERIC(18,6)
DECLARE @dblOriginalTotalTax		NUMERIC(18,6)
DECLARE @strPriceMethod				NVARCHAR(MAX)
DECLARE @strPriceBasis				NVARCHAR(MAX)
DECLARE @strPriceProfileId			NVARCHAR(MAX)
DECLARE @strPriceIndexId			NVARCHAR(MAX)


SELECT TOP 1 
 @dblOriginalTotalPrice		  = dblOriginalTotalPrice	
,@dblCalculatedTotalPrice	  = dblCalculatedTotalPrice
,@dblOriginalGrossPrice		  = dblOriginalGrossPrice	
,@dblCalculatedGrossPrice	  = dblCalculatedGrossPrice
,@dblCalculatedNetPrice		  = dblCalculatedNetPrice	
,@dblOriginalNetPrice		  = dblOriginalNetPrice	
,@dblCalculatedPumpPrice	  = dblCalculatedPumpPrice	
,@dblOriginalPumpPrice		  = dblOriginalPumpPrice	
,@dblCalculatedTotalTax		  = dblCalculatedTotalTax	
,@dblOriginalTotalTax		  = dblOriginalTotalTax	
,@strPriceMethod			  = strPriceMethod			
,@strPriceBasis				  = strPriceBasis			
,@strPriceProfileId			  = strPriceProfileId		
,@strPriceIndexId			  = strPriceIndexId		
FROM 
@tblCFTransactionToLog


DECLARE @dblToOriginalTotalPrice		NVARCHAR(MAX)	
DECLARE @dblToCalculatedTotalPrice		NVARCHAR(MAX)
DECLARE @dblToOriginalGrossPrice		NVARCHAR(MAX)
DECLARE @dblToCalculatedGrossPrice		NVARCHAR(MAX)
DECLARE @dblToCalculatedNetPrice		NVARCHAR(MAX)
DECLARE @dblToOriginalNetPrice			NVARCHAR(MAX)
DECLARE @dblToCalculatedPumpPrice		NVARCHAR(MAX)
DECLARE @dblToOriginalPumpPrice			NVARCHAR(MAX)
DECLARE @dblToCalculatedTotalTax		NVARCHAR(MAX)
DECLARE @dblToOriginalTotalTax			NVARCHAR(MAX)
DECLARE @strToPriceMethod				NVARCHAR(MAX)
DECLARE @strToPriceBasis				NVARCHAR(MAX)
DECLARE @strToPriceProfileId			NVARCHAR(MAX)
DECLARE @strToPriceIndexId				NVARCHAR(MAX)


SET @dblToOriginalTotalPrice	=  CAST(@dblOriginalTotalPrice		AS NVARCHAR(MAX))
SET @dblToOriginalGrossPrice	=  CAST(@dblOriginalGrossPrice 		AS NVARCHAR(MAX))
SET @dblToOriginalNetPrice		=  CAST(@dblOriginalNetPrice		AS NVARCHAR(MAX))
SET @dblToCalculatedTotalPrice	=  CAST(@dblCalculatedTotalPrice 	AS NVARCHAR(MAX))
SET @dblToCalculatedGrossPrice	=  CAST(@dblCalculatedGrossPrice 	AS NVARCHAR(MAX))	
SET @dblToCalculatedNetPrice	=  CAST(@dblCalculatedNetPrice		AS NVARCHAR(MAX))
SET @dblToCalculatedTotalTax	=  CAST(@dblCalculatedTotalTax		AS NVARCHAR(MAX))
SET @dblToOriginalTotalTax		=  CAST(@dblOriginalTotalTax		AS NVARCHAR(MAX))
SET @strToPriceMethod			=  ISNULL(@strPriceMethod			,'')
SET @strToPriceBasis			=  ISNULL(@strPriceBasis			,'')
SET @strToPriceProfileId		=  ISNULL(@strPriceProfileId		,'')
SET @strToPriceIndexId			=  ISNULL(@strPriceIndexId			,'')
					


SET @children += ' {' + '"change":' +'"'+ 'Total Original Price'		  +'"'+ ',"from":"' + @dblFromOriginalTotalPrice		 + '",' + '"to":"' + @dblToOriginalTotalPrice	+ '",' + '"iconCls": "small-gear"},'
SET @children += ' {' + '"change":' +'"'+ 'Original Gross Pirce'		  +'"'+ ',"from":"' + @dblFromOriginalGrossPrice		 + '",' + '"to":"' + @dblToOriginalGrossPrice	+ '",' + '"iconCls": "small-gear"},'
SET @children += ' {' + '"change":' +'"'+ 'Original Net Price'			  +'"'+ ',"from":"' + @dblFromOriginalNetPrice		 + '",' + '"to":"' + @dblToOriginalNetPrice		+ '",' + '"iconCls": "small-gear"},'
SET @children += ' {' + '"change":' +'"'+ 'Total Calculated Price' 		  +'"'+ ',"from":"' + @dblFromCalculatedTotalPrice	 + '",' + '"to":"' + @dblToCalculatedTotalPrice	+ '",' + '"iconCls": "small-gear"},'
SET @children += ' {' + '"change":' +'"'+ 'Calculated Gross Pirce' 		  +'"'+ ',"from":"' + @dblFromCalculatedGrossPrice	 + '",' + '"to":"' + @dblToCalculatedGrossPrice	+ '",' + '"iconCls": "small-gear"},'
SET @children += ' {' + '"change":' +'"'+ 'Calculated Net Price'		  +'"'+ ',"from":"' + @dblFromCalculatedNetPrice		 + '",' + '"to":"' + @dblToCalculatedNetPrice	+ '",' + '"iconCls": "small-gear"},'
SET @children += ' {' + '"change":' +'"'+ 'Total Calculated Tax'		  +'"'+ ',"from":"' + @dblFromCalculatedTotalTax		 + '",' + '"to":"' + @dblToCalculatedTotalTax	+ '",' + '"iconCls": "small-gear"},'
SET @children += ' {' + '"change":' +'"'+ 'Total Original Tax'			  +'"'+ ',"from":"' + @dblFromOriginalTotalTax		 + '",' + '"to":"' + @dblToOriginalTotalTax		+ '",' + '"iconCls": "small-gear"},'
SET @children += ' {' + '"change":' +'"'+ 'Price Method'				  +'"'+ ',"from":"' + @strFromPriceMethod				 + '",' + '"to":"' + @strToPriceMethod			+ '",' + '"iconCls": "small-gear"},'
SET @children += ' {' + '"change":' +'"'+ 'Price Basis'				      +'"'+ ',"from":"' + @strFromPriceBasis				 + '",' + '"to":"' + @strToPriceBasis			+ '",' + '"iconCls": "small-gear"},'
SET @children += ' {' + '"change":' +'"'+ 'Price Profile'				  +'"'+ ',"from":"' + @strFromPriceProfileId			 + '",' + '"to":"' + @strToPriceProfileId		+ '",' + '"iconCls": "small-gear"},'
SET @children += ' {' + '"change":' +'"'+ 'Price Index'				      +'"'+ ',"from":"' + @strFromPriceIndexId			 + '",' + '"to":"' + @strToPriceIndexId			+ '",' + '"iconCls": "small-gear"}'


exec uspSMAuditLog
@screenName				 = @screenName,
@keyValue				 = @keyValue,
@entityId				 = @entityId,
@actionType				 = @processName,
@changeDescription  	 = @processName,
@details				 = @children


