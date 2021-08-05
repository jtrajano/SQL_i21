CREATE PROCEDURE [dbo].[uspCTReportContractDetailSequence]
	
	 @intContractHeaderId INT
	,@strDetailAmendedColumns NVARCHAR(MAX) = NULL
	
AS

BEGIN TRY
	DECLARE @ysnExternal BIT 
	DECLARE	@ErrMsg NVARCHAR(MAX)

	
	DECLARE @TotalQuantity DECIMAL(24,10),
			@TotalNetQuantity DECIMAL(24,10),
			@dblNoOfLots NVARCHAR(20),

			@IntNoOFUniFormItemUOM INT,
			@IntNoOFUniFormNetWeightUOM INT,
			@intLastApprovedContractId INT,
			@intPrevApprovedContractId INT,
			@strAmendedColumns NVARCHAR(MAX),
			@intContractSequenceId INT

	DECLARE @Amend TABLE (intContractDetailId INT, strAmendedColumns NVARCHAR(MAX))

	SELECT @IntNoOFUniFormItemUOM=COUNT(DISTINCT intItemUOMId)  FROM tblCTContractDetail WITH (NOLOCK) WHERE intContractHeaderId= @intContractHeaderId
	SELECT @IntNoOFUniFormNetWeightUOM=COUNT(DISTINCT intNetWeightUOMId)  FROM tblCTContractDetail WITH (NOLOCK) WHERE intContractHeaderId= @intContractHeaderId

	SELECT  @dblNoOfLots = dblNoOfLots FROM tblCTContractHeader WITH (NOLOCK) WHERE intContractHeaderId=@intContractHeaderId
	SELECT  @TotalQuantity = dblQuantity FROM tblCTContractHeader WITH (NOLOCK) WHERE intContractHeaderId=@intContractHeaderId
	SELECT  @TotalNetQuantity =SUM(dblNetWeight) FROM tblCTContractDetail WITH (NOLOCK) WHERE intContractHeaderId=@intContractHeaderId AND intContractStatusId <> 3

	SELECT @intContractSequenceId = MIN(intContractDetailId) FROM tblCTContractDetail WITH (NOLOCK) WHERE intContractHeaderId = @intContractHeaderId

	SELECT @ysnExternal = (CASE WHEN intBookVsEntityId > 0 THEN CONVERT(BIT,1) ELSE CONVERT(BIT,0) END)		
	FROM tblCTContractHeader CH
	LEFT JOIN tblCTBookVsEntity be on be.intEntityId = CH.intEntityId
	WHERE CH.intContractHeaderId = @intContractHeaderId

	WHILE ISNULL(@intContractSequenceId,0) > 0
	BEGIN
		SELECT @strAmendedColumns = ''
		SELECT TOP 1 @intLastApprovedContractId =  intApprovedContractId
		FROM   tblCTApprovedContract WITH (NOLOCK)
		WHERE  intContractDetailId = @intContractSequenceId AND strApprovalType IN ('Amendment and Approvals','Contract Amendment ') AND ysnApproved = 1
		ORDER BY intApprovedContractId DESC

		SELECT TOP 1 @intPrevApprovedContractId =  intApprovedContractId
		FROM   tblCTApprovedContract WITH (NOLOCK)
		WHERE  intContractDetailId = @intContractSequenceId AND intApprovedContractId < @intLastApprovedContractId  AND ysnApproved = 1
		ORDER BY intApprovedContractId DESC
             
		IF @intPrevApprovedContractId IS NOT NULL AND @intLastApprovedContractId IS NOT NULL
		BEGIN
			EXEC uspCTCompareRecords 'tblCTApprovedContract', @intPrevApprovedContractId, @intLastApprovedContractId,'intApprovedById,dtmApproved,
			intContractBasisId,dtmPlannedAvailabilityDate,strOrigin,dblNetWeight,intNetWeightUOMId,
			intSubLocationId,intStorageLocationId,intPurchasingGroupId,strApprovalType,strVendorLotID,ysnApproved,intCertificationId,intLoadingPortId', @strAmendedColumns OUTPUT
		END

		INSERT INTO @Amend
		SELECT @intContractSequenceId,@strAmendedColumns

		SELECT @intContractSequenceId = MIN(intContractDetailId) FROM tblCTContractDetail WITH (NOLOCK) WHERE intContractHeaderId = @intContractHeaderId AND intContractDetailId > @intContractSequenceId
	END
	


	SELECT	intContractHeaderId		= CD.intContractHeaderId,
			intContractSeq			= CD.intContractSeq,
			intPricingTypeId		= CD.intPricingTypeId,
			strItemNo				= IM.strItemNo,
			strPeriod				= CONVERT(NVARCHAR(50),dtmStartDate,106) + ' - ' + CONVERT(NVARCHAR(50),dtmEndDate,106),
			strSequencePeriod			= CONVERT(NVARCHAR(50),dtmStartDate,106) + ' -   ' + CONVERT(NVARCHAR(50),dtmEndDate,106),
			strSequenceQunatity		= LTRIM(dbo.fnRemoveTrailingZeroes(CD.dblQuantity)) + ' - ' + UM.strUnitMeasure,
			strPrice				= CASE	WHEN	CD.intPricingTypeId IN (1,6) THEN dbo.fnRemoveTrailingZeroes(CAST(CD.dblCashPrice AS NUMERIC(18, 6))) + ' ' + CY.strCurrency + ' per ' + PU.strUnitMeasure + ' net' 
											WHEN 	CD.intPricingTypeId = 2	THEN dbo.fnRemoveTrailingZeroes(CAST(CD.dblBasis AS NUMERIC(18, 2))) + ' ' + CY.strCurrency + ' per ' + PU.strUnitMeasure + ', ' + MO.strFutureMonth + CASE WHEN ISNULL(CH.ysnMultiplePriceFixation,0) = 0 THEN ' ('+ LTRIM(CAST(CD.dblNoOfLots AS INT)) +' Lots)' ELSE '' END 	
									  END,
			strSequencePrice		= CASE	WHEN	CD.intPricingTypeId IN (1,6) THEN LTRIM(CAST(CD.dblCashPrice AS NUMERIC(18, 6))) + ' ' + CY.strCurrency + ' per ' + PU.strUnitMeasure + ' net' 
											WHEN 	CD.intPricingTypeId = 2	THEN dbo.fnRemoveTrailingZeroes(CAST(CD.dblBasis AS NUMERIC(18, 2))) + ' ' + CY.strCurrency + ' per ' + PU.strUnitMeasure + ', ' + MO.strFutureMonth + CASE WHEN ISNULL(CH.ysnMultiplePriceFixation,0) = 0 THEN ' ('+ LTRIM(CAST(CD.dblNoOfLots AS INT)) +' Lots)' ELSE '' END 	
									  END,
			strQunatity				= CASE WHEN CP.strDefaultContractReport = 'ContractBeGreen' THEN CONVERT(NVARCHAR,CAST(CD.dblQuantity  AS Money),1) ELSE LTRIM(dbo.fnRemoveTrailingZeroes(CD.dblQuantity)) END + ' ' + UM.strUnitMeasure,
			dblQuantity				= CD.dblQuantity,
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
			strAmendedColumns		= CASE WHEN ISNULL(@strDetailAmendedColumns,'') <>'' THEN @strDetailAmendedColumns ELSE  AM.strAmendedColumns END,
			strCommodityCode		= CO.strCommodityCode,
			strERPBatchNumber		= CD.strERPBatchNumber,
			strItemSpecification	= CD.strItemSpecification,
			strBasisComponent		= dbo.fnCTGetBasisComponentString(CD.intContractDetailId,'HERSHEY'),

			strStraussQuantity		= dbo.fnRemoveTrailingZeroes(CD.dblQuantity) + ' ' + UM.strUnitMeasure,
			strStaussItemDescription = (case when @ysnExternal = convert(bit,1) then '(' + IBM.strItemNo + ') ' else '' end) + IM.strDescription,
			strItemBundleNoLabel	= (case when @ysnExternal = convert(bit,1) then 'GROUP QUALITY CODE:' else null end),
			strStraussItemBundleNo	= IBM.strItemNo,
			strStraussPrice			= CASE WHEN CD.intPricingTypeId = 2 THEN 'Price to be fixed basis ' + MA.strFutMarketName + ' ' + DATENAME(mm,MO.dtmFutureMonthsDate) + ' ' + DATENAME(yyyy,MO.dtmFutureMonthsDate) + 
												CASE WHEN CD.dblBasis < 0 THEN ' minus ' ELSE ' plus ' END +
													BCU.strCurrency + ' ' + dbo.fnCTChangeNumericScale(abs(CD.dblBasis),2) + '/'+ BUM.strUnitMeasure +' at '+ CD.strFixationBy + '''s option prior to first notice day of ' + DATENAME(mm,MO.dtmFutureMonthsDate) + ' ' + DATENAME(yyyy,MO.dtmFutureMonthsDate) + ' or on presentation of documents,whichever is earlier.'
										   ELSE '' + dbo.fnCTChangeNumericScale(CD.dblCashPrice,2) + ' ' + BCU.strCurrency + ' per ' + PU.strUnitMeasure
									   END,
			strStraussShipmentLabel	= (case when PO.strPositionType = 'Spot' then 'DELIVERY' else 'SHIPMENT' end),
			strStraussShipment		= datename(m,CD.dtmEndDate) + ' ' + substring(CONVERT(VARCHAR,CD.dtmEndDate,107),9,4) + (case when PO.strPositionType = 'Spot' then ' delivery' else ' shipment' end),
			strStraussDestinationPointName = (case when PO.strPositionType = 'Spot' then CT.strCity else CTY.strCity end)

	FROM	tblCTContractDetail CD	WITH (NOLOCK)
	JOIN	tblCTContractHeader	CH	WITH (NOLOCK) ON	CH.intContractHeaderId	=	CD.intContractHeaderId	
	JOIN	tblICCommodity		CO	WITH (NOLOCK) ON	CO.intCommodityId		=	CH.intCommodityId		LEFT
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
	JOIN	tblSMCurrency		BCU	WITH (NOLOCK) ON	BCU.intCurrencyID		=	CD.intBasisCurrencyId	LEFT
	JOIN	tblICItemUOM		BCY	WITH (NOLOCK) ON	BCY.intItemUOMId		=	CD.intBasisUOMId		LEFT
	JOIN	tblICUnitMeasure	BUM WITH (NOLOCK) ON	BUM.intUnitMeasureId	=	BCY.intUnitMeasureId	LEFT
	JOIN	tblICItemUOM		PCY WITH (NOLOCK) ON	PCY.intItemUOMId		=	CD.intPriceItemUOMId	LEFT
	JOIN	tblICUnitMeasure	PUM WITH (NOLOCK) ON	PUM.intUnitMeasureId	=	PCY.intUnitMeasureId	LEFT
	JOIN	tblCTPosition		PO	WITH (NOLOCK) ON	PO.intPositionId		=	CH.intPositionId		LEFT
	JOIN	tblSMCity			CT	WITH (NOLOCK) ON	CT.intCityId			=	CH.intINCOLocationTypeId LEFT
	JOIN	tblSMCity			CTY	WITH (NOLOCK) ON	CTY.intCityId			=	CD.intDestinationPortId
		
	CROSS JOIN tblCTCompanyPreference   CP
	WHERE	CD.intContractDetailId	=	@intContractHeaderId
	AND		CD.intContractStatusId <> 3

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH