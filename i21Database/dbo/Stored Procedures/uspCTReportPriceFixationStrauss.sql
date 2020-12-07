﻿CREATE PROCEDURE [dbo].[uspCTReportPriceFixationStrauss]
	@xmlParam NVARCHAR(MAX) = NULL  
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	 

	DECLARE @strCompanyName				NVARCHAR(500),
			@intPriceFixationId			INT,
			@intPriceContractId			INT,
			@intContractHeaderId		INT,
			@intContractDetailId		INT,
			@intReportLogoHeight		INT,
			@intReportLogoWidth			INT,
			@intScreenId				INT,
			@FirstApprovalId			INT,
			@FirstApprovalSign			VARBINARY(MAX),
			@InterCompApprovalSign		VARBINARY(MAX),	
   			@InterCompSubmitterSign  VARBINARY(MAX),  
			@xmlDocumentId				INT,
			@intTransactionId			INT,
			@PreviousSubmitterId		INT,
			@PreviousSubmitterSign 		VARBINARY(MAX)

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

	SELECT  @intPriceContractId		=	intPriceContractId, 
			@intContractHeaderId	=	intContractHeaderId,
			@intContractDetailId	=	intContractDetailId 
	FROM	tblCTPriceFixation 
	WHERE	intPriceFixationId=@intPriceFixationId
	
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

	SELECT	TOP 1 @FirstApprovalId=intApproverId, @PreviousSubmitterId = intSubmittedById
	FROM	tblSMApproval 
	WHERE	intTransactionId=@intTransactionId
	AND		strStatus='Approved' 
	ORDER BY intApprovalId

	SELECT	@FirstApprovalSign =  Sig.blbDetail 
	FROM	tblSMSignature Sig  WITH (NOLOCK)
	JOIN    tblEMEntitySignature ES ON Sig.intSignatureId = ES.intElectronicSignatureId
	WHERE	Sig.intEntityId=@FirstApprovalId

	SELECT	@PreviousSubmitterSign =  Sig.blbDetail 
	FROM	tblSMSignature Sig  WITH (NOLOCK)
	JOIN    tblEMEntitySignature ES ON Sig.intSignatureId = ES.intElectronicSignatureId
	WHERE	Sig.intEntityId=@PreviousSubmitterId
	
	SELECT	TOP 1 @InterCompApprovalSign =Sig.blbDetail 
	FROM	tblCTIntrCompApproval	IA
	JOIN	tblSMUserSecurity		US	ON	US.strUserName	=	IA.strUserName	
	JOIN	tblSMSignature			Sig	ON	US.intEntityId	=	Sig.intEntityId
	JOIN    tblEMEntitySignature	ES	ON	Sig.intSignatureId = ES.intElectronicSignatureId
	WHERE	IA.intContractHeaderId	=	@intContractHeaderId
	AND		IA.strScreen	=	'Price Contract'
	 AND IA.ysnApproval = 1
	   
	 SELECT TOP 1 @InterCompSubmitterSign =Sig.blbDetail   
	 FROM tblCTIntrCompApproval IA  
	 JOIN tblSMUserSecurity  US ON US.strUserName = IA.strUserName   
	 JOIN tblSMSignature   Sig ON US.intEntityId = Sig.intEntityId  
	 JOIN    tblEMEntitySignature ES ON Sig.intSignatureId = ES.intElectronicSignatureId  
	 WHERE IA.intContractHeaderId = @intContractHeaderId  
	 AND  IA.strScreen = 'Price Contract'  
	 AND IA.ysnApproval = 0

	SELECT	@strCompanyName	=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) = '' THEN NULL ELSE LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) END
	FROM	tblSMCompanySetup

	SELECT	 DISTINCT
			xmlParam = @xmlParam,
			PF.intPriceFixationId,
			blbHeaderLogo = dbo.fnSMGetCompanyLogo('Header'),
			blbFooterLogo = dbo.fnSMGetCompanyLogo('Footer'),
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
			CH.strContractNumber,
			CH.strCustomerContract,
			strDescription = IM.strDescription,
			strQuantity = dbo.fnRemoveTrailingZeroes(CD.dblQuantity)+ ' ' + UM.strUnitMeasure,
			strPeriod = datename(dd,CD.dtmStartDate)
						+ ' '
						+ datename(mm,CD.dtmStartDate)
						+ ' '
						+ datename(yyyy,CD.dtmStartDate)
						+ ' - '
						+ datename(dd,CD.dtmEndDate)
						+ ' '
						+ datename(mm,CD.dtmEndDate)
						+ ' '
						+ datename(yyyy,CD.dtmEndDate),
			strStatus = CASE	WHEN	ISNULL(PF.[dblTotalLots],0) - ISNULL(PF.[dblLotsFixed],0) = 0 
								THEN	'This confirms that the above contract has been priced as follows:'
								ELSE	'This confirms that the above contract has been partially priced as follows:'
						END,
			dblLotsUnFixed = dbo.fnCTChangeNumericScale(ISNULL(PF.dblTotalLots-PF.dblLotsFixed,0),1),
			strTotal = dbo.fnCTChangeNumericScale(PF.dblPriceWORollArb,2) + ' ' + CY.strDescription + ' per ' + CM.strUnitMeasure,
			strDifferential = dbo.fnCTChangeNumericScale(CAST(dbo.fnCTConvertQuantityToTargetCommodityUOM(PF.intFinalPriceUOMId,PU.intCommodityUnitMeasureId, PF.dblOriginalBasis) AS NUMERIC(18, 6)),2) + ' ' + CY.strDescription + ' per ' + CM.strUnitMeasure,
			strAdditionalCost = dbo.fnRemoveTrailingZeroes(PF.dblAdditionalCost) + ' ' + CY.strCurrency + ' per ' + CM.strUnitMeasure,
			strFinalPrice =	dbo.fnCTChangeNumericScale(PF.dblFinalPrice,2) + ' ' + CY.strDescription + ' per ' + CM.strUnitMeasure,
			strSummary = CASE	WHEN	ISNULL(PF.[dblTotalLots],0) - ISNULL(PF.[dblLotsFixed],0) = 0 
								THEN	'All lot(s) are fixed.'
								ELSE	''
						END,
			strCurrencyExchangeRate = FY.strCurrency + '/' + TY.strCurrency,
			CD.dblRate,
			strFXFinalPriceLabel = CASE WHEN CD.intCurrencyExchangeRateId IS NULL THEN NULL ELSE 'Final Price' END,
			strFXFinalPrice = LTRIM(
									dbo.fnCTConvertQuantityToTargetCommodityUOM(FC.intCommodityUnitMeasureId,PF.intFinalPriceUOMId,PF.dblFinalPrice)
									*
									dbo.fnCTGetCurrencyExchangeRate(CD.intContractDetailId,0)/CASE WHEN CY.ysnSubCurrency = 1 THEN ISNULL(CY.intCent,1) ELSE 1 END
								)
								+  ' '
								+ CASE WHEN CD.intCurrencyId = TY.intCurrencyID THEN FY.strCurrency ELSE TY.strCurrency END
								+ ' per ' + FM.strUnitMeasure,
			strBuyer = CASE WHEN CH.ysnBrokerage = 1 THEN EC.strEntityName ELSE CASE WHEN CH.intContractTypeId = 1 THEN @strCompanyName ELSE EY.strEntityName END END,
			strSeller = CASE WHEN CH.ysnBrokerage = 1 THEN EY.strEntityName ELSE CASE WHEN CH.intContractTypeId = 2 THEN @strCompanyName ELSE EY.strEntityName END END,
			CounterSubmitterSign = @InterCompSubmitterSign,
			SubmitterSign = @PreviousSubmitterSign,
		    BuyerSign = CASE WHEN CH.intContractTypeId = 2 THEN @FirstApprovalSign ELSE @InterCompApprovalSign END,			
		    SellerSign = CASE WHEN CH.intContractTypeId = 1 THEN @FirstApprovalSign ELSE @InterCompApprovalSign END,
			intReportLogoHeight = ISNULL(@intReportLogoHeight,0),
			intReportLogoWidth = ISNULL(@intReportLogoWidth,0)

	FROM	tblCTPriceFixation			PF
	JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId			=	PF.intContractHeaderId
	cross apply	(	select top 1 cd1.*
					from tblCTContractDetail cd1
					where cd1.intContractHeaderId = 
													case
													when isnull(@intContractDetailId,0) = 0
													then @intContractHeaderId
													else cd1.intContractHeaderId
													end
						  and cd1.intContractDetailId =
						  							case
						  							when isnull(@intContractDetailId,0) = 0
						  							then cd1.intContractDetailId
						  							else @intContractDetailId 
						  							end
				) CD
	--CROSS	APPLY dbo.fnCTGetTopOneSequence(PF.intContractHeaderId,PF.intContractDetailId) SQ
	--JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId			=	SQ.intContractDetailId
	JOIN	tblSMCompanyLocation		CL	ON	CL.intCompanyLocationId			=	CD.intCompanyLocationId
	JOIN	vyuCTEntity					EY	ON	EY.intEntityId					=	CH.intEntityId	AND
												EY.strEntityType				=	(CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)	LEFT
	JOIN	vyuCTEntity					EC	ON	EC.intEntityId					=	CH.intCounterPartyId  
												AND EC.strEntityType				=	'Customer'			LEFT
	JOIN	tblICItem					IM	ON	IM.intItemId					=	CD.intItemId			LEFT
	JOIN	tblICItemUOM				QM	ON	QM.intItemUOMId					=	CD.intItemUOMId			LEFT
	JOIN	tblICUnitMeasure			UM	ON	UM.intUnitMeasureId				=	QM.intUnitMeasureId		LEFT	
	JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID				=	CD.intCurrencyId		LEFT
	JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityUnitMeasureId	=	PF.intFinalPriceUOMId	LEFT	
	JOIN	tblICUnitMeasure			CM	ON	CM.intUnitMeasureId				=	CU.intUnitMeasureId		LEFT	
	JOIN	tblICItemUOM				PM	ON	PM.intItemUOMId					=	CD.intPriceItemUOMId	LEFT
	JOIN	tblICCommodityUnitMeasure	PU	ON	PU.intCommodityId				=	CH.intCommodityId		AND PU.intUnitMeasureId				=	PM.intUnitMeasureId		LEFT
	JOIN	tblSMCurrencyExchangeRate	ER	ON	ER.intCurrencyExchangeRateId	=	CD.intCurrencyExchangeRateId	LEFT	
	JOIN	tblSMCurrency				FY	ON	FY.intCurrencyID				=	ER.intFromCurrencyId	LEFT					
	JOIN	tblSMCurrency				TY	ON	TY.intCurrencyID				=	ER.intToCurrencyId		LEFT	
	JOIN	tblICItemUOM				FU	ON	FU.intItemUOMId					=	CD.intFXPriceUOMId		LEFT
	JOIN	tblICCommodityUnitMeasure	FC	ON	FC.intCommodityId				=	CH.intCommodityId		AND FC.intUnitMeasureId				=	FU.intUnitMeasureId		LEFT	
	JOIN	tblICUnitMeasure			FM	ON	FM.intUnitMeasureId				=	FC.intUnitMeasureId

	WHERE	PF.intPriceFixationId	=	@intPriceFixationId
	

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO