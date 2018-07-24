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

			@intLastApprovedContractId	INT,
			@intPrevApprovedContractId	INT,
			@strAmendedColumns			NVARCHAR(MAX),
			@intContractDetailId		INT,
			@TotalAtlasLots				INT,
			@strSequenceHistoryId	    NVARCHAR(MAX),
			@strDetailAmendedColumns	NVARCHAR(MAX),
			@intLaguageId				INT,
			@strExpressionLabelName		NVARCHAR(50) = 'Expression',
			@strMonthLabelName			NVARCHAR(50) = 'Month',
			@intApproverGroupId			INT,
			@type						NVARCHAR(50),
			@strIds						NVARCHAR(MAX),
			@strGABShipDelv				NVARCHAR(MAX),
			@intReportLogoHeight		INT,
			@intReportLogoWidth			INT

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
	
	DECLARE @tblSequenceHistoryId TABLE
	(
	  intSequenceAmendmentLogId INT
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
    
	SELECT	@strIds = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intContractHeaderId'
	
	SELECT	@strSequenceHistoryId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'strSequenceHistoryId'
	
	SELECT	@intLaguageId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intSrLanguageId'

	SELECT	@type = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'Type'

	SELECT	TOP 1 @intContractHeaderId	= Item FROM dbo.fnSplitString(@strIds,',')

	SELECT @intReportLogoHeight = intReportLogoHeight,@intReportLogoWidth = intReportLogoWidth FROM tblLGCompanyPreference

	INSERT INTO @tblSequenceHistoryId
	(
	  intSequenceAmendmentLogId
	)
	SELECT strValues FROM dbo.fnARGetRowsFromDelimitedValues(@strSequenceHistoryId)

	SELECT	@intContractHeaderId = intContractHeaderId
	FROM	tblCTSequenceAmendmentLog   
	WHERE	intSequenceAmendmentLogId = (SELECT MIN(intSequenceAmendmentLogId) FROM @tblSequenceHistoryId)

	SELECT @intScreenId=intScreenId FROM tblSMScreen WHERE ysnApproval=1 AND strNamespace='ContractManagement.view.Contract'--ContractManagement.view.ContractAmendment
	SELECT @intTransactionId=intTransactionId,@IsFullApproved = ysnOnceApproved FROM tblSMTransaction WHERE intScreenId=@intScreenId AND intRecordId=@intContractHeaderId

	SELECT	@strCommodityCode	=	CM.strCommodityCode,
			@ysnPrinted			=	CH.ysnPrinted
	FROM	tblCTContractHeader CH
	JOIN	tblICCommodity		CM	ON	CM.intCommodityId		=	CH.intCommodityId
	WHERE	CH.intContractHeaderId = @intContractHeaderId

	IF @IsFullApproved = 1	
	BEGIN	
		SET @strApprovalText='This document concerns the Confirmed Agreement between Parties. Please sign in twofold and return to KDE as follows: one PDF-copy of the signed original by e-mail.'	
	END
	ELSE
		SET @strApprovalText='This document concerns an unconfirmed agreement. Please check this unconfirmed agreement and let us know if you find any discrepancies; If no notification of discrepancy has been received by us from you within 24 hours after receipt of this document, this unconfirmed agreement becomes confirmed from Supplier side. Once confirmed from Supplier side, KDE will check the document on discrepancies. If no discrepancies are found, a confirmed agreement will be issued by KDE, replacing the unconfirmed agreement. A confirmed agreement will only be binding for KDE once it has been signed by the authorized KDE representatives. Upon receipt of the confirmed agreement signed by KDE, Supplier shall sign the confirmed agreement and return it to KDE'

	IF @strCommodityCode = 'Tea'
		SET @strApprovalText = NULL

    SELECT TOP 1 @FirstApprovalId=intApproverId,@intApproverGroupId = intApproverGroupId FROM tblSMApproval WHERE intTransactionId=@intTransactionId AND strStatus='Approved' ORDER BY intApprovalId
	SELECT TOP 1 @SecondApprovalId=intApproverId FROM tblSMApproval WHERE intTransactionId=@intTransactionId AND strStatus='Approved' AND intApproverId <> @FirstApprovalId AND ISNULL(intApproverGroupId,0) <> @intApproverGroupId ORDER BY intApprovalId

	SELECT @FirstApprovalSign =  Sig.blbDetail 
								 FROM tblSMSignature Sig 
								 --JOIN tblEMEntitySignature ESig ON ESig.intElectronicSignatureId=Sig.intSignatureId 
								 WHERE Sig.intEntityId=@FirstApprovalId

	SELECT @SecondApprovalSign =Sig.blbDetail 
								FROM tblSMSignature Sig 
								--JOIN tblEMEntitySignature ESig ON ESig.intElectronicSignatureId=Sig.intSignatureId 
								WHERE Sig.intEntityId=@SecondApprovalId
	
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
					SELECT	CHAR(13)+CHAR(10) + dbo.[fnCTGetTranslation]('ContractManagement.view.Condition',CD.intConditionId,@intLaguageId,'Description',DM.strConditionDesc)
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

	SELECT @intContractDetailId = MIN(intContractDetailId) FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId

	WHILE ISNULL(@intContractDetailId,0) > 0
	BEGIN
		SELECT @intPrevApprovedContractId = NULL, @intLastApprovedContractId = NULL
		SELECT TOP 1 @intLastApprovedContractId =  intApprovedContractId,@dtmApproved = dtmApproved 
		FROM   tblCTApprovedContract 
		WHERE  intContractDetailId = @intContractDetailId AND strApprovalType IN ('Contract Amendment ') AND ysnApproved = 1
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
		 
		 SELECT @intContractDetailId = MIN(intContractDetailId) FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId AND intContractDetailId > @intContractDetailId
	 END

	IF @strAmendedColumns IS NULL AND EXISTS(SELECT 1 FROM @tblSequenceHistoryId)
	BEGIN
		 SELECT  @strAmendedColumns= STUFF((
											SELECT DISTINCT ',' + LTRIM(RTRIM(AAP.strDataIndex))
											FROM tblCTAmendmentApproval AAP
											JOIN tblCTSequenceAmendmentLog AL ON AL.intAmendmentApprovalId =AAP.intAmendmentApprovalId
											JOIN @tblSequenceHistoryId SH ON SH.intSequenceAmendmentLogId  = AL.intSequenceAmendmentLogId  
											WHERE ISNULL(AAP.ysnAmendment,0) =1
											FOR XML PATH('')
											), 1, 1, '')
        
		SELECT @strDetailAmendedColumns = STUFF((
										  		SELECT DISTINCT ',' + LTRIM(RTRIM(AAP.strDataIndex))
										  		FROM tblCTAmendmentApproval AAP
										  		JOIN tblCTSequenceAmendmentLog AL ON AL.intAmendmentApprovalId =AAP.intAmendmentApprovalId
										  		JOIN @tblSequenceHistoryId SH ON SH.intSequenceAmendmentLogId  = AL.intSequenceAmendmentLogId 
										  		WHERE ISNULL(AAP.ysnAmendment,0) =1 AND AAP.intAmendmentApprovalId BETWEEN 7 AND 19
										  		FOR XML PATH('')
										  		), 1, 1, '')

	END

	IF @strAmendedColumns IS NULL SELECT @strAmendedColumns = ''
	IF ISNULL(@ysnPrinted,0) = 0 SELECT @strAmendedColumns = ''

	/*Declared variables for translating expression*/
	declare @rtContract nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Contract'), 'Contract');
	declare @rtConfirmation nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Confirmation'), 'Confirmation');
	declare @rtWeConfirmHaving nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'We confirm having'), 'We confirm having');
	declare @rtBoughtFrom nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'bought from'), 'bought from');
	declare @rtSoldTo nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'sold to'), 'sold to');
	declare @rtYouAsFollows nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'you as follows'), 'you as follows');
	declare @rtOrder nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Order'), 'Order');
	declare @rtStrAssociation1 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'The contract has been closed on the conditions of the'), 'The contract has been closed on the conditions of the');
	declare @rtStrAssociation2 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'latest edition'), 'latest edition');
	declare @rtTo nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'to'), 'to');
	declare @rtStrQaulityAndInspection1 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Quality as per approved sample'), 'Quality as per approved sample');
	declare @rtStrQaulityAndInspection2 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'and subject to consignment conforming to'), 'and subject to consignment conforming to');
	declare @rtStrQaulityAndInspection3 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'standard quality criteria'), 'standard quality criteria');
	declare @rtStrArbitration1 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Rules of arbitration of'), 'Rules of arbitration of');
	declare @rtStrArbitration2 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'as per latest edition for quality and principle'), 'as per latest edition for quality and principle');
	declare @rtStrArbitration3 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Place of jurisdiction is'), 'Place of jurisdiction is');
	declare @rtFLOID nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'FLO ID'), 'FLO ID');
	declare @rtStrInsuranceBy nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'To be covered by'), 'To be covered by');
	declare @rtLocation nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Location'), 'Location');
	declare @rtDocumentsRequired nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Documents Required'), 'Documents Required');
	declare @rtContract2 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Contract'), 'Contract');
	declare @rtNotesRemarks nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Notes/Remarks'), 'Notes/Remarks');
	declare @rtPriceBasis nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Price Basis'), 'Price Basis');
	declare @rtOthers nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Others'), 'Others');
	declare @rtCondition nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Condition'), 'Condition');
	declare @rtProducer nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Producer'), 'Producer');
	declare @rtShipper nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Shipper'), 'Shipper');
	declare @rtPosition nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Position'), 'Position');
	declare @rtCropYear nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Crop Year'), 'Crop Year');
	declare @rtWeighing nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Weighing'), 'Weighing');
	declare @rtPaymentTerms nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Payment Terms'), 'Payment Terms');
	declare @rtApprovalterm nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Approval term'), 'Approval term');
	declare @rtInsurance nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Insurance'), 'Insurance');
	declare @rtConditions nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Conditions'), 'Conditions');
	declare @rtStrCondition1 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'The contract has been closed on the conditions of the'), 'The contract has been closed on the conditions of the');
	declare @rtStrCondition2 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'latest edition and the particular conditions mentioned below'), 'latest edition and the particular conditions mentioned below');
	declare @rtStrCondition3 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Subject - Contract Amendment as of'), 'Subject - Contract Amendment as of');
	declare @rtStrCondition4 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'The field/s highlighted in bold have been amended'), 'The field/s highlighted in bold have been amended');
	declare @rtArbitration nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Arbitration'), 'Arbitration');
	declare @rtPricing nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Pricing'), 'Pricing');
	declare @rtCall nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Call'), 'Call');
	declare @rtBuyerRefNo nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Buyer Ref No'), 'Buyer Ref No');
	declare @rtSellerRefNo nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Seller Ref No'), 'Seller Ref No');
	declare @rtLotssOf nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'lots(s) of'), 'lots(s) of');
	declare @rtFutures nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'futures'), 'futures');
	declare @rtMinus nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'minus'), 'minus');
	declare @rtPlus nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'plus'), 'plus');
	declare @rtStrPricing1 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'price fixation in'), 'price fixation in');
	declare @rtStrPricing2 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'option, before first notice day. (Number of Lots to be fixed'), 'option, before first notice day. (Number of Lots to be fixed');
	declare @rtConfirmationOf nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Confirmation of'), 'Confirmation of');
	declare @rtStrGABAssociation1 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'We confirm having bought today, at the conditions'), 'We confirm having bought today, at the conditions');
	declare @rtStrGABAssociation3 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'We confirm having sold to you today, at the conditions'), 'We confirm having sold to you today, at the conditions');
	declare @rtStrGABAssociation2 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'latest edition'), 'latest edition');
	declare @rtStriDealAssociation nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Re today phone conversation we confirm to you the following sale at the conditions'),'Re today phone conversation we confirm to you the following sale at the conditions');
	
	
	SELECT @TotalAtlasLots= CASE 
								 WHEN SUM(dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, UOM.intUnitMeasureId, MA.intUnitMeasureId, CD.dblQuantity) / MA.dblContractSize) < 1 THEN 1
								 ELSE ROUND(SUM(dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, UOM.intUnitMeasureId, MA.intUnitMeasureId, CD.dblQuantity) / MA.dblContractSize),0)
							END
							FROM tblCTContractDetail CD
							JOIN tblICItemUOM UOM ON UOM.intItemUOMId = CD.intItemUOMId
							JOIN tblRKFutureMarket MA ON MA.intFutureMarketId = CD.intFutureMarketId
							WHERE CD.intContractHeaderId = @intContractHeaderId

	IF @type = 'MULTIPLE'
	BEGIN
		SELECT @ErrMsg =  STUFF((
										  		SELECT DISTINCT '-' + RIGHT(strContractNumber,3)
										  		FROM tblCTContractHeader
										  		WHERE intContractHeaderId IN (SELECT Item FROM dbo.fnSplitString(@strIds,','))
												AND intContractHeaderId <> @intContractHeaderId
										  		FOR XML PATH('')
										  		), 1, 1, '')
	END

	SELECT	 intContractHeaderId					= CH.intContractHeaderId
			,strCaption								= isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,TP.strContractType), TP.strContractType) + ' '+@rtContract+':- ' + CH.strContractNumber
			,strHersheyCaption						= isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,TP.strContractType), TP.strContractType) + ' '+@rtConfirmation+':- ' + CH.strContractNumber
			,strTeaCaption							= @strCompanyName + ' - '+TP.strContractType+' '  + @rtContract
			,strAtlasDeclaration					= @rtWeConfirmHaving			   + CASE WHEN CH.intContractTypeId = 1	   THEN ' '+@rtBoughtFrom+' '   ELSE ' '+@rtSoldTo+' ' END + @rtYouAsFollows + ':'
			,strPurchaseOrder						= TP.strContractType + ' '+@rtOrder+':- ' + CASE WHEN CM.strCommodityCode = 'Tea' THEN SQ.strERPPONumber ELSE NULL        END
			,dtmContractDate						= CH.dtmContractDate
			,strAssociation							= @rtStrAssociation1 + ' '+ isnull(rtrt.strTranslation,AN.strComment) + ' ('+isnull(rtrt1.strTranslation,AN.strName)+')'+' '+@rtStrAssociation2+'.'
			,strBuyerRefNo							= CASE WHEN CH.intContractTypeId = 1 THEN CH.strContractNumber ELSE CH.strCustomerContract END
			,strSellerRefNo							= CASE WHEN CH.intContractTypeId = 2 THEN CH.strContractNumber ELSE CH.strCustomerContract END
			,strContractNumber						= CH.strContractNumber
			,strCustomerContract					= CH.strCustomerContract
			,strContractBasis						= CB.strContractBasis
			,strContractBasisDesc					= CB.strContractBasis+' '+CASE WHEN CB.strINCOLocationType = 'City' THEN CT.strCity ELSE SL.strSubLocationName END
			,strCityWarehouse						= CASE WHEN CB.strINCOLocationType = 'City' THEN CT.strCity ELSE SL.strSubLocationName END
			,strLocationName						= SQ.strLocationName			
			,strCropYear							= CY.strCropYear
			,srtLoadingPoint						= SQ.srtLoadingPoint
			,strLoadingPointName					= SQ.strLoadingPointName
			,strShipper								= SQ.strShipper
			,srtDestinationPoint					= SQ.srtDestinationPoint 
			,strDestinationPointName				= SQ.strDestinationPointName
			,strLoadingAndDestinationPointName		= SQ.strLoadingPointName + ' '+@rtTo+' ' + SQ.strDestinationPointName
			,strWeight								= isnull(rtrt4.strTranslation,W1.strWeightGradeDesc) 
			,strTerm							    = isnull(rtrt7.strTranslation,TM.strTerm)
			,strGrade								= isnull(rtrt3.strTranslation,W2.strWeightGradeDesc)
			,strQaulityAndInspection				= @rtStrQaulityAndInspection1 + ' ' + ' - ' + isnull(rtrt3.strTranslation,W2.strWeightGradeDesc) + ' '+@rtStrQaulityAndInspection2+' ' + @strCompanyName + '''s '+@rtStrQaulityAndInspection3+'.'
			,strContractDocuments					= @strContractDocuments
			,strArbitration							= @rtStrArbitration1 + ' '+ isnull(rtrt.strTranslation,AN.strComment) + '  '+@rtStrArbitration2+'. ' 
														+ CHAR(13)+CHAR(10) +
														@rtStrArbitration3 + ' ' + AB.strState +', '+ isnull(rtrt8.strTranslation,RY.strCountry)

			,strCompanyAddress						=   @strCompanyName + ', '		  + CHAR(13)+CHAR(10) +
														ISNULL(@strAddress,'') + ', ' + CHAR(13)+CHAR(10) +
														ISNULL(@strCity,'') + ISNULL(', '+@strState,'') + ISNULL(', '+@strZip,'') + ISNULL(', '+@strCountry,'')
			
			,strOtherPartyAddress					=   LTRIM(RTRIM(EY.strEntityName)) + ', '				+ CHAR(13)+CHAR(10) +
														ISNULL(LTRIM(RTRIM(EY.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
														ISNULL(LTRIM(RTRIM(EY.strEntityCity)),'') + 
														ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityState)) = ''   THEN NULL ELSE LTRIM(RTRIM(EY.strEntityState))   END,'') + 
														ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityZipCode)) END,'') + 
														ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(isnull(rtrt10.strTranslation,EY.strEntityCountry))) END,'') +
														CASE WHEN @ysnFairtrade = 1 THEN
															ISNULL( CHAR(13)+CHAR(10) + @rtFLOID + ': '+CASE WHEN LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) = '' THEN NULL ELSE LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) END,'')
														ELSE '' END
			
			,strBuyer							    = CASE WHEN CH.intContractTypeId = 1 THEN @strCompanyName ELSE EY.strEntityName END
			,strSeller							    = CASE WHEN CH.intContractTypeId = 2 THEN @strCompanyName ELSE EY.strEntityName END
			,dblQuantity						    = CH.dblQuantity
			,strCurrency						    = SQ.strCurrency
			,strInsuranceBy						    = @rtStrInsuranceBy + ' ' + IB.strInsuranceBy			
			,strPrintableRemarks				    = CH.strPrintableRemarks			
			,strArbitrationComment				    = isnull(rtrt.strTranslation,AN.strComment)	
			,blbHeaderLogo						    = dbo.fnSMGetCompanyLogo('Header')
			,blbFooterLogo						    = dbo.fnSMGetCompanyLogo('Footer') 
			,strProducer							= PR.strName
			,strPosition							= PO.strPosition
			,strContractConditions				    = @strContractConditions
			,lblAtlasLocation						= CASE WHEN ISNULL(CASE WHEN CB.strINCOLocationType = 'City' THEN CT.strCity ELSE SL.strSubLocationName END,'') <>''     THEN @rtLocation + ' :'					ELSE NULL END
			,lblContractDocuments					= CASE WHEN ISNULL(@strContractDocuments,'') <>''	   THEN @rtDocumentsRequired + ' :'			ELSE NULL END
			,lblArbitrationComment					= CASE WHEN ISNULL(AN.strComment,'') <>''			   THEN @rtContract2 + ' :'					ELSE NULL END
			,lblPrintableRemarks					= CASE WHEN ISNULL(CH.strPrintableRemarks,'') <>''	   THEN @rtNotesRemarks + ' :'				ELSE NULL END
			,lblContractBasis						= CASE WHEN ISNULL(CB.strContractBasis,'') <>''		   THEN @rtPriceBasis + ' :'					ELSE NULL END
			,lblContractText						= CASE WHEN ISNULL(TX.strText,'') <>''				   THEN @rtOthers + ' :'						ELSE NULL END
			,lblCondition						    = CASE WHEN ISNULL(CB.strContractBasis,'') <>''		   THEN @rtCondition + ' :'					ELSE NULL END
			,lblAtlasProducer						= CASE WHEN ISNULL(PR.strName,'') <>''				   THEN @rtProducer + ' :'					ELSE NULL END
			,lblProducer							= CASE WHEN ISNULL(PR.strName,'') <>''				   THEN @rtShipper + ' :'						ELSE NULL END
			,lblLoadingPoint						= CASE WHEN ISNULL(SQ.strLoadingPointName,'') <>''     THEN SQ.srtLoadingPoint + ' :'		ELSE NULL END
			,lblPosition							= CASE WHEN ISNULL(PO.strPosition,'') <>''		       THEN @rtPosition + ' :'					ELSE NULL END
			,lblCropYear							= CASE WHEN ISNULL(CY.strCropYear,'') <>''			   THEN @rtCropYear +' :'				    ELSE NULL END
			,lblShipper								= CASE WHEN ISNULL(SQ.strShipper,'') <>''			   THEN @rtShipper + ' :'					    ELSE NULL END 
			,lblDestinationPoint					= CASE WHEN ISNULL(SQ.strDestinationPointName,'') <>'' THEN SQ.srtDestinationPoint + ' :'   ELSE NULL END
			,lblWeighing						    = CASE WHEN ISNULL(W1.strWeightGradeDesc,'') <>''	   THEN @rtWeighing + ' :'					ELSE NULL END
			,lblTerm								= CASE WHEN ISNULL(TM.strTerm,'') <>''				   THEN @rtPaymentTerms + ' :'				ELSE NULL END
			,lblGrade								= CASE WHEN ISNULL(W2.strWeightGradeDesc,'') <>''	   THEN @rtApprovalterm + ' :'				ELSE NULL END
			,lblInsurance							= CASE WHEN ISNULL(IB.strInsuranceBy,'') <>''		   THEN @rtInsurance + ':'					ELSE NULL END
			,lblContractCondition					= CASE WHEN ISNULL(@strContractConditions,'') <>''	   THEN @rtConditions + ':'					ELSE NULL END
			--,strLocationWithDate					= SQ.strLocationName+', '+CONVERT(CHAR(11),CH.dtmContractDate,13)
			,strLocationWithDate					= SQ.strLocationName+', '+DATENAME(dd,CH.dtmContractDate) + ' ' + isnull(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,LEFT(DATENAME(MONTH,CH.dtmContractDate),3)), LEFT(DATENAME(MONTH,CH.dtmContractDate),3)) + ' ' + DATENAME(yyyy,CH.dtmContractDate)
			,strContractText						= ISNULL(TX.strText,'') 
	        ,strCondition							=	CASE WHEN LEN(LTRIM(RTRIM(@strAmendedColumns))) = 0 THEN
																@rtStrCondition1 + ' '+ isnull(rtrt.strTranslation,AN.strComment) + ' ('+isnull(rtrt1.strTranslation,AN.strName)+')'+@rtStrCondition2+' .' 
														ELSE
																@rtStrCondition3 + ' '+ CONVERT(NVARCHAR(15),@dtmApproved,106) + CHAR(13) + CHAR(10) + @rtStrCondition4 + '.'
														END
			
			,strPositionWithPackDesc			    = PO.strPosition +ISNULL(' ('+CASE WHEN SQ.strPackingDescription = '' THEN NULL ELSE SQ.strPackingDescription END+') ','')
			,strText							    = ISNULL(TX.strText,'') +' '+ ISNULL(CH.strPrintableRemarks,'') 
			,strContractCompanyName					= SQ.strContractCompanyName
			,strContractPrintSignOff			    = SQ.strContractPrintSignOff
			,strEntityName							= LTRIM(RTRIM(EY.strEntityName))
			,strApprovalText					    = @strApprovalText
			,FirstApprovalSign						= CASE WHEN @IsFullApproved=1 AND @strCommodityCode = 'Coffee' THEN @FirstApprovalSign  ELSE NULL END
			,SecondApprovalSign						= CASE WHEN @IsFullApproved=1 AND @strCommodityCode = 'Coffee' THEN @SecondApprovalSign ELSE NULL END
			,strAmendedColumns						= @strAmendedColumns
			,lblArbitration							= CASE WHEN ISNULL(AN.strComment,'') <>''	 AND ISNULL(AB.strState,'') <>''		 AND ISNULL(RY.strCountry,'') <>'' THEN @rtArbitration + ':'  ELSE NULL END
			,lblPricing								= CASE WHEN ISNULL(SQ.strFixationBy,'') <>'' AND ISNULL(SQ.strFutMarketName,'') <>'' AND CH.intPricingTypeId=2		   THEN @rtPricing + ' :'		ELSE NULL END
			,strCaller								= CASE WHEN LTRIM(RTRIM(SQ.strFixationBy)) = '' THEN NULL ELSE SQ.strFixationBy END+'''s '+@rtCall+' ('+SQ.strFutMarketName+')' 
			,lblBuyerRefNo							= CASE WHEN (CH.intContractTypeId = 1 AND ISNULL(CH.strContractNumber,'') <>'') OR (CH.intContractTypeId <> 1 AND ISNULL(CH.strCustomerContract,'') <>'') THEN  @rtBuyerRefNo + '. :'  ELSE NULL END
			,lblSellerRefNo							= CASE WHEN (CH.intContractTypeId = 2 AND ISNULL(CH.strContractNumber,'') <>'') OR (CH.intContractTypeId <> 2 AND ISNULL(CH.strCustomerContract,'') <>'') THEN  @rtSellerRefNo + '. :' ELSE NULL END
			,strAtlasCaller							= CASE WHEN ISNULL(SQ.strFixationBy,'') <> '' AND CH.intPricingTypeId = 2 THEN SQ.strFixationBy +'''s '+@rtCall+' vs '+LTRIM(@TotalAtlasLots)+' '+@rtLotssOf+' '+SQ.strFutMarketName + ' ' + @rtFutures ELSE NULL END
			,strCallerDesc						    = CASE WHEN LTRIM(RTRIM(SQ.strFixationBy)) = '' THEN NULL 
													  ELSE 
													  	  CASE WHEN CH.intPricingTypeId=2 THEN SQ.strFixationBy +'''s '+@rtCall+' ('+SQ.strFutMarketName+')'
													  	  ELSE NULL END
													  END 
			,strDetailAmendedColumns				= @strDetailAmendedColumns
		    ,strINCOTermWithWeight					=	dbo.fnCTGetTranslation('ContractManagement.view.INCOShipTerm',CB.intContractBasisId,@intLaguageId,'Contract Basis',CB.strContractBasis) + ISNULL(', ' + isnull(rtrt4.strTranslation,W1.strWeightGradeDesc),'')
			,strQuantityWithUOM						=	dbo.fnRemoveTrailingZeroes(CH.dblQuantity) + ' ' + isnull(rtrt2.strTranslation,UM.strUnitMeasure) + ' ' + ISNULL(SQ.strNoOfContainerAndType, '')
			,strItemDescWithSpec					=	SQ.strItemDescWithSpec
			,strStartAndEndDate						=	SQ.strStartAndEndDate
			,strNoOfContainerAndType				=	SQ.strNoOfContainerAndType
			,strFutureMonthYear						=	SQ.strFutureMonthYear
			,strPricing								=	SQ.strFutMarketName + ' ' + SQ.strFutureMonthYear +
														CASE WHEN SQ.dblBasis < 0 THEN ' '+@rtMinus+' ' ELSE ' '+@rtPlus+' ' END +  
														dbo.fnRemoveTrailingZeroes(SQ.dblBasis) + ' ' + SQ.strPriceCurrencyAndUOM + 
														' '+@rtStrPricing1+' ' + SQ.strBuyerSeller + 
														'''s '+@rtStrPricing2+':'+dbo.fnRemoveTrailingZeroes(dblLotsToFix)+').'
			,strGABHeader							=	@rtConfirmationOf + ' ' + isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,TP.strContractType), TP.strContractType) + ' ' + CH.strContractNumber+ISNULL('-' + @ErrMsg , '')		
			,strGABAssociation						=	CASE WHEN CH.intContractTypeId = 1 THEN @rtStrGABAssociation1 ELSE @rtStrGABAssociation3 END
														+ ' ' + isnull(rtrt.strTranslation,AN.strComment) + ' ('+isnull(rtrt1.strTranslation,AN.strName)+')'+' '+@rtStrGABAssociation2+'.'
			,striDealAssociation					=	@rtStriDealAssociation
														+ ' ' + isnull(rtrt.strTranslation,AN.strComment) + ' ('+isnull(rtrt1.strTranslation,AN.strName)+')'+' '+@rtStrGABAssociation2+'.'
			,strCompanyCityAndDate					=	ISNULL(@strCity + ', ', '') + LEFT(DATENAME(DAY,getdate()),2) + ' ' + isnull(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,LEFT(DATENAME(MONTH,getdate()),3)), LEFT(DATENAME(MONTH,getdate()),3)) + ' ' + LEFT(DATENAME(YEAR,getdate()),4)
			,strCompanyName							=	@strCompanyName
			,striDealShipment						=  ISNULL(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,DATENAME(MONTH, SQ.dtmStartDate)), DATENAME(MONTH, SQ.dtmStartDate)) +'('+ RIGHT(YEAR(SQ.dtmStartDate), 2)+')'
			,striDealSeller							=   LTRIM(RTRIM(EV.strEntityName)) + ', ' + CHAR(13)+CHAR(10) +
														ISNULL(LTRIM(RTRIM(EV.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
														ISNULL(LTRIM(RTRIM(EV.strEntityCity)),'') + 
														ISNULL(', '+CASE WHEN LTRIM(RTRIM(EV.strEntityState)) = '' THEN NULL ELSE LTRIM(RTRIM(EV.strEntityState)) END,'') + 
														ISNULL(', '+CASE WHEN LTRIM(RTRIM(EV.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EV.strEntityZipCode)) END,'') + 
														ISNULL(', '+CASE WHEN LTRIM(RTRIM(EV.strEntityCountry)) = '' THEN NULL ELSE isnull(rtrt11.strTranslation,LTRIM(RTRIM(EV.strEntityCountry))) END,'')

			,striDealBuyer							=   LTRIM(RTRIM(EC.strEntityName)) + ', ' + CHAR(13)+CHAR(10) +
														ISNULL(LTRIM(RTRIM(EC.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
														ISNULL(LTRIM(RTRIM(EC.strEntityCity)),'') + 
														ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityState)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityState)) END,'') + 
														ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityZipCode)) END,'') + 
														ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityCountry)) = '' THEN NULL ELSE isnull(rtrt12.strTranslation,LTRIM(RTRIM(EC.strEntityCountry))) END,'')
			,striDealPrice							=	strFutMarketName + ' ' + strFutureMonth + ' ' + LTRIM(dblBasis)+' '+ strBasisCurrency + '/' + strBasisUnitMeasure
			,lblGABShipDelv							=	CASE WHEN strPosition = 'Spot' THEN dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Delivery') ELSE dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Shipment') END
			,strIds									=	@strIds
			,strType								=	@type
			,intLaguageId							=	@intLaguageId
			,intReportLogoHeight					=	ISNULL(@intReportLogoHeight,0)
			,intReportLogoWidth						=	ISNULL(@intReportLogoWidth,0)

	FROM	tblCTContractHeader			CH
	JOIN	tblICCommodity				CM	ON	CM.intCommodityId				=	CH.intCommodityId
	JOIN	tblCTContractType			TP	ON	TP.intContractTypeId			=	CH.intContractTypeId
	JOIN	vyuCTEntity					EY	ON	EY.intEntityId					=	CH.intEntityId	AND
												EY.strEntityType				=	(CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)	LEFT
	JOIN	vyuCTEntity					EV	ON	EV.intEntityId					=	CH.intEntityId        
											AND EV.strEntityType				=	'Vendor'					LEFT
	JOIN	vyuCTEntity					EC	ON	EC.intEntityId					=	CH.intCounterPartyId  
											AND EC.strEntityType				=	'Customer'					LEFT
	JOIN	tblCTCropYear				CY	ON	CY.intCropYearId				=	CH.intCropYearId			LEFT
	JOIN	tblCTContractBasis			CB	ON	CB.intContractBasisId			=	CH.intContractBasisId		LEFT
	JOIN	tblCTWeightGrade			W1	ON	W1.intWeightGradeId				=	CH.intWeightId				LEFT
	JOIN	tblCTWeightGrade			W2	ON	W2.intWeightGradeId				=	CH.intGradeId				LEFT
	JOIN	tblCTContractText			TX	ON	TX.intContractTextId			=	CH.intContractTextId		LEFT
	JOIN	tblCTAssociation			AN	ON	AN.intAssociationId				=	CH.intAssociationId			LEFT
	JOIN	tblSMTerm					TM	ON	TM.intTermID					=	CH.intTermId				LEFT
	JOIN	tblSMCity					AB	ON	AB.intCityId					=	CH.intArbitrationId			LEFT
	JOIN	tblSMCountry				RY	ON	RY.intCountryID					=	AB.intCountryId				LEFT
	JOIN	tblCTInsuranceBy			IB	ON	IB.intInsuranceById				=	CH.intInsuranceById			LEFT	
	JOIN	tblEMEntity					PR	ON	PR.intEntityId					=	CH.intProducerId			LEFT
	JOIN	tblCTPosition				PO	ON	PO.intPositionId				=	CH.intPositionId			LEFT
	JOIN	tblSMCountry				CO	ON	CO.intCountryID					=	CH.intCountryId				LEFT
	JOIN	tblAPVendor					VR	ON	VR.intEntityId					=	CH.intEntityId				LEFT
	JOIN	tblARCustomer				CR	ON	CR.intEntityId					=	CH.intEntityId				LEFT	
	JOIN	tblSMCity					CT	ON	CT.intCityId					=	CH.intINCOLocationTypeId	LEFT
	JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityUnitMeasureId	=	CH.intCommodityUOMId		LEFT
	JOIN	tblICUnitMeasure			UM	ON	UM.intUnitMeasureId				=	CU.intUnitMeasureId			LEFT
	JOIN	tblSMCompanyLocationSubLocation		SL	ON	SL.intCompanyLocationSubLocationId	=		CH.intWarehouseId LEFT
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
							strFutMarketName = isnull(rtrt6.strTranslation,MA.strFutMarketName),
							CD.strPackingDescription				AS strPackingDescription,
							CL.strContractCompanyName				AS strContractCompanyName,
						    CL.strContractPrintSignOff              AS strContractPrintSignOff,
							CD.strERPPONumber,
							(SELECT SUM(dblNoOfLots) FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId) AS dblTotalNoOfLots,
							isnull(rtIMTranslation.strTranslation, IM.strDescription) + ISNULL(', ' + CD.strItemSpecification, '') AS strItemDescWithSpec,
							--CONVERT(NVARCHAR(20),CD.dtmStartDate,106) + ' - ' +  CONVERT(NVARCHAR(20),CD.dtmEndDate,106) AS strStartAndEndDate,
							LEFT(DATENAME(DAY,CD.dtmStartDate),2) + ' ' + isnull(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,LEFT(DATENAME(MONTH,CD.dtmStartDate),3)), LEFT(DATENAME(MONTH,CD.dtmStartDate),3)) + ' ' + LEFT(DATENAME(YEAR,CD.dtmStartDate),4) + ' - ' + LEFT(DATENAME(DAy,CD.dtmEndDate),2) + ' ' + isnull(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,LEFT(DATENAME(MONTH,CD.dtmEndDate),3)), LEFT(DATENAME(MONTH,CD.dtmEndDate),3)) + ' ' + LEFT(DATENAME(YEAR,CD.dtmEndDate),4) AS strStartAndEndDate,
							LTRIM(CD.intNumberOfContainers) + ' x ' + isnull(rtrt11.strTranslation,CT.strContainerType) AS strNoOfContainerAndType,
							--DATENAME(mm,MO.dtmFutureMonthsDate) + ' ' + DATENAME(yyyy,MO.dtmFutureMonthsDate) AS strFutureMonthYear,
							isnull(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,DATENAME(mm,MO.dtmFutureMonthsDate)), DATENAME(mm,MO.dtmFutureMonthsDate)) + ' ' + DATENAME(yyyy,MO.dtmFutureMonthsDate) AS strFutureMonthYear,
							CD.dblBasis,
							CD.strBuyerSeller,
							ISNULL(CD.dblNoOfLots - ISNULL(PF.dblLotsFixed,0), 0) AS dblLotsToFix,
							CD.intPricingTypeId,
							CY.strCurrency + '-' + ISNULL(rtrt5.strTranslation,UM.strUnitMeasure) AS	strPriceCurrencyAndUOM,
							CD.dtmStartDate,
							ISNULL(rtrt8.strTranslation,MO.strFutureMonth) strFutureMonth,
							BC.strCurrency AS strBasisCurrency,
							ISNULL(rtrt7.strTranslation,BM.strUnitMeasure) strBasisUnitMeasure

				FROM		tblCTContractDetail		CD
				JOIN		tblICItem				IM	ON	IM.intItemId				=	CD.intItemId
				JOIN		tblSMCompanyLocation	CL	ON	CL.intCompanyLocationId		=	CD.intCompanyLocationId		LEFT
				JOIN		tblSMCity				LP	ON	LP.intCityId				=	CD.intLoadingPortId			LEFT
				JOIN		tblSMCity				DP	ON	DP.intCityId				=	CD.intDestinationPortId		LEFT
				JOIN		tblEMEntity				TT	ON	TT.intEntityId				=	CD.intShipperId				LEFT
				JOIN		tblSMCurrency			CY	ON	CY.intCurrencyID			=	CD.intCurrencyId			LEFT
				JOIN		tblSMCurrency			BC	ON	BC.intCurrencyID			=	CD.intBasisCurrencyId		LEFT
				JOIN		tblRKFutureMarket		MA	ON	MA.intFutureMarketId		=	CD.intFutureMarketId		LEFT
				JOIN		tblRKFuturesMonth		MO	ON	MO.intFutureMonthId			=	CD.intFutureMonthId			LEFT
				JOIN		tblLGContainerType		CT	ON	CT.intContainerTypeId		=	CD.intContainerTypeId		LEFT
				JOIN		tblCTPriceFixation		PF	ON	PF.intContractDetailId		=	CD.intContractDetailId		LEFT
				JOIN		tblICItemUOM			IU	ON	IU.intItemUOMId				=	CD.intPriceItemUOMId		LEFT
				JOIN		tblICUnitMeasure		UM	ON	UM.intUnitMeasureId			=	IU.intUnitMeasureId

				LEFT JOIN   tblICItemUOM			BU	ON  BU.intItemUOMId				=	CD.intBasisUOMId
				LEFT JOIN   tblICUnitMeasure		BM	ON  BM.intUnitMeasureId			=	BU.intUnitMeasureId
	
				left join tblSMScreen				rts5 on rts5.strNamespace = 'Inventory.view.ReportTranslation'
				left join tblSMTransaction			rtt5 on rtt5.intScreenId = rts5.intScreenId and rtt5.intRecordId = UM.intUnitMeasureId
				left join tblSMReportTranslation	rtrt5 on rtrt5.intLanguageId = @intLaguageId and rtrt5.intTransactionId = rtt5.intTransactionId and rtrt5.strFieldName = 'Name'
	
				left join tblSMScreen				rts6 on rts6.strNamespace = 'RiskManagement.view.FuturesMarket'
				left join tblSMTransaction			rtt6 on rtt6.intScreenId = rts6.intScreenId and rtt6.intRecordId = MA.intFutureMarketId
				left join tblSMReportTranslation	rtrt6 on rtrt6.intLanguageId = @intLaguageId and rtrt6.intTransactionId = rtt6.intTransactionId and rtrt6.strFieldName = 'Market Name'

				left join tblSMScreen				rts11 on rts11.strNamespace = 'Logistics.view.ContainerType'
				left join tblSMTransaction			rtt11 on rtt11.intScreenId = rts11.intScreenId and rtt11.intRecordId = CT.intContainerTypeId
				left join tblSMReportTranslation	rtrt11 on rtrt11.intLanguageId = @intLaguageId and rtrt11.intTransactionId = rtt11.intTransactionId and rtrt11.strFieldName = 'Container Type'

				left join tblSMScreen				rtIMScreen on rtIMScreen.strNamespace = 'Inventory.view.Item'
				left join tblSMTransaction			rtIMTransaction on rtIMTransaction.intScreenId = rtIMScreen.intScreenId and rtIMTransaction.intRecordId = IM.intItemId
				left join tblSMReportTranslation	rtIMTranslation on rtIMTranslation.intLanguageId = @intLaguageId and rtIMTranslation.intTransactionId = rtIMTransaction.intTransactionId and rtIMTranslation.strFieldName = 'Description'

				left join tblSMScreen				rts8 on rts8.strNamespace = 'RiskManagement.view.FuturesTradingMonths'
				left join tblSMTransaction			rtt8 on rtt8.intScreenId = rts8.intScreenId and rtt8.intRecordId = CD.intFutureMonthId
				left join tblSMReportTranslation	rtrt8 on rtrt8.intLanguageId = @intLaguageId and rtrt8.intTransactionId = rtt8.intTransactionId and rtrt8.strFieldName = 'Future Trading Month'
	
				left join tblSMScreen				rts7 on rts7.strNamespace = 'Inventory.view.ReportTranslation'
				left join tblSMTransaction			rtt7 on rtt7.intScreenId = rts7.intScreenId and rtt7.intRecordId = CD.intUnitMeasureId
				left join tblSMReportTranslation	rtrt7 on rtrt7.intLanguageId = @intLaguageId and rtrt7.intTransactionId = rtt7.intTransactionId and rtrt7.strFieldName = 'Name'

			)										SQ	ON	SQ.intContractHeaderId		=	CH.intContractHeaderId	
														AND SQ.intRowNum = 1
														
	left join tblSMScreen				rts on rts.strNamespace = 'ContractManagement.view.Associations'
	left join tblSMTransaction			rtt on rtt.intScreenId = rts.intScreenId and rtt.intRecordId = AN.intAssociationId
	left join tblSMReportTranslation	rtrt on rtrt.intLanguageId = @intLaguageId and rtrt.intTransactionId = rtt.intTransactionId and rtrt.strFieldName = 'Printable Contract Text'
	
	left join tblSMScreen				rts1 on rts1.strNamespace = 'ContractManagement.view.Associations'
	left join tblSMTransaction			rtt1 on rtt1.intScreenId = rts1.intScreenId and rtt1.intRecordId = AN.intAssociationId
	left join tblSMReportTranslation	rtrt1 on rtrt1.intLanguageId = @intLaguageId and rtrt1.intTransactionId = rtt1.intTransactionId and rtrt1.strFieldName = 'Name'
	
	left join tblSMScreen				rts2 on rts2.strNamespace = 'Inventory.view.ReportTranslation'
	left join tblSMTransaction			rtt2 on rtt2.intScreenId = rts2.intScreenId and rtt2.intRecordId = UM.intUnitMeasureId
	left join tblSMReportTranslation	rtrt2 on rtrt2.intLanguageId = @intLaguageId and rtrt2.intTransactionId = rtt2.intTransactionId and rtrt2.strFieldName = 'Name'
	
	left join tblSMScreen				rts3 on rts3.strNamespace = 'ContractManagement.view.WeightGrades'
	left join tblSMTransaction			rtt3 on rtt3.intScreenId = rts3.intScreenId and rtt3.intRecordId = W2.intWeightGradeId
	left join tblSMReportTranslation	rtrt3 on rtrt3.intLanguageId = @intLaguageId and rtrt3.intTransactionId = rtt3.intTransactionId and rtrt3.strFieldName = 'Name'
	
	left join tblSMScreen				rts4 on rts4.strNamespace = 'ContractManagement.view.WeightGrades'
	left join tblSMTransaction			rtt4 on rtt4.intScreenId = rts4.intScreenId and rtt4.intRecordId = W1.intWeightGradeId
	left join tblSMReportTranslation	rtrt4 on rtrt4.intLanguageId = @intLaguageId and rtrt4.intTransactionId = rtt4.intTransactionId and rtrt4.strFieldName = 'Name'
	
	left join tblSMScreen				rts7 on rts7.strNamespace = 'i21.view.Term'
	left join tblSMTransaction			rtt7 on rtt7.intScreenId = rts7.intScreenId and rtt7.intRecordId = TM.intTermID
	left join tblSMReportTranslation	rtrt7 on rtrt7.intLanguageId = @intLaguageId and rtrt7.intTransactionId = rtt7.intTransactionId and rtrt7.strFieldName = 'Terms'
	
	left join tblSMScreen				rts8 on rts8.strNamespace = 'i21.view.Country'
	left join tblSMTransaction			rtt8 on rtt8.intScreenId = rts8.intScreenId and rtt8.intRecordId = RY.intCountryID
	left join tblSMReportTranslation	rtrt8 on rtrt8.intLanguageId = @intLaguageId and rtrt8.intTransactionId = rtt8.intTransactionId and rtrt8.strFieldName = 'Country'
	
	left join tblSMCountry				rtc10 on lower(rtrim(ltrim(rtc10.strCountry))) = lower(rtrim(ltrim(EY.strEntityCountry)))
	left join tblSMScreen				rts10 on rts10.strNamespace = 'i21.view.Country'
	left join tblSMTransaction			rtt10 on rtt10.intScreenId = rts10.intScreenId and rtt10.intRecordId = rtc10.intCountryID
	left join tblSMReportTranslation	rtrt10 on rtrt10.intLanguageId = @intLaguageId and rtrt10.intTransactionId = rtt10.intTransactionId and rtrt10.strFieldName = 'Country'

	left join tblSMCountry				rtc11 on lower(rtrim(ltrim(rtc11.strCountry))) = lower(rtrim(ltrim(EV.strEntityCountry)))
	left join tblSMScreen				rts11 on rts11.strNamespace = 'i21.view.Country'
	left join tblSMTransaction			rtt11 on rtt11.intScreenId = rts11.intScreenId and rtt11.intRecordId = rtc11.intCountryID
	left join tblSMReportTranslation	rtrt11 on rtrt11.intLanguageId = @intLaguageId and rtrt11.intTransactionId = rtt11.intTransactionId and rtrt11.strFieldName = 'Country'

	left join tblSMCountry				rtc12 on lower(rtrim(ltrim(rtc12.strCountry))) = lower(rtrim(ltrim(EC.strEntityCountry)))
	left join tblSMScreen				rts12 on rts12.strNamespace = 'i21.view.Country'
	left join tblSMTransaction			rtt12 on rtt12.intScreenId = rts12.intScreenId and rtt12.intRecordId = rtc12.intCountryID
	left join tblSMReportTranslation	rtrt12 on rtrt12.intLanguageId = @intLaguageId and rtrt12.intTransactionId = rtt12.intTransactionId and rtrt12.strFieldName = 'Country'


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