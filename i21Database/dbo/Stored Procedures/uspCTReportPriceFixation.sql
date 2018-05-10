﻿CREATE PROCEDURE [dbo].[uspCTReportPriceFixation]
		
	@xmlParam NVARCHAR(MAX) = NULL  
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	 

	DECLARE @strCompanyName			NVARCHAR(500),
			@strAddress				NVARCHAR(500),
			@strCounty				NVARCHAR(500),
			@strCity				NVARCHAR(500),
			@strState				NVARCHAR(500),
			@strZip					NVARCHAR(500),
			@strCountry				NVARCHAR(500),
			@intPriceFixationId		INT,
			@xmlDocumentId			INT,
			@strContractDocuments	NVARCHAR(MAX),
			@intLastModifiedUserId	INT,
			@LastModifiedUserSign      VARBINARY(MAX)
			
			DECLARE @TotalQuantity DECIMAL(24,10)
			DECLARE @TotalNetQuantity DECIMAL(24,10)			
			DECLARE @IntNoOFUniFormItemUOM INT
			DECLARE @IntNoOFUniFormNetWeightUOM INT
			DECLARE @intContractHeaderId INT

	IF	LTRIM(RTRIM(@xmlParam)) = ''   
		SET @xmlParam = NULL   
      
	DECLARE @temp_xml_table TABLE 
	(  
			[fieldname]		NVARCHAR(50),  
			condition		NVARCHAR(20),        
			[from]			NVARCHAR(50), 
			[to]			NVARCHAR(50),  
			[join]			NVARCHAR(10),  
			[begingroup]	NVARCHAR(50),  
			[endgroup]		NVARCHAR(50),  
			[datatype]		NVARCHAR(50) 
	)  
  
  
	EXEC sp_xml_preparedocument @xmlDocumentId output, @xmlParam  
  
	INSERT INTO @temp_xml_table  
	SELECT	*  
	FROM	OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)  
	WITH (  
				[fieldname]		NVARCHAR(50),  
				condition		NVARCHAR(20),        
				[from]			NVARCHAR(50), 
				[to]			NVARCHAR(50),  
				[join]			NVARCHAR(10),  
				[begingroup]	NVARCHAR(50),  
				[endgroup]		NVARCHAR(50),  
				[datatype]		NVARCHAR(50)  
	)  
    
	SELECT	@intPriceFixationId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intPriceFixationId'

	SELECT  @intContractHeaderId= intContractHeaderId FROM tblCTPriceFixation WHERE intPriceFixationId=@intPriceFixationId
	SELECT  @IntNoOFUniFormItemUOM=COUNT(DISTINCT intUnitMeasureId)  FROM tblCTContractDetail  WHERE intContractHeaderId= @intContractHeaderId
	SELECT  @IntNoOFUniFormNetWeightUOM=COUNT(DISTINCT U.intUnitMeasureId)  FROM tblCTContractDetail D
	JOIN	tblICItemUOM	U	ON	U.intItemUOMId	=	D.intNetWeightUOMId
	WHERE intContractHeaderId= @intContractHeaderId
	SELECT  @TotalQuantity = dblQuantity FROM tblCTContractHeader WHERE intContractHeaderId=@intContractHeaderId
	SELECT  @TotalNetQuantity =SUM(dblNetWeight) FROM tblCTContractDetail WHERE intContractHeaderId=@intContractHeaderId
	
	SELECT @intLastModifiedUserId=ISNULL(intLastModifiedById,intCreatedById) FROM tblCTPriceContract PC
	JOIN tblCTPriceFixation PF ON PF.intPriceContractId=PC.intPriceContractId 
	WHERE PF.intPriceFixationId=@intPriceFixationId
	
	SELECT @LastModifiedUserSign = Sig.blbDetail 
								   FROM tblSMSignature Sig 
								   JOIN tblEMEntitySignature ESig ON ESig.intElectronicSignatureId=Sig.intSignatureId 
								   WHERE ESig.intEntityId=@intLastModifiedUserId 

	SELECT	@strCompanyName	=	CASE WHEN LTRIM(RTRIM(strCompanyName)) = '' THEN NULL ELSE LTRIM(RTRIM(strCompanyName)) END,
			@strAddress		=	CASE WHEN LTRIM(RTRIM(strAddress)) = '' THEN NULL ELSE LTRIM(RTRIM(strAddress)) END,
			@strCounty		=	CASE WHEN LTRIM(RTRIM(strCounty)) = '' THEN NULL ELSE LTRIM(RTRIM(strCounty)) END,
			@strCity		=	CASE WHEN LTRIM(RTRIM(strCity)) = '' THEN NULL ELSE LTRIM(RTRIM(strCity)) END,
			@strState		=	CASE WHEN LTRIM(RTRIM(strState)) = '' THEN NULL ELSE LTRIM(RTRIM(strState)) END,
			@strZip			=	CASE WHEN LTRIM(RTRIM(strZip)) = '' THEN NULL ELSE LTRIM(RTRIM(strZip)) END,
			@strCountry		=	CASE WHEN LTRIM(RTRIM(strCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(strCountry)) END
	FROM	tblSMCompanySetup

	SELECT	 DISTINCT 
			PF.intPriceFixationId,
			CH.strContractNumber,
			CH.strCustomerContract,
			strDescription = isnull(rtrt.strTranslation,IM.strDescription),
			strQuantity = dbo.fnRemoveTrailingZeroes(CD.dblQuantity)+ ' ' + isnull(rtrt2.strTranslation,UM.strUnitMeasure) ,
			strPeriod = CONVERT(NVARCHAR(50),dtmStartDate,106) + ' - ' + CONVERT(NVARCHAR(50),dtmEndDate,106) ,
			strStatus = CASE	WHEN	ISNULL(PF.[dblTotalLots],0) - ISNULL(PF.[dblLotsFixed],0) = 0 
								THEN	'This confirms that the above contract has been fully fixed as follows:'
								ELSE	'This confirms that the above contract has been partially fixed as follows:'
						END,			
			strOtherPartyAddress = LTRIM(RTRIM(EY.strEntityName)) + ', ' + CHAR(13)+CHAR(10) +
									ISNULL(LTRIM(RTRIM(EY.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
									ISNULL(LTRIM(RTRIM(EY.strEntityCity)),'') + 
									ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityState)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityState)) END,'') + 
									ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityZipCode)) END,'') + 
									ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityCountry)) END,''),
			strTotal = dbo.fnRemoveTrailingZeroes(PF.dblPriceWORollArb) + ' ' + CY.strCurrency + ' per ' + isnull(rtrt3.strTranslation,CM.strUnitMeasure),
			strDifferential = dbo.fnRemoveTrailingZeroes(CAST(dbo.fnCTConvertQuantityToTargetCommodityUOM(PF.intFinalPriceUOMId,PU.intCommodityUnitMeasureId, PF.dblOriginalBasis) AS NUMERIC(18, 6))) + ' ' + CY.strCurrency + ' per ' + isnull(rtrt3.strTranslation,CM.strUnitMeasure) ,
			strAdditionalCost = dbo.fnRemoveTrailingZeroes(PF.dblAdditionalCost) + ' ' + CY.strCurrency + ' per ' + isnull(rtrt3.strTranslation,CM.strUnitMeasure) ,
			strFinalPrice = dbo.fnRemoveTrailingZeroes(PF.dblFinalPrice) + ' ' + CY.strCurrency + ' per ' + isnull(rtrt3.strTranslation,CM.strUnitMeasure) ,
			strSummary = CASE	WHEN	ISNULL(PF.[dblTotalLots],0) - ISNULL(PF.[dblLotsFixed],0) = 0 
								THEN	'All lot(s) are fixed.'
								ELSE	''
						END,
			strBuyer = CASE WHEN CH.intContractTypeId = 1 THEN @strCompanyName ELSE EY.strEntityName END,
			strSeller = CASE WHEN CH.intContractTypeId = 2 THEN @strCompanyName ELSE EY.strEntityName END,
			blbHeaderLogo = dbo.fnSMGetCompanyLogo('Header'),
			blbFooterLogo = dbo.fnSMGetCompanyLogo('Footer'),
			strCurrencyExchangeRate = FY.strCurrency + '/' + TY.strCurrency,
			CD.dblRate,
			strFXFinalPrice = LTRIM(
									dbo.fnCTConvertQuantityToTargetCommodityUOM(FC.intCommodityUnitMeasureId,PF.intFinalPriceUOMId,PF.dblFinalPrice)*
									dbo.fnCTGetCurrencyExchangeRate(CD.intContractDetailId,0)/CASE WHEN CY.ysnSubCurrency = 1 THEN ISNULL(CY.intCent,1) ELSE 1 END
								) +  ' ' + 
								CASE WHEN CD.intCurrencyId = TY.intCurrencyID THEN FY.strCurrency ELSE TY.strCurrency END + 
								' per ' + isnull(rtrt5.strTranslation,FM.strUnitMeasure),
			strFXFinalPriceLabel = CASE WHEN CD.intCurrencyExchangeRateId IS NULL THEN NULL ELSE 'Final Price' END,
			strQuantityDesc = CASE 
								WHEN ISNULL(ysnMultiplePriceFixation,0)=0 THEN
									CASE 
										WHEN UM.strUnitType='Quantity' THEN LTRIM(FLOOR(CD.dblQuantity)) + ' bags/ ' + isnull(rtrt2.strTranslation,UM.strUnitMeasure)+CASE WHEN CD.dblNetWeight IS NOT NULL THEN  ' (' ELSE '' END + ISNULL(LTRIM(FLOOR(CD.dblNetWeight)),'')+ ' '+ ISNULL(isnull(rtrt4.strTranslation,U7.strUnitMeasure),'') +CASE WHEN isnull(rtrt4.strTranslation,U7.strUnitMeasure) IS NOT NULL THEN   ')' ELSE '' END  
										ELSE ISNULL(LTRIM(dbo.fnRemoveTrailingZeroes(CD.dblNetWeight)),'')+ ' '+ ISNULL(isnull(rtrt4.strTranslation,U7.strUnitMeasure),'') 
									END
								ELSE
									CASE 
											WHEN UM.strUnitType='Quantity' AND @IntNoOFUniFormItemUOM=1 THEN LTRIM(dbo.fnRemoveTrailingZeroes(@TotalQuantity)) + ' bags/ ' + isnull(rtrt2.strTranslation,UM.strUnitMeasure)+CASE WHEN CD.dblNetWeight IS NOT NULL AND @IntNoOFUniFormNetWeightUOM=1 THEN  ' (' ELSE '' END + ISNULL(LTRIM(dbo.fnRemoveTrailingZeroes(@TotalNetQuantity)),'')+ ' '+ ISNULL(isnull(rtrt4.strTranslation,U7.strUnitMeasure),'') +CASE WHEN isnull(rtrt4.strTranslation,U7.strUnitMeasure) IS NOT NULL THEN   ')' ELSE '' END  
											ELSE CASE WHEN @IntNoOFUniFormNetWeightUOM=1 THEN ISNULL(LTRIM(dbo.fnRemoveTrailingZeroes(@TotalNetQuantity)),'')+ ' '+ ISNULL(isnull(rtrt4.strTranslation,U7.strUnitMeasure),'') ELSE '' END
									END
								END,
			strPeriodWithPosition = CONVERT(NVARCHAR(50),dtmStartDate,106) + ' - ' + CONVERT(NVARCHAR(50),dtmEndDate,106)+CASE WHEN PO.strPosition IS NOT NULL THEN  ' ('+PO.strPosition+') ' ELSE '' END,
			strLotsFixedLabel = CASE WHEN FLOOR((PF.dblTotalLots-PF.dblLotsFixed))=0 THEN '' ELSE 'Lots to be fixed :' END,
			intLotsUnFixed = LTRIM(FLOOR((PF.dblTotalLots-PF.dblLotsFixed))),
			dblLotsUnFixed = dbo.fnRemoveTrailingZeroes(ISNULL(PF.dblTotalLots-PF.dblLotsFixed,0)),
			strTotalDesc = LTRIM(CAST(ROUND(PF.dblPriceWORollArb,2) AS NUMERIC(18,2))) + ' ' + CY.strCurrency + ' per ' + isnull(rtrt3.strTranslation,CM.strUnitMeasure) ,
			strDifferentialDesc = LTRIM(CAST(CD.dblBasis AS NUMERIC(18, 2))) + ' ' + CY.strCurrency + ' per ' + isnull(rtrt3.strTranslation,CM.strUnitMeasure) ,			
			strFXFinalPriceLabelDesc = CASE WHEN CD.intCurrencyExchangeRateId IS NULL THEN NULL ELSE 'Final Price :' END,
			strFinalPriceDesc = LTRIM(CAST(ROUND(CD.dblCashPrice,2) AS NUMERIC(18,2))) + ' ' + CY.strCurrency + ' per '+isnull(rtrt3.strTranslation,CM.strUnitMeasure) ,
			strCurrencyExchangeRateDesc = FY.strCurrency + '/' + TY.strCurrency+ ' :',
			dblRateDesc = dbo.fnRemoveTrailingZeroes(ROUND(CD.dblRate,2)),
			strFXFinalPriceDesc = LTRIM(
										dbo.fnRemoveTrailingZeroes(ROUND(dbo.fnCTConvertQuantityToTargetCommodityUOM(FC.intCommodityUnitMeasureId,PF.intFinalPriceUOMId,PF.dblFinalPrice)*
										dbo.fnCTGetCurrencyExchangeRate(CD.intContractDetailId,0)/CASE WHEN CY.ysnSubCurrency = 1 THEN ISNULL(CY.intCent,1) ELSE 1 END,2))
									) +  ' ' + 
									CASE WHEN CD.intCurrencyId = TY.intCurrencyID THEN FY.strCurrency ELSE TY.strCurrency END + 
									' per ' + isnull(rtrt5.strTranslation,FM.strUnitMeasure),
			strLastModifiedUserSign = @LastModifiedUserSign,
			strTotalLots = dbo.fnRemoveTrailingZeroes(ISNULL(PF.dblTotalLots,0)),
			strMarketMonth = isnull(rtrt6.strTranslation,MA.strFutMarketName) +  ' '  + DATENAME(mm,MO.dtmFutureMonthsDate) + ' ' + DATENAME(yyyy,MO.dtmFutureMonthsDate),
			--strMarketMonth = isnull(rtrt6.strTranslation,MA.strFutMarketName) +  ' '  + isnull(rtrt1.strTranslation,MO.strFutureMonth),
			strCompanyCityAndDate = ISNULL(@strCity + ', ', '') + CONVERT(NVARCHAR(20),GETDATE(),106),
			strCompanyName = @strCompanyName

	FROM	tblCTPriceFixation			PF
	JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId			=	PF.intContractHeaderId
	JOIN	(
				SELECT	ROW_NUMBER() OVER (PARTITION BY CD.intContractHeaderId ORDER BY CD.intContractDetailId ASC) intRowNum,* 
				FROM	tblCTContractDetail			CD	

			)							CD	ON	CD.intContractHeaderId			=	CH.intContractHeaderId
											AND	CD.intContractDetailId			=	CASE	WHEN	PF.intContractDetailId IS NOT NULL 
																							THEN	PF.intContractDetailId 
																							ELSE	CD.intContractDetailId 
																					END		
	JOIN	vyuCTEntity					EY	ON	EY.intEntityId					=	CH.intEntityId	AND
												EY.strEntityType				=	(CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)	LEFT
	JOIN	tblICItem					IM	ON	IM.intItemId					=	CD.intItemId			LEFT
	JOIN	tblICItemUOM				QM	ON	QM.intItemUOMId					=	CD.intItemUOMId			LEFT
	JOIN	tblICUnitMeasure			UM	ON	UM.intUnitMeasureId				=	QM.intUnitMeasureId		LEFT	
	JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID				=	CD.intCurrencyId		LEFT
	JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityUnitMeasureId	=	PF.intFinalPriceUOMId	LEFT	
	JOIN	tblICUnitMeasure			CM	ON	CM.intUnitMeasureId				=	CU.intUnitMeasureId		LEFT	
	JOIN	tblICItemUOM				PM	ON	PM.intItemUOMId					=	CD.intPriceItemUOMId	LEFT
	JOIN	tblICCommodityUnitMeasure	PU	ON	PU.intCommodityId				=	CH.intCommodityId		AND 
												PU.intUnitMeasureId				=	PM.intUnitMeasureId		LEFT
	JOIN	tblSMCurrencyExchangeRate	ER	ON	ER.intCurrencyExchangeRateId	=	CD.intCurrencyExchangeRateId	LEFT	
	JOIN	tblSMCurrency				FY	ON	FY.intCurrencyID				=	ER.intFromCurrencyId	LEFT					
	JOIN	tblSMCurrency				TY	ON	TY.intCurrencyID				=	ER.intToCurrencyId		LEFT	
	JOIN	tblICItemUOM				FU	ON	FU.intItemUOMId					=	CD.intFXPriceUOMId		LEFT
	JOIN	tblICCommodityUnitMeasure	FC	ON	FC.intCommodityId				=	CH.intCommodityId		AND 
												FC.intUnitMeasureId				=	FU.intUnitMeasureId		LEFT
	JOIN	tblICItemUOM				WU	ON	WU.intItemUOMId					=	CD.intNetWeightUOMId	LEFT
	JOIN	tblICUnitMeasure			U7	ON	U7.intUnitMeasureId				=	WU.intUnitMeasureId		LEFT	
	JOIN	tblICUnitMeasure			FM	ON	FM.intUnitMeasureId				=	FC.intUnitMeasureId		LEFT
	JOIN	tblCTPosition				PO	ON	PO.intPositionId				=	CH.intPositionId		LEFT
	JOIN	tblRKFutureMarket			MA	ON	MA.intFutureMarketId			=	CD.intFutureMarketId	LEFT
	JOIN	tblRKFuturesMonth			MO	ON	MO.intFutureMonthId				=	CD.intFutureMonthId

	left join tblEMEntity				rte on rte.intEntityId = CH.intEntityId

	inner join tblSMScreen				rts on rts.strNamespace = 'Inventory.view.Item'
	left join tblSMTransaction			rtt on rtt.intScreenId = rts.intScreenId and rtt.intRecordId = IM.intItemId
	left join tblSMReportTranslation	rtrt on rtrt.intLanguageId = rte.intLanguageId and rtrt.intTransactionId = rtt.intTransactionId and rtrt.strFieldName = 'Description'
	
	inner join tblSMScreen				rts1 on rts1.strNamespace = 'RiskManagement.view.FuturesTradingMonths'
	left join tblSMTransaction			rtt1 on rtt1.intScreenId = rts1.intScreenId and rtt1.intRecordId = MO.intFutureMonthId
	left join tblSMReportTranslation	rtrt1 on rtrt1.intLanguageId = rte.intLanguageId and rtrt1.intTransactionId = rtt1.intTransactionId and rtrt1.strFieldName = 'Future Trading Month'
	
	inner join tblSMScreen				rts2 on rts2.strNamespace = 'Inventory.view.InventoryUOM'
	left join tblSMTransaction			rtt2 on rtt2.intScreenId = rts2.intScreenId and rtt2.intRecordId = UM.intUnitMeasureId
	left join tblSMReportTranslation	rtrt2 on rtrt2.intLanguageId = rte.intLanguageId and rtrt2.intTransactionId = rtt2.intTransactionId and rtrt2.strFieldName = 'UOM'
	
	inner join tblSMScreen				rts3 on rts3.strNamespace = 'Inventory.view.InventoryUOM'
	left join tblSMTransaction			rtt3 on rtt3.intScreenId = rts3.intScreenId and rtt3.intRecordId = CM.intUnitMeasureId
	left join tblSMReportTranslation	rtrt3 on rtrt3.intLanguageId = rte.intLanguageId and rtrt3.intTransactionId = rtt3.intTransactionId and rtrt3.strFieldName = 'UOM'
	
	inner join tblSMScreen				rts4 on rts4.strNamespace = 'Inventory.view.InventoryUOM'
	left join tblSMTransaction			rtt4 on rtt4.intScreenId = rts4.intScreenId and rtt4.intRecordId = U7.intUnitMeasureId
	left join tblSMReportTranslation	rtrt4 on rtrt4.intLanguageId = rte.intLanguageId and rtrt4.intTransactionId = rtt4.intTransactionId and rtrt4.strFieldName = 'UOM'
	
	inner join tblSMScreen				rts5 on rts5.strNamespace = 'Inventory.view.InventoryUOM'
	left join tblSMTransaction			rtt5 on rtt5.intScreenId = rts5.intScreenId and rtt5.intRecordId = FM.intUnitMeasureId
	left join tblSMReportTranslation	rtrt5 on rtrt5.intLanguageId = rte.intLanguageId and rtrt5.intTransactionId = rtt5.intTransactionId and rtrt5.strFieldName = 'UOM'
	
	inner join tblSMScreen				rts6 on rts6.strNamespace = 'RiskManagement.view.FuturesMarket'
	left join tblSMTransaction			rtt6 on rtt6.intScreenId = rts6.intScreenId and rtt6.intRecordId = MA.intFutureMarketId
	left join tblSMReportTranslation	rtrt6 on rtrt6.intLanguageId = rte.intLanguageId and rtrt6.intTransactionId = rtt6.intTransactionId and rtrt6.strFieldName = 'Market Name'

	WHERE	PF.intPriceFixationId	=	@intPriceFixationId
	


	/*
	SELECT	 DISTINCT 
			PF.intPriceFixationId,
			CH.strContractNumber,
			CH.strCustomerContract,
			IM.strDescription,
			dbo.fnRemoveTrailingZeroes(CD.dblQuantity)+ ' ' + UM.strUnitMeasure strQuantity,
			CONVERT(NVARCHAR(50),dtmStartDate,106) + ' - ' + CONVERT(NVARCHAR(50),dtmEndDate,106) strPeriod,
			CASE	WHEN	ISNULL(PF.[dblTotalLots],0) - ISNULL(PF.[dblLotsFixed],0) = 0 
					THEN	'This confirms that the above contract has been fully fixed as follows:'
					ELSE	'This confirms that the above contract has been partially fixed as follows:'
			END		AS		strStatus,			
			LTRIM(RTRIM(EY.strEntityName)) + ', ' + CHAR(13)+CHAR(10) +
			ISNULL(LTRIM(RTRIM(EY.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
			ISNULL(LTRIM(RTRIM(EY.strEntityCity)),'') + 
			ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityState)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityState)) END,'') + 
			ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityZipCode)) END,'') + 
			ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityCountry)) END,'')
			AS	strOtherPartyAddress,
			dbo.fnRemoveTrailingZeroes(PF.dblPriceWORollArb) + ' ' + CY.strCurrency + ' per ' + CM.strUnitMeasure strTotal,
			dbo.fnRemoveTrailingZeroes(CAST(dbo.fnCTConvertQuantityToTargetCommodityUOM(PF.intFinalPriceUOMId,PU.intCommodityUnitMeasureId, PF.dblOriginalBasis) AS NUMERIC(18, 6))) + ' ' + CY.strCurrency + ' per ' + CM.strUnitMeasure strDifferential,
			dbo.fnRemoveTrailingZeroes(PF.dblAdditionalCost) + ' ' + CY.strCurrency + ' per ' + CM.strUnitMeasure strAdditionalCost,
			dbo.fnRemoveTrailingZeroes(PF.dblFinalPrice) + ' ' + CY.strCurrency + ' per ' + CM.strUnitMeasure strFinalPrice,
			CASE	WHEN	ISNULL(PF.[dblTotalLots],0) - ISNULL(PF.[dblLotsFixed],0) = 0 
					THEN	'All lot(s) are fixed.'
					ELSE	''
			END		AS		strSummary,
			CASE WHEN CH.intContractTypeId = 1 THEN @strCompanyName ELSE EY.strEntityName END AS strBuyer,
			CASE WHEN CH.intContractTypeId = 2 THEN @strCompanyName ELSE EY.strEntityName END AS strSeller,
			dbo.fnSMGetCompanyLogo('Header') AS blbHeaderLogo,
			dbo.fnSMGetCompanyLogo('Footer') AS blbFooterLogo,
			FY.strCurrency + '/' + TY.strCurrency AS strCurrencyExchangeRate,
			CD.dblRate,
			LTRIM(
				dbo.fnCTConvertQuantityToTargetCommodityUOM(FC.intCommodityUnitMeasureId,PF.intFinalPriceUOMId,PF.dblFinalPrice)*
				dbo.fnCTGetCurrencyExchangeRate(CD.intContractDetailId,0)/CASE WHEN CY.ysnSubCurrency = 1 THEN ISNULL(CY.intCent,1) ELSE 1 END
			) +  ' ' + 
			CASE WHEN CD.intCurrencyId = TY.intCurrencyID THEN FY.strCurrency ELSE TY.strCurrency END + 
			' per ' + FM.strUnitMeasure AS strFXFinalPrice,
			CASE WHEN CD.intCurrencyExchangeRateId IS NULL THEN NULL ELSE 'Final Price' END AS strFXFinalPriceLabel,
			CASE 
			WHEN ISNULL(ysnMultiplePriceFixation,0)=0 THEN
				CASE 
					WHEN UM.strUnitType='Quantity' THEN LTRIM(FLOOR(CD.dblQuantity)) + ' bags/ ' + UM.strUnitMeasure+CASE WHEN CD.dblNetWeight IS NOT NULL THEN  ' (' ELSE '' END + ISNULL(LTRIM(FLOOR(CD.dblNetWeight)),'')+ ' '+ ISNULL(U7.strUnitMeasure,'') +CASE WHEN U7.strUnitMeasure IS NOT NULL THEN   ')' ELSE '' END  
					ELSE ISNULL(LTRIM(dbo.fnRemoveTrailingZeroes(CD.dblNetWeight)),'')+ ' '+ ISNULL(U7.strUnitMeasure,'') 
				END
			ELSE
				CASE 
						WHEN UM.strUnitType='Quantity' AND @IntNoOFUniFormItemUOM=1 THEN LTRIM(dbo.fnRemoveTrailingZeroes(@TotalQuantity)) + ' bags/ ' + UM.strUnitMeasure+CASE WHEN CD.dblNetWeight IS NOT NULL AND @IntNoOFUniFormNetWeightUOM=1 THEN  ' (' ELSE '' END + ISNULL(LTRIM(dbo.fnRemoveTrailingZeroes(@TotalNetQuantity)),'')+ ' '+ ISNULL(U7.strUnitMeasure,'') +CASE WHEN U7.strUnitMeasure IS NOT NULL THEN   ')' ELSE '' END  
						ELSE CASE WHEN @IntNoOFUniFormNetWeightUOM=1 THEN ISNULL(LTRIM(dbo.fnRemoveTrailingZeroes(@TotalNetQuantity)),'')+ ' '+ ISNULL(U7.strUnitMeasure,'') ELSE '' END
				END
			END
			AS  strQuantityDesc,
			CONVERT(NVARCHAR(50),dtmStartDate,106) + ' - ' + CONVERT(NVARCHAR(50),dtmEndDate,106)+CASE WHEN PO.strPosition IS NOT NULL THEN  ' ('+PO.strPosition+') ' ELSE '' END strPeriodWithPosition,
			CASE WHEN FLOOR((PF.dblTotalLots-PF.dblLotsFixed))=0 THEN '' ELSE 'Lots to be fixed :' END AS strLotsFixedLabel,
			LTRIM(FLOOR((PF.dblTotalLots-PF.dblLotsFixed))) AS intLotsUnFixed,
			dbo.fnRemoveTrailingZeroes(ISNULL(PF.dblTotalLots-PF.dblLotsFixed,0)) AS dblLotsUnFixed,
			LTRIM(CAST(ROUND(PF.dblPriceWORollArb,2) AS NUMERIC(18,2))) + ' ' + CY.strCurrency + ' per ' + CM.strUnitMeasure strTotalDesc,
			LTRIM(CAST(CD.dblBasis AS NUMERIC(18, 2))) + ' ' + CY.strCurrency + ' per ' + CM.strUnitMeasure strDifferentialDesc,			
			CASE WHEN CD.intCurrencyExchangeRateId IS NULL THEN NULL ELSE 'Final Price :' END AS strFXFinalPriceLabelDesc,
			LTRIM(CAST(ROUND(CD.dblCashPrice,2) AS NUMERIC(18,2))) + ' ' + CY.strCurrency + ' per '+CM.strUnitMeasure strFinalPriceDesc,
			FY.strCurrency + '/' + TY.strCurrency+ ' :' AS strCurrencyExchangeRateDesc,
			dbo.fnRemoveTrailingZeroes(ROUND(CD.dblRate,2)) AS dblRateDesc,
			LTRIM(
				dbo.fnRemoveTrailingZeroes(ROUND(dbo.fnCTConvertQuantityToTargetCommodityUOM(FC.intCommodityUnitMeasureId,PF.intFinalPriceUOMId,PF.dblFinalPrice)*
				dbo.fnCTGetCurrencyExchangeRate(CD.intContractDetailId,0)/CASE WHEN CY.ysnSubCurrency = 1 THEN ISNULL(CY.intCent,1) ELSE 1 END,2))
			) +  ' ' + 
			CASE WHEN CD.intCurrencyId = TY.intCurrencyID THEN FY.strCurrency ELSE TY.strCurrency END + 
			' per ' + FM.strUnitMeasure AS strFXFinalPriceDesc,
			@LastModifiedUserSign AS strLastModifiedUserSign,
			dbo.fnRemoveTrailingZeroes(ISNULL(PF.dblTotalLots,0)) AS strTotalLots,
			MA.strFutMarketName +  ' '  + DATENAME(mm,MO.dtmFutureMonthsDate) + ' ' + DATENAME(yyyy,MO.dtmFutureMonthsDate) AS strMarketMonth,
			ISNULL(@strCity + ', ', '') + CONVERT(NVARCHAR(20),GETDATE(),106) strCompanyCityAndDate,
			@strCompanyName strCompanyName

	FROM	tblCTPriceFixation			PF
	JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId			=	PF.intContractHeaderId
	JOIN	(
				SELECT	ROW_NUMBER() OVER (PARTITION BY CD.intContractHeaderId ORDER BY CD.intContractDetailId ASC) intRowNum,* 
				FROM	tblCTContractDetail			CD	

			)							CD	ON	CD.intContractHeaderId			=	CH.intContractHeaderId
											AND	CD.intContractDetailId			=	CASE	WHEN	PF.intContractDetailId IS NOT NULL 
																							THEN	PF.intContractDetailId 
																							ELSE	CD.intContractDetailId 
																					END		
	JOIN	vyuCTEntity					EY	ON	EY.intEntityId					=	CH.intEntityId	AND
												EY.strEntityType				=	(CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)	LEFT
	JOIN	tblICItem					IM	ON	IM.intItemId					=	CD.intItemId			LEFT
	JOIN	tblICItemUOM				QM	ON	QM.intItemUOMId					=	CD.intItemUOMId			LEFT
	JOIN	tblICUnitMeasure			UM	ON	UM.intUnitMeasureId				=	QM.intUnitMeasureId		LEFT	
	JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID				=	CD.intCurrencyId		LEFT
	JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityUnitMeasureId	=	PF.intFinalPriceUOMId	LEFT	
	JOIN	tblICUnitMeasure			CM	ON	CM.intUnitMeasureId				=	CU.intUnitMeasureId		LEFT	
	JOIN	tblICItemUOM				PM	ON	PM.intItemUOMId					=	CD.intPriceItemUOMId	LEFT
	JOIN	tblICCommodityUnitMeasure	PU	ON	PU.intCommodityId				=	CH.intCommodityId		AND 
												PU.intUnitMeasureId				=	PM.intUnitMeasureId		LEFT
	JOIN	tblSMCurrencyExchangeRate	ER	ON	ER.intCurrencyExchangeRateId	=	CD.intCurrencyExchangeRateId	LEFT	
	JOIN	tblSMCurrency				FY	ON	FY.intCurrencyID				=	ER.intFromCurrencyId	LEFT					
	JOIN	tblSMCurrency				TY	ON	TY.intCurrencyID				=	ER.intToCurrencyId		LEFT	
	JOIN	tblICItemUOM				FU	ON	FU.intItemUOMId					=	CD.intFXPriceUOMId		LEFT
	JOIN	tblICCommodityUnitMeasure	FC	ON	FC.intCommodityId				=	CH.intCommodityId		AND 
												FC.intUnitMeasureId				=	FU.intUnitMeasureId		LEFT
	JOIN	tblICItemUOM				WU	ON	WU.intItemUOMId					=	CD.intNetWeightUOMId	LEFT
	JOIN	tblICUnitMeasure			U7	ON	U7.intUnitMeasureId				=	WU.intUnitMeasureId		LEFT	
	JOIN	tblICUnitMeasure			FM	ON	FM.intUnitMeasureId				=	FC.intUnitMeasureId		LEFT
	JOIN	tblCTPosition				PO	ON	PO.intPositionId				=	CH.intPositionId		LEFT
	JOIN	tblRKFutureMarket			MA	ON	MA.intFutureMarketId			=	CD.intFutureMarketId	LEFT
	JOIN	tblRKFuturesMonth			MO	ON	MO.intFutureMonthId				=	CD.intFutureMonthId
	WHERE	PF.intPriceFixationId	=	@intPriceFixationId

	*/
	

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO