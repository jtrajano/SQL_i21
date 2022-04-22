CREATE PROCEDURE [dbo].[uspCTReportContractWalterMatter]
	@xmlParam NVARCHAR(MAX) = NULL
AS

BEGIN TRY
	
	DECLARE
		@ErrMsg NVARCHAR(MAX)
		,@xmlDocumentId			INT
		,@strIds						NVARCHAR(MAX)
		,@ysnFeedOnApproval		BIT = 0
		,@IsFullApproved         BIT = 0
		,@intContractHeaderId	INT
		,@intScreenId			INT
		,@strCompanyName			NVARCHAR(500)
		,@strContractConditions	NVARCHAR(MAX)
		,@strContractDocuments	NVARCHAR(MAX)
		,@TotalLots					INT
		,@ysnFairtrade			BIT = 0
		,@type						NVARCHAR(50)
		;


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

	SELECT	@type = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'Type'

	SELECT	TOP 1 @intContractHeaderId	= Item FROM dbo.fnSplitString(@strIds,',')

	SELECT	@intContractHeaderId = intContractHeaderId
	FROM	tblCTSequenceAmendmentLog WITH (NOLOCK)   
	WHERE	intSequenceAmendmentLogId = (SELECT MIN(intSequenceAmendmentLogId) FROM @tblSequenceHistoryId)

	SELECT @intScreenId=intScreenId FROM tblSMScreen WITH (NOLOCK) WHERE ysnApproval=1 AND strNamespace='ContractManagement.view.Contract'
	SELECT
		@IsFullApproved = ysnOnceApproved
	FROM tblSMTransaction WITH (NOLOCK)
	WHERE intScreenId=@intScreenId AND intRecordId=@intContractHeaderId

	SELECT	@strCompanyName	=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) = '' THEN NULL ELSE LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) END
	FROM	tblSMCompanySetup WITH (NOLOCK)

	INSERT INTO @tblContractDocument(strDocumentName)
	SELECT 			
		DM.strDocumentName
	FROM tblCTContractDocument CD WITH (NOLOCK)	
	JOIN tblICDocument DM WITH (NOLOCK) ON DM.intDocumentId = CD.intDocumentId	
	WHERE CD.intContractHeaderId = @intContractHeaderId
	ORDER BY DM.strDocumentName
	
	SELECT	@strContractDocuments = STUFF(								
			   (SELECT			
					CHAR(13)+CHAR(10) + char(149) +' ' + DM.strDocumentName	
					FROM tblCTContractDocument CD	
					JOIN tblICDocument DM WITH (NOLOCK) ON DM.intDocumentId = CD.intDocumentId	
					WHERE CD.intContractHeaderId=CH.intContractHeaderId	
					ORDER BY DM.strDocumentName		
					FOR XML PATH(''), TYPE				
			   ).value('.','varchar(max)')
			   ,1,2, ''						
		  )
	FROM tblCTContractHeader CH
	left join tblCTBookVsEntity be on be.intEntityId = CH.intEntityId
	WHERE CH.intContractHeaderId = @intContractHeaderId

	SELECT	@strContractConditions = STUFF(								
			(
					SELECT	CHAR(13)+CHAR(10) + DM.strConditionDesc
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

	SELECT
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

	SELECT
		intContractHeaderId					= CH.intContractHeaderId
		,blbHeaderLogo						    = dbo.fnSMGetCompanyLogo('Header')
		,strContractTypeNumber					= TP.strContractType + ' Contract Nr. ' + CH.strContractNumber
		,strContractType						= CASE WHEN CH.intContractTypeId = 1 THEN 'SELLER:' ELSE 'BUYER:' END
		,dtmContractDate						= CH.dtmContractDate
		,strOtherPartyAddress					= CASE 
													WHEN CH.strReportTo = 'Buyer' THEN
													LTRIM(RTRIM(EC.strEntityName)) + ', '				+ CHAR(13)+CHAR(10) +
													ISNULL(LTRIM(RTRIM(EC.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
													ISNULL(LTRIM(RTRIM(EC.strEntityCity)),'') + 
													ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityState)) = ''   THEN NULL ELSE LTRIM(RTRIM(EC.strEntityState))   END,'') + 
													ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityZipCode)) END,'') + 
													ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityCountry)) END,'') +
													CASE WHEN @ysnFairtrade = 1 THEN
														ISNULL( CHAR(13)+CHAR(10) + 'FLO ID: '+CASE WHEN LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) = '' THEN NULL ELSE LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) END,'')
													ELSE '' END													
													ELSE
													LTRIM(RTRIM(EY.strEntityName)) + ', '				+ CHAR(13)+CHAR(10) +
													ISNULL(LTRIM(RTRIM(EY.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
													ISNULL(LTRIM(RTRIM(EY.strEntityCity)),'') + 
													ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityState)) = ''   THEN NULL ELSE LTRIM(RTRIM(EY.strEntityState))   END,'') + 
													ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityZipCode)) END,'') + 
													ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityCountry)) END,'') +
													CASE WHEN @ysnFairtrade = 1 THEN
														ISNULL( CHAR(13)+CHAR(10) + 'FLO ID: '+CASE WHEN LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) = '' THEN NULL ELSE LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) END,'')
													ELSE '' END
													END
		,strAtlasDeclaration					= 'We confirm having' + CASE WHEN CH.intContractTypeId = 1	   THEN ' bought from '   ELSE ' sold to ' END + 'you as follows:'
		,strReferenceNo							= CASE WHEN CH.intContractTypeId = 2 THEN CH.strCustomerContract ELSE CH.strCustomerContract END	
		,strCommodityCode						= ICC.strDescription		
		,lblCropYear							= CASE WHEN ISNULL(CH.ysnPrintCropYear,'') <> 0	THEN 'Crop Year :'	ELSE NULL END
		,strCropYear							= CASE WHEN ISNULL(CH.ysnPrintCropYear,'') <> 0 THEN CY.strCropYear ELSE NULL END
		,strContractBasis						= CB.strFreightTerm + ' ' + SCI.strCity
		,strInsurance							= CASE WHEN ISNULL(CH.intInsuranceById,'') <>'' THEN ('To be covered by ' + CASE WHEN CH.intInsuranceById = 1 THEN 'Buyer' ELSE 'Seller' END) ELSE  ''  END
		,lblWeighing						    = CASE WHEN ISNULL(W1.strWeightGradeDesc,'') <>''	   THEN 'Weighing :'					ELSE NULL END
		,strWeight								= W1.strWeightGradeDesc
		,lblTerm								= CASE WHEN ISNULL(TM.strTerm,'') <>''				   THEN 'Payment Terms :'				ELSE NULL END
		,strTerm							    = TM.strTerm
		,lblGrade								= CASE WHEN ISNULL(W2.strWeightGradeDesc,'') <>''	   THEN 'Approval term :'				ELSE NULL END
		,strGrade								= CASE WHEN ISNULL(W2.strWeightGradeDesc,'') <>''	   THEN W2.strWeightGradeDesc			ELSE NULL END
		,strApprovalTerm						= CASE WHEN ISNULL(W2.strWeightGradeDesc,'') <>''	   THEN W2.strWeightGradeDesc			ELSE NULL END
		,strPriceFixation						= 'Price to be fixed by the ' + CASE WHEN ISNULL(SQ.strFixationBy,'') <> '' THEN SQ.strFixationBy +'''s call latest one day prior to the First Notice Day.' END		
		,lblContractCondition					= CASE WHEN ISNULL(@strContractConditions,'') <>''	   THEN 'Conditions:'					ELSE NULL END
		,strContractConditions				    = @strContractConditions	
		,lblContractDocuments					= CASE WHEN ISNULL(@strContractDocuments,'') <>''	   THEN 'Documents Required :'			ELSE NULL END
		,strContractDocuments					= @strContractDocuments
		,strPackaging							= 'In hydrocarbon-free bags as per IJO-Standard 98/01.'
		,strDressing							= (SELECT TOP 1 strConditionDesc FROM tblCTCondition where strConditionName LIKE '%Dressing%')		

		,lblBuyerRefNo							= CASE WHEN (CH.intContractTypeId = 1 AND ISNULL(CH.strContractNumber,'') <>'') OR (CH.intContractTypeId <> 1 AND ISNULL(CH.strCustomerContract,'') <>'') THEN  'Buyer Ref No. :'  ELSE NULL END
		,strBuyerRefNo							= CASE WHEN CH.intContractTypeId = 1 THEN CH.strContractNumber ELSE CH.strCustomerContract END
		,lblIncoTerms							= CASE WHEN ISNULL(CB.strFreightTerm,'') <>''		   THEN 'Incoterms :'					ELSE NULL END
		,lblPosition							= CASE WHEN ISNULL(PO.strPosition,'') <>''		       THEN 'Position :'					ELSE NULL END
		,strPosition							= PO.strPosition
		,lblAtlasProducer						= CASE WHEN ISNULL(PR.strName,'') <>''				   THEN 'Producer :'					ELSE NULL END
		,strProducer							= PR.strName
		,lblLoadingPoint						= CASE WHEN ISNULL(SQ.strLoadingPointName,'') <>''     THEN SQ.srtLoadingPoint + ' :'		ELSE NULL END
		,strLoadingPointName					= SQ.strLoadingPointName
		,lblSellerRefNo							= CASE WHEN (CH.intContractTypeId = 2 AND ISNULL(CH.strContractNumber,'') <>'') OR (CH.intContractTypeId <> 2 AND ISNULL(CH.strCustomerContract,'') <>'') THEN  'Seller Ref No. :' ELSE NULL END
		,strSellerRefNo							= CASE WHEN CH.intContractTypeId = 2 THEN CH.strContractNumber ELSE CH.strCustomerContract END
		,lblAtlasLocation				 		= CASE WHEN ISNULL(CASE WHEN CB.strINCOLocationType = 'City' THEN CT.strCity ELSE SL.strSubLocationName END,'') <>''     THEN 'Location :'					ELSE NULL END
		,strCityWarehouse						= CASE WHEN CB.strINCOLocationType = 'City' THEN CT.strCity ELSE SL.strSubLocationName END
		,lblShipper								= CASE WHEN ISNULL(SQ.strShipper,'') <>''			   THEN 'Shipper :'					    ELSE NULL END 
		,strShipper								= SQ.strShipper
		,lblDestinationPoint					= CASE WHEN ISNULL(SQ.strDestinationPointName,'') <>'' THEN SQ.srtDestinationPoint + ' :'   ELSE NULL END
		,strDestinationPointName				= (case when PO.strPositionType = 'Spot' then CT.strCity else SQ.strDestinationPointName end)
		,lblPricing								= CASE WHEN ISNULL(SQ.strFixationBy,'') <>'' AND ISNULL(SQ.strFutMarketName,'') <>'' AND CH.intPricingTypeId=2		   THEN 'Pricing :'		ELSE NULL END
		,strBeGreenCaller						= CASE WHEN ISNULL(SQ.strFixationBy,'') <> '' THEN SQ.strFixationBy +'''s Call vs '+LTRIM(@TotalLots)+' lots(s) of '+SQ.strFutMarketName + ' futures' ELSE NULL END
		,lblBeGreenArbitrationComment			= CASE WHEN ISNULL(AN.strComment,'') <>''			   THEN 'Rule :'							ELSE NULL END
		,strArbitrationComment				    = AN.strComment
		,lblArbitration							= CASE WHEN ISNULL(AN.strComment,'') <>''	 AND ISNULL(AB.strState,'') <>''		 AND ISNULL(RY.strCountry,'') <>'' THEN 'Arbitration:'  ELSE NULL END
		,strArbitration							=   AB.strCity
		,lblContractText						= CASE WHEN ISNULL(TX.strText,'') <>''				   THEN 'Others :'						ELSE NULL END
		,strContractText						= ISNULL(TX.strText,'') 
		,lblPrintableRemarks					= CASE WHEN ISNULL(CH.strPrintableRemarks,'') <>''	   THEN 'Notes/Remarks :'				ELSE NULL END
		,strPrintableRemarks				    = CH.strPrintableRemarks			
		,strBuyer							    = CASE WHEN CH.intContractTypeId = 1 THEN @strCompanyName ELSE EY.strEntityName END
		,strSeller							    = CASE WHEN CH.intContractTypeId = 2 THEN @strCompanyName ELSE EY.strEntityName END
	FROM
		tblCTContractHeader				CH
		JOIN	tblCTContractType				TP	WITH (NOLOCK) ON	TP.intContractTypeId			=	CH.intContractTypeId
		JOIN	vyuCTEntity						EY	WITH (NOLOCK) ON	EY.intEntityId					=	CH.intEntityId	AND EY.strEntityType					=	(CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)
		LEFT JOIN	vyuCTEntity					EC	WITH (NOLOCK) ON	EC.intEntityId					=	CH.intCounterPartyId  
		LEFT JOIN	tblCTCropYear				CY	WITH (NOLOCK) ON	CY.intCropYearId				=	CH.intCropYearId			
		LEFT JOIN	tblSMFreightTerms			CB	WITH (NOLOCK) ON	CB.intFreightTermId				=	CH.intFreightTermId		
		LEFT JOIN	tblCTWeightGrade			W1	WITH (NOLOCK) ON	W1.intWeightGradeId				=	CH.intWeightId				
		LEFT JOIN	tblCTWeightGrade			W2	WITH (NOLOCK) ON	W2.intWeightGradeId				=	CH.intGradeId				
		LEFT JOIN	tblCTContractText			TX	WITH (NOLOCK) ON	TX.intContractTextId			=	CH.intContractTextId		
		LEFT JOIN	tblCTAssociation			AN	WITH (NOLOCK) ON	AN.intAssociationId				=	CH.intAssociationId			
		LEFT JOIN	tblSMTerm					TM	WITH (NOLOCK) ON	TM.intTermID					=	CH.intTermId				
		LEFT JOIN	tblSMCity					AB	WITH (NOLOCK) ON	AB.intCityId					=	CH.intArbitrationId			
		LEFT JOIN	tblSMCountry				RY	WITH (NOLOCK) ON	RY.intCountryID					=	AB.intCountryId
		LEFT JOIN	tblSMCountry				SMC WITH (NOLOCK) ON	SMC.intCountryID				=	CH.intCountryId
		LEFT JOIN	tblSMCity					SCI WITH (NOLOCK) ON	SCI.intCountryId				=	SMC.intCountryID
		LEFT JOIN	tblEMEntity					PR	WITH (NOLOCK) ON	PR.intEntityId					=	CH.intProducerId			
		LEFT JOIN	tblCTPosition				PO	WITH (NOLOCK) ON	PO.intPositionId				=	CH.intPositionId
		LEFT JOIN	tblAPVendor					VR	WITH (NOLOCK) ON	VR.intEntityId					=	CH.intEntityId				
		LEFT JOIN	tblARCustomer				CR	WITH (NOLOCK) ON	CR.intEntityId					=	CH.intEntityId					
		LEFT JOIN	tblSMCity					CT	WITH (NOLOCK) ON	CT.intCityId					=	CH.intINCOLocationTypeId
		LEFT JOIN	tblSMCompanyLocationSubLocation		SL	WITH (NOLOCK) ON	SL.intCompanyLocationSubLocationId	=		CH.intWarehouseId
		LEFT JOIN	tblICCommodity				ICC WITH (NOLOCK) ON	ICC.intCommodityId				=	CH.intCommodityId
		
		LEFT JOIN	(
					SELECT		ROW_NUMBER() OVER (PARTITION BY CD.intContractHeaderId ORDER BY CD.intContractSeq ASC) AS intRowNum
				
								,CD.intContractHeaderId
								,LP.strCity								AS	strLoadingPointName
								,'Loading ' + CD.strLoadingPointType		AS	srtLoadingPoint
								,TT.strName								AS	strShipper
								,DP.strCity								AS	strDestinationPointName
								,'Destination ' + CD.strLoadingPointType AS	srtDestinationPoint
								,CD.strFixationBy
								,strFutMarketName = MA.strFutMarketName
					FROM		tblCTContractDetail		CD  WITH (NOLOCK)	
					LEFT JOIN	tblSMCity				LP	WITH (NOLOCK) ON	LP.intCityId				=	CD.intLoadingPortId	
					LEFT JOIN	tblEMEntity				TT	WITH (NOLOCK) ON	TT.intEntityId				=	CD.intShipperId			
					LEFT JOIN	tblSMCity				DP	WITH (NOLOCK) ON	DP.intCityId				=	CD.intDestinationPortId		
					LEFT JOIN	tblRKFutureMarket		MA	WITH (NOLOCK) ON	MA.intFutureMarketId		=	CD.intFutureMarketId
				) SQ ON	SQ.intContractHeaderId = CH.intContractHeaderId AND SQ.intRowNum = 1
	where CH.intContractHeaderId = @intContractHeaderId
	
	SELECT @ysnFeedOnApproval = ysnFeedOnApproval FROM tblCTCompanyPreference

	IF @IsFullApproved=1  OR ISNULL(@ysnFeedOnApproval,0) = 0
		UPDATE tblCTContractHeader SET ysnPrinted = 1 WHERE intContractHeaderId	= @intContractHeaderId

END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH
GO