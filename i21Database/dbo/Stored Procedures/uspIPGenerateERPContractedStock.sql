﻿CREATE PROCEDURE dbo.uspIPGenerateERPContractedStock (
	@intPageNumber INT = 1
	,@intPageSize INT = 50
	,@ysnUpdateFeedStatus BIT = 1
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @strXML NVARCHAR(MAX)
		,@intContractedStockPreStageId INT
		,@dtmCurrentDate DATETIME
		,@ErrMsg   NVARCHAR(MAX)

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
				ORDER BY (
						SELECT NULL
						)
				)
			,intContractDetailId = CD.intContractDetailId
			,dblBalanceQty = CD.dblQuantity - IsNULL(LD2.dblQuantity, 0)
			,intStatusId = NULL
			,dtmProcessedDate = @dtmCurrentDate
		FROM tblCTContractDetail CD
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		OUTER APPLY (
			SELECT Sum(dblQuantity) dblQuantity
			FROM tblLGLoadDetail LD
			WHERE LD.intPContractDetailId = CD.intContractDetailId
			) LD2
		WHERE CD.intContractStatusId = 1 --Open
	END

	IF NOT EXISTS (
			SELECT *
			FROM dbo.tblIPContractedStockPreStage
			WHERE intStatusId IS NULL
				AND intContractedStockPreStageId BETWEEN (@intPageNumber - 1) * @intPageSize + 1
					AND @intPageNumber * @intPageSize
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
		SELECT @tmp = 50

	IF @intPageSize > @tmp
	BEGIN
		SELECT @intPageSize = @tmp
	END

	INSERT INTO @tblIPContractedStockPreStage (intContractedStockPreStageId)
	SELECT PS.intContractedStockPreStageId
	FROM dbo.tblIPContractedStockPreStage PS
	WHERE intStatusId IS NULL
		AND intContractedStockPreStageId BETWEEN (@intPageNumber - 1) * @intPageSize + 1
			AND @intPageNumber * @intPageSize

	UPDATE dbo.tblIPContractedStockPreStage
	SET intStatusId = - 1
	WHERE intContractedStockPreStageId IN (
			SELECT PS.intContractedStockPreStageId
			FROM @tblIPContractedStockPreStage PS
			)

	SELECT @strXML = @strXML + '<DocNo>' + ltrim(IsNULL(CS.intContractedStockPreStageId, '')) + '</DocNo>'
	+ '<MsgType>Contracted_Stock</MsgType>' 
	+ '<Sender>iRely</Sender>' 
	+ '<Receiver>ICRON</Receiver>' 
	+ '<StockCode></StockCode>' 
	+ '<BatchNumber>' + Case When B.strBatchId is not null Then B.strBatchId Else CH.strContractNumber + '/' + ltrim(CD.intContractSeq) End + '</BatchNumber>' 
	+ '<Plant>' + ltrim(MU.strLocationNumber)  + '</Plant>' 
	+ '<ItemCode>' + I.strItemNo + '</ItemCode>' 
	+ '<StockDate>' + CONVERT(VARCHAR(33), CD.dtmUpdatedAvailabilityDate, 126) + '</StockDate>' 
	+ '<Quantity>' + ltrim(CD.dblQuantity) + '</Quantity>' 
	+ '<MixingUnit>' + IsNULL(MU.strLocationName , '') + '</MixingUnit>' 
	+ '<Taste>' + ltrim(IsNULL(B.dblTeaTaste,'')) + '</Taste>' 
	+ '<Hue>' + ltrim(IsNULL(B.dblTeaHue,'')) + '</Hue>' 
	+ '<Intensity>' + ltrim(IsNULL(B.dblTeaIntensity,'')) + '</Intensity>' 
	+ '<MouthFeel>' + ltrim(IsNULL(B.dblTeaMouthFeel,'')) + '</MouthFeel>'
	+ '<ContainerNo></ContainerNo>' 
	+ '<FromLocationCode>' + IsNULL(C1.strCity, '') + '</FromLocationCode>' 
	+ '<PONumber>' +  Case When B.strBatchId is not null Then B.strBatchId Else CH.strContractNumber + '/' + ltrim(CD.intContractSeq) End + '</PONumber>' 
	+ '<POStatus></POStatus>' 
	+ '<ShippingDate>' + CONVERT(VARCHAR(33), CD.dtmStartDate, 126) + '</ShippingDate>' 
	+ '<UnitCost>' +  ltrim(CD.dblCashPrice) + '</UnitCost>' 
	+ '<Vessel></Vessel>' 
	+ '<StockType>C</StockType>' 
	+ '<Channel>' + IsNULL(SB.strSubBook, '') + '</Channel>' 
	+ '<StorageLocation>' + IsNULL(MUSL.strSubLocationName , '') + '</StorageLocation>' 
	+ '<Size>' + IsNULL(B.strLeafSize, '') + '</Size>' 
	+ '<Volume>' + ltrim(IsNULL(B.dblTeaVolume, '')) + '</Volume>' 
	+ '<Appearance>' + ltrim(IsNULL(B.dblTeaAppearance, '')) + '</Appearance>' 
	+ '<ExpiryDate>' + CONVERT(VARCHAR(33), DateAdd(mm, I.intLifeTime, B.dtmProductionBatch), 126) + '</ExpiryDate>' 
	+ '<NoOfBags>' + ltrim(CS1.dblBalanceQty ) + '</NoOfBags>' 
	+ '<UnitWeight>' + ltrim(CS1.dblBalanceQty*IU.dblUnitQty) + '</UnitWeight>' 
	+ '<NoOfBagsPerPallet>' + ltrim(IsNULL(I.intUnitPerLayer * I.intLayerPerPallet, '')) + '</NoOfBagsPerPallet>' 
	+ '<ReceiptDate></ReceiptDate>' 
	+ '<BuyingOrderNo>' + IsNULL(B.strBuyingOrderNumber, '') + '</BuyingOrderNo>' 
	+ '<StrategicFlag>' + ltrim(IsNULL(B.ysnStrategic, '')) + '</StrategicFlag>' 
	+ '<Origin>' + IsNULL(B.strTeaOrigin, '') + '</Origin>' 
	+ '<IncoTerms>' + IsNULL(FT.strFreightTerm, '') + '</IncoTerms>' 
	+ '<IncoTermsDesc>' + IsNULL(FT.strDescription, '') + '</IncoTermsDesc>' 
	+ '<Currency>' + IsNULL(C.strCurrency, '') + '</Currency>' 
	+ '<MaterialCode>' + IsNULL(I.strShortName, '') + '</MaterialCode>' 
	+ '<ReservedMixingUnit>'+IsNULL(B.strReserveMU, '')+'</ReservedMixingUnit>' 
	+ '<SAPSystem></SAPSystem>' 
	+ '<InvoiceNo>' + IsNULL(B.strTeaGardenChopInvoiceNumber, '') + '</InvoiceNo>' 
	+ '<Garden>' + IsNULL(GM.strGardenMark, '') + '</Garden>'
	+ '<Grade>' + IsNULL(B.strLeafGrade, '') + '</Grade>' 
	+ '<ItemCodeOriginal>' + IsNULL(OI.strItemNo , '') + '</ItemCodeOriginal>' 
	+ '<SaleYear>' + Ltrim(IsNULL(B.intSalesYear, '')) + '</SaleYear>' 
	+ '<SaleNumber>' + ltrim(IsNULL(B.intSales, '')) + '</SaleNumber>' 
	+ '<BrokerCode>' + IsNULL(BK.strName, '') + '</BrokerCode>' 
	+ '<AuctionCenter>' + IsNULL(SM.strLocationName, '') + '</AuctionCenter>' 
	+ '<BoughtPrice>' + Ltrim(IsNULL(B.ysnBoughtPrice, '')) + '</BoughtPrice>' 
	+ '<LandedPrice>' + ltrim(IsNULL(B.dblLandedPrice, '')) + '</LandedPrice>' 
	+ '<TinNo>' + IsNULL(T.strTINNumber , '') + '</TinNo>' 
	+ '<TBO>' + IsNULL(SM.strLocationName, '') + '</TBO>' 
	+ '<AvailableFrom>' + CONVERT(VARCHAR(33), B.dtmTeaAvailableFrom, 126) + '</AvailableFrom>' 
	+ '<TeaType>' + IsNULL(B.strTeaType, '') + '</TeaType>' 
	+ '<SaleDate>' + CONVERT(VARCHAR (33), B.dtmSalesDate , 126) + '</SaleDate>' 
	+ '<InitialBuyDate>' + CONVERT(VARCHAR(33), B.dtmInitialBuy, 126) + '</InitialBuyDate>' 
	+ '<BulkDensity>' + ltrim(IsNULL(B.dblBulkDensity, '')) + '</BulkDensity>' 
	+ '<BasePrice>' + ltrim(IsNULL(B.dblBasePrice, '')) + '</BasePrice>'
	FROM @tblIPContractedStockPreStage CS
	JOIN tblIPContractedStockPreStage CS1 on CS1.intContractedStockPreStageId =CS.intContractedStockPreStageId 
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = CS1.intContractDetailId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblICItem I ON I.intItemId = CD.intItemId
	JOIN tblICItemUOM IU ON IU.intItemId  = CD.intItemId and IU.ysnStockUnit =1
	JOIN tblCTSubBook SB ON SB.intSubBookId = CD.intSubBookId
	JOIN tblSMCurrency C ON C.intCurrencyID = CD.intCurrencyId
	LEFT JOIN tblSMCity C1 ON C1.intCityId = CD.intLoadingPortId
	LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = CD.intFreightTermId
	JOIN tblMFBatch B ON B.intContractDetailId = CD.intContractDetailId --It should be based on PO
	JOIN tblEMEntity BK ON BK.intEntityId = B.intBrokerId
	JOIN tblSMCompanyLocation SM ON SM.intCompanyLocationId = B.intBuyingCenterLocationId
	JOIN tblSMCompanyLocation MU ON MU.intCompanyLocationId = CD.intCompanyLocationId  
	JOIN tblSMCompanyLocationSubLocation  MUSL ON MUSL.intCompanyLocationSubLocationId  = CD.intSubLocationId 
	JOIN tblQMGardenMark  GM ON GM.intGardenMarkId = B.intGardenMarkId  
	JOIN tblICItem OI on OI.intItemId=B.intOriginalItemId
	Left JOIN tblQMTINClearance T on T.intBatchId =B.intBatchId 
	

	UPDATE dbo.tblIPContractedStockPreStage
	SET intStatusId = NULL
	WHERE intContractedStockPreStageId IN (
			SELECT PS.intContractedStockPreStageId
			FROM @tblIPContractedStockPreStage PS
			)
		AND intStatusId = - 1

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