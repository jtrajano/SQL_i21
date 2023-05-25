CREATE PROCEDURE [dbo].[uspGRGrainFlowReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN
	SET FMTONLY OFF
	SET NOCOUNT ON
	
	DECLARE @ErrMsg NVARCHAR(MAX)

	IF LTRIM(RTRIM(@xmlParam)) = ''
		SET @xmlParam = NULL

	-- XML Parameter Table
	DECLARE @temp_xml_table TABLE 
	(
		id int identity(1,1)
		,[fieldname] NVARCHAR(50)
		,[condition] NVARCHAR(20)
		,[from] NVARCHAR(MAX)
		,[to] NVARCHAR(MAX)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
	)
	DECLARE @xmlDocumentId AS INT

	EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT,@xmlParam

	INSERT INTO @temp_xml_table
	SELECT *
	FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2) WITH 
	(
		[fieldname] NVARCHAR(50)
		,[condition] NVARCHAR(20)
		,[from] NVARCHAR(50)
		,[to] NVARCHAR(50)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
	)

	DECLARE @final_condition nvarchar(max) = ''
	
	UPDATE @temp_xml_table 
	SET [to] = CONVERT(nvarchar, DATEADD(day, 1,CAST([to] AS DATE)), 101) 
	WHERE datatype LIKE 'Date%' 
		AND ([to] IS NOT NULL AND [to] <> '')
	
	SELECT @final_condition = @final_condition + ' '  +
							dbo.fnAPCreateFilter(fieldname, condition, [from], [to], [join], begingroup, endgroup, datatype) + ' ' + [join]  
	FROM @temp_xml_table xml_table 
		WHERE condition <> 'Dummy'
	ORDER BY id ASC

	SET @final_condition = @final_condition + ' 1 = 1' 
	
	-- Query Parameters
	-- DECLARE @dtmTicketDateTimeFrom DATETIME
	-- DECLARE @dtmTicketDateTimeTo DATETIME
	
	DECLARE @MaxTicketNumber int = 999999999
	-- SELECT @dtmTicketDateTimeTo = [to]
	-- FROM @temp_xml_table
	-- WHERE [fieldname] = 'dtmReceiptDate';

	-- SELECT @dtmTicketDateTimeFrom = [from]
	-- FROM @temp_xml_table
	-- WHERE [fieldname] = 'dtmReceiptDate';

	IF OBJECT_ID('tempdb..#tmpSampleExport') IS NOT NULL DROP TABLE #tmpSampleExport    

	DECLARE @sFrom nvarchar(50)
	DECLARE @sTo nvarchar(50)

	-- IF(@dtmTicketDateTimeFrom IS NULL)
	-- 	SET @sFrom = CONVERT(nvarchar, GETDATE(), 111)
	-- ELSE
	-- 	SET @sFrom = CONVERT(nvarchar, @dtmTicketDateTimeFrom, 111)


	-- IF (@dtmTicketDateTimeTo IS NULL)
	-- 	SET @sTo = CONVERT(nvarchar,  DATEADD(DAY, 1, GETDATE()), 111)
	-- ELSE 
	-- 	SET @sTo = CONVERT(nvarchar, DATEADD(day, 1, @dtmTicketDateTimeTo), 111)

	
	-- SELECT @sTo = REPLACE(@sTo, '/', '-') 
	-- 		,@sFrom = REPLACE(@sFrom, '/', '-') 

	SELECT TOP 0 * into #tmpSampleExport FROM vyuGRGrainFlowReport
	DECLARE @sqlcmd NVARCHAR(500)

	SET @sqlcmd = 'INSERT INTO #tmpSampleExport 
					SELECT *
					FROM vyuGRGrainFlowReport 
					WHERE ' + @final_condition
	exec (@sqlcmd)

	--calculate wgt avg buy/sell basis
	SELECT DISTINCT strCommodityCode
	INTO #Commodities
	FROM #tmpSampleExport

	SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY strFuturesMonth ASC) AS intRowNum
		,strFuturesMonth
	INTO #FuturesMonth
	FROM #tmpSampleExport
	WHERE strFuturesMonth IS NOT NULL
	GROUP BY strFuturesMonth

	DECLARE @strFuturesMonth NVARCHAR(100)
	DECLARE @dblTotalDelivered DECIMAL(18,6)
	DECLARE @dblTotalDirect DECIMAL(18,6)
	DECLARE @dblTotalFromStorage DECIMAL(18,6)
	DECLARE @dblTotalAllSales DECIMAL(18,6)
	DECLARE @dblTotalPurchaseBasis DECIMAL(18,6)
	DECLARE @dblTotalSellBasis DECIMAL(18,6)
	DECLARE @commodity NVARCHAR(100)
	--DECLARE @intRowNumReceiptDate INT
	DECLARE @intRowNumFuturesMonth INT

	DECLARE @FinalTable AS TABLE(
		strCommodityCode NVARCHAR(100)
		,dtmReceiptDate NVARCHAR(200)
		,dblDelivered DECIMAL(18,6)
		,dblDirect DECIMAL(18,6)
		,dblFromStorage DECIMAL(18,6)
		,dblUnpricedReceipts DECIMAL(18,6)
		,dblAllSales DECIMAL(18,6)
		,dblBuyBasis DECIMAL(18,6)
		,dblSellBasis DECIMAL(18,6)
		,strFuturesMonth NVARCHAR(100)
	)

	WHILE EXISTS(SELECT 1 FROM #Commodities)
	BEGIN
		SELECT TOP 1 @commodity = strCommodityCode FROM #Commodities

		SELECT @intRowNumFuturesMonth = MIN(intRowNum) FROM #FuturesMonth

		WHILE @intRowNumFuturesMonth > 0
		BEGIN
			IF OBJECT_ID('tempdb..#tmpGrain') IS NOT NULL DROP TABLE #tmpGrain
			IF OBJECT_ID('tempdb..#tmpFinal') IS NOT NULL DROP TABLE #tmpFinal

			SELECT @strFuturesMonth = strFuturesMonth FROM #FuturesMonth WHERE intRowNum = @intRowNumFuturesMonth

			SELECT *
				,del_x_buyBasis		= ISNULL(dblDelivered,0) * ISNULL(dblBuyBasis,0)
				,dir_x_buyBasis		= ISNULL(dblDirect,0) * ISNULL(dblBuyBasis,0)
				,stor_x_buyBasis	= ISNULL(dblFromStorage,0) * ISNULL(dblBuyBasis,0)
				,sales_x_sellBasis	= ISNULL(dblAllSales,0) * ISNULL(dblSellBasis,0)				
			INTO #tmpGrain
			FROM #tmpSampleExport
			WHERE strCommodityCode = @commodity
				AND strFuturesMonth = @strFuturesMonth

			SELECT 
				@dblTotalDelivered		= ISNULL(SUM(dblDelivered),0)
				,@dblTotalDirect		= ISNULL(SUM(dblDirect),0)
				,@dblTotalFromStorage	= ISNULL(SUM(dblFromStorage),0)
				,@dblTotalAllSales		= ISNULL(SUM(dblAllSales),0)
				,@dblTotalPurchaseBasis = ISNULL(SUM(dblBuyBasis),0)
				,@dblTotalSellBasis		= ISNULL(SUM(dblSellBasis),0)
			FROM #tmpSampleExport
			WHERE strCommodityCode = @commodity
				AND strFuturesMonth = @strFuturesMonth
			GROUP BY strCommodityCode
				,strFuturesMonth

			SELECT 
				strCommodityCode
				,dtmReceiptDate
				,dblDelivered
				,dblDirect
				,dblFromStorage
				,dblUnpricedReceipts
				,dblAllSales
				,dblBuyBasis		= dblBuyBasis / CASE WHEN @dblTotalDelivered + @dblTotalDirect + @dblTotalFromStorage = 0 THEN 1 ELSE @dblTotalDelivered + @dblTotalDirect + @dblTotalFromStorage END
				,dblSellBasis		= dblSellBasis / CASE WHEN @dblTotalAllSales = 0 THEN 1 ELSE @dblTotalAllSales END
				,strFuturesMonth	= @strFuturesMonth
			INTO #tmpFinal
			FROM (
				SELECT 
					strCommodityCode
					,dtmReceiptDate
					,dblDelivered = SUM(dblDelivered)
					,dblDirect = SUM(dblDirect)
					,dblFromStorage = SUM(dblFromStorage)
					,dblUnpricedReceipts = SUM(dblUnpricedReceipts)
					,dblAllSales = SUM(dblAllSales)
					,dblBuyBasis = SUM(del_x_buyBasis + dir_x_buyBasis + stor_x_buyBasis)
					,dblSellBasis = SUM(sales_x_sellBasis)	
				FROM #tmpGrain
				GROUP BY strCommodityCode
					,dtmReceiptDate
			) A
				
			INSERT INTO @FinalTable
			SELECT 
				strCommodityCode
				,dtmReceiptDate
				,dblDelivered = SUM(dblDelivered)
				,dblDirect = SUM(dblDirect)
				,dblFromStorage = SUM(dblFromStorage)
				,dblUnpricedReceipts = SUM(dblUnpricedReceipts)
				,dblAllSales = SUM(dblAllSales)
				,dblBuyBasis = SUM(dblBuyBasis)
				,dblSellBasis = SUM(dblSellBasis)
				,strFuturesMonth
			FROM #tmpFinal
			GROUP BY strCommodityCode
				,dtmReceiptDate	
				,strFuturesMonth
			

			SELECT @intRowNumFuturesMonth = MIN(intRowNum) FROM #FuturesMonth WHERE intRowNum > @intRowNumFuturesMonth			
		END

		INSERT INTO @FinalTable
		SELECT
			strCommodityCode
			,dtmReceiptDate
			,ISNULL(SUM(dblDelivered),0)
			,ISNULL(SUM(dblDirect),0)
			,ISNULL(SUM(dblFromStorage),0)
			,ISNULL(SUM(dblUnpricedReceipts),0)
			,ISNULL(SUM(dblAllSales),0)
			,0
			,0
			,NULL
		FROM #tmpSampleExport
		WHERE strCommodityCode = @commodity
			AND strFuturesMonth IS NULL
		GROUP BY strCommodityCode
			,dtmReceiptDate		

		DELETE FROM #Commodities WHERE strCommodityCode = @commodity
	END

	
	SELECT * FROM @FinalTable ORDER BY strFuturesMonth
END