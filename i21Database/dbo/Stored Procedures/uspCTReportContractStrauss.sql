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
			,@ysnFairtrade							BIT = 0
			,@rtFLOID								nvarchar(10) = 'FLO ID'
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
			,@dtmEndDate							DateTime
			,@intDestinationPortId					INT
			,@strDestinationPort					NVARCHAR(500)
			,@strApplicableLaw						NVARCHAR(MAX)
			,@strGeneralCondition					NVARCHAR(MAX)
			,@ysnIsParent							int
			,@blbParentSubmitSignature				varbinary(max)
			,@blbParentApproveSignature				varbinary(max)
			,@blbChildSubmitSignature				varbinary(max)
			,@blbChildApproveSignature				varbinary(max)
			,@intChildDefaultSubmitById				int;

	DECLARE @tblSequenceHistoryId TABLE
	(
	  intSequenceAmendmentLogId INT
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

	
	SELECT @intScreenId=intScreenId FROM tblSMScreen WITH (NOLOCK) WHERE ysnApproval=1 AND strNamespace='ContractManagement.view.Contract'
	SELECT @intTransactionId=intTransactionId,@IsFullApproved = ysnOnceApproved FROM tblSMTransaction WITH (NOLOCK) WHERE intScreenId=@intScreenId AND intRecordId=@intContractHeaderId
	set @StraussContractSubmitId  = isnull(@intChildDefaultSubmitById,(SELECT TOP 1 intSubmittedById FROM tblSMApproval WHERE intTransactionId=@intTransactionId ORDER BY intApprovalId));
	SELECT TOP 1 @FirstApprovalId=intApproverId,@intApproverGroupId = intApproverGroupId FROM tblSMApproval WHERE intTransactionId=@intTransactionId AND strStatus='Approved' ORDER BY intApprovalId

	select
		@ysnIsParent = t.ysnIsParent
		,@blbParentSubmitSignature = h.blbDetail
		,@blbParentApproveSignature = j.blbDetail
		,@blbChildSubmitSignature = l.blbDetail
		,@blbChildApproveSignature = n.blbDetail
	from
		(
		select
			ysnIsParent = (case when isnull(b.intMultiCompanyParentId,0) = 0 then convert(bit,1) else convert(bit,0) end)
			,intParentSubmitBy = (case when isnull(b.intMultiCompanyParentId,0) = 0 then @StraussContractSubmitId else d.intEntityId end)
			,intParentApprovedBy = (case when isnull(b.intMultiCompanyParentId,0) = 0 then @FirstApprovalId else f.intEntityId end)
			,intChildSubmitBy = (case when isnull(b.intMultiCompanyParentId,0) = 0 then d.intEntityId else @StraussContractSubmitId end)
			,intChildApprovedBy = (case when isnull(b.intMultiCompanyParentId,0) = 0 then f.intEntityId else @FirstApprovalId end)
		from
			tblCTContractHeader a
			inner join tblSMMultiCompany b on b.intMultiCompanyId = a.intCompanyId
			left join tblCTIntrCompApproval c on c.intContractHeaderId = a.intContractHeaderId and c.strScreen = 'Contract' and c.ysnApproval = 0
			left join tblSMUserSecurity d on lower(d.strUserName) = lower(c.strUserName)
			left join tblCTIntrCompApproval e on e.intContractHeaderId = a.intContractHeaderId and e.strScreen = 'Contract' and e.ysnApproval = 1
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
	
	SELECT @ysnExternal = (case when intBookVsEntityId > 0 then convert(bit,1) else convert(bit,0) end)		
	FROM tblCTContractHeader CH
	left join tblCTBookVsEntity be on be.intEntityId = CH.intEntityId
	WHERE CH.intContractHeaderId = @intContractHeaderId

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

	INSERT INTO @tblSequenceHistoryId
	(
	  intSequenceAmendmentLogId
	)
	SELECT strValues FROM dbo.fnARGetRowsFromDelimitedValues(@strSequenceHistoryId)

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
	END

	IF @strAmendedColumns IS NULL SELECT @strAmendedColumns = ''

	SELECT	@strCompanyName	=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) = '' THEN NULL ELSE LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) END
	FROM	tblSMCompanySetup WITH (NOLOCK)

	select top 1 @strPackingDescription = strPackingDescription, @intContractDetailItemId = intItemId, @intContractDetailBundleItemId = intItemBundleId, @intFutureMarketId = intFutureMarketId, @intFutureMonthId = intFutureMonthId, @dblContractDetailBasis = dblBasis,@intBasisCurrencyId = intBasisCurrencyId, @intBasisUOMId = intBasisUOMId, @strFixationBy = strFixationBy, @dblCashPrice = dblCashPrice, @intPriceItemUOMId = intPriceItemUOMId, @dtmEndDate = dtmEndDate, @intDestinationPortId = intDestinationPortId from tblCTContractDetail where intContractHeaderId = @intContractHeaderId order by intContractSeq;
	select top 1 @strItemDescription = strDescription from tblICItem where intItemId = @intContractDetailItemId;
	select top 1 @strItemBundleNo = strItemNo from tblICItem where intItemId = @intContractDetailBundleItemId;
	select top 1 @strFutMarketName = strFutMarketName from tblRKFutureMarket where intFutureMarketId = @intFutureMarketId;
	select top 1 @dtmFutureMonthsDate = dtmFutureMonthsDate from tblRKFuturesMonth where intFutureMonthId = @intFutureMonthId;

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
	
	SELECT
		intContractHeaderId								= CH.intContractHeaderId
		,intContractTypeId								=		CH.intContractTypeId
		
		,StraussContractSubmitByParentSignature			=		@blbParentSubmitSignature--(case when @ysnIsParent = convert(bit,1) then @blbParentSubmitSignature else @blbChildSubmitSignature end)
		,InterCompApprovalSign							=		@blbParentApproveSignature--(case when @ysnIsParent = convert(bit,1) then @blbParentApproveSignature else @blbChildApproveSignature end)
		,StraussContractSubmitSignature					=		@blbChildSubmitSignature--(case when @ysnIsParent = convert(bit,1) then @blbChildSubmitSignature else @blbParentSubmitSignature end)
		,StraussContractApproverSignature				=		@blbChildApproveSignature--(case when @ysnIsParent = convert(bit,1) then @blbChildApproveSignature else @blbParentApproveSignature end)
		,strEntityName									=		(case when @ysnIsParent = convert(bit,0) then LTRIM(RTRIM(EY.strEntityName)) else @strCompanyName end)
		,strCompanyName									=		(case when @ysnIsParent = convert(bit,0) then @strCompanyName else LTRIM(RTRIM(EY.strEntityName)) end)
		
		,strItemBundleNoLabel							=		(case when @ysnExternal = convert(bit,1) then 'GROUP QUALITY CODE:' else null end)
		,blbHeaderLogo									=		dbo.fnSMGetCompanyLogo('Header')
		,strStraussOtherPartyAddress					= '<span style="font-family:Arial;font-size:12px;">' +
															CASE   
															WHEN
																CH.strReportTo = 'Buyer'
															THEN
																LTRIM(RTRIM(EC.strEntityName)) + '</br>'    +
																ISNULL(LTRIM(RTRIM(EC.strEntityAddress)),'') + '</br>' +
																ISNULL(LTRIM(RTRIM(EC.strEntityCity)),'') +   
																ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityState)) = ''   THEN NULL ELSE LTRIM(RTRIM(EC.strEntityState))   END,'') +   
																ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityZipCode)) END,'') +   
																ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityCountry)) END,'') +  
																CASE
																WHEN @ysnFairtrade = 1
																THEN ISNULL( CHAR(13)+CHAR(10) + @rtFLOID + ': ' +
																	CASE
																	WHEN LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) = ''
																	THEN NULL
																	ELSE LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId)))
																	END,
																	'')  
																ELSE
																	''
																END               
																ELSE
																	LTRIM(RTRIM(EY.strEntityName)) + '</br>' +
																	ISNULL(LTRIM(RTRIM(EY.strEntityAddress)),'') + '</br>' +
																	ISNULL(LTRIM(RTRIM(EY.strEntityCity)),'') +   
																	ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityState)) = ''   THEN NULL ELSE LTRIM(RTRIM(EY.strEntityState))   END,'') +   
																	ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityZipCode)) END,'') +   
																	ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityCountry)) END,'') +  
																	CASE
																	WHEN @ysnFairtrade = 1
																	THEN ISNULL( CHAR(13)+CHAR(10) + @rtFLOID + ': ' + 
																		CASE
																		WHEN LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) = ''
																		THEN NULL
																		ELSE LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId)))
																		END,
																		'')  
																	ELSE ''
																	END  
																END + '</span>'
	 ,dtmContractDate									= CH.dtmContractDate
	 ,strContractNumberStrauss				= CH.strContractNumber + (case when LEN(LTRIM(RTRIM(ISNULL(@strAmendedColumns,'')))) = 0 then '' else ' - AMENDMENT' end)
	 ,strSeller							    = CASE WHEN CH.intContractTypeId = 2 THEN @strCompanyName ELSE EY.strEntityName END
	 ,strBuyer							    = CASE WHEN CH.intContractTypeId = 1 THEN @strCompanyName ELSE EY.strEntityName END
	 ,strStraussQuantity					= dbo.fnRemoveTrailingZeroes(CH.dblQuantity) + ' ' + UM.strUnitMeasure + ' ' + ISNULL(@strPackingDescription, '')
	 ,strItemDescription					= @strItemDescription
	 ,strItemBundleNo						=	(case when @ysnExternal = convert(bit,1) then @strItemBundleNo else null end)
	 ,strStraussPrice						=	CASE WHEN CH.intPricingTypeId = 2 THEN 
															'Price to be fixed basis ' + @strFutMarketName + ' ' + 
															@strFutureMonthYear + CASE WHEN @dblContractDetailBasis < 0 THEN ' minus ' ELSE ' plus ' END +
															@strBasisCurrency + ' ' + dbo.fnCTChangeNumericScale(abs(@dblContractDetailBasis),2) + '/'+ @strUnitMeasure +' at '+ @strFixationBy+'''s option prior to first notice day of '+@strFutureMonthYear+' or on presentation of documents,whichever is earlier.'
														ELSE
															'' + dbo.fnCTChangeNumericScale(@dblCashPrice,2) + ' ' + @strPriceCurrencyAndUOMForPriced2	
														END
	,strStraussShipmentLabel				= (case when PO.strPositionType = 'Spot' then 'DELIVERY' else 'SHIPMENT' end)
	,strStraussShipment						= datename(m,@dtmEndDate) + ' ' + substring(CONVERT(VARCHAR,@dtmEndDate,107),9,4) + (case when PO.strPositionType = 'Spot' then ' delivery' else ' shipment' end)
	,strDestinationPointName				= (case when PO.strPositionType = 'Spot' then CT.strCity else @strDestinationPort end)
	,strStraussCondition     				= 	CB.strFreightTerm + '('+CB.strDescription+')' + ' ' + isnull(CT.strCity,'') + ' ' + isnull(W1.strWeightGradeDesc,'')
	,strTerm							    = TM.strTerm
	,strStraussApplicableLaw				=	@strApplicableLaw
	,strStraussContract						=	'In accordance with '+AN.strComment+' (latest edition)'
	,strStrussOtherCondition				= '<span style="font-family:Arial;font-size:13px;">' + isnull(W2.strWeightGradeDesc,'') +  isnull(@strGeneralCondition,'') + '</span>'
	,blbFooterLogo						    = dbo.fnSMGetCompanyLogo('Footer') 

	FROM
		tblCTContractHeader CH
		LEFT JOIN vyuCTEntity	EC WITH (NOLOCK)
			ON	EC.intEntityId = CH.intCounterPartyId  
			AND EC.strEntityType = 'Customer'
		LEFT JOIN tblSMCountry rtc12
			on lower(rtrim(ltrim(rtc12.strCountry))) = lower(rtrim(ltrim(EC.strEntityCountry)))
		LEFT JOIN tblAPVendor VR WITH (NOLOCK)
			ON VR.intEntityId = CH.intEntityId
		LEFT JOIN tblARCustomer CR WITH (NOLOCK)
			ON CR.intEntityId = CH.intEntityId
		JOIN vyuCTEntity EY	WITH (NOLOCK)
			ON EY.intEntityId =	CH.intEntityId
			AND EY.strEntityType = (CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)
	LEFT JOIN	tblICCommodityUnitMeasure	CU	WITH (NOLOCK) ON	CU.intCommodityUnitMeasureId	=	CH.intCommodityUOMId		
	LEFT JOIN	tblICUnitMeasure			UM	WITH (NOLOCK) ON	UM.intUnitMeasureId				=	CU.intUnitMeasureId
	LEFT JOIN	tblCTPosition				PO	WITH (NOLOCK) ON	PO.intPositionId				=	CH.intPositionId
	LEFT JOIN	tblSMCity					CT	WITH (NOLOCK) ON	CT.intCityId					=	CH.intINCOLocationTypeId
	LEFT JOIN	tblSMFreightTerms			CB	WITH (NOLOCK) ON	CB.intFreightTermId				=	CH.intFreightTermId
	LEFT JOIN	tblCTWeightGrade			W1	WITH (NOLOCK) ON	W1.intWeightGradeId				=	CH.intWeightId
	LEFT JOIN	tblSMTerm					TM	WITH (NOLOCK) ON	TM.intTermID					=	CH.intTermId
	LEFT JOIN	tblCTAssociation			AN	WITH (NOLOCK) ON	AN.intAssociationId				=	CH.intAssociationId
	LEFT JOIN	tblCTWeightGrade			W2	WITH (NOLOCK) ON	W2.intWeightGradeId				=	CH.intGradeId
	where CH.intContractHeaderId = @intContractHeaderId
	
	SELECT @ysnFeedOnApproval = ysnFeedOnApproval FROM tblCTCompanyPreference

	IF @IsFullApproved=1  OR ISNULL(@ysnFeedOnApproval,0) = 0
		UPDATE tblCTContractHeader SET ysnPrinted = 1 WHERE intContractHeaderId	= @intContractHeaderId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH