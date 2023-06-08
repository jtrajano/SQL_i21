CREATE PROCEDURE [dbo].[uspCTReportContractDetail]
	
	 @intContractHeaderId INT
	,@strDetailAmendedColumns NVARCHAR(MAX) = NULL
	
AS

BEGIN TRY
	DECLARE @ysnExternal BIT 
	DECLARE	@ErrMsg NVARCHAR(MAX)
	DECLARE @space NVARCHAR(100)
	
	DECLARE @TotalQuantity DECIMAL(24,10),
			@TotalNetQuantity DECIMAL(24,10),
			@dblNoOfLots NVARCHAR(20),

			@IntNoOFUniFormItemUOM INT,
			@IntNoOFUniFormNetWeightUOM INT,
			@intLastApprovedContractId INT,
			@intPrevApprovedContractId INT,
			@strAmendedColumns NVARCHAR(MAX),
			@intContractDetailId INT

	DECLARE @Amend TABLE (intContractDetailId INT, strAmendedColumns NVARCHAR(MAX))

	SELECT @IntNoOFUniFormItemUOM=COUNT(DISTINCT intItemUOMId)  FROM tblCTContractDetail WITH (NOLOCK) WHERE intContractHeaderId= @intContractHeaderId
	SELECT @IntNoOFUniFormNetWeightUOM=COUNT(DISTINCT intNetWeightUOMId)  FROM tblCTContractDetail WITH (NOLOCK) WHERE intContractHeaderId= @intContractHeaderId

	SELECT  @dblNoOfLots = dblNoOfLots FROM tblCTContractHeader WITH (NOLOCK) WHERE intContractHeaderId=@intContractHeaderId
	SELECT  @TotalQuantity = dblQuantity FROM tblCTContractHeader WITH (NOLOCK) WHERE intContractHeaderId=@intContractHeaderId
	SELECT  @TotalNetQuantity =SUM(dblNetWeight) FROM tblCTContractDetail WITH (NOLOCK) WHERE intContractHeaderId=@intContractHeaderId AND intContractStatusId <> 3

	SELECT @intContractDetailId = MIN(intContractDetailId) FROM tblCTContractDetail WITH (NOLOCK) WHERE intContractHeaderId = @intContractHeaderId

	SELECT @ysnExternal = (CASE WHEN intBookVsEntityId > 0 THEN CONVERT(BIT,1) ELSE CONVERT(BIT,0) END)		
	FROM tblCTContractHeader CH
	LEFT JOIN tblCTBookVsEntity be on be.intEntityId = CH.intEntityId
	WHERE CH.intContractHeaderId = @intContractHeaderId

	DECLARE @strAmendedColumnsDetails	NVARCHAR(MAX)
	DECLARE @fontBoldCashPrice NVARCHAR(MAX)
	DECLARE @fontBoldBasis NVARCHAR(MAX)
	DECLARE @fontBoldFutureMarket NVARCHAR(MAX)
	DECLARE @fontBoldFutureMonth NVARCHAR(MAX)
	DECLARE @fontBoldFutures NVARCHAR(MAX)
	DECLARE @fontBoldCurrency NVARCHAR(MAX)
	DECLARE @fontBoldQuantity NVARCHAR(MAX)
	DECLARE @fontBoldQuantityUOM NVARCHAR(MAX)
	DECLARE @fontBoldStartDate NVARCHAR(MAX)
	DECLARE @fontBoldEndDate NVARCHAR(MAX)
	DECLARE @fontBold NVARCHAR(MAX)
	DECLARE @fontBoldItem NVARCHAR(MAX)
	DECLARE @fontBoldStatus NVARCHAR(MAX)

	SELECT  @strAmendedColumnsDetails = STUFF((
											SELECT DISTINCT ',' + LTRIM(RTRIM(AAP.strDataIndex))
											FROM tblCTAmendmentApproval AAP
											JOIN tblCTSequenceAmendmentLog AL WITH (NOLOCK) ON AL.intAmendmentApprovalId =AAP.intAmendmentApprovalId AND AL.intContractHeaderId = @intContractHeaderId 
											JOIN tblCTSequenceHistory SH  ON SH.intContractHeaderId = @intContractHeaderId
											WHERE ISNULL(AAP.ysnAmendment,0) = 1
											FOR XML PATH('')
											), 1, 1, '')

	SET @fontBold = '<span style="font-family:Arial;font-size:13px;">'
	IF CHARINDEX('dblCashPrice',@strAmendedColumnsDetails, 0) > 0 
		BEGIN
			SET @fontBoldCashPrice = '<span style="font-family:Arial;font-size:13px;font-weight:bold;">'
		END
		ELSE
		BEGIN 
			SET @fontBoldCashPrice = '<span style="font-family:Arial;font-size:13px;">'
		END
	IF CHARINDEX('dblBasis',@strAmendedColumnsDetails, 0) > 0 
		BEGIN
			SET @fontBoldBasis = '<span style="font-family:Arial;font-size:13px;font-weight:bold;">'
		END
		ELSE
		BEGIN 
			SET @fontBoldBasis = '<span style="font-family:Arial;font-size:13px;">'
		END
	IF CHARINDEX('intFutureMarketId',@strAmendedColumnsDetails, 0) > 0 
		BEGIN
			SET @fontBoldFutureMarket = '<span style="font-family:Arial;font-size:13px;font-weight:bold;">'
		END
		ELSE
		BEGIN 
			SET @fontBoldFutureMarket = '<span style="font-family:Arial;font-size:13px;">'
		END
	IF CHARINDEX('dblFutures',@strAmendedColumnsDetails, 0) > 0 
		BEGIN
			SET @fontBoldFutures = '<span style="font-family:Arial;font-size:13px;font-weight:bold;">'
		END
		ELSE
		BEGIN 
			SET @fontBoldFutures = '<span style="font-family:Arial;font-size:13px;">'
		END
	IF CHARINDEX('intCurrencyId',@strAmendedColumnsDetails, 0) > 0 
		BEGIN
			SET @fontBoldCurrency = '<span style="font-family:Arial;font-size:13px;font-weight:bold;">'
		END
		ELSE
		BEGIN 
			SET @fontBoldCurrency = '<span style="font-family:Arial;font-size:13px;">'
		END
	IF CHARINDEX('intFutureMonthId',@strAmendedColumnsDetails, 0) > 0 
		BEGIN
			SET @fontBoldFutureMonth = '<span style="font-family:Arial;font-size:13px;font-weight:bold;">'
		END
		ELSE
		BEGIN 
			SET @fontBoldFutureMonth = '<span style="font-family:Arial;font-size:13px;">'
		END
	IF CHARINDEX('dblQuantity',@strAmendedColumnsDetails, 0) > 0 
		BEGIN
			SET @fontBoldQuantity = '<span style="font-family:Arial;font-size:13px;font-weight:bold;">'
		END
		ELSE
		BEGIN 
			SET @fontBoldQuantity = '<span style="font-family:Arial;font-size:13px;">'
		END	
	IF CHARINDEX('intItemUOMId',@strAmendedColumnsDetails, 0) > 0 
		BEGIN
			SET @fontBoldQuantityUOM = '<span style="font-family:Arial;font-size:13px;font-weight:bold;">'
		END
		ELSE
		BEGIN 
			SET @fontBoldQuantityUOM = '<span style="font-family:Arial;font-size:13px;">'
		END	
	IF CHARINDEX('dtmStartDate',@strAmendedColumnsDetails, 0) > 0 
		BEGIN
			SET @fontBoldStartDate = '<span style="font-family:Arial;font-size:13px;font-weight:bold;">'
		END
		ELSE
		BEGIN 
			SET @fontBoldStartDate = '<span style="font-family:Arial;font-size:13px;">'
		END
	IF CHARINDEX('dtmEndDate',@strAmendedColumnsDetails, 0) > 0 
		BEGIN
			SET @fontBoldEndDate = '<span style="font-family:Arial;font-size:13px;font-weight:bold;">'
		END
		ELSE
		BEGIN 
			SET @fontBoldEndDate = '<span style="font-family:Arial;font-size:13px;">'
		END
	IF CHARINDEX('intItemId',@strAmendedColumnsDetails, 0) > 0 
		BEGIN
			SET @fontBoldItem = '<span style="font-family:Arial;font-size:13px;font-weight:bold;">'
		END
		ELSE
		BEGIN 
			SET @fontBoldItem = '<span style="font-family:Arial;font-size:13px;">'
		END	
	IF CHARINDEX('intContractStatusId',@strAmendedColumnsDetails, 0) > 0 
		BEGIN
			SET @fontBoldStatus = '<span style="font-family:Arial;font-size:13px;font-weight:bold;">'
		END
		ELSE
		BEGIN 
			SET @fontBoldStatus = '<span style="font-family:Arial;font-size:13px;">'
		END	
	
		
	DECLARE @htmlDoc NVARCHAR(MAX)
	SET @htmlDoc = '</br></br>'
	SET @space = '                      '
	WHILE ISNULL(@intContractDetailId,0) > 0
	BEGIN
		SELECT @strAmendedColumns = ''
		SELECT TOP 1 @intLastApprovedContractId =  intApprovedContractId
		FROM   tblCTApprovedContract WITH (NOLOCK)
		WHERE  intContractDetailId = @intContractDetailId AND strApprovalType IN ('Amendment and Approvals','Contract Amendment ') AND ysnApproved = 1
		ORDER BY intApprovedContractId DESC

		SELECT TOP 1 @intPrevApprovedContractId =  intApprovedContractId
		FROM   tblCTApprovedContract WITH (NOLOCK)
		WHERE  intContractDetailId = @intContractDetailId AND intApprovedContractId < @intLastApprovedContractId  AND ysnApproved = 1
		ORDER BY intApprovedContractId DESC
             
		IF @intPrevApprovedContractId IS NOT NULL AND @intLastApprovedContractId IS NOT NULL
		BEGIN
			EXEC uspCTCompareRecords 'tblCTApprovedContract', @intPrevApprovedContractId, @intLastApprovedContractId,'intApprovedById,dtmApproved,
			intContractBasisId,dtmPlannedAvailabilityDate,strOrigin,dblNetWeight,intNetWeightUOMId,
			intSubLocationId,intStorageLocationId,intPurchasingGroupId,strApprovalType,strVendorLotID,ysnApproved,intCertificationId,intLoadingPortId', @strAmendedColumns OUTPUT
		END

		INSERT INTO @Amend
		SELECT @intContractDetailId,@strAmendedColumns

		SELECT @intContractDetailId = MIN(intContractDetailId) FROM tblCTContractDetail WITH (NOLOCK) WHERE intContractHeaderId = @intContractHeaderId AND intContractDetailId > @intContractDetailId
	END
	


	SELECT	intContractHeaderId		= CD.intContractHeaderId,
			intContractSeq			= CD.intContractSeq,
			strPeriod				= CONVERT(NVARCHAR(50),dtmStartDate,106) + ' - ' + CONVERT(NVARCHAR(50),dtmEndDate,106),
			strAtlasPeriod			= CONVERT(NVARCHAR(50),dtmStartDate,106) + ' -   ' + CONVERT(NVARCHAR(50),dtmEndDate,106),
			strQunatity				= CASE WHEN CP.strDefaultContractReport = 'ContractBeGreen' THEN CONVERT(NVARCHAR,CAST(CD.dblQuantity  AS Money),1) ELSE LTRIM(dbo.fnRemoveTrailingZeroes(CD.dblQuantity)) END + ' ' + UM.strUnitMeasure,
			strAtlasQunatity		= LTRIM(dbo.fnRemoveTrailingZeroes(CD.dblQuantity)) + ' - ' + UM.strUnitMeasure,
			dblQuantity				= CD.dblQuantity,
			strPrice				= CASE	WHEN	CD.intPricingTypeId IN (1,6) THEN dbo.fnRemoveTrailingZeroes(CAST(CD.dblCashPrice AS NUMERIC(18, 6))) + ' ' + CY.strCurrency + ' per ' + PU.strUnitMeasure + ' net' 
											WHEN 	CD.intPricingTypeId = 2	THEN dbo.fnRemoveTrailingZeroes(CAST(CD.dblBasis AS NUMERIC(18, 2))) + ' ' + CY.strCurrency + ' per ' + PU.strUnitMeasure + ', ' + MO.strFutureMonth + CASE WHEN ISNULL(CH.ysnMultiplePriceFixation,0) = 0 THEN ' ('+ LTRIM(CAST(CD.dblNoOfLots AS INT)) +' Lots)' ELSE '' END 	
									  END,
			strAtlasPrice			= CASE	WHEN	CD.intPricingTypeId IN (1,6) THEN LTRIM(CAST(CD.dblCashPrice AS NUMERIC(18, 4))) + ' ' + CY.strCurrency + ' per ' + PU.strUnitMeasure + ' net' 
											WHEN 	CD.intPricingTypeId = 2		 THEN LTRIM(CAST(CD.dblBasis AS NUMERIC(18, 4))) + ' ' + CY.strCurrency + ' per ' + PU.strUnitMeasure + ', ' + MO.strFutureMonth  	
									  END,
			strBeGreenPrice			= CASE	WHEN	CD.intPricingTypeId IN (1,6) THEN CONVERT(NVARCHAR,CAST(CD.dblCashPrice  AS Money),1) + ' ' + CY.strCurrency + '/' + PU.strUnitMeasure + ' ' + MO.strFutureMonth  	
											WHEN 	CD.intPricingTypeId = 2		 THEN CONVERT(NVARCHAR,CAST(ABS(CD.dblBasis)  AS Money),1) + ' ' + CY.strCurrency + '/' + PU.strUnitMeasure + CASE WHEN CD.dblBasis < 0 THEN ' under ' ELSE ' over ' END + MO.strFutureMonth  	
									  END,
			strDescription			= ISNULL(IC.strContractItemName,IM.strDescription),
			strBagMark				= BM.strBagMark,
			strReference			= CD.strReference,
			dtmETD					= GETDATE(),
			dtmContractDate			= CH.dtmContractDate,
			strGarden				= EF.strFieldNumber ,
			strGrade				= CD.strGrade,
			dblNetWeight			= CD.dblNetWeight,
			strWeightUOM			= NU.strUnitMeasure,
			dblUnitQty				= dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intNetWeightUOMId,1),
			dblCashPrice			= CD.dblCashPrice,
			strCurrency				= CY.strCurrency,
			dblTotalCost			= CD.dblTotalCost,
			strPriceUOM				= PU.strUnitMeasure ,
			strQuantityDesc			= CASE 
											WHEN UM.strUnitType='Quantity' THEN LTRIM(dbo.fnRemoveTrailingZeroes(CD.dblQuantity)) + ' bags/ ' + UM.strUnitMeasure+CASE WHEN CD.dblNetWeight IS NOT NULL THEN  ' (' ELSE '' END + ISNULL(LTRIM(dbo.fnRemoveTrailingZeroes(CD.dblNetWeight)),'')+ ' '+ ISNULL(U7.strUnitMeasure,'') +CASE WHEN U7.strUnitMeasure IS NOT NULL THEN   ')' ELSE '' END  
											ELSE ISNULL(LTRIM(dbo.fnRemoveTrailingZeroes(CD.dblNetWeight)),'')+ ' '+ ISNULL(U7.strUnitMeasure,'') 
									  END,
			strPriceDesc			= CASE	WHEN	CD.intPricingTypeId IN (1,6) THEN LTRIM(CAST(CD.dblCashPrice AS NUMERIC(18, 2))) + ' ' + CY.strCurrency + ' per ' + PU.strUnitMeasure + ' net' 
											WHEN 	CD.intPricingTypeId = 2	THEN LTRIM(CAST(CD.dblBasis AS NUMERIC(18, 2))) + ' ' + CY.strCurrency + ' per ' + PU.strUnitMeasure + ', ' + MO.strFutureMonth + CASE WHEN ISNULL(CH.ysnMultiplePriceFixation,0) = 0 THEN ' ('+ LTRIM(CAST(CD.dblNoOfLots AS INT)) +' Lots)' ELSE '' END 	
									  END,
			strTotalDesc			= CASE 
											WHEN ISNULL(CH.ysnMultiplePriceFixation,0)=1 THEN
												CASE 
													WHEN UM.strUnitType='Quantity' AND @IntNoOFUniFormItemUOM=1 THEN LTRIM(dbo.fnRemoveTrailingZeroes(@TotalQuantity)) + ' bags/ ' + UM.strUnitMeasure+CASE WHEN CD.dblNetWeight IS NOT NULL AND @IntNoOFUniFormNetWeightUOM=1 THEN  ' (' ELSE '' END + ISNULL(LTRIM(dbo.fnRemoveTrailingZeroes(@TotalNetQuantity)),'')+ ' '+ ISNULL(U7.strUnitMeasure,'') +CASE WHEN U7.strUnitMeasure IS NOT NULL THEN   ')' ELSE '' END  
													ELSE CASE WHEN @IntNoOFUniFormNetWeightUOM=1 THEN ISNULL(LTRIM(dbo.fnRemoveTrailingZeroes(@TotalNetQuantity)),'')+ ' '+ ISNULL(U7.strUnitMeasure,'') ELSE '' END
												END
											ELSE 
												NULL 
									  END,
			lblLots					= CASE	WHEN	CD.intPricingTypeId = 1 THEN NULL
											WHEN 	CD.intPricingTypeId = 2	THEN 'Lots :'
									  END,
			dblNoOfLots				= CASE	WHEN	CD.intPricingTypeId = 1 THEN NULL
											WHEN 	CD.intPricingTypeId = 2	THEN dbo.fnRemoveTrailingZeroes(@dblNoOfLots)
									  END,
			strLots				    = dbo.fnRemoveTrailingZeroes(CD.dblNoOfLots),
			dblRatio			    = dbo.fnCTChangeNumericScale(CD.dblRatio,4),
			strMarketMonth			= MA.strFutMarketName + ' ' + REPLACE(MO.strFutureMonth ,' ','-') ,
			strAmendedColumnsDetails= @strAmendedColumnsDetails,
			strAmendedColumns		= CASE WHEN ISNULL(@strDetailAmendedColumns,'') <>'' THEN @strDetailAmendedColumns ELSE  AM.strAmendedColumns END,
			strCommodityCode		= CO.strCommodityCode,
			strERPBatchNumber		= CD.strERPBatchNumber,
			strItemSpecification	= CD.strItemSpecification,
			strBasisComponent		= dbo.fnCTGetBasisComponentString(CD.intContractDetailId,'HERSHEY'),
			strStraussQuantity		= CASE WHEN CHARINDEX('intContractStatusId',@strAmendedColumnsDetails, 0) > 0
												OR CHARINDEX('dblQuantity',@strAmendedColumnsDetails, 0) > 0
										   THEN CASE WHEN CH.intPricingTypeId = 2 THEN @htmlDoc 
													 WHEN LEN(IM.strDescription) > 150 THEN @htmlDoc
													 WHEN LEN(IBM.strItemNo) > 150 THEN @htmlDoc
												ELSE (CASE WHEN  CH.intPricingTypeId = 1 AND LEN('('+ IBM.strItemNo + ') ' + IM.strDescription) > 150  THEN @htmlDoc ELSE '' END)  END +  @fontBoldQuantity + dbo.fnRemoveTrailingZeroes(CD.dblQuantity) + '</span>' + @fontBoldQuantityUOM + ' ' + UM.strUnitMeasure +'</span>' 												
												+ @fontBoldStatus + (CASE WHEN CD.intContractStatusId = 3 THEN ' - Cancelled.' ELSE '' END) + '</span>'
										   ELSE
												dbo.fnRemoveTrailingZeroes(CD.dblQuantity) + ' ' + UM.strUnitMeasure + (CASE WHEN CD.intContractStatusId = 3 THEN ' - Cancelled.' ELSE '' END)
									   END,
			strStaussItemDescription = (case when @ysnExternal = convert(bit,1) then '(' + IBM.strItemNo + ') ' else '' end) + IM.strDescription,
			strItemBundleNoLabel	= (case when @ysnExternal = convert(bit,1) then 'GROUP QUALITY CODE:' else null end),
			strStraussItemBundleNo	= IBM.strItemNo,
			strStraussPrice			= CASE WHEN CHARINDEX('dblCashPrice',@strAmendedColumnsDetails, 0) > 0
										   OR CHARINDEX('dblBasis',@strAmendedColumnsDetails, 0) > 0
										   OR CHARINDEX('intFutureMarketId',@strAmendedColumnsDetails, 0) > 0
										   OR CHARINDEX('dblFutures',@strAmendedColumnsDetails, 0) > 0
										   OR CHARINDEX('intCurrencyId',@strAmendedColumnsDetails, 0) > 0
										   OR CHARINDEX('intFutureMonthId',@strAmendedColumnsDetails, 0) > 0
									  THEN
										(CASE WHEN CH.intPricingTypeId = 2
											THEN  @fontBold + 'PTBF basis ' +  '</span>' + @fontBoldFutureMarket + MA.strFutMarketName + space(20)  + '</span>' + ' ' + @fontBoldFutureMonth + DATENAME(mm,MO.dtmFutureMonthsDate) + ' ' + DATENAME(yyyy,MO.dtmFutureMonthsDate) + '</span>'
			 									+ CASE WHEN CD.dblBasis < 0 THEN  @fontBold + ' minus ' + '</span>'  ELSE  @fontBold +  ' plus ' + '</span>' END
			 									+ @fontBoldCurrency + BCU.strCurrency+  '</span>' + ' '
			 									+ @fontBoldBasis + dbo.fnCTChangeNumericScale(abs(CD.dblBasis),2)+'</span>' + '/' + @fontBold + BUM.strUnitMeasure + '</span>'
			 									+ @fontBold + ' at ' + CD.strFixationBy + '''s option prior to FND of ' + '</span>'
			 									+ @fontBoldFutureMonth + DATENAME(mm,MO.dtmFutureMonthsDate) + ' ' + DATENAME(yyyy,MO.dtmFutureMonthsDate)  + '</span>'
			 									+ '<div style="font-family:Arial;font-size:13px;">' + ' or prior to presentation of documents,whichever is earlier.' + '</div>'
			 								ELSE + ( CASE WHEN CH.intPricingTypeId = 2 OR LEN('('+ IBM.strItemNo + ') ' + IM.strDescription) > 150 THEN @htmlDoc 
													      ELSE  '</br>' END ) + @fontBoldCashPrice + dbo.fnCTChangeNumericScale(CD.dblCashPrice,2)+ '</span>' +  @fontBoldCurrency +' ' + BCU.strCurrency + '</span>' + '<span>'+@fontBold + ' per ' + '</span>' +  @fontBold + PU.strUnitMeasure + '</span>' 
			 						   END)
									
									 ELSE
										 CASE WHEN CH.intPricingTypeId = 2
											THEN 'PTBF basis ' + MA.strFutMarketName + ' ' + DATENAME(mm,MO.dtmFutureMonthsDate) + ' ' + DATENAME(yyyy,MO.dtmFutureMonthsDate)
			 									+ CASE WHEN CD.dblBasis < 0 THEN ' minus ' ELSE ' plus ' END
			 									+ BCU.strCurrency + ' '
			 									+ dbo.fnCTChangeNumericScale(abs(CD.dblBasis),2) + '/' + BUM.strUnitMeasure
			 									+ ' at ' + CD.strFixationBy + '''s option prior to FND of '
			 									+ DATENAME(mm,MO.dtmFutureMonthsDate) + ' ' + DATENAME(yyyy,MO.dtmFutureMonthsDate)
			 									+ ' or prior to presentation of documents,whichever is earlier.'
			 								ELSE '' + dbo.fnCTChangeNumericScale(CD.dblCashPrice,2) + ' ' + BCU.strCurrency + ' per ' + PU.strUnitMeasure
			 						   END
									 END,
			strStraussShipmentLabel	= (case when PO.strPositionType = 'Spot' then 'DELIVERY' else 'SHIPMENT' end),
			strStraussShipment		=  CASE WHEN CHARINDEX('dtmStartDate',@strAmendedColumnsDetails, 0) > 0  OR CHARINDEX('dtmEndDate',@strAmendedColumnsDetails, 0) > 0
											THEN  ((CASE WHEN CH.intPricingTypeId = 2 THEN @htmlDoc   ELSE ( CASE WHEN LEN('('+ IBM.strItemNo + ') ' + IM.strDescription) > 150 THEN @htmlDoc ELSE  '' END )
													END) + 
													
													(CASE 														
														WHEN SM.strReportDateFormat = 'M/d/yyyy'	THEN @fontBoldStartDate + dbo.fnConvertDateToReportDateFormat(CD.dtmStartDate, 0)+ '</span>' + ' - ' + @fontBoldEndDate +dbo.fnConvertDateToReportDateFormat( CD.dtmEndDate, 0) + '</span>'																																		
														WHEN SM.strReportDateFormat = 'M/d/yy'		THEN @fontBoldStartDate + dbo.fnConvertDateToReportDateFormat(CD.dtmStartDate, 0)+ '</span>' + ' - ' + @fontBoldEndDate +dbo.fnConvertDateToReportDateFormat( CD.dtmEndDate, 0) + '</span>'
														WHEN SM.strReportDateFormat = 'dd-MMM-yyyy' THEN @fontBoldStartDate + dbo.fnConvertDateToReportDateFormat(CD.dtmStartDate, 0)+ '</span>' + ' - ' + @fontBoldEndDate +dbo.fnConvertDateToReportDateFormat( CD.dtmEndDate, 0) + '</span>'												  
													ELSE @fontBoldStartDate + CONVERT(NVARCHAR, CD.dtmStartDate, ISNULL(SM.intConversionId, 101)) + '</span>' + ' - ' + @fontBoldEndDate + CONVERT(NVARCHAR, CD.dtmEndDate, ISNULL(SM.intConversionId, 101)) + '</span>'
													END)
												   )
									   ELSE	
											(CASE WHEN SM.strReportDateFormat = 'M/d/yyyy'		THEN dbo.fnConvertDateToReportDateFormat(CD.dtmStartDate, 0) + ' - ' + dbo.fnConvertDateToReportDateFormat( CD.dtmEndDate, 0)
												  WHEN SM.strReportDateFormat = 'M/d/yy'		THEN dbo.fnConvertDateToReportDateFormat(CD.dtmStartDate, 0) + ' - ' + dbo.fnConvertDateToReportDateFormat( CD.dtmEndDate, 0)
												  WHEN SM.strReportDateFormat = 'dd-MMM-yyyy'  THEN dbo.fnConvertDateToReportDateFormat(CD.dtmStartDate, 0) + ' - ' + dbo.fnConvertDateToReportDateFormat( CD.dtmEndDate, 0)
											ELSE  CONVERT(NVARCHAR, CD.dtmStartDate, ISNULL(SM.intConversionId, 101)) + ' - ' + CONVERT(NVARCHAR, CD.dtmEndDate, ISNULL(SM.intConversionId, 101)) 
											END)
									   END, 
			strStraussDestinationPointName = (case when PO.strPositionType = 'Spot' then CT.strCity else CTY.strCity end),
			strWalterPositionLabel	= ISNULL(strPosition,'') + ' ' + 'Period',
			strWalterOrigin			= dbo.[fnCTGetSeqDisplayField](CD.intContractDetailId, 'Origin'),
			strWalterPricing		= CASE WHEN CD.intPricingTypeId in (1,6) THEN 'Priced at ' + LTRIM(CAST(CD.dblCashPrice AS NUMERIC(18, 2))) +' ' + CY.strCurrency + '/' + PU.strUnitMeasure ELSE 
									   'To be fixed at ' + CASE WHEN ISNULL(CD.strFixationBy,'') <> '' THEN CD.strFixationBy +'''s Call, against '  ELSE '' END
									   +  MA.strFutMarketName +	' ' + DATENAME(mm,MO.dtmFutureMonthsDate) + '-' + CAST(MO.intYear AS NVARCHAR) + ' '
									   +  CASE WHEN CD.intPricingTypeId in (2) AND CD.dblBasis > 0	  THEN '  +' +  LTRIM(CAST(CD.dblBasis AS NUMERIC(18, 2)))  + ' ' + CY.strCurrency + '/' + PU.strUnitMeasure  ELSE '     ' +  LTRIM(CAST(CD.dblBasis AS NUMERIC(18, 2)))  + ' ' + CY.strCurrency + '/' + PU.strUnitMeasure END + ''	
									   +  CASE WHEN CD.intPricingTypeId = 2 AND CO.strCommodityCode != 'Cocoa' THEN @space+'(Lots to be fixed:' + LTRIM(dbo.fnRemoveTrailingZeroes(CD.dblNoOfLots)) +')'
											   ELSE '' END
									 END, 
			--EKATERRA
			strTealingo				= ISNULL(ICI.strItemNo,IBM.strItemNo),
			strTargetNoPackage		= dbo.fnRemoveTrailingZeroes(CD.dblQuantity), --Qty Sequence
			strPkgType				= UM.strUnitMeasure, --Qty UOM
			strAvgWeight			= U7.strUnitMeasure, --Net UOM
			strApproxWeight			= dbo.fnRemoveTrailingZeroes(CD.dblNetWeight), --NETWEIGHT
			strPriceKg				= ROUND(dbo.fnCTConvertQtyToTargetItemUOM(CD.intPriceItemUOMId,KG.intItemUOMId,CD.dblCashPrice),2), 
			strTotalValue			= ROUND(CD.dblTotalCost,2) ,
			strMixingUnit			= CB.strBook,
			strPortofArrival		= CTY.strCity,
			dtmEtaPOL				= CD.dtmEtaPol,
			dtmEtaPOD				= CD.dtmEtaPod,
			dtmStockDate			= CD.dtmUpdatedAvailabilityDate,
			dtmOrigStockDate		= CD.dtmPlannedAvailabilityDate								
	FROM	tblCTContractDetail CD	WITH (NOLOCK)
	JOIN	tblCTContractHeader	CH	WITH (NOLOCK) ON	CH.intContractHeaderId	=	CD.intContractHeaderId	
	JOIN	tblICCommodity		CO	WITH (NOLOCK) ON	CO.intCommodityId		=	CH.intCommodityId		LEFT
	--JOIN	 tblICCommodityUnitMeasure CUM WITH (NOLOCK) ON CUM.intCommodityUnitMeasureId = CH.intCommodityUOMId LEFT
	--JOIN	tblICUnitMeasure	COM	WITH (NOLOCK) ON	COM.intUnitMeasureId	=	CUM.intUnitMeasureId	LEFT	
	JOIN	tblICItemUOM		QM	WITH (NOLOCK) ON	QM.intItemUOMId			=	CD.intItemUOMId			LEFT
	JOIN	tblICUnitMeasure	UM	WITH (NOLOCK) ON	UM.intUnitMeasureId		=	QM.intUnitMeasureId		LEFT
	JOIN	tblICItemUOM		PM	WITH (NOLOCK) ON	PM.intItemUOMId			=	CD.intPriceItemUOMId	LEFT
	JOIN	tblICUnitMeasure	PU	WITH (NOLOCK) ON	PU.intUnitMeasureId		=	PM.intUnitMeasureId		LEFT
	JOIN	tblSMCurrency		CY	WITH (NOLOCK) ON	CY.intCurrencyID		=	CD.intCurrencyId		LEFT
	JOIN	tblRKFutureMarket	MA	WITH (NOLOCK) ON	MA.intFutureMarketId	=	CD.intFutureMarketId	LEFT
	JOIN	tblRKFuturesMonth	MO	WITH (NOLOCK) ON	MO.intFutureMonthId		=	CD.intFutureMonthId		LEFT
	JOIN	tblICItem			IM	WITH (NOLOCK) ON	IM.intItemId			=	CD.intItemId			LEFT
	JOIN	[tblEMEntityFarm]	EF	WITH (NOLOCK) ON	EF.intFarmFieldId		=	CD.intFarmFieldId		LEFT
	JOIN	tblCTBagMark		BM	WITH (NOLOCK) ON	BM.intContractDetailId	=	CD.intContractDetailId	
									AND	BM.ysnDefault			=	1						LEFT
	JOIN	tblICItemUOM		NM	WITH (NOLOCK) ON	NM.intItemUOMId			=	CD.intNetWeightUOMId	LEFT
	JOIN	tblICItemUOM		WU	WITH (NOLOCK) ON	WU.intItemUOMId			=	CD.intNetWeightUOMId	LEFT
	JOIN	tblICUnitMeasure	U7	WITH (NOLOCK) ON	U7.intUnitMeasureId		=	WU.intUnitMeasureId		LEFT
	JOIN	tblICUnitMeasure	NU	WITH (NOLOCK) ON	NU.intUnitMeasureId		=	NM.intUnitMeasureId		LEFT
	JOIN	@Amend				AM	ON	AM.intContractDetailId	=	CD.intContractDetailId	LEFT
	JOIN	tblICItemContract	IC	WITH (NOLOCK) ON	IC.intItemContractId	=	CD.intItemContractId	LEFT
	
	-- Strauss
	JOIN	tblICItem			IBM	WITH (NOLOCK) ON	IBM.intItemId			=	CD.intItemBundleId		LEFT
	JOIN	tblICItem			ICI	WITH (NOLOCK) ON	ICI.intItemId			=	CD.intItemId			LEFT
	JOIN	tblSMCurrency		BCU	WITH (NOLOCK) ON	BCU.intCurrencyID		=	CD.intBasisCurrencyId	LEFT
	JOIN	tblICItemUOM		BCY	WITH (NOLOCK) ON	BCY.intItemUOMId		=	CD.intBasisUOMId		LEFT
	JOIN	tblICUnitMeasure	BUM WITH (NOLOCK) ON	BUM.intUnitMeasureId	=	BCY.intUnitMeasureId	LEFT
	JOIN	tblICItemUOM		PCY WITH (NOLOCK) ON	PCY.intItemUOMId		=	CD.intPriceItemUOMId	LEFT
	JOIN	tblICUnitMeasure	PUM WITH (NOLOCK) ON	PUM.intUnitMeasureId	=	PCY.intUnitMeasureId	LEFT
	JOIN	tblCTPosition		PO	WITH (NOLOCK) ON	PO.intPositionId		=	CH.intPositionId		LEFT
	JOIN	tblSMCity			CT	WITH (NOLOCK) ON	CT.intCityId			=	CH.intINCOLocationTypeId LEFT
	JOIN	tblSMCity			CTY	WITH (NOLOCK) ON	CTY.intCityId			=	CD.intDestinationPortId LEFT
	JOIN	tblCTBook			CB	WITH (NOLOCK) ON	CB.intBookId			=   CD.intBookId
	LEFT JOIN tblICItemUOM      KG  WITH (NOLOCK) ON	CD.intPriceItemUOMId			=   KG.intItemUOMId AND KG.intUnitMeasureId = 4
	CROSS JOIN tblCTCompanyPreference   CP
	CROSS JOIN (
		SELECT strReportDateFormat
			, intConversionId = CASE WHEN strReportDateFormat = 'M/d/yyyy' THEN 101
									WHEN strReportDateFormat = 'M/d/yy' THEN 1
									WHEN strReportDateFormat = 'MM/dd/yy' THEN 1
									WHEN strReportDateFormat = 'MM/dd/yyyy' THEN 101
									WHEN strReportDateFormat = 'yy/MM/dd' THEN 11
									WHEN strReportDateFormat = 'yyyy/MM/dd' THEN 111
									WHEN strReportDateFormat = 'dd-MM-yyyy' THEN 105
									WHEN strReportDateFormat = 'dd/MM/yyyy' THEN 103
									WHEN strReportDateFormat = 'dd-MMM-yyyy' THEN 106 END
		FROM tblSMCompanyPreference
	) SM
	WHERE	CD.intContractHeaderId	=	@intContractHeaderId
	--AND		CD.intContractStatusId <> 3

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH