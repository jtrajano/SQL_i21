CREATE PROCEDURE [dbo].[uspCTReportPriceConfirmation]
	@strPriceFixationID NVARCHAR(MAX) = NULL  
AS

BEGIN TRY
	
	DECLARE @ErrMsg						NVARCHAR(MAX)		 
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
			@intTransactionId			INT			   

	SELECT TOP 1 @intPriceFixationId = intPriceFixationId FROM tblCTPriceFixationDetail WHERE intPriceFixationDetailId IN (SELECT * FROM dbo.fnSplitString(@strPriceFixationID,',') )
    
	SELECT @intLaguageId = intLanguageId FROM tblSMLanguage WHERE strLanguage = 'English'

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
	
	SELECT	@intLastModifiedUserId	=	ISNULL(intLastModifiedById,intCreatedById) 
	FROM	tblCTPriceContract PC
	JOIN	tblCTPriceFixation PF	ON	PF.intPriceContractId	=	PC.intPriceContractId 
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
	LEFT JOIN tblSMCountry				rtc9 on lower(rtrim(ltrim(rtc9.strCountry))) = lower(rtrim(ltrim(tblSMCompanySetup.strCountry)))
	LEFT JOIN tblSMScreen				rts9 on rts9.strNamespace = 'i21.view.Country'
	LEFT JOIN tblSMTransaction			rtt9 on rtt9.intScreenId = rts9.intScreenId and rtt9.intRecordId = rtc9.intCountryID
	LEFT JOIN tblSMReportTranslation	rtrt9 on rtrt9.intLanguageId = @intLaguageId and rtrt9.intTransactionId = rtt9.intTransactionId and rtrt9.strFieldName = 'Country'

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

	SELECT	DISTINCT 
			PF.intPriceFixationId,
			PF.intContractHeaderId,
			blbHeaderLogo = dbo.fnSMGetCompanyLogo('Header'),
			blbFooterLogo = dbo.fnSMGetCompanyLogo('Footer'),
			strBuyerAddress	= CASE 
								WHEN CH.intContractTypeId = 2 THEN --Customer
									LTRIM(RTRIM(EC1.strEntityName)) + ', ' + CHAR(13)+CHAR(10) +
									ISNULL(LTRIM(RTRIM(EC1.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
									ISNULL(LTRIM(RTRIM(EC1.strEntityCity)),'') + 
									ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC1.strEntityState)) = '' THEN NULL ELSE LTRIM(RTRIM(EC1.strEntityState)) END,'') + 
									ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC1.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EC1.strEntityZipCode)) END,'') + 
									ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC1.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EC1.strEntityCountry)) END,'')							
								ELSE -- Seller (Vendor)
									LTRIM(RTRIM(@strCompanyName)) + ', ' + CHAR(13)+CHAR(10) +
									ISNULL(LTRIM(RTRIM(@strAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
									ISNULL(LTRIM(RTRIM(@strCity)),'') + 
									ISNULL(', '+CASE WHEN LTRIM(RTRIM(@strState)) = '' THEN NULL ELSE LTRIM(RTRIM(@strState)) END,'') + 
									ISNULL(', '+CASE WHEN LTRIM(RTRIM(@strZip)) = '' THEN NULL ELSE LTRIM(RTRIM(@strZip)) END,'') + 
									ISNULL(', '+CASE WHEN LTRIM(RTRIM(@strCounty)) = '' THEN NULL ELSE LTRIM(RTRIM(@strCountry)) END,'')
								END,
			strSellerAddress = CASE 
								WHEN CH.intContractTypeId = 2 THEN --Customer
									LTRIM(RTRIM(@strCompanyName)) + ', ' + CHAR(13)+CHAR(10) +
									ISNULL(LTRIM(RTRIM(@strAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
									ISNULL(LTRIM(RTRIM(@strCity)),'') + 
									ISNULL(', '+CASE WHEN LTRIM(RTRIM(@strState)) = '' THEN NULL ELSE LTRIM(RTRIM(@strState)) END,'') + 
									ISNULL(', '+CASE WHEN LTRIM(RTRIM(@strZip)) = '' THEN NULL ELSE LTRIM(RTRIM(@strZip)) END,'') + 
									ISNULL(', '+CASE WHEN LTRIM(RTRIM(@strCounty)) = '' THEN NULL ELSE LTRIM(RTRIM(@strCountry)) END,'')					
								ELSE -- Seller (Vendor)
									LTRIM(RTRIM(EY.strEntityName)) + ', ' + CHAR(13)+CHAR(10) +
									ISNULL(LTRIM(RTRIM(EY.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
									ISNULL(LTRIM(RTRIM(EY.strEntityCity)),'') + 
									ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityState)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityState)) END,'') + 
									ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityZipCode)) END,'') + 
									ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityCountry)) END,'')
								END,
			CH.strContractNumber,
			CD.intContractSeq,
			CH.strCustomerContract,
			IM.strItemNo,
			strQuantity = dbo.fnRemoveTrailingZeroes(CD.dblQuantity)+ ' ' + ISNULL(rtrt2.strTranslation,UM.strUnitMeasure) ,
			strZFSQuantity = dbo.fnCTFormatNumber(CD.dblQuantity,'#,0.00####') + ' ' + ISNULL(rtrt2.strTranslation,UM.strUnitMeasure),
			strPeriod = DATENAME(dd,CD.dtmStartDate) + ' ' + ISNULL(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,DATENAME(mm,CD.dtmStartDate)),DATENAME(mm,CD.dtmStartDate)) + ' ' + DATENAME(yyyy,CD.dtmStartDate) + ' - ' + DATENAME(dd,CD.dtmEndDate) + ' ' + ISNULL(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,DATENAME(mm,CD.dtmEndDate)),DATENAME(mm,CD.dtmEndDate)) + ' ' + DATENAME(yyyy,CD.dtmEndDate),
			strAccountNumber = EY.strEntityNumber,--CASE WHEN CH.intContractTypeId = 1 THEN EC.strEntityNumber ELSE EY.strEntityNumber END,
			SP.strEntityName as strSalesperson,
			CDV.strLocationName,
			strStatus = CASE
							WHEN ISNULL(PF.[dblTotalLots],0) - ISNULL(PF.[dblLotsFixed],0) = 0 THEN	
								@strStatus1
							ELSE
								@strStatus2
						END,
			PD.dtmFixationDate,
			PD.intNumber as intPricingNumber,
			CV.strCommodityCode as strCommodity,
			CD.dblQuantity,
			strZFSPricedQuantity = dbo.fnCTFormatNumber(PD.dblQuantity,'#,0.00####'),
			ISNULL(rtrt2.strTranslation,CM.strSymbol) as strUOM,
			CD.dblBasis,
			strZFSBasis = dbo.fnCTFormatNumber(PD.dblBasis,'#,0.00####'),
			LTRIM(CAST(ROUND(PD.dblFutures,2) AS NUMERIC(18,2))) as dblFuturePrice,
			dbo.fnCTFormatNumber(PD.dblFutures,'#,0.0000##') as strZFSFuturePrice,
			LTRIM(CAST(ROUND(ISNULL(PD.dblFutures,0) - ISNULL(CD.dblBasis,0),2) AS NUMERIC(18,2))) + ' ' + CY.strCurrency + ' '+@per+' ' + ISNULL(rtrt2.strTranslation,CM.strUnitMeasure) strCashPrice,
			dbo.fnCTFormatNumber(PD.dblCashPrice,'#,0.0000##') + ' ' + CY.strCurrency + ' '+@per+' ' + ISNULL(rtrt2.strTranslation,CM.strUnitMeasure) strZFSCashPrice,
			MO.strFutureMonth,
			CV.strFreightTerm,
			PD.strNotes,
			strBuyer = CASE WHEN CH.ysnBrokerage = 1 THEN EC.strEntityName ELSE CASE WHEN CH.intContractTypeId = 1 THEN @strCompanyName ELSE EY.strEntityName END END,
			strSeller = CASE WHEN CH.ysnBrokerage = 1 THEN EY.strEntityName ELSE CASE WHEN CH.intContractTypeId = 2 THEN @strCompanyName ELSE EY.strEntityName END END,
			strTitle = (case when CH.intContractTypeId = 1 then 'Purchase' else 'Sale' end) + ' Contract Pricing Confirmation',
			strEntityLabel = (case when CH.intContractTypeId = 1 then 'Vendor' else 'Customer' end) + ' Ref'


	FROM	tblCTPriceFixation			PF
	JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId			=	PF.intContractHeaderId
	JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId			=	PF.intContractDetailId
	JOIN	tblSMCompanyLocation		CL	ON	CL.intCompanyLocationId			=	CD.intCompanyLocationId
	JOIN	vyuCTEntity					EY	ON	EY.intEntityId					=	CH.intEntityId
											--AND EY.strEntityType				=	(CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)	LEFT
	LEFT JOIN	vyuCTEntity					EC	ON	EC.intEntityId					=	CH.intCounterPartyId  
												AND EC.strEntityType				=	'Customer'			LEFT
	JOIN	vyuCTEntity					EC1	ON	EC1.intEntityId					=	CH.intEntityId			LEFT
	JOIN	vyuCTEntity					SP	ON	SP.intEntityId					=	CH.intSalespersonId		LEFT
	JOIN	tblICItem					IM	ON	IM.intItemId					=	CD.intItemId			LEFT
	JOIN	tblICItemUOM				QM	ON	QM.intItemUOMId					=	CD.intItemUOMId			LEFT
	JOIN	tblICUnitMeasure			UM	ON	UM.intUnitMeasureId				=	QM.intUnitMeasureId		LEFT	
	JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID				=	CD.intCurrencyId		LEFT
	JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityUnitMeasureId	=	PF.intFinalPriceUOMId	LEFT	
	JOIN	tblICUnitMeasure			CM	ON	CM.intUnitMeasureId				=	CU.intUnitMeasureId		LEFT	
	JOIN	tblRKFuturesMonth			MO	ON	MO.intFutureMonthId				=	CD.intFutureMonthId		LEFT

	JOIN	vyuCTContractHeaderView		CV	ON	CV.intContractHeaderId			=	PF.intContractHeaderId	LEFT
	JOIN	vyuCTContractDetailView		CDV	ON	CDV.intContractHeaderId			=	PF.intContractHeaderId	LEFT
	JOIN	tblCTPriceFixationDetail	PD	ON	PD.intPriceFixationId			=	PF.intPriceFixationId	


	LEFT JOIN tblSMScreen				rts on rts.strNamespace = 'Inventory.view.Item'
	LEFT JOIN tblSMTransaction			rtt on rtt.intScreenId = rts.intScreenId and rtt.intRecordId = IM.intItemId
	LEFT JOIN tblSMReportTranslation	rtrt on rtrt.intLanguageId = @intLaguageId and rtrt.intTransactionId = rtt.intTransactionId and rtrt.strFieldName = 'Description'

	LEFT JOIN tblSMScreen				rts2 on rts2.strNamespace = 'Inventory.view.ReportTranslation'
	LEFT JOIN tblSMTransaction			rtt2 on rtt2.intScreenId = rts2.intScreenId and rtt2.intRecordId = UM.intUnitMeasureId
	LEFT JOIN tblSMReportTranslation	rtrt2 on rtrt2.intLanguageId = @intLaguageId and rtrt2.intTransactionId = rtt2.intTransactionId and rtrt2.strFieldName = 'Name'

	WHERE	PF.intPriceFixationId	=	@intPriceFixationId AND intPriceFixationDetailId IN (SELECT * FROM dbo.fnSplitString(@strPriceFixationID,',') )
	

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO