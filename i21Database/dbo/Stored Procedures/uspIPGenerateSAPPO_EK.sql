CREATE PROCEDURE dbo.uspIPGenerateSAPPO_EK (@ysnUpdateFeedStatus BIT = 1)
AS
BEGIN TRY
	SET NOCOUNT ON

	--Status Id: -1(Processing), 1(Internal Error), 2(Waiting Ack), 3(Failure Ack), 4 (Success Ack)
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strError NVARCHAR(MAX) = ''
		,@strHeaderRowState NVARCHAR(50)
		,@strHeaderXML NVARCHAR(MAX) = ''
		,@strItemXML NVARCHAR(MAX) = ''
		,@strLineXML NVARCHAR(MAX) = ''
		,@strBatchXML NVARCHAR(MAX) = ''
		,@strXML NVARCHAR(MAX) = ''
		,@strRootXML NVARCHAR(MAX) = ''
		,@strFinalXML NVARCHAR(MAX) = ''
		,@ysnTrackMFTActivity BIT
		,@strLocalForLocal nvarchar(50)
		,@intTealingoItemId INT
	DECLARE @tblOutput AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intContractFeedId INT
		,strRowState NVARCHAR(50)
		,strXML NVARCHAR(MAX)
		,strInfo1 NVARCHAR(100)
		,strInfo2 NVARCHAR(100)
		)
	DECLARE @intContractFeedId INT
	DECLARE @intLoadId INT
		,@intLoadDetailId INT
		,@intCompanyLocationId INT
		,@ysnPosted BIT
	DECLARE @strLoadNumber NVARCHAR(100)
		,@strVendorAccountNum NVARCHAR(100)
		,@strLocationName NVARCHAR(100)
		,@strCommodityCode NVARCHAR(100)
		,@strERPPONumber NVARCHAR(100)
	DECLARE @tblIPContractFeed TABLE (intContractFeedId INT)
	DECLARE @strContractNumber NVARCHAR(100)
		,@intContractSeq INT
		,@intDetailNumber INT
		,@strERPContractNumber NVARCHAR(100)
		,@strERPItemNumber NVARCHAR(100)
		,@strItemNo NVARCHAR(100)
		,@dblQuantity NUMERIC(18, 6)
		,@strQuantityUOM NVARCHAR(50)
		,@dblNetWeight NUMERIC(18, 6)
		,@strNetWeightUOM NVARCHAR(50)
		,@strPricingType NVARCHAR(50)
		,@dblCashPrice NUMERIC(18, 6)
		,@strPriceUOM NVARCHAR(50)
		,@strPriceCurrency NVARCHAR(50)
		,@dtmStartDate DATETIME
		,@dtmEndDate DATETIME
		,@dtmPlannedAvailabilityDate DATETIME
		,@dtmUpdatedAvailabilityDate DATETIME
		,@strPurchasingGroup NVARCHAR(150)
		,@strPackingDescription NVARCHAR(50)
		,@strVirtualPlant NVARCHAR(100)
		,@strLoadingPoint NVARCHAR(100)
		,@strDestinationPoint NVARCHAR(100)
		,@dblLeadTime NUMERIC(18, 6)
		,@strBatchId NVARCHAR(50)
		,@intContractHeaderId INT
		,@intContractDetailId INT
		,@intSampleId INT
		,@intBatchId INT
	DECLARE @strDetailRowState NVARCHAR(50)
		,@strMarketZoneCode NVARCHAR(50)
		,@strTeaOrigin NVARCHAR(50)
		,@strISOCode NVARCHAR(3)
		,@strTeaLingoItem NVARCHAR(50)
		,@strPlant NVARCHAR(50)
		,@dtmProductionBatch DATETIME
		,@dtmExpiration DATETIME
		,@strBuyingCountry NVARCHAR(50)
		,@strMixingUnitCountry NVARCHAR(50)
		,@intMixingUnitCount INT
	DECLARE @intPOFeedId INT
	DECLARE @ContractFeedId TABLE (intContractFeedId INT)
	DECLARE @tblLGLoad TABLE (intLoadId INT)
	DECLARE @intMainLoadId INT
	DECLARE @tmp INT
	DECLARE @strErrorMessage NVARCHAR(MAX)

	SELECT @tmp = strValue
	FROM tblIPSAPIDOCTag
	WHERE strMessageType = 'PO'
		AND strTag = 'Count'

	IF ISNULL(@tmp, 0) = 0
		SELECT @tmp = 50

	DELETE
	FROM @tblLGLoad

	DELETE
	FROM @ContractFeedId

	INSERT INTO @tblLGLoad (intLoadId)
	SELECT DISTINCT TOP (@tmp) intLoadId
	FROM tblIPContractFeed CF
	WHERE CF.intStatusId IS NULL

	SELECT @intMainLoadId = MIN(intLoadId)
	FROM @tblLGLoad

	IF @intMainLoadId IS NULL
	BEGIN
		RETURN
	END

	UPDATE tblIPContractFeed
	SET intStatusId = - 1
	WHERE intLoadId IN (
			SELECT intLoadId
			FROM @tblLGLoad
			)
		AND intStatusId IS NULL

	WHILE @intMainLoadId IS NOT NULL
	BEGIN
		SELECT @strHeaderXML = ''
			,@strLineXML = ''
			,@strHeaderRowState = NULL

		DELETE
		FROM @tblIPContractFeed

		INSERT INTO @tblIPContractFeed (intContractFeedId)
		SELECT CF.intContractFeedId
		FROM tblIPContractFeed CF
		WHERE CF.intLoadId = @intMainLoadId
			AND CF.intStatusId = - 1

		SELECT @intContractFeedId = MIN(intContractFeedId)
		FROM @tblIPContractFeed

		IF @intContractFeedId IS NULL
		BEGIN
			GOTO NextLoad
		END

		UPDATE tblLGLoad
		SET strComments = ''
		WHERE intLoadId = @intMainLoadId
			AND ISNULL(strComments, '') <> ''

		WHILE @intContractFeedId IS NOT NULL
		BEGIN
			SELECT @strError = ''

			SELECT @intLoadId = NULL
				,@intLoadDetailId = NULL
				,@intCompanyLocationId = NULL
				,@ysnPosted = 0

			SELECT @strLoadNumber = NULL
				,@strVendorAccountNum = NULL
				,@strLocationName = NULL
				,@strCommodityCode = NULL
				,@strERPPONumber = NULL

			SELECT @intLoadId = intLoadId
				,@intLoadDetailId = intLoadDetailId
				,@intCompanyLocationId = intCompanyLocationId
				,@strLoadNumber = strLoadNumber
				,@strVendorAccountNum = strVendorAccountNum
				,@strLocationName = strLocationName
				,@strCommodityCode = strCommodityCode
				,@strERPPONumber = strERPPONumber
			FROM dbo.tblIPContractFeed
			WHERE intContractFeedId = @intContractFeedId

			-- If the first record is delete feed then do not send the feed
			--IF EXISTS (
			--	SELECT 1
			--	FROM tblIPContractFeed
			--	WHERE intLoadId = @intLoadId
			--		AND intContractFeedId < @intContractFeedId
			--		AND ISNULL(strRowState, '') IN (
			--			'Cancelled'
			--			,'Deleted'
			--			)
			--	)
			--BEGIN
			--	UPDATE dbo.tblIPContractFeed
			--	SET strMessage = 'Cannot send delete feed since create Feed is not yet sent. '
			--		,intStatusId = 1
			--	WHERE intContractFeedId = @intContractFeedId

			--	GOTO NextRec
			--END

			IF ISNULL(@strHeaderRowState, '') = ''
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM tblIPContractFeed
						WHERE intLoadId = @intLoadId
							AND intContractFeedId < @intContractFeedId
							AND ISNULL(intStatusId, 0) IN (
								2
								,4
								)
						)
				BEGIN
					SELECT @strHeaderRowState = 'U'
				END
				ELSE
				BEGIN
					SELECT @strHeaderRowState = 'C'
				END
			END

			IF @strHeaderRowState = 'C'
				AND ISNULL(@strERPPONumber, '') <> ''
			BEGIN
				SELECT @strHeaderRowState = 'U'
			END

			IF ISNULL(@strLoadNumber, '') = ''
			BEGIN
				SELECT @strError = @strError + 'Load Number cannot be blank. '
			END

			IF ISNULL(@strVendorAccountNum, '') = ''
			BEGIN
				SELECT @strError = @strError + 'Vendor Account Number cannot be blank. '
			END

			IF ISNULL(@strLocationName, '') = ''
			BEGIN
				SELECT @strError = @strError + 'Location cannot be blank. '
			END

			IF ISNULL(@strCommodityCode, '') = ''
			BEGIN
				SELECT @strError = @strError + 'Commodity cannot be blank. '
			END

			IF @strError <> ''
			BEGIN
				UPDATE dbo.tblIPContractFeed
				SET strMessage = @strError
					,intStatusId = 1
				WHERE intContractFeedId = @intContractFeedId

				GOTO NextRec
			END

			IF @strHeaderRowState <> 'C'
				AND ISNULL(@strERPPONumber, '') = ''
			BEGIN
				UPDATE dbo.tblIPContractFeed
				SET strMessage = 'ERP PO Number is not available. '
				WHERE intContractFeedId = @intContractFeedId

				GOTO NextRec
			END

			-- If previous feed is waiting for acknowledgement then do not send the current feed
			IF EXISTS (
					SELECT TOP 1 1
					FROM tblIPContractFeed CF
					WHERE CF.intLoadId = @intLoadId
						AND CF.intLoadDetailId = @intLoadDetailId
						AND CF.intContractFeedId < @intContractFeedId
						AND CF.intStatusId = 2
					ORDER BY CF.intContractFeedId DESC
					)
			BEGIN
				UPDATE dbo.tblIPContractFeed
				SET strMessage = 'Previous feed is waiting for acknowledgement. '
				WHERE intContractFeedId = @intContractFeedId

				GOTO NextRec
			END

			-- Vendor should be same for all the details in a LS
			IF EXISTS (
					SELECT 1
					FROM tblIPContractFeed CF WITH (NOLOCK)
					WHERE CF.intLoadId = @intLoadId
						AND intStatusId Is NULL 
						AND CF.strVendorAccountNum <> @strVendorAccountNum
					)
			BEGIN
				UPDATE dbo.tblIPContractFeed
				SET strMessage = 'Vendor should be same for all the order details in a LS. '
					,intStatusId = 1
				WHERE intContractFeedId = @intContractFeedId

				GOTO NextRec
			END

			IF ISNULL(@strHeaderXML, '') = ''
			BEGIN
				SELECT @strHeaderXML = ''

				SELECT @strHeaderXML += '<Header>'

				SELECT @strHeaderXML += '<RefNo>' + @strLoadNumber + '</RefNo>'

				SELECT @strHeaderXML += '<VendorAccountNo>' + @strVendorAccountNum + '</VendorAccountNo>'

				SELECT @strHeaderXML += '<Location>' + @strLocationName + '</Location>'

				SELECT @strHeaderXML += '<HeaderRowState>' + @strHeaderRowState + '</HeaderRowState>'

				SELECT @strHeaderXML += '<Commodity>' + @strCommodityCode + '</Commodity>'
			END

			SELECT @strContractNumber = NULL
				,@intContractSeq = NULL
				,@intDetailNumber = NULL
				,@strERPContractNumber = NULL
				,@strERPPONumber = NULL
				,@strERPItemNumber = NULL
				,@strItemNo = NULL
				,@dblQuantity = NULL
				,@strQuantityUOM = NULL
				,@dblNetWeight = NULL
				,@strNetWeightUOM = NULL
				,@strPricingType = NULL
				,@dblCashPrice = NULL
				,@strPriceUOM = NULL
				,@strPriceCurrency = NULL
				,@dtmStartDate = NULL
				,@dtmEndDate = NULL
				,@dtmPlannedAvailabilityDate = NULL
				,@dtmUpdatedAvailabilityDate = NULL
				,@strPurchasingGroup = NULL
				,@strPackingDescription = NULL
				,@strVirtualPlant = NULL
				,@strLoadingPoint = NULL
				,@strDestinationPoint = NULL
				,@dblLeadTime = NULL
				,@strBatchId = NULL
				,@intContractHeaderId = NULL
				,@intContractDetailId = NULL
				,@intSampleId = NULL
				,@intBatchId = NULL

			SELECT @strDetailRowState = NULL
				,@strMarketZoneCode = NULL
				,@strTeaOrigin = NULL
				,@strISOCode = NULL
				,@strTeaLingoItem = NULL
				,@strPlant = NULL
				,@dtmProductionBatch = NULL
				,@dtmExpiration = NULL
				,@strBuyingCountry = NULL
				,@strMixingUnitCountry = NULL
				,@intMixingUnitCount = NULL

			SELECT @strContractNumber = strContractNumber
				,@intContractSeq = intContractSeq
				,@strERPContractNumber = strERPContractNumber
				,@strERPPONumber = strERPPONumber
				,@strERPItemNumber = strERPItemNumber
				,@strItemNo = strItemNo
				,@dblQuantity = dblQuantity
				,@strQuantityUOM = strQuantityUOM
				,@dblNetWeight = dblNetWeight
				,@strNetWeightUOM = strNetWeightUOM
				,@strPricingType = strPricingType
				,@dblCashPrice = dblCashPrice
				,@strPriceUOM = strPriceUOM
				,@strPriceCurrency = strPriceCurrency
				,@dtmStartDate = dtmStartDate
				,@dtmEndDate = dtmEndDate
				,@dtmPlannedAvailabilityDate = dtmPlannedAvailabilityDate
				,@dtmUpdatedAvailabilityDate = dtmUpdatedAvailabilityDate
				,@strPurchasingGroup = strPurchasingGroup
				,@strPackingDescription = strPackingDescription
				,@strVirtualPlant = strVirtualPlant
				,@strLoadingPoint = strLoadingPoint
				,@strDestinationPoint = strDestinationPoint
				,@dblLeadTime = dblLeadTime
				,@strBatchId = strBatchId
				,@intContractHeaderId = intContractHeaderId
				,@intContractDetailId = intContractDetailId
				,@intSampleId = intSampleId
				,@intBatchId = intBatchId
				,@strDetailRowState = strRowState
				,@strMarketZoneCode = strMarketZoneCode
				,@intDetailNumber = intDetailNumber
			FROM dbo.tblIPContractFeed
			WHERE intContractFeedId = @intContractFeedId

			IF @strDetailRowState = 'Cancelled'
				OR @strDetailRowState = 'Deleted'
			BEGIN
				SELECT @strDetailRowState = 'D'
			END
			ELSE IF @strDetailRowState = 'Added'
			BEGIN
				SELECT @strDetailRowState = 'C'
			END
			ELSE IF @strDetailRowState = 'Modified'
			BEGIN
				SELECT @strDetailRowState = 'U'
			END

			IF @strDetailRowState = 'U'
			BEGIN
				IF NOT EXISTS (
					SELECT 1
					FROM tblIPContractFeed
					WHERE intLoadId = @intLoadId
						AND intLoadDetailId = @intLoadDetailId
						AND intContractFeedId < @intContractFeedId
						AND ISNULL(intStatusId, 0) IN (
							2
							,4
							)
					)
				BEGIN
					SELECT @strDetailRowState = 'C'

					UPDATE tblIPContractFeed
					SET strRowState = 'Added'
					WHERE intContractFeedId = @intContractFeedId
				END
			END

			--SELECT @intDetailNumber = LD.intDetailNumber
			--FROM dbo.tblLGLoadDetail LD WITH (NOLOCK)
			--WHERE LD.intLoadDetailId = @intLoadDetailId

			SELECT @ysnPosted = L.ysnPosted
			FROM dbo.tblLGLoad L WITH (NOLOCK)
			JOIN dbo.tblARMarketZone MZ WITH (NOLOCK) ON MZ.intMarketZoneId = L.intMarketZoneId
			WHERE intLoadId = @intLoadId

			SELECT @ysnTrackMFTActivity = 0,@strLocalForLocal=''

			SELECT @strBuyingCountry = BCL.strCountry
				,@strMixingUnitCountry = MCL.strCountry
				,@ysnTrackMFTActivity = IsNULL(BCL.ysnTrackMFTActivity,0)
				,@strLocalForLocal	=	BCL.strVendorRefNoPrefix
			FROM tblMFBatch B WITH (NOLOCK)
			JOIN dbo.tblSMCompanyLocation BCL WITH (NOLOCK) ON BCL.intCompanyLocationId = B.intBuyingCenterLocationId
			JOIN dbo.tblSMCompanyLocation MCL WITH (NOLOCK) ON MCL.intCompanyLocationId = B.intMixingUnitLocationId
			WHERE B.intBatchId = @intBatchId

			SELECT @intMixingUnitCount = COUNT(1)
			FROM (
				SELECT DISTINCT B.intMixingUnitLocationId
				FROM dbo.tblLGLoadDetail LD WITH (NOLOCK)
				JOIN dbo.tblMFBatch B WITH (NOLOCK) ON B.intBatchId = LD.intBatchId
				JOIN dbo.tblSMCompanyLocation L on L.intCompanyLocationId=B.intBuyingCenterLocationId
					AND LD.intLoadId = @intLoadId AND IsNULL(L.ysnTrackMFTActivity,0)=0
				) t

			IF (ISNULL(@intMixingUnitCount, 0) > 1)
			BEGIN
				SELECT @strError = @strError + 'Multiple Mixing Unit cannot be used in a single PO. '

				UPDATE tblIPContractFeed
				SET strMessage = @strError
					,intStatusId = 1
				WHERE intContractFeedId = @intContractFeedId
					AND intLoadDetailId = @intLoadDetailId

				SELECT @strError = ''

				GOTO NextRec
			END

			IF ISNULL(@strBuyingCountry, '') = ISNULL(@strMixingUnitCountry, '')
			BEGIN
				SELECT @strVirtualPlant = MCL.strVendorRefNoPrefix
				FROM tblMFBatch B WITH (NOLOCK)
				JOIN dbo.tblSMCompanyLocation MCL WITH (NOLOCK) ON MCL.intCompanyLocationId = B.intMixingUnitLocationId
				WHERE B.intBatchId = @intBatchId
			END
			ELSE IF IsNULL(@ysnTrackMFTActivity,0)=1
			BEGIN
				SELECT @strVirtualPlant = @strLocalForLocal
			END

			IF @strDetailRowState <> 'D'
				AND ISNULL(@ysnPosted, 0) = 0
			BEGIN
				SELECT @strError = @strError + 'Load is not yet posted. '

				UPDATE tblIPContractFeed
				SET strMessage = @strError
					,intStatusId = 1
				WHERE intContractFeedId = @intContractFeedId
					AND intLoadDetailId = @intLoadDetailId

				SELECT @strError = ''

				GOTO NextRec
			END

			IF ISNULL(@strMarketZoneCode, '') = ''
			BEGIN
				SELECT @strError = @strError + 'Market Zone cannot be blank. '

				UPDATE tblIPContractFeed
				SET strMessage = @strError
					,intStatusId = 1
				WHERE intContractFeedId = @intContractFeedId
					AND intLoadDetailId = @intLoadDetailId

				SELECT @strError = ''

				GOTO NextRec
			END

			IF ISNULL(@strMarketZoneCode, '') IN (
					'AUC'
					) OR EXISTS (SELECT *FROM tblLGLoadDetail WHERE intLoadDetailId=@intLoadDetailId AND intPContractDetailId IS NULL)
			BEGIN
				IF ISNULL(@intSampleId, 0) = 0
				BEGIN
					SELECT @strError = @strError + 'Sample No cannot be blank. '
				END
			END
			ELSE
			BEGIN
				IF ISNULL(@strERPContractNumber, '') = ''
				BEGIN
					SELECT @strError = @strError + 'ERP Contract No. cannot be blank. '
				END

				IF @intContractSeq IS NULL
				BEGIN
					SELECT @strError = @strError + 'Contract Seq cannot be blank. '
				END

				IF @dtmStartDate IS NULL
				BEGIN
					SELECT @strError = @strError + 'Start Date cannot be blank. '
				END

				IF @dtmEndDate IS NULL
				BEGIN
					SELECT @strError = @strError + 'End Date cannot be blank. '
				END

				IF @dtmPlannedAvailabilityDate IS NULL
				BEGIN
					SELECT @strError = @strError + 'Planned Availability Date cannot be blank. '
				END

				IF @dtmUpdatedAvailabilityDate IS NULL
				BEGIN
					SELECT @strError = @strError + 'Updated Availability Date cannot be blank. '
				END

				IF ISNULL(@strPackingDescription, '') = ''
				BEGIN
					SELECT @strError = @strError + 'Packing Description cannot be blank. '
				END

				IF ISNULL(@strLoadingPoint, '') = ''
				BEGIN
					SELECT @strError = @strError + 'Loading Port cannot be blank. '
				END

				IF ISNULL(@strDestinationPoint, '') = ''
				BEGIN
					SELECT @strError = @strError + 'Destination Port cannot be blank. '
				END

				IF ISNULL(@dblLeadTime, 0) = 0
				BEGIN
					SELECT @strError = @strError + 'Lead Time cannot be blank. '
				END

				IF ISNULL(@strContractNumber, '') = ''
				BEGIN
					SELECT @strError = @strError + 'Contract No. cannot be blank. '
				END
			END

			IF @strDetailRowState <> 'C'
			BEGIN
				IF ISNULL(@strERPPONumber, '') = ''
				BEGIN
					SELECT @strError = @strError + 'ERP PO Number cannot be blank. '
				END
			END

			IF ISNULL(@strItemNo, '') = ''
			BEGIN
				SELECT @strError = @strError + 'Item No cannot be blank. '
			END

			IF ISNULL(@dblQuantity, 0) = 0
			BEGIN
				SELECT @strError = @strError + 'Quantity cannot be blank. '
			END

			IF ISNULL(@strQuantityUOM, '') = ''
			BEGIN
				SELECT @strError = @strError + 'Qty UOM cannot be blank. '
			END

			IF ISNULL(@dblNetWeight, 0) = 0
			BEGIN
				SELECT @strError = @strError + 'Net Weight cannot be blank. '
			END

			IF ISNULL(@strNetWeightUOM, '') = ''
			BEGIN
				SELECT @strError = @strError + 'Net Weight UOM cannot be blank. '
			END

			IF ISNULL(@strPricingType, '') = ''
			BEGIN
				SELECT @strError = @strError + 'Price Type cannot be blank. '
			END

			IF ISNULL(@dblCashPrice, 0) = 0
			BEGIN
				SELECT @strError = @strError + 'Cash Price cannot be blank. '
			END

			IF ISNULL(@strPriceUOM, '') = ''
			BEGIN
				SELECT @strError = @strError + 'Price UOM cannot be blank. '
			END

			IF ISNULL(@strPriceCurrency, '') = ''
			BEGIN
				SELECT @strError = @strError + 'Price Currency cannot be blank. '
			END

			IF ISNULL(@strPurchasingGroup, '') = ''
			BEGIN
				SELECT @strError = @strError + 'Purchasing Group cannot be blank. '
			END

			IF ISNULL(@strVirtualPlant, '') = ''
			BEGIN
				SELECT @strError = @strError + 'Virtual Plant cannot be blank. '
			END

			IF ISNULL(@intDetailNumber, 0) = 0
			BEGIN
				SELECT @strError = @strError + 'Sequence No cannot be blank. '
			END

			IF @strDetailRowState = 'C'
				AND ISNULL(@strERPItemNumber, '') = ''
				AND ISNULL(@intDetailNumber, 0) > 0
			BEGIN
				SELECT @strERPItemNumber = RIGHT('000' + CONVERT(NVARCHAR, (@intDetailNumber * 10)), 5)

				UPDATE tblIPContractFeed
				SET strERPItemNumber = @strERPItemNumber
				WHERE intContractFeedId = @intContractFeedId
					AND intLoadDetailId = @intLoadDetailId
			END

			IF ISNULL(@strERPItemNumber, '') = ''
			BEGIN
				SELECT @strError = @strError + 'ERP PO Line Item No. cannot be blank. '
			END

			IF @strError <> ''
			BEGIN
				UPDATE tblIPContractFeed
				SET strMessage = @strError
					,intStatusId = 1
				WHERE intContractFeedId = @intContractFeedId
					AND intLoadDetailId = @intLoadDetailId

				SELECT @strError = ''

				GOTO NextRec
			END

			SELECT @strItemXML = ''

			SELECT @strItemXML += '<Line>'

			SELECT @strItemXML += '<TrackingNo>' + LTRIM(@intContractFeedId) + '</TrackingNo>'

			SELECT @strItemXML += '<RowState>' + ISNULL(@strDetailRowState, '') + '</RowState>'

			SELECT @strItemXML += '<ERPContractNo>' + ISNULL(@strERPContractNumber, '') + '</ERPContractNo>'

			IF ISNULL(@strContractNumber, '')=''
				SELECT @strItemXML += '<ContractNo>' + '' + '</ContractNo>'
			ELSE
				SELECT @strItemXML += '<ContractNo>' + ISNULL(@strContractNumber, '') + '</ContractNo>'

			SELECT @strItemXML += '<SequenceNo>' + ISNULL(LTRIM(@intDetailNumber), '') + '</SequenceNo>'

			SELECT @strItemXML += '<PONumber>' + ISNULL(@strERPPONumber, '') + '</PONumber>'

			SELECT @strItemXML += '<POLineItemNo>' + ISNULL(@strERPItemNumber, '') + '</POLineItemNo>'

			SELECT @strItemXML += '<ItemNo>' + ISNULL(@strItemNo, '') + '</ItemNo>'

			SELECT @strItemXML += '<Quantity>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(@dblQuantity, 0))) + '</Quantity>'

			SELECT @strItemXML += '<QuantityUOM>' + ISNULL(@strQuantityUOM, '') + '</QuantityUOM>'

			SELECT @strItemXML += '<NetWeight>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(@dblNetWeight, 0))) + '</NetWeight>'

			SELECT @strItemXML += '<NetWeightUOM>' + ISNULL(@strNetWeightUOM, '') + '</NetWeightUOM>'

			SELECT @strItemXML += '<PriceType>' + ISNULL(@strPricingType, '') + '</PriceType>'

			SELECT @strItemXML += '<Price>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(@dblCashPrice, 0))) + '</Price>'

			SELECT @strItemXML += '<PriceUOM>' + ISNULL(@strPriceUOM, '') + '</PriceUOM>'

			SELECT @strItemXML += '<PriceCurrency>' + ISNULL(@strPriceCurrency, '') + '</PriceCurrency>'

			SELECT @strItemXML += '<StartDate>' + ISNULL(CONVERT(VARCHAR(33), @dtmStartDate, 126), '') + '</StartDate>'

			SELECT @strItemXML += '<EndDate>' + ISNULL(CONVERT(VARCHAR(33), @dtmEndDate, 126), '') + '</EndDate>'

			SELECT @strItemXML += '<PlannedAvlDate>' + ISNULL(CONVERT(VARCHAR(33), @dtmPlannedAvailabilityDate, 126), '') + '</PlannedAvlDate>'

			SELECT @strItemXML += '<UpdatedAvlDate>' + ISNULL(CONVERT(VARCHAR(33), @dtmUpdatedAvailabilityDate, 126), '') + '</UpdatedAvlDate>'

			SELECT @strItemXML += '<PurchGroup>' + ISNULL(@strPurchasingGroup, '') + '</PurchGroup>'

			SELECT @strItemXML += '<PackDesc>' + ISNULL(@strPackingDescription, '') + '</PackDesc>'

			SELECT @strItemXML += '<VirtualPlant>' + ISNULL(@strVirtualPlant, '') + '</VirtualPlant>'

			IF ISNULL(@strItemXML, '') = ''
			BEGIN
				UPDATE tblIPContractFeed
				SET strMessage = 'PO Line Item XML is not available. '
					,intStatusId = 1
				WHERE intContractFeedId = @intContractFeedId
					AND intLoadDetailId = @intLoadDetailId

				GOTO NextRec
			END

			IF ISNULL(@strBatchId, '') = ''
			BEGIN
				SELECT @strError = @strError + 'Batch Id cannot be blank. '
			END

			SELECT @intTealingoItemId=NULL

			SELECT @strTeaOrigin = B.strTeaOrigin
				,@strTeaLingoItem = B.strItemNo
				,@strPlant = CL.strVendorRefNoPrefix
				,@dtmProductionBatch = B.dtmProductionBatch
				,@dtmExpiration = B.dtmExpiration
				,@intTealingoItemId=B.intTealingoItemId
			FROM vyuMFBatch B WITH (NOLOCK)
			LEFT JOIN dbo.tblSMCompanyLocation CL WITH (NOLOCK) ON CL.intCompanyLocationId = B.intMixingUnitLocationId
			WHERE B.intBatchId = @intBatchId

			SELECT @strISOCode = strISOCode
			FROM dbo.tblSMCountry C WITH (NOLOCK)
			WHERE C.strCountry = @strTeaOrigin

			IF ISNULL(@strTeaLingoItem, '') = ''
			BEGIN
				SELECT @strError = @strError + 'Batch - Item cannot be blank. '
			END

			IF ISNULL(@strPlant, '') = '' AND IsNULL(@ysnTrackMFTActivity,0)=0
			BEGIN
				SELECT @strError = @strError + 'Batch - MU Location cannot be blank. '
			END

			IF @dtmProductionBatch IS NULL
			BEGIN
				SELECT @strError = @strError + 'Batch - Production Date cannot be blank. '
			END

			IF @dtmExpiration IS NULL
			BEGIN
				SELECT @strError = @strError + 'Batch - Expiration Date cannot be blank. '
			END

			IF @strError <> ''
			BEGIN
				UPDATE tblIPContractFeed
				SET strMessage = @strError
					,intStatusId = 1
				WHERE intContractFeedId = @intContractFeedId
					AND intLoadDetailId = @intLoadDetailId

				SELECT @strError = ''

				GOTO NextRec
			END

			SELECT @strBatchXML = ''

			SELECT @strBatchXML = @strBatchXML
				+ '<Batch>'
				+ '<LoadingPort>' + ISNULL(@strLoadingPoint, '') + '</LoadingPort>'
				+ '<DestinationPort>' + ISNULL(@strDestinationPoint, '') + '</DestinationPort>'
				+ '<LeadTime>' + LTRIM(CONVERT(NUMERIC(18, 0), ISNULL(@dblLeadTime, 0))) + '</LeadTime>'
				+ '<BatchId>' + B.strBatchId + '</BatchId>'
				+ '<SaleNumber>' + LTRIM(B.intSales) + '</SaleNumber>'
				+ '<SaleYear>' + LTRIM(B.intSalesYear) + '</SaleYear>'
				+ '<SalesDate>' + ISNULL(CONVERT(VARCHAR(33), B.dtmSalesDate, 126), '') + '</SalesDate>'
				+ '<TeaType>' + ISNULL(B.strTeaType, '') + '</TeaType>'
				+ '<BrokerCode>' + dbo.fnEscapeXML(ISNULL(B.strBroker, '')) + '</BrokerCode>'
				+ '<VendorLotNumber>' + ISNULL(B.strVendorLotNumber, '') + '</VendorLotNumber>'
				+ '<AuctionCenter>' + ISNULL(B.strBuyingCenterLocation, '') + '</AuctionCenter>'
				+ '<ThirdPartyWHStatus>' + ISNULL(B.str3PLStatus, '') + '</ThirdPartyWHStatus>'
				+ '<AdditionalSupplierReference>' + dbo.fnEscapeXML(ISNULL(LEFT(B.strSupplierReference, 15), '')) + '</AdditionalSupplierReference>'
				+ '<AirwayBillNumberCode>' + ISNULL(B.strAirwayBillCode, '') + '</AirwayBillNumberCode>'
				+ '<AWBSampleReceived>' + ISNULL(B.strAWBSampleReceived, '') + '</AWBSampleReceived>'
				+ '<AWBSampleReference>' + ISNULL(LEFT(B.strAWBSampleReference, 15), '') + '</AWBSampleReference>'
				+ '<BasePrice>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblBasePrice, 0))) + '</BasePrice>'
				+ '<BoughtAsReserve>' + LTRIM(ISNULL(B.ysnBoughtAsReserved, '')) + '</BoughtAsReserve>'
				+ '<BoughtPrice>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblBoughtPrice, 0))) + '</BoughtPrice>'
				+ '<BrokerWarehouse>' + ISNULL(LEFT(B.strBrokerWarehouse, 15), '') + '</BrokerWarehouse>'
				+ '<BulkDensity>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblBulkDensity, 0))) + '</BulkDensity>'
				+ '<BuyingOrderNumber>' + ISNULL(B.strBuyingOrderNumber, '') + '</BuyingOrderNumber>'
				+ '<Channel>' + ISNULL(@strMarketZoneCode, '') + '</Channel>'
				+ '<ContainerNo>' + ISNULL(B.strContainerNumber, '') + '</ContainerNo>'
				+ '<Currency>' + ISNULL(C.strCurrency, '') + '</Currency>'
				+ '<DateOfProductionOfBatch>' + ISNULL(CONVERT(VARCHAR(33), B.dtmProductionBatch, 126), '') + '</DateOfProductionOfBatch>'
				+ '<DateTeaAvailableFrom>' + ISNULL(CONVERT(VARCHAR(33), B.dtmTeaAvailableFrom, 126), '') + '</DateTeaAvailableFrom>'
				+ '<DustContent>' + ISNULL(B.strDustContent, '') + '</DustContent>'
				+ '<EuropeanCompliantFlag></EuropeanCompliantFlag>'
				+ '<EvaluatorsCodeAtTBO>' + ISNULL(B.strTBOEvaluatorCode, '') + '</EvaluatorsCodeAtTBO>'
				+ '<EvaluatorsRemarks>' + dbo.fnEscapeXML(ISNULL(LEFT(B.strEvaluatorRemarks, 15), '')) + '</EvaluatorsRemarks>'
				+ '<ExpirationDateShelfLife>' + ISNULL(CONVERT(VARCHAR(33), B.dtmExpiration, 126), '') + '</ExpirationDateShelfLife>'
				+ '<FromLocationCode>' + ISNULL(CITY.strCity, '') + '</FromLocationCode>'
				+ '<GrossWt>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblGrossWeight, 0))) + '</GrossWt>'
				+ '<InitialBuyDate>' + ISNULL(CONVERT(VARCHAR(33), B.dtmInitialBuy, 126), '') + '</InitialBuyDate>'
				+ '<WeightPerUnit>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblWeightPerUnit, 0))) + '</WeightPerUnit>'
				+ '<LandedPrice>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblLandedPrice, 0))) + '</LandedPrice>'
				+ '<LeafCategory>' + ISNULL(B.strLeafCategory, '') + '</LeafCategory>'
				+ '<LeafManufacturingType>' + ISNULL(B.strLeafManufacturingType, '') + '</LeafManufacturingType>'
				+ '<LeafSize>' + ISNULL(B.strLeafSize, '') + '</LeafSize>'
				+ '<LeafStyle>' + ISNULL(B.strLeafStyle, '') + '</LeafStyle>'
				+ '<MixingUnit>' + ISNULL(CL.strLocationName, '') + '</MixingUnit>'
				+ '<NumberOfPackagesBought>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblPackagesBought, 0))) + '</NumberOfPackagesBought>'
				+ '<OriginOfTea>' + ISNULL(@strISOCode, '') + '</OriginOfTea>'
				+ '<OriginalTeaLingoItem>' + ISNULL(I.strItemNo, '') + '</OriginalTeaLingoItem>'
				+ '<PackagesPerPallet>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblPackagesPerPallet, 0))) + '</PackagesPerPallet>'
				+ '<Plant>' + CASE WHEN ISNULL(@strBuyingCountry, '') = ISNULL(@strMixingUnitCountry, '') OR @ysnTrackMFTActivity=1 THEN '' ELSE ISNULL(CL.strVendorRefNoPrefix, '') END + '</Plant>'
				+ '<TotalQuantity>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblTotalQuantity, 0))) + '</TotalQuantity>'
				+ '<SampleBoxNo>' + ISNULL(B.strSampleBoxNumber, '') + '</SampleBoxNo>'
				+ '<SellingPrice>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblSellingPrice, 0))) + '</SellingPrice>'
				+ '<StockDate>' + ISNULL(CONVERT(VARCHAR(33), B.dtmStock, 126), '') + '</StockDate>'
				+ '<StorageLocation>' + CASE WHEN ISNULL(@strBuyingCountry, '') = ISNULL(@strMixingUnitCountry, '') OR @ysnTrackMFTActivity=1 THEN '' ELSE ISNULL(B.strStorageLocation, '') END + '</StorageLocation>'
				+ '<SubChannel>' + ISNULL(B.strSubChannel, '') + '</SubChannel>'
				+ '<StrategicFlag>' + LTRIM(ISNULL(B.ysnStrategic, '')) + '</StrategicFlag>'
				+ '<SubClusterTeaLingo>' + ISNULL(B.strTeaLingoSubCluster, '') + '</SubClusterTeaLingo>'
				+ '<SupplierPreInvoiceDate>' + ISNULL(CONVERT(VARCHAR(33), B.dtmSupplierPreInvoiceDate, 126), '') + '</SupplierPreInvoiceDate>'
				+ '<Sustainability>' + ISNULL(B.strSustainability, '') + '</Sustainability>'
				+ '<TasterComments>' + dbo.fnEscapeXML(ISNULL(LEFT(B.strTasterComments, 15), '')) + '</TasterComments>'
				+ '<TeaAppearance>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblTeaAppearance, 0))) + '</TeaAppearance>'
				+ '<TeaBuyingOffice>' + ISNULL(B.strTeaBuyingOffice, '') + '</TeaBuyingOffice>'
				+ '<TeaColour>' + ISNULL(B.strTeaColour, '') + '</TeaColour>'
				+ '<TeaGardenChopInvoiceNo>' + ISNULL(LEFT(B.strTeaGardenChopInvoiceNumber, 15), '') + '</TeaGardenChopInvoiceNo>'
				+ '<TeaGardenMark>' + dbo.fnEscapeXML(ISNULL(LEFT(GM.strGardenMark, 15), '')) + '</TeaGardenMark>'
				+ '<TeaGroup>' + ISNULL(B.strTeaGroup, '') + '</TeaGroup>'
				+ '<TeaHue>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblTeaHue, 0))) + '</TeaHue>'
				+ '<TeaIntensity>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblTeaIntensity, 0))) + '</TeaIntensity>'
				+ '<TeaLeafGrade>' + ISNULL(B.strLeafGrade, '') + '</TeaLeafGrade>'
				+ '<TeaMoisture>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblTeaMoisture, 0))) + '</TeaMoisture>'
				+ '<TeaMouthfeel>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblTeaMouthFeel, 0))) + '</TeaMouthfeel>'
				+ '<TeaOrganic>' + LTRIM(ISNULL(B.ysnTeaOrganic, '')) + '</TeaOrganic>'
				+ '<TeaTaste>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblTeaTaste, 0))) + '</TeaTaste>'
				+ '<TeaVolume>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblTeaVolume, 0))) + '</TeaVolume>'
				+ '<TeaLingoItem>' + ISNULL(B.strItemNo, '') + '</TeaLingoItem>'
				+ '<TinNumber>' + ISNULL(B.strTINNumber, '') + '</TinNumber>'
				+ '<WarehouseArrivalDate>' + ISNULL(CONVERT(VARCHAR(33), B.dtmWarehouseArrival, 126), '') + '</WarehouseArrivalDate>'
				+ '<YearOfManufacture>' + LTRIM(ISNULL(B.intYearManufacture, '')) + '</YearOfManufacture>'
				+ '<PackageSize>' + ISNULL(B.strPackageSize, '') + '</PackageSize>'
				+ '<PackageType>' + ISNULL(B.strPackageUOM, '') + '</PackageType>'
				+ '<TareWt>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblTareWeight, 0))) + '</TareWt>'
				+ '<Taster>' + dbo.fnEscapeXML(ISNULL(LEFT(B.strTaster, 15), '')) + '</Taster>'
				+ '<FeedStock>' + ISNULL(I.strShortName, '') + '</FeedStock>'
				+ '<FluorideLimit>' + ISNULL(B.strFlourideLimit, '') + '</FluorideLimit>'
				+ '<LocalAuctionNumber>' + ISNULL(B.strLocalAuctionNumber, '') + '</LocalAuctionNumber>'
				+ '<POStatus>' + ISNULL(B.strPOStatus, '') + '</POStatus>'
				+ '<ProductionSite>' + ISNULL(B.strProductionSite, '') + '</ProductionSite>'
				+ '<ReserveMU>' + ISNULL(B.strReserveMU, '') + '</ReserveMU>'
				+ '<QualityComments>' + ISNULL(LEFT(B.strQualityComments, 15), '') + '</QualityComments>'
				+ '<RareEarth>' + ISNULL(B.strRareEarth, '') + '</RareEarth>'
				+ '<TeaLingoVersion>' + ISNULL(I1.strGTIN, '') + '</TeaLingoVersion>'
				+ '<FreightAgent>' + ISNULL(B.strFreightAgent, '') + '</FreightAgent>'
				+ '<SealNo>' + ISNULL(B.strSealNumber, '') + '</SealNo>'
				+ '<ContainerType>' + ISNULL(B.strContainerType, '') + '</ContainerType>'
				+ '<Voyage>' + ISNULL(B.strVoyage, '') + '</Voyage>'
				+ '<Vessel>' + ISNULL(B.strVessel, '') + '</Vessel>'
				+ '<ETD>' + ISNULL(CONVERT(VARCHAR(33), B.dtmEtaPol, 126), '') + '</ETD>'
				+ '</Batch>'
			FROM vyuMFBatch B WITH (NOLOCK)
			--LEFT JOIN dbo.tblQMSample S WITH (NOLOCK) ON S.intSampleId = B.intSampleId
			LEFT JOIN dbo.tblSMCurrency C WITH (NOLOCK) ON C.intCurrencyID = B.intCurrencyId
			LEFT JOIN dbo.tblSMCity CITY WITH (NOLOCK) ON CITY.intCityId = B.intFromPortId
			LEFT JOIN dbo.tblICItem I WITH (NOLOCK) ON I.intItemId = B.intOriginalItemId
			LEFT JOIN dbo.tblQMGardenMark GM WITH (NOLOCK) ON GM.intGardenMarkId = B.intGardenMarkId
			LEFT JOIN dbo.tblICItem I1 WITH (NOLOCK) ON I1.intItemId = B.intTealingoItemId
			LEFT JOIN dbo.tblSMCompanyLocation CL WITH (NOLOCK) ON CL.intCompanyLocationId = B.intMixingUnitLocationId
			WHERE B.intBatchId = @intBatchId

			--EXEC dbo.uspMFBatchPreStage @intBatchId = @intBatchId
			--		,@intUserId = 1
			--		,@intOriginalItemId = @intTealingoItemId
			--		,@intItemId = @intTealingoItemId

			IF ISNULL(@strBatchXML, '') = ''
			BEGIN
				UPDATE tblIPContractFeed
				SET strMessage = 'PO Line Item Batch XML is not available. '
					,intStatusId = 1
				WHERE intContractFeedId = @intContractFeedId
					AND intLoadDetailId = @intLoadDetailId

				GOTO NextRec
			END

			SELECT @strLineXML += @strItemXML + @strBatchXML + '</Line>'

			INSERT INTO @ContractFeedId (intContractFeedId)
			SELECT @intContractFeedId

			IF @ysnUpdateFeedStatus = 1
			BEGIN
				UPDATE tblIPContractFeed
				SET intStatusId = 2
					,strMessage = NULL
					,strFeedStatus = 'Awt Ack'
				WHERE intContractFeedId = @intContractFeedId

				UPDATE tblLGLoad
				SET dtmDispatchMailSent = GETDATE()
					,ysnDispatchMailSent = 1
					,intConcurrencyId = intConcurrencyId + 1
				WHERE intLoadId = @intLoadId
					AND dtmDispatchMailSent IS NULL
			END

			NextRec:

			SELECT @intContractFeedId = MIN(intContractFeedId)
			FROM @tblIPContractFeed
			WHERE intContractFeedId > @intContractFeedId
		END
		
		IF ISNULL(@strLineXML, '') <> ''
		BEGIN
			SELECT @strXML += @strHeaderXML + @strLineXML + '</Header>'
		END

		NextLoad:

		SELECT @strErrorMessage =  ''

		SELECT @strErrorMessage = @strErrorMessage + ISNULL(strBatchId, '') + ' - ' + ISNULL(strMessage, '') + CHAR(13) + CHAR(10)
		FROM tblIPContractFeed
		WHERE intLoadId = @intMainLoadId
			AND intStatusId = 1
			AND ISNULL(strMessage, '') <> ''

		IF ISNULL(@strErrorMessage, '') <> ''
		BEGIN
			UPDATE tblLGLoad
			SET strComments = 'Internal: ' + CHAR(13) + CHAR(10) + @strErrorMessage
			WHERE intLoadId = @intMainLoadId
		END

		SELECT @intMainLoadId = MIN(intLoadId)
		FROM @tblLGLoad
		WHERE intLoadId > @intMainLoadId
	END

	IF @strXML <> ''
	BEGIN
		SELECT @intPOFeedId = NULL

		-- Generate Unique Id
		EXEC dbo.uspSMGetStartingNumber 183
			,@intPOFeedId OUTPUT

		SELECT @strRootXML = '<DocNo>' + LTRIM(@intPOFeedId) + '</DocNo>'

		SELECT @strRootXML += '<MsgType>Purchase_Order</MsgType>'

		SELECT @strRootXML += '<Sender>iRely</Sender>'

		SELECT @strRootXML += '<Receiver>SAP</Receiver>'

		SELECT @strFinalXML = '<root>' + @strRootXML + @strXML + '</root>'

		IF EXISTS (
				SELECT 1
				FROM @ContractFeedId
				)
		BEGIN
			UPDATE F
			SET F.intDocNo = @intPOFeedId
			FROM tblIPContractFeed F
			JOIN @ContractFeedId FS ON FS.intContractFeedId = F.intContractFeedId
		END
		
		DELETE
		FROM @tblOutput

		INSERT INTO @tblOutput (
			intContractFeedId
			,strRowState
			,strXML
			,strInfo1
			,strInfo2
			)
		VALUES (
			@intContractFeedId
			,@strHeaderRowState
			,@strFinalXML
			,ISNULL(@strContractNumber, '')
			,ISNULL(@strERPPONumber, '')
			)
	END

	UPDATE tblIPContractFeed
	SET intStatusId = NULL
	WHERE intLoadId IN (
			SELECT intLoadId
			FROM @tblLGLoad
			)
		AND intStatusId = - 1

	SELECT ISNULL(intContractFeedId, '0') AS id
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
