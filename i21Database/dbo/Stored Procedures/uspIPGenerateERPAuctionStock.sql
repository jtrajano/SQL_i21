CREATE PROCEDURE dbo.uspIPGenerateERPAuctionStock (
	@limit INT = 0
	,@offset INT = 0
	,@ysnUpdateFeedStatus BIT = 1
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @strXML NVARCHAR(MAX)
		,@strDetailXML NVARCHAR(MAX)
		,@ErrMsg NVARCHAR(MAX)
		,@intAuctionStockPreStageId INT
		,@dtmCurrentDate DATETIME
		,@intDefaultCurrencyId INT
		,@intTotalRows int
		,@dtmStartDayOfWeek Datetime
		,@dtmStartDayOfLast7Days Datetime 
		,@dtmStartDayOfLast28Days Datetime

	Select @dtmCurrentDate=Convert(char,GETDATE(),101)

	SELECT @dtmStartDayOfWeek= DATEADD(DD, 1 - DATEPART(DW, @dtmCurrentDate), @dtmCurrentDate)
	SELECT @dtmStartDayOfLast7Days=DATEADD(DD, 1 - DATEPART(DW, @dtmCurrentDate), @dtmCurrentDate)-6
	SELECT @dtmStartDayOfLast28Days=DATEADD(DD, 1 - DATEPART(DW, @dtmCurrentDate), @dtmCurrentDate)-27

	DECLARE @tblIPAuctionStockPreStage TABLE (intItemId INT,intLocationId INT)
	DECLARE @tblIPAuctionStock7 AS TABLE (
		intItemId INT
		,intLocationId INT
		,intCurrencyId INT
		,dblLastWeekBought NUMERIC(18, 6)
		,dblLastWeekPrice NUMERIC(18, 6)
		,dblLastWeekAvailable NUMERIC(18, 6)
		,dblLastWeekPressure NUMERIC(18, 6)
		)
	DECLARE @tblIPAuctionStock28 AS TABLE (
		intItemId INT
		,intLocationId INT
		,intCurrencyId INT
		,dblLastWeekBought NUMERIC(18, 6)
		,dblLastWeekPrice NUMERIC(18, 6)
		,dblLastWeekAvailable NUMERIC(18, 6)
		,dblLastWeekPressure NUMERIC(18, 6)
		)
	DECLARE @tblOutput AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intWorkOrderId INT
		,strRowState NVARCHAR(50)
		,strXML NVARCHAR(MAX)
		,strWorkOrderNo NVARCHAR(50)
		,strERPOrderNo NVARCHAR(50)
		)
	DECLARE @tblIPAvailableStock AS TABLE (
		intItemId INT
		,intLocationId INT
		,dblAvailable NUMERIC(18, 6)
		)

	IF NOT EXISTS (
			SELECT *
			FROM tblIPAuctionStockPreStage
			WHERE dtmProcessedDate = @dtmStartDayOfWeek
			)
	BEGIN
		DELETE
		FROM tblIPAuctionStockPreStage

		INSERT INTO tblIPAuctionStockPreStage (
			intAuctionStockPreStageId
			,intItemId
			,dtmProcessedDate
			,intLocationId
			)
		SELECT ROW_NUMBER() OVER (
				ORDER BY intItemId
				)
			,intItemId
			,@dtmStartDayOfWeek
			,intLocationId
		FROM (
			SELECT DISTINCT S.intItemId,S.intLocationId
			FROM tblQMSample S
			WHERE S.dtmSaleDate BETWEEN @dtmStartDayOfLast28Days
					AND @dtmStartDayOfWeek
					AND S.intMarketZoneId  =1
			) AS DT
		Order by intItemId
	END

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblIPAuctionStockPreStage
			WHERE intStatusId IS NULL
				AND intAuctionStockPreStageId between @offset + 1
					AND @limit + @offset
			)
	BEGIN
		RETURN
	END

	DECLARE @tmp INT

	SELECT @tmp = strValue
	FROM tblIPSAPIDOCTag
	WHERE strMessageType = 'Auction Stock'
		AND strTag = 'Count'

	IF ISNULL(@tmp, 0) = 0
		SELECT @tmp = 100

	IF @limit > @tmp
	BEGIN
		SELECT @limit = @tmp
	END

	INSERT INTO @tblIPAuctionStockPreStage (intItemId,intLocationId)
	SELECT PS.intItemId,PS.intLocationId
	FROM dbo.tblIPAuctionStockPreStage PS
	WHERE PS.intStatusId IS NULL
		AND intAuctionStockPreStageId BETWEEN @offset + 1
					AND @limit + @offset

	UPDATE dbo.tblIPAuctionStockPreStage
	SET intStatusId = - 1
	WHERE Exists (
			SELECT 1
			FROM @tblIPAuctionStockPreStage PS
			Where PS.intItemId=tblIPAuctionStockPreStage.intItemId and PS.intLocationId=tblIPAuctionStockPreStage.intLocationId
			)

	SELECT @intDefaultCurrencyId = intDefaultCurrencyId
	FROM tblSMCompanyPreference

	INSERT INTO @tblIPAuctionStock7 (
		intItemId
		,intLocationId
		,intCurrencyId
		,dblLastWeekBought
		,dblLastWeekPrice
		,dblLastWeekAvailable
		)
	SELECT S.intItemId
		,S.intLocationId
		,IsNULL(S.intCurrencyId, @intDefaultCurrencyId) AS intCurrencyId
		,Sum(isNULL(S.dblB1QtyBought*UC.dblConversionToStock,0)  )
		,SUM(isNULL(S.dblB1QtyBought * S.dblB1Price,0)) / Sum(isNULL(S.dblB1QtyBought,0)) dblLastPrice
		,Sum(isNULL(S.dblB1QtyBought*UC.dblConversionToStock,0) +isNULL(S.dblB2QtyBought*UC.dblConversionToStock,0) +isNULL(S.dblB3QtyBought*UC.dblConversionToStock,0)+isNULL(S.dblB4QtyBought*UC.dblConversionToStock,0)+isNULL(S.dblB5QtyBought *UC.dblConversionToStock,0))
	FROM tblQMSample S
	JOIN @tblIPAuctionStockPreStage AI ON S.intItemId = AI.intItemId AND S.intLocationId=AI.intLocationId
	LEFT JOIN tblICUnitMeasureConversion UC on UC.intUnitMeasureId =S.intB1QtyUOMId and UC.intStockUnitMeasureId =4 
	WHERE S.dtmSaleDate BETWEEN @dtmStartDayOfLast7Days
			AND @dtmStartDayOfWeek
			AND S.intMarketZoneId  =1
	GROUP BY S.intItemId
		,S.intLocationId
		,S.intCurrencyId

	INSERT INTO @tblIPAuctionStock28 (
		intItemId
		,intLocationId
		,intCurrencyId
		,dblLastWeekBought
		,dblLastWeekPrice
		,dblLastWeekAvailable
		)
	SELECT S.intItemId
		,S.intLocationId
		,IsNULL(S.intCurrencyId, @intDefaultCurrencyId) AS intCurrencyId
		,Sum(isNULL(S.dblB1QtyBought*UC.dblConversionToStock,0)  )
		,SUM(isNULL(S.dblB1QtyBought * S.dblB1Price,0)) / Sum(isNULL(S.dblB1QtyBought,0)) dblLastPrice
		,Sum(isNULL(S.dblB1QtyBought*UC.dblConversionToStock,0) +isNULL(S.dblB2QtyBought*UC.dblConversionToStock,0) +isNULL(S.dblB3QtyBought*UC.dblConversionToStock,0)+isNULL(S.dblB4QtyBought*UC.dblConversionToStock,0)+isNULL(S.dblB5QtyBought *UC.dblConversionToStock,0))
	FROM tblQMSample S
	JOIN @tblIPAuctionStockPreStage AI ON S.intItemId = AI.intItemId AND S.intLocationId=AI.intLocationId
	LEFT JOIN tblICUnitMeasureConversion UC on UC.intUnitMeasureId =S.intB1QtyUOMId and UC.intStockUnitMeasureId =4 
	WHERE S.dtmSaleDate BETWEEN @dtmStartDayOfLast28Days
			AND @dtmStartDayOfWeek
			AND S.intMarketZoneId  =1
	GROUP BY S.intItemId
		,S.intLocationId
		,S.intCurrencyId

	UPDATE @tblIPAuctionStock7
	SET dblLastWeekPressure = (
			CASE 
				WHEN dblLastWeekAvailable > 0
					THEN Round((dblLastWeekBought / dblLastWeekAvailable) * 100, 2)
				ELSE Round(dblLastWeekBought, 2)
				END
			)

	UPDATE @tblIPAuctionStock28
	SET dblLastWeekPressure = (
			CASE 
				WHEN dblLastWeekAvailable > 0
					THEN Round((dblLastWeekBought / dblLastWeekAvailable) * 100, 2)
				ELSE Round(dblLastWeekBought, 2)
				END
			)

	Select @intTotalRows=Count(*)
	from tblIPAuctionStockPreStage

	SELECT @strXML = '<root><DocNo>' + IsNULL(ltrim(MIN(AS7.intItemId)), '') + '</DocNo>' + '<MsgType>Auction_Stock</MsgType>' + '<Sender>iRely</Sender>' 
						+ '<Receiver>ICRON</Receiver>'
						+ '<TotalRows>'+IsNULL(ltrim(@intTotalRows),'')+'</TotalRows>'
	FROM @tblIPAuctionStock7 AS7

	SELECT @strDetailXML = IsNULL(@strDetailXML,'') + '<Header><ItemCode>' + IsNULL(I.strItemNo, '') + '</ItemCode>' 
							+ '<BuyingCenter>' + IsNULL(CL.strLocationName, '') + '</BuyingCenter>' 
							+ '<LastWeekDate>' + IsNULL(CONVERT(VARCHAR(33), @dtmStartDayOfLast7Days, 126), '') + '</LastWeekDate>' 
							+ '<Currency>' + IsNULL(ltrim(C.strCurrency), '') + '</Currency>' 
							+ '<LastWeekPrice>' + IsNULL([dbo].[fnRemoveTrailingZeroes](AS7.dblLastWeekPrice), '') + '</LastWeekPrice>' 
							+ '<LastWeekBought>' + IsNULL([dbo].[fnRemoveTrailingZeroes](AS7.dblLastWeekBought), '') + '</LastWeekBought>' 
							+ '<LastWeekAvailable>' + IsNULL([dbo].[fnRemoveTrailingZeroes](AS7.dblLastWeekAvailable), '') + '</LastWeekAvailable>' 
							+ '<LastWeekPressure>' + IsNULL([dbo].[fnRemoveTrailingZeroes](AS7.dblLastWeekPressure), '') + '</LastWeekPressure>' 
							+ '<Last4WeekPrice>' + IsNULL([dbo].[fnRemoveTrailingZeroes](AS28.dblLastWeekPrice), '') + '</Last4WeekPrice>' 
							+ '<Last4WeekBought>' + IsNULL([dbo].[fnRemoveTrailingZeroes](AS28.dblLastWeekBought), '') + '</Last4WeekBought>' 
							+ '<Last4WeekAvailable>' + IsNULL([dbo].[fnRemoveTrailingZeroes](AS28.dblLastWeekAvailable), '') + '</Last4WeekAvailable>' 
							+ '<Last4WeekPressure>' + IsNULL([dbo].[fnRemoveTrailingZeroes](AS28.dblLastWeekPressure), '') + '</Last4WeekPressure></Header>'
	FROM @tblIPAuctionStock28 AS28
	FULL JOIN @tblIPAuctionStock7 AS7 ON AS28.intItemId = AS7.intItemId
		AND AS28.intLocationId = AS7.intLocationId
	JOIN tblICItem I ON I.intItemId = IsNULL(AS28.intItemId,AS7.intItemId)
	JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = IsNULL(AS28.intLocationId,AS7.intLocationId)
	JOIN tblSMCurrency C ON C.intCurrencyID = IsNULL(AS28.intCurrencyId,AS7.intCurrencyId)

	UPDATE dbo.tblIPAuctionStockPreStage
	SET intStatusId = NULL
	WHERE Exists (
			SELECT 1
			FROM @tblIPAuctionStockPreStage PS
			Where PS.intItemId =tblIPAuctionStockPreStage.intItemId 
			and PS.intLocationId =tblIPAuctionStockPreStage.intLocationId
			)
		AND intStatusId = - 1

	IF LEN(@strDetailXML)>0
	BEGIN
		SELECT @strXML = @strXML +@strDetailXML+ '</root>'

		SELECT IsNULL(1, '0') AS id
			,IsNULL(@strXML, '') AS strXml
			,'' AS strInfo1
			,'' AS strInfo2
			,'' AS strOnFailureCallbackSql
	END
	ELSE
	BEGIN
		SELECT IsNULL(1, '0') AS id
			,'' AS strXml
			,'' AS strInfo1
			,'' AS strInfo2
			,'' AS strOnFailureCallbackSql
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
