CREATE PROCEDURE dbo.uspIPGenerateERPAuctionStock (
	@limit INT = 1
	,@offset INT = 50
	,@ysnUpdateFeedStatus BIT = 1
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @strXML NVARCHAR(MAX)
		,@ErrMsg NVARCHAR(MAX)
		,@intAuctionStockPreStageId INT
		,@dtmCurrentDate DATETIME
		,@intDefaultCurrencyId INT

	SELECT @dtmCurrentDate = Convert(CHAR, GETDATE(), 101)

	DECLARE @tblIPAuctionStockPreStage TABLE (intItemId INT)
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
			WHERE dtmProcessedDate = @dtmCurrentDate
			)
	BEGIN
		DELETE
		FROM tblIPAuctionStockPreStage

		INSERT INTO tblIPAuctionStockPreStage (
			intAuctionStockPreStageId
			,intItemId
			,dtmProcessedDate
			)
		SELECT ROW_NUMBER() OVER (
				ORDER BY (
						SELECT NULL
						)
				)
			,intItemId
			,@dtmCurrentDate
		FROM (
			SELECT DISTINCT S.intItemId
			FROM tblQMSample S
			WHERE S.dtmSaleDate BETWEEN GetDATE() - 28
					AND GETDATE()
			) AS DT
	END

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblIPAuctionStockPreStage
			WHERE intStatusId IS NULL
				AND intAuctionStockPreStageId BETWEEN (@limit - 1) * @offset + 1
					AND @limit * @offset
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
		SELECT @tmp = 50

	IF @offset > @tmp
	BEGIN
		SELECT @offset = @tmp
	END

	INSERT INTO @tblIPAuctionStockPreStage (intItemId)
	SELECT PS.intItemId
	FROM dbo.tblIPAuctionStockPreStage PS
	WHERE PS.intStatusId IS NULL
		AND intAuctionStockPreStageId BETWEEN (@limit - 1) * @offset + 1
			AND @limit * @offset

	UPDATE dbo.tblIPAuctionStockPreStage
	SET intStatusId = - 1
	WHERE intItemId IN (
			SELECT PS.intItemId
			FROM @tblIPAuctionStockPreStage PS
			)

	SELECT @intDefaultCurrencyId = intDefaultCurrencyId
	FROM tblSMCompanyPreference

	INSERT INTO @tblIPAuctionStock7 (
		intItemId
		,intLocationId
		,intCurrencyId
		,dblLastWeekBought
		,dblLastWeekPrice
		)
	SELECT S.intItemId
		,S.intLocationId
		,IsNULL(S.intCurrencyId, @intDefaultCurrencyId) AS intCurrencyId
		,Sum(S.dblB1QtyBought) LastWeekBought
		,SUM(S.dblB1QtyBought * S.dblB1Price) / Sum(S.dblB1QtyBought) dblLastPrice
	FROM tblQMSample S
	JOIN @tblIPAuctionStockPreStage AI ON S.intItemId = AI.intItemId
	WHERE S.dtmSaleDate BETWEEN GetDATE() - 7
			AND GETDATE()
	GROUP BY S.intItemId
		,S.intLocationId
		,S.intCurrencyId

	INSERT INTO @tblIPAuctionStock28 (
		intItemId
		,intLocationId
		,intCurrencyId
		,dblLastWeekBought
		,dblLastWeekPrice
		)
	SELECT S.intItemId
		,S.intLocationId
		,IsNULL(S.intCurrencyId, @intDefaultCurrencyId) AS intCurrencyId
		,Sum(S.dblB1QtyBought)
		,SUM(S.dblB1QtyBought * S.dblB1Price) / Sum(S.dblB1QtyBought) dblLastPrice
	FROM tblQMSample S
	JOIN @tblIPAuctionStockPreStage AI ON S.intItemId = AI.intItemId
	WHERE S.dtmSaleDate BETWEEN GetDATE() - 28
			AND GETDATE()
	GROUP BY S.intItemId
		,S.intLocationId
		,S.intCurrencyId

	INSERT INTO @tblIPAvailableStock (
		intItemId
		,intLocationId
		,dblAvailable
		)
	SELECT L.intItemId
		,L.intLocationId
		,SUM(L.dblGrossWeight) AS dblGrossWeight
	FROM dbo.tblICLot L
	JOIN @tblIPAuctionStock28 AS28 ON AS28.intItemId = L.intItemId
		AND AS28.intLocationId = L.intLocationId
	WHERE L.dblGrossWeight > 0
	GROUP BY L.intItemId
		,L.intLocationId

	UPDATE AS7
	SET dblLastWeekAvailable = S.dblAvailable
		,dblLastWeekPressure = (
			CASE 
				WHEN S.dblAvailable > 0
					THEN Round((AS7.dblLastWeekBought / S.dblAvailable) * 100, 2)
				ELSE Round(AS7.dblLastWeekBought, 2)
				END
			)
	FROM @tblIPAuctionStock7 AS7
	JOIN @tblIPAvailableStock S ON S.intItemId = AS7.intItemId
		AND S.intLocationId = AS7.intLocationId

	UPDATE AS28
	SET dblLastWeekAvailable = S.dblAvailable
		,dblLastWeekPressure = (
			CASE 
				WHEN S.dblAvailable > 0
					THEN Round((AS28.dblLastWeekBought / S.dblAvailable) * 100, 2)
				ELSE Round(AS28.dblLastWeekBought, 2)
				END
			)
	FROM @tblIPAuctionStock28 AS28
	JOIN @tblIPAvailableStock S ON S.intItemId = AS28.intItemId
		AND S.intLocationId = AS28.intLocationId

	SELECT @strXML = '<root><DocNo>' + IsNULL(ltrim(MIN(AS7.intItemId)), '') + '</DocNo>' + '<MsgType>Auction_Stock</MsgType>' + '<Sender>iRely</Sender>' + '<Receiver>ICRON</Receiver>'
	FROM @tblIPAuctionStock7 AS7

	SELECT @strXML = @strXML + '<Header><ItemCode>' + IsNULL(I.strItemNo, '') + '</ItemCode>' 
							+ '<BuyingCenter>' + IsNULL(CL.strLocationName, '') + '</BuyingCenter>' 
							+ '<LastWeekDate>' + IsNULL(CONVERT(VARCHAR(33), GETDATE() - 7, 126), '') + '</LastWeekDate>' 
							+ '<Currency>' + IsNULL(ltrim(C.strCurrency), '') + '</Currency>' 
							+ '<LastWeekPrice>' + IsNULL(ltrim(AS7.dblLastWeekPrice), '') + '</LastWeekPrice>' 
							+ '<LastWeekBought>' + IsNULL([dbo].[fnRemoveTrailingZeroes](AS7.dblLastWeekBought), '') + '</LastWeekBought>' 
							+ '<LastWeekAvailable>' + IsNULL([dbo].[fnRemoveTrailingZeroes](AS7.dblLastWeekAvailable), '') + '</LastWeekAvailable>' 
							+ '<LastWeekPressure>' + IsNULL(ltrim(AS7.dblLastWeekPressure), '') + '</LastWeekPressure>' 
							+ '<Last4WeekPrice>' + IsNULL(ltrim(AS28.dblLastWeekPrice), '') + '</Last4WeekPrice>' 
							+ '<Last4WeekBought>' + IsNULL([dbo].[fnRemoveTrailingZeroes](AS28.dblLastWeekBought), '') + '</Last4WeekBought>' 
							+ '<Last4WeekAvailable>' + IsNULL([dbo].[fnRemoveTrailingZeroes](AS28.dblLastWeekAvailable), '') + '</Last4WeekAvailable>' 
							+ '<Last4WeekPressure>' + IsNULL(ltrim(AS28.dblLastWeekPressure), '') + '</Last4WeekPressure></Header>'
	FROM @tblIPAuctionStock7 AS7
	JOIN @tblIPAuctionStock28 AS28 ON AS28.intItemId = AS7.intItemId
		AND AS28.intLocationId = AS7.intLocationId
	JOIN tblICItem I ON I.intItemId = AS7.intItemId
	JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = AS7.intLocationId
	JOIN tblSMCurrency C ON C.intCurrencyID = AS7.intCurrencyId

	SELECT @strXML = @strXML + '</root>'

	SELECT IsNULL(1, '0') AS id
		,IsNULL(@strXML, '') AS strXml
		,'' AS strInfo1
		,'' AS strInfo2
		,'' AS strOnFailureCallbackSql
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
