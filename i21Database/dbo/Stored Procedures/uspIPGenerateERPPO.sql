CREATE PROCEDURE dbo.uspIPGenerateERPPO (
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
		,@strDetailXML NVARCHAR(MAX) = ''
		,@strFinalXML NVARCHAR(MAX) = ''
	DECLARE @intContractFeedId INT
		,@intContractDetailId INT
		,@intContractHeaderId INT
		,@strContractNumber NVARCHAR(100)
		,@strERPPONumber NVARCHAR(100)
		,@strVendorAccountNum NVARCHAR(100)
		,@strBook NVARCHAR(100)
		,@strCommodityCode NVARCHAR(50)
		,@strCustomerContract NVARCHAR(50)
		,@intBookId INT
		,@intCurrencyId INT
		,@strCurrency NVARCHAR(40)
	DECLARE @intActionId INT
		,@intContractStatusId INT
		,@dtmPlannedAvailabilityDate DATETIME
		,@dtmUpdatedAvailabilityDate DATETIME
		,@strSubLocation NVARCHAR(50)
		,@dblQuantity NUMERIC(18, 6)
		,@strPricingType NVARCHAR(50)
		,@dtmFixationDate DATETIME
		,@strCertificate NVARCHAR(MAX) = ''
	DECLARE @intPricingTypeId INT
		,@intFutureMarketId INT
		,@intFutureMonthId INT
		,@intDestinationPortId INT
		,@intShipperId INT
		,@intCompanyLocationId INT
	DECLARE @tblOutput AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intContractFeedId INT
		,strRowState NVARCHAR(50)
		,strXML NVARCHAR(MAX)
		,strContractNumber NVARCHAR(100)
		,strERPPONumber NVARCHAR(100)
		)
	DECLARE @tblCTContractFeed TABLE (intContractFeedId INT)

	IF NOT EXISTS (
			SELECT 1
			FROM tblCTContractFeed
			WHERE intStatusId IS NULL
			)
	BEGIN
		RETURN
	END

	DELETE
	FROM @tblCTContractFeed

	INSERT INTO @tblCTContractFeed (intContractFeedId)
	SELECT TOP 50 CF.intContractFeedId
	FROM tblCTContractFeed CF
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CF.intContractHeaderId
		AND CF.intStatusId IS NULL
		AND CH.intContractTypeId = 1
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = CF.intContractDetailId
	JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
		AND CL.strLotOrigin = @strCompanyLocation

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
			,@strDetailXML = ''

		SELECT @intContractDetailId = NULL
			,@intContractHeaderId = NULL
			,@strContractNumber = NULL
			,@strERPPONumber = NULL
			,@strVendorAccountNum = NULL
			,@strBook = NULL
			,@strCommodityCode = NULL
			,@strCustomerContract = NULL
			,@intBookId = NULL

		SELECT @intActionId = NULL
			,@intContractStatusId = NULL
			,@dtmPlannedAvailabilityDate = NULL
			,@dtmUpdatedAvailabilityDate = NULL
			,@strSubLocation = NULL
			,@dblQuantity = NULL
			,@strPricingType = NULL
			,@dtmFixationDate = NULL
			,@strCertificate = ''

		SELECT @intPricingTypeId = NULL
			,@intFutureMarketId = NULL
			,@intFutureMonthId = NULL
			,@intDestinationPortId = NULL
			,@intShipperId = NULL
			,@intCompanyLocationId = NULL

		SELECT @intContractDetailId = intContractDetailId
			,@intContractHeaderId = intContractHeaderId
			,@strContractNumber = strContractNumber
			,@strERPPONumber = strERPPONumber
			,@strRowState = strRowState
			,@strUserName = strCreatedBy
			,@strVendorAccountNum = strVendorAccountNum
			,@strCommodityCode = strCommodityCode
			,@dtmPlannedAvailabilityDate = dtmPlannedAvailabilityDate
			,@strSubLocation = strSubLocation
			,@dblQuantity = dblQuantity
		FROM dbo.tblCTContractFeed
		WHERE intContractFeedId = @intContractFeedId

		SELECT TOP 1 @intCurrencyId = intCurrencyID
			,@strCurrency = strCurrency
		FROM tblSMCurrency
		WHERE strCurrency LIKE '%USD%'

		SELECT @intBookId = intBookId
			,@strCustomerContract = strCustomerContract
		FROM dbo.tblCTContractHeader
		WHERE intContractHeaderId = @intContractHeaderId

		SELECT @strBook = strBook
		FROM dbo.tblCTBook
		WHERE intBookId = @intBookId

		SELECT @dtmUpdatedAvailabilityDate = CD.dtmUpdatedAvailabilityDate
			,@strPricingType = PT.strPricingType
		FROM tblCTContractDetail CD WITH (NOLOCK)
		JOIN tblCTPricingType PT WITH (NOLOCK) ON PT.intPricingTypeId = CD.intPricingTypeId
		WHERE CD.intContractDetailId = @intContractDetailId

		SELECT @intPricingTypeId = intPricingTypeId
			,@intFutureMarketId = intFutureMarketId
			,@intFutureMonthId = intFutureMonthId
			,@intDestinationPortId = intDestinationPortId
			,@intShipperId = intShipperId
			,@intCompanyLocationId = intCompanyLocationId
		FROM dbo.tblCTContractDetail WITH (NOLOCK)
		WHERE intContractDetailId = @intContractDetailId

		IF ISNULL(@strVendorAccountNum, '') = ''
		BEGIN
			SELECT @strError = @strError + 'Vendor Account Number cannot be blank. '
		END

		IF ISNULL(@strBook, '') = ''
		BEGIN
			SELECT @strError = @strError + 'Book cannot be blank. '
		END

		IF @dtmPlannedAvailabilityDate IS NULL
		BEGIN
			SELECT @strError = @strError + 'Planned Availability Date cannot be blank. '
		END

		IF @dtmUpdatedAvailabilityDate IS NULL
		BEGIN
			SELECT @strError = @strError + 'Updated Availability Date cannot be blank. '
		END

		IF ISNULL(@strSubLocation, '') = ''
		BEGIN
			SELECT @strError = @strError + 'Storage Location cannot be blank. '
		END

		IF ISNULL(@dblQuantity, 0) = 0
		BEGIN
			SELECT @strError = @strError + 'Quantity cannot be blank. '
		END

		IF ISNULL(@strPricingType, '') = ''
		BEGIN
			SELECT @strError = @strError + 'Pricing Type cannot be blank. '
		END

		IF @strError <> ''
		BEGIN
			UPDATE dbo.tblCTContractFeed
			SET strMessage = @strError
				,intStatusId = 2
			WHERE intContractFeedId = @intContractFeedId

			GOTO NextPO
		END

		BEGIN
			IF @strRowState <> 'Added'
				AND IsNULL(@strERPPONumber, '') = ''
			BEGIN
				GOTO NextPO
			END

			SELECT @strXML = '<header id="' + ltrim(@intContractFeedId) + '">' + 
				'<TrxSequenceNo>' + ltrim(@intContractFeedId) + '</TrxSequenceNo>' + 
				'<CompanyLocation>' + ltrim(@strCompanyLocation) + '</CompanyLocation>' + 
				'<ActionId>' + Ltrim(CASE 
						WHEN @strRowState = 'Added'
							THEN 1
						ELSE 2
						END) + '</ActionId>' + 
				'<CreatedDate>' + CONVERT(VARCHAR(33), GetDate(), 126) + '</CreatedDate>' + 
				'<CreatedBy>' + @strUserName + '</CreatedBy>' + 
				'<ContractNo>' + @strContractNumber + '</ContractNo>' + 
				'<ContractDate>' + IsNULL(convert(VARCHAR, CF.dtmContractDate, 112), '') + '</ContractDate>' + 
				'<VendorAccountNo>' + @strVendorAccountNum + '</VendorAccountNo>' + 
				'<Book>' + @strBook + '</Book>' + 
				'<Commodity>' + @strCommodityCode + '</Commodity>' + 
				'<VendorRefNo>' + ISNULL(@strCustomerContract, '') + '</VendorRefNo>' + 
				'<TermsCode>' + ISNULL(CF.strTermCode, '') + '</TermsCode>' + 
				'<INCOTerm>' + ISNULL(CF.strContractBasis, '') + '</INCOTerm>' + 
				'<INCOTermLocation>' + ISNULL(C.strCity, '') + '</INCOTermLocation>' + 
				'<Position>' + ISNULL(P.strPosition, '') + '</Position>' + 
				'<WeightTerm>' + ISNULL(W1.strWeightGradeDesc, '') + '</WeightTerm>' + 
				'<ApprovalBasis>' + ISNULL(W2.strWeightGradeDesc, '') + '</ApprovalBasis>'
			FROM dbo.tblCTContractFeed CF
			JOIN dbo.tblCTContractHeader CH ON CH.intContractHeaderId = CF.intContractHeaderId
				AND CF.intContractFeedId = @intContractFeedId
			LEFT JOIN tblSMCity C ON C.intCityId = CH.intINCOLocationTypeId
			LEFT JOIN tblCTPosition P ON P.intPositionId = CH.intPositionId
			LEFT JOIN tblCTWeightGrade W1 ON W1.intWeightGradeId = CH.intWeightId
			LEFT JOIN tblCTWeightGrade W2 ON W2.intWeightGradeId = CH.intGradeId

			IF NOT EXISTS (
					SELECT 1
					FROM tblCTContractDetail
					WHERE intContractDetailId = @intContractDetailId
					)
				SELECT @intActionId = 4
			ELSE
				SELECT @intActionId = (
						CASE 
							WHEN @strRowState = 'Added'
								THEN 1
							WHEN @strRowState = 'Modified'
								THEN 2
							ELSE 3
							END
						)

			SELECT TOP 1 @dtmFixationDate = PFD.dtmFixationDate
			FROM tblCTPriceFixation PF
			JOIN tblCTPriceFixationDetail PFD ON PFD.intPriceFixationId = PF.intPriceFixationId
				AND PF.intContractDetailId = @intContractDetailId

			SELECT @strCertificate += '<Certificate>' + C.strCertificationName + '</Certificate>'
			FROM tblCTContractCertification CC
			JOIN tblICCertification C ON C.intCertificationId = CC.intCertificationId
				AND CC.intContractDetailId = @intContractDetailId

			IF @intActionId = 4
			BEGIN
				SELECT @strDetailXML = '<line id="' + LTRIM(@intContractFeedId) + '" parentId="' + ltrim(@intContractFeedId) + '">' + 
					'<TrxSequenceNo>' + LTRIM(@intContractFeedId) + '</TrxSequenceNo>' + 
					'<ActionId>' + LTRIM(@intActionId) + '</ActionId>' + 
					'<SequenceNo>' + LTRIM(CF.intContractSeq) + '</SequenceNo>' + 
					'<ItemNo>' + CF.strItemNo + '</ItemNo>' + 
					'<Quantity>' + LTRIM(CONVERT(NUMERIC(18, 6), CF.dblQuantity)) + '</Quantity>' + 
					'<QuantityUOM>' + CF.strQuantityUOM + '</QuantityUOM>' + 
					'<NetWeight>' + LTRIM(CONVERT(NUMERIC(18, 6), CF.dblNetWeight)) + '</NetWeight>' + 
					'<NetWeightUOM>' + CF.strNetWeightUOM + '</NetWeightUOM>' + 
					'<ERPPONumber>' + ISNULL(CF.strERPPONumber, '') + '</ERPPONumber>' + 
					'<ERPPOlineNo>' + ISNULL(CF.strERPItemNumber, '') + '</ERPPOlineNo>' + 
					'</line>'
				FROM dbo.tblCTContractFeed CF
				WHERE CF.intContractFeedId = @intContractFeedId
			END
			ELSE
			BEGIN
				SELECT @strDetailXML = '<line id="' + LTRIM(@intContractFeedId) + '" parentId="' + ltrim(@intContractFeedId) + '">' + 
					'<TrxSequenceNo>' + LTRIM(@intContractFeedId) + '</TrxSequenceNo>' + 
					'<ActionId>' + LTRIM(@intActionId) + '</ActionId>' + 
					'<Status>' + LTRIM(CD.intContractStatusId) + '</Status>' + 
					'<SequenceNo>' + LTRIM(CF.intContractSeq) + '</SequenceNo>' + 
					'<StartDate>' + ISNULL(CONVERT(VARCHAR, CF.dtmStartDate, 112), '') + '</StartDate>' + 
					'<EndDate>' + ISNULL(CONVERT(VARCHAR, CF.dtmEndDate, 112), '') + '</EndDate>' + 
					'<PlannedAvailabilityDate>' + ISNULL(CONVERT(VARCHAR, @dtmPlannedAvailabilityDate, 112), '') + '</PlannedAvailabilityDate>' + 
					'<UpdatedAvailabilityDate>' + ISNULL(CONVERT(VARCHAR, @dtmUpdatedAvailabilityDate, 112), '') + '</UpdatedAvailabilityDate>' + 
					'<StorageLocation>' + @strSubLocation + '</StorageLocation>' + 
					'<StorageUnit>' + ISNULL(CF.strStorageLocation, '') + '</StorageUnit>' + 
					'<ItemNo>' + CF.strItemNo + '</ItemNo>' + 
					'<Quantity>' + LTRIM(CONVERT(NUMERIC(18, 6), CF.dblQuantity)) + '</Quantity>' + 
					'<QuantityUOM>' + CF.strQuantityUOM + '</QuantityUOM>' + 
					'<NetWeight>' + LTRIM(CONVERT(NUMERIC(18, 6), CF.dblNetWeight)) + '</NetWeight>' + 
					'<NetWeightUOM>' + CF.strNetWeightUOM + '</NetWeightUOM>' + 
					'<PricingType>' + @strPricingType + '</PricingType>' + 
					'<FuturesMarket>' + ISNULL(FM.strFutMarketName, '') + '</FuturesMarket>' + 
					'<FuturesMonth>' + ISNULL(FMO.strFutureMonth, '') + '</FuturesMonth>' + 
					'<CashPrice>' + LTRIM(CONVERT(NUMERIC(18, 6), ISNULL(dbo.fnRKConvertUOMCurrency('ItemUOM', CD.intPriceItemUOMId, IUOM.intItemUOMId, 1, CD.intCurrencyId, @intCurrencyId, CD.dblCashPrice, CD.intContractDetailId), 0))) + '</CashPrice>' + 
					'<PriceUOM>' + ISNULL(UOM.strUnitMeasure, '') + '</PriceUOM>' + 
					'<PriceCurrency>' + ISNULL(@strCurrency, '') + '</PriceCurrency>' + 
					'<FixationDate>' + ISNULL(CONVERT(VARCHAR, @dtmFixationDate, 112), '') + '</FixationDate>' + 
					'<Origin>' + ISNULL(CF.strOrigin, '') + '</Origin>' + 
					'<LoadingPort>' + ISNULL(CF.strLoadingPoint, '') + '</LoadingPort>' + 
					'<DestinationPort>' + ISNULL(DP.strCity, '') + '</DestinationPort>' + 
					'<Shipper>' + ISNULL(S.strName, '') + '</Shipper>' + 
					'<Certificates>' + ISNULL(@strCertificate, '') + '</Certificates>' + 
					'<ERPPONumber>' + ISNULL(CF.strERPPONumber, '') + '</ERPPONumber>' + 
					'<ERPPOlineNo>' + ISNULL(CF.strERPItemNumber, '') + '</ERPPOlineNo>' + 
					'</line>'
				FROM dbo.tblCTContractFeed CF
				JOIN dbo.tblCTContractDetail CD ON CD.intContractDetailId = CF.intContractDetailId
					AND CF.intContractFeedId = @intContractFeedId
				LEFT JOIN dbo.tblRKFutureMarket FM ON FM.intFutureMarketId = CD.intFutureMarketId
				LEFT JOIN dbo.tblRKFuturesMonth FMO ON FMO.intFutureMonthId = CD.intFutureMonthId
				LEFT JOIN dbo.tblICItemUOM IUOM ON IUOM.intItemId = CD.intItemId
					AND IUOM.ysnStockUnit = 1
				LEFT JOIN dbo.tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId
				LEFT JOIN dbo.tblSMCity DP ON DP.intCityId = CD.intDestinationPortId
				LEFT JOIN dbo.tblEMEntity S ON S.intEntityId = CD.intShipperId
			END
			
			IF IsNULL(@strDetailXML, '') <> ''
			BEGIN
				SELECT @strFinalXML = @strFinalXML + @strXML + @strDetailXML + '</header>'

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
					)
				SELECT @intContractHeaderId
					,@intContractDetailId
					,@strCustomerContract
					,@intShipperId
					,@intDestinationPortId
					,@intCompanyLocationId
					,@intBookId
			END
			ELSE
			BEGIN
				UPDATE dbo.tblCTContractFeed
				SET strMessage = 'Detail XML not available. '
					,intStatusId = 2
				WHERE intContractFeedId = @intContractFeedId

				GOTO NextPO
			END
		END

		DELETE
		FROM tblIPThirdPartyContractFeed
		WHERE intContractFeedId = @intContractFeedId

		-- Add all the extra columns which are not avail in feed table
		INSERT INTO tblIPThirdPartyContractFeed (
			intContractFeedId
			,strERPPONumber
			,strRowState
			)
		SELECT @intContractFeedId
			,@strERPPONumber
			,@strRowState

		IF @ysnUpdateFeedStatus = 1
		BEGIN
			UPDATE tblCTContractFeed
			SET intStatusId = 1
				,strMessage = 'Success'
			WHERE intContractFeedId = @intContractFeedId
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
			,ISNULL(@strERPPONumber, '')
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
