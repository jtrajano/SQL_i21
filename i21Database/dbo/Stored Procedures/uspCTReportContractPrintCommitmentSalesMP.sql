CREATE PROCEDURE [dbo].[uspCTReportContractPrintCommitmentSalesMP]
	@xmlParam NVARCHAR(MAX) = NULL
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)	
	 

	DECLARE
			@xmlDocumentId							INT
			,@ysnFeedOnApproval						BIT = 0
			,@IsFullApproved						BIT = 0
			,@MPContractSubmitId					INT
			,@intContractHeaderId					INT
			,@intContractDetailId					INT
			,@strIds								NVARCHAR(MAX)
			,@intMPCompanyId						INT
			,@FirstApprovalId						INT
			,@intApproverGroupId					INT
			,@intTransactionId						INT
			,@intScreenId							INT
			,@intSrCurrentUserId					INT
			,@ysnExternal							BIT
			,@ysnFairtrade							BIT = 0
			,@rtFLOID								nvarchar(10) = 'FLO ID'
			,@strAmendedColumns						NVARCHAR(MAX)
			,@strContractDetailId					NVARCHAR(MAX)
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
			,@intCurrencyExchangeRateId				INT
			,@dblForexRate							numeric(18,6)
			,@intBasisCurrencyId					INT
			,@strBasisCurrency						NVARCHAR(500)
			,@intSequenceCurrency					INT
			,@strSequenceCurrency					NVARCHAR(500)
			,@intBasisUOMId							INT
			,@intUnitMeasureId						INT
			,@strUnitMeasure						NVARCHAR(500)
			,@strFixationBy							NVARCHAR(500)
			,@dblCashPrice							numeric(18,6)
			,@strPriceCurrencyAndUOMForPriced2		NVARCHAR(500)
			,@dblFutures							numeric(18,6)
			,@intPriceItemUOMId						INT
			,@intUnitMeasureId2						INT
			,@strUnitMeasure2						NVARCHAR(500)
			,@dtmEndDate							DateTime
			,@dtmStartDate							DateTime
			,@intDestinationPortId					INT
			,@strDestinationPort					NVARCHAR(500)
			,@strApplicableLaw						NVARCHAR(MAX)
			,@strGeneralCondition					NVARCHAR(MAX)
			,@ysnIsParent							int
			,@blbParentSubmitSignature				varbinary(max)
			,@blbParentApproveSignature				varbinary(max)
			,@blbChildSubmitSignature				varbinary(max)
			,@blbChildApproveSignature				varbinary(max)
			,@blbPerCompanySignature				varbinary(max)
			,@intChildDefaultSubmitById				int
			,@strTransactionApprovalStatus			NVARCHAR(100)
			,@strFromCurrency						NVARCHAR(100)
			,@strToCurrency							NVARCHAR(100);

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

	SELECT	@strContractDetailId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intContractDetailId'

	SELECT	@intSrCurrentUserId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intSrCurrentUserId'

	SELECT	TOP 1 @intContractHeaderId	= Item FROM dbo.fnSplitString(@strIds,',')
	SELECT	TOP 1 @intContractDetailId	= Item FROM dbo.fnSplitString(@strContractDetailId,',')

	SELECT @intScreenId=intScreenId FROM tblSMScreen WITH (NOLOCK) WHERE ysnApproval=1 AND strNamespace='ContractManagement.view.Contract'
	SELECT @intTransactionId=intTransactionId,@IsFullApproved = ysnOnceApproved FROM tblSMTransaction WITH (NOLOCK) WHERE intScreenId=@intScreenId AND intRecordId=@intContractHeaderId

	SELECT	TOP 1 @FirstApprovalId = intApproverId
		, @intApproverGroupId = intApproverGroupId
		, @MPContractSubmitId = intSubmittedById
	FROM	tblSMApproval 
	WHERE	intTransactionId = @intTransactionId
	AND		strStatus = 'Approved' 
	ORDER BY intApprovalId

	IF (ISNULL(@MPContractSubmitId, 0) = 0)
	BEGIN
		SELECT	TOP 1 @MPContractSubmitId = intSubmittedById
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
			, @MPContractSubmitId = NULL
		END

		IF @strTransactionApprovalStatus = 'Waiting for Approval'
		BEGIN
			SELECT @FirstApprovalId = NULL
			, @intApproverGroupId = NULL
			, @MPContractSubmitId = intSubmittedById
			FROM tblSMApproval WHERE	intTransactionId = @intTransactionId AND ysnCurrent = 1 AND strStatus = 'Waiting for Approval' 
		END

		IF @strTransactionApprovalStatus = 'Approved'
		BEGIN
			SELECT	TOP 1 @FirstApprovalId = intApproverId
				, @intApproverGroupId = intApproverGroupId
				, @MPContractSubmitId = intSubmittedById
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
		,@blbChildSubmitSignature = l.blbDetail
		,@blbChildApproveSignature = n.blbDetail
	from
		(
		select
			ysnIsParent = (case when isnull(b.intMultiCompanyParentId,0) = 0 then convert(bit,1) else convert(bit,0) end)
			,intParentSubmitBy = (case when isnull(b.intMultiCompanyParentId,0) = 0 then @MPContractSubmitId else d.intEntityId end)
			,intParentApprovedBy = (case when isnull(b.intMultiCompanyParentId,0) = 0 then @FirstApprovalId else f.intEntityId end)
			,intChildSubmitBy = (case when isnull(b.intMultiCompanyParentId,0) = 0 then d.intEntityId else @MPContractSubmitId end)
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
	
	select @blbPerCompanySignature = h.blbDetail
	from tblEMEntitySignature g 
		left join tblSMSignature h  on h.intEntityId = g.intEntityId and h.intSignatureId = g.intElectronicSignatureId
		WHERE g.intEntityId = @intSrCurrentUserId
		
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

	IF (ISNULL(@strContractDetailId, '') <> '')
	BEGIN
		INSERT INTO @tblSequenceHistoryId (intSequenceHistoryId)
		SELECT strValues FROM dbo.fnARGetRowsFromDelimitedValues(@strContractDetailId)
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
		
		SELECT TOP 1 @dtmApproveDate = CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset, A.dtmDate), DATENAME(TzOffset, SYSDATETIMEOFFSET())))
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

	SELECT	@strCompanyName	=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) = '' THEN NULL ELSE LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) END
	FROM	tblSMCompanySetup WITH (NOLOCK)

	select top 1 @strPackingDescription = strPackingDescription, @intContractDetailItemId = intItemId, @intContractDetailBundleItemId = intItemBundleId, @intFutureMarketId = intFutureMarketId, @intFutureMonthId = intFutureMonthId, 
				 @intSequenceCurrency = intCurrencyId, @dblContractDetailBasis = dblBasis,@intBasisCurrencyId = intBasisCurrencyId, @intBasisUOMId = intBasisUOMId, @strFixationBy = strFixationBy, @dblCashPrice = dblCashPrice, @dblFutures = dblFutures,
				 @intPriceItemUOMId = intPriceItemUOMId, @dtmStartDate = dtmStartDate, @dtmEndDate = dtmEndDate, @intDestinationPortId = intDestinationPortId, @intCurrencyExchangeRateId = intCurrencyExchangeRateId, @dblForexRate = dblRate
	from tblCTContractDetail 			 
	where intContractDetailId = @intContractDetailId order by intContractSeq;

	select top 1 @strItemDescription = strDescription from tblICItem where intItemId = @intContractDetailItemId;
	select top 1 @strItemBundleNo = strItemNo from tblICItem where intItemId = @intContractDetailBundleItemId;
	select top 1 @strFutMarketName = strFutMarketName from tblRKFutureMarket where intFutureMarketId = @intFutureMarketId;
	select top 1 @dtmFutureMonthsDate = dtmFutureMonthsDate from tblRKFuturesMonth where intFutureMonthId = @intFutureMonthId;

	set @strFutureMonthYear = DATENAME(mm,@dtmFutureMonthsDate) + ' ' + DATENAME(yyyy,@dtmFutureMonthsDate);

	
	select top 1 @strSequenceCurrency = strCurrency from tblSMCurrency where intCurrencyID = @intSequenceCurrency;
	select top 1 @strBasisCurrency = strCurrency from tblSMCurrency where intCurrencyID = @intBasisCurrencyId;
	select top 1 @intUnitMeasureId = intUnitMeasureId from tblICItemUOM where intItemUOMId = @intBasisUOMId;
	select top 1 @strUnitMeasure = strUnitMeasure from tblICUnitMeasure where intUnitMeasureId = @intUnitMeasureId;
	select top 1 @intUnitMeasureId2 = intUnitMeasureId from tblICItemUOM where intItemUOMId = @intPriceItemUOMId		
	select top 1 @strUnitMeasure2 = strUnitMeasure from tblICUnitMeasure where intUnitMeasureId = @intUnitMeasureId2
	select top 1 @strFromCurrency = ISNULL(strSymbol,'') +''+ strCurrency from tblSMCurrency c
	INNER JOIN tblSMCurrencyExchangeRate er ON c.intCurrencyID = er.intFromCurrencyId and intCurrencyExchangeRateId = @intCurrencyExchangeRateId
	select top 1 @strToCurrency = ISNULL(strSymbol,'')  +''+ strCurrency from tblSMCurrency c
	INNER JOIN tblSMCurrencyExchangeRate er ON c.intCurrencyID = er.intToCurrencyId and intCurrencyExchangeRateId = @intCurrencyExchangeRateId

	set @strPriceCurrencyAndUOMForPriced2 = @strSequenceCurrency + ', per ' + @strUnitMeasure2;

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
		,intContractTypeId								= CH.intContractTypeId
		,MPContractSubmitByParentSignature				= @blbParentSubmitSignature
		,InterCompApprovalSign							= @blbParentApproveSignature
		,MPContractSubmitSignature						= @blbChildSubmitSignature
		,MPContractApproverSignature					= @blbChildApproveSignature
		,strExchangeRate								= '( ' + @strFromCurrency + ' to ' + @strToCurrency +' )' 
		,dblForexRate									= @dblForexRate
		,strCompanyName									= (case when @ysnIsParent = convert(bit,0) then LTRIM(RTRIM(EY.strEntityName)) else @strCompanyName end)
		,intEntityId									= CH.intEntityId
		,strCustomerName								= (case when @ysnIsParent = convert(bit,0) then @strCompanyName else LTRIM(RTRIM(EL.strCheckPayeeName)) end)
		,strCustomerNumber								= PN.strPhone
		,strCustomerEmail								= PC.strEmail
		,blbHeaderLogo									= dbo.fnSMGetCompanyLogo('Header')
		,strContractDate								= CONVERT (VARCHAR, CH.dtmContractDate, 107) 
		,strFutureMonth									= @strFutureMonthYear
		,strFutureMarket								= @strFutMarketName
		,strFutureMarketMonth							= @strFutureMonthYear +','+ @strFutMarketName
		,dblSequencePrice								= @dblFutures
		,strPriceCurrencyAndUOMForPriced				= @strPriceCurrencyAndUOMForPriced2
		,dblQuantity									= dblQuantity
		,strContractNumberMP							= CH.strContractNumber
		,strTodaysDate									= CONVERT (VARCHAR, getdate(), 107)
		,strSequenceStartEndDate						= DATENAME (MONTH, @dtmStartDate) + ' / ' +   DATENAME (YEAR, @dtmStartDate)  + ' - ' + DATENAME (MONTH, @dtmEndDate) + ' / ' +   DATENAME (YEAR, @dtmEndDate)
		--,strSeller										= CASE WHEN CH.intContractTypeId = 2 THEN @strCompanyName ELSE EY.strEntityName END
		--,strBuyer										= CASE WHEN CH.intContractTypeId = 1 THEN @strCompanyName ELSE EY.strEntityName END
		,strMPQuantity									= dbo.fnRemoveTrailingZeroes(CH.dblQuantity) + ' ' + UM.strUnitMeasure
		,strItemDescription								= @strItemDescription
		,strItemBundleNo								=	(case when @ysnExternal = convert(bit,1) then @strItemBundleNo else null end)
		,strMPPrice										=	CASE WHEN CH.intPricingTypeId = 2 THEN 
																'Price to be fixed basis ' + @strFutMarketName + ' ' + 
																@strFutureMonthYear + CASE WHEN @dblContractDetailBasis < 0 THEN ' minus ' ELSE ' plus ' END +
																@strBasisCurrency + ' ' + dbo.fnCTChangeNumericScale(abs(@dblContractDetailBasis),2) + '/'+ @strUnitMeasure +' at '+ @strFixationBy+'''s option prior to first notice day of '+@strFutureMonthYear+' or on presentation of documents,whichever is earlier.'
															ELSE
																'' + dbo.fnCTChangeNumericScale(@dblCashPrice,2) + ' ' + @strPriceCurrencyAndUOMForPriced2	
															END
		,strTerm										= TM.strTerm
		,strMPContract									=  AN.strComment
		,strStrussOtherCondition						= '<span style="font-family:Arial;font-size:13px;">' + isnull(W2.strWeightGradeDesc,'') +  isnull(@strGeneralCondition,'') + '</span>'
		,strHeaderCondition								=  isnull(CC.strConditionDescription,'') 
		,strContractText								= CTT.strText
		,blbFooterLogo									= dbo.fnSMGetCompanyLogo('Footer')
		,strSalesPerson									= ETS.strName
		,strPrimaryContact								= PC.strName
		,blbCompanySignature							= SU.blbFile
	FROM
		tblCTContractHeader CH
		LEFT JOIN vyuCTEntity	EC 
			WITH (NOLOCK) ON	EC.intEntityId = CH.intCounterPartyId   AND EC.strEntityType = 'Customer'
		LEFT JOIN tblSMCountry rtc12
			on lower(rtrim(ltrim(rtc12.strCountry))) = lower(rtrim(ltrim(EC.strEntityCountry)))
		LEFT JOIN tblAPVendor VR 
			WITH (NOLOCK) ON VR.intEntityId = CH.intEntityId
		LEFT JOIN tblARCustomer CR 
			WITH (NOLOCK) ON CR.intEntityId = CH.intEntityId
		JOIN vyuCTEntity EY	
			WITH (NOLOCK) ON EY.intEntityId	=	CH.intEntityId
			AND EY.strEntityType = (CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)
		LEFT JOIN tblEMEntity ET
			WITH (NOLOCK) ON ET.intEntityId = EY.intEntityId
		LEFT JOIN tblEMEntityLocation EL
			WITH (NOLOCK) ON EL.intEntityId	=CH.intEntityId
		LEFT JOIN tblEMEntity ETS
			WITH (NOLOCK) ON ETS.intEntityId = CH.intSalespersonId
		INNER JOIN dbo.[tblEMEntityToContact] ETC
			WITH (NOLOCK)ON ETC.intEntityId = CH.intEntityId
		INNER JOIN dbo.tblEMEntity PC
			WITH (NOLOCK) ON ETC.intEntityContactId = PC.[intEntityId] AND ETC.ysnDefaultContact = 1
		INNER JOIN dbo.tblEMEntityPhoneNumber PN
			WITH (NOLOCK) ON PN.[intEntityId] = PC.[intEntityId]
		LEFT JOIN	tblICCommodityUnitMeasure	CU	
			WITH (NOLOCK) ON	CU.intCommodityUnitMeasureId	=	CH.intCommodityUOMId		
		LEFT JOIN	tblICUnitMeasure			UM	
			WITH (NOLOCK) ON	UM.intUnitMeasureId				=	CU.intUnitMeasureId
		LEFT JOIN	tblCTPosition				PO	
			WITH (NOLOCK) ON	PO.intPositionId				=	CH.intPositionId
		LEFT JOIN	tblSMCity					CT	
			WITH (NOLOCK) ON	CT.intCityId					=	CH.intINCOLocationTypeId
		LEFT JOIN	tblSMFreightTerms			CB	
			WITH (NOLOCK) ON	CB.intFreightTermId				=	CH.intFreightTermId
		LEFT JOIN	tblCTWeightGrade			W1	
			WITH (NOLOCK) ON	W1.intWeightGradeId				=	CH.intWeightId
		LEFT JOIN	tblSMTerm					TM	
			WITH (NOLOCK) ON	TM.intTermID					=	CH.intTermId
		LEFT JOIN	tblCTAssociation			AN	
			WITH (NOLOCK) ON	AN.intAssociationId				=	CH.intAssociationId
		LEFT JOIN	tblCTWeightGrade			W2	
			WITH (NOLOCK) ON	W2.intWeightGradeId				=	CH.intGradeId
		LEFT JOIN tblCTContractText CTT
			WITH  (NOLOCK) ON CTT.intContractTextId				=	CH.intContractTextId
		LEFT JOIN tblARSalesperson SP  
			WITH  (NOLOCK) ON SP.intEntityId = CH.intSalespersonId
		LEFT JOIN tblSMAttachment SA  
			WITH  (NOLOCK) ON SA.intAttachmentId= SP.intAttachmentSignatureId
		LEFT JOIN tblSMUpload SU 
			WITH  (NOLOCK) ON SU.intAttachmentId= SA.intAttachmentId
		OUTER APPLY (
			 SELECT 
			 intContractHeaderId	= intContractHeaderId
			,strConditionDescription= strConditionDescription
			
			FROM   tblCTContractCondition CC
			INNER JOIN tblCTCondition C ON C.intConditionId = CC.intConditionId
			WHERE  CC.intContractHeaderId =  CH.intContractHeaderId
			AND C.strConditionName NOT LIKE UPPER('%DISCLAIMER%') 
		)CC
		
	where CH.intContractHeaderId = @intContractHeaderId
	
	SELECT @ysnFeedOnApproval = ysnFeedOnApproval FROM tblCTCompanyPreference

	IF @IsFullApproved=1  OR ISNULL(@ysnFeedOnApproval,0) = 0
		UPDATE tblCTContractHeader SET ysnPrinted = 1 WHERE intContractHeaderId	= @intContractHeaderId

END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspCTReportContractPrintCommitmentSalesMP - '+ ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH