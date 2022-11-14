CREATE PROCEDURE dbo.uspIPGenerateSAPPO (@ysnUpdateFeedStatus BIT = 1)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)



	SELECT '0' AS id
		,'<root><DocNo>930</DocNo><MsgType>Purchase_Order</MsgType><Sender>iRely</Sender><Receiver>SAP</Receiver><Header><RefNo>LS-1</RefNo><VendorAccountNo>IR0000001</VendorAccountNo><Location>KEMB</Location><HeaderRowState>U</HeaderRowState><Commodity>Tea</Commodity><Line><TrackingNo>100</TrackingNo><RowState>U</RowState><ERPContractNo>ERP1001</ERPContractNo><ContractNo>P100</ContractNo><SequenceNo>1</SequenceNo><PONumber>ERPPO1001</PONumber><POLineItemNo>10</POLineItemNo><ItemNo>DE13KE-R</ItemNo><Quantity>10</Quantity><QuantityUOM>500 Kg Bags</QuantityUOM><NetWeight>5000</NetWeight><NetWeightUOM>KG</NetWeightUOM><PriceType>Cash</PriceType><Price>2.5</Price><PriceUOM>500 Kg Bags</PriceUOM><PriceCurrency>USD</PriceCurrency><StartDate>2022-08-01T00:00:00</StartDate><EndDate>2022-08-31T00:00:00</EndDate><PlannedAvlDate>2022-08-31T00:00:00</PlannedAvlDate><UpdatedAvlDate>2022-08-31T00:00:00</UpdatedAvlDate><PurchGroup>F51</PurchGroup><PackDesc>Bags</PackDesc><VirtualPlant>A460</VirtualPlant><Batch><LoadingPort>Mombasa</LoadingPort><DestinationPort>Dubai</DestinationPort><LeadTime>34</LeadTime><BatchId>0KA219768</BatchId><SaleNumber>2</SaleNumber><SaleYear>2020</SaleYear><SalesDate>2022-10-11T00:00:00</SalesDate><TeaType>M</TeaType><BrokerCode>KECOM</BrokerCode><VendorLotNumber>100001</VendorLotNumber><AuctionCenter>KEMB</AuctionCenter><ThirdPartyWHStatus>Open</ThirdPartyWHStatus><AdditionalSupplierReference>SR00001</AdditionalSupplierReference><AirwayBillNumberCode>DHL#3805340954</AirwayBillNumberCode><AWBSampleReceived>Yes</AWBSampleReceived><AWBSampleReference>10001</AWBSampleReference><BasePrice>1.35</BasePrice><BoughtAsReserve>Yes</BoughtAsReserve><BoughtPrice>1.46</BoughtPrice><BrokerWarehouse>KEMITU</BrokerWarehouse><BulkDensity>0</BulkDensity><BuyingOrderNumber>444</BuyingOrderNumber><Channel>Auction</Channel><ContainerNo>MRKU123456</ContainerNo><Currency>USD</Currency><DateOfProductionOfBatch>2022-10-11T00:00:00</DateOfProductionOfBatch><DateTeaAvailableFrom>2022-10-11T00:00:00</DateTeaAvailableFrom><DustContent>Sample</DustContent><EuropeanCompliantFlag>Yes</EuropeanCompliantFlag><EvaluatorsCodeAtTBO>DU987</EvaluatorsCodeAtTBO><EvaluatorsRemarks>Woody taste</EvaluatorsRemarks><ExpirationDateShelfLife>2022-10-11T00:00:00</ExpirationDateShelfLife><FromLocationCode>KE01</FromLocationCode><GrossWt>2112</GrossWt><InitialBuyDate>2022-10-11T00:00:00</InitialBuyDate><WeightPerUnit>51</WeightPerUnit><LandedPrice>1.56</LandedPrice><LeafCategory>FANNINGS</LeafCategory><LeafManufacturingType>CTC</LeafManufacturingType><LeafSize>D</LeafSize><LeafStyle>3</LeafStyle><MixingUnit>RULED</MixingUnit><NumberOfPackagesBought>40</NumberOfPackagesBought><OriginOfTea>UG</OriginOfTea><OriginalTeaLingoItem>DG22UG-R</OriginalTeaLingoItem><PackagesPerPallet>20</PackagesPerPallet><Plant>WU01</Plant><TotalQuantity>2000</TotalQuantity><SampleBoxNo>A528</SampleBoxNo><SellingPrice>1.54</SellingPrice><StockDate>2022-10-11T00:00:00</StockDate><StorageLocation>W019</StorageLocation><SubChannel>Yes</SubChannel><StrategicFlag>Yes</StrategicFlag><SubClusterTeaLingo>G2</SubClusterTeaLingo><SupplierPreInvoiceDate>2022-10-11T00:00:00</SupplierPreInvoiceDate><Sustainability>RA</Sustainability><TasterComments>Woody</TasterComments><TeaAppearance>0</TeaAppearance><TeaBuyingOffice>F51</TeaBuyingOffice><TeaColour>B</TeaColour><TeaGardenChopInvoiceNo>UK521781X</TeaGardenChopInvoiceNo><TeaGardenMark>BUGAMBE</TeaGardenMark><TeaGroup>DG22</TeaGroup><TeaHue>0.6</TeaHue><TeaIntensity>4.4</TeaIntensity><TeaLeafGrade>PF1</TeaLeafGrade><TeaMoisture>0</TeaMoisture><TeaMouthfeel>4.6</TeaMouthfeel><TeaOrganic>Yes</TeaOrganic><TeaTaste>4</TeaTaste><TeaVolume>125</TeaVolume><TeaLingoItem>DG23UG-R</TeaLingoItem><TinNumber>9208</TinNumber><WarehouseArrivalDate>2022-10-11T00:00:00</WarehouseArrivalDate><YearOfManufacture>2020</YearOfManufacture><PackageSize>B</PackageSize><PackageType>B</PackageType><TareWt>0</TareWt><Taster>Roop</Taster><FeedStock>BCFMS</FeedStock><FluorideLimit>0.02</FluorideLimit><LocalAuctionNumber>10001</LocalAuctionNumber><POStatus>Open</POStatus><ProductionSite>Sample</ProductionSite><ReserveMU>RULED</ReserveMU><QualityComments>Good</QualityComments><RareEarth>Sample</RareEarth><TeaLingoVersion>8.2</TeaLingoVersion><FreightAgent>Sample</FreightAgent><SealNo>S123</SealNo><ContainerType>20 FT</ContainerType><Voyage>V123</Voyage><Vessel>Sample</Vessel></Batch></Line></Header></root>' AS strXml
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
