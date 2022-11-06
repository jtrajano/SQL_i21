CREATE PROCEDURE dbo.uspIPGenerateERPAuctionStock (
	@intPageNumber INT = 1
	,@intPageSize INT = 50
	,@ysnUpdateFeedStatus BIT = 1
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @strXML NVARCHAR(MAX)
		,@ErrMsg NVARCHAR(MAX)
		,@intAuctionStockPreStageId INT
		,@dtmCurrentDate DATETIME

	SELECT @dtmCurrentDate = Convert(CHAR, GETDATE(), 101)

	DECLARE @tblIPAuctionStockPreStage TABLE (intItemId INT)
	DECLARE @tblIPAuctionStock7 AS TABLE (
		intItemId INT
		,intLocationId INT
		,intCurrencyId INT
		,dblLastWeekBought NUMERIC(18, 6)
		,dblLastWeekPrice NUMERIC(18, 6)
		,dblLastWeekAvailable  NUMERIC(18, 6)
		,dblLastWeekPressure  NUMERIC(18, 6)
		)
	DECLARE @tblIPAuctionStock28 AS TABLE (
		intItemId INT
		,intLocationId INT
		,intCurrencyId INT
		,dblLastWeekBought NUMERIC(18, 6)
		,dblLastWeekPrice NUMERIC(18, 6)
		,dblLastWeekAvailable  NUMERIC(18, 6)
		,dblLastWeekPressure  NUMERIC(18, 6)
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
		SELECT DISTINCT ROW_NUMBER() OVER (
				ORDER BY (
						SELECT NULL
						)
				)
			,S.intItemId
			,@dtmCurrentDate
		FROM tblQMSample S
		WHERE S.dtmSaleDate BETWEEN GetDATE() - 28
				AND GETDATE()
	END

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblIPAuctionStockPreStage
			WHERE intStatusId IS NULL
				AND intAuctionStockPreStageId BETWEEN (@intPageNumber - 1) * @intPageSize + 1
					AND @intPageNumber * @intPageSize
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

	IF @intPageSize > @tmp
	BEGIN
		SELECT @intPageSize = @tmp
	END

	INSERT INTO @tblIPAuctionStockPreStage (intItemId)
	SELECT PS.intItemId
	FROM dbo.tblIPAuctionStockPreStage PS
	WHERE PS.intStatusId IS NULL
		AND intAuctionStockPreStageId BETWEEN (@intPageNumber - 1) * @intPageSize + 1
			AND @intPageNumber * @intPageSize

	UPDATE dbo.tblIPAuctionStockPreStage
	SET intStatusId = - 1
	WHERE intItemId IN (
			SELECT PS.intItemId
			FROM @tblIPAuctionStockPreStage PS
			)

	INSERT INTO @tblIPAuctionStock7(intItemId 
		,intLocationId 
		,intCurrencyId 
		,dblLastWeekBought 
		,dblLastWeekPrice)
	SELECT S.intItemId
		,S.intLocationId
		,S.intCurrencyId
		,Sum(OB.dblB1QtyBought) LastWeekBought
		,SUM(OB.dblB1QtyBought * OB.dblB1Price) / Sum(OB.dblB1QtyBought) dblLastPrice
	FROM tblQMSample S
	JOIN tblQMSampleOtherBuyers OB ON OB.intSampleId = S.intSampleId
	JOIN @tblIPAuctionStockPreStage AI ON S.intItemId = AI.intItemId
	WHERE dtmBusinessDate BETWEEN GetDATE() - 7
			AND GETDATE()
	GROUP BY S.intItemId
		,S.intLocationId
		,S.intCurrencyId

	INSERT INTO @tblIPAuctionStock28  (intItemId 
		,intLocationId 
		,intCurrencyId 
		,dblLastWeekBought 
		,dblLastWeekPrice)
	SELECT S.intItemId
		,S.intLocationId
		,S.intCurrencyId
		,Sum(OB.dblB1QtyBought)
		,SUM(OB.dblB1QtyBought * OB.dblB1Price) / Sum(OB.dblB1QtyBought) dblLastPrice
	FROM tblQMSample S
	JOIN tblQMSampleOtherBuyers OB ON OB.intSampleId = S.intSampleId
	JOIN @tblIPAuctionStockPreStage AI ON S.intItemId = AI.intItemId
	WHERE dtmBusinessDate BETWEEN GetDATE() - 28
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

	Update AS7
	Set dblLastWeekAvailable=S.dblAvailable 
		,dblLastWeekPressure =(Case When S.dblAvailable>0 then Round((AS7.dblLastWeekBought/S.dblAvailable)*100,2) Else Round(AS7.dblLastWeekBought,2) End)
	from @tblIPAuctionStock7	AS7 
	JOIN @tblIPAvailableStock S on S.intItemId=AS7.intItemId  and S.intLocationId=AS7.intLocationId

	Update AS28
	Set dblLastWeekAvailable=S.dblAvailable 
		,dblLastWeekPressure =(Case When S.dblAvailable>0 then Round((AS28.dblLastWeekBought/S.dblAvailable)*100,2) Else Round(AS28.dblLastWeekBought,2) End)
	from @tblIPAuctionStock7	AS28 
	JOIN @tblIPAvailableStock S on S.intItemId=AS28.intItemId  and S.intLocationId=AS28.intLocationId


	SELECT @strXML = @strXML + '<DocNo>' + ltrim(AS7.intItemId) + '</DocNo>'
		+ '<MsgType>Contracted_Stock</MsgType>'  
		+'<Sender>iRely</Sender>' 
		+'<Receiver>ICRON</Receiver>'
		+ '<ItemCode>' +  I.strItemNo + '</ItemCode>' 
		+ '<BuyingCenter>' +  CL.strLocationName + '</BuyingCenter>' 
		+ '<LastWeekDate>' + CONVERT(VARCHAR(33), GETDATE()-7, 126) + '</LastWeekDate>' 
		+ '<Currency>' + ltrim(C.strCurrency)+ '</Currency>' 
		+ '<LastWeekPrice>' +  ltrim(AS7.dblLastWeekPrice) + '</LastWeekPrice>' 
		+ '<LastWeekBought>' +  ltrim(AS7.dblLastWeekBought) + '</LastWeekBought>' 
		+ '<LastWeekAvailable>' + ltrim(AS7.dblLastWeekAvailable) + '</LastWeekAvailable>' 
		+ '<LastWeekPressure>' + ltrim(AS7.dblLastWeekPressure)+ '</LastWeekPressure>'
		+ '<Last4WeekPrice>' +  ltrim(AS28.dblLastWeekPrice) + '</Last4WeekPrice>' 
		+ '<Last4WeekBought>' +  ltrim(AS28.dblLastWeekBought) + '</Last4WeekBought>' 
		+ '<Last4WeekAvailable>' + ltrim(AS28.dblLastWeekAvailable) + '</Last4WeekAvailable>' 
		+ '<Last4WeekPressure>' + ltrim(AS28.dblLastWeekPressure)+ '</Last4WeekPressure>'
	FROM @tblIPAuctionStock7 AS7
	JOIN @tblIPAuctionStock28 AS28 ON AS28.intItemId = AS7.intItemId
		AND AS28.intLocationId = AS7.intLocationId
	JOIN tblICItem I ON I.intItemId = AS7.intItemId
	JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = AS7.intLocationId
	JOIN tblSMCurrency C ON C.intCurrencyID = AS7.intCurrencyId

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