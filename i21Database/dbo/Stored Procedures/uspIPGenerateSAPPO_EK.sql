CREATE PROCEDURE dbo.uspIPGenerateSAPPO_EK (@ysnUpdateFeedStatus BIT = 1)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strError NVARCHAR(MAX) = ''
		,@strRowState NVARCHAR(50)
		,@strHeaderRowState NVARCHAR(50)
		,@strHeaderXML NVARCHAR(MAX) = ''
		,@strItemXML NVARCHAR(MAX) = ''
		,@strLineXML NVARCHAR(MAX) = ''
		,@strBatchXML NVARCHAR(MAX) = ''
		,@strXML NVARCHAR(MAX) = ''
		,@strRootXML NVARCHAR(MAX) = ''
		,@strFinalXML NVARCHAR(MAX) = ''
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
	DECLARE @strLoadNumber NVARCHAR(100)
		,@strVendorAccountNum NVARCHAR(100)
		,@strLocationName NVARCHAR(100)
		,@strCommodityCode NVARCHAR(100)
		,@strERPPONumber NVARCHAR(100)
	DECLARE @tblIPContractFeed TABLE (intContractFeedId INT)
	DECLARE @tblLGLoadDetail TABLE (intLoadDetailId INT)
	DECLARE @strContractNumber NVARCHAR(100)
		,@intContractSeq INT
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
	DECLARE @intPOFeedId INT
	DECLARE @ContractFeedId TABLE (intContractFeedId INT)
	DECLARE @tmp INT

	SELECT @tmp = strValue
	FROM tblIPSAPIDOCTag
	WHERE strMessageType = 'PO'
		AND strTag = 'Count'

	IF ISNULL(@tmp, 0) = 0
		SELECT @tmp = 50

	DELETE
	FROM @tblIPContractFeed

	INSERT INTO @tblIPContractFeed (intContractFeedId)
	SELECT DISTINCT TOP (@tmp) intContractFeedId
	FROM tblIPContractFeed CF
	WHERE CF.intStatusId IS NULL

	SELECT @intContractFeedId = MIN(intContractFeedId)
	FROM @tblIPContractFeed

	IF @intContractFeedId IS NULL
	BEGIN
		RETURN
	END

	UPDATE tblIPContractFeed
	SET intStatusId = - 1
	WHERE intContractFeedId IN (
			SELECT intContractFeedId
			FROM @tblIPContractFeed
			)

	WHILE @intContractFeedId IS NOT NULL
	BEGIN
		SELECT @strRowState = NULL
			,@strHeaderRowState = NULL
			,@strError = ''

		SELECT @intLoadId = NULL
			,@intLoadDetailId = NULL
			,@intCompanyLocationId = NULL

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

		IF EXISTS (
				SELECT 1
				FROM tblIPContractFeed
				WHERE intLoadId = @intLoadId
					AND intContractFeedId < @intContractFeedId
					AND ISNULL(intStatusId, 0) IN (
						2
						,3
						)
				)
		BEGIN
			SELECT @strHeaderRowState = 'U'
		END
		ELSE
		BEGIN
			SELECT @strHeaderRowState = 'C'
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

		-- Validate to check Vendor should be same for all the details in a LS
		SELECT @strHeaderXML = ''

		SELECT @strHeaderXML += '<Header>'

		SELECT @strHeaderXML += '<RefNo>' + @strLoadNumber + '</RefNo>'

		SELECT @strHeaderXML += '<VendorAccountNo>' + @strVendorAccountNum + '</VendorAccountNo>'

		SELECT @strHeaderXML += '<Location>' + @strLocationName + '</Location>'

		SELECT @strHeaderXML += '<HeaderRowState>' + @strHeaderRowState + '</HeaderRowState>'

		SELECT @strHeaderXML += '<Commodity>' + @strCommodityCode + '</Commodity>'

		DELETE
		FROM @tblLGLoadDetail

		DELETE
		FROM @ContractFeedId

		SELECT @strLineXML = ''

		INSERT INTO @tblLGLoadDetail (intLoadDetailId)
		SELECT LD.intLoadDetailId
		FROM tblLGLoadDetail LD
		WHERE LD.intLoadDetailId = @intLoadDetailId
			AND LD.intLoadId = @intLoadId

		SELECT @intLoadDetailId = MIN(intLoadDetailId)
		FROM @tblLGLoadDetail

		WHILE @intLoadDetailId IS NOT NULL
		BEGIN
			SELECT @strContractNumber = NULL
				,@intContractSeq = NULL
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
				,@strDetailRowState = @strRowState
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

			IF @strHeaderRowState = 'C'
			BEGIN
				SELECT @strDetailRowState = 'C'
			END

			SELECT @strMarketZoneCode = strMarketZoneCode
			FROM dbo.tblLGLoad L
			JOIN dbo.tblARMarketZone MZ ON MZ.intMarketZoneId = L.intMarketZoneId
			WHERE intLoadId = @intLoadId

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

			IF ISNULL(@strMarketZoneCode, '') = 'AUC'
			BEGIN
				SELECT @strContractNumber = S.strSampleNumber
				FROM dbo.tblQMSample S
				WHERE S.intSampleId = @intSampleId
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
			END

			IF ISNULL(@strContractNumber, '') = ''
			BEGIN
				SELECT @strError = @strError + 'Contract No. cannot be blank. '
			END

			IF ISNULL(@strERPPONumber, '') = ''
			BEGIN
				SELECT @strError = @strError + 'ERP PO Number cannot be blank. '
			END

			IF ISNULL(@strERPItemNumber, '') = ''
			BEGIN
				SELECT @strError = @strError + 'ERP PO Line Item No. cannot be blank. '
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

			IF @strError <> ''
			BEGIN
				UPDATE tblIPContractFeed
				SET strMessage = @strError
					,intStatusId = 1
				WHERE intContractFeedId = @intContractFeedId
					AND intLoadDetailId = @intLoadDetailId

				SELECT @strError = ''

				GOTO NextItemRec
			END

			SELECT @strItemXML = ''

			SELECT @strItemXML += '<Line>'

			SELECT @strItemXML += '<TrackingNo>' + LTRIM(@intLoadDetailId) + '</TrackingNo>'

			SELECT @strItemXML += '<RowState>' + LTRIM(@strDetailRowState) + '</RowState>'

			SELECT @strItemXML += '<ERPContractNo>' + ISNULL(@strERPContractNumber, '') + '</ERPContractNo>'

			SELECT @strItemXML += '<ContractNo>' + ISNULL(@strContractNumber, '') + '</ContractNo>'

			SELECT @strItemXML += '<SequenceNo>' + LTRIM(@intContractSeq) + '</SequenceNo>'

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

				GOTO NextItemRec
					--GOTO NextRec
			END

			-- Batch fields validations
			IF ISNULL(@strBatchId, '') = ''
			BEGIN
				SELECT @strError = @strError + 'Batch Id cannot be blank. '
			END

			IF @strError <> ''
			BEGIN
				UPDATE tblIPContractFeed
				SET strMessage = @strError
					,intStatusId = 1
				WHERE intContractFeedId = @intContractFeedId
					AND intLoadDetailId = @intLoadDetailId

				SELECT @strError = ''

				GOTO NextItemRec
			END

			SELECT @strBatchXML = ''

			SELECT @strBatchXML = @strBatchXML
				+ '<Batch>'
				+ '<LoadingPort>' + ISNULL(@strLoadingPoint, '') + '</LoadingPort>'
				+ '<DestinationPort>' + ISNULL(@strDestinationPoint, '') + '</DestinationPort>'
				+ '<LeadTime>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(@dblLeadTime, 0))) + '</LeadTime>'
				+ '<BatchId>' + B.strBatchId + '</BatchId>'
				+ '<SaleNumber>' + LTRIM(B.intSales) + '</SaleNumber>'
				+ '<SaleYear>' + LTRIM(B.intSalesYear) + '</SaleYear>'
				+ '<SalesDate>' + ISNULL(CONVERT(VARCHAR(33), B.dtmSalesDate, 126), '') + '</SalesDate>'
				+ '<TeaType>' + ISNULL(B.strTeaType, '') + '</TeaType>'
				+ '<BrokerCode>' + ISNULL(B.strBroker, '') + '</BrokerCode>'
				+ '<VendorLotNumber>' + ISNULL(B.strVendorLotNumber, '') + '</VendorLotNumber>'
				+ '<AuctionCenter>' + ISNULL(B.strBuyingCenterLocation, '') + '</AuctionCenter>'
				+ '<ThirdPartyWHStatus>' + ISNULL(B.str3PLStatus, '') + '</ThirdPartyWHStatus>'
				+ '<AdditionalSupplierReference>' + ISNULL(B.strSupplierReference, '') + '</AdditionalSupplierReference>'
				+ '<AirwayBillNumberCode>' + ISNULL(B.strAirwayBillCode, '') + '</AirwayBillNumberCode>'
				+ '<AWBSampleReceived>' + ISNULL(B.strAWBSampleReceived, '') + '</AWBSampleReceived>'
				+ '<AWBSampleReference>' + ISNULL(B.strAWBSampleReference, '') + '</AWBSampleReference>'
				+ '<BasePrice>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblBasePrice, 0))) + '</BasePrice>'
				+ '<BoughtAsReserve>' + LTRIM(ISNULL(B.ysnBoughtAsReserved, '')) + '</BoughtAsReserve>'
				+ '<BoughtPrice>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblBoughtPrice, 0))) + '</BoughtPrice>'
				+ '<BrokerWarehouse>' + ISNULL(B.strBrokerWarehouse, '') + '</BrokerWarehouse>'
				+ '<BulkDensity>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblBulkDensity, 0))) + '</BulkDensity>'
				+ '<BuyingOrderNumber>' + ISNULL(B.strBuyingOrderNumber, '') + '</BuyingOrderNumber>'
				+ '<Channel>' + ISNULL(MZ.strMarketZoneCode, '') + '</Channel>'
				+ '<ContainerNo>' + ISNULL(B.strContainerNumber, '') + '</ContainerNo>'
				+ '<Currency>' + ISNULL(C.strCurrency, '') + '</Currency>'
				+ '<DateOfProductionOfBatch>' + ISNULL(CONVERT(VARCHAR(33), B.dtmProductionBatch, 126), '') + '</DateOfProductionOfBatch>'
				+ '<DateTeaAvailableFrom>' + ISNULL(CONVERT(VARCHAR(33), B.dtmTeaAvailableFrom, 126), '') + '</DateTeaAvailableFrom>'
				+ '<DustContent>' + ISNULL(B.strDustContent, '') + '</DustContent>'
				+ '<EuropeanCompliantFlag>' + LTRIM(ISNULL(B.ysnEUCompliant, '')) + '</EuropeanCompliantFlag>'
				+ '<EvaluatorsCodeAtTBO>' + ISNULL(B.strTBOEvaluatorCode, '') + '</EvaluatorsCodeAtTBO>'
				+ '<EvaluatorsRemarks>' + ISNULL(B.strEvaluatorRemarks, '') + '</EvaluatorsRemarks>'
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
				+ '<MixingUnit>' + ISNULL(B.strMixingUnitLocation, '') + '</MixingUnit>'
				+ '<NumberOfPackagesBought>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblPackagesBought, 0))) + '</NumberOfPackagesBought>'
				+ '<OriginOfTea>' + ISNULL(B.strTeaOrigin, '') + '</OriginOfTea>'
				+ '<OriginalTeaLingoItem>' + ISNULL(I.strItemNo, '') + '</OriginalTeaLingoItem>'
				+ '<PackagesPerPallet>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblPackagesPerPallet, 0))) + '</PackagesPerPallet>'
				+ '<Plant>' + ISNULL(B.strPlant, '') + '</Plant>'
				+ '<TotalQuantity>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblTotalQuantity, 0))) + '</TotalQuantity>'
				+ '<SampleBoxNo>' + ISNULL(B.strSampleBoxNumber, '') + '</SampleBoxNo>'
				+ '<SellingPrice>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblSellingPrice, 0))) + '</SellingPrice>'
				+ '<StockDate>' + ISNULL(CONVERT(VARCHAR(33), B.dtmStock, 126), '') + '</StockDate>'
				+ '<StorageLocation>' + ISNULL(B.strStorageLocation, '') + '</StorageLocation>'
				+ '<SubChannel>' + ISNULL(B.strSubChannel, '') + '</SubChannel>'
				+ '<StrategicFlag>' + LTRIM(ISNULL(B.ysnStrategic, '')) + '</StrategicFlag>'
				+ '<SubClusterTeaLingo>' + ISNULL(B.strTeaLingoSubCluster, '') + '</SubClusterTeaLingo>'
				+ '<SupplierPreInvoiceDate>' + ISNULL(CONVERT(VARCHAR(33), B.dtmSupplierPreInvoiceDate, 126), '') + '</SupplierPreInvoiceDate>'
				+ '<Sustainability>' + ISNULL(B.strSustainability, '') + '</Sustainability>'
				+ '<TasterComments>' + ISNULL(B.strTasterComments, '') + '</TasterComments>'
				+ '<TeaAppearance>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblTeaAppearance, 0))) + '</TeaAppearance>'
				+ '<TeaBuyingOffice>' + ISNULL(B.strTeaBuyingOffice, '') + '</TeaBuyingOffice>'
				+ '<TeaColour>' + ISNULL(B.strTeaColour, '') + '</TeaColour>'
				+ '<TeaGardenChopInvoiceNo>' + ISNULL(B.strTeaGardenChopInvoiceNumber, '') + '</TeaGardenChopInvoiceNo>'
				+ '<TeaGardenMark>' + ISNULL(GM.strGardenMark, '') + '</TeaGardenMark>'
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
				+ '<Taster>' + ISNULL(B.strTaster, '') + '</Taster>'
				+ '<FeedStock>' + ISNULL(B.strFeedStock, '') + '</FeedStock>'
				+ '<FluorideLimit>' + ISNULL(B.strFlourideLimit, '') + '</FluorideLimit>'
				+ '<LocalAuctionNumber>' + ISNULL(B.strLocalAuctionNumber, '') + '</LocalAuctionNumber>'
				+ '<POStatus>' + ISNULL(B.strPOStatus, '') + '</POStatus>'
				+ '<ProductionSite>' + ISNULL(B.strProductionSite, '') + '</ProductionSite>'
				+ '<ReserveMU>' + ISNULL(B.strReserveMU, '') + '</ReserveMU>'
				+ '<QualityComments>' + ISNULL(B.strQualityComments, '') + '</QualityComments>'
				+ '<RareEarth>' + ISNULL(B.strRareEarth, '') + '</RareEarth>'
				+ '<TeaLingoVersion>' + ISNULL(I1.strGTIN, '') + '</TeaLingoVersion>'
				+ '<FreightAgent>' + ISNULL(B.strFreightAgent, '') + '</FreightAgent>'
				+ '<SealNo>' + ISNULL(B.strSealNumber, '') + '</SealNo>'
				+ '<ContainerType>' + ISNULL(B.strContainerType, '') + '</ContainerType>'
				+ '<Voyage>' + ISNULL(B.strVoyage, '') + '</Voyage>'
				+ '<Vessel>' + ISNULL(B.strVessel, '') + '</Vessel>'
				+ '</Batch>'
			FROM vyuMFBatch B
			LEFT JOIN dbo.tblQMSample S ON S.intSampleId = B.intSampleId
			LEFT JOIN dbo.tblARMarketZone MZ ON MZ.intMarketZoneId = S.intMarketZoneId
			LEFT JOIN dbo.tblSMCurrency C ON C.intCurrencyID = B.intCurrencyId
			LEFT JOIN dbo.tblSMCity CITY ON CITY.intCityId = B.intFromPortId
			LEFT JOIN dbo.tblICItem I ON I.intItemId = B.intOriginalItemId
			LEFT JOIN dbo.tblQMGardenMark GM ON GM.intGardenMarkId = B.intGardenMarkId
			LEFT JOIN dbo.tblICItem I1 ON I1.intItemId = B.intTealingoItemId
			WHERE B.intBatchId = @intBatchId

			IF ISNULL(@strBatchXML, '') = ''
			BEGIN
				UPDATE tblIPContractFeed
				SET strMessage = 'PO Line Item Batch XML is not available. '
					,intStatusId = 1
				WHERE intContractFeedId = @intContractFeedId
					AND intLoadDetailId = @intLoadDetailId

				--GOTO NextRec
				GOTO NextItemRec
			END

			SELECT @strLineXML += @strItemXML + @strBatchXML + '</Line>'

			INSERT INTO @ContractFeedId (intContractFeedId)
			SELECT @intContractFeedId

			NextItemRec:

			SELECT @intLoadDetailId = MIN(intLoadDetailId)
			FROM @tblLGLoadDetail
			WHERE intLoadDetailId > @intLoadDetailId
		END

		IF EXISTS (
				SELECT 1
				FROM @ContractFeedId
				)
		BEGIN
			SELECT @strXML += @strHeaderXML + @strLineXML + '</Header>'
		END

		IF @ysnUpdateFeedStatus = 1
		BEGIN
			UPDATE tblIPContractFeed
			SET intStatusId = 2
				,strMessage = NULL
				,strFeedStatus = 'Awt Ack'
			WHERE intContractFeedId = @intContractFeedId
		END

		NextRec:

		SELECT @intContractFeedId = MIN(intContractFeedId)
		FROM @tblIPContractFeed
		WHERE intContractFeedId > @intContractFeedId
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
	WHERE intContractFeedId IN (
			SELECT intContractFeedId
			FROM @tblIPContractFeed
			)
		AND intStatusId = - 1

	SELECT ISNULL(intContractFeedId, '0') AS id
		,ISNULL(strXML, '') AS strXml
		,ISNULL(strInfo1, '') AS strInfo1
		,ISNULL(strInfo2, '') AS strInfo2
		,'' AS strOnFailureCallbackSql
	FROM @tblOutput
	ORDER BY intRowNo
		--SELECT L.strLoadNumber
		--	,'' VendorAccountNo -- Detail
		--	,'' [Location] -- Detail
		--	,'' HeaderRowState
		--	,'' Commodity -- Detail
		--FROM dbo.tblLGLoad L
		--WHERE L.intLoadId = @intLoadId
		--SELECT LTRIM(LD.intLoadDetailId)
		--	,'' RowState
		--	,ISNULL(CH.strCustomerContract, '')
		--	,ISNULL(CH.strContractNumber, '')
		--	,LTRIM(CD.intContractSeq)
		--	,ISNULL(L.strExternalShipmentNumber, '')
		--	,ISNULL(LD.strExternalShipmentItemNumber, '')
		--	,ISNULL(I.strItemNo, '')
		--	,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(LD.dblQuantity, 0)))
		--	,ISNULL(UOM.strUnitMeasure, '')
		--	,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(LD.dblNet, 0)))
		--	,ISNULL(WUOM.strUnitMeasure, '')
		--	,ISNULL(LD.strPriceStatus, '')
		--	,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(LD.dblUnitPrice, 0)))
		--	,ISNULL(PUOM.strUnitMeasure, '')
		--	,ISNULL(CUR.strCurrency, '')
		--	,ISNULL(CONVERT(VARCHAR(33), CD.dtmStartDate, 126), '')
		--	,ISNULL(CONVERT(VARCHAR(33), CD.dtmEndDate, 126), '')
		--	,ISNULL(CONVERT(VARCHAR(33), CD.dtmPlannedAvailabilityDate, 126), '')
		--	,ISNULL(CONVERT(VARCHAR(33), CD.dtmUpdatedAvailabilityDate, 126), '')
		--	,ISNULL(CL.strLocationNumber, '')
		--	,ISNULL(CD.strPackingDescription, '')
		--	,ISNULL(CL.strOregonFacilityNumber, '')
		--	,ISNULL(LPC.strCity, '')
		--	,ISNULL(DPC.strCity, '')
		--	,LTRIM(ISNULL(LLT.dblPurchaseToShipment, 0) + ISNULL(LLT.dblPortToPort, 0) + ISNULL(LLT.dblPortToMixingUnit, 0) + ISNULL(LLT.dblMUToAvailableForBlending, 0))
		--FROM dbo.tblLGLoadDetail LD
		--JOIN dbo.tblLGLoad L ON L.intLoadId = LD.intLoadId
		--JOIN dbo.tblICItem I ON I.intItemId = LD.intItemId
		--LEFT JOIN dbo.tblICItemUOM IUOM ON IUOM.intItemUOMId = LD.intItemUOMId
		--LEFT JOIN dbo.tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId
		--LEFT JOIN dbo.tblICItemUOM WIUOM ON WIUOM.intItemUOMId = LD.intWeightItemUOMId
		--LEFT JOIN dbo.tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = WIUOM.intUnitMeasureId
		--LEFT JOIN dbo.tblICItemUOM PIUOM ON PIUOM.intItemUOMId = LD.intPriceUOMId
		--LEFT JOIN dbo.tblICUnitMeasure PUOM ON PUOM.intUnitMeasureId = PIUOM.intUnitMeasureId
		--LEFT JOIN dbo.tblSMCurrency CUR ON CUR.intCurrencyID = LD.intPriceCurrencyId
		--LEFT JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = LD.intPCompanyLocationId
		--LEFT JOIN dbo.tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
		--LEFT JOIN dbo.tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		--LEFT JOIN dbo.tblSMCity LPC ON LPC.intCityId = CD.intLoadingPortId
		--LEFT JOIN dbo.tblSMCity DPC ON DPC.intCityId = CD.intDestinationPortId
		--LEFT JOIN dbo.tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = CD.intStorageLocationId
		--LEFT JOIN dbo.tblMFLocationLeadTime LLT ON LLT.intPortOfDispatchId = CD.intLoadingPortId
		--	AND LLT.intPortOfArrivalId = CD.intDestinationPortId
		--	AND LLT.intChannelId = CD.intMarketZoneId
		--	AND LLT.strReceivingStorageLocation = CLSL.strSubLocationName
		--	AND LLT.intBuyingCenterId = CD.intCompanyLocationId
		--	AND LLT.intOriginId = I.intOriginId
		----LEFT JOIN dbo.tblMFBatch B ON B.intBatchId = LD.intBatchId
		--WHERE LD.intLoadDetailId = @intLoadDetailId
		--SELECT B.strBatchId
		--	,LTRIM(B.intSales)
		--	,LTRIM(B.intSalesYear)
		--	,ISNULL(CONVERT(VARCHAR(33), B.dtmSalesDate, 126), '')
		--	,ISNULL(B.strTeaType, '')
		--	,ISNULL(B.strBroker, '')
		--	,ISNULL(B.strVendorLotNumber, '')
		--	,ISNULL(B.strBuyingCenterLocation, '')
		--	,ISNULL(B.str3PLStatus, '')
		--	,ISNULL(B.strSupplierReference, '')
		--	,ISNULL(B.strAirwayBillCode, '')
		--	,ISNULL(B.strAWBSampleReceived, '')
		--	,ISNULL(B.strAWBSampleReference, '')
		--	,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblBasePrice, 0)))
		--	,LTRIM(ISNULL(B.ysnBoughtAsReserved, ''))
		--	,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblBoughtPrice, 0)))
		--	,ISNULL(B.strBrokerWarehouse, '')
		--	,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblBulkDensity, 0)))
		--	,ISNULL(B.strBuyingOrderNumber, '')
		--	,ISNULL(MZ.strMarketZoneCode, '')
		--	,ISNULL(B.strContainerNumber, '')
		--	,ISNULL(C.strCurrency, '')
		--	,ISNULL(CONVERT(VARCHAR(33), B.dtmProductionBatch, 126), '')
		--	,ISNULL(CONVERT(VARCHAR(33), B.dtmTeaAvailableFrom, 126), '')
		--	,ISNULL(B.strDustContent, '')
		--	,LTRIM(ISNULL(B.ysnEUCompliant, ''))
		--	,ISNULL(B.strTBOEvaluatorCode, '')
		--	,ISNULL(B.strEvaluatorRemarks, '')
		--	,ISNULL(CONVERT(VARCHAR(33), B.dtmExpiration, 126), '')
		--	,ISNULL(CITY.strCity, '')
		--	,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblGrossWeight, 0)))
		--	,ISNULL(CONVERT(VARCHAR(33), B.dtmInitialBuy, 126), '')
		--	,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblWeightPerUnit, 0)))
		--	,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblLandedPrice, 0)))
		--	,ISNULL(B.strLeafCategory, '')
		--	,ISNULL(B.strLeafManufacturingType, '')
		--	,ISNULL(B.strLeafSize, '')
		--	,ISNULL(B.strLeafStyle, '')
		--	,ISNULL(B.strMixingUnitLocation, '')
		--	,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblPackagesBought, 0)))
		--	,ISNULL(B.strTeaOrigin, '')
		--	,ISNULL(I.strItemNo, '')
		--	,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblPackagesPerPallet, 0)))
		--	,ISNULL(B.strPlant, '')
		--	,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblTotalQuantity, 0)))
		--	,ISNULL(B.strSampleBoxNumber, '')
		--	,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblSellingPrice, 0)))
		--	,ISNULL(CONVERT(VARCHAR(33), B.dtmStock, 126), '')
		--	,ISNULL(B.strStorageLocation, '')
		--	,ISNULL(B.strSubChannel, '')
		--	,LTRIM(ISNULL(B.ysnStrategic, ''))
		--	,ISNULL(B.strTeaLingoSubCluster, '')
		--	,ISNULL(CONVERT(VARCHAR(33), B.dtmSupplierPreInvoiceDate, 126), '')
		--	,ISNULL(B.strSustainability, '')
		--	,ISNULL(B.strTasterComments, '')
		--	,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblTeaAppearance, 0)))
		--	,ISNULL(B.strTeaBuyingOffice, '')
		--	,ISNULL(B.strTeaColour, '')
		--	,ISNULL(B.strTeaGardenChopInvoiceNumber, '')
		--	,ISNULL(GM.strGardenMark, '')
		--	,ISNULL(B.strTeaGroup, '')
		--	,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblTeaHue, 0)))
		--	,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblTeaIntensity, 0)))
		--	,ISNULL(B.strLeafGrade, '')
		--	,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblTeaMoisture, 0)))
		--	,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblTeaMouthFeel, 0)))
		--	,LTRIM(ISNULL(B.ysnTeaOrganic, ''))
		--	,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblTeaTaste, 0)))
		--	,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblTeaVolume, 0)))
		--	,ISNULL(B.strItemNo, '')
		--	,ISNULL(B.strTINNumber, '')
		--	,ISNULL(CONVERT(VARCHAR(33), B.dtmWarehouseArrival, 126), '')
		--	,LTRIM(ISNULL(B.intYearManufacture, ''))
		--	,ISNULL(B.strPackageSize, '')
		--	,ISNULL(B.strPackageUOM, '')
		--	,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblTareWeight, 0)))
		--	,ISNULL(B.strTaster, '')
		--	,ISNULL(B.strFeedStock, '')
		--	,ISNULL(B.strFlourideLimit, '')
		--	,ISNULL(B.strLocalAuctionNumber, '')
		--	,ISNULL(B.strPOStatus, '')
		--	,ISNULL(B.strProductionSite, '')
		--	,ISNULL(B.strReserveMU, '')
		--	,ISNULL(B.strQualityComments, '')
		--	,ISNULL(B.strRareEarth, '')
		--	,ISNULL(I1.strGTIN, '')
		--	,ISNULL(B.strFreightAgent, '')
		--	,ISNULL(B.strSealNumber, '')
		--	,ISNULL(B.strContainerType, '')
		--	,ISNULL(B.strVoyage, '')
		--	,ISNULL(B.strVessel, '')
		--FROM vyuMFBatch B
		--LEFT JOIN dbo.tblQMSample S ON S.intSampleId = B.intSampleId
		--LEFT JOIN dbo.tblARMarketZone MZ ON MZ.intMarketZoneId = S.intMarketZoneId
		--LEFT JOIN dbo.tblSMCurrency C ON C.intCurrencyID = B.intCurrencyId
		--LEFT JOIN dbo.tblSMCity CITY ON CITY.intCityId = B.intFromPortId
		--LEFT JOIN dbo.tblICItem I ON I.intItemId = B.intOriginalItemId
		--LEFT JOIN dbo.tblQMGardenMark GM ON GM.intGardenMarkId = B.intGardenMarkId
		--LEFT JOIN dbo.tblICItem I1 ON I1.intItemId = B.intTealingoItemId
		--WHERE B.intBatchId = @intBatchId
		--SELECT '0' AS id
		--	,'<root><DocNo>930</DocNo><MsgType>Purchase_Order</MsgType><Sender>iRely</Sender><Receiver>SAP</Receiver><Header><RefNo>LS-1</RefNo><VendorAccountNo>IR0000001</VendorAccountNo><Location>KEMB</Location><HeaderRowState>U</HeaderRowState><Commodity>Tea</Commodity><Line><TrackingNo>100</TrackingNo><RowState>U</RowState><ERPContractNo>ERP1001</ERPContractNo><ContractNo>P100</ContractNo><SequenceNo>1</SequenceNo><PONumber>ERPPO1001</PONumber><POLineItemNo>10</POLineItemNo><ItemNo>DE13KE-R</ItemNo><Quantity>10</Quantity><QuantityUOM>500 Kg Bags</QuantityUOM><NetWeight>5000</NetWeight><NetWeightUOM>KG</NetWeightUOM><PriceType>Cash</PriceType><Price>2.5</Price><PriceUOM>500 Kg Bags</PriceUOM><PriceCurrency>USD</PriceCurrency><StartDate>2022-08-01T00:00:00</StartDate><EndDate>2022-08-31T00:00:00</EndDate><PlannedAvlDate>2022-08-31T00:00:00</PlannedAvlDate><UpdatedAvlDate>2022-08-31T00:00:00</UpdatedAvlDate><PurchGroup>F51</PurchGroup><PackDesc>Bags</PackDesc><VirtualPlant>A460</VirtualPlant><Batch><LoadingPort>Mombasa</LoadingPort><DestinationPort>Dubai</DestinationPort><LeadTime>34</LeadTime><BatchId>0KA219768</BatchId><SaleNumber>2</SaleNumber><SaleYear>2020</SaleYear><SalesDate>2022-10-11T00:00:00</SalesDate><TeaType>M</TeaType><BrokerCode>KECOM</BrokerCode><VendorLotNumber>100001</VendorLotNumber><AuctionCenter>KEMB</AuctionCenter><ThirdPartyWHStatus>Open</ThirdPartyWHStatus><AdditionalSupplierReference>SR00001</AdditionalSupplierReference><AirwayBillNumberCode>DHL#3805340954</AirwayBillNumberCode><AWBSampleReceived>Yes</AWBSampleReceived><AWBSampleReference>10001</AWBSampleReference><BasePrice>1.35</BasePrice><BoughtAsReserve>Yes</BoughtAsReserve><BoughtPrice>1.46</BoughtPrice><BrokerWarehouse>KEMITU</BrokerWarehouse><BulkDensity>0</BulkDensity><BuyingOrderNumber>444</BuyingOrderNumber><Channel>Auction</Channel><ContainerNo>MRKU123456</ContainerNo><Currency>USD</Currency><DateOfProductionOfBatch>2022-10-11T00:00:00</DateOfProductionOfBatch><DateTeaAvailableFrom>2022-10-11T00:00:00</DateTeaAvailableFrom><DustContent>Sample</DustContent><EuropeanCompliantFlag>Yes</EuropeanCompliantFlag><EvaluatorsCodeAtTBO>DU987</EvaluatorsCodeAtTBO><EvaluatorsRemarks>Woody taste</EvaluatorsRemarks><ExpirationDateShelfLife>2022-10-11T00:00:00</ExpirationDateShelfLife><FromLocationCode>KE01</FromLocationCode><GrossWt>2112</GrossWt><InitialBuyDate>2022-10-11T00:00:00</InitialBuyDate><WeightPerUnit>51</WeightPerUnit><LandedPrice>1.56</LandedPrice><LeafCategory>FANNINGS</LeafCategory><LeafManufacturingType>CTC</LeafManufacturingType><LeafSize>D</LeafSize><LeafStyle>3</LeafStyle><MixingUnit>RULED</MixingUnit><NumberOfPackagesBought>40</NumberOfPackagesBought><OriginOfTea>UG</OriginOfTea><OriginalTeaLingoItem>DG22UG-R</OriginalTeaLingoItem><PackagesPerPallet>20</PackagesPerPallet><Plant>WU01</Plant><TotalQuantity>2000</TotalQuantity><SampleBoxNo>A528</SampleBoxNo><SellingPrice>1.54</SellingPrice><StockDate>2022-10-11T00:00:00</StockDate><StorageLocation>W019</StorageLocation><SubChannel>Yes</SubChannel><StrategicFlag>Yes</StrategicFlag><SubClusterTeaLingo>G2</SubClusterTeaLingo><SupplierPreInvoiceDate>2022-10-11T00:00:00</SupplierPreInvoiceDate><Sustainability>RA</Sustainability><TasterComments>Woody</TasterComments><TeaAppearance>0</TeaAppearance><TeaBuyingOffice>F51</TeaBuyingOffice><TeaColour>B</TeaColour><TeaGardenChopInvoiceNo>UK521781X</TeaGardenChopInvoiceNo><TeaGardenMark>BUGAMBE</TeaGardenMark><TeaGroup>DG22</TeaGroup><TeaHue>0.6</TeaHue><TeaIntensity>4.4</TeaIntensity><TeaLeafGrade>PF1</TeaLeafGrade><TeaMoisture>0</TeaMoisture><TeaMouthfeel>4.6</TeaMouthfeel><TeaOrganic>Yes</TeaOrganic><TeaTaste>4</TeaTaste><TeaVolume>125</TeaVolume><TeaLingoItem>DG23UG-R</TeaLingoItem><TinNumber>9208</TinNumber><WarehouseArrivalDate>2022-10-11T00:00:00</WarehouseArrivalDate><YearOfManufacture>2020</YearOfManufacture><PackageSize>B</PackageSize><PackageType>B</PackageType><TareWt>0</TareWt><Taster>Roop</Taster><FeedStock>BCFMS</FeedStock><FluorideLimit>0.02</FluorideLimit><LocalAuctionNumber>10001</LocalAuctionNumber><POStatus>Open</POStatus><ProductionSite>Sample</ProductionSite><ReserveMU>RULED</ReserveMU><QualityComments>Good</QualityComments><RareEarth>Sample</RareEarth><TeaLingoVersion>8.2</TeaLingoVersion><FreightAgent>Sample</FreightAgent><SealNo>S123</SealNo><ContainerType>20 FT</ContainerType><Voyage>V123</Voyage><Vessel>Sample</Vessel></Batch></Line></Header></root>' 
		--	AS strXml
		--	,'PO-1' AS strInfo1
		--	,'ERP-PO-123' AS strInfo2
		--	,'' AS strOnFailureCallbackSql
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
