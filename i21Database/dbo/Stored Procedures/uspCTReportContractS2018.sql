-- THIS REPORT CAME OUT FROM uspCTReportContract 
-- IF THERE IS COLUMN NEEDED CHECH ON THE ORIGNAL STORED PROCEDURE FIRST
CREATE PROCEDURE [dbo].[uspCTReportContractS2018]
	@xmlParam NVARCHAR(MAX) = NULL  
AS
BEGIN TRY
	DECLARE @ErrMsg						NVARCHAR(MAX),
			@strCompanyName				NVARCHAR(500),
			@strAddress					NVARCHAR(500),
			@strCounty					NVARCHAR(500),
			@strCity					NVARCHAR(500),
			@strState					NVARCHAR(500),
			@strZip						NVARCHAR(500),
			@strCountry					NVARCHAR(500),
			@intContractHeaderId		INT,
			@xmlDocumentId				INT,
			@strContractDocuments		NVARCHAR(MAX),
			@strContractConditions		NVARCHAR(MAX),
			@intScreenId				INT,
			@intTransactionId			INT,
			@strApprovalText			NVARCHAR(MAX),
			@FirstApprovalId			INT,
			@SecondApprovalId			INT,
			@StraussContractSubmitId    INT,
			@FirstApprovalSign			VARBINARY(MAX),
			@SecondApprovalSign			VARBINARY(MAX),
			@InterCompApprovalSign		VARBINARY(MAX),
			@StraussContractApproverSignature  VARBINARY(MAX),
			@StraussContractSubmitSignature  VARBINARY(MAX),
			@FirstApprovalName			NVARCHAR(MAX),
			@SecondApprovalName			NVARCHAR(MAX),
			@IsFullApproved				BIT = 0,
			@ysnFairtrade				BIT = 0,
			@ysnFeedOnApproval			BIT = 0,
			@strCommodityCode			NVARCHAR(MAX),
			@dtmApproved				DATETIME,
			@ysnPrinted					BIT,
			@intLastApprovedContractId	INT,
			@intPrevApprovedContractId	INT,
			@strAmendedColumns			NVARCHAR(MAX),
			@intContractDetailId		INT,
			@TotalLots					INT,
			@strSequenceHistoryId	    NVARCHAR(MAX),
			@strDetailAmendedColumns	NVARCHAR(MAX),
			@intLaguageId				INT,
			@strExpressionLabelName		NVARCHAR(50) = 'Expression',
			@strMonthLabelName			NVARCHAR(50) = 'Month',
			@intApproverGroupId			INT,
			@type						NVARCHAR(50),
			@strIds						NVARCHAR(MAX),
			@intReportLogoHeight		INT,
			@intReportLogoWidth			INT,
			@intFirstHalfNoOfDocuments	INT,
			@strFirstHalfDocuments		NVARCHAR(MAX),
			@strSecondHalfDocuments		NVARCHAR(MAX),
			@strReportTo				NVARCHAR(MAX),
			@strOurCommn				NVARCHAR(MAX),
			@strBrkgCommn				NVARCHAR(MAX),
			@strApplicableLaw			NVARCHAR(MAX),
			@strGeneralCondition		NVARCHAR(MAX)

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
			@strReportTo		=	strReportTo
	FROM	tblCTContractHeader CH	WITH (NOLOCK)
	JOIN	tblICCommodity		CM	WITH (NOLOCK) ON	CM.intCommodityId		=	CH.intCommodityId
	WHERE	CH.intContractHeaderId = @intContractHeaderId

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
	LEFT JOIN tblSMCountry				rtc9 WITH (NOLOCK) ON LOWER(RTRIM(LTRIM(rtc9.strCountry))) = LOWER(RTRIM(LTRIM(tblSMCompanySetup.strCountry)))
	LEFT JOIN tblSMScreen				rts9 WITH (NOLOCK) ON rts9.strNamespace = 'SystemManager.view.Country'
	LEFT JOIN tblSMTransaction			rtt9 WITH (NOLOCK) ON rtt9.intScreenId = rts9.intScreenId and rtt9.intRecordId = rtc9.intCountryID
	LEFT JOIN tblSMReportTranslation	rtrt9 WITH (NOLOCK) ON rtrt9.intLanguageId = @intLaguageId and rtrt9.intTransactionId = rtt9.intTransactionId and rtrt9.strFieldName = 'Country'

	INSERT INTO @tblContractDocument(strDocumentName)
	SELECT DM.strDocumentName
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
		  )  				
	FROM tblCTContractHeader CH						
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
	DECLARE @rtFLOID nvarchar(500) = ISNULL(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'FLO ID'), 'FLO ID');
	DECLARE @rtMinus nvarchar(500) = ISNULL(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'minus'), 'minus');
	DECLARE @rtPlus nvarchar(500) = ISNULL(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'plus'), 'plus');
	DECLARE @rtStrBrokerCommissionPer nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'per'),'per');

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
	
	SELECT	intContractHeaderId					= CH.intContractHeaderId			
	,dtmContractDate						= CH.dtmContractDate
	,strContractNumberStrauss				= CH.strContractNumber + (case when LEN(LTRIM(RTRIM(ISNULL(@strAmendedColumns,'')))) = 0 then '' else ' - AMENDMENT' end)
	,strDestinationPointName				= (case when PO.strPositionType = 'Spot' then CT.strCity else SQ.strDestinationPointName end)
	,strTerm							    = dbo.fnCTGetTranslation('SystemManager.view.Term',TM.intTermID,@intLaguageId,'Terms',TM.strTerm) 
	,strStraussOtherPartyAddress     = '<span style="font-family:Arial;font-size:12px;">' + CASE   
	WHEN CH.strReportTo = 'Buyer' THEN --Customer  
	LTRIM(RTRIM(EC.strEntityName)) + '</br>'    +-- CHAR(13)+CHAR(10) +  
	ISNULL(LTRIM(RTRIM(EC.strEntityAddress)),'') + '</br>' +-- CHAR(13)+CHAR(10) +  
	ISNULL(LTRIM(RTRIM(EC.strEntityCity)),'') +   
	ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityState)) = ''   THEN NULL ELSE LTRIM(RTRIM(EC.strEntityState))   END,'') +   
	ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityZipCode)) END,'') +   
	ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(dbo.fnCTGetTranslation('SystemManager.view.Country',rtc12.intCountryID,@intLaguageId,'Country',rtc12.strCountry))) END,'') +  
	CASE WHEN @ysnFairtrade = 1 THEN  
	ISNULL( CHAR(13)+CHAR(10) + @rtFLOID + ': '+CASE WHEN LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) = '' THEN NULL ELSE LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) END,'')  
	ELSE '' END               
	ELSE -- Seller (Vendor)  
	LTRIM(RTRIM(EY.strEntityName)) + '</br>' + --CHAR(13)+CHAR(10) +  
	ISNULL(LTRIM(RTRIM(EY.strEntityAddress)),'') + '</br>' + --CHAR(13)+CHAR(10) +  
	ISNULL(LTRIM(RTRIM(EY.strEntityCity)),'') +   
	ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityState)) = ''   THEN NULL ELSE LTRIM(RTRIM(EY.strEntityState))   END,'') +   
	ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityZipCode)) END,'') +   
	ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(dbo.fnCTGetTranslation('SystemManager.view.Country',rtc10.intCountryID,@intLaguageId,'Country',rtc10.strCountry))) END,'') +  
	CASE WHEN @ysnFairtrade = 1 THEN  
	ISNULL( CHAR(13)+CHAR(10) + @rtFLOID + ': '+CASE WHEN LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) = '' THEN NULL ELSE LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) END,'')  
	ELSE '' END  
	END + '</span>'
	,strBuyer							    = CASE WHEN CH.intContractTypeId = 1 THEN @strCompanyName ELSE EY.strEntityName END
	,strSeller							    = CASE WHEN CH.intContractTypeId = 2 THEN @strCompanyName ELSE EY.strEntityName END
	,strEntityName							= LTRIM(RTRIM(EY.strEntityName))
	,StraussContractApproverSignature		=  @StraussContractApproverSignature
	,StraussContractSubmitSignature			=  @StraussContractSubmitSignature
	,InterCompApprovalSign					= @InterCompApprovalSign
	,strCompanyName							=	@strCompanyName
	,strItemDescription						=	strItemDescription
	,strStraussQuantity						=	dbo.fnRemoveTrailingZeroes(CH.dblQuantity) + ' ' + dbo.fnCTGetTranslation('Inventory.view.ReportTranslation',UM.intUnitMeasureId,@intLaguageId,'Name',UM.strUnitMeasure) + ' ' + ISNULL(SQ.strPackingDescription, '')
	,strItemBundleNo						=	SQ.strItemBundleNo
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
	)	EB ON EB.intContractHeaderId = CH.intContractHeaderId											
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
	LEFT JOIN	tblICCommodityUnitMeasure	CU	WITH (NOLOCK) ON	CU.intCommodityUnitMeasureId	=	CH.intCommodityUOMId		
	LEFT JOIN	tblICUnitMeasure			UM	WITH (NOLOCK) ON	UM.intUnitMeasureId				=	CU.intUnitMeasureId			
	LEFT JOIN	tblSMCompanyLocationSubLocation		SL	WITH (NOLOCK) ON	SL.intCompanyLocationSubLocationId	=		CH.intWarehouseId 
	LEFT JOIN	
	(
		SELECT ROW_NUMBER() OVER (PARTITION BY CD.intContractHeaderId ORDER BY CD.intContractSeq ASC) AS intRowNum, 
				CD.intContractHeaderId,
				DP.strCity AS	strDestinationPointName,
				CD.strFixationBy,
				strFutMarketName = dbo.fnCTGetTranslation('RiskManagement.view.FuturesMarket',MA.intFutureMarketId,@intLaguageId,'Market Name',MA.strFutMarketName),
				CD.strPackingDescription AS strPackingDescription,
				dbo.fnCTGetTranslation('Inventory.view.Item',IM.intItemId,@intLaguageId,'Description',IM.strDescription) strItemDescription,
				ISNULL(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,DATENAME(mm,MO.dtmFutureMonthsDate)), DATENAME(mm,MO.dtmFutureMonthsDate)) + ' ' + DATENAME(yyyy,MO.dtmFutureMonthsDate) AS strFutureMonthYear,
				CD.dblBasis,
				CY.strCurrency + ' per ' + dbo.fnCTGetTranslation('Inventory.view.ReportTranslation',UM.intUnitMeasureId,@intLaguageId,'Name',UM.strUnitMeasure) AS	strPriceCurrencyAndUOMForPriced2,
				CD.dtmEndDate,
				BC.strCurrency AS strBasisCurrency,
				dbo.fnCTGetTranslation('Inventory.view.ReportTranslation',BM.intUnitMeasureId,@intLaguageId,'Name',BM.strUnitMeasure) strBasisUnitMeasure,
				BI.strItemNo strItemBundleNo,
				CD.dblCashPrice
		FROM		tblCTContractDetail		CD  WITH (NOLOCK)
		INNER JOIN	tblICItem				IM	WITH (NOLOCK) ON	IM.intItemId				=	CD.intItemId
		INNER JOIN	tblSMCompanyLocation	CL	WITH (NOLOCK) ON	CL.intCompanyLocationId		=	CD.intCompanyLocationId		
		LEFT JOIN	tblSMCity				LP	WITH (NOLOCK) ON	LP.intCityId				=	CD.intLoadingPortId			
		LEFT JOIN	tblSMCity				DP	WITH (NOLOCK) ON	DP.intCityId				=	CD.intDestinationPortId		
		LEFT JOIN	tblEMEntity				TT	WITH (NOLOCK) ON	TT.intEntityId				=	CD.intShipperId				
		LEFT JOIN	tblSMCurrency			CY	WITH (NOLOCK) ON	CY.intCurrencyID			=	CD.intCurrencyId			
		LEFT JOIN	tblSMCurrency			BC	WITH (NOLOCK) ON	BC.intCurrencyID			=	CD.intBasisCurrencyId		
		LEFT JOIN	tblRKFutureMarket		MA	WITH (NOLOCK) ON	MA.intFutureMarketId		=	CD.intFutureMarketId		
		LEFT JOIN	tblRKFuturesMonth		MO	WITH (NOLOCK) ON	MO.intFutureMonthId			=	CD.intFutureMonthId			
		LEFT JOIN	tblLGContainerType		CT	WITH (NOLOCK) ON	CT.intContainerTypeId		=	CD.intContainerTypeId		
		LEFT JOIN	tblCTPriceFixation		PF	WITH (NOLOCK) ON	PF.intContractDetailId		=	CD.intContractDetailId		
		LEFT JOIN	tblICItemUOM			IU	WITH (NOLOCK) ON	IU.intItemUOMId				=	CD.intPriceItemUOMId		
		LEFT JOIN	tblICUnitMeasure		UM	WITH (NOLOCK) ON	UM.intUnitMeasureId			=	IU.intUnitMeasureId
		LEFT JOIN   tblICItemUOM			BU	WITH (NOLOCK) ON	BU.intItemUOMId				=	CD.intBasisUOMId
		LEFT JOIN   tblICUnitMeasure		BM	WITH (NOLOCK) ON	BM.intUnitMeasureId			=	BU.intUnitMeasureId
		LEFT JOIN	tblICItem				BI	WITH (NOLOCK) ON	BI.intItemId				=	CD.intItemBundleId
	) SQ	ON	SQ.intContractHeaderId		=	CH.intContractHeaderId AND SQ.intRowNum = 1
	LEFT JOIN tblSMCountry				rtc10 on lower(rtrim(ltrim(rtc10.strCountry))) = lower(rtrim(ltrim(EY.strEntityCountry)))
	LEFT JOIN tblSMCountry				rtc11 on lower(rtrim(ltrim(rtc11.strCountry))) = lower(rtrim(ltrim(EV.strEntityCountry)))
	LEFT JOIN tblSMCountry				rtc12 on lower(rtrim(ltrim(rtc12.strCountry))) = lower(rtrim(ltrim(EC.strEntityCountry)))
	LEFT JOIN tblCTPricingType pricingType on pricingType.intPricingTypeId = CH.intPricingTypeId
	
	SELECT @ysnFeedOnApproval = ysnFeedOnApproval FROM tblCTCompanyPreference

	IF @IsFullApproved=1  OR ISNULL(@ysnFeedOnApproval,0) = 0
		UPDATE tblCTContractHeader SET ysnPrinted = 1 WHERE intContractHeaderId	= @intContractHeaderId
END TRY
BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH