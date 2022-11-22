CREATE PROCEDURE dbo.uspIPGenerateSAPPO_EK (@ysnUpdateFeedStatus BIT = 1)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	
	DECLARE @strHeaderXML NVARCHAR(MAX) = ''
	DECLARE @intLoadId INT

	SELECT @intLoadId = NULL
	
	SELECT @strHeaderXML = ''

	SELECT L.strLoadNumber
		,'' VendorAccountNo
		,ISNULL(CL.strLocationName, '')
		,'' HeaderRowState
		,'' Commodity
	FROM dbo.tblLGLoad L
	LEFT JOIN dbo.tblAPVendor V ON V.intEntityId = L.intEntityId
	LEFT JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = L.intCompanyLocationId
	WHERE L.intLoadId = @intLoadId
	

	DECLARE @strItemXML NVARCHAR(MAX) = ''
	DECLARE @intLoadDetailId INT

	SELECT @intLoadDetailId = NULL
	
	SELECT @strItemXML = ''

	SELECT LTRIM(LD.intLoadDetailId)
		,'' RowState
		,ISNULL(CH.strCustomerContract, '')
		,ISNULL(CH.strContractNumber, '')
		,LTRIM(CD.intContractSeq)
		,ISNULL(L.strExternalShipmentNumber, '')
		,ISNULL(LD.strExternalShipmentItemNumber, '')
		,ISNULL(I.strItemNo, '')
		,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(LD.dblQuantity, 0)))
		,ISNULL(UOM.strUnitMeasure, '')
		,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(LD.dblNet, 0)))
		,ISNULL(WUOM.strUnitMeasure, '')
		,ISNULL(LD.strPriceStatus, '')
		,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(LD.dblUnitPrice, 0)))
		,ISNULL(PUOM.strUnitMeasure, '')
		,ISNULL(CUR.strCurrency, '')
		,ISNULL(CONVERT(VARCHAR(33), CD.dtmStartDate, 126), '')
		,ISNULL(CONVERT(VARCHAR(33), CD.dtmEndDate, 126), '')
		,ISNULL(CONVERT(VARCHAR(33), CD.dtmPlannedAvailabilityDate, 126), '')
		,ISNULL(CONVERT(VARCHAR(33), CD.dtmUpdatedAvailabilityDate, 126), '')
		,ISNULL(CL.strLocationNumber, '')
		,ISNULL(CD.strPackingDescription, '')
		,'' VirtualPlant
		,ISNULL(LPC.strCity, '')
		,ISNULL(DPC.strCity, '')
		,'' LeadTime -- Calculate ,LTRIM(ISNULL(LD.LeadTime, 0))
	FROM dbo.tblLGLoadDetail LD
	JOIN dbo.tblLGLoad L ON L.intLoadId = LD.intLoadId
	JOIN dbo.tblICItem I ON I.intItemId = LD.intItemId
	LEFT JOIN dbo.tblICItemUOM IUOM ON IUOM.intItemUOMId = LD.intItemUOMId
	LEFT JOIN dbo.tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IUOM.intUnitMeasureId
	LEFT JOIN dbo.tblICItemUOM WIUOM ON WIUOM.intItemUOMId = LD.intWeightItemUOMId
	LEFT JOIN dbo.tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = WIUOM.intUnitMeasureId
	LEFT JOIN dbo.tblICItemUOM PIUOM ON PIUOM.intItemUOMId = LD.intPriceUOMId
	LEFT JOIN dbo.tblICUnitMeasure PUOM ON PUOM.intUnitMeasureId = PIUOM.intUnitMeasureId
	LEFT JOIN dbo.tblSMCurrency CUR ON CUR.intCurrencyID = LD.intPriceCurrencyId
	LEFT JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = LD.intPCompanyLocationId
	LEFT JOIN dbo.tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
	LEFT JOIN dbo.tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN dbo.tblSMCity LPC ON LPC.intCityId = CD.intLoadingPortId
	LEFT JOIN dbo.tblSMCity DPC ON DPC.intCityId = CD.intDestinationPortId
	--LEFT JOIN dbo.tblMFBatch B ON B.intContractDetailId = CD.intContractDetailId --It should be based on intBatchId
	WHERE LD.intLoadDetailId = @intLoadDetailId


	DECLARE @strBatchXML NVARCHAR(MAX) = ''
	DECLARE @intBatchId INT

	SELECT @intBatchId = NULL

	SELECT @strBatchXML = ''

	SELECT B.strBatchId
		,LTRIM(B.intSales)
		,LTRIM(B.intSalesYear)
		,ISNULL(B.strTeaType, '')
		,ISNULL(B.strBroker, '')
		,ISNULL(B.strVendorLotNumber, '')
		,ISNULL(B.strBuyingCenterLocation, '')
		,ISNULL(B.str3PLStatus, '')
		,ISNULL(B.strSupplierReference, '')
		,ISNULL(B.strAirwayBillCode, '')
		,ISNULL(B.strAWBSampleReceived, '')
		,ISNULL(B.strAWBSampleReference, '')
		,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblBasePrice, 0)))
		,LTRIM(ISNULL(B.ysnBoughtAsReserved, ''))
		,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblBoughtPrice, 0)))
		,ISNULL(B.strBrokerWarehouse, '')
		,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblBulkDensity, 0)))
		,ISNULL(B.strBuyingOrderNumber, '')
		,ISNULL(SB.strSubBook, '')
		,ISNULL(B.strContainerNumber, '')
		,ISNULL(C.strCurrency, '')
		,ISNULL(CONVERT(VARCHAR(33), B.dtmProductionBatch, 126), '')
		,ISNULL(CONVERT(VARCHAR(33), B.dtmTeaAvailableFrom, 126), '')
		,ISNULL(B.strDustContent, '')
		,LTRIM(ISNULL(B.ysnEUCompliant, ''))
		,ISNULL(B.strTBOEvaluatorCode, '')
		,ISNULL(B.strEvaluatorRemarks, '')
		,ISNULL(CONVERT(VARCHAR(33), B.dtmExpiration, 126), '')
		,ISNULL(CITY.strCity, '')
		,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblGrossWeight, 0)))
		,ISNULL(CONVERT(VARCHAR(33), B.dtmInitialBuy, 126), '')
		,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblWeightPerUnit, 0)))
		,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblLandedPrice, 0)))
		,ISNULL(B.strLeafCategory, '')
		,ISNULL(B.strLeafManufacturingType, '')
		,ISNULL(B.strLeafSize, '')
		,ISNULL(B.strLeafStyle, '')
		,ISNULL(B.strMixingUnitLocation, '')
		,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblPackagesBought, 0)))
		,ISNULL(B.strTeaOrigin, '')
		,ISNULL(I.strItemNo, '')
		,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblPackagesPerPallet, 0)))
		,ISNULL(B.strPlant, '')
		,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblTotalQuantity, 0)))
		,ISNULL(B.strSampleBoxNumber, '')
		,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblSellingPrice, 0)))
		,ISNULL(CONVERT(VARCHAR(33), B.dtmStock, 126), '')
		,ISNULL(B.strStorageLocation, '')
		,ISNULL(B.strSubChannel, '')
		,LTRIM(ISNULL(B.ysnStrategic, ''))
		,ISNULL(B.strTeaLingoSubCluster, '')
		,ISNULL(CONVERT(VARCHAR(33), B.dtmSupplierPreInvoiceDate, 126), '')
		,ISNULL(B.strSustainability, '')
		,ISNULL(B.strTasterComments, '')
		,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblTeaAppearance, 0)))
		,ISNULL(B.strTeaBuyingOffice, '')
		,ISNULL(B.strTeaColour, '')
		,ISNULL(B.strTeaGardenChopInvoiceNumber, '')
		,ISNULL(GM.strGardenMark, '')
		,ISNULL(B.strTeaGroup, '')
		,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblTeaHue, 0)))
		,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblTeaIntensity, 0)))
		,ISNULL(B.strLeafGrade, '')
		,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblTeaMoisture, 0)))
		,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblTeaMouthFeel, 0)))
		,LTRIM(ISNULL(B.ysnTeaOrganic, ''))
		,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblTeaTaste, 0)))
		,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblTeaVolume, 0)))
		,ISNULL(B.strItemNo, '')
		,ISNULL(B.strTINNumber, '')
		,ISNULL(CONVERT(VARCHAR(33), B.dtmWarehouseArrival, 126), '')
		,LTRIM(ISNULL(B.intYearManufacture, ''))
		,ISNULL(B.strPackageSize, '')
		,ISNULL(B.strPackageUOM, '')
		,LTRIM(CONVERT(NUMERIC(18, 2), ISNULL(B.dblTareWeight, 0)))
		,ISNULL(B.strTaster, '')
		,ISNULL(B.strFeedStock, '')
		,ISNULL(B.strFlourideLimit, '')
		,ISNULL(B.strLocalAuctionNumber, '')
		,ISNULL(B.strPOStatus, '')
		,ISNULL(B.strProductionSite, '')
		,ISNULL(B.strReserveMU, '')
		,ISNULL(B.strQualityComments, '')
		,ISNULL(B.strRareEarth, '')
		,'' TeaLingoVersion
		,ISNULL(B.strFreightAgent, '')
		,ISNULL(B.strSealNumber, '')
		,ISNULL(B.strContainerType, '')
		,ISNULL(B.strVoyage, '')
		,ISNULL(B.strVessel, '')
	FROM vyuMFBatch B
	LEFT JOIN dbo.tblCTSubBook SB ON SB.intSubBookId = B.intSubBookId
	LEFT JOIN dbo.tblSMCurrency C ON C.intCurrencyID = B.intCurrencyId
	LEFT JOIN dbo.tblSMCity CITY ON CITY.intCityId = B.intFromPortId
	LEFT JOIN dbo.tblICItem I ON I.intItemId = B.intOriginalItemId
	LEFT JOIN dbo.tblQMGardenMark GM ON GM.intGardenMarkId = B.intGardenMarkId
	WHERE B.intBatchId = @intBatchId

	SELECT '0' AS id
		,'<root><DocNo>930</DocNo><MsgType>Purchase_Order</MsgType><Sender>iRely</Sender><Receiver>SAP</Receiver><Header><RefNo>LS-1</RefNo><VendorAccountNo>IR0000001</VendorAccountNo><Location>KEMB</Location><HeaderRowState>U</HeaderRowState><Commodity>Tea</Commodity><Line><TrackingNo>100</TrackingNo><RowState>U</RowState><ERPContractNo>ERP1001</ERPContractNo><ContractNo>P100</ContractNo><SequenceNo>1</SequenceNo><PONumber>ERPPO1001</PONumber><POLineItemNo>10</POLineItemNo><ItemNo>DE13KE-R</ItemNo><Quantity>10</Quantity><QuantityUOM>500 Kg Bags</QuantityUOM><NetWeight>5000</NetWeight><NetWeightUOM>KG</NetWeightUOM><PriceType>Cash</PriceType><Price>2.5</Price><PriceUOM>500 Kg Bags</PriceUOM><PriceCurrency>USD</PriceCurrency><StartDate>2022-08-01T00:00:00</StartDate><EndDate>2022-08-31T00:00:00</EndDate><PlannedAvlDate>2022-08-31T00:00:00</PlannedAvlDate><UpdatedAvlDate>2022-08-31T00:00:00</UpdatedAvlDate><PurchGroup>F51</PurchGroup><PackDesc>Bags</PackDesc><VirtualPlant>A460</VirtualPlant><Batch><LoadingPort>Mombasa</LoadingPort><DestinationPort>Dubai</DestinationPort><LeadTime>34</LeadTime><BatchId>0KA219768</BatchId><SaleNumber>2</SaleNumber><SaleYear>2020</SaleYear><SalesDate>2022-10-11T00:00:00</SalesDate><TeaType>M</TeaType><BrokerCode>KECOM</BrokerCode><VendorLotNumber>100001</VendorLotNumber><AuctionCenter>KEMB</AuctionCenter><ThirdPartyWHStatus>Open</ThirdPartyWHStatus><AdditionalSupplierReference>SR00001</AdditionalSupplierReference><AirwayBillNumberCode>DHL#3805340954</AirwayBillNumberCode><AWBSampleReceived>Yes</AWBSampleReceived><AWBSampleReference>10001</AWBSampleReference><BasePrice>1.35</BasePrice><BoughtAsReserve>Yes</BoughtAsReserve><BoughtPrice>1.46</BoughtPrice><BrokerWarehouse>KEMITU</BrokerWarehouse><BulkDensity>0</BulkDensity><BuyingOrderNumber>444</BuyingOrderNumber><Channel>Auction</Channel><ContainerNo>MRKU123456</ContainerNo><Currency>USD</Currency><DateOfProductionOfBatch>2022-10-11T00:00:00</DateOfProductionOfBatch><DateTeaAvailableFrom>2022-10-11T00:00:00</DateTeaAvailableFrom><DustContent>Sample</DustContent><EuropeanCompliantFlag>Yes</EuropeanCompliantFlag><EvaluatorsCodeAtTBO>DU987</EvaluatorsCodeAtTBO><EvaluatorsRemarks>Woody taste</EvaluatorsRemarks><ExpirationDateShelfLife>2022-10-11T00:00:00</ExpirationDateShelfLife><FromLocationCode>KE01</FromLocationCode><GrossWt>2112</GrossWt><InitialBuyDate>2022-10-11T00:00:00</InitialBuyDate><WeightPerUnit>51</WeightPerUnit><LandedPrice>1.56</LandedPrice><LeafCategory>FANNINGS</LeafCategory><LeafManufacturingType>CTC</LeafManufacturingType><LeafSize>D</LeafSize><LeafStyle>3</LeafStyle><MixingUnit>RULED</MixingUnit><NumberOfPackagesBought>40</NumberOfPackagesBought><OriginOfTea>UG</OriginOfTea><OriginalTeaLingoItem>DG22UG-R</OriginalTeaLingoItem><PackagesPerPallet>20</PackagesPerPallet><Plant>WU01</Plant><TotalQuantity>2000</TotalQuantity><SampleBoxNo>A528</SampleBoxNo><SellingPrice>1.54</SellingPrice><StockDate>2022-10-11T00:00:00</StockDate><StorageLocation>W019</StorageLocation><SubChannel>Yes</SubChannel><StrategicFlag>Yes</StrategicFlag><SubClusterTeaLingo>G2</SubClusterTeaLingo><SupplierPreInvoiceDate>2022-10-11T00:00:00</SupplierPreInvoiceDate><Sustainability>RA</Sustainability><TasterComments>Woody</TasterComments><TeaAppearance>0</TeaAppearance><TeaBuyingOffice>F51</TeaBuyingOffice><TeaColour>B</TeaColour><TeaGardenChopInvoiceNo>UK521781X</TeaGardenChopInvoiceNo><TeaGardenMark>BUGAMBE</TeaGardenMark><TeaGroup>DG22</TeaGroup><TeaHue>0.6</TeaHue><TeaIntensity>4.4</TeaIntensity><TeaLeafGrade>PF1</TeaLeafGrade><TeaMoisture>0</TeaMoisture><TeaMouthfeel>4.6</TeaMouthfeel><TeaOrganic>Yes</TeaOrganic><TeaTaste>4</TeaTaste><TeaVolume>125</TeaVolume><TeaLingoItem>DG23UG-R</TeaLingoItem><TinNumber>9208</TinNumber><WarehouseArrivalDate>2022-10-11T00:00:00</WarehouseArrivalDate><YearOfManufacture>2020</YearOfManufacture><PackageSize>B</PackageSize><PackageType>B</PackageType><TareWt>0</TareWt><Taster>Roop</Taster><FeedStock>BCFMS</FeedStock><FluorideLimit>0.02</FluorideLimit><LocalAuctionNumber>10001</LocalAuctionNumber><POStatus>Open</POStatus><ProductionSite>Sample</ProductionSite><ReserveMU>RULED</ReserveMU><QualityComments>Good</QualityComments><RareEarth>Sample</RareEarth><TeaLingoVersion>8.2</TeaLingoVersion><FreightAgent>Sample</FreightAgent><SealNo>S123</SealNo><ContainerType>20 FT</ContainerType><Voyage>V123</Voyage><Vessel>Sample</Vessel></Batch></Line></Header></root>' 
		AS strXml
		,'PO-1' AS strInfo1
		,'ERP-PO-123' AS strInfo2
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
