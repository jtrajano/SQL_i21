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
			@StraussContractSubmitId       INT,
			@FirstApprovalSign      VARBINARY(MAX),
			@SecondApprovalSign     VARBINARY(MAX),
			@InterCompApprovalSign  VARBINARY(MAX),
			@StraussContractApproverSignature  VARBINARY(MAX),
			@StraussContractSubmitSignature  VARBINARY(MAX),
			@FirstApprovalName      NVARCHAR(MAX),
			@SecondApprovalName     NVARCHAR(MAX),
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
			@TotalLots					INT,
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
			@intReportLogoWidth			INT,
			@intFirstHalfNoOfDocuments	INT,
			@strFirstHalfDocuments		NVARCHAR(MAX),
			@strSecondHalfDocuments		NVARCHAR(MAX),
			@strReportTo				NVARCHAR(MAX),
			@strOurCommn				NVARCHAR(MAX),
			@strBrkgCommn				NVARCHAR(MAX),
			@strApplicableLaw			NVARCHAR(MAX),
			@strGeneralCondition		NVARCHAR(MAX),
			@ysnExternal				BIT,
			@intStraussCompanyId INT,
			@intMultiCompanyParentId INT = 0

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
	
	DECLARE @tblContractDocument AS TABLE 
	(
		 intContractDocumentKey INT IDENTITY(1, 1)
		,strDocumentName NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
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

	SELECT @intReportLogoHeight = intReportLogoHeight,@intReportLogoWidth = intReportLogoWidth FROM tblLGCompanyPreference WITH (NOLOCK)

	INSERT INTO @tblSequenceHistoryId
	(
	  intSequenceAmendmentLogId
	)
	SELECT strValues FROM dbo.fnARGetRowsFromDelimitedValues(@strSequenceHistoryId)

	SELECT	@intContractHeaderId = intContractHeaderId
	FROM	tblCTSequenceAmendmentLog WITH (NOLOCK)   
	WHERE	intSequenceAmendmentLogId = (SELECT MIN(intSequenceAmendmentLogId) FROM @tblSequenceHistoryId)

	SELECT @intScreenId=intScreenId FROM tblSMScreen WITH (NOLOCK) WHERE ysnApproval=1 AND strNamespace='ContractManagement.view.Contract'--ContractManagement.view.ContractAmendment
	SELECT @intTransactionId=intTransactionId,@IsFullApproved = ysnOnceApproved FROM tblSMTransaction WITH (NOLOCK) WHERE intScreenId=@intScreenId AND intRecordId=@intContractHeaderId

	SELECT	@strCommodityCode	=	CM.strCommodityCode,
			@ysnPrinted			=	CH.ysnPrinted,
			@strReportTo		=	strReportTo,
   			@intStraussCompanyId = CH.intCompanyId
	FROM	tblCTContractHeader CH	WITH (NOLOCK)
	JOIN	tblICCommodity		CM	WITH (NOLOCK) ON	CM.intCommodityId		=	CH.intCommodityId
	WHERE	CH.intContractHeaderId = @intContractHeaderId

	 if (@intStraussCompanyId is not null and @intStraussCompanyId > 0)
	 begin
		set @intMultiCompanyParentId = (select isnull(intMultiCompanyParentId,0) from tblSMMultiCompany where intMultiCompanyId = @intStraussCompanyId);
	 end

	IF @IsFullApproved = 1	
	BEGIN	
		SET @strApprovalText='This document concerns the Confirmed Agreement between Parties. Please sign in twofold and return to KDE as follows: one PDF-copy of the signed original by e-mail.'	
	END
	ELSE
		SET @strApprovalText='This document concerns an unconfirmed agreement. Please check this unconfirmed agreement and let us know if you find any discrepancies; If no notification of discrepancy has been received by us from you within 24 hours after receipt of this document, this unconfirmed agreement becomes confirmed from Supplier side. Once confirmed from Supplier side, KDE will check the document on discrepancies. If no discrepancies are found, a confirmed agreement will be issued by KDE, replacing the unconfirmed agreement. A confirmed agreement will only be binding for KDE once it has been signed by the authorized KDE representatives. Upon receipt of the confirmed agreement signed by KDE, Supplier shall sign the confirmed agreement and return it to KDE'

	IF @strCommodityCode = 'Tea'
		SET @strApprovalText = NULL

    SELECT TOP 1 @StraussContractSubmitId=intSubmittedById FROM tblSMApproval WHERE intTransactionId=@intTransactionId ORDER BY intApprovalId
    SELECT TOP 1 @FirstApprovalId=intApproverId,@intApproverGroupId = intApproverGroupId FROM tblSMApproval WHERE intTransactionId=@intTransactionId AND strStatus='Approved' ORDER BY intApprovalId
	SELECT TOP 1 @SecondApprovalId=intApproverId FROM tblSMApproval WHERE intTransactionId=@intTransactionId AND strStatus='Approved' AND (intApproverId <> @FirstApprovalId OR ISNULL(intApproverGroupId,0) <> @intApproverGroupId) ORDER BY intApprovalId

	SELECT	@FirstApprovalSign = Sig.blbDetail, @FirstApprovalName = fe.strName
	FROM	tblSMSignature Sig WITH (NOLOCK)
	JOIN	tblEMEntitySignature ES ON Sig.intSignatureId = ES.intElectronicSignatureId
	LEFT JOIN tblEMEntity fe on fe.intEntityId = @FirstApprovalId
	WHERE	Sig.intEntityId=@FirstApprovalId

	SELECT	@SecondApprovalSign = Sig.blbDetail, @SecondApprovalName = se.strName
	FROM	tblSMSignature Sig  WITH (NOLOCK)
	JOIN	tblEMEntitySignature ES ON Sig.intSignatureId = ES.intElectronicSignatureId
	LEFT JOIN tblEMEntity se on se.intEntityId = @SecondApprovalId
	WHERE	Sig.intEntityId=@SecondApprovalId

	SELECT	@InterCompApprovalSign =Sig.blbDetail 
	FROM	tblCTIntrCompApproval	IA
	JOIN	tblSMUserSecurity		US	ON	US.strUserName		=	IA.strUserName	
	JOIN	tblSMSignature			Sig	ON	US.intEntityId		=	Sig.intEntityId
	JOIN	tblEMEntitySignature	ES	ON	Sig.intSignatureId	=	ES.intElectronicSignatureId
	WHERE	IA.intContractHeaderId	=	@intContractHeaderId
	AND		IA.strScreen	=	'Contract'

	SELECT @FirstApprovalSign =  Sig.blbDetail, @FirstApprovalName = ent.strName 
								 FROM tblSMSignature Sig  WITH (NOLOCK)
								 --JOIN tblEMEntitySignature ESig ON ESig.intElectronicSignatureId=Sig.intSignatureId
								 left join tblEMEntity ent on ent.intEntityId = Sig.intEntityId
								 WHERE Sig.intEntityId=@FirstApprovalId

	SELECT @SecondApprovalSign =Sig.blbDetail, @SecondApprovalName = ent.strName
								FROM tblSMSignature Sig  WITH (NOLOCK)
								--JOIN tblEMEntitySignature ESig ON ESig.intElectronicSignatureId=Sig.intSignatureId 
								 left join tblEMEntity ent on ent.intEntityId = Sig.intEntityId
								WHERE Sig.intEntityId=@SecondApprovalId	


	SELECT @StraussContractApproverSignature =  Sig.blbDetail 
								 FROM tblSMSignature Sig  WITH (NOLOCK)
								 JOIN tblEMEntitySignature ESig ON ESig.intElectronicSignatureId=Sig.intSignatureId
								 left join tblEMEntity ent on ent.intEntityId = Sig.intEntityId
								 WHERE Sig.intEntityId=@FirstApprovalId


	SELECT @StraussContractSubmitSignature =  Sig.blbDetail 
								 FROM tblSMSignature Sig  WITH (NOLOCK)
								 JOIN tblEMEntitySignature ESig ON ESig.intElectronicSignatureId=Sig.intSignatureId
								 left join tblEMEntity ent on ent.intEntityId = Sig.intEntityId
								 WHERE Sig.intEntityId=@StraussContractSubmitId


	SELECT	@strCompanyName	=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) = '' THEN NULL ELSE LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) END,
			@strAddress		=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strAddress)) = '' THEN NULL ELSE LTRIM(RTRIM(tblSMCompanySetup.strAddress)) END,
			@strCounty		=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(isnull(rtrt9.strTranslation,tblSMCompanySetup.strCountry))) END,
			@strCity		=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strCity)) = '' THEN NULL ELSE LTRIM(RTRIM(tblSMCompanySetup.strCity)) END,
			@strState		=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strState)) = '' THEN NULL ELSE LTRIM(RTRIM(tblSMCompanySetup.strState)) END,
			@strZip			=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strZip)) = '' THEN NULL ELSE LTRIM(RTRIM(tblSMCompanySetup.strZip)) END,
			@strCountry		=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(isnull(rtrt9.strTranslation,tblSMCompanySetup.strCountry))) END
	FROM	tblSMCompanySetup WITH (NOLOCK)
	left join tblSMCountry				rtc9 WITH (NOLOCK) on lower(rtrim(ltrim(rtc9.strCountry))) = lower(rtrim(ltrim(tblSMCompanySetup.strCountry)))
	left join tblSMScreen				rts9 WITH (NOLOCK) on rts9.strNamespace = 'i21.view.Country'
	left join tblSMTransaction			rtt9 WITH (NOLOCK) on rtt9.intScreenId = rts9.intScreenId and rtt9.intRecordId = rtc9.intCountryID
	left join tblSMReportTranslation	rtrt9 WITH (NOLOCK) on rtrt9.intLanguageId = @intLaguageId and rtrt9.intTransactionId = rtt9.intTransactionId and rtrt9.strFieldName = 'Country'

	INSERT INTO @tblContractDocument(strDocumentName)
	SELECT 			
		DM.strDocumentName
	FROM tblCTContractDocument CD WITH (NOLOCK)	
	JOIN tblICDocument DM WITH (NOLOCK) ON DM.intDocumentId = CD.intDocumentId	
	WHERE CD.intContractHeaderId = @intContractHeaderId
	ORDER BY DM.strDocumentName
	
	SELECT @intFirstHalfNoOfDocuments = CEILING(COUNT(1)/2.0) FROM @tblContractDocument	

	SELECT @strFirstHalfDocuments = STUFF((
										SELECT strDocumentName + CHAR(13) + CHAR(10)
										FROM @tblContractDocument WHERE intContractDocumentKey < = @intFirstHalfNoOfDocuments
										FOR XML PATH('')
											,TYPE
										).value('.', 'varchar(max)'), 1, 0, '')
							    FROM @tblContractDocument

	SELECT @strSecondHalfDocuments = STUFF((
										SELECT strDocumentName + CHAR(13) + CHAR(10)
										FROM @tblContractDocument WHERE intContractDocumentKey > @intFirstHalfNoOfDocuments
										FOR XML PATH('')
											,TYPE
										).value('.', 'varchar(max)'), 1, 0, '')
							    FROM @tblContractDocument

	SELECT	@strContractDocuments = STUFF(								
			   (SELECT			
					CHAR(13)+CHAR(10) + DM.strDocumentName	
					FROM tblCTContractDocument CD	
					JOIN tblICDocument DM WITH (NOLOCK) ON DM.intDocumentId = CD.intDocumentId	
					WHERE CD.intContractHeaderId=CH.intContractHeaderId	
					ORDER BY DM.strDocumentName		
					FOR XML PATH(''), TYPE				
			   ).value('.','varchar(max)')
			   ,1,2, ''						
		  ),
		  @ysnExternal = (case when intBookVsEntityId > 0 then convert(bit,1) else convert(bit,0) end)		
	FROM tblCTContractHeader CH
	left join tblCTBookVsEntity be on be.intEntityId = CH.intEntityId
	WHERE CH.intContractHeaderId = @intContractHeaderId

	SELECT	@strContractConditions = STUFF(								
			(
					SELECT	CHAR(13)+CHAR(10) + dbo.[fnCTGetTranslation]('ContractManagement.view.Condition',CD.intConditionId,@intLaguageId,'Description',DM.strConditionDesc)
					FROM	tblCTContractCondition	CD  WITH (NOLOCK)
					JOIN	tblCTCondition			DM	WITH (NOLOCK) ON DM.intConditionId = CD.intConditionId	
					WHERE	CD.intContractHeaderId	=	CH.intContractHeaderId	
					ORDER BY DM.strConditionName		
					FOR XML PATH(''), TYPE				
			   ).value('.','varchar(max)')
			   ,1,2, ''						
			)  				
	FROM	tblCTContractHeader CH WITH (NOLOCK)						
	WHERE	CH.intContractHeaderId = @intContractHeaderId

	SELECT	@strApplicableLaw = dbo.[fnCTGetTranslation]('ContractManagement.view.Condition',CD.intConditionId,@intLaguageId,'Description',DM.strConditionDesc)
	FROM	tblCTContractCondition	CD  WITH (NOLOCK)
	JOIN	tblCTCondition			DM	WITH (NOLOCK) ON DM.intConditionId = CD.intConditionId	
	WHERE	CD.intContractHeaderId	=	@intContractHeaderId
	AND		UPPER(DM.strConditionName)	=	'APPLICABLE LAW'

	SELECT	@strGeneralCondition = STUFF(								
			(
					SELECT	--CHAR(13)+CHAR(10) + 
							'  </br>' + dbo.[fnCTGetTranslation]('ContractManagement.view.Condition',CD.intConditionId,1,'Description',DM.strConditionDesc)
					FROM	tblCTContractCondition	CD  WITH (NOLOCK)
					JOIN	tblCTCondition			DM	WITH (NOLOCK) ON DM.intConditionId = CD.intConditionId	
					WHERE	CD.intContractHeaderId	=	CH.intContractHeaderId	AND (UPPER(DM.strConditionName)	= 'GENERAL CONDITION' OR UPPER(DM.strConditionName) LIKE	'%GENERAL_CONDITION')
					ORDER BY DM.intConditionId		
					FOR XML PATH(''), TYPE				
			   ).value('.','varchar(max)')
			   ,1,2, ''						
			)
	FROM	tblCTContractHeader CH WITH (NOLOCK)						
	WHERE	CH.intContractHeaderId = @intContractHeaderId

	IF EXISTS
	(
				SELECT	TOP 1 1 
				FROM	tblCTContractCertification	CC  WITH (NOLOCK)
				JOIN	tblCTContractDetail			CH	WITH (NOLOCK) ON	CC.intContractDetailId	=	CH.intContractDetailId
				JOIN	tblICCertification			CF	WITH (NOLOCK) ON	CF.intCertificationId	=	CC.intCertificationId	
				WHERE	UPPER(CF.strCertificationName) = 'FAIRTRADE' AND CH.intContractHeaderId = @intContractHeaderId
	)
	BEGIN
		SET @ysnFairtrade = 1
	END

	SELECT @intContractDetailId = MIN(intContractDetailId) FROM tblCTContractDetail WITH (NOLOCK) WHERE intContractHeaderId = @intContractHeaderId

	WHILE ISNULL(@intContractDetailId,0) > 0
	BEGIN
		SELECT @intPrevApprovedContractId = NULL, @intLastApprovedContractId = NULL
		SELECT TOP 1 @intLastApprovedContractId =  intApprovedContractId,@dtmApproved = dtmApproved 
		FROM   tblCTApprovedContract  WITH (NOLOCK)
		WHERE  intContractDetailId = @intContractDetailId AND strApprovalType IN ('Amendment and Approvals','Contract Amendment ') AND ysnApproved = 1
		ORDER BY intApprovedContractId DESC

		SELECT TOP 1 @intPrevApprovedContractId =  intApprovedContractId
		FROM   tblCTApprovedContract  WITH (NOLOCK)
		WHERE  intContractDetailId = @intContractDetailId AND intApprovedContractId < @intLastApprovedContractId AND ysnApproved = 1
		ORDER BY intApprovedContractId DESC

		IF @intPrevApprovedContractId IS NOT NULL AND @intLastApprovedContractId IS NOT NULL
		BEGIN
			EXEC uspCTCompareRecords 'tblCTApprovedContract', @intPrevApprovedContractId, @intLastApprovedContractId,'intApprovedById,dtmApproved,
			intContractBasisId,dtmPlannedAvailabilityDate,strOrigin,dblNetWeight,intNetWeightUOMId,
			intSubLocationId,intStorageLocationId,intPurchasingGroupId,strApprovalType,strVendorLotID,ysnApproved,intCertificationId,intLoadingPortId', @strAmendedColumns OUTPUT
		END
		 
		 SELECT @intContractDetailId = MIN(intContractDetailId) FROM tblCTContractDetail WITH (NOLOCK) WHERE intContractHeaderId = @intContractHeaderId AND intContractDetailId > @intContractDetailId
	 END

	IF @strAmendedColumns IS NULL AND EXISTS(SELECT 1 FROM @tblSequenceHistoryId)
	BEGIN
		 SELECT  @strAmendedColumns= STUFF((
											SELECT DISTINCT ',' + LTRIM(RTRIM(AAP.strDataIndex))
											FROM tblCTAmendmentApproval AAP
											JOIN tblCTSequenceAmendmentLog AL WITH (NOLOCK) ON AL.intAmendmentApprovalId =AAP.intAmendmentApprovalId
											JOIN @tblSequenceHistoryId SH  ON SH.intSequenceAmendmentLogId  = AL.intSequenceAmendmentLogId  
											WHERE ISNULL(AAP.ysnAmendment,0) =1
											FOR XML PATH('')
											), 1, 1, '')
        
		SELECT @strDetailAmendedColumns = STUFF((
										  		SELECT DISTINCT ',' + LTRIM(RTRIM(AAP.strDataIndex))
										  		FROM tblCTAmendmentApproval AAP
										  		JOIN tblCTSequenceAmendmentLog AL WITH (NOLOCK) ON AL.intAmendmentApprovalId =AAP.intAmendmentApprovalId
										  		JOIN @tblSequenceHistoryId SH  ON SH.intSequenceAmendmentLogId  = AL.intSequenceAmendmentLogId 
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
	declare @rtStrBrokerCommissionMessage1 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'It is understood that your commission is'),'It is understood that your commission is');
	declare @rtStrBrokerCommissionMessage2 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'and will be paid by'),'and will be paid by');
	declare @rtStrBrokerCommissionMessage3 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'to you directly.'),'to you directly.');
	declare @rtStrBrokerCommissionPer nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'per'),'per');
	
	SELECT @TotalAtlasLots= CASE 
								 WHEN SUM(dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, UOM.intUnitMeasureId, MA.intUnitMeasureId, CD.dblQuantity) / MA.dblContractSize) < 1 THEN 1
								 ELSE ROUND(SUM(dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, UOM.intUnitMeasureId, MA.intUnitMeasureId, CD.dblQuantity) / MA.dblContractSize),0)
							END,
		  @TotalLots		=	SUM(CD.dblNoOfLots)
							FROM tblCTContractDetail CD WITH (NOLOCK)
							JOIN tblICItemUOM UOM WITH (NOLOCK) ON UOM.intItemUOMId = CD.intItemUOMId
							JOIN tblRKFutureMarket MA WITH (NOLOCK) ON MA.intFutureMarketId = CD.intFutureMarketId
							WHERE CD.intContractHeaderId = @intContractHeaderId

	IF @type = 'MULTIPLE'
	BEGIN
		SELECT @ErrMsg =  STUFF((
										  		SELECT DISTINCT '-' + RIGHT(strContractNumber,3)
										  		FROM tblCTContractHeader WITH (NOLOCK)
										  		WHERE intContractHeaderId IN (SELECT Item FROM dbo.fnSplitString(@strIds,','))
												AND intContractHeaderId <> @intContractHeaderId
										  		FOR XML PATH('')
										  		), 1, 1, '')
	END
	
	----Commission
	SELECT  @strOurCommn	= 
			CASE	WHEN @strReportTo = 'Seller' 
					THEN	dbo.fnCTChangeNumericScale(dblRate,2) + ' ' + strCurrency + ' / ' + strUOM + ' included, payable by sellers'
				ELSE	'' 
			END
	FROM	vyuCTContractCostView 
	WHERE	intContractHeaderId = @intContractHeaderId 
	AND		strParty = 'Vendor'

	SELECT  @strBrkgCommn	=
			CASE	WHEN strParty = 'Broker' AND @strReportTo = strPaidBy
						THEN	dbo.fnCTChangeNumericScale(CC.dblRate,2) + ' ' + CC.strCurrency + ' / ' + CC.strUOM + ' included to be paid directly to:' + CHAR(13)+CHAR(10) +
								LTRIM(RTRIM(EY.strEntityName)) + ', '				+ CHAR(13)+CHAR(10) +
								ISNULL(LTRIM(RTRIM(EY.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
								ISNULL(LTRIM(RTRIM(EY.strEntityCity)),'') + 
								ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityZipCode)) END,'') + 
								ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityState)) = ''   THEN NULL ELSE LTRIM(RTRIM(EY.strEntityState))   END,'') + CHAR(13)+CHAR(10) +
								ISNULL(CASE WHEN LTRIM(RTRIM(EY.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(dbo.fnCTGetTranslation('i21.view.Country',CY.intCountryID,@intLaguageId,'Country',CY.strCountry))) END,'')
					ELSE	'' 
			END
	FROM	vyuCTContractCostView	CC
	JOIN	vyuCTEntity				EY ON EY.intEntityId = CC.intVendorId AND EY.strEntityType = 'Broker'
	LEFT	JOIN tblSMCountry		CY ON lower(rtrim(ltrim(CY.strCountry))) = lower(rtrim(ltrim(EY.strEntityCountry)))
	WHERE	CC.intContractHeaderId = @intContractHeaderId 
	AND		strParty = 'Broker'
	--------------------

	SELECT	 intContractHeaderId					= CH.intContractHeaderId
			,strCaption								= isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,TP.strContractType), TP.strContractType) + ' '+@rtContract+':- ' + CH.strContractNumber
			,strHersheyCaption						= isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,TP.strContractType), TP.strContractType) + ' '+@rtConfirmation+': ' + CH.strContractNumber
			,strCaptionBGT							= TP.strContractType + ' Contract: ' + CH.strContractNumber
			,strCaptionEQT							= TP.strContractType + ' Contract'
			,strTeaCaption							= @strCompanyName + ' - '+TP.strContractType+' '  + @rtContract
			,strAtlasDeclaration					= @rtWeConfirmHaving			   + CASE WHEN CH.intContractTypeId = 1	   THEN ' '+@rtBoughtFrom+' '   ELSE ' '+@rtSoldTo+' ' END + @rtYouAsFollows + ':'
			,strPurchaseOrder						= TP.strContractType + ' '+@rtOrder+':- ' + CASE WHEN CM.strCommodityCode = 'Tea' THEN SQ.strERPPONumber ELSE NULL        END
			,dtmContractDate						= CH.dtmContractDate
			,strAssociation							= @rtStrAssociation1 + ' '+ dbo.fnCTGetTranslation('ContractManagement.view.Associations',AN.intAssociationId,@intLaguageId,'Printable Contract Text',AN.strComment)
													+ ' ('+dbo.fnCTGetTranslation('ContractManagement.view.Associations',AN.intAssociationId,@intLaguageId,'Name',AN.strName)+')'+' '+@rtStrAssociation2+'.'
			,strBuyerRefNo							= CASE WHEN CH.intContractTypeId = 1 THEN CH.strContractNumber ELSE CH.strCustomerContract END
			,strSellerRefNo							= CASE WHEN CH.intContractTypeId = 2 THEN CH.strContractNumber ELSE CH.strCustomerContract END
			,strContractNumber						= CH.strContractNumber
			,strContractNumberStrauss				= CH.strContractNumber + (case when LEN(LTRIM(RTRIM(ISNULL(@strAmendedColumns,'')))) = 0 then '' else ' - AMENDMENT' end)
			,strCustomerContract					= CH.strCustomerContract
			,strContractBasis						= CB.strFreightTerm
			,strContractBasisDesc					= CB.strFreightTerm+' '+CASE WHEN CB.strINCOLocationType = 'City' THEN CT.strCity ELSE SL.strSubLocationName END
			,strCityWarehouse						= CASE WHEN CB.strINCOLocationType = 'City' THEN CT.strCity ELSE SL.strSubLocationName END
			,strLocationName						= SQ.strLocationName			
			,strCropYear							= CY.strCropYear
			,srtLoadingPoint						= SQ.srtLoadingPoint
			,strLoadingPointName					= SQ.strLoadingPointName
			,strShipper								= SQ.strShipper
			,srtDestinationPoint					= SQ.srtDestinationPoint 
			,strDestinationPointName				= (case when PO.strPositionType = 'Spot' then CT.strCity else SQ.strDestinationPointName end)
			,strLoadingAndDestinationPointName		= SQ.strLoadingPointName + ' '+@rtTo+' ' + SQ.strDestinationPointName
			,strWeight								= dbo.fnCTGetTranslation('ContractManagement.view.WeightGrades',W1.intWeightGradeId,@intLaguageId,'Name',W1.strWeightGradeDesc)
			,strTerm							    = dbo.fnCTGetTranslation('i21.view.Term',TM.intTermID,@intLaguageId,'Terms',TM.strTerm) 
			,strGrade								= dbo.fnCTGetTranslation('ContractManagement.view.WeightGrades',W2.intWeightGradeId,@intLaguageId,'Name',W2.strWeightGradeDesc) 
			,strQaulityAndInspection				= @rtStrQaulityAndInspection1 + ' ' + ' - ' + dbo.fnCTGetTranslation('ContractManagement.view.WeightGrades',W2.intWeightGradeId,@intLaguageId,'Name',W2.strWeightGradeDesc) + ' '+@rtStrQaulityAndInspection2+' ' + @strCompanyName + '''s '+@rtStrQaulityAndInspection3+'.'
			,strContractDocuments					= @strContractDocuments
			,strFirstHalfDocuments					= LTRIM(@strFirstHalfDocuments)
			,strSecondHalfDocuments				    = LTRIM(@strSecondHalfDocuments)
			,strArbitration							= @rtStrArbitration1 + ' '+ dbo.fnCTGetTranslation('ContractManagement.view.Associations',AN.intAssociationId,@intLaguageId,'Printable Contract Text',AN.strComment) + '  '+@rtStrArbitration2+'. ' 
														+ CHAR(13)+CHAR(10) +
														@rtStrArbitration3 + ' ' + AB.strState +', '+ dbo.fnCTGetTranslation('i21.view.Country',RY.intCountryID,@intLaguageId,'Country',RY.strCountry)
			,strGABArbitration						= ISNULL(NULLIF(AB.strState, ''), AB.strCity) +', '+ dbo.fnCTGetTranslation('i21.view.Country',RY.intCountryID,@intLaguageId,'Country',RY.strCountry)
			,strBeGreenArbitration					=   AB.strCity
			,strEQTArbitration						=   AB.strCity
			,strCompanyAddress						=   @strCompanyName + ', '		  + CHAR(13)+CHAR(10) +
														ISNULL(@strAddress,'') + ', ' + CHAR(13)+CHAR(10) +
														ISNULL(@strCity,'') + ISNULL(', '+@strState,'') + ISNULL(', '+@strZip,'') + ISNULL(', '+@strCountry,'')
			,strStraussOtherPartyAddress     = '<span style="font-family:Arial;font-size:12px;">' + CASE   
               WHEN CH.strReportTo = 'Buyer' THEN --Customer  
                LTRIM(RTRIM(EC.strEntityName)) + '</br>'    +-- CHAR(13)+CHAR(10) +  
                ISNULL(LTRIM(RTRIM(EC.strEntityAddress)),'') + '</br>' +-- CHAR(13)+CHAR(10) +  
                ISNULL(LTRIM(RTRIM(EC.strEntityCity)),'') +   
                ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityState)) = ''   THEN NULL ELSE LTRIM(RTRIM(EC.strEntityState))   END,'') +   
                ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityZipCode)) END,'') +   
                ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(dbo.fnCTGetTranslation('i21.view.Country',rtc12.intCountryID,@intLaguageId,'Country',rtc12.strCountry))) END,'') +  
                CASE WHEN @ysnFairtrade = 1 THEN  
                 ISNULL( CHAR(13)+CHAR(10) + @rtFLOID + ': '+CASE WHEN LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) = '' THEN NULL ELSE LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) END,'')  
                ELSE '' END               
               ELSE -- Seller (Vendor)  
                LTRIM(RTRIM(EY.strEntityName)) + '</br>' + --CHAR(13)+CHAR(10) +  
                ISNULL(LTRIM(RTRIM(EY.strEntityAddress)),'') + '</br>' + --CHAR(13)+CHAR(10) +  
                ISNULL(LTRIM(RTRIM(EY.strEntityCity)),'') +   
                ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityState)) = ''   THEN NULL ELSE LTRIM(RTRIM(EY.strEntityState))   END,'') +   
                ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityZipCode)) END,'') +   
                ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(dbo.fnCTGetTranslation('i21.view.Country',rtc10.intCountryID,@intLaguageId,'Country',rtc10.strCountry))) END,'') +  
                CASE WHEN @ysnFairtrade = 1 THEN  
                 ISNULL( CHAR(13)+CHAR(10) + @rtFLOID + ': '+CASE WHEN LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) = '' THEN NULL ELSE LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) END,'')  
                ELSE '' END  
               END + '</span>'
			,strOtherPartyAddress					= CASE 
													  WHEN CH.strReportTo = 'Buyer' THEN --Customer
													  	LTRIM(RTRIM(EC.strEntityName)) + ', '				+ CHAR(13)+CHAR(10) +
													  	ISNULL(LTRIM(RTRIM(EC.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
													  	ISNULL(LTRIM(RTRIM(EC.strEntityCity)),'') + 
													  	ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityState)) = ''   THEN NULL ELSE LTRIM(RTRIM(EC.strEntityState))   END,'') + 
													  	ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityZipCode)) END,'') + 
													  	ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(dbo.fnCTGetTranslation('i21.view.Country',rtc12.intCountryID,@intLaguageId,'Country',rtc12.strCountry))) END,'') +
													  	CASE WHEN @ysnFairtrade = 1 THEN
													  		ISNULL( CHAR(13)+CHAR(10) + @rtFLOID + ': '+CASE WHEN LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) = '' THEN NULL ELSE LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) END,'')
													  	ELSE '' END													
													  ELSE -- Seller (Vendor)
													  	LTRIM(RTRIM(EY.strEntityName)) + ', '				+ CHAR(13)+CHAR(10) +
													  	ISNULL(LTRIM(RTRIM(EY.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
													  	ISNULL(LTRIM(RTRIM(EY.strEntityCity)),'') + 
													  	ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityState)) = ''   THEN NULL ELSE LTRIM(RTRIM(EY.strEntityState))   END,'') + 
													  	ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityZipCode)) END,'') + 
													  	ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(dbo.fnCTGetTranslation('i21.view.Country',rtc10.intCountryID,@intLaguageId,'Country',rtc10.strCountry))) END,'') +
													  	CASE WHEN @ysnFairtrade = 1 THEN
													  		ISNULL( CHAR(13)+CHAR(10) + @rtFLOID + ': '+CASE WHEN LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) = '' THEN NULL ELSE LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) END,'')
													  	ELSE '' END
													  END
			,strGABOtherPartyAddress				=	CASE 
														WHEN CH.strReportTo = 'Buyer' THEN --Customer
															LTRIM(RTRIM(EC.strEntityName)) + ', '				+ CHAR(13)+CHAR(10) +
															ISNULL(LTRIM(RTRIM(EC.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
															
															ISNULL(CASE WHEN LTRIM(RTRIM(EC.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityZipCode)) END,'') +
															ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityCity)) = ''   THEN NULL ELSE LTRIM(RTRIM(EC.strEntityCity))   END,'') + CHAR(13)+CHAR(10) + 
															 
															ISNULL(CASE WHEN LTRIM(RTRIM(EC.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(dbo.fnCTGetTranslation('i21.view.Country',rtc10.intCountryID,@intLaguageId,'Country',rtc10.strCountry))) END,'') 
														ELSE -- Seller (Vendor)
															LTRIM(RTRIM(EY.strEntityName)) + ', '				+ CHAR(13)+CHAR(10) +
															ISNULL(LTRIM(RTRIM(EY.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
															
															ISNULL(CASE WHEN LTRIM(RTRIM(EY.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityZipCode)) END,'') +
															ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityCity)) = ''   THEN NULL ELSE LTRIM(RTRIM(EY.strEntityCity))   END,'')  + CHAR(13)+CHAR(10) + 
															
															
															ISNULL(CASE WHEN LTRIM(RTRIM(EY.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(dbo.fnCTGetTranslation('i21.view.Country',rtc10.intCountryID,@intLaguageId,'Country',rtc10.strCountry))) END,'')
														END
			,strAtlasOtherPartyAddress				=   LTRIM(RTRIM(EY.strEntityName)) +' - '+ ISNULL(CASE WHEN LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) = '' THEN NULL ELSE LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) END,'')+ CHAR(13)+CHAR(10) +
														ISNULL(LTRIM(RTRIM(EY.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
														ISNULL(LTRIM(RTRIM(EY.strEntityCity)),'') + 
														ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityState)) = ''   THEN NULL ELSE LTRIM(RTRIM(EY.strEntityState))   END,'') + 
														ISNULL(' - '+CASE WHEN LTRIM(RTRIM(EY.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityZipCode)) END,'') + CHAR(13)+CHAR(10) + 
														ISNULL(CASE WHEN LTRIM(RTRIM(EY.strEntityCountry)) = ''      THEN NULL ELSE LTRIM(RTRIM(dbo.fnCTGetTranslation('i21.view.Country',rtc10.intCountryID,@intLaguageId,'Country',rtc10.strCountry))) END,'') 

			,strBrokerAddress						=   LTRIM(RTRIM(EB.strEntityName)) +' - '+ ISNULL(CASE WHEN LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) = '' THEN NULL ELSE LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) END,'')+ CHAR(13)+CHAR(10) +
														ISNULL(LTRIM(RTRIM(EB.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
														ISNULL(LTRIM(RTRIM(EB.strEntityCity)),'') + 
														ISNULL(', '+CASE WHEN LTRIM(RTRIM(EB.strEntityState)) = ''   THEN NULL ELSE LTRIM(RTRIM(EB.strEntityState))   END,'') + 
														ISNULL(' - '+CASE WHEN LTRIM(RTRIM(EB.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EB.strEntityZipCode)) END,'') + CHAR(13)+CHAR(10) + 
														ISNULL(CASE WHEN LTRIM(RTRIM(EB.strEntityCountry)) = ''      THEN NULL ELSE LTRIM(RTRIM(dbo.fnCTGetTranslation('i21.view.Country',rtc10.intCountryID,@intLaguageId,'Country',rtc10.strCountry))) END,'') 
			,strBrokerCommissionMessage				= @rtStrBrokerCommissionMessage1 + ' ' + EB.strBrokerCommission + ' ' + @rtStrBrokerCommissionMessage2 + ' ' 
														+ dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId, CASE WHEN EB.strPaidBy = 'Company' THEN 'us' ELSE EB.strPaidBy END) + ' ' + @rtStrBrokerCommissionMessage3
			,strBuyer							    = CASE WHEN CH.intContractTypeId = 1 THEN @strCompanyName ELSE EY.strEntityName END
			,strSeller							    = CASE WHEN CH.intContractTypeId = 2 THEN @strCompanyName ELSE EY.strEntityName END
			,strAtlasSeller							= CASE WHEN CH.intContractTypeId = 2 THEN @strCompanyName ELSE EY.strEntityName +' - '+ ISNULL(CASE WHEN LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) = '' THEN NULL ELSE LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) END,'') END
			,dblQuantity						    = CH.dblQuantity
			,strCurrency						    = SQ.strCurrency
			,strInsuranceBy						    = @rtStrInsuranceBy + ' ' + IB.strInsuranceBy			
			,strPrintableRemarks				    = CH.strPrintableRemarks			
			,strArbitrationComment				    = dbo.fnCTGetTranslation('ContractManagement.view.Associations',AN.intAssociationId,@intLaguageId,'Printable Contract Text',AN.strComment)	
			,blbHeaderLogo						    = dbo.fnSMGetCompanyLogo('Header')
			,blbFooterLogo						    = dbo.fnSMGetCompanyLogo('Footer') 
			,strProducer							= PR.strName
			,strPosition							= PO.strPosition
			,strContractConditions				    = @strContractConditions
			,lblAtlasLocation						= CASE WHEN ISNULL(CASE WHEN CB.strINCOLocationType = 'City' THEN CT.strCity ELSE SL.strSubLocationName END,'') <>''     THEN @rtLocation + ' :'					ELSE NULL END
			,lblContractDocuments					= CASE WHEN ISNULL(@strContractDocuments,'') <>''	   THEN @rtDocumentsRequired + ' :'			ELSE NULL END
			,lblAtlasContractDocuments				= CASE WHEN ISNULL(@strContractDocuments,'') <>''	   THEN @rtDocumentsRequired			ELSE NULL END
			,lblAtlasContractDocumentsColon			= CASE WHEN ISNULL(@strContractDocuments,'') <>''	   THEN ':'			ELSE NULL END
			,lblArbitrationComment					= CASE WHEN ISNULL(AN.strComment,'') <>''			   THEN @rtContract2 + ' :'					ELSE NULL END
			,lblAtlasArbitrationComment				= CASE WHEN ISNULL(AN.strComment,'') <>''			   THEN @rtContract2				ELSE NULL END
			,lblAtlasArbitrationCommentColon		= CASE WHEN ISNULL(AN.strComment,'') <>''			   THEN ':'					ELSE NULL END
			,lblBeGreenArbitrationComment			= CASE WHEN ISNULL(AN.strComment,'') <>''			   THEN 'Rule :'							ELSE NULL END
			,lblPrintableRemarks					= CASE WHEN ISNULL(CH.strPrintableRemarks,'') <>''	   THEN @rtNotesRemarks + ' :'				ELSE NULL END
			,lblAtlasPrintableRemarks				= CASE WHEN ISNULL(CH.strPrintableRemarks,'') <>''	   THEN @rtNotesRemarks			ELSE NULL END
			,lblAtlasPrintableRemarksColon			= CASE WHEN ISNULL(CH.strPrintableRemarks,'') <>''	   THEN ':'				ELSE NULL END
			,lblContractBasis						= CASE WHEN ISNULL(CB.strFreightTerm,'') <>''		   THEN @rtPriceBasis + ' :'					ELSE NULL END
			,lblIncoTerms							= CASE WHEN ISNULL(CB.strFreightTerm,'') <>''		   THEN 'Incoterms :'					ELSE NULL END
			,lblContractText						= CASE WHEN ISNULL(TX.strText,'') <>''				   THEN @rtOthers + ' :'						ELSE NULL END
			,lblAtlasContractText					= CASE WHEN ISNULL(TX.strText,'') <>''				   THEN @rtOthers						ELSE NULL END
			,lblAtlasContractTextColon				= CASE WHEN ISNULL(TX.strText,'') <>''				   THEN ':'						ELSE NULL END
			,lblCondition						    = CASE WHEN ISNULL(CB.strFreightTerm,'') <>''		   THEN @rtCondition + ' :'					ELSE NULL END
			,lblAtlasProducer						= CASE WHEN ISNULL(PR.strName,'') <>''				   THEN @rtProducer + ' :'					ELSE NULL END
			,lblProducer							= CASE WHEN ISNULL(PR.strName,'') <>''				   THEN @rtShipper + ' :'						ELSE NULL END
			,lblLoadingPoint						= CASE WHEN ISNULL(SQ.strLoadingPointName,'') <>''     THEN SQ.srtLoadingPoint + ' :'		ELSE NULL END
			,lblPosition							= CASE WHEN ISNULL(PO.strPosition,'') <>''		       THEN @rtPosition + ' :'					ELSE NULL END
			,lblCropYear							= CASE WHEN ISNULL(CY.strCropYear,'') <>''			   THEN @rtCropYear +' :'				    ELSE NULL END
			,lblShipper								= CASE WHEN ISNULL(SQ.strShipper,'') <>''			   THEN @rtShipper + ' :'					    ELSE NULL END 
			,lblDestinationPoint					= CASE WHEN ISNULL(SQ.strDestinationPointName,'') <>'' THEN SQ.srtDestinationPoint + ' :'   ELSE NULL END
			,lblWeighing						    = CASE WHEN ISNULL(W1.strWeightGradeDesc,'') <>''	   THEN @rtWeighing + ' :'					ELSE NULL END
			,lblAtlasWeighing						= CASE WHEN ISNULL(W1.strWeightGradeDesc,'') <>''	   THEN @rtWeighing							ELSE NULL END
			,lblAtlasWeighingColon					= CASE WHEN ISNULL(W1.strWeightGradeDesc,'') <>''	   THEN ':'									ELSE NULL END
			,lblTerm								= CASE WHEN ISNULL(TM.strTerm,'') <>''				   THEN @rtPaymentTerms + ' :'				ELSE NULL END
			,lblAtlasTerm							= CASE WHEN ISNULL(TM.strTerm,'') <>''				   THEN @rtPaymentTerms						ELSE NULL END
			,lblAtlasTermColon						= CASE WHEN ISNULL(TM.strTerm,'') <>''				   THEN ':'									ELSE NULL END
			,lblGrade								= CASE WHEN ISNULL(W2.strWeightGradeDesc,'') <>''	   THEN @rtApprovalterm + ' :'				ELSE NULL END
			,lblAtlasGrade							= CASE WHEN ISNULL(W2.strWeightGradeDesc,'') <>''	   THEN @rtApprovalterm						ELSE NULL END
			,lblAtlasGradeColon						= CASE WHEN ISNULL(W2.strWeightGradeDesc,'') <>''	   THEN ':'									ELSE NULL END
			,lblInsurance							= CASE WHEN ISNULL(IB.strInsuranceBy,'') <>''		   THEN @rtInsurance + ':'					ELSE NULL END
			,lblContractCondition					= CASE WHEN ISNULL(@strContractConditions,'') <>''	   THEN @rtConditions + ':'					ELSE NULL END
			,lblAtlasContractCondition					= CASE WHEN ISNULL(@strContractConditions,'') <>''	   THEN @rtConditions				ELSE NULL END
			,lblAtlasContractConditionColon					= CASE WHEN ISNULL(@strContractConditions,'') <>''	   THEN ':'					ELSE NULL END
			--,strLocationWithDate					= SQ.strLocationName+', '+CONVERT(CHAR(11),CH.dtmContractDate,13)
			,strLocationWithDate					= SQ.strLocationName+', '+DATENAME(dd,CH.dtmContractDate) + ' ' + isnull(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,LEFT(DATENAME(MONTH,CH.dtmContractDate),3)), LEFT(DATENAME(MONTH,CH.dtmContractDate),3)) + ' ' + DATENAME(yyyy,CH.dtmContractDate)
			,strContractText						= ISNULL(TX.strText,'') 
	        ,strCondition							=	CASE WHEN LEN(LTRIM(RTRIM(ISNULL(@strAmendedColumns,'')))) = 0 THEN
																@rtStrCondition1 + ' '+ ISNULL(dbo.fnCTGetTranslation('ContractManagement.view.Associations',AN.intAssociationId,@intLaguageId,'Printable Contract Text',AN.strComment),'') + ' ('+ISNULL(dbo.fnCTGetTranslation('ContractManagement.view.Associations',AN.intAssociationId,@intLaguageId,'Name',AN.strName),'')+') '+@rtStrCondition2+'.' 
														ELSE
																@rtStrCondition3 + ' '+ CONVERT(NVARCHAR(15),ISNULL(@dtmApproved,''),106) + CHAR(13) + CHAR(10) + @rtStrCondition4 + '.'
														END
			
			,strPositionWithPackDesc			    = PO.strPosition +ISNULL(' ('+CASE WHEN SQ.strPackingDescription = '' THEN NULL ELSE SQ.strPackingDescription END+') ','')
			,strText							    = ISNULL(TX.strText,'') +' '+ ISNULL(CH.strPrintableRemarks,'') 
			,strContractCompanyName					= SQ.strContractCompanyName
			,strContractPrintSignOff			    = SQ.strContractPrintSignOff
			,strEntityName							= LTRIM(RTRIM(EY.strEntityName))
			,strApprovalText					    = @strApprovalText
			,FirstApprovalSign						= CASE WHEN @IsFullApproved=1 AND @strCommodityCode LIKE '%Coffee%' THEN @FirstApprovalSign  ELSE NULL END
			,SecondApprovalSign						= CASE WHEN @IsFullApproved=1 AND @strCommodityCode LIKE '%Coffee%' THEN @SecondApprovalSign ELSE NULL END
			,FirstApprovalName						= CASE WHEN @IsFullApproved=1 AND @strCommodityCode LIKE '%Coffee%' THEN @FirstApprovalName ELSE NULL END
			,SecondApprovalName						= CASE WHEN @IsFullApproved=1 AND @strCommodityCode LIKE '%Coffee%' THEN @SecondApprovalName ELSE NULL END
			,StraussContractApproverSignature		=  @StraussContractApproverSignature
			--,StraussContractSubmitSignature			=  @StraussContractSubmitSignature
			,StraussContractSubmitSignature   		=  (case when @intMultiCompanyParentId > 0 and CH.intContractTypeId = 1 then null else @StraussContractSubmitSignature  end)
   			,StraussContractSubmitByParentSignature =  (case when @intMultiCompanyParentId > 0 and CH.intContractTypeId = 1 then @StraussContractSubmitSignature else null  end)
			,InterCompApprovalSign					= @InterCompApprovalSign
			,strAmendedColumns						= @strAmendedColumns
			,lblArbitration							= CASE WHEN ISNULL(AN.strComment,'') <>''	 AND ISNULL(AB.strState,'') <>''		 AND ISNULL(RY.strCountry,'') <>'' THEN @rtArbitration + ':'  ELSE NULL END
			,lblPricing								= CASE WHEN ISNULL(SQ.strFixationBy,'') <>'' AND ISNULL(SQ.strFutMarketName,'') <>'' AND CH.intPricingTypeId=2		   THEN @rtPricing + ' :'		ELSE NULL END
			,lblAtlasPricing						= CASE WHEN ISNULL(SQ.strFixationBy,'') <>'' AND ISNULL(SQ.strFutMarketName,'') <>'' AND CH.intPricingTypeId=2		   THEN @rtPricing ELSE NULL END
			,lblAtlasPricingColon					= CASE WHEN ISNULL(SQ.strFixationBy,'') <>'' AND ISNULL(SQ.strFutMarketName,'') <>'' AND CH.intPricingTypeId=2		   THEN ':' ELSE NULL END
			,strCaller								= CASE WHEN LTRIM(RTRIM(SQ.strFixationBy)) = '' THEN NULL ELSE SQ.strFixationBy END+'''s '+@rtCall+' ('+SQ.strFutMarketName+')' 
			,strHersheyCaller						= CASE WHEN LTRIM(RTRIM(SQ.strFixationBy)) = '' THEN NULL ELSE SQ.strFixationBy END+'''s '+@rtCall
			,lblBuyerRefNo							= CASE WHEN (CH.intContractTypeId = 1 AND ISNULL(CH.strContractNumber,'') <>'') OR (CH.intContractTypeId <> 1 AND ISNULL(CH.strCustomerContract,'') <>'') THEN  @rtBuyerRefNo + '. :'  ELSE NULL END
			,lblSellerRefNo							= CASE WHEN (CH.intContractTypeId = 2 AND ISNULL(CH.strContractNumber,'') <>'') OR (CH.intContractTypeId <> 2 AND ISNULL(CH.strCustomerContract,'') <>'') THEN  @rtSellerRefNo + '. :' ELSE NULL END
			,strAtlasCaller							= CASE WHEN ISNULL(SQ.strFixationBy,'') <> '' AND CH.intPricingTypeId = 2 THEN SQ.strFixationBy +'''s '+@rtCall+' vs '+LTRIM(@TotalAtlasLots)+' '+@rtLotssOf+' '+SQ.strFutMarketName + ' ' + @rtFutures ELSE NULL END
			,strBeGreenCaller						= CASE WHEN ISNULL(SQ.strFixationBy,'') <> '' THEN SQ.strFixationBy +'''s Call vs '+LTRIM(@TotalLots)+' lots(s) of '+SQ.strFutMarketName + ' futures' ELSE NULL END
			,strEQTCaller							= CASE WHEN ISNULL(SQ.strFixationBy,'') <> '' THEN SQ.strFixationBy +'''s Call vs '+LTRIM(@TotalLots)+' lots(s) of '+SQ.strFutMarketName + ' futures' ELSE NULL END
			,strCallerDesc						    = CASE WHEN LTRIM(RTRIM(SQ.strFixationBy)) = '' THEN NULL 
													  ELSE 
													  	  CASE WHEN CH.intPricingTypeId=2 THEN SQ.strFixationBy +'''s '+@rtCall+' ('+SQ.strFutMarketName+')'
													  	  ELSE NULL END
													  END 
			,strDetailAmendedColumns				= @strDetailAmendedColumns
		    ,strINCOTermWithWeight					=	dbo.fnCTGetTranslation('ContractManagement.view.INCOShipTerm',CB.intFreightTermId,@intLaguageId,'Contract Basis',CB.strFreightTerm) + ISNULL(', ' + dbo.fnCTGetTranslation('ContractManagement.view.WeightGrades',W1.intWeightGradeId,@intLaguageId,'Name',W1.strWeightGradeDesc),'')
			,strQuantityWithUOM						=	dbo.fnRemoveTrailingZeroes(CH.dblQuantity) + ' ' + dbo.fnCTGetTranslation('Inventory.view.ReportTranslation',UM.intUnitMeasureId,@intLaguageId,'Name',UM.strUnitMeasure) + ' ' + ISNULL(SQ.strNoOfContainerAndType, '')
			,strItemDescWithSpec					=	SQ.strItemDescWithSpec
			,strStartAndEndDate						=	SQ.strStartAndEndDate
			,strNoOfContainerAndType				=	SQ.strNoOfContainerAndType
			,strFutureMonthYear						=	SQ.strFutureMonthYear
			,strPricing								=	SQ.strFutMarketName + ' ' + SQ.strFutureMonthYear +
														CASE WHEN SQ.dblBasis < 0 THEN ' '+@rtMinus+' ' ELSE ' '+@rtPlus+' ' END +  
														dbo.fnRemoveTrailingZeroes(SQ.dblBasis) + ' ' + SQ.strPriceCurrencyAndUOM + 
														' '+@rtStrPricing1+' ' + SQ.strBuyerSeller + 
														'''s '+@rtStrPricing2+':'+dbo.fnRemoveTrailingZeroes(dblLotsToFix)+').'
			,strGABPricing							=	(
															case
															when pricingType.strPricingType = 'Basis'
															then  SQ.strFutMarketName + ' ' + SQ.strFutureMonthYear
																+
																CASE
																WHEN SQ.dblBasis < 0
																THEN ' '+@rtMinus+' '
																ELSE ' '+@rtPlus+' '
																END
																+  
																dbo.fnRemoveTrailingZeroes(SQ.dblBasis) + ' ' + SQ.strPriceCurrencyAndUOM + ' '+@rtStrPricing1+' ' + dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,SQ.strFixationBy)
																+
																CASE
																WHEN dbo.fnCTGetReportLanguage(@intLaguageId) = 'Italian'
																THEN ' '
																ELSE '''s '
																END
																+
																@rtStrPricing2+':'+dbo.fnRemoveTrailingZeroes(dblLotsToFix)+').'
															when pricingType.strPricingType = 'Priced'
															THEN dbo.fnRemoveTrailingZeroes(SQ.dblCashPrice) + ' ' + SQ.strPriceCurrencyAndUOMForPriced
															ELSE dbo.fnRemoveTrailingZeroes(SQ.dblBasis) + ' ' + SQ.strPriceCurrencyAndUOMForPriced
															end
														)
			,strGABHeader							=	@rtConfirmationOf + ' ' + isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,TP.strContractType), TP.strContractType) + ' ' + CASE WHEN @type = 'MULTIPLE' THEN '' ELSE CH.strContractNumber END --+ISNULL('-' + @ErrMsg , '')		
			,striDealHeader							=	@rtConfirmationOf + ' ' + isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Sale'), 'Sale') + ' ' + CASE WHEN @type = 'MULTIPLE' THEN '' ELSE CH.strContractNumber END --+ISNULL('-' + @ErrMsg , '')		
			,strGABAssociation						=	CASE WHEN CH.intContractTypeId = 1 THEN @rtStrGABAssociation1 ELSE @rtStrGABAssociation3 END
														+ ' ' + dbo.fnCTGetTranslation('ContractManagement.view.Associations',AN.intAssociationId,@intLaguageId,'Printable Contract Text',AN.strComment) + ' ('+dbo.fnCTGetTranslation('ContractManagement.view.Associations',AN.intAssociationId,@intLaguageId,'Name',AN.strName)+')'+' '+@rtStrGABAssociation2+':'
			,striDealAssociation					=	@rtStriDealAssociation
														+ ' ' + dbo.fnCTGetTranslation('ContractManagement.view.Associations',AN.intAssociationId,@intLaguageId,'Printable Contract Text',AN.strComment) + ' ('+dbo.fnCTGetTranslation('ContractManagement.view.Associations',AN.intAssociationId,@intLaguageId,'Name',AN.strName)+')'+' '+@rtStrGABAssociation2+'.'
			,strEQTAssociation						=	@rtStrAssociation1 + ' '+ dbo.fnCTGetTranslation('ContractManagement.view.Associations',AN.intAssociationId,@intLaguageId,'Printable Contract Text',AN.strComment)+' '+@rtStrAssociation2+'.'
			,strCompanyCityAndDate				=	ISNULL(@strCity + ', ', '') + LEFT(DATENAME(DAY,CH.dtmContractDate),2)
														+ ' ' + isnull(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,LEFT(DATENAME(MONTH,CH.dtmContractDate),3)), LEFT(DATENAME(MONTH,CH.dtmContractDate),3)) + ' ' + LEFT(DATENAME(YEAR,CH.dtmContractDate),4)
			
			,strGABCompanyCityAndDate				=	ISNULL(@strCity + ', ', '') + LEFT(DATENAME(DAY,CH.dtmContractDate),2)
														+ ' ' + isnull(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,LEFT(DATENAME(MONTH,CH.dtmContractDate),3)), LEFT(DATENAME(MONTH,CH.dtmContractDate),3)) + ' ' + LEFT(DATENAME(YEAR,CH.dtmContractDate),4)
			
			,strCompanyName							=	@strCompanyName
			,striDealShipment						=	ISNULL(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,DATENAME(MONTH, SQ.dtmStartDate)), DATENAME(MONTH, SQ.dtmStartDate)) +'('+ RIGHT(YEAR(SQ.dtmStartDate), 2)+')'
			,striDealSeller							=   LTRIM(RTRIM(EV.strEntityName)) + ', ' + CHAR(13)+CHAR(10) +
														ISNULL(LTRIM(RTRIM(EV.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
														ISNULL(LTRIM(RTRIM(EV.strEntityCity)),'') + 
														ISNULL(', '+CASE WHEN LTRIM(RTRIM(EV.strEntityState)) = '' THEN NULL ELSE LTRIM(RTRIM(EV.strEntityState)) END,'') + 
														ISNULL(', '+CASE WHEN LTRIM(RTRIM(EV.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EV.strEntityZipCode)) END,'') + 
														ISNULL(', '+CASE WHEN LTRIM(RTRIM(EV.strEntityCountry)) = '' THEN NULL ELSE dbo.fnCTGetTranslation('i21.view.Country',rtc11.intCountryID,@intLaguageId,'Country',rtc11.strCountry) END,'')

			,striDealBuyer							=   LTRIM(RTRIM(EC.strEntityName)) + ', ' + CHAR(13)+CHAR(10) +
														ISNULL(LTRIM(RTRIM(EC.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
														ISNULL(LTRIM(RTRIM(EC.strEntityCity)),'') + 
														ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityState)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityState)) END,'') + 
														ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityZipCode)) END,'') + 
														ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityCountry)) = '' THEN NULL ELSE dbo.fnCTGetTranslation('i21.view.Country',rtc12.intCountryID,@intLaguageId,'Country',rtc12.strCountry) END,'')
			,striDealPrice							=	(
															case
															when pricingType.strPricingType = 'Basis'
															then strFutMarketName + ' ' + strFutureMonth + ' ' + CONVERT(VARCHAR, CAST(SQ.dblBasis AS MONEY), 1) +' '+ strBasisCurrency + '/' + strBasisUnitMeasure
															when pricingType.strPricingType = 'Priced'
															--then 'At' + ' ' + CONVERT(VARCHAR, CAST(SQ.dblCashPrice AS MONEY), 1) +' '+ strBasisCurrency + '/' + strBasisUnitMeasure
															--else 'At' + ' ' + CONVERT(VARCHAR, CAST(dblBasis AS MONEY), 1) +' '+ strBasisCurrency + '/' + strBasisUnitMeasure
															then dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'At') + ' ' + CONVERT(VARCHAR, CAST(SQ.dblCashPrice AS MONEY), 1) +' '+ strBasisCurrency + '/' + strBasisUnitMeasure
															else dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'At') + ' ' + CONVERT(VARCHAR, CAST(dblBasis AS MONEY), 1) +' '+ strBasisCurrency + '/' + strBasisUnitMeasure
															end
														)
			,lblGABShipDelv							=	CASE WHEN strPosition = 'Spot' THEN dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Delivery') ELSE dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Shipment') END
			,strIds									=	@strIds
			,strType								=	@type
			,intLaguageId							=	@intLaguageId
			,intReportLogoHeight					=	ISNULL(@intReportLogoHeight,0)
			,intReportLogoWidth						=	ISNULL(@intReportLogoWidth,0)
			,strOurCommn							=	@strOurCommn
			,strBrkgCommn							=	@strBrkgCommn
			,strItemDescription						=	strItemDescription
			,strStraussQuantity						=	dbo.fnRemoveTrailingZeroes(CH.dblQuantity) + ' ' + dbo.fnCTGetTranslation('Inventory.view.ReportTranslation',UM.intUnitMeasureId,@intLaguageId,'Name',UM.strUnitMeasure) + ' ' + ISNULL(SQ.strPackingDescription, '')
			,strItemBundleNo						=	(case when @ysnExternal = convert(bit,1) then SQ.strItemBundleNo else null end)
			,strItemBundleNoLabel					=	(case when @ysnExternal = convert(bit,1) then 'GROUP QUALITY CODE:' else null end)
			,strStraussPrice						=	CASE WHEN CH.intPricingTypeId = 2 THEN 
															'Price to be fixed basis ' + strFutMarketName + ' ' + 
															strFutureMonthYear + CASE WHEN SQ.dblBasis < 0 THEN ' '+@rtMinus+' ' ELSE ' '+@rtPlus+' ' END +
															SQ.strBasisCurrency + ' ' + dbo.fnCTChangeNumericScale(abs(SQ.dblBasis),2) + '/'+ SQ.strBasisUnitMeasure +' at '+ SQ.strFixationBy+'''s option prior to first notice day of '+strFutureMonthYear+' or on presentation of documents,whichever is earlier.'
														ELSE
															'' + dbo.fnCTChangeNumericScale(SQ.dblCashPrice,2) + ' ' + strPriceCurrencyAndUOMForPriced2	
														END
			,strStraussCondition     				= 	CB.strFreightTerm + '('+CB.strDescription+')' + ' ' + isnull(CT.strCity,'') + ' ' + isnull(W1.strWeightGradeDesc,'')  
			,strStraussApplicableLaw				=	@strApplicableLaw
			,strStraussContract						=	'In accordance with '+AN.strComment+' (latest edition)'
		    ,strStrussOtherCondition    = '<span style="font-family:Arial;font-size:13px;">' + isnull(W2.strWeightGradeDesc,'') +  isnull(@strGeneralCondition,'') + '</span>'
		    ,strStraussShipment      = datename(m,SQ.dtmEndDate) + ' ' + substring(CONVERT(VARCHAR,SQ.dtmEndDate,107),9,4) + (case when PO.strPositionType = 'Spot' then ' delivery' else ' shipment' end)   
		    ,strStraussShipmentLabel      = (case when PO.strPositionType = 'Spot' then 'DELIVERY' else 'SHIPMENT' end) 
			,intContractTypeId						=	CH.intContractTypeId

	FROM	tblCTContractHeader				CH
	JOIN	tblICCommodity					CM	WITH (NOLOCK) ON	CM.intCommodityId				=	CH.intCommodityId
												AND	CH.intContractHeaderId			IN	(SELECT Item FROM dbo.fnSplitString(@strIds,','))
	JOIN	tblCTContractType				TP	WITH (NOLOCK) ON	TP.intContractTypeId			=	CH.intContractTypeId
	JOIN	vyuCTEntity						EY	WITH (NOLOCK) ON	EY.intEntityId					=	CH.intEntityId	AND
												EY.strEntityType					=	(CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)
	LEFT JOIN	vyuCTEntity					EV	WITH (NOLOCK) ON	EV.intEntityId					=	CH.intEntityId        
												AND EV.strEntityType				=	'Vendor'					
	LEFT JOIN	vyuCTEntity					EC	WITH (NOLOCK) ON	EC.intEntityId					=	CH.intCounterPartyId  
												AND EC.strEntityType				=	'Customer'		
	LEFT JOIN 
	(
		SELECT c.intContractHeaderId,
				a.strEntityName,
				a.strEntityAddress,
				a.strEntityCity,
				a.strEntityState,
				a.strEntityZipCode,
				a.strEntityCountry,
				strBrokerCommission =	CONVERT(NVARCHAR,CAST(b.dblRate  AS Money),1) + ' ' + d.strCurrency + ' ' + @rtStrBrokerCommissionPer + ' ' + dbo.fnCTGetTranslation('Inventory.view.ReportTranslation',e.intUnitMeasureId,@intLaguageId,'Name',e.strUnitMeasure),
				strPaidBy			=	ISNULL(NULLIF(b.strPaidBy, ''), 'Company')
		FROM vyuCTEntity a
		INNER JOIN tblCTContractCost b ON a.intEntityId = b.intVendorId AND b.strParty = 'Broker' AND a.strEntityType = 'Broker'
		INNER JOIN tblCTContractDetail c ON b.intContractDetailId = c.intContractDetailId
		INNER JOIN tblSMCurrency d	 ON	c.intCurrencyId = d.intCurrencyID
		INNER JOIN tblICUnitMeasure e ON e.intUnitMeasureId = c.intUnitMeasureId
	)										EB ON EB.intContractHeaderId = CH.intContractHeaderId											
	LEFT JOIN	tblCTCropYear				CY	WITH (NOLOCK) ON	CY.intCropYearId				=	CH.intCropYearId			
	LEFT JOIN	tblSMFreightTerms			CB	WITH (NOLOCK) ON	CB.intFreightTermId				=	CH.intFreightTermId		
	LEFT JOIN	tblCTWeightGrade			W1	WITH (NOLOCK) ON	W1.intWeightGradeId				=	CH.intWeightId				
	LEFT JOIN	tblCTWeightGrade			W2	WITH (NOLOCK) ON	W2.intWeightGradeId				=	CH.intGradeId				
	LEFT JOIN	tblCTContractText			TX	WITH (NOLOCK) ON	TX.intContractTextId			=	CH.intContractTextId		
	LEFT JOIN	tblCTAssociation			AN	WITH (NOLOCK) ON	AN.intAssociationId				=	CH.intAssociationId			
	LEFT JOIN	tblSMTerm					TM	WITH (NOLOCK) ON	TM.intTermID					=	CH.intTermId				
	LEFT JOIN	tblSMCity					AB	WITH (NOLOCK) ON	AB.intCityId					=	CH.intArbitrationId			
	LEFT JOIN	tblSMCountry				RY	WITH (NOLOCK) ON	RY.intCountryID					=	AB.intCountryId				
	LEFT JOIN	tblCTInsuranceBy			IB	WITH (NOLOCK) ON	IB.intInsuranceById				=	CH.intInsuranceById				
	LEFT JOIN	tblEMEntity					PR	WITH (NOLOCK) ON	PR.intEntityId					=	CH.intProducerId			
	LEFT JOIN	tblCTPosition				PO	WITH (NOLOCK) ON	PO.intPositionId				=	CH.intPositionId			
	LEFT JOIN	tblSMCountry				CO	WITH (NOLOCK) ON	CO.intCountryID					=	CH.intCountryId				
	LEFT JOIN	tblAPVendor					VR	WITH (NOLOCK) ON	VR.intEntityId					=	CH.intEntityId				
	LEFT JOIN	tblARCustomer				CR	WITH (NOLOCK) ON	CR.intEntityId					=	CH.intEntityId					
	LEFT JOIN	tblSMCity					CT	WITH (NOLOCK) ON	CT.intCityId					=	CH.intINCOLocationTypeId	
	INNER JOIN	tblICCommodityUnitMeasure	CU	WITH (NOLOCK) ON	CU.intCommodityUnitMeasureId	=	CH.intCommodityUOMId		
	INNER JOIN	tblICUnitMeasure			UM	WITH (NOLOCK) ON	UM.intUnitMeasureId				=	CU.intUnitMeasureId			
	LEFT JOIN	tblSMCompanyLocationSubLocation		SL	WITH (NOLOCK) ON	SL.intCompanyLocationSubLocationId	=		CH.intWarehouseId 
	LEFT JOIN	(
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
							strFutMarketName = dbo.fnCTGetTranslation('RiskManagement.view.FuturesMarket',MA.intFutureMarketId,@intLaguageId,'Market Name',MA.strFutMarketName),
							CD.strPackingDescription				AS strPackingDescription,
							CL.strContractCompanyName				AS strContractCompanyName,
						    CL.strContractPrintSignOff              AS strContractPrintSignOff,
							CD.strERPPONumber,
							(SELECT SUM(dblNoOfLots) FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId) AS dblTotalNoOfLots,
							dbo.fnCTGetTranslation('Inventory.view.Item',IM.intItemId,@intLaguageId,'Description',IM.strDescription) + ISNULL(', ' + CD.strItemSpecification, '') AS strItemDescWithSpec,
							dbo.fnCTGetTranslation('Inventory.view.Item',IM.intItemId,@intLaguageId,'Description',IM.strDescription) strItemDescription,
							--CONVERT(NVARCHAR(20),CD.dtmStartDate,106) + ' - ' +  CONVERT(NVARCHAR(20),CD.dtmEndDate,106) AS strStartAndEndDate,
							LEFT(DATENAME(DAY,CD.dtmStartDate),2) + ' ' + isnull(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,LEFT(DATENAME(MONTH,CD.dtmStartDate),3)), LEFT(DATENAME(MONTH,CD.dtmStartDate),3)) + ' ' + LEFT(DATENAME(YEAR,CD.dtmStartDate),4) + ' - ' + LEFT(DATENAME(DAy,CD.dtmEndDate),2) + ' ' + isnull(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,LEFT(DATENAME(MONTH,CD.dtmEndDate),3)), LEFT(DATENAME(MONTH,CD.dtmEndDate),3)) + ' ' + LEFT(DATENAME(YEAR,CD.dtmEndDate),4) AS strStartAndEndDate,
							LTRIM(CD.intNumberOfContainers) + ' x ' + dbo.fnCTGetTranslation('Logistics.view.ContainerType',CT.intContainerTypeId,@intLaguageId,'Container Type',CT.strContainerType) AS strNoOfContainerAndType,
							--DATENAME(mm,MO.dtmFutureMonthsDate) + ' ' + DATENAME(yyyy,MO.dtmFutureMonthsDate) AS strFutureMonthYear,
							isnull(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,DATENAME(mm,MO.dtmFutureMonthsDate)), DATENAME(mm,MO.dtmFutureMonthsDate)) + ' ' + DATENAME(yyyy,MO.dtmFutureMonthsDate) AS strFutureMonthYear,
							CD.dblBasis,
							CD.strBuyerSeller,
							ISNULL(CD.dblNoOfLots - ISNULL(PF.dblLotsFixed,0), 0) AS dblLotsToFix,
							CD.intPricingTypeId,
							CY.strCurrency + '-' + dbo.fnCTGetTranslation('Inventory.view.ReportTranslation',UM.intUnitMeasureId,@intLaguageId,'Name',UM.strUnitMeasure) AS	strPriceCurrencyAndUOM,
							CY.strCurrency + '/' + dbo.fnCTGetTranslation('Inventory.view.ReportTranslation',UM.intUnitMeasureId,@intLaguageId,'Name',UM.strUnitMeasure) AS	strPriceCurrencyAndUOMForPriced,
							CY.strCurrency + ' per ' + dbo.fnCTGetTranslation('Inventory.view.ReportTranslation',UM.intUnitMeasureId,@intLaguageId,'Name',UM.strUnitMeasure) AS	strPriceCurrencyAndUOMForPriced2,
							CD.dtmStartDate,
							CD.dtmEndDate,
							dbo.fnCTGetTranslation('RiskManagement.view.FuturesTradingMonths',CD.intFutureMonthId,@intLaguageId,'Future Trading Month',MO.strFutureMonth) strFutureMonth,
							BC.strCurrency AS strBasisCurrency,
							dbo.fnCTGetTranslation('Inventory.view.ReportTranslation',BM.intUnitMeasureId,@intLaguageId,'Name',BM.strUnitMeasure) strBasisUnitMeasure,
							BI.strItemNo strItemBundleNo,
							CD.dblCashPrice

				FROM		tblCTContractDetail		CD  WITH (NOLOCK)
				JOIN		tblICItem				IM	WITH (NOLOCK) ON	IM.intItemId				=	CD.intItemId
				JOIN		tblSMCompanyLocation	CL	WITH (NOLOCK) ON	CL.intCompanyLocationId		=	CD.intCompanyLocationId		
				LEFT JOIN	tblSMCity				LP	WITH (NOLOCK) ON	LP.intCityId				=	CD.intLoadingPortId			
				LEFT JOIN	tblSMCity				DP	WITH (NOLOCK) ON	DP.intCityId				=	CD.intDestinationPortId		
				LEFT JOIN	tblEMEntity				TT	WITH (NOLOCK) ON	TT.intEntityId				=	CD.intShipperId				
				LEFT JOIN	tblSMCurrency			CY	WITH (NOLOCK) ON	CY.intCurrencyID			=	CD.intCurrencyId			
				LEFT JOIN	tblSMCurrency			BC	WITH (NOLOCK) ON	BC.intCurrencyID			=	CD.intBasisCurrencyId		
				LEFT JOIN	tblRKFutureMarket		MA	WITH (NOLOCK) ON	MA.intFutureMarketId		=	CD.intFutureMarketId		
				LEFT JOIN	tblRKFuturesMonth		MO	WITH (NOLOCK) ON	MO.intFutureMonthId			=	CD.intFutureMonthId			
				LEFT JOIN	tblLGContainerType		CT	WITH (NOLOCK) ON	CT.intContainerTypeId		=	CD.intContainerTypeId		
				INNER JOIN	tblCTPriceFixation		PF	WITH (NOLOCK) ON	PF.intContractDetailId		=	CD.intContractDetailId		
				INNER JOIN	tblICItemUOM			IU	WITH (NOLOCK) ON	IU.intItemUOMId				=	CD.intPriceItemUOMId		
				INNER JOIN	tblICUnitMeasure		UM	WITH (NOLOCK) ON	UM.intUnitMeasureId			=	IU.intUnitMeasureId
				INNER JOIN  tblICItemUOM			BU	WITH (NOLOCK) ON	BU.intItemUOMId				=	CD.intBasisUOMId
				INNER JOIN  tblICUnitMeasure		BM	WITH (NOLOCK) ON	BM.intUnitMeasureId			=	BU.intUnitMeasureId
				INNER JOIN	tblICItem				BI	WITH (NOLOCK) ON	BI.intItemId				=	CD.intItemBundleId

			)										SQ	ON	SQ.intContractHeaderId		=	CH.intContractHeaderId	
														AND SQ.intRowNum = 1
	LEFT JOIN tblSMCountry				rtc10 on lower(rtrim(ltrim(rtc10.strCountry))) = lower(rtrim(ltrim(EY.strEntityCountry)))
	LEFT JOIN tblSMCountry				rtc11 on lower(rtrim(ltrim(rtc11.strCountry))) = lower(rtrim(ltrim(EV.strEntityCountry)))
	LEFT JOIN tblSMCountry				rtc12 on lower(rtrim(ltrim(rtc12.strCountry))) = lower(rtrim(ltrim(EC.strEntityCountry)))
	LEFT JOIN tblCTPricingType pricingType on pricingType.intPricingTypeId = CH.intPricingTypeId
	ORDER BY CH.intContractHeaderId DESC
	
	SELECT @ysnFeedOnApproval = ysnFeedOnApproval FROM tblCTCompanyPreference

	IF @IsFullApproved=1  OR ISNULL(@ysnFeedOnApproval,0) = 0
		UPDATE tblCTContractHeader SET ysnPrinted = 1 WHERE intContractHeaderId	= @intContractHeaderId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH