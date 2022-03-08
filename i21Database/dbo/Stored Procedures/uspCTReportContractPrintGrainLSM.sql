CREATE PROCEDURE uspCTReportContractPrintGrainLSM

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
			@intContractHeaderId	NVARCHAR(MAX),
			@FirstApprovalId		INT,
			@SecondApprovalId       INT,
			@FirstApprovalSign      VARBINARY(MAX),
			@SecondApprovalSign     VARBINARY(MAX),
			@InterCompApprovalSign  VARBINARY(MAX),
			@FirstApprovalName      NVARCHAR(MAX),
			@SecondApprovalName     NVARCHAR(MAX),
			@intApproverGroupId		INT,
			@IsFullApproved			BIT = 0,
			@LGMContractSubmitId INT,
			@strTransactionApprovalStatus			NVARCHAR(100),
			@intTransactionId						INT,
			@intScreenId							INT,
			@ysnIsParent							int,
			@blbParentSubmitSignature				varbinary(max),
			@blbParentApproveSignature				varbinary(max),
			@blbChildSubmitSignature				varbinary(max),
			@blbChildApproveSignature				varbinary(max),
			@intChildDefaultSubmitById				int,
			@strAmendedColumns						NVARCHAR(MAX),
			@xmlDocumentId			INT,
			@intDecimalDPR			INT
			
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

	SELECT	@strCompanyName	=	CASE WHEN LTRIM(RTRIM(strCompanyName)) = '' THEN NULL ELSE LTRIM(RTRIM(strCompanyName)) END,
			@strAddress		=	CASE WHEN LTRIM(RTRIM(strAddress)) = '' THEN NULL ELSE LTRIM(RTRIM(strAddress)) END,
			@strCounty		=	CASE WHEN LTRIM(RTRIM(strCounty)) = '' THEN NULL ELSE LTRIM(RTRIM(strCounty)) END,
			@strCity		=	CASE WHEN LTRIM(RTRIM(strCity)) = '' THEN NULL ELSE LTRIM(RTRIM(strCity)) END,
			@strState		=	CASE WHEN LTRIM(RTRIM(strState)) = '' THEN NULL ELSE LTRIM(RTRIM(strState)) END,
			@strZip			=	CASE WHEN LTRIM(RTRIM(strZip)) = '' THEN NULL ELSE LTRIM(RTRIM(strZip)) END,
			@strCountry		=	CASE WHEN LTRIM(RTRIM(strCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(strCountry)) END
	FROM	tblSMCompanySetup

	
	IF @strAmendedColumns IS NULL SELECT @strAmendedColumns = ''

	DECLARE @thisContractStatus NVARCHAR(100)
	SELECT @intScreenId=intScreenId FROM tblSMScreen WITH (NOLOCK) WHERE ysnApproval=1 AND strNamespace='ContractManagement.view.Contract'
	SELECT @intTransactionId=intTransactionId, @thisContractStatus = strApprovalStatus, @IsFullApproved = ysnOnceApproved FROM tblSMTransaction WITH (NOLOCK) WHERE intScreenId=@intScreenId AND intRecordId=@intContractHeaderId
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

	IF (ISNULL(@LGMContractSubmitId, 0) = 0)
	BEGIN
		SELECT	TOP 1 @LGMContractSubmitId = intSubmittedById
		FROM	tblSMApproval 
		WHERE	intTransactionId = @intTransactionId
		AND		strStatus = 'Submitted' 
		ORDER BY intApprovalId
	END

	--if contract is for amendment
	IF EXISTS(SELECT TOP 1 1 FROM tblSMTransaction WHERE intTransactionId = @intTransactionId AND ysnOnceApproved = 1)
	BEGIN

		SELECT @strTransactionApprovalStatus = strApprovalStatus FROM tblSMTransaction WHERE intTransactionId = @intTransactionId
		IF @strTransactionApprovalStatus = 'Waiting for Submit'
		BEGIN
			SELECT @FirstApprovalId = NULL
			, @intApproverGroupId = NULL
			, @LGMContractSubmitId = NULL
		END

		IF @strTransactionApprovalStatus = 'Waiting for Approval'
		BEGIN
			SELECT @FirstApprovalId = NULL
			, @intApproverGroupId = NULL
			, @LGMContractSubmitId = intSubmittedById
			FROM tblSMApproval WHERE	intTransactionId = @intTransactionId AND ysnCurrent = 1 AND strStatus = 'Waiting for Approval' 
		END

		IF @strTransactionApprovalStatus = 'Approved'
		BEGIN
			SELECT	TOP 1 @FirstApprovalId = intApproverId
				, @intApproverGroupId = intApproverGroupId
				, @LGMContractSubmitId = intSubmittedById
			FROM tblSMApproval WHERE	intTransactionId = @intTransactionId AND ysnCurrent = 1 AND strStatus = 'Approved' 
		END

	END

	select top 1
		@intChildDefaultSubmitById = (case when isnull(smc.intMultiCompanyParentId,0) = 0 then null else us.intEntityId end)
	from
		tblCTContractHeader ch
		,tblSMMultiCompany smc
		,tblIPMultiCompany mc
		,tblSMUserSecurity us
	where
		ch.intContractHeaderId = @intContractHeaderId
		and smc.intMultiCompanyId = ch.intCompanyId
		and mc.intCompanyId = smc.intMultiCompanyId
		and lower(us.strUserName) = lower(mc.strApprover)

	select
		@ysnIsParent = t.ysnIsParent
		,@blbParentSubmitSignature = h.blbDetail
		,@blbParentApproveSignature = j.blbDetail
		,@blbChildSubmitSignature = 
			CASE WHEN @thisContractStatus = 'Approved' AND t.ysnIsParent = 1 AND @strTransactionApprovalStatus = 'Approved' THEN l.blbDetail 
			ELSE 
				CASE WHEN @thisContractStatus IN ('Waiting for Approval', 'Approved') AND t.ysnIsParent = 0 THEN l.blbDetail ELSE NULL END 
			END
		,@blbChildApproveSignature = 
			CASE WHEN @thisContractStatus = 'Approved' AND t.ysnIsParent = 1 AND @strTransactionApprovalStatus = 'Approved' THEN n.blbDetail
			ELSE
				CASE WHEN @thisContractStatus IN ('Waiting for Approval', 'Approved') AND t.ysnIsParent = 0 THEN n.blbDetail ELSE NULL END
			END
	from
		(
		select
			ysnIsParent = (case when isnull(b.intMultiCompanyParentId,0) = 0 then convert(bit,1) else convert(bit,0) end)
			,intParentSubmitBy = (case when isnull(b.intMultiCompanyParentId,0) = 0 then @LGMContractSubmitId else d.intEntityId end)
			,intParentApprovedBy = (case when isnull(b.intMultiCompanyParentId,0) = 0 then @FirstApprovalId else f.intEntityId end)
			,intChildSubmitBy = (case when isnull(b.intMultiCompanyParentId,0) = 0 then d.intEntityId else @LGMContractSubmitId end)
			,intChildApprovedBy = (case when isnull(b.intMultiCompanyParentId,0) = 0 then f.intEntityId else @FirstApprovalId end)
		from
			tblCTContractHeader a
			inner join tblSMMultiCompany b on b.intMultiCompanyId = a.intCompanyId
			left join tblCTIntrCompApproval c on c.intContractHeaderId = a.intContractHeaderId and c.strScreen = (case when LEN(LTRIM(RTRIM(ISNULL(@strAmendedColumns,'')))) > 0 then 'Amendment and Approvals' else 'Contract' end) and c.ysnApproval = 0
			left join tblSMUserSecurity d on lower(d.strUserName) = lower(c.strUserName)
			left join tblCTIntrCompApproval e on e.intContractHeaderId = a.intContractHeaderId and e.strScreen = (case when LEN(LTRIM(RTRIM(ISNULL(@strAmendedColumns,'')))) > 0 then 'Amendment and Approvals' else 'Contract' end) and e.ysnApproval = 1
			left join tblSMUserSecurity f on lower(f.strUserName) = lower(e.strUserName)
		where
			a.intContractHeaderId = @intContractHeaderId
		) t
		left join tblEMEntitySignature g on g.intEntityId = t.intParentSubmitBy
		left join tblSMSignature h  on h.intEntityId = g.intEntityId and h.intSignatureId = g.intElectronicSignatureId
		left join tblEMEntitySignature i on i.intEntityId = t.intParentApprovedBy
		left join tblSMSignature j  on j.intEntityId = i.intEntityId and j.intSignatureId = i.intElectronicSignatureId
		left join tblEMEntitySignature k on k.intEntityId = t.intChildSubmitBy
		left join tblSMSignature l  on l.intEntityId = k.intEntityId and l.intSignatureId = k.intElectronicSignatureId
		left join tblEMEntitySignature m on m.intEntityId = t.intChildApprovedBy
		left join tblSMSignature n  on n.intEntityId = m.intEntityId and n.intSignatureId = m.intElectronicSignatureId 

	SELECT	@strCompanyName + CHAR(13)+CHAR(10) +
			ISNULL(@strAddress,'') + CHAR(13)+CHAR(10) +
			ISNULL(@strCity,'') +ISNULL(', '+@strState,'') + ISNULL('  '+@strZip,'') + CHAR(13)+CHAR(10) +  
			ISNULL(@strCountry,'')
			AS	strA,
			LTRIM(RTRIM(CH.strEntityName))+ CHAR(13)+CHAR(10) +
			ISNULL(LTRIM(RTRIM(CH.strEntityAddress)),'')+ CHAR(13)+CHAR(10) +
			ISNULL(LTRIM(RTRIM(CH.strEntityCity)),'') + 
			ISNULL(', '+CASE WHEN LTRIM(RTRIM(CH.strEntityState)) = '' THEN NULL ELSE LTRIM(RTRIM(CH.strEntityState)) END,'') + 
			ISNULL('  '+CASE WHEN LTRIM(RTRIM(CH.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(CH.strEntityZipCode)) END,'') + CHAR(13)+CHAR(10) + 
			ISNULL(CASE WHEN LTRIM(RTRIM(CH.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(CH.strEntityCountry)) END,'')
			AS	strB,
			CH.dtmContractDate,
			CH.strContractNumber,
			CH.intContractHeaderId,
			CH.strEntityNumber strNumber,
			CASE	WHEN	CH.intContractTypeId  =	1	
					THEN	'We confirm PURCHASE from you as follows :'
					WHEN	CH.intContractTypeId  =	2
					THEN	'We confirm SALES to you as follows :'
			END		AS	strConfirm,
			@strCompanyName AS	strE,
			CH.strEntityName		AS	strF,
			CASE	WHEN	CH.intContractTypeId  =	1	
					THEN	'PURCHASE '+ UPPER(CH.strPricingType) +' CONTRACT CONFIRMATION'
					WHEN	CH.intContractTypeId  =	2
					THEN	'SALES '+ UPPER(CH.strPricingType) +' CONTRACT CONFIRMATION'
			END		AS	strHeading,
			CASE	WHEN	CH.intContractTypeId  =	1	
					THEN	'BUYER'
					WHEN	CH.intContractTypeId  =	2
					THEN	'SELLER'
			END		AS	strC,
			CASE	WHEN	CH.intContractTypeId  =	1	
					THEN	'SELLER'
					WHEN	CH.intContractTypeId  =	2
					THEN	'BUYER'
			END		AS	strD,
			CH.strSalesperson,
			--(SELECT TOP 1 Sig.blbDetail FROM tblSMSignature Sig  WITH (NOLOCK) WHERE Sig.intEntityId=CH.intSalespersonId) SalespersonSignature,
			(SELECT TOP 1 Sig.blbFile FROM tblSMUpload Sig  WITH (NOLOCK) WHERE Sig.intAttachmentId=CH.intAttachmentSignatureId) SalespersonSignature,
			TX.strText,
			CH.strContractBasis +
			ISNULL(', '+CASE WHEN LTRIM(RTRIM(CH.strINCOLocation)) = '' THEN NULL ELSE LTRIM(RTRIM(CH.strINCOLocation)) END,'') + 
			ISNULL(', '+CASE WHEN LTRIM(RTRIM(CH.strCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(CH.strCountry)) END,'') strContractBasis ,
			CH.strWeight,
			CH.strGrade,
			dbo.fnSMGetCompanyLogo('Header') AS blbHeaderLogo,
			strPrintableRemarks,
			CH.strTerm
		   ,lblCustomerContract					=	CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor Ref :' ELSE 'Customer Ref :' END
		   ,strCustomerContract					=   ISNULL(CH.strCustomerContract,'')
		   ,CH.strFreightTerm
		   ,LGMContractSubmitByParentSignature	= @blbParentSubmitSignature
		   ,LGMContractSubmitSignature			= @blbChildSubmitSignature
		   ,blbSalesContractFirstApproverSignature	= CASE WHEN CH.intContractTypeId  IN (1,2) THEN @FirstApprovalSign ELSE NULL END 
		   --OLD
		   --,blbSalesParentApproverSignature		=  CASE WHEN CH.intContractTypeId IN (1,2) THEN @SecondApprovalSign ELSE NULL END 
		   ,blbSalesParentApproverSignature		=  CASE WHEN CH.intContractTypeId IN (1,2) THEN SMU.blbFile ELSE NULL END 
		   ,blbPurchaseContractFirstApproverSignature	= NULL--CASE WHEN CH.intContractTypeId  =  2 THEN NULL ELSE @FirstApprovalSign END
		   ,blbPurchaseParentApproveSignature		= NULL-- CASE WHEN CH.intContractTypeId  =  2 THEN NULL ELSE @SecondApprovalSign END 
	FROM	vyuCTContractHeaderView CH
	LEFT
	JOIN	tblCTContractText		TX	ON	TX.intContractTextId	=	CH.intContractTextId
	LEFT JOIN tblSMAttachment			SMA on SMA.strRecordNo = CH.intSalespersonId
	LEFT JOIN tblSMUpload				SMU on SMA.intAttachmentId = SMU.intAttachmentId
	WHERE	intContractHeaderId	IN (SELECT Item FROM dbo.fnSplitString(@intContractHeaderId,','))
	
	UPDATE tblCTContractHeader SET ysnPrinted = 1 WHERE intContractHeaderId	IN (SELECT Item FROM dbo.fnSplitString(@intContractHeaderId,','))

END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspCTReportContractPrintGrainLSM - ' + ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO