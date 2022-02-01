CREATE PROCEDURE dbo.uspIPGenerateERPCO (
	@strCompanyLocation NVARCHAR(6) = NULL
	,@ysnUpdateFeedStatus BIT = 1
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strRowState NVARCHAR(50)
		,@strUserName NVARCHAR(50)
		,@strError NVARCHAR(MAX) = ''
		,@strXML NVARCHAR(MAX) = ''
		,@strFinalXML NVARCHAR(MAX) = ''
	DECLARE @intContractFeedId INT
		,@intContractDetailId INT
		,@intContractHeaderId INT
		,@strContractNumber NVARCHAR(100)
		,@strERPCONumber NVARCHAR(100)
		,@strBook NVARCHAR(100)
		,@strCustomerContract NVARCHAR(50)
		,@intBookId INT
	DECLARE @strQuantityUOM NVARCHAR(50)
		,@strDefaultCurrency NVARCHAR(40)
		,@intCurrencyId INT
		,@intUnitMeasureId INT
		,@intItemId INT
		,@intItemUOMId INT
	DECLARE @intActionId INT
		,@dtmContractDate DATETIME
		,@strCustomerPrefix NVARCHAR(100)
		,@strTermCode NVARCHAR(50)
		,@dtmStartDate DATETIME
		,@dtmEndDate DATETIME
		,@dblQuantity NUMERIC(18, 6)
		,@strFuturesMarket NVARCHAR(30)
		,@strFuturesMonth NVARCHAR(30)
		,@intNoOfLots INT
		,@dblFuturesPrice NUMERIC(18, 6)
		,@dblFXRate NUMERIC(18, 6)
		,@strFXCurrency NVARCHAR(40)
		,@strRefFuturesMarket NVARCHAR(30)
		,@strRefFuturesMonth NVARCHAR(30)
		,@dblRefFuturesPrice NUMERIC(18, 6)
		,@strSubBook NVARCHAR(50)
		,@dblQuantityPerLot NUMERIC(18, 6)
		,@ERPCONumber NVARCHAR(50)
	DECLARE @intPricingTypeId INT
		,@intFutureMarketId INT
		,@intFutureMonthId INT
		,@intDestinationPortId INT
		,@intShipperId INT
		,@intCompanyLocationId INT
		,@intContractStatusId INT
		,@dtmUpdatedAvailabilityDate DATETIME
		,@intSubBookId INT
	DECLARE @tblOutput AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intContractFeedId INT
		,strRowState NVARCHAR(50)
		,strXML NVARCHAR(MAX)
		,strContractNumber NVARCHAR(100)
		,strERPPONumber NVARCHAR(100)
		)
	DECLARE @tblCTContractFeed TABLE (intContractFeedId INT)

	EXEC uspIPValidateERPOtherFieldsContractFeed

	IF NOT EXISTS (
			SELECT 1
			FROM tblCTContractFeed
			WHERE intStatusId IS NULL
			)
	BEGIN
		RETURN
	END

	DECLARE @tmp INT

	SELECT @tmp = strValue
	FROM tblIPSAPIDOCTag
	WHERE strMessageType = 'CO'
		AND strTag = 'Count'

	IF ISNULL(@tmp, 0) = 0
		SELECT @tmp = 50

	DELETE
	FROM @tblCTContractFeed

	INSERT INTO @tblCTContractFeed (intContractFeedId)
	SELECT TOP (@tmp) CF.intContractFeedId
	FROM tblCTContractFeed CF
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CF.intContractHeaderId
		AND CF.intStatusId IS NULL
		AND CH.intContractTypeId = 2
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = CF.intContractDetailId
	JOIN tblARCustomer C ON C.intEntityId = CH.intEntityId
		AND ISNULL(C.strLinkCustomerNumber, '') = @strCompanyLocation

	SELECT @intContractFeedId = MIN(intContractFeedId)
	FROM @tblCTContractFeed

	IF @intContractFeedId IS NULL
	BEGIN
		RETURN
	END

	UPDATE tblCTContractFeed
	SET intStatusId = - 1
	WHERE intContractFeedId IN (
			SELECT intContractFeedId
			FROM @tblCTContractFeed
			)

	WHILE @intContractFeedId IS NOT NULL
	BEGIN
		SELECT @strRowState = NULL
			,@strUserName = NULL
			,@strError = ''
			,@strXML = ''

		SELECT @intContractDetailId = NULL
			,@intContractHeaderId = NULL
			,@strContractNumber = NULL
			,@strERPCONumber = NULL
			,@strBook = NULL
			,@strCustomerContract = NULL
			,@intBookId = NULL

		SELECT @strQuantityUOM = NULL
			,@strDefaultCurrency = NULL
			,@intCurrencyId = NULL
			,@intUnitMeasureId = NULL
			,@intItemId = NULL
			,@intItemUOMId = NULL

		SELECT @intActionId = NULL
			,@dtmContractDate = NULL
			,@strCustomerPrefix = NULL
			,@strTermCode = NULL
			,@dtmStartDate = NULL
			,@dtmEndDate = NULL
			,@dblQuantity = NULL
			,@strFuturesMarket = NULL
			,@strFuturesMonth = NULL
			,@intNoOfLots = NULL
			,@dblFuturesPrice = NULL
			,@dblFXRate = NULL
			,@strFXCurrency = NULL
			,@strRefFuturesMarket = NULL
			,@strRefFuturesMonth = NULL
			,@dblRefFuturesPrice = NULL
			,@strSubBook = NULL
			,@dblQuantityPerLot = NULL
			,@ERPCONumber = NULL

		SELECT @intPricingTypeId = NULL
			,@intFutureMarketId = NULL
			,@intFutureMonthId = NULL
			,@intDestinationPortId = NULL
			,@intShipperId = NULL
			,@intCompanyLocationId = NULL
			,@intContractStatusId = NULL
			,@dtmUpdatedAvailabilityDate = NULL
			,@intSubBookId = NULL

		SELECT @intContractDetailId = intContractDetailId
			,@intContractHeaderId = intContractHeaderId
			,@strContractNumber = strContractNumber
			,@strERPCONumber = strERPPONumber
			,@strRowState = strRowState
			,@strUserName = strCreatedBy
			,@intItemId = intItemId
		FROM dbo.tblCTContractFeed
		WHERE intContractFeedId = @intContractFeedId

		SELECT @intBookId = intBookId
			,@strCustomerContract = strCustomerContract
			,@intSubBookId = intSubBookId
		FROM dbo.tblCTContractHeader
		WHERE intContractHeaderId = @intContractHeaderId

		SELECT @strBook = strBook
		FROM dbo.tblCTBook
		WHERE intBookId = @intBookId

		-- Add all the extra columns which are not avail in feed table
		IF NOT EXISTS (
				SELECT 1
				FROM tblIPThirdPartyContractFeed
				WHERE intContractFeedId = @intContractFeedId
				)
			INSERT INTO tblIPThirdPartyContractFeed (
				intContractFeedId
				,strERPPONumber
				,strRowState
				,strBook
				)
			SELECT @intContractFeedId
				,@strERPCONumber
				,@strRowState
				,@strBook

		SELECT @strBook = strBook
		FROM tblIPThirdPartyContractFeed
		WHERE intContractFeedId = @intContractFeedId

		SELECT @strQuantityUOM = strQuantityUOM
			,@strDefaultCurrency = strDefaultCurrency
		FROM tblIPCompanyPreference

		SELECT @intCurrencyId = intCurrencyID
		FROM tblSMCurrency
		WHERE strCurrency = @strDefaultCurrency

		IF @intCurrencyId IS NULL
		BEGIN
			SELECT TOP 1 @intCurrencyId = intCurrencyID
				,@strDefaultCurrency = strCurrency
			FROM tblSMCurrency
			WHERE strCurrency LIKE '%USD%'
		END

		SELECT @intUnitMeasureId = IUOM.intUnitMeasureId
			,@intItemUOMId = IUOM.intItemUOMId
		FROM tblICUnitMeasure UOM
		JOIN tblICItemUOM IUOM ON IUOM.intUnitMeasureId = UOM.intUnitMeasureId
			AND IUOM.intItemId = @intItemId
			AND UOM.strUnitMeasure = @strQuantityUOM

		IF @intUnitMeasureId IS NULL
		BEGIN
			SELECT TOP 1 @intItemUOMId = IUOM.intItemUOMId
				,@intUnitMeasureId = IUOM.intUnitMeasureId
				,@strQuantityUOM = UOM.strUnitMeasure
			FROM dbo.tblICItemUOM IUOM
			JOIN dbo.tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId
				AND IUOM.intItemId = @intItemId
				AND IUOM.ysnStockUnit = 1
		END

		SELECT @intPricingTypeId = intPricingTypeId
			,@intFutureMarketId = intFutureMarketId
			,@intFutureMonthId = intFutureMonthId
			,@intDestinationPortId = intDestinationPortId
			,@intShipperId = intShipperId
			,@intCompanyLocationId = intCompanyLocationId
			,@intContractStatusId = intContractStatusId
			,@dtmUpdatedAvailabilityDate = dtmUpdatedAvailabilityDate
		FROM dbo.tblCTContractDetail WITH (NOLOCK)
		WHERE intContractDetailId = @intContractDetailId

		SELECT @strContractNumber = CF.strContractNumber
			,@dtmContractDate = CF.dtmContractDate
			,@strCustomerPrefix = E.strExternalERPId
			,@strTermCode = CF.strTermCode
			,@dtmStartDate = CF.dtmStartDate
			,@dtmEndDate = CF.dtmEndDate
			,@dblQuantity = CONVERT(NUMERIC(18, 6), ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, @intItemUOMId, CF.dblQuantity), 0))
			,@strFuturesMarket = FM.strFutMarketName
			,@strFuturesMonth = FMO.strFutureMonth
			,@intNoOfLots = ISNULL(CONVERT(INT, CD.dblNoOfLots), 0)
			,@dblFuturesPrice = CONVERT(NUMERIC(18, 6), ISNULL(dbo.fnRKConvertUOMCurrency('ItemUOM', CD.intPriceItemUOMId, @intItemUOMId, 1, CD.intCurrencyId, @intCurrencyId, CD.dblFutures, NULL), 0))
			,@dblFXRate = ISNULL(CD.dblRate, 1)
			,@strFXCurrency = C.strCurrency
			,@strRefFuturesMarket = RFM.strFutMarketName
			,@strRefFuturesMonth = RFMO.strFutureMonth
			,@dblRefFuturesPrice = CONVERT(NUMERIC(18, 6), ISNULL(dbo.fnRKConvertUOMCurrency('ItemUOM', CD.intRefFuturesItemUOMId, @intItemUOMId, 1, CD.intRefFuturesCurrencyId, @intCurrencyId, CD.dblRefFuturesQty, NULL), 0))
			,@strSubBook = SB.strSubBook
			,@dblQuantityPerLot = CONVERT(NUMERIC(18, 6), ISNULL(dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, FM.intUnitMeasureId, @intUnitMeasureId, RWC.dblQuantityPerLot), 0))
			,@ERPCONumber = CF.strERPPONumber
		FROM dbo.tblCTContractFeed CF
		JOIN dbo.tblCTContractHeader CH ON CH.intContractHeaderId = CF.intContractHeaderId
			AND CF.intContractFeedId = @intContractFeedId
		JOIN dbo.tblCTContractDetail CD ON CD.intContractDetailId = CF.intContractDetailId
		LEFT JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
		LEFT JOIN dbo.tblRKFutureMarket FM ON FM.intFutureMarketId = CD.intFutureMarketId
		LEFT JOIN dbo.tblRKFuturesMonth FMO ON FMO.intFutureMonthId = CD.intFutureMonthId
		LEFT JOIN dbo.tblSMCurrency C ON C.intCurrencyID = CD.intInvoiceCurrencyId
		LEFT JOIN dbo.tblRKFutureMarket RFM ON RFM.intFutureMarketId = CD.intRefFuturesMarketId
		LEFT JOIN dbo.tblRKFuturesMonth RFMO ON RFMO.intFutureMonthId = CD.intRefFuturesMonthId
		LEFT JOIN dbo.tblCTSubBook SB ON SB.intSubBookId = CH.intSubBookId
		LEFT JOIN tblCTRawToWipConversion RWC ON RWC.intBookId = CH.intBookId
			AND RWC.intSubBookId = CH.intSubBookId
			AND RWC.intFuturesMarketId = CD.intFutureMarketId

		IF ISNULL(@strCustomerPrefix, '') = ''
		BEGIN
			SELECT @strError = @strError + 'Customer Prefix cannot be blank. '
		END

		IF ISNULL(@dblQuantity, 0) = 0
		BEGIN
			SELECT @strError = @strError + 'Quantity cannot be blank. '
		END

		IF @strError <> ''
		BEGIN
			UPDATE dbo.tblCTContractFeed
			SET strMessage = @strError
				,intStatusId = 1
			WHERE intContractFeedId = @intContractFeedId

			GOTO NextPO
		END

		BEGIN
			IF @strRowState <> 'Added'
				AND IsNULL(@strERPCONumber, '') = ''
			BEGIN
				UPDATE dbo.tblCTContractFeed
				SET strMessage = 'ERP PO Number is not available. '
				WHERE intContractFeedId = @intContractFeedId

				GOTO NextPO
			END

			-- If previous feed is waiting for acknowledgement then do not send the current feed
			IF EXISTS (
					SELECT TOP 1 1
					FROM tblCTContractFeed CF
					JOIN tblCTContractDetail CD ON CD.intContractDetailId = CF.intContractDetailId
						AND CD.intContractDetailId = @intContractDetailId
					JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CF.intContractHeaderId
					JOIN tblARCustomer C ON C.intEntityId = CH.intEntityId
						AND ISNULL(C.strLinkCustomerNumber, '') = @strCompanyLocation
						AND CF.intContractFeedId < @intContractFeedId
						AND intStatusId = 2
					ORDER BY CF.intContractFeedId DESC
					)
			BEGIN
				UPDATE dbo.tblCTContractFeed
				SET strMessage = 'Previous feed is waiting for acknowledgement. '
				WHERE intContractFeedId = @intContractFeedId

				GOTO NextPO
			END

			IF NOT EXISTS (
					SELECT 1
					FROM tblCTContractDetail
					WHERE intContractDetailId = @intContractDetailId
					)
			BEGIN
				UPDATE dbo.tblCTContractFeed
				SET strMessage = 'Contract Seq not available. '
					,intStatusId = 1
				WHERE intContractFeedId = @intContractFeedId

				GOTO NextPO
			END
			ELSE
			BEGIN
				SELECT @intActionId = (
						CASE 
							WHEN @strRowState = 'Added'
								THEN 1
							WHEN @strRowState = 'Modified'
								THEN 2
							ELSE 3
							END
						)
			END

			SELECT @strXML = '<header id="' + LTRIM(@intContractFeedId) + '">'

			SELECT @strXML += '<TrxSequenceNo>' + LTRIM(@intContractFeedId) + '</TrxSequenceNo>'

			SELECT @strXML += '<CompanyLocation>' + LTRIM(@strCompanyLocation) + '</CompanyLocation>'

			SELECT @strXML += '<ActionId>' + LTRIM(@intActionId) + '</ActionId>'

			SELECT @strXML += '<CreatedDate>' + CONVERT(VARCHAR(33), GetDate(), 126) + '</CreatedDate>'

			SELECT @strXML += '<CreatedByUser>' + @strUserName + '</CreatedByUser>'

			SELECT @strXML += '<ContractNo>' + @strContractNumber + '</ContractNo>'

			SELECT @strXML += '<ContractDate>' + ISNULL(convert(VARCHAR, @dtmContractDate, 112), '') + '</ContractDate>'

			SELECT @strXML += '<CustomerPrefix>' + @strCustomerPrefix + '</CustomerPrefix>'

			SELECT @strXML += '<TermsCode>' + ISNULL(@strTermCode, '') + '</TermsCode>'

			SELECT @strXML += '<StartDate>' + ISNULL(CONVERT(VARCHAR, @dtmStartDate, 112), '') + '</StartDate>'

			SELECT @strXML += '<EndDate>' + ISNULL(CONVERT(VARCHAR, @dtmEndDate, 112), '') + '</EndDate>'

			SELECT @strXML += '<Quantity>' + LTRIM(@dblQuantity) + '</Quantity>'

			SELECT @strXML += '<QuantityUOM>' + @strQuantityUOM + '</QuantityUOM>'

			SELECT @strXML += '<FuturesMarket>' + ISNULL(@strFuturesMarket, '') + '</FuturesMarket>'

			SELECT @strXML += '<FuturesMonth>' + ISNULL(@strFuturesMonth, '') + '</FuturesMonth>'

			SELECT @strXML += '<Lots>' + LTRIM(@intNoOfLots) + '</Lots>'

			SELECT @strXML += '<FuturesPrice>' + LTRIM(@dblFuturesPrice) + '</FuturesPrice>'

			SELECT @strXML += '<PriceUOM>' + @strQuantityUOM + '</PriceUOM>'

			SELECT @strXML += '<PriceCurrency>' + @strDefaultCurrency + '</PriceCurrency>'

			SELECT @strXML += '<FXRate>' + LTRIM(@dblFXRate) + '</FXRate>'

			SELECT @strXML += '<FXCurrency>' + ISNULL(@strFXCurrency, '') + '</FXCurrency>'

			SELECT @strXML += '<ReferenceFuturesMarket>' + ISNULL(@strRefFuturesMarket, '') + '</ReferenceFuturesMarket>'

			SELECT @strXML += '<ReferenceFuturesMonth>' + ISNULL(@strRefFuturesMonth, '') + '</ReferenceFuturesMonth>'

			SELECT @strXML += '<ReferenceFuturesPrice>' + LTRIM(@dblRefFuturesPrice) + '</ReferenceFuturesPrice>'

			SELECT @strXML += '<ReferencePriceUOM>' + @strQuantityUOM + '</ReferencePriceUOM>'

			SELECT @strXML += '<ReferencePriceCurrency>' + @strDefaultCurrency + '</ReferencePriceCurrency>'

			SELECT @strXML += '<Book>' + ISNULL(@strBook, '') + '</Book>'

			SELECT @strXML += '<Sub-Book>' + ISNULL(@strSubBook, '') + '</Sub-Book>'

			SELECT @strXML += '<QuantityPerLot>' + LTRIM(@dblQuantityPerLot) + '</QuantityPerLot>'

			SELECT @strXML += '<QuantityPerLotUOM>' + @strQuantityUOM + '</QuantityPerLotUOM>'

			SELECT @strXML += '<ERPCONumber>' + ISNULL(@ERPCONumber, '') + '</ERPCONumber>'

			IF IsNULL(@strXML, '') <> ''
			BEGIN
				SELECT @strFinalXML = @strFinalXML + @strXML + '</header>'

				DELETE
				FROM dbo.tblIPContractFeedLog
				WHERE intContractDetailId = @intContractDetailId

				-- Keep the latest record value in this table
				INSERT INTO dbo.tblIPContractFeedLog (
					intContractHeaderId
					,intContractDetailId
					,strCustomerContract
					,intShipperId
					,intDestinationPortId
					,intCompanyLocationId
					,intHeaderBookId
					,intContractStatusId
					,dtmUpdatedAvailabilityDate
					,intSubBookId
					)
				SELECT @intContractHeaderId
					,@intContractDetailId
					,@strCustomerContract
					,@intShipperId
					,@intDestinationPortId
					,@intCompanyLocationId
					,@intBookId
					,@intContractStatusId
					,@dtmUpdatedAvailabilityDate
					,@intSubBookId
			END
			ELSE
			BEGIN
				UPDATE dbo.tblCTContractFeed
				SET strMessage = 'XML not available. '
					,intStatusId = 1
				WHERE intContractFeedId = @intContractFeedId

				GOTO NextPO
			END
		END

		IF @ysnUpdateFeedStatus = 1
		BEGIN
			UPDATE tblCTContractFeed
			SET intStatusId = 2
				,strMessage = NULL
				,strFeedStatus = 'Awt Ack'
			WHERE intContractFeedId = @intContractFeedId

			UPDATE tblCTContractHeader
			SET ysnExported = 1
				,dtmExported = GETDATE()
			WHERE intContractHeaderId = @intContractHeaderId
		END

		NextPO:

		SELECT @intContractFeedId = MIN(intContractFeedId)
		FROM @tblCTContractFeed
		WHERE intContractFeedId > @intContractFeedId
	END

	IF @strFinalXML <> ''
	BEGIN
		SELECT @strFinalXML = '<root><data>' + @strFinalXML + '</data></root>'

		DELETE
		FROM @tblOutput

		INSERT INTO @tblOutput (
			intContractFeedId
			,strRowState
			,strXML
			,strContractNumber
			,strERPPONumber
			)
		VALUES (
			@intContractFeedId
			,@strRowState
			,@strFinalXML
			,ISNULL(@strContractNumber, '')
			,ISNULL(@strERPCONumber, '')
			)
	END

	UPDATE tblCTContractFeed
	SET intStatusId = NULL
	WHERE intContractFeedId IN (
			SELECT intContractFeedId
			FROM @tblCTContractFeed
			)
		AND intStatusId = - 1

	SELECT IsNULL(intContractFeedId, '0') AS id
		,IsNULL(strXML, '') AS strXml
		,IsNULL(strContractNumber, '') AS strInfo1
		,IsNULL(strERPPONumber, '') AS strInfo2
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
