CREATE PROCEDURE [dbo].[uspCTReportPriceFixation]
		
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
	SELECT  @IntNoOFUniFormItemUOM=COUNT(DISTINCT intItemUOMId)  FROM tblCTContractDetail WHERE intContractHeaderId= @intContractHeaderId
	SELECT  @IntNoOFUniFormNetWeightUOM=COUNT(DISTINCT intNetWeightUOMId)  FROM tblCTContractDetail WHERE intContractHeaderId= @intContractHeaderId
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
			IM.strDescription,
			LTRIM(CD.dblQuantity)+ ' ' + UM.strUnitMeasure strQuantity,
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
			LTRIM(PF.dblPriceWORollArb) + ' ' + CY.strCurrency + ' per ' + CM.strUnitMeasure strTotal,
			LTRIM(CAST(dbo.fnCTConvertQuantityToTargetCommodityUOM(PF.intFinalPriceUOMId,PU.intCommodityUnitMeasureId, PF.dblOriginalBasis) AS NUMERIC(18, 6))) + ' ' + CY.strCurrency + ' per ' + CM.strUnitMeasure strDifferential,
			LTRIM(PF.dblAdditionalCost) + ' ' + CY.strCurrency + ' per ' + CM.strUnitMeasure strAdditionalCost,
			LTRIM(PF.dblFinalPrice) + ' ' + CY.strCurrency + ' per ' + CM.strUnitMeasure strFinalPrice,
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
			@LastModifiedUserSign AS strLastModifiedUserSign

	FROM	tblCTPriceFixation			PF
	JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId			=	PF.intContractHeaderId
	JOIN	tblCTContractDetail			CD	ON	CD.intContractHeaderId			=	CH.intContractHeaderId
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
	JOIN	tblCTPosition				PO	ON	PO.intPositionId				=	CH.intPositionId	
	WHERE	PF.intPriceFixationId	=	@intPriceFixationId
	

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO