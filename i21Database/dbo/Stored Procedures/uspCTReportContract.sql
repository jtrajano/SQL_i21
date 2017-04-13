CREATE PROCEDURE [dbo].[uspCTReportContract]
	
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
			@intContractHeaderId	INT,
			@xmlDocumentId			INT,
			@strContractDocuments	NVARCHAR(MAX),
			@strContractConditions	NVARCHAR(MAX),
			@intScreenId			INT,
			@intTransactionId       INT,
			@strApprovalText		NVARCHAR(MAX),
			@FirstApprovalId		INT,
			@SecondApprovalId       INT,
			@FirstApprovalSign      VARBINARY(MAX),
			@SecondApprovalSign     VARBINARY(MAX),
			@IsFullApproved         BIT = 0,
			@ysnFairtrade			BIT = 0,
			@ysnFeedOnApproval		BIT = 0,
			@strCommodityCode		NVARCHAR(MAX),
			@dtmApproved			DATETIME,
			@ysnPrinted				BIT,

			@intLastApprovedContractId INT,
			@intPrevApprovedContractId INT,
			@strAmendedColumns NVARCHAR(MAX),
			@intContractDetailId INT			

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
    
	SELECT	@intContractHeaderId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intContractHeaderId'
	
	SELECT @intScreenId=intScreenId FROM tblSMScreen WHERE ysnApproval=1 AND strNamespace='ContractManagement.view.Contract'--ContractManagement.view.ContractAmendment
	SELECT @intTransactionId=intTransactionId FROM tblSMTransaction WHERE intScreenId=@intScreenId AND intRecordId=@intContractHeaderId

	SELECT	@strCommodityCode	=	CM.strCommodityCode,
			@ysnPrinted			=	CH.ysnPrinted
	FROM	tblCTContractHeader CH
	JOIN	tblICCommodity		CM	ON	CM.intCommodityId		=	CH.intCommodityId
	WHERE	CH.intContractHeaderId = @intContractHeaderId

	IF (SELECT COUNT(1) FROM tblSMApproval WHERE intTransactionId=@intTransactionId AND strStatus='Approved') >1	
	BEGIN	
		SET @strApprovalText='This document concerns the Confirmed Agreement between Parties. Please sign in twofold and return to KDE as follows: one PDF-copy of the signed original by e-mail.'	
		SET @IsFullApproved=1    
	END
	ELSE
		SET @strApprovalText='This document concerns an unconfirmed agreement. Please check this unconfirmed agreement and let us know if you find any discrepancies; If no notification of discrepancy has been received by us from you within 24 hours after receipt of this document, this unconfirmed agreement becomes confirmed from Supplier side. Once confirmed from Supplier side, KDE will check the document on discrepancies. If no discrepancies are found, a confirmed agreement will be issued by KDE, replacing the unconfirmed agreement. A confirmed agreement will only be binding for KDE once it has been signed by the authorized KDE representatives. Upon receipt of the confirmed agreement signed by KDE, Supplier shall sign the confirmed agreement and return it to KDE'

	IF @strCommodityCode = 'Tea'
		SET @strApprovalText = NULL

    SELECT TOP 1 @FirstApprovalId=intApproverId FROM tblSMApproval WHERE intTransactionId=@intTransactionId AND strStatus='Approved' ORDER BY intApprovalId
	SELECT TOP 1 @SecondApprovalId=intApproverId FROM tblSMApproval WHERE intTransactionId=@intTransactionId AND strStatus='Approved' AND intApproverId <> @FirstApprovalId ORDER BY intApprovalId

	SELECT @FirstApprovalSign =  Sig.blbDetail 
								 FROM tblSMSignature Sig 
								 --JOIN tblEMEntitySignature ESig ON ESig.intElectronicSignatureId=Sig.intSignatureId 
								 WHERE Sig.intEntityId=@FirstApprovalId

	SELECT @SecondApprovalSign =Sig.blbDetail 
								FROM tblSMSignature Sig 
								--JOIN tblEMEntitySignature ESig ON ESig.intElectronicSignatureId=Sig.intSignatureId 
								WHERE Sig.intEntityId=@SecondApprovalId

	SELECT	@strCompanyName	=	CASE WHEN LTRIM(RTRIM(strCompanyName)) = '' THEN NULL ELSE LTRIM(RTRIM(strCompanyName)) END,
			@strAddress		=	CASE WHEN LTRIM(RTRIM(strAddress)) = '' THEN NULL ELSE LTRIM(RTRIM(strAddress)) END,
			@strCounty		=	CASE WHEN LTRIM(RTRIM(strCounty)) = '' THEN NULL ELSE LTRIM(RTRIM(strCounty)) END,
			@strCity		=	CASE WHEN LTRIM(RTRIM(strCity)) = '' THEN NULL ELSE LTRIM(RTRIM(strCity)) END,
			@strState		=	CASE WHEN LTRIM(RTRIM(strState)) = '' THEN NULL ELSE LTRIM(RTRIM(strState)) END,
			@strZip			=	CASE WHEN LTRIM(RTRIM(strZip)) = '' THEN NULL ELSE LTRIM(RTRIM(strZip)) END,
			@strCountry		=	CASE WHEN LTRIM(RTRIM(strCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(strCountry)) END
	FROM	tblSMCompanySetup

	SELECT	@strContractDocuments = STUFF(								
			   (SELECT			
					CHAR(13)+CHAR(10) + DM.strDocumentName	
					FROM tblCTContractDocument CD	
					JOIN tblICDocument DM ON DM.intDocumentId = CD.intDocumentId	
					WHERE CD.intContractHeaderId=CH.intContractHeaderId	
					ORDER BY DM.strDocumentName		
					FOR XML PATH(''), TYPE				
			   ).value('.','varchar(max)')
			   ,1,2, ''						
		  )  				
	FROM tblCTContractHeader CH						
	WHERE CH.intContractHeaderId = @intContractHeaderId

	SELECT	@strContractConditions = STUFF(								
			(
					SELECT	CHAR(13)+CHAR(10) + DM.strConditionDesc
					FROM	tblCTContractCondition	CD	
					JOIN	tblCTCondition			DM	ON DM.intConditionId = CD.intConditionId	
					WHERE	CD.intContractHeaderId	=	CH.intContractHeaderId	
					ORDER BY DM.strConditionName		
					FOR XML PATH(''), TYPE				
			   ).value('.','varchar(max)')
			   ,1,2, ''						
			)  				
	FROM	tblCTContractHeader CH						
	WHERE	CH.intContractHeaderId = @intContractHeaderId

	IF EXISTS
	(
				SELECT	TOP 1 1 
				FROM	tblCTContractCertification	CC
				JOIN	tblCTContractDetail			CH	ON	CC.intContractDetailId	=	CH.intContractDetailId
				JOIN	tblICCertification			CF	ON	CF.intCertificationId	=	CC.intCertificationId	
				WHERE	UPPER(CF.strCertificationName) = 'FAIRTRADE' AND CH.intContractHeaderId = @intContractHeaderId
	)
	BEGIN
		SET @ysnFairtrade = 1
	END

	SELECT TOP 1 @intLastApprovedContractId =  intApprovedContractId,@intContractDetailId = intContractDetailId,@dtmApproved = dtmApproved 
    FROM   tblCTApprovedContract 
    WHERE  intContractHeaderId = @intContractHeaderId AND strApprovalType IN ('Contract Amendment ') AND ysnApproved = 1
    ORDER BY intApprovedContractId DESC

	SELECT TOP 1 @intPrevApprovedContractId =  intApprovedContractId
    FROM   tblCTApprovedContract 
    WHERE  intContractDetailId = @intContractDetailId AND intApprovedContractId < @intLastApprovedContractId AND ysnApproved = 1
    ORDER BY intApprovedContractId DESC

	IF @intPrevApprovedContractId IS NOT NULL AND @intLastApprovedContractId IS NOT NULL
	BEGIN
		EXEC uspCTCompareRecords 'tblCTApprovedContract', @intPrevApprovedContractId, @intLastApprovedContractId,'intApprovedById,dtmApproved,
		intContractBasisId,dtmPlannedAvailabilityDate,strOrigin,dblNetWeight,intNetWeightUOMId,
		intSubLocationId,intStorageLocationId,intPurchasingGroupId,strApprovalType,strVendorLotID,ysnApproved,intCertificationId,intLoadingPortId', @strAmendedColumns OUTPUT
	END

	IF @strAmendedColumns IS NULL SELECT @strAmendedColumns = ''
	IF ISNULL(@ysnPrinted,0) = 0 SELECT @strAmendedColumns = ''
	 
	SELECT	CH.intContractHeaderId,

			TP.strContractType + ' Contract:- ' + CH.strContractNumber AS strCaption,
			@strCompanyName + ' - '+TP.strContractType+' Contract' AS strTeaCaption,
			TP.strContractType + ' Order:- ' + CASE WHEN CM.strCommodityCode = 'Tea' THEN SQ.strERPPONumber ELSE NULL END AS strPurchaseOrder,
			CH.dtmContractDate,
			'The contract has been closed on the conditions of the '+ AN.strComment + ' ('+AN.strName+')'+' latest edition.' strAssociation,
			CASE WHEN CH.intContractTypeId = 1 THEN CH.strContractNumber ELSE CH.strCustomerContract END AS strBuyerRefNo,
			CASE WHEN CH.intContractTypeId = 2 THEN CH.strContractNumber ELSE CH.strCustomerContract END AS strSellerRefNo,
			CH.strContractNumber,
			CH.strCustomerContract,
			CB.strContractBasis,
			CB.strContractBasis+' '+CASE WHEN CB.strINCOLocationType = 'City' THEN CT.strCity ELSE SL.strSubLocationName END AS strContractBasisDesc,
			SQ.strLocationName,			
			CY.strCropYear,
			SQ.srtLoadingPoint + ' :' srtLoadingPoint,
			SQ.strLoadingPointName,
			SQ.strShipper,
			SQ.srtDestinationPoint + ' :' srtDestinationPoint,
			SQ.strDestinationPointName,
			SQ.strLoadingPointName + ' to ' + SQ.strDestinationPointName AS strLoadingAndDestinationPointName,

			W1.strWeightGradeDesc AS	strWeight,
			TM.strTerm,
			W2.strWeightGradeDesc AS	strGrade,
			'Quality as per approved sample ' + ' - ' + W2.strWeightGradeDesc + ' and subject to consignment conforming to ' + @strCompanyName + '''s standard quality criteria.' AS strQaulityAndInspection,

			@strContractDocuments strContractDocuments,
			'Rules of arbitration of '+ AN.strComment + '  as per latest edition for quality and principle. ' + CHAR(13)+CHAR(10) +
			'Place of jurisdiction is ' + AB.strState +', '+RY.strCountry AS strArbitration,
			@strCompanyName + ', '  + CHAR(13)+CHAR(10) +
			ISNULL(@strAddress,'') + ', ' + CHAR(13)+CHAR(10) +
			ISNULL(@strCity,'') + ISNULL(', '+@strState,'') + ISNULL(', '+@strZip,'') + ISNULL(', '+@strCountry,'')
			AS	strCompanyAddress,
			LTRIM(RTRIM(EY.strEntityName)) + ', ' + CHAR(13)+CHAR(10) +
			ISNULL(LTRIM(RTRIM(EY.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
			ISNULL(LTRIM(RTRIM(EY.strEntityCity)),'') + 
			ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityState)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityState)) END,'') + 
			ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityZipCode)) END,'') + 
			ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityCountry)) END,'') +
			CASE WHEN @ysnFairtrade = 1 THEN
				ISNULL( CHAR(13)+CHAR(10) +'FLO ID: '+CASE WHEN LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) = '' THEN NULL ELSE LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) END,'')
			ELSE '' END
			AS	strOtherPartyAddress,
			
			CASE WHEN CH.intContractTypeId = 1 THEN @strCompanyName ELSE EY.strEntityName END AS strBuyer,
			CASE WHEN CH.intContractTypeId = 2 THEN @strCompanyName ELSE EY.strEntityName END AS strSeller,
			CH.dblQuantity,
			SQ.strCurrency,
			'To be covered by ' + IB.strInsuranceBy AS strInsuranceBy,			
			CH.strPrintableRemarks,			
			AN.strComment	AS strArbitrationComment,
			dbo.fnSMGetCompanyLogo('Header') AS blbHeaderLogo,
			dbo.fnSMGetCompanyLogo('Footer') AS blbFooterLogo,
			PR.strName AS strProducer,
			PO.strPosition,
			CASE WHEN LTRIM(RTRIM(SQ.strFixationBy)) = '' THEN NULL ELSE SQ.strFixationBy END+'''s Call ('+SQ.strFutMarketName+')' strCaller,
			CASE WHEN LTRIM(RTRIM(SQ.strFixationBy)) = '' THEN NULL 
			ELSE 
				CASE WHEN CH.intPricingTypeId=2 THEN SQ.strFixationBy +'''s Call ('+SQ.strFutMarketName+')'
				ELSE NULL END
			END strCallerDesc,
			@strContractConditions AS strContractConditions,
			CASE WHEN ISNULL(CB.strContractBasis,'') <>'' THEN 'Condition :' ELSE NULL END AS lblCondition,
			CASE WHEN ISNULL(PR.strName,'') <>'' THEN 'Producer :' ELSE NULL END AS lblProducer,
			CASE WHEN ISNULL(SQ.strLoadingPointName,'') <>'' THEN SQ.srtLoadingPoint + ' :'  ELSE NULL END AS lblLoadingPoint,
			CASE WHEN ISNULL(PO.strPosition,'') <>'' THEN 'Position :' ELSE NULL END AS lblPosition,			
			CASE WHEN (CH.intContractTypeId = 2 AND ISNULL(CH.strContractNumber,'') <>'') OR (CH.intContractTypeId <> 2 AND ISNULL(CH.strCustomerContract,'') <>'') THEN  'Seller Ref No. :' ELSE NULL END AS lblSellerRefNo,
			CASE WHEN ISNULL(CY.strCropYear,'') <>'' THEN 'Crop Year :' ELSE NULL END AS lblCropYear,
			CASE WHEN ISNULL(SQ.strShipper,'') <>'' THEN 'Shipper :' ELSE NULL END AS lblShipper,
			CASE WHEN ISNULL(SQ.strDestinationPointName,'') <>'' THEN SQ.srtDestinationPoint + ' :'  ELSE NULL END AS lblDestinationPoint,			
			CASE WHEN ISNULL(SQ.strFixationBy,'') <>'' AND ISNULL(SQ.strFutMarketName,'') <>'' AND CH.intPricingTypeId=2 THEN 'Pricing :' ELSE NULL END AS lblPricing,
			CASE WHEN ISNULL(W1.strWeightGradeDesc,'') <>'' THEN 'Weighing:' ELSE NULL END AS lblWeighing,
			CASE WHEN ISNULL(TM.strTerm,'') <>'' THEN 'Payment Term:' ELSE NULL END AS lblTerm,
			CASE WHEN ISNULL(IB.strInsuranceBy,'') <>'' THEN 'Insurance:' ELSE NULL END AS lblInsurance,
			CASE WHEN ISNULL(AN.strComment,'') <>'' AND ISNULL(AB.strState,'') <>'' AND ISNULL(RY.strCountry,'') <>'' THEN 'Arbitration:' ELSE NULL END AS lblArbitration,
			CASE WHEN ISNULL(@strContractConditions,'') <>'' THEN 'Conditions:' ELSE NULL END AS lblContractCondition,
			SQ.strLocationName+', '+CONVERT(CHAR(11),CH.dtmContractDate,13) AS strLocationWithDate,
	        CASE WHEN LEN(LTRIM(RTRIM(@strAmendedColumns))) = 0 THEN
			'The contract has been closed on the conditions of the '+ AN.strComment + ' ('+AN.strName+')'+' latest edition and the particular conditions mentioned below.' 
		    ELSE
				'Subject - Contract Amendment as of '+ CONVERT(NVARCHAR(15),@dtmApproved,106) + CHAR(13) + CHAR(10) + 'The field/s highlighted in bold have been amended.'
			END strCondition,
			PO.strPosition +' ('+SQ.strPackingDescription +') ' AS strPositionWithPackDesc,
			TX.strText+' '+CH.strPrintableRemarks AS strText,
			SQ.strContractCompanyName,
			SQ.strContractPrintSignOff,
			LTRIM(RTRIM(EY.strEntityName))AS strCompanyName,
			@strApprovalText AS strApprovalText,
			CASE WHEN @IsFullApproved=1 THEN @FirstApprovalSign ELSE NULL END AS FirstApprovalSign,
			CASE WHEN @IsFullApproved=1 THEN @SecondApprovalSign ELSE NULL END AS SecondApprovalSign,

			@strAmendedColumns strAmendedColumns

	FROM	tblCTContractHeader CH
	JOIN	tblICCommodity		CM	ON	CM.intCommodityId		=	CH.intCommodityId
	JOIN	tblCTContractType	TP	ON	TP.intContractTypeId	=	CH.intContractTypeId
	JOIN	vyuCTEntity			EY	ON	EY.intEntityId			=	CH.intEntityId	AND
										EY.strEntityType		=	(CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)	LEFT
	JOIN	tblCTCropYear		CY	ON	CY.intCropYearId		=	CH.intCropYearId		LEFT
	JOIN	tblCTContractBasis	CB	ON	CB.intContractBasisId	=	CH.intContractBasisId	LEFT
	JOIN	tblCTWeightGrade	W1	ON	W1.intWeightGradeId		=	CH.intWeightId			LEFT
	JOIN	tblCTWeightGrade	W2	ON	W2.intWeightGradeId		=	CH.intGradeId			LEFT
	JOIN	tblCTContractText	TX	ON	TX.intContractTextId	=	CH.intContractTextId	LEFT
	JOIN	tblCTAssociation	AN	ON	AN.intAssociationId		=	CH.intAssociationId		LEFT
	JOIN	tblSMTerm			TM	ON	TM.intTermID			=	CH.intTermId			LEFT
	JOIN	tblSMCity			AB	ON	AB.intCityId			=	CH.intArbitrationId		LEFT
	JOIN	tblSMCountry		RY	ON	RY.intCountryID			=	AB.intCountryId			LEFT
	JOIN	tblCTInsuranceBy	IB	ON	IB.intInsuranceById		=	CH.intInsuranceById		LEFT	
	JOIN	tblEMEntity			PR	ON	PR.intEntityId			=	CH.intProducerId		LEFT
	JOIN	tblCTPosition		PO	ON	PO.intPositionId		=	CH.intPositionId		LEFT
	JOIN	tblSMCountry		CO	ON	CO.intCountryID			=	CH.intCountryId			LEFT
	JOIN	tblAPVendor			VR	ON	VR.intEntityVendorId	=	CH.intEntityId			LEFT
	JOIN	tblARCustomer		CR	ON	CR.intEntityCustomerId	=	CH.intEntityId			LEFT	
	JOIN	tblSMCity			CT	ON	CT.intCityId			=	CH.intINCOLocationTypeId	LEFT
	JOIN	tblSMCompanyLocationSubLocation		SL	ON	SL.intCompanyLocationSubLocationId	=		CH.intINCOLocationTypeId LEFT
	JOIN	(
				SELECT		ROW_NUMBER() OVER (PARTITION BY CD.intContractHeaderId ORDER BY CD.intContractSeq ASC) AS intRowNum, 
							CD.intContractHeaderId,
							CL.strLocationName,
							'Loading ' + CD.strLoadingPointType		AS	srtLoadingPoint,
							LP.strCity								AS	strLoadingPointName,
							'Destination ' + CD.strLoadingPointType AS	srtDestinationPoint,
							DP.strCity								AS	strDestinationPointName,
							TT.strName								AS	strShipper,
							CY.strCurrency,
							CD.strFixationBy,
							MA.strFutMarketName,
							CD.strPackingDescription				AS strPackingDescription,
							CL.strContractCompanyName				AS strContractCompanyName,
						    CL.strContractPrintSignOff              AS strContractPrintSignOff,
							CD.strERPPONumber

				FROM		tblCTContractDetail		CD
				JOIN		tblSMCompanyLocation	CL	ON	CL.intCompanyLocationId		=	CD.intCompanyLocationId		LEFT
				JOIN		tblSMCity				LP	ON	LP.intCityId				=	CD.intLoadingPortId			LEFT
				JOIN		tblSMCity				DP	ON	DP.intCityId				=	CD.intDestinationPortId		LEFT
				JOIN		tblEMEntity				TT	ON	TT.intEntityId				=	CD.intShipperId				LEFT
				JOIN		tblSMCurrency			CY	ON	CY.intCurrencyID			=	CD.intCurrencyId			LEFT
				JOIN		tblRKFutureMarket		MA	ON	MA.intFutureMarketId		=	CD.intFutureMarketId		
			)					SQ	ON	SQ.intContractHeaderId	=	CH.intContractHeaderId	AND  SQ.intRowNum = 1 
	WHERE	CH.intContractHeaderId	=	@intContractHeaderId
	
	SELECT @ysnFeedOnApproval = ysnFeedOnApproval FROM tblCTCompanyPreference

	IF @IsFullApproved=1  OR ISNULL(@ysnFeedOnApproval,0) = 0
		UPDATE tblCTContractHeader SET ysnPrinted = 1 WHERE intContractHeaderId	= @intContractHeaderId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO