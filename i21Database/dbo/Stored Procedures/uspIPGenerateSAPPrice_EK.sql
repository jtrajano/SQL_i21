CREATE PROCEDURE dbo.uspIPGenerateSAPPrice_EK (@ysnUpdateFeedStatus BIT = 1)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strError NVARCHAR(MAX) = ''
	DECLARE @strXML NVARCHAR(MAX) = ''
		,@strItemXML NVARCHAR(MAX) = ''
		,@strRootXML NVARCHAR(MAX) = ''
		,@strFinalXML NVARCHAR(MAX) = ''
		,@dtmCurrentDate DATETIME
		,@intDocID INT
		,@intPriceFeedId INT
	DECLARE @tblIPPriceFeed TABLE (intPriceFeedId INT)
	DECLARE @strPurchGroup NVARCHAR(50)
		,@strChannel NVARCHAR(50)
		,@strIncoTerms NVARCHAR(50)
		,@strOrigin NVARCHAR(50)
		,@strAuctionCenter NVARCHAR(50)
		,@strSupplier NVARCHAR(50)
		,@strPlant NVARCHAR(50)
		,@strStorageLocation NVARCHAR(50)
		,@strLoadingPort NVARCHAR(50)
		,@strDestinationPort NVARCHAR(50)
		,@dblCashPrice NUMERIC(18, 6)
		,@strCurrency NVARCHAR(50)
		,@dblQuantity NUMERIC(18, 6)
		,@strContainerType NVARCHAR(50)
		,@strShippingLine NVARCHAR(50)
		,@dtmPricingDate DATETIME
	DECLARE @PriceFeedId TABLE (intPriceFeedId INT)
	DECLARE @tblOutput AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intPriceFeedId INT
		,strRowState NVARCHAR(50)
		,strXML NVARCHAR(MAX)
		,strInfo1 NVARCHAR(100)
		,strInfo2 NVARCHAR(100)
		)
	DECLARE @tmp INT

	SELECT @tmp = strValue
	FROM tblIPSAPIDOCTag
	WHERE strMessageType = 'Price Simulation'
		AND strTag = 'Count'

	IF ISNULL(@tmp, 0) = 0
		SELECT @tmp = 100

	DELETE
	FROM @PriceFeedId

	DELETE
	FROM @tblIPPriceFeed

	SELECT @intDocID = NULL

	INSERT INTO @tblIPPriceFeed (intPriceFeedId)
	SELECT DISTINCT TOP (@tmp) PF.intPriceFeedId
	FROM dbo.tblIPPriceFeed PF WITH (NOLOCK)
	WHERE PF.intStatusId IS NULL

	SELECT @intPriceFeedId = MIN(intPriceFeedId)
	FROM @tblIPPriceFeed

	IF @intPriceFeedId IS NULL
	BEGIN
		RETURN
	END

	UPDATE tblIPPriceFeed
	SET intStatusId = - 1
	WHERE intPriceFeedId IN (
			SELECT intPriceFeedId
			FROM @tblIPPriceFeed
			)

	WHILE @intPriceFeedId IS NOT NULL
	BEGIN
		SELECT @strError = ''

		SELECT @strPurchGroup = NULL
			,@strChannel = NULL
			,@strIncoTerms = NULL
			,@strOrigin = NULL
			,@strAuctionCenter = NULL
			,@strSupplier = NULL
			,@strPlant = NULL
			,@strStorageLocation = NULL
			,@strLoadingPort = NULL
			,@strDestinationPort = NULL
			,@dblCashPrice = NULL
			,@strCurrency = NULL
			,@dblQuantity = NULL
			,@strContainerType = NULL
			,@strShippingLine = NULL
			,@dtmPricingDate = NULL

		SELECT @strPurchGroup = strPurchGroup
			,@strChannel = strChannel
			,@strIncoTerms = strIncoTerms
			,@strOrigin = strOrigin
			,@strAuctionCenter = strAuctionCenter
			,@strSupplier = strSupplier
			,@strPlant = strPlant
			,@strStorageLocation = strStorageLocation
			,@strLoadingPort = strLoadingPort
			,@strDestinationPort = strDestinationPort
			,@dblCashPrice = dblCashPrice
			,@strCurrency = strCurrency
			,@dblQuantity = dblQuantity
			,@strContainerType = strContainerType
			,@strShippingLine = strShippingLine
			,@dtmPricingDate = dtmPricingDate
		FROM dbo.tblIPPriceFeed WITH (NOLOCK)
		WHERE intPriceFeedId = @intPriceFeedId

		IF ISNULL(@strPurchGroup, '') = ''
		BEGIN
			SELECT @strError = @strError + 'Purchasing Group cannot be blank. '
		END

		IF ISNULL(@strChannel, '') = ''
		BEGIN
			SELECT @strError = @strError + 'Channel cannot be blank. '
		END

		IF ISNULL(@strOrigin, '') = ''
		BEGIN
			SELECT @strError = @strError + 'Origin cannot be blank. '
		END

		IF ISNULL(@strSupplier, '') = ''
		BEGIN
			SELECT @strError = @strError + 'Supplier cannot be blank. '
		END

		IF ISNULL(@strPlant, '') = ''
		BEGIN
			SELECT @strError = @strError + 'Book cannot be blank. '
		END

		IF ISNULL(@strStorageLocation, '') = ''
		BEGIN
			SELECT @strError = @strError + 'Storage Location cannot be blank. '
		END

		IF ISNULL(@strLoadingPort, '') = ''
		BEGIN
			SELECT @strError = @strError + 'Loading Port cannot be blank. '
		END

		IF ISNULL(@strCurrency, '') = ''
		BEGIN
			SELECT @strError = @strError + 'Currency cannot be blank. '
		END

		IF ISNULL(@dblQuantity, 0) = 0
		BEGIN
			SELECT @strError = @strError + 'Quantity cannot be blank. '
		END

		IF ISNULL(@strIncoTerms, '') = ''
		BEGIN
			SELECT @strError = @strError + 'Inco Terms cannot be blank. '
		END

		IF ISNULL(@strDestinationPort, '') = ''
		BEGIN
			SELECT @strError = @strError + 'Destination Port cannot be blank. '
		END

		IF ISNULL(@strContainerType, '') = ''
		BEGIN
			SELECT @strError = @strError + 'Container Type cannot be blank. '
		END

		IF ISNULL(@strShippingLine, '') = ''
		BEGIN
			SELECT @strError = @strError + 'Shipping Line cannot be blank. '
		END

		IF @strError <> ''
		BEGIN
			UPDATE dbo.tblIPPriceFeed
			SET strMessage = @strError
				,intStatusId = 1
			WHERE intPriceFeedId = @intPriceFeedId

			GOTO NextRec
		END

		SELECT @strXML = ''

		SELECT @strXML += '<Header>'

		SELECT @strXML += '<ReferenceNo>' + LTRIM(@intPriceFeedId) + '</ReferenceNo>'

		SELECT @strXML += '<PurchGroup>' + ISNULL(@strPurchGroup, '') + '</PurchGroup>'

		SELECT @strXML += '<Channel>' + ISNULL(@strChannel, '') + '</Channel>'

		SELECT @strXML += '<IncoTerms>' + ISNULL(@strIncoTerms, '') + '</IncoTerms>'

		SELECT @strXML += '<Origin>' + ISNULL(@strOrigin, '') + '</Origin>'

		SELECT @strXML += '<AuctionCenter>' + ISNULL(@strAuctionCenter, '') + '</AuctionCenter>'

		SELECT @strXML += '<Supplier>' + ISNULL(@strSupplier, '') + '</Supplier>'

		SELECT @strXML += '<Plant>' + ISNULL(@strPlant, '') + '</Plant>'

		SELECT @strXML += '<StorageLocation>' + LTRIM(SUBSTRING(ISNULL(@strStorageLocation, ''), CHARINDEX('/', @strStorageLocation) + 1, LEN(@strStorageLocation))) + '</StorageLocation>'

		SELECT @strXML += '<LoadingPort>' + ISNULL(@strLoadingPort, '') + '</LoadingPort>'

		SELECT @strXML += '<DestinationPort>' + ISNULL(@strDestinationPort, '') + '</DestinationPort>'

		SELECT @strXML += '<CashPrice>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(@dblCashPrice, 0))) + '</CashPrice>'

		SELECT @strXML += '<Currency>' + ISNULL(@strCurrency, '') + '</Currency>'

		SELECT @strXML += '<Quantity>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(@dblQuantity, 0))) + '</Quantity>'

		SELECT @strXML += '<ContainerType>' + ISNULL(@strContainerType, '') + '</ContainerType>'

		SELECT @strXML += '<ShippingLine>' + ISNULL(@strShippingLine, '') + '</ShippingLine>'

		SELECT @strXML += '<PricingDate>' + ISNULL(CONVERT(VARCHAR(33), @dtmPricingDate, 126), '') + '</PricingDate>'

		IF ISNULL(@strXML, '') = ''
		BEGIN
			UPDATE tblIPPriceFeed
			SET strMessage = 'XML is not available. '
				,intStatusId = 1
			WHERE intPriceFeedId = @intPriceFeedId

			GOTO NextRec
		END

		IF ISNULL(@strXML, '') <> ''
		BEGIN
			SELECT @strItemXML += @strXML + '</Header>'
		END

		INSERT INTO @PriceFeedId (intPriceFeedId)
		SELECT @intPriceFeedId

		IF @ysnUpdateFeedStatus = 1
		BEGIN
			UPDATE tblIPPriceFeed
			SET intStatusId = 2
				,strMessage = NULL
				,strFeedStatus = 'Awt Ack'
			WHERE intPriceFeedId = @intPriceFeedId
		END

		NextRec:

		SELECT @intPriceFeedId = MIN(intPriceFeedId)
		FROM @tblIPPriceFeed
		WHERE intPriceFeedId > @intPriceFeedId
	END

	IF @strItemXML <> ''
	BEGIN
		SELECT @intDocID = ISNULL(MAX(intPriceFeedId), 1)
		FROM @tblIPPriceFeed

		SELECT @strRootXML = '<DocNo>' + LTRIM(@intDocID) + '</DocNo>'

		SELECT @strRootXML += '<MsgType>Price_Simulation</MsgType>'

		SELECT @strRootXML += '<Sender>iRely</Sender>'

		SELECT @strRootXML += '<Receiver>SAP</Receiver>'

		SELECT @strFinalXML = '<root>' + @strRootXML + @strItemXML + '</root>'

		IF EXISTS (
				SELECT 1
				FROM @PriceFeedId
				)
		BEGIN
			UPDATE F
			SET F.intDocNo = @intDocID
				,F.intReferenceNo = FS.intPriceFeedId
			FROM tblIPPriceFeed F
			JOIN @PriceFeedId FS ON FS.intPriceFeedId = F.intPriceFeedId
		END

		DELETE
		FROM @tblOutput

		INSERT INTO @tblOutput (
			intPriceFeedId
			,strRowState
			,strXML
			,strInfo1
			,strInfo2
			)
		VALUES (
			@intPriceFeedId
			,'Modified'
			,@strFinalXML
			,ISNULL(@strPurchGroup, '')
			,ISNULL(@strChannel, '')
			)
	END

	UPDATE tblIPPriceFeed
	SET intStatusId = NULL
	WHERE intPriceFeedId IN (
			SELECT intPriceFeedId
			FROM @tblIPPriceFeed
			)
		AND intStatusId = - 1

	SELECT ISNULL(intPriceFeedId, '0') AS id
		,ISNULL(strXML, '') AS strXml
		,ISNULL(strInfo1, '') AS strInfo1
		,ISNULL(strInfo2, '') AS strInfo2
		,'' AS strOnFailureCallbackSql
	FROM @tblOutput
	ORDER BY intRowNo
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
