CREATE PROCEDURE [dbo].[uspCTReportContractStrauss]
	@xmlParam NVARCHAR(MAX) = NULL
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)	
	 

	DECLARE
			@xmlDocumentId							INT
			,@ysnFeedOnApproval						BIT = 0
			,@IsFullApproved						BIT = 0
			,@StraussContractSubmitId				INT
			,@intContractHeaderId					INT
			,@strIds								NVARCHAR(MAX)
			,@intStraussCompanyId					INT
			,@FirstApprovalId						INT
			,@intApproverGroupId					INT
			,@intTransactionId						INT
			,@intScreenId							INT
			,@ysnExternal							BIT
			,@strAmendedColumns						NVARCHAR(MAX)
			,@strSequenceHistoryId					NVARCHAR(MAX)
			,@strCompanyName						NVARCHAR(500)
			,@strPackingDescription					NVARCHAR(100)
			,@strItemDescription					NVARCHAR(500)
			,@intContractDetailItemId				INT
			,@intContractDetailBundleItemId			INT
			,@strItemBundleNo						NVARCHAR(500)
			,@intFutureMarketId						INT
			,@strFutMarketName						NVARCHAR(500)
			,@intFutureMonthId						INT
			,@dtmFutureMonthsDate					DateTime
			,@strFutureMonthYear					NVARCHAR(500)
			,@dblContractDetailBasis				numeric(18,6)
			,@intBasisCurrencyId					INT
			,@strBasisCurrency						NVARCHAR(500)
			,@intBasisUOMId							INT
			,@intUnitMeasureId						INT
			,@strUnitMeasure						NVARCHAR(500)
			,@strFixationBy							NVARCHAR(500)
			,@dblCashPrice							numeric(18,6)
			,@strPriceCurrencyAndUOMForPriced2		NVARCHAR(500)
			,@intPriceItemUOMId						INT
			,@intUnitMeasureId2						INT
			,@strUnitMeasure2						NVARCHAR(500)
			,@dtmStartDate							DATETIME
			,@dtmEndDate							DATETIME
			,@intDestinationPortId					INT
			,@strDestinationPort					NVARCHAR(500)
			,@strApplicableLaw						NVARCHAR(MAX)
			,@strGeneralCondition					NVARCHAR(MAX)
			,@ysnIsParent							int
			,@blbParentSubmitSignature				varbinary(max)
			,@blbParentApproveSignature				varbinary(max)
			,@blbChildSubmitSignature				varbinary(max)
			,@blbChildApproveSignature				varbinary(max)
			,@intChildDefaultSubmitById				int
			,@strTransactionApprovalStatus			NVARCHAR(100);

	DECLARE @tblSequenceHistoryId TABLE
	(
	  intSequenceHistoryId INT
	)

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
    
	SELECT	@strIds = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intContractHeaderId'

	SELECT	@strSequenceHistoryId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'strSequenceHistoryId'

	SELECT	TOP 1 @intContractHeaderId	= Item FROM dbo.fnSplitString(@strIds,',')
	DECLARE @thisContractStatus NVARCHAR(100)

	SELECT @intScreenId=intScreenId FROM tblSMScreen WITH (NOLOCK) WHERE ysnApproval=1 AND strNamespace='ContractManagement.view.Contract'
	SELECT @intTransactionId=intTransactionId, @thisContractStatus = strApprovalStatus, @IsFullApproved = ysnOnceApproved FROM tblSMTransaction WITH (NOLOCK) WHERE intScreenId=@intScreenId AND intRecordId=@intContractHeaderId

	IF (ISNULL(@strSequenceHistoryId, '') <> '')
	BEGIN
		INSERT INTO @tblSequenceHistoryId (intSequenceHistoryId)
		SELECT strValues FROM dbo.fnARGetRowsFromDelimitedValues(@strSequenceHistoryId)
	END
	ELSE
	BEGIN
		INSERT INTO @tblSequenceHistoryId (intSequenceHistoryId)
		SELECT DISTINCT intSequenceHistoryId
		FROM tblCTSequenceHistory
		WHERE intContractHeaderId = @intContractHeaderId
	END

	IF @strAmendedColumns IS NULL AND EXISTS(SELECT 1 FROM @tblSequenceHistoryId)
	BEGIN
		DECLARE @dtmApproveDate DATETIME
		
		SELECT TOP 1 @dtmApproveDate = A.dtmDate
		FROM tblSMApproval A
		JOIN tblSMTransaction T ON T.intTransactionId = A.intTransactionId
		WHERE T.intScreenId = @intScreenId
			AND strStatus = 'Approved'
			AND T.intRecordId = @intContractHeaderId
		ORDER BY intApprovalId

		SELECT  @strAmendedColumns = STUFF((
											SELECT DISTINCT ',' + LTRIM(RTRIM(AAP.strDataIndex))
											FROM tblCTAmendmentApproval AAP
											JOIN tblCTSequenceAmendmentLog AL WITH (NOLOCK) ON AL.intAmendmentApprovalId =AAP.intAmendmentApprovalId
											JOIN @tblSequenceHistoryId SH  ON SH.intSequenceHistoryId = AL.intSequenceHistoryId  
											WHERE ISNULL(AAP.ysnAmendment,0) = 1
												AND AL.dtmHistoryCreated >= @dtmApproveDate
											FOR XML PATH('')
											), 1, 1, '')
	END

	IF @strAmendedColumns IS NULL SELECT @strAmendedColumns = ''

	SELECT	TOP 1 @FirstApprovalId = intApproverId
		, @intApproverGroupId = intApproverGroupId
		, @StraussContractSubmitId = intSubmittedById
	FROM	tblSMApproval 
	WHERE	intTransactionId = @intTransactionId
	AND		strStatus = 'Approved' 
	ORDER BY intApprovalId

	IF (ISNULL(@StraussContractSubmitId, 0) = 0)
	BEGIN
		SELECT	TOP 1 @StraussContractSubmitId = intSubmittedById
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
			, @StraussContractSubmitId = NULL
		END

		IF @strTransactionApprovalStatus = 'Waiting for Approval'
		BEGIN
			SELECT @FirstApprovalId = NULL
			, @intApproverGroupId = NULL
			, @StraussContractSubmitId = intSubmittedById
			FROM tblSMApproval WHERE	intTransactionId = @intTransactionId AND ysnCurrent = 1 AND strStatus = 'Waiting for Approval' 
		END

		IF @strTransactionApprovalStatus = 'Approved'
		BEGIN
			SELECT	TOP 1 @FirstApprovalId = intApproverId
				, @intApproverGroupId = intApproverGroupId
				, @StraussContractSubmitId = intSubmittedById
			FROM tblSMApproval WHERE	intTransactionId = @intTransactionId AND ysnCurrent = 1 AND strStatus = 'Approved' 
		END

	END

	select top 1
		@intChildDefaultSubmitById = (case when isnull(smc.intMultiCompanyParentId,0) = 0 then null else us.intEntityId end)
	from
		tblCTContractHeader ch
		inner join tblSMMultiCompany smc on smc.intMultiCompanyId = ch.intCompanyId
		inner join tblIPMultiCompany mc on mc.intCompanyId = smc.intMultiCompanyId
		inner join tblSMUserSecurity us on lower(us.strUserName) = lower(mc.strApprover)
	where
		ch.intContractHeaderId = @intContractHeaderId

	select
		@ysnIsParent = t.ysnIsParent
		,@blbParentSubmitSignature = h.blbDetail
		,@blbParentApproveSignature = j.blbDetail
		,@blbChildSubmitSignature = 
			CASE WHEN @thisContractStatus IN ('Approved', 'Approved with Modifications') AND t.ysnIsParent = 1 AND @strTransactionApprovalStatus IN ('Approved', 'Approved with Modifications') THEN l.blbDetail 
			ELSE 
				CASE WHEN @thisContractStatus IN ('Waiting for Approval', 'Approved', 'Approved with Modifications') AND t.ysnIsParent = 0 THEN l.blbDetail ELSE NULL END 
			END
		,@blbChildApproveSignature = 
			CASE WHEN @thisContractStatus IN ('Approved', 'Approved with Modifications') AND t.ysnIsParent = 1 AND @strTransactionApprovalStatus IN ('Approved', 'Approved with Modifications') THEN n.blbDetail
			ELSE
				CASE WHEN @thisContractStatus IN ('Waiting for Approval', 'Approved', 'Approved with Modifications') AND t.ysnIsParent = 0 THEN n.blbDetail ELSE NULL END
			END
	from
		(
		select
			ysnIsParent = (case when isnull(b.intMultiCompanyParentId,0) = 0 then convert(bit,1) else convert(bit,0) end)
			,intParentSubmitBy = (case when isnull(b.intMultiCompanyParentId,0) = 0 then @StraussContractSubmitId else d.intEntityId end)
			,intParentApprovedBy = (case when isnull(b.intMultiCompanyParentId,0) = 0 then @FirstApprovalId else ISNULL(f.intEntityId,k.intEntityId) end)
			,intChildSubmitBy = (case when isnull(b.intMultiCompanyParentId,0) = 0 then d.intEntityId else @StraussContractSubmitId end)
			,intChildApprovedBy = (case when isnull(b.intMultiCompanyParentId,0) = 0 then f.intEntityId else @FirstApprovalId end)
		from
			tblCTContractHeader a
			inner join tblSMMultiCompany b on b.intMultiCompanyId = a.intCompanyId
			left join tblCTIntrCompApproval c on c.intContractHeaderId = a.intContractHeaderId and c.strScreen IN ('Amendment and Approvals', 'Contract') AND ISNULL(c.intPriceFixationId, 0) = 0 and c.ysnApproval = 0
			left join tblSMUserSecurity d on lower(d.strUserName) = lower(c.strUserName)
			left join tblCTIntrCompApproval e on e.intContractHeaderId = a.intContractHeaderId and e.strScreen IN ('Amendment and Approvals', 'Contract') AND ISNULL(c.intPriceFixationId, 0) = 0 and e.ysnApproval = 1
			left join tblSMUserSecurity f on lower(f.strUserName) = lower(e.strUserName)
			left join tblCTIntrCompApproval j on j.intContractHeaderId = a.intContractHeaderId and j.strScreen =  'Contract' and j.ysnApproval = 1
			left join tblSMUserSecurity k on lower(k.strUserName) = lower(j.strUserName)
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
	
	SELECT @ysnExternal = (CASE WHEN intBookVsEntityId > 0 THEN CONVERT(BIT, 0) ELSE CONVERT(BIT, 1) END)
	FROM tblCTContractHeader CH
	LEFT JOIN tblCTBookVsEntity be ON be.intEntityId = CH.intEntityId
	WHERE CH.intContractHeaderId = @intContractHeaderId
	
	SELECT	@strCompanyName	=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) = '' THEN NULL ELSE LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) END
	FROM	tblSMCompanySetup WITH (NOLOCK)

	SELECT TOP 1 @strPackingDescription = strPackingDescription
		, @intContractDetailItemId = intItemId
		, @intContractDetailBundleItemId = intItemBundleId
		, @intFutureMarketId = intFutureMarketId
		, @intFutureMonthId = intFutureMonthId
		, @dblContractDetailBasis = dblBasis
		, @intBasisCurrencyId = intBasisCurrencyId
		, @intBasisUOMId = intBasisUOMId
		, @strFixationBy = strFixationBy
		, @dblCashPrice = dblCashPrice
		, @intPriceItemUOMId = intPriceItemUOMId
		, @dtmEndDate = dtmEndDate
		, @dtmStartDate = dtmStartDate
		, @intDestinationPortId = intDestinationPortId
	FROM tblCTContractDetail
	WHERE intContractHeaderId = @intContractHeaderId
	ORDER BY intContractSeq

	SELECT TOP 1 @strItemDescription = strDescription from tblICItem where intItemId = @intContractDetailItemId;
	SELECT TOP 1 @strItemBundleNo = strItemNo from tblICItem where intItemId = @intContractDetailBundleItemId;
	SELECT TOP 1 @strFutMarketName = strFutMarketName from tblRKFutureMarket where intFutureMarketId = @intFutureMarketId;
	SELECT TOP 1 @dtmFutureMonthsDate = dtmFutureMonthsDate from tblRKFuturesMonth where intFutureMonthId = @intFutureMonthId;

	set @strFutureMonthYear = DATENAME(mm,@dtmFutureMonthsDate) + ' ' + DATENAME(yyyy,@dtmFutureMonthsDate);

	select top 1 @strBasisCurrency = strCurrency from tblSMCurrency where intCurrencyID = @intBasisCurrencyId;
	select top 1 @intUnitMeasureId = intUnitMeasureId from tblICItemUOM where intItemUOMId = @intBasisUOMId;
	select top 1 @strUnitMeasure = strUnitMeasure from tblICUnitMeasure where intUnitMeasureId = @intUnitMeasureId;
	select top 1 @intUnitMeasureId2 = intUnitMeasureId from tblICItemUOM where intItemUOMId = @intPriceItemUOMId		
	select top 1 @strUnitMeasure2 = strUnitMeasure from tblICUnitMeasure where intUnitMeasureId = @intUnitMeasureId2

	set @strPriceCurrencyAndUOMForPriced2 = @strBasisCurrency + ' per ' + @strUnitMeasure2;

	select top 1 @strDestinationPort = strCity from tblSMCity where intCityId = @intDestinationPortId;

	SELECT	@strApplicableLaw = DM.strConditionDesc
	FROM	tblCTContractCondition	CD  WITH (NOLOCK)
	JOIN	tblCTCondition			DM	WITH (NOLOCK) ON DM.intConditionId = CD.intConditionId	
	WHERE	CD.intContractHeaderId	=	@intContractHeaderId
	AND		UPPER(DM.strConditionName)	=	'APPLICABLE LAW'

	SELECT	@strGeneralCondition = STUFF(								
			(
					SELECT
							'  </br>' + CASE WHEN dbo.fnTrim(CD.strConditionDescription) = '' THEN  DM.strConditionDesc ELSE CD.strConditionDescription END
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
	
	SELECT intContractHeaderId					= CH.intContractHeaderId
		,intContractTypeId						= CH.intContractTypeId
		,StraussContractSubmitByParentSignature	= @blbParentSubmitSignature
		,InterCompApprovalSign					= @blbParentApproveSignature
		,StraussContractSubmitSignature			= @blbChildSubmitSignature
		,StraussContractApproverSignature		= @blbChildApproveSignature
		,strEntityName							= (CASE WHEN @ysnIsParent = CONVERT(BIT, 0) THEN LTRIM(RTRIM(EY.strEntityName)) ELSE @strCompanyName END)
		,strCompanyName							= (CASE WHEN @ysnIsParent = CONVERT(BIT, 0) THEN @strCompanyName ELSE LTRIM(RTRIM(EY.strEntityName)) END)
		,strItemBundleNoLabel					= (CASE WHEN @ysnExternal = CONVERT(BIT, 0) THEN 'GROUP QUALITY CODE:' ELSE NULL END)
		,blbHeaderLogo							= dbo.fnSMGetCompanyLogo('Header')
		,strStraussOtherPartyAddress			= '<span style="font-family:Arial;font-size:12px;">' +
													CASE WHEN CH.strReportTo = 'Buyer'
													THEN
														'<b>' + LTRIM(RTRIM(EC.strEntityName)) + '</b></br>' +
														CASE WHEN REPLACE(ISNULL(LTRIM(RTRIM(EC.strEntityAddress)), ''), CHAR(10), '</br>') = '' THEN '' ELSE REPLACE(ISNULL(LTRIM(RTRIM(EC.strEntityAddress)), ''), CHAR(10), '</br>') + '</br>' END +
														CASE WHEN ISNULL(LTRIM(RTRIM(EC.strEntityZipCode)), '') = '' THEN '' ELSE LTRIM(RTRIM(EC.strEntityZipCode)) + ' ' END +
														CASE WHEN ISNULL(LTRIM(RTRIM(EC.strEntityCity)), '') = '' THEN CASE WHEN ISNULL(LTRIM(RTRIM(EC.strEntityZipCode)), '') = '' THEN '' ELSE '</br>' END ELSE LTRIM(RTRIM(EC.strEntityCity)) + '</br>' END +
														ISNULL(CASE WHEN LTRIM(RTRIM(EC.strEntityState)) = ''   THEN NULL ELSE LTRIM(RTRIM(EC.strEntityState)) + '</br>' END, '') +
														ISNULL(CASE WHEN LTRIM(RTRIM(EC.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityCountry)) END, '')
													ELSE
														'<b>' + LTRIM(RTRIM(EY.strEntityName)) + '</b></br>' +
														CASE WHEN REPLACE(ISNULL(LTRIM(RTRIM(EY.strEntityAddress)), ''), CHAR(10), '</br>') = '' THEN '' ELSE REPLACE(ISNULL(LTRIM(RTRIM(EY.strEntityAddress)), ''), CHAR(10), '</br>') + '</br>' END +
														CASE WHEN ISNULL(LTRIM(RTRIM(EY.strEntityZipCode)), '') = '' THEN '' ELSE LTRIM(RTRIM(EY.strEntityZipCode)) + ' ' END +
														CASE WHEN ISNULL(LTRIM(RTRIM(EY.strEntityCity)), '') = '' THEN CASE WHEN ISNULL(LTRIM(RTRIM(EY.strEntityZipCode)), '') = '' THEN '' ELSE '</br>' END ELSE LTRIM(RTRIM(EY.strEntityCity)) + '</br>' END +
														ISNULL(CASE WHEN LTRIM(RTRIM(EY.strEntityState)) = ''   THEN NULL ELSE LTRIM(RTRIM(EY.strEntityState)) + '</br>' END, '') +
														ISNULL(CASE WHEN LTRIM(RTRIM(EY.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityCountry)) END, '')
													END + '</span>'
		 ,dtmContractDate						= CH.dtmContractDate
		 ,strContractNumberStrauss				= CH.strContractNumber + (CASE WHEN LEN(LTRIM(RTRIM(ISNULL(@strAmendedColumns, '')))) = 0 OR (@strTransactionApprovalStatus = 'Waiting for Submit' OR @strTransactionApprovalStatus = 'Waiting for Approval') THEN '' ELSE ' - AMENDMENT' END)
		 ,strSeller							    = CASE WHEN CH.intContractTypeId = 2 THEN @strCompanyName ELSE EY.strEntityName END
		 ,strBuyer							    = CASE WHEN CH.intContractTypeId = 1 THEN @strCompanyName ELSE EY.strEntityName END
		 ,strStraussQuantity					= dbo.fnRemoveTrailingZeroes(CH.dblQuantity) + ' ' + UM.strUnitMeasure
		 ,strItemDescription					= @strItemDescription
		 ,strItemBundleNo						= (CASE WHEN @ysnExternal = CONVERT(BIT, 0) THEN @strItemBundleNo ELSE NULL END)
		 ,strStraussPrice						= CASE WHEN CH.intPricingTypeId = 2 THEN 'Price to be fixed basis ' + @strFutMarketName + ' ' +
															@strFutureMonthYear + CASE WHEN @dblContractDetailBasis < 0 THEN ' minus ' ELSE ' plus ' END +
															@strBasisCurrency + ' ' + dbo.fnCTChangeNumericScale(abs(@dblContractDetailBasis),2) + '/'+ @strUnitMeasure +' at '+ @strFixationBy+'''s option prior to first notice day of '+@strFutureMonthYear+' or on presentation of documents,whichever is earlier.'
													ELSE '' + dbo.fnCTChangeNumericScale(@dblCashPrice,2) + ' ' + @strPriceCurrencyAndUOMForPriced2 END
		,strStraussShipmentLabel				= (CASE WHEN PO.strPositionType = 'Spot' THEN 'DELIVERY' ELSE 'SHIPMENT' END)
		,strStraussShipment						= CONVERT(VARCHAR, @dtmStartDate, 101) + ' - ' + CONVERT(VARCHAR, @dtmEndDate, 101)
		,strDestinationPointName				= (CASE WHEN PO.strPositionType = 'Spot' THEN CT.strCity ELSE @strDestinationPort END)
		,strStraussCondition     				= CB.strFreightTerm + ' (' + CB.strDescription + ')' + ' ' + ISNULL(CT.strCity, '') + ' ' + ISNULL(W1.strWeightGradeDesc, '')
		,strTerm							    = TM.strTerm
		,strStraussApplicableLaw				= @strApplicableLaw
		,strStraussContract						= 'In accordance with ' + AN.strComment + ' (latest edition)'
		,strStrussOtherCondition				= '<span style="font-family:Arial;font-size:13px;">' + ISNULL(W2.strWeightGradeDesc, '') +  ISNULL(@strGeneralCondition, '') + '</span>'
		,blbFooterLogo						    = dbo.fnSMGetCompanyLogo('Footer') 
		,ysnExternal							= @ysnExternal
		,strArbitrationText						= (CASE WHEN @ysnExternal = CONVERT(BIT, 1) THEN ARB.strCity ELSE NULL END)
		,strReferenceNo							= CASE WHEN LTRIM(RTRIM(ISNULL(CH.strCustomerContract, ''))) <> '' THEN 'Your Ref. ' + ltrim(rtrim(CH.strCustomerContract)) ELSE NULL END

	FROM tblCTContractHeader CH
	LEFT JOIN vyuCTEntity EC WITH (NOLOCK) ON EC.intEntityId = CH.intCounterPartyId AND EC.strEntityType = 'Customer'
	LEFT JOIN tblSMCountry rtc12 on lower(rtrim(ltrim(rtc12.strCountry))) = lower(rtrim(ltrim(EC.strEntityCountry)))
	JOIN vyuCTEntity EY	WITH (NOLOCK) ON EY.intEntityId =	CH.intEntityId AND EY.strEntityType = (CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)
	LEFT JOIN tblICCommodityUnitMeasure	CU	WITH (NOLOCK) ON CU.intCommodityUnitMeasureId	=	CH.intCommodityUOMId		
	LEFT JOIN tblICUnitMeasure			UM	WITH (NOLOCK) ON UM.intUnitMeasureId			=	CU.intUnitMeasureId
	LEFT JOIN tblCTPosition				PO	WITH (NOLOCK) ON PO.intPositionId				=	CH.intPositionId
	LEFT JOIN tblSMCity					CT	WITH (NOLOCK) ON CT.intCityId					=	CH.intINCOLocationTypeId
	LEFT JOIN tblSMFreightTerms			CB	WITH (NOLOCK) ON CB.intFreightTermId			=	CH.intFreightTermId
	LEFT JOIN tblCTWeightGrade			W1	WITH (NOLOCK) ON W1.intWeightGradeId			=	CH.intWeightId
	LEFT JOIN tblSMTerm					TM	WITH (NOLOCK) ON TM.intTermID					=	CH.intTermId
	LEFT JOIN tblCTAssociation			AN	WITH (NOLOCK) ON AN.intAssociationId			=	CH.intAssociationId
	LEFT JOIN tblCTWeightGrade			W2	WITH (NOLOCK) ON W2.intWeightGradeId			=	CH.intGradeId
	LEFT JOIN tblSMCity ARB WITH (NOLOCK) ON ARB.intCityId = CH.intArbitrationId AND ISNULL(ARB.ysnArbitration, 0) = 1
	where CH.intContractHeaderId = @intContractHeaderId
	
	SELECT @ysnFeedOnApproval = ysnFeedOnApproval FROM tblCTCompanyPreference

	IF @IsFullApproved=1  OR ISNULL(@ysnFeedOnApproval,0) = 0
		UPDATE tblCTContractHeader SET ysnPrinted = 1 WHERE intContractHeaderId	= @intContractHeaderId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
