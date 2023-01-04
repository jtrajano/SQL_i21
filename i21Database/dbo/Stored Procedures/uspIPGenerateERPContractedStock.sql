CREATE PROCEDURE dbo.uspIPGenerateERPContractedStock (
	@ysnUpdateFeedStatus BIT = 1
	,@limit INT = 0
	,@offset INT = 0

	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @strXML NVARCHAR(MAX)
		,@strDetailXML NVARCHAR(MAX)
		,@intContractedStockPreStageId INT
		,@dtmCurrentDate DATETIME
		,@ErrMsg   NVARCHAR(MAX)
		,@intTotalRows int

	SELECT @dtmCurrentDate = Convert(CHAR, GETDATE(), 101)

	DECLARE @tblIPContractedStockPreStage TABLE (intContractedStockPreStageId INT)
	DECLARE @tblOutput AS TABLE (
		intRowNo INT IDENTITY(1, 1)
		,intWorkOrderId INT
		,strRowState NVARCHAR(50)
		,strXML NVARCHAR(MAX)
		,strWorkOrderNo NVARCHAR(50)
		,strERPOrderNo NVARCHAR(50)
		)

	IF NOT EXISTS (
			SELECT *
			FROM tblIPContractedStockPreStage
			WHERE dtmProcessedDate = @dtmCurrentDate
			)
	BEGIN
		DELETE
		FROM tblIPContractedStockPreStage

		INSERT INTO tblIPContractedStockPreStage (
			intContractedStockPreStageId
			,intContractDetailId
			,dblBalanceQty
			,intStatusId
			,dtmProcessedDate
			)
		SELECT intContractedStockPreStageId = ROW_NUMBER() OVER (
				ORDER BY CH.intContractHeaderId
				)
			,intContractDetailId = CD.intContractDetailId
			,dblBalanceQty = CD.dblQuantity - IsNULL(B2.dblQuantity, 0)
			,intStatusId = NULL
			,dtmProcessedDate = @dtmCurrentDate
		FROM tblCTContractDetail CD
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		OUTER APPLY (
			SELECT Sum(B.dblTotalQuantity*B.dblWeightPerUnit ) dblQuantity
			FROM tblMFBatch B
			WHERE B.intContractDetailId = CD.intContractDetailId
			) B2
		WHERE CD.intContractStatusId = 1 --Open
		AND CD.dblQuantity - IsNULL(B2.dblQuantity, 0)>0
		ORDER BY CH.intContractHeaderId

		Select @intContractedStockPreStageId=MAX(intContractedStockPreStageId) from tblIPContractedStockPreStage

		INSERT INTO tblIPContractedStockPreStage (
			intContractedStockPreStageId
			,intBatchId
			,intStatusId
			,dtmProcessedDate
			)
		SELECT intContractedStockPreStageId = IsNULL(@intContractedStockPreStageId,0)+ROW_NUMBER() OVER (
				ORDER BY B.intBatchId
				)
			,intBatchId=B.intBatchId 
			,intStatusId = NULL
			,dtmProcessedDate = @dtmCurrentDate
		FROM dbo.tblMFBatch B
		WHERE NOT EXISTS(SELECT *FROM dbo.tblLGLoadDetail LD WHERE LD.intBatchId=B.intBatchId )
		AND B.intLocationId<>B.intMixingUnitLocationId
		ORDER BY B.intBatchId 	
		END

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblIPContractedStockPreStage
			WHERE intStatusId IS NULL
				AND intContractedStockPreStageId BETWEEN @offset + 1
					AND @limit + @offset
			)
	BEGIN
		RETURN
	END

	DECLARE @tmp INT

	SELECT @tmp = strValue
	FROM tblIPSAPIDOCTag
	WHERE strMessageType = 'Contracted Stock'
		AND strTag = 'Count'

	IF ISNULL(@tmp, 0) = 0
		SELECT @tmp = 100

	IF @limit > @tmp
	BEGIN
		SELECT @limit = @tmp
	END

	INSERT INTO @tblIPContractedStockPreStage (intContractedStockPreStageId)
	SELECT PS.intContractedStockPreStageId
	FROM dbo.tblIPContractedStockPreStage PS
	WHERE intStatusId IS NULL
		AND intContractedStockPreStageId BETWEEN @offset + 1
					AND @limit + @offset

	UPDATE dbo.tblIPContractedStockPreStage
	SET intStatusId = - 1
	WHERE intContractedStockPreStageId IN (
			SELECT PS.intContractedStockPreStageId
			FROM @tblIPContractedStockPreStage PS
			)

	Select @intTotalRows=Count(*)
	from tblIPContractedStockPreStage

	Select @strXML= '<root><DocNo>' + IsNULL(ltrim(MIN(CS.intContractedStockPreStageId)), '') + '</DocNo>'
	+ '<MsgType>Contracted_Stock</MsgType>' 
	+ '<Sender>iRely</Sender>' 
	+ '<Receiver>ICRON</Receiver>' 
	+ '<TotalRows>'+IsNULL(ltrim(@intTotalRows),'')+'</TotalRows>'
	FROM @tblIPContractedStockPreStage CS

	SELECT @strDetailXML = IsNULL(@strDetailXML,'') 
	+ '<Header><StockCode></StockCode>' 
	+ '<BatchNumber>' + Case When B.strBatchId is not null Then B.strBatchId Else CH.strContractNumber + '/' + ltrim(CD.intContractSeq) End + '</BatchNumber>' 
	+ '<Plant>' + IsNULL(ltrim(MU.strVendorRefNoPrefix),'')  + '</Plant>' 
	+ '<ItemCode>' + I.strItemNo + '</ItemCode>' 
	+ '<StockDate>' + IsNULL(CONVERT(VARCHAR(33), CD.dtmUpdatedAvailabilityDate, 126),'') + '</StockDate>' 
	+ '<Quantity>' + [dbo].[fnRemoveTrailingZeroes](CD.dblQuantity) + '</Quantity>' 
	+ '<MixingUnit>' + IsNULL(ltrim(MU.strLocationName) , '') + '</MixingUnit>' 
	+ '<Taste>' + IsNULL([dbo].[fnRemoveTrailingZeroes](B.dblTeaTaste),'') + '</Taste>' 
	+ '<Hue>' + IsNULL([dbo].[fnRemoveTrailingZeroes](B.dblTeaHue),'') + '</Hue>' 
	+ '<Intensity>' + IsNULL([dbo].[fnRemoveTrailingZeroes](B.dblTeaIntensity),'') + '</Intensity>' 
	+ '<MouthFeel>' + IsNULL([dbo].[fnRemoveTrailingZeroes](B.dblTeaMouthFeel),'') + '</MouthFeel>'
	+ '<ContainerNo></ContainerNo>' 
	+ '<FromLocationCode>' + IsNULL(C1.strCity, '') + '</FromLocationCode>' 
	+ '<PONumber>' +  Case When B.strBatchId is not null Then B.strBatchId Else CH.strContractNumber + '/' + ltrim(CD.intContractSeq) End + '</PONumber>' 
	+ '<POStatus></POStatus>' 
	+ '<ShippingDate>' + IsNULL(CONVERT(VARCHAR(33), CD.dtmStartDate, 126),'') + '</ShippingDate>' 
	+ '<UnitCost>' +  IsNULL([dbo].[fnRemoveTrailingZeroes](CD.dblCashPrice),'') + '</UnitCost>' 
	+ '<Vessel></Vessel>' 
	+ '<StockType>'+(Case When B.intMarketZoneId =1 Then 'A'When B.intMarketZoneId =4 Then 'C'When B.intMarketZoneId =7 Then 'C1'When B.intMarketZoneId =3 Then 'C2'When B.intMarketZoneId =8 Then 'SPT' Else 'Others'End)+'</StockType>' 
	+ '<Channel>' + IsNULL(MZ.strMarketZoneCode, '') + '</Channel>' 
	+ '<StorageLocation>' + IsNULL(LTRIM(SUBSTRING(ISNULL(MUSL.strSubLocationName, ''), CHARINDEX('/', MUSL.strSubLocationName) + 1, LEN(MUSL.strSubLocationName))) , '') + '</StorageLocation>' 
	+ '<Size>' + IsNULL(B.strLeafSize, '') + '</Size>' 
	+ '<Volume>' + IsNULL([dbo].[fnRemoveTrailingZeroes](B.dblTeaVolume), '') + '</Volume>' 
	+ '<Appearance>' + IsNULL([dbo].[fnRemoveTrailingZeroes](B.dblTeaAppearance), '') + '</Appearance>' 
	+ '<ExpiryDate>' + IsNULL(CONVERT(VARCHAR(33), DateAdd(mm, I.intLifeTime, B.dtmProductionBatch), 126),'') + '</ExpiryDate>' 
	+ '<NoOfBags>' + IsNULL([dbo].[fnRemoveTrailingZeroes](CS1.dblBalanceQty) ,'') + '</NoOfBags>' 
	+ '<UnitWeight>' + IsNULL([dbo].[fnRemoveTrailingZeroes](CS1.dblBalanceQty*IU.dblUnitQty),'') + '</UnitWeight>' 
	+ '<NoOfBagsPerPallet>' + IsNULL(ltrim(I.intUnitPerLayer * I.intLayerPerPallet), '') + '</NoOfBagsPerPallet>' 
	+ '<ReceiptDate></ReceiptDate>' 
	+ '<BuyingOrderNo>' + IsNULL(B.strBuyingOrderNumber, '') + '</BuyingOrderNo>' 
	+ '<StrategicFlag>' + IsNULL(ltrim(SB.strSubBook ), '') + '</StrategicFlag>' 
	+ '<Origin>' + IsNULL(Country.strISOCode, '') + '</Origin>' 
	+ '<IncoTerms>' + IsNULL(FT.strFreightTerm, '') + '</IncoTerms>' 
	+ '<IncoTermsDesc>' + IsNULL(FT.strDescription, '') + '</IncoTermsDesc>' 
	+ '<Currency>' + IsNULL(C.strCurrency, '') + '</Currency>' 
	+ '<MaterialCode>' + IsNULL(I.strShortName, '') + '</MaterialCode>' 
	+ '<ReservedMixingUnit>'+IsNULL(B.strReserveMU, '')+'</ReservedMixingUnit>' 
	+ '<SAPSystem>iRely</SAPSystem>' 
	+ '<InvoiceNo>' + IsNULL(B.strTeaGardenChopInvoiceNumber, '') + '</InvoiceNo>' 
	+ '<Garden>' + IsNULL(GM.strGardenMark, '') + '</Garden>'
	+ '<Grade>' + IsNULL(B.strLeafGrade, '') + '</Grade>' 
	+ '<ItemCodeOriginal>' + IsNULL(OI.strItemNo , '') + '</ItemCodeOriginal>' 
	+ '<SaleYear>' + IsNULL(ltrim(B.intSalesYear), '') + '</SaleYear>' 
	+ '<SaleNumber>' + IsNULL(ltrim(B.intSales), '') + '</SaleNumber>' 
	+ '<BrokerCode>' + IsNULL(BK.strName, '') + '</BrokerCode>' 
	+ '<AuctionCenter>' + IsNULL(SM.strLocationName , '') + '</AuctionCenter>' 
	+ '<BoughtPrice>' + IsNULL([dbo].[fnRemoveTrailingZeroes](CD.dblCashPrice), '') + '</BoughtPrice>' 
	+ '<LandedPrice>' + IsNULL([dbo].[fnRemoveTrailingZeroes](B.dblLandedPrice), '') + '</LandedPrice>' 
	+ '<TinNo>' + IsNULL(T.strTINNumber , '') + '</TinNo>' 
	+ '<TBO>' + IsNULL(SM.strLocationNumber, '') + '</TBO>' 
	+ '<AvailableFrom>' + IsNULL(CONVERT(VARCHAR(33), B.dtmTeaAvailableFrom, 126),'') + '</AvailableFrom>' 
	+ '<TeaType>' + IsNULL(B.strTeaType, '') + '</TeaType>' 
	+ '<SaleDate>' + IsNULL(CONVERT(VARCHAR (33), B.dtmSalesDate , 126),'') + '</SaleDate>' 
	+ '<InitialBuyDate>' + IsNULL(CONVERT(VARCHAR(33), B.dtmInitialBuy, 126),'') + '</InitialBuyDate>' 
	+ '<BulkDensity>' + IsNULL(ltrim(B.dblBulkDensity), '') + '</BulkDensity>' 
	+ '<BasePrice>' + IsNULL([dbo].[fnRemoveTrailingZeroes](CD.dblCashPrice), '') + '</BasePrice></Header>'
	FROM @tblIPContractedStockPreStage CS
	JOIN tblIPContractedStockPreStage CS1 on CS1.intContractedStockPreStageId =CS.intContractedStockPreStageId 
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = CS1.intContractDetailId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblICItem I ON I.intItemId = CD.intItemId
	Left JOIN tblICCommodityAttribute CA on CA.intCommodityAttributeId =I.intOriginId 
	Left JOIN tblSMCountry Country on Country.intCountryID =CA.intCountryID 
	JOIN tblICItemUOM IU ON IU.intItemUOMId  = CD.intItemUOMId 
	Left JOIN tblCTSubBook SB ON SB.intSubBookId = CD.intSubBookId
	JOIN tblSMCurrency C ON C.intCurrencyID = CD.intCurrencyId
	LEFT JOIN tblSMCity C1 ON C1.intCityId = CD.intLoadingPortId
	LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = CD.intFreightTermId
	LEFT JOIN tblMFBatch B ON B.intContractDetailId = CD.intContractDetailId --It should be based on PO
	LEFT JOIN tblEMEntity BK ON BK.intEntityId = B.intBrokerId
	LEFT JOIN tblSMCompanyLocation SM ON SM.intCompanyLocationId = B.intBuyingCenterLocationId
	LEFT JOIN tblSMCompanyLocation MU ON MU.intCompanyLocationId = B.intMixingUnitLocationId  
	LEFT JOIN tblSMCompanyLocationSubLocation  MUSL ON MUSL.intCompanyLocationSubLocationId  = CD.intSubLocationId 
	LEFT JOIN tblQMGardenMark  GM ON GM.intGardenMarkId = B.intGardenMarkId  
	LEFT JOIN tblICItem OI on OI.intItemId=B.intOriginalItemId
	LEFT JOIN tblQMTINClearance T on T.intBatchId =B.intBatchId 
	Left JOIN tblARMarketZone MZ on MZ.intMarketZoneId =CD.intMarketZoneId
	Where B.intLocationId<>B.intMixingUnitLocationId  
	
SELECT @strDetailXML = IsNULL(@strDetailXML,'') 
	+ '<Header><StockCode></StockCode>' 
	+ '<BatchNumber>' + IsNULL(B.strBatchId,'') + '</BatchNumber>' 
	+ '<Plant>' + IsNULL(ltrim(MU.strVendorRefNoPrefix),'')  + '</Plant>' 
	+ '<ItemCode>' + IsNULL(I.strItemNo,'') + '</ItemCode>' 
	+ '<StockDate>' + IsNULL(IsNULL(CONVERT(VARCHAR(33), CD.dtmUpdatedAvailabilityDate, 126),CONVERT(VARCHAR(33), B.dtmStock , 126)),'') + '</StockDate>' 
	+ '<Quantity>' + IsNULL([dbo].[fnRemoveTrailingZeroes](B.dblTotalQuantity),'') + '</Quantity>' 
	+ '<MixingUnit>' + IsNULL(ltrim(MU.strLocationName) , '') + '</MixingUnit>' 
	+ '<Taste>' + IsNULL([dbo].[fnRemoveTrailingZeroes](B.dblTeaTaste),'') + '</Taste>' 
	+ '<Hue>' + IsNULL([dbo].[fnRemoveTrailingZeroes](B.dblTeaHue),'') + '</Hue>' 
	+ '<Intensity>' + IsNULL([dbo].[fnRemoveTrailingZeroes](B.dblTeaIntensity),'') + '</Intensity>' 
	+ '<MouthFeel>' + IsNULL([dbo].[fnRemoveTrailingZeroes](B.dblTeaMouthFeel),'') + '</MouthFeel>'
	+ '<ContainerNo></ContainerNo>' 
	+ '<FromLocationCode>' + IsNULL(C1.strCity, '') + '</FromLocationCode>' 
	+ '<PONumber>' +  IsNULL(B.strBatchId, '') + '</PONumber>' 
	+ '<POStatus></POStatus>' 
	+ '<ShippingDate>' + IsNULL(IsNULL(CONVERT(VARCHAR(33), CD.dtmUpdatedAvailabilityDate, 126),CONVERT(VARCHAR(33), B.dtmStock, 126)),'') + '</ShippingDate>' 
	+ '<UnitCost>' +  IsNULL(IsNULL([dbo].[fnRemoveTrailingZeroes](CD.dblCashPrice),[dbo].[fnRemoveTrailingZeroes](B.dblBoughtPrice)),'') + '</UnitCost>' 
	+ '<Vessel></Vessel>' 
	+ '<StockType>'+(Case When B.intMarketZoneId =1 Then 'A'When B.intMarketZoneId =4 Then 'C'When B.intMarketZoneId =7 Then 'C1'When B.intMarketZoneId =3 Then 'C2'When B.intMarketZoneId =8 Then 'SPT' Else 'Others'End)+'</StockType>' 
	+ '<Channel>' + IsNULL(MZ.strMarketZoneCode, '') + '</Channel>' 
	+ '<StorageLocation></StorageLocation>' 
	+ '<Size>' + IsNULL(B.strLeafSize, '') + '</Size>' 
	+ '<Volume>' + IsNULL([dbo].[fnRemoveTrailingZeroes](B.dblTeaVolume), '') + '</Volume>' 
	+ '<Appearance>' + IsNULL([dbo].[fnRemoveTrailingZeroes](B.dblTeaAppearance), '') + '</Appearance>' 
	+ '<ExpiryDate>' + IsNULL(CONVERT(VARCHAR(33), DateAdd(mm, I.intLifeTime, B.dtmProductionBatch), 126),'') + '</ExpiryDate>' 
	+ '<NoOfBags>' + IsNULL([dbo].[fnRemoveTrailingZeroes](B.dblTotalQuantity ) ,'') + '</NoOfBags>' 
	+ '<UnitWeight>' + IsNULL([dbo].[fnRemoveTrailingZeroes](B.dblTotalQuantity *B.dblWeightPerUnit ),'') + '</UnitWeight>' 
	+ '<NoOfBagsPerPallet>' + IsNULL(ltrim(I.intUnitPerLayer * I.intLayerPerPallet), '') + '</NoOfBagsPerPallet>' 
	+ '<ReceiptDate></ReceiptDate>' 
	+ '<BuyingOrderNo>' + IsNULL(B.strBuyingOrderNumber, '') + '</BuyingOrderNo>' 
	+ '<StrategicFlag>' + IsNULL(ltrim(SB.strSubBook ), '') + '</StrategicFlag>' 
	+ '<Origin>' + IsNULL(Country.strISOCode, '') + '</Origin>' 
	+ '<IncoTerms></IncoTerms>' 
	+ '<IncoTermsDesc></IncoTermsDesc>' 
	+ '<Currency>' + IsNULL(C.strCurrency, '') + '</Currency>' 
	+ '<MaterialCode>' + IsNULL(I.strShortName, '') + '</MaterialCode>' 
	+ '<ReservedMixingUnit>'+IsNULL(B.strReserveMU, '')+'</ReservedMixingUnit>' 
	+ '<SAPSystem>iRely</SAPSystem>' 
	+ '<InvoiceNo>' + IsNULL(B.strTeaGardenChopInvoiceNumber, '') + '</InvoiceNo>' 
	+ '<Garden>' + IsNULL(GM.strGardenMark, '') + '</Garden>'
	+ '<Grade>' + IsNULL(B.strLeafGrade, '') + '</Grade>' 
	+ '<ItemCodeOriginal>' + IsNULL(OI.strItemNo , '') + '</ItemCodeOriginal>' 
	+ '<SaleYear>' + IsNULL(ltrim(B.intSalesYear), '') + '</SaleYear>' 
	+ '<SaleNumber>' + IsNULL(ltrim(B.intSales), '') + '</SaleNumber>' 
	+ '<BrokerCode>' + IsNULL(BK.strName, '') + '</BrokerCode>' 
	+ '<AuctionCenter>' + IsNULL(SM.strLocationName , '') + '</AuctionCenter>' 
	+ '<BoughtPrice>' + IsNULL(IsNULL([dbo].[fnRemoveTrailingZeroes](CD.dblCashPrice),[dbo].[fnRemoveTrailingZeroes](B.dblBoughtPrice)),'') + '</BoughtPrice>' 
	+ '<LandedPrice>' + IsNULL([dbo].[fnRemoveTrailingZeroes](B.dblLandedPrice), '') + '</LandedPrice>' 
	+ '<TinNo>' + IsNULL(T.strTINNumber , '') + '</TinNo>' 
	+ '<TBO>' + IsNULL(SM.strLocationNumber, '') + '</TBO>' 
	+ '<AvailableFrom>' + IsNULL(CONVERT(VARCHAR(33), B.dtmTeaAvailableFrom, 126),'') + '</AvailableFrom>' 
	+ '<TeaType>' + IsNULL(B.strTeaType, '') + '</TeaType>' 
	+ '<SaleDate>' + IsNULL(CONVERT(VARCHAR (33), B.dtmSalesDate , 126),'') + '</SaleDate>' 
	+ '<InitialBuyDate>' + IsNULL(CONVERT(VARCHAR(33), B.dtmInitialBuy, 126),'') + '</InitialBuyDate>' 
	+ '<BulkDensity>' + IsNULL(ltrim(B.dblBulkDensity), '') + '</BulkDensity>' 
	+ '<BasePrice>' + IsNULL(IsNULL([dbo].[fnRemoveTrailingZeroes](CD.dblCashPrice),[dbo].[fnRemoveTrailingZeroes](B.dblBasePrice )),'') + '</BasePrice></Header>'
	FROM @tblIPContractedStockPreStage CS
	JOIN tblIPContractedStockPreStage CS1 on CS1.intContractedStockPreStageId =CS.intContractedStockPreStageId 
	JOIN tblMFBatch B ON B.intBatchId = CS1.intBatchId 
	Left JOIN tblCTContractDetail CD ON CD.intContractDetailId = B.intContractDetailId
	JOIN tblICItem I ON I.intItemId = B.intTealingoItemId 
	Left JOIN tblICCommodityAttribute CA on CA.intCommodityAttributeId =I.intOriginId 
	Left JOIN tblSMCountry Country on Country.intCountryID =CA.intCountryID 
	Left JOIN tblCTSubBook SB ON SB.intSubBookId = B.intSubBookId
	Left JOIN tblSMCurrency C ON C.intCurrencyID = B.intCurrencyId
	LEFT JOIN tblSMCity C1 ON C1.intCityId = B.intFromPortId
	LEFT JOIN tblEMEntity BK ON BK.intEntityId = B.intBrokerId
	LEFT JOIN tblSMCompanyLocation SM ON SM.intCompanyLocationId = B.intBuyingCenterLocationId
	LEFT JOIN tblSMCompanyLocation MU ON MU.intCompanyLocationId = B.intMixingUnitLocationId  
	LEFT JOIN tblQMGardenMark  GM ON GM.intGardenMarkId = B.intGardenMarkId  
	LEFT JOIN tblICItem OI on OI.intItemId=B.intOriginalItemId
	LEFT JOIN tblQMTINClearance T on T.intBatchId =B.intBatchId 
	Left JOIN tblARMarketZone MZ on MZ.intMarketZoneId =B.intMarketZoneId
	Where B.intLocationId<>B.intMixingUnitLocationId  

	UPDATE dbo.tblIPContractedStockPreStage
	SET intStatusId = NULL
	WHERE intContractedStockPreStageId IN (
			SELECT PS.intContractedStockPreStageId
			FROM @tblIPContractedStockPreStage PS
			)
		AND intStatusId = - 1

	IF LEN(@strDetailXML)>0
	BEGIN
		SELECT @strXML=@strXML+@strDetailXML+'</root>'

		SELECT IsNULL(1, '0') AS id
			,IsNULL(@strXML, '') AS strXml
			,'' AS strInfo1
			,'' AS strInfo2
			,'' AS strOnFailureCallbackSql
	END
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