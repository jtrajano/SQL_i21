Create PROCEDURE uspIPGenerateERPBatchRecategorization_EK (
	@limit INT = 100
	,@offset INT = 0
	,@ysnUpdateFeedStatus BIT = 1
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@intBatchPreStageId INT
		,@strXML NVARCHAR(MAX) = ''
		,@strRootXML NVARCHAR(MAX) = ''
		,@strHeaderXML NVARCHAR(MAX) = ''
		,@strERPOrderNo NVARCHAR(50)
		,@intWorkOrderId INT
		,@intLocationId INT
		,@strPlantNo NVARCHAR(50)
		,@strError NVARCHAR(MAX) = ''
		,@strWorkOrderNo NVARCHAR(50)
		,@strERPPONumber NVARCHAR(50)
		,@intBatchId INT
		,@intOriginalItemId INT
		,@intItemId INT
		,@strItemNo NVARCHAR(50)
		,@strOriginalItemNo NVARCHAR(50)
		,@strERPPOLineNo NVARCHAR(50)
		,@strLocationNumber NVARCHAR(50)
		,@strBatchXML NVARCHAR(MAX) = ''
		,@strTeaOrigin 	NVARCHAR(50)
		,@strISOCode	 NVARCHAR(50)
		,@strMarketZoneCode NVARCHAR(50)
		,@strBatchNo  NVARCHAR(50)
	DECLARE @tblOutput AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intBatchId INT
		,strRowState NVARCHAR(50)
		,strXML NVARCHAR(MAX)
		,strBatchNo NVARCHAR(50)
		,strERPOrderNo NVARCHAR(50)
		)
	DECLARE @tblMFBatchPreStage TABLE (intBatchPreStageId INT)

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblMFBatchPreStage
			WHERE intStatusId IS NULL
			)
	BEGIN
		RETURN
	END

	DECLARE @tmp INT
		,@FirstCount INT = 0

	SELECT @tmp = strValue
	FROM tblIPSAPIDOCTag
	WHERE strMessageType = 'Batch Recategorization'
		AND strTag = 'Count'

	IF ISNULL(@tmp, 0) = 0
		SELECT @tmp = 50

	IF @limit > @tmp
	BEGIN
		SELECT @limit = @tmp
	END

	INSERT INTO @tblMFBatchPreStage (intBatchPreStageId)
	SELECT TOP (@limit) PS.intBatchPreStageId
	FROM dbo.tblMFBatchPreStage PS
	WHERE PS.intStatusId IS NULL
	ORDER BY intBatchPreStageId

	SELECT @intBatchPreStageId = MIN(intBatchPreStageId)
	FROM @tblMFBatchPreStage

	IF @intBatchPreStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE dbo.tblMFBatchPreStage
	SET intStatusId = - 1
	WHERE intBatchPreStageId IN (
			SELECT PS.intBatchPreStageId
			FROM @tblMFBatchPreStage PS
			)

	SELECT @strRootXML = '<root><CtrlPoint><DocNo>' + IsNULL(ltrim(@intBatchPreStageId), '') + '</DocNo>' + '<MsgType>Stock_Recategorization</MsgType>' + '<Sender>iRely</Sender>' + '<Receiver>SAP</Receiver></CtrlPoint>'

	WHILE @intBatchPreStageId IS NOT NULL
	BEGIN
		SELECT @intBatchId = NULL
			,@intOriginalItemId = NULL
			,@intItemId = NULL
			,@strItemNo = NULL
			,@strOriginalItemNo = NULL
			,@strLocationNumber =NULL
			, @strERPPONumber = NULL
			,@strERPPOLineNo = NULL
			,@intLocationId =  NULL
			,@strTeaOrigin=NULL
			,@strTeaOrigin=NULL
			,@strMarketZoneCode = NULL
			,@strBatchNo=NULL

		SELECT @intBatchId = intBatchId
			,@intOriginalItemId = intOriginalItemId
			,@intItemId = intItemId
		FROM tblMFBatchPreStage
		WHERE intBatchPreStageId = @intBatchPreStageId

		SELECT @strItemNo = strItemNo
		FROM tblICItem
		WHERE intItemId = @intItemId

		SELECT @strOriginalItemNo = strItemNo
		FROM tblICItem
		WHERE intItemId = @intOriginalItemId

		SELECT @strERPPONumber = strERPPONumber
			,@strERPPOLineNo = strERPPOLineNo
			,@intLocationId =  intBuyingCenterLocationId
			,@strTeaOrigin=strTeaOrigin 
			,@strBatchNo=strBatchId 
		FROM dbo.tblMFBatch
		WHERE intBatchId = @intBatchId

		SELECT @strISOCode = strISOCode
		FROM dbo.tblSMCountry C WITH (NOLOCK)
		WHERE C.strCountry = @strTeaOrigin

		Select 	@strLocationNumber =strLocationNumber 
		from tblSMCompanyLocation
		Where intCompanyLocationId=@intLocationId
				   SELECT @strHeaderXML =''
		SELECT @strHeaderXML =  '<Header>'
				+'<TransactionType>15</TransactionType>'
				+'<Location>' + IsNULL(@strLocationNumber, '') + '</Location>' 
				+'<StorageLocation></StorageLocation>'
				+'<StorageUnit></StorageUnit>'
				+'<OldItemNo>' + IsNULL(@strOriginalItemNo, '') + '</OldItemNo>'
				+'<NewItemNo>' + IsNULL(@strItemNo, '') + '</NewItemNo>'
				+'<LotNo>' + IsNULL(@strBatchNo , '') + '</LotNo>'
				+'<PONumber>' + IsNULL(@strERPPONumber, '') + '</PONumber>'
				+'<POLineItemNo>' + IsNULL(@strERPPOLineNo, '') + '</POLineItemNo>'
		SELECT @strBatchXML = ''

			SELECT @strBatchXML = @strBatchXML
				+ '<Batch>'
				+ '<BatchId>' + B.strBatchId + '</BatchId>'
				+ '<SaleNumber>' + LTRIM(B.intSales) + '</SaleNumber>'
				+ '<SaleYear>' + LTRIM(B.intSalesYear) + '</SaleYear>'
				+ '<SalesDate>' + ISNULL(CONVERT(VARCHAR(33), B.dtmSalesDate, 23), '') + '</SalesDate>'
				+ '<TeaType>' + ISNULL(B.strTeaType, '') + '</TeaType>'
				+ '<BrokerCode>' + dbo.fnEscapeXML(ISNULL(B.strBroker, '')) + '</BrokerCode>'
				+ '<VendorLotNumber>' + ISNULL(B.strVendorLotNumber, '') + '</VendorLotNumber>'
				+ '<AuctionCenter>' + ISNULL(B.strBuyingCenterLocation, '') + '</AuctionCenter>'
				+ '<ThirdPartyWHStatus>' + ISNULL(B.str3PLStatus, '') + '</ThirdPartyWHStatus>'
				+ '<AdditionalSupplierReference>' + ISNULL(LEFT(B.strSupplierReference, 15), '') + '</AdditionalSupplierReference>'
				+ '<AirwayBillNumberCode>' + ISNULL(B.strAirwayBillCode, '') + '</AirwayBillNumberCode>'
				+ '<AWBSampleReceived>' + ISNULL(B.strAWBSampleReceived, '') + '</AWBSampleReceived>'
				+ '<AWBSampleReference>' + ISNULL(LEFT(B.strAWBSampleReference, 15), '') + '</AWBSampleReference>'
				+ '<BasePrice>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblBasePrice, 0))) + '</BasePrice>'
				+ '<BoughtAsReserve>' + LTRIM(ISNULL(B.ysnBoughtAsReserved, '')) + '</BoughtAsReserve>'
				+ '<BoughtPrice>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblBoughtPrice, 0))) + '</BoughtPrice>'
				+ '<BrokerWarehouse>' + ISNULL(LEFT(B.strBrokerWarehouse, 15), '') + '</BrokerWarehouse>'
				+ '<BulkDensity>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblBulkDensity, 0))) + '</BulkDensity>'
				+ '<BuyingOrderNumber>' + ISNULL(B.strBuyingOrderNumber, '') + '</BuyingOrderNumber>'
				+ '<Channel>' + ISNULL(MZ.strMarketZoneCode, '') + '</Channel>'
				+ '<ContainerNo>' + ISNULL(B.strContainerNumber, '') + '</ContainerNo>'
				+ '<Currency>' + ISNULL(C.strCurrency, '') + '</Currency>'
				+ '<DateOfProductionOfBatch>' + ISNULL(CONVERT(VARCHAR(33), B.dtmProductionBatch, 23), '') + '</DateOfProductionOfBatch>'
				+ '<DateTeaAvailableFrom>' + ISNULL(CONVERT(VARCHAR(33), B.dtmTeaAvailableFrom, 23), '') + '</DateTeaAvailableFrom>'
				+ '<DustContent>' + ISNULL(B.strDustContent, '') + '</DustContent>'
				+ '<EuropeanCompliantFlag></EuropeanCompliantFlag>'
				+ '<EvaluatorsCodeAtTBO>' + ISNULL(B.strTBOEvaluatorCode, '') + '</EvaluatorsCodeAtTBO>'
				+ '<EvaluatorsRemarks>' + dbo.fnEscapeXML(ISNULL(LEFT(B.strEvaluatorRemarks, 15), '')) + '</EvaluatorsRemarks>'
				+ '<ExpirationDateShelfLife>' + ISNULL(CONVERT(VARCHAR(33), B.dtmExpiration, 23), '') + '</ExpirationDateShelfLife>'
				+ '<FromLocationCode>' + ISNULL(CITY.strCity, '') + '</FromLocationCode>'
				+ '<GrossWt>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblGrossWeight, 0))) + '</GrossWt>'
				+ '<InitialBuyDate>' + ISNULL(CONVERT(VARCHAR(33), B.dtmInitialBuy, 23), '') + '</InitialBuyDate>'
				+ '<WeightPerUnit>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblWeightPerUnit, 0))) + '</WeightPerUnit>'
				+ '<LandedPrice>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblLandedPrice, 0))) + '</LandedPrice>'
				+ '<LeafCategory>' + ISNULL(B.strLeafCategory, '') + '</LeafCategory>'
				+ '<LeafManufacturingType>' + ISNULL(B.strLeafManufacturingType, '') + '</LeafManufacturingType>'
				+ '<LeafSize>' + ISNULL(B.strLeafSize, '') + '</LeafSize>'
				+ '<LeafStyle>' + ISNULL(B.strLeafStyle, '') + '</LeafStyle>'
				+ '<MixingUnit>' + ISNULL(B.strMixingUnitLocation, '') + '</MixingUnit>'
				+ '<NumberOfPackagesBought>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblPackagesBought, 0))) + '</NumberOfPackagesBought>'
				+ '<OriginOfTea>' + ISNULL(@strISOCode, '') + '</OriginOfTea>'
				+ '<OriginalTeaLingoItem>' + ISNULL(I.strItemNo, '') + '</OriginalTeaLingoItem>'
				+ '<PackagesPerPallet>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblPackagesPerPallet, 0))) + '</PackagesPerPallet>'
				+ '<Plant>' + ISNULL(CL.strVendorRefNoPrefix, '') + '</Plant>'
				+ '<TotalQuantity>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblTotalQuantity, 0))) + '</TotalQuantity>'
				+ '<SampleBoxNo>' + ISNULL(B.strSampleBoxNumber, '') + '</SampleBoxNo>'
				+ '<SellingPrice>' + LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblSellingPrice, 0))) + '</SellingPrice>'
				+ '<StockDate>' + ISNULL(CONVERT(VARCHAR(33), B.dtmStock, 23), '') + '</StockDate>'
				+ '<StorageLocation>' + ISNULL(B.strStorageLocation, '') + '</StorageLocation>'
				+ '<SubChannel>' + ISNULL(B.strSubChannel, '') + '</SubChannel>'
				+ '<StrategicFlag>' + LTRIM(ISNULL(B.ysnStrategic, '')) + '</StrategicFlag>'
				+ '<SubClusterTeaLingo>' + ISNULL(B.strTeaLingoSubCluster, '') + '</SubClusterTeaLingo>'
				+ '<SupplierPreInvoiceDate>' + ISNULL(CONVERT(VARCHAR(33), B.dtmSupplierPreInvoiceDate, 23), '') + '</SupplierPreInvoiceDate>'
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
				+ '<WarehouseArrivalDate>' + ISNULL(CONVERT(VARCHAR(33), B.dtmWarehouseArrival, 23), '') + '</WarehouseArrivalDate>'
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
				+ '</Batch>'
			FROM vyuMFBatch B WITH (NOLOCK)
			LEFT JOIN dbo.tblSMCurrency C WITH (NOLOCK) ON C.intCurrencyID = B.intCurrencyId
			LEFT JOIN dbo.tblSMCity CITY WITH (NOLOCK) ON CITY.intCityId = B.intFromPortId
			LEFT JOIN dbo.tblICItem I WITH (NOLOCK) ON I.intItemId = B.intOriginalItemId
			LEFT JOIN dbo.tblQMGardenMark GM WITH (NOLOCK) ON GM.intGardenMarkId = B.intGardenMarkId
			LEFT JOIN dbo.tblICItem I1 WITH (NOLOCK) ON I1.intItemId = B.intTealingoItemId
			LEFT JOIN dbo.tblSMCompanyLocation CL WITH (NOLOCK) ON CL.intCompanyLocationId = B.intMixingUnitLocationId
			LEFT JOIN dbo.tblQMSample S WITH (NOLOCK) ON S.intSampleId = B.intSampleId
			LEFT JOIN dbo.tblARMarketZone MZ WITH (NOLOCK) ON MZ.intMarketZoneId = S.intMarketZoneId
			WHERE B.intBatchId = @intBatchId

			IF ISNULL(@strBatchXML, '') = ''
			BEGIN
				UPDATE tblMFBatchPreStage
				SET strMessage = 'Batch XML is not available. '
					,intStatusId = 1
				WHERE intBatchPreStageId = @intBatchPreStageId

				--GOTO NextRec
				GOTO NextItemRec
			END

			SELECT @strXML = @strXML + @strHeaderXML +@strBatchXML+ '</Header>'

		IF @ysnUpdateFeedStatus = 1
		BEGIN
			UPDATE dbo.tblMFBatchPreStage
			SET intStatusId = 2
				,strMessage = 'Success'
			WHERE intBatchPreStageId = @intBatchPreStageId
		END
			NextItemRec:

		SELECT @intBatchPreStageId = MIN(intBatchPreStageId)
		FROM @tblMFBatchPreStage
		WHERE intBatchPreStageId > @intBatchPreStageId
	END

	IF LEN(@strXML)>0
	BEGIN
		   SELECT @strXML = @strRootXML + @strXML +  '</root>'

		INSERT INTO @tblOutput (
			intBatchId
			,strRowState
			,strXML
			,strBatchNo
			,strERPOrderNo
			)
		VALUES (
			@intWorkOrderId
			,'Added'
			,@strXML
			,ISNULL(@strWorkOrderNo, '')
			,ISNULL(@strERPOrderNo, '')
			)
	END

	UPDATE dbo.tblMFBatchPreStage
	SET intStatusId = NULL
	WHERE intBatchPreStageId IN (
			SELECT PS.intBatchPreStageId
			FROM @tblMFBatchPreStage PS
			)
		AND intStatusId = - 1

	SELECT IsNULL(intBatchId, '0') AS id
		,IsNULL(strXML, '') AS strXml
		,IsNULL(strBatchNo, '') AS strInfo1
		,IsNULL(strERPOrderNo, '') AS strInfo2
		,'' AS strOnFailuBatchbackSql
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
