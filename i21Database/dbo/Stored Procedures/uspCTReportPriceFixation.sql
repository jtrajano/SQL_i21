﻿CREATE PROCEDURE [dbo].[uspCTReportPriceFixation]
	@xmlParam NVARCHAR(MAX) = NULL  
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	DECLARE @strCompanyName				NVARCHAR(500),
			@strAddress					NVARCHAR(500),
			@strCounty					NVARCHAR(500),
			@strCity					NVARCHAR(500),
			@strState					NVARCHAR(500),
			@strZip						NVARCHAR(500),
			@strCountry					NVARCHAR(500),
			@intPriceFixationId			INT,
			@xmlDocumentId				INT,
			@strContractDocuments		NVARCHAR(MAX),
			@intLastModifiedUserId		INT,
			@LastModifiedUserSign		VARBINARY(MAX),
			@intLaguageId				INT,
			@strExpressionLabelName		NVARCHAR(50) = 'Expression',
			@strMonthLabelName			NVARCHAR(50) = 'Month',
			@intReportLogoHeight		INT,
			@intReportLogoWidth			INT,			
			@TotalQuantity				DECIMAL(24,10),
			@TotalNetQuantity			DECIMAL(24,10),			
			@IntNoOFUniFormItemUOM		INT,
			@IntNoOFUniFormNetWeightUOM INT,
			@intContractHeaderId		INT,
			@intContractDetailId		INT,
			@intPriceContractId			INT,
			@FirstApprovalId			INT,
			@FirstApprovalSign			VARBINARY(MAX),
			@InterCompApprovalSign		VARBINARY(MAX),
			@intScreenId				INT,
			@intTransactionId			INT,
			@ysnEnableFXFieldInContractPricing BIT = 0,
			@strFinalCurrency nvarchar(50)

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
    
	INSERT INTO @temp_xml_table
	SELECT	*  
	FROM	OPENXML(@xmlDocumentId, 'xmlparam/dummies/filter', 2)  
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
    
	SELECT	@intLaguageId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intSrLanguageId'

	IF ISNULL(@intLaguageId,0) = 0
	BEGIN
		SELECT @intLaguageId = intLanguageId FROM tblSMLanguage WHERE strLanguage = 'English'
	END

	SELECT  @intPriceContractId		=	intPriceContractId, 
			@intContractHeaderId	=	intContractHeaderId,
			@intContractDetailId	=	intContractDetailId 
	FROM	tblCTPriceFixation 
	WHERE	intPriceFixationId=@intPriceFixationId

	SELECT  @IntNoOFUniFormItemUOM	=	COUNT(DISTINCT intUnitMeasureId)  
	FROM	tblCTContractDetail  
	WHERE	intContractHeaderId	= @intContractHeaderId

	SELECT  @IntNoOFUniFormNetWeightUOM	=	COUNT(DISTINCT U.intUnitMeasureId)  
	FROM	tblCTContractDetail D
	JOIN	tblICItemUOM		U	ON	U.intItemUOMId	=	D.intNetWeightUOMId
	WHERE	intContractHeaderId	=	@intContractHeaderId

	SELECT  @TotalQuantity = dblQuantity 
	FROM	tblCTContractHeader 
	WHERE	intContractHeaderId	=	@intContractHeaderId

	SELECT  @TotalNetQuantity =	SUM(dblNetWeight) 
	FROM	tblCTContractDetail 
	WHERE	intContractHeaderId	=	@intContractHeaderId
	
	SELECT	@intLastModifiedUserId	=	ISNULL(intLastModifiedById,intCreatedById),
			@strFinalCurrency = PCC.strCurrency
	FROM	tblCTPriceContract PC
	JOIN	tblCTPriceFixation PF	ON	PF.intPriceContractId	=	PC.intPriceContractId
	LEFT JOIN tblSMCurrency PCC on PCC.intCurrencyID = PC.intFinalCurrencyId
	WHERE	PF.intPriceFixationId	=	@intPriceFixationId
	
	SELECT	@intReportLogoHeight = intReportLogoHeight,
			@intReportLogoWidth = intReportLogoWidth 
	FROM	tblLGCompanyPreference

	SELECT @intScreenId = intScreenId
	FROM tblSMScreen 
	WHERE strNamespace = 'ContractManagement.view.PriceContracts'
	AND ysnApproval = 1

	SELECT @intTransactionId = intTransactionId
	FROM tblSMTransaction
	WHERE intScreenId = @intScreenId
	AND intRecordId = @intPriceContractId 

	SELECT	TOP 1 @FirstApprovalId=intApproverId 
	FROM	tblSMApproval 
	WHERE	intTransactionId=@intTransactionId
	AND		strStatus='Approved' 
	ORDER 
	BY		intApprovalId

	SELECT	@FirstApprovalSign =  Sig.blbDetail 
	FROM	tblSMSignature Sig  WITH (NOLOCK)
	JOIN    tblEMEntitySignature ES ON Sig.intSignatureId = ES.intElectronicSignatureId
	WHERE	Sig.intEntityId=@FirstApprovalId

	SELECT	@LastModifiedUserSign = Sig.blbDetail 
	FROM	tblSMSignature Sig 
	JOIN	tblEMEntitySignature ESig ON ESig.intElectronicSignatureId=Sig.intSignatureId 
	WHERE	ESig.intEntityId=@intLastModifiedUserId 
	
	SELECT	@InterCompApprovalSign =Sig.blbDetail 
	FROM	tblCTIntrCompApproval	IA
	JOIN	tblSMUserSecurity		US	ON	US.strUserName	=	IA.strUserName	
	JOIN	tblSMSignature			Sig	ON	US.intEntityId	=	Sig.intEntityId
	JOIN    tblEMEntitySignature	ES	ON	Sig.intSignatureId = ES.intElectronicSignatureId
	WHERE	IA.intContractHeaderId	=	@intContractHeaderId
	AND		IA.strScreen	=	'Price Contract'

	SELECT	@strCompanyName	=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) = '' THEN NULL ELSE LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) END,
			@strAddress		=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strAddress)) = '' THEN NULL ELSE LTRIM(RTRIM(tblSMCompanySetup.strAddress)) END,
			@strCounty		=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(isnull(rtrt9.strTranslation,tblSMCompanySetup.strCountry))) END,
			@strCity		=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strCity)) = '' THEN NULL ELSE LTRIM(RTRIM(tblSMCompanySetup.strCity)) END,
			@strState		=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strState)) = '' THEN NULL ELSE LTRIM(RTRIM(tblSMCompanySetup.strState)) END,
			@strZip			=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strZip)) = '' THEN NULL ELSE LTRIM(RTRIM(tblSMCompanySetup.strZip)) END,
			@strCountry		=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(isnull(rtrt9.strTranslation,tblSMCompanySetup.strCountry))) END
	FROM	tblSMCompanySetup
	left join tblSMCountry				rtc9 on lower(rtrim(ltrim(rtc9.strCountry))) = lower(rtrim(ltrim(tblSMCompanySetup.strCountry)))
	left join tblSMScreen				rts9 on rts9.strNamespace = 'i21.view.Country'
	left join tblSMTransaction			rtt9 on rtt9.intScreenId = rts9.intScreenId and rtt9.intRecordId = rtc9.intCountryID
	left join tblSMReportTranslation	rtrt9 on rtrt9.intLanguageId = @intLaguageId and rtrt9.intTransactionId = rtt9.intTransactionId and rtrt9.strFieldName = 'Country'

	/*Declared variables for translating expression*/
	declare @strStatus1 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'This confirms that the above contract has been priced as follows:'), 'This confirms that the above contract has been priced as follows:');
	declare @strStatus2 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'This confirms that the above contract has been partially priced as follows:'),'This confirms that the above contract has been partially priced as follows:');
	declare @strStatus3 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'This confirms that the above contract has been fully fixed as follows:'), 'This confirms that the above contract has been priced as follows:');
	declare @strStatus4 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'This confirms that the above contract has been partially fixed as follows:'),'This confirms that the above contract has been partially priced as follows:');
	declare @per nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'per'),'per');
	declare @strSummary nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'All lot(s) are fixed.'),'All lot(s) are fixed.');
	declare @FinalPrice nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Final Price'),'Final Price');
	declare @Lotstobefixed nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Lots to be fixed'),'Lots to be fixed');
	declare @bags nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'bags'),'bags');

	select top 1 @ysnEnableFXFieldInContractPricing = ysnEnableFXFieldInContractPricing from tblCTCompanyPreference;
	
	--LOGO SETUP TAB IMPLEMENTATION
	DECLARE @imgLocationLogo vARBINARY (MAX),
			@strLogoType  NVARCHAR(50),
			@intCompanyLocationId INT
	
	SELECT TOP 1 @intCompanyLocationId = intCompanyLocationId FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId
	SELECT TOP 1 @imgLocationLogo = imgLogo, @strLogoType = 'Logo' FROM tblSMLogoPreference
	WHERE (ysnDefault = 1 OR  ysnContract = 1)  AND  intCompanyLocationId = @intCompanyLocationId

	SELECT	 DISTINCT 
			PF.intPriceFixationId,
			PF.intContractHeaderId,
			lblReferenceX = CASE WHEN CH.intContractTypeId = 1 THEN 'Buyers Ref.' ELSE 'Seller Ref.' END,
			lblReferenceY = CASE WHEN CH.intContractTypeId = 2 THEN 'Buyers Ref.' ELSE 'Seller Ref.' END,
			strCustomerContractJDE = EY.strEntityNumber,
			CH.strContractNumber,
			CH.strContractNumber +'-'+LTRIM(CD.intContractSeq) AS strAtlasContractNumber,
			CH.strCustomerContract,
			strDescription = isnull(rtrt.strTranslation,IM.strDescription),
			strQuantity = dbo.fnRemoveTrailingZeroes(CD.dblQuantity)+ ' ' + isnull(rtrt2.strTranslation,UM.strUnitMeasure) ,
			strPeriod = datename(dd,CD.dtmStartDate) + ' ' + isnull(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,datename(mm,CD.dtmStartDate)),datename(mm,CD.dtmStartDate)) + ' ' + datename(yyyy,CD.dtmStartDate) + ' - ' + datename(dd,CD.dtmEndDate) + ' ' + isnull(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,datename(mm,CD.dtmEndDate)),datename(mm,CD.dtmEndDate)) + ' ' + datename(yyyy,CD.dtmEndDate),
			strAtlasPeriod = CONVERT(NVARCHAR(50),CD.dtmStartDate,106) + ' to ' + CONVERT(NVARCHAR(50),CD.dtmEndDate,106) ,
			strStatus = CASE	WHEN	ISNULL(PF.[dblTotalLots],0) - ISNULL(PF.[dblLotsFixed],0) = 0 
								THEN	@strStatus1
								ELSE	@strStatus2
						END,
			strStatusJDE = CASE	WHEN	ISNULL(PF.[dblTotalLots],0) - ISNULL(PF.[dblLotsFixed],0) = 0 
								THEN	@strStatus3
								ELSE	@strStatus4
						END,
			strAtlasStatus = CASE	
									WHEN	ISNULL(PF.[dblTotalLots],0) - ISNULL(PF.[dblLotsFixed],0) = 0 THEN	'This confirms that the above contract has been Fully fixed as follows:'
									ELSE	'This confirms that the above contract has been Partially fixed as follows:'
							 END,			
			strOtherPartyAddress	= CASE 
									  WHEN CH.strReportTo = 'Buyer' THEN --Customer
									  	LTRIM(RTRIM(EC.strEntityName)) + ', ' + CHAR(13)+CHAR(10) +
										ISNULL(LTRIM(RTRIM(EC.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
										ISNULL(LTRIM(RTRIM(EC.strEntityCity)),'') + 
										ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityState)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityState)) END,'') + 
										ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityZipCode)) END,'') + 
										ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityCountry)) END,'')							
									  ELSE -- Seller (Vendor)
									  	LTRIM(RTRIM(EY.strEntityName)) + ', ' + CHAR(13)+CHAR(10) +
										ISNULL(LTRIM(RTRIM(EY.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
										ISNULL(LTRIM(RTRIM(EY.strEntityCity)),'') + 
										ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityState)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityState)) END,'') + 
										ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityZipCode)) END,'') + 
										ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityCountry)) END,'')
									  END,
			strGABOtherPartyAddress		=	CASE 
												WHEN CH.strReportTo = 'Buyer' THEN --Customer
													LTRIM(RTRIM(EC.strEntityName)) + ', '				+ CHAR(13)+CHAR(10) +
													ISNULL(LTRIM(RTRIM(EC.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
															
													ISNULL(CASE WHEN LTRIM(RTRIM(EC.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityZipCode)) END,'') +
													ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityCity)) = ''   THEN NULL ELSE LTRIM(RTRIM(EC.strEntityCity))   END,'') + CHAR(13)+CHAR(10) + 
															 
													ISNULL(CASE WHEN LTRIM(RTRIM(EC.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(dbo.fnCTGetTranslation('i21.view.Country',rtc12.intCountryID,@intLaguageId,'Country',rtc12.strCountry))) END,'') 
												ELSE -- Seller (Vendor)
													LTRIM(RTRIM(EY.strEntityName)) + ', '				+ CHAR(13)+CHAR(10) +
													ISNULL(LTRIM(RTRIM(EY.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
															
													ISNULL(CASE WHEN LTRIM(RTRIM(EY.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityZipCode)) END,'') +
													ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityCity)) = ''   THEN NULL ELSE LTRIM(RTRIM(EY.strEntityCity))   END,'')  + CHAR(13)+CHAR(10) + 
															
															
													ISNULL(CASE WHEN LTRIM(RTRIM(EY.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(dbo.fnCTGetTranslation('i21.view.Country',rtc10.intCountryID,@intLaguageId,'Country',rtc10.strCountry))) END,'')
											END,
			strAtlasOtherPartyAddress	=   LTRIM(RTRIM(EY.strEntityName)) + CHAR(13)+CHAR(10) +
											ISNULL(LTRIM(RTRIM(EY.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
											ISNULL(LTRIM(RTRIM(EY.strEntityCity)),'') + 
											ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityState)) = ''   THEN NULL ELSE LTRIM(RTRIM(EY.strEntityState))   END,'') + 
											ISNULL(' - '+CASE WHEN LTRIM(RTRIM(EY.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityZipCode)) END,'') + CHAR(13)+CHAR(10) + 
											ISNULL(CASE WHEN LTRIM(RTRIM(EY.strEntityCountry)) = ''      THEN NULL ELSE LTRIM(RTRIM(EY.strEntityCountry)) END,''),

			strTotal = CONVERT(NVARCHAR,CAST(PF.dblPriceWORollArb  AS Money),1) + ' ' + 
					   CASE WHEN isnull(@ysnEnableFXFieldInContractPricing,0) = 1 THEN IC.strCurrency ELSE  CY.strDescription END + 
					   ' ' + @per + ' ' + ISNULL(rtrt3.strTranslation,CM.strUnitMeasure),			
			strDifferential = dbo.fnCTChangeNumericScale(CAST(dbo.fnCTConvertQuantityToTargetCommodityUOM(PF.intFinalPriceUOMId,PU.intCommodityUnitMeasureId, PF.dblOriginalBasis) AS NUMERIC(18, 6)),2) + 
					   ' ' + CASE WHEN ISNULL(@ysnEnableFXFieldInContractPricing,0) = 1 THEN IC.strCurrency ELSE  CY.strDescription END + ' ' + @per +
					   ' ' + isnull(rtrt3.strTranslation,CM.strUnitMeasure) ,
			lblAdditionalCost = CASE WHEN ISNULL(PF.dblAdditionalCost,0) <> 0 
									 THEN 'Additional Cost' ELSE NULL 
								END,
			lblAdditionalCostColon = CASE WHEN ISNULL(PF.dblAdditionalCost,0) <> 0 
										  THEN ':' ELSE NULL 
									 END,
			strEQTAdditionalCost = CASE WHEN ISNULL(PF.dblAdditionalCost,0) <> 0 
										THEN dbo.fnRemoveTrailingZeroes(PF.dblAdditionalCost) + ' ' + CY.strCurrency + ' ' + @per + ' ' + isnull(rtrt3.strTranslation,CM.strUnitMeasure) 
								   ELSE NULL END, 
			strAdditionalCost = dbo.fnRemoveTrailingZeroes(PF.dblAdditionalCost) + ' ' + CY.strCurrency + ' ' + @per + ' ' + isnull(rtrt3.strTranslation,CM.strUnitMeasure) ,
			strFinalPrice =	CONVERT(NVARCHAR,CAST(PF.dblFinalPrice  AS Money),1) + 
							' ' + CASE WHEN isnull(@ysnEnableFXFieldInContractPricing,0) = 1 THEN IC.strCurrency ELSE  CY.strDescription END + 
							' ' + @per + ' ' + isnull(rtrt3.strTranslation,CM.strUnitMeasure) ,
			strFinalPrice2 =	'=    ' + dbo.fnRemoveTrailingZeroes(ROUND(
								CASE	WHEN	CD.intCurrencyId = CD.intInvoiceCurrencyId 
										THEN	NULL
										ELSE	CASE	WHEN	CY.intMainCurrencyId	=	CD.intInvoiceCurrencyId
														THEN	dbo.fnCTConvertQtyToTargetItemUOM(CD.intFXPriceUOMId,CD.intPriceItemUOMId,CD.dblCashPrice) / 100
														ELSE	dbo.fnCTConvertQtyToTargetItemUOM(CD.intFXPriceUOMId,CD.intPriceItemUOMId,CD.dblCashPrice) * CD.dblRate
												END
								END,2)) + ' ' + IY.strCurrency + ' ' + @per + ' ' +  dbo.fnCTGetTranslation('Inventory.view.ReportTranslation',FN.intUnitMeasureId,@intLaguageId,'Name',FN.strUnitMeasure),
			strSummary = CASE	WHEN	ISNULL(PF.[dblTotalLots],0) - ISNULL(PF.[dblLotsFixed],0) = 0 
								THEN	@strSummary
								ELSE	''
						END,
			strBuyer = CASE WHEN CH.ysnBrokerage = 1 THEN EC.strEntityName ELSE CASE WHEN CH.intContractTypeId = 1 THEN @strCompanyName ELSE EY.strEntityName END END,
			strSeller = CASE WHEN CH.ysnBrokerage = 1 THEN EY.strEntityName ELSE CASE WHEN CH.intContractTypeId = 2 THEN @strCompanyName ELSE EY.strEntityName END END,
			blbHeaderLogo = dbo.[fnCTGetCompanyLogo]('Header', CH.intContractHeaderId),			
			blbFooterLogo = dbo.[fnCTGetCompanyFooterLogo]('Footer',  CH.intContractHeaderId),
			strLogoFooterType	= CASE WHEN dbo.[fnCTGetCompanyLocationCount](@intContractHeaderId) > 1 THEN 'Attachment' 
									   WHEN EXISTS (SELECT 1 FROM tblSMLogoPreferenceFooter where intCompanyLocationId = @intCompanyLocationId AND  ysnContract = 0 ) THEN 'Attachment' 
								  ELSE ISNULL(@strLogoType,'Attachment') END,
			strLogoType			= CASE WHEN dbo.[fnCTGetCompanyLocationCount](@intContractHeaderId) > 1 THEN 'Attachment' 
									   WHEN EXISTS (SELECT 1 FROM tblSMLogoPreference where intCompanyLocationId = @intCompanyLocationId AND  ysnContract = 0 ) THEN 'Attachment' 
								  ELSE ISNULL(@strLogoType,'Attachment') END,
			strCurrencyExchangeRate = CASE  WHEN CD.intInvoiceCurrencyId != ISNULL(CY.intMainCurrencyId,CD.intCurrencyId) THEN ISNULL((FY.strCurrency + '/' + TY.strCurrency), @strFinalCurrency)
											WHEN CD.intInvoiceCurrencyId = ISNULL(CY.intMainCurrencyId,CD.intCurrencyId) AND PF.dblFX = 1 THEN NULL
											ELSE NULL END,
			dblRate =  CASE WHEN CD.intInvoiceCurrencyId != ISNULL(CY.intMainCurrencyId,CD.intCurrencyId) THEN (case when isnull(@ysnEnableFXFieldInContractPricing,0) = 1 then PF.dblFX else CD.dblRate end)
							WHEN CD.intInvoiceCurrencyId = ISNULL(CY.intMainCurrencyId,CD.intCurrencyId) AND PF.dblFX = 1 THEN NULL
							ELSE NULL END,
			strFXFinalPrice = LTRIM(
									dbo.fnCTConvertQuantityToTargetCommodityUOM(FC.intCommodityUnitMeasureId,PF.intFinalPriceUOMId,PF.dblFinalPrice)*
									CASE WHEN  isnull(@ysnEnableFXFieldInContractPricing,0) = 1 
									 THEN ISNULL(PF.dblFX,1)
									ELSE dbo.fnCTGetCurrencyExchangeRate(CD.intContractDetailId,0)/CASE WHEN CY.ysnSubCurrency = 1 THEN ISNULL(CY.intCent,1) ELSE 1 END 
									END
								) +  ' ' + 
								CASE WHEN CD.intCurrencyId = TY.intCurrencyID THEN FY.strCurrency ELSE TY.strCurrency END + 
								' '+@per+' ' + isnull(rtrt5.strTranslation,FM.strUnitMeasure),
			strFXFinalPriceLabel = CASE WHEN CD.intCurrencyExchangeRateId IS NULL THEN NULL ELSE @FinalPrice END,
			strQuantityDesc = CASE 
								WHEN ISNULL(CH.ysnMultiplePriceFixation,0)=0 THEN
									CASE 
										WHEN UM.strUnitType='Quantity' THEN LTRIM(FLOOR(CD.dblQuantity)) + ' ' + @bags + '/ ' + isnull(rtrt2.strTranslation,UM.strUnitMeasure)+CASE WHEN CD.dblNetWeight IS NOT NULL THEN  ' (' ELSE '' END + ISNULL(LTRIM(FLOOR(CD.dblNetWeight)),'')+ ' '+ ISNULL(isnull(rtrt4.strTranslation,U7.strUnitMeasure),'') +CASE WHEN isnull(rtrt4.strTranslation,U7.strUnitMeasure) IS NOT NULL THEN   ')' ELSE '' END  
										ELSE ISNULL(LTRIM(dbo.fnRemoveTrailingZeroes(CD.dblNetWeight)),'')+ ' '+ ISNULL(isnull(rtrt4.strTranslation,U7.strUnitMeasure),'') 
									END
								ELSE
									CASE 
											WHEN UM.strUnitType='Quantity' AND @IntNoOFUniFormItemUOM=1 THEN LTRIM(dbo.fnRemoveTrailingZeroes(@TotalQuantity)) + ' ' + @bags + '/ ' + isnull(rtrt2.strTranslation,UM.strUnitMeasure)+CASE WHEN CD.dblNetWeight IS NOT NULL AND @IntNoOFUniFormNetWeightUOM=1 THEN  ' (' ELSE '' END + ISNULL(LTRIM(dbo.fnRemoveTrailingZeroes(@TotalNetQuantity)),'')+ ' '+ ISNULL(isnull(rtrt4.strTranslation,U7.strUnitMeasure),'') +CASE WHEN isnull(rtrt4.strTranslation,U7.strUnitMeasure) IS NOT NULL THEN   ')' ELSE '' END  
											ELSE CASE WHEN @IntNoOFUniFormNetWeightUOM=1 THEN ISNULL(LTRIM(dbo.fnRemoveTrailingZeroes(@TotalNetQuantity)),'')+ ' '+ ISNULL(isnull(rtrt4.strTranslation,U7.strUnitMeasure),'') ELSE '' END
									END
								END,
			strPeriodWithPosition = CONVERT(NVARCHAR(50),CD.dtmStartDate,106) + ' - ' + CONVERT(NVARCHAR(50),CD.dtmEndDate,106)+CASE WHEN PO.strPosition IS NOT NULL THEN  ' ('+PO.strPosition+') ' ELSE '' END,
			strLotsFixedLabel = CASE WHEN FLOOR((PF.dblTotalLots-PF.dblLotsFixed))=0 THEN '' ELSE @Lotstobefixed + ' :' END,
			intLotsUnFixed = LTRIM(CEILING((PF.dblTotalLots-PF.dblLotsFixed))),
			dblLotsUnFixed = dbo.fnCTChangeNumericScale(ISNULL(PF.dblTotalLots-PF.dblLotsFixed,0),1),
			strTotalDesc = LTRIM(CAST(ROUND(PF.dblPriceWORollArb,2) AS NUMERIC(18,2))) + ' ' + CY.strCurrency + ' '+@per+' ' + isnull(rtrt3.strTranslation,CM.strUnitMeasure) ,
			strDifferentialDesc = LTRIM(CAST(CD.dblBasis AS NUMERIC(18, 2))) + ' ' + CY.strCurrency + ' '+@per+' ' + isnull(rtrt3.strTranslation,CM.strUnitMeasure) ,			
			strFXFinalPriceLabelDesc = CASE WHEN CD.intCurrencyExchangeRateId IS NULL THEN NULL ELSE @FinalPrice + ' :' END,
			strFinalPriceDesc = LTRIM(CAST(ROUND(CD.dblCashPrice,2) AS NUMERIC(18,2))) + ' ' + CY.strCurrency + ' '+@per+' '+isnull(rtrt3.strTranslation,CM.strUnitMeasure) ,
			strCurrencyExchangeRateDesc = FY.strCurrency + '/' + TY.strCurrency+ ' :',
			dblRateDesc = dbo.fnRemoveTrailingZeroes(ROUND(CD.dblRate,2)),
			strFXFinalPriceDesc = LTRIM(
										dbo.fnRemoveTrailingZeroes(ROUND(dbo.fnCTConvertQuantityToTargetCommodityUOM(FC.intCommodityUnitMeasureId,PF.intFinalPriceUOMId,PF.dblFinalPrice)*
										dbo.fnCTGetCurrencyExchangeRate(CD.intContractDetailId,0)/CASE WHEN CY.ysnSubCurrency = 1 THEN ISNULL(CY.intCent,1) ELSE 1 END,2))
									) +  ' ' + 
									CASE WHEN CD.intCurrencyId = TY.intCurrencyID THEN FY.strCurrency ELSE TY.strCurrency END + 
									' '+@per+' ' + isnull(rtrt5.strTranslation,FM.strUnitMeasure),
			strLastModifiedUserSign = CASE WHEN @LastModifiedUserSign = '' THEN NULL ELSE @LastModifiedUserSign END,
			strTotalLots = dbo.fnRemoveTrailingZeroes(ISNULL(PF.dblTotalLots,0)),
			strMarketMonth = isnull(rtrt6.strTranslation,MA.strFutMarketName) +  ' '  + DATENAME(mm,MO.dtmFutureMonthsDate) + ' ' + DATENAME(yyyy,MO.dtmFutureMonthsDate),
			--strMarketMonth = isnull(rtrt6.strTranslation,MA.strFutMarketName) +  ' '  + isnull(rtrt1.strTranslation,MO.strFutureMonth),
			--strCompanyCityAndDate = ISNULL(@strCity + ', ', '') + CONVERT(NVARCHAR(20),GETDATE(),106),
			strCompanyCityAndDate = ISNULL(@strCity + ', ', '') + datename(dd,getdate()) + ' ' + isnull(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,datename(mm,getdate())),datename(mm,getdate())) + ' ' + datename(yyyy,getdate()),
			strCompanyName = @strCompanyName,
			strCPContract  = CH.strCPContract,
			intLanguageId = @intLaguageId,
			xmlParam = @xmlParam,
			CASE WHEN CH.intContractTypeId = 1 THEN isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Seller Reference'),'Seller Reference') ELSE isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Buyer Reference'),'Buyer Reference') END lblReference,
			ISNULL(@intReportLogoHeight,0) intReportLogoHeight,
			ISNULL(@intReportLogoWidth,0) intReportLogoWidth,
			dbo.fnCTGetBasisComponentString(CD.intContractDetailId,'HERSHEY')  AS strBasisComponent,
			CD.strERPPONumber,
			CD.dblRatio,
			CL.strContractCompanyName,
			CL.strContractPrintSignOff
		   ,dtmContractDate						= CH.dtmContractDate
		   ,CASE WHEN CH.intContractTypeId = 1 THEN @FirstApprovalSign ELSE @InterCompApprovalSign END AS BuyerSign
		   ,CASE WHEN CH.intContractTypeId = 2 THEN @FirstApprovalSign ELSE @InterCompApprovalSign END AS SellerSign
		   ,ysnEnableFXFieldInContractPricing = @ysnEnableFXFieldInContractPricing
		   ,strFixPriceLabel = (CASE WHEN SPC.strStatus = 'Fully Priced' THEN 'Final Contract Price'
									 WHEN SPC.strStatus = 'Partially Priced' THEN 'Average Fixed Price'
								ELSE 'Average Fixed Price' END)
			
	FROM	tblCTPriceFixation PF
	JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId			=	PF.intContractHeaderId
	CROSS	APPLY dbo.fnCTGetTopOneSequence(PF.intContractHeaderId,PF.intContractDetailId) SQ
	JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId			=	SQ.intContractDetailId
	JOIN	tblSMCompanyLocation		CL	ON	CL.intCompanyLocationId			=	CD.intCompanyLocationId
	JOIN	vyuCTEntity					EY	ON	EY.intEntityId					=	CH.intEntityId	AND
												EY.strEntityType				=	(CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)	
	LEFT JOIN	vyuCTEntity				EC	ON	EC.intEntityId					=	CH.intCounterPartyId  AND EC.strEntityType	=	'Customer'			
	LEFT JOIN tblICItem					IM	ON	IM.intItemId					=	CD.intItemId			
	LEFT JOIN tblICItemUOM				QM	ON	QM.intItemUOMId					=	CD.intItemUOMId			
	LEFT JOIN tblICUnitMeasure			UM	ON	UM.intUnitMeasureId				=	QM.intUnitMeasureId		
	LEFT JOIN tblCTPriceContract		PC	ON  PC.intPriceContractId			=	PF.intPriceContractId
	LEFT JOIN tblSMCurrency				CY	ON	CY.intCurrencyID				=	CD.intCurrencyId		
	LEFT JOIN tblICCommodityUnitMeasure	CU	ON	CU.intCommodityUnitMeasureId	=	PF.intFinalPriceUOMId	
	LEFT JOIN tblICUnitMeasure			CM	ON	CM.intUnitMeasureId				=	CU.intUnitMeasureId		
	LEFT JOIN tblICItemUOM				PM	ON	PM.intItemUOMId					=	CD.intPriceItemUOMId	
	LEFT JOIN tblICCommodityUnitMeasure	PU	ON	PU.intCommodityId				=	CH.intCommodityId		
			 									AND  PU.intUnitMeasureId		=	PM.intUnitMeasureId		
	LEFT JOIN tblSMCurrencyExchangeRate	ER	ON	ER.intCurrencyExchangeRateId	=	CD.intCurrencyExchangeRateId	
	LEFT JOIN tblSMCurrency				FY	ON	FY.intCurrencyID				=	ER.intFromCurrencyId	
	LEFT JOIN tblSMCurrency				TY	ON	TY.intCurrencyID				=	ER.intToCurrencyId		
	LEFT JOIN tblSMCurrency				IC	ON	IC.intCurrencyID				=	PC.intFinalCurrencyId
	LEFT JOIN tblICItemUOM				FU	ON	FU.intItemUOMId					=	CD.intFXPriceUOMId		
	LEFT JOIN tblICCommodityUnitMeasure	FC	ON	FC.intCommodityId				=	CH.intCommodityId		
			 									AND FC.intUnitMeasureId			=	FU.intUnitMeasureId		
	LEFT JOIN tblICItemUOM				WU	ON	WU.intItemUOMId					=	CD.intNetWeightUOMId	
	LEFT JOIN tblICUnitMeasure			U7	ON	U7.intUnitMeasureId				=	WU.intUnitMeasureId		
	LEFT JOIN tblICUnitMeasure			FM	ON	FM.intUnitMeasureId				=	FC.intUnitMeasureId		
	LEFT JOIN tblCTPosition				PO	ON	PO.intPositionId				=	CH.intPositionId		
	LEFT JOIN tblRKFutureMarket			MA	ON	MA.intFutureMarketId			=	CD.intFutureMarketId	
	LEFT JOIN tblRKFuturesMonth			MO	ON	MO.intFutureMonthId				=	CD.intFutureMonthId		
	LEFT JOIN tblSMCurrency				IY	ON	IY.intCurrencyID				=	CD.intInvoiceCurrencyId	
	LEFT JOIN tblICItemUOM				FO	ON	FO.intItemUOMId					=	CD.intFXPriceUOMId		
	LEFT JOIN tblICUnitMeasure			FN	ON	FN.intUnitMeasureId				=	FO.intUnitMeasureId		

	LEFT JOIN tblSMScreen				rts   ON rts.strNamespace = 'Inventory.view.Item'
	LEFT JOIN tblSMTransaction			rtt   ON rtt.intScreenId = rts.intScreenId and rtt.intRecordId = IM.intItemId
	LEFT JOIN tblSMReportTranslation	rtrt  ON rtrt.intLanguageId = @intLaguageId and rtrt.intTransactionId = rtt.intTransactionId and rtrt.strFieldName = 'Description'
	
	LEFT JOIN tblSMScreen				rts1  ON rts1.strNamespace = 'RiskManagement.view.FuturesTradingMonths'
	LEFT JOIN tblSMTransaction			rtt1  ON rtt1.intScreenId = rts1.intScreenId and rtt1.intRecordId = MO.intFutureMonthId
	LEFT JOIN tblSMReportTranslation	rtrt1 ON rtrt1.intLanguageId = @intLaguageId and rtrt1.intTransactionId = rtt1.intTransactionId and rtrt1.strFieldName = 'Future Trading Month'
	
	LEFT JOIN tblSMScreen				rts2  ON rts2.strNamespace = 'Inventory.view.ReportTranslation'
	LEFT JOIN tblSMTransaction			rtt2  ON rtt2.intScreenId = rts2.intScreenId and rtt2.intRecordId = UM.intUnitMeasureId
	LEFT JOIN tblSMReportTranslation	rtrt2 ON rtrt2.intLanguageId = @intLaguageId and rtrt2.intTransactionId = rtt2.intTransactionId and rtrt2.strFieldName = 'Name'
	
	LEFT JOIN tblSMScreen				rts3  ON rts3.strNamespace = 'Inventory.view.ReportTranslation'
	LEFT JOIN tblSMTransaction			rtt3  ON rtt3.intScreenId = rts3.intScreenId and rtt3.intRecordId = CM.intUnitMeasureId
	LEFT JOIN tblSMReportTranslation	rtrt3 ON rtrt3.intLanguageId = @intLaguageId and rtrt3.intTransactionId = rtt3.intTransactionId and rtrt3.strFieldName = 'Name'
	
	LEFT JOIN tblSMScreen				rts4  ON rts4.strNamespace = 'Inventory.view.ReportTranslation'
	LEFT JOIN tblSMTransaction			rtt4  ON rtt4.intScreenId = rts4.intScreenId and rtt4.intRecordId = U7.intUnitMeasureId
	LEFT JOIN tblSMReportTranslation	rtrt4 ON rtrt4.intLanguageId = @intLaguageId and rtrt4.intTransactionId = rtt4.intTransactionId and rtrt4.strFieldName = 'Name'
	
	LEFT JOIN tblSMScreen				rts5  ON rts5.strNamespace = 'Inventory.view.ReportTranslation'
	LEFT JOIN tblSMTransaction			rtt5  ON rtt5.intScreenId = rts5.intScreenId and rtt5.intRecordId = FM.intUnitMeasureId
	LEFT JOIN tblSMReportTranslation	rtrt5 ON rtrt5.intLanguageId = @intLaguageId and rtrt5.intTransactionId = rtt5.intTransactionId and rtrt5.strFieldName = 'Name'
	
	LEFT JOIN tblSMScreen				rts6  ON rts6.strNamespace = 'RiskManagement.view.FuturesMarket'
	LEFT JOIN tblSMTransaction			rtt6  ON rtt6.intScreenId = rts6.intScreenId and rtt6.intRecordId = MA.intFutureMarketId
	LEFT JOIN tblSMReportTranslation	rtrt6 ON rtrt6.intLanguageId = @intLaguageId and rtrt6.intTransactionId = rtt6.intTransactionId and rtrt6.strFieldName = 'Market Name'

	LEFT JOIN tblSMCountry				rtc10 ON lower(rtrim(ltrim(rtc10.strCountry))) = lower(rtrim(ltrim(EY.strEntityCountry)))
	LEFT JOIN tblSMCountry				rtc12 ON lower(rtrim(ltrim(rtc12.strCountry))) = lower(rtrim(ltrim(EC.strEntityCountry)))
	LEFT JOIN vyuCTPriceContractStatus	SPC   ON  SPC.intContractHeaderId = PF.intContractHeaderId AND SPC.intPriceFixationId = @intPriceFixationId
	WHERE	PF.intPriceFixationId	=	@intPriceFixationId
	

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO