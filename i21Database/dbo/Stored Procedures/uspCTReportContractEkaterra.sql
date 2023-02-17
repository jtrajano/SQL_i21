CREATE PROCEDURE [dbo].[uspCTReportContractEkaterra]
	@xmlParam NVARCHAR(MAX) = NULL
AS

BEGIN TRY
	
	DECLARE
		@ErrMsg NVARCHAR(MAX)
		,@xmlDocumentId			INT
		,@strIds				NVARCHAR(MAX)
		,@ysnFeedOnApproval		BIT = 0
		,@IsFullApproved        BIT = 0
		,@intContractHeaderId	INT
		,@intScreenId			INT
		,@strCompanyName		NVARCHAR(500)
		,@strContractConditions	NVARCHAR(MAX)
		,@strContractDocuments	NVARCHAR(MAX)
		,@TotalLots				INT
		,@ysnFairtrade			BIT = 0
		,@type					NVARCHAR(50)
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
	DECLARE @strGeneralConditionName NVARCHAR(MAX)
	DECLARE @strGeneralCondition NVARCHAR(520)
	SELECT TOP 1 @strGeneralConditionName = DM.strConditionName							
					FROM	tblCTContractCondition	CD  WITH (NOLOCK)
					JOIN	tblCTCondition			DM	WITH (NOLOCK) ON DM.intConditionId = CD.intConditionId	
					WHERE	CD.intContractHeaderId	=	@intContractHeaderId	AND (UPPER(DM.strConditionName)	= 'GENERAL CONDITION' OR UPPER(DM.strConditionName) LIKE	'%GENERAL_CONDITION')
					
	SELECT	TOP 1 @strGeneralCondition = CASE WHEN dbo.fnTrim(CD.strConditionDescription) = '' THEN  DM.strConditionDesc ELSE CD.strConditionDescription END							
					FROM	tblCTContractCondition	CD  WITH (NOLOCK)
					JOIN	tblCTCondition			DM	WITH (NOLOCK) ON DM.intConditionId = CD.intConditionId	
					WHERE	CD.intContractHeaderId	=	@intContractHeaderId	AND (UPPER(DM.strConditionName)	= 'GENERAL CONDITION' OR UPPER(DM.strConditionName) LIKE	'%GENERAL_CONDITION') 
									
	--LOGO SETUP TAB IMPLEMENTATION
	DECLARE @imgLocationLogo vARBINARY (MAX),
			@strLogoType  NVARCHAR(50),
			@intCompanyLocationId INT,
			@locCount INT

	SELECT TOP 1 @intCompanyLocationId = intCompanyLocationId FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId
	SELECT TOP 1 @imgLocationLogo = imgLogo, @strLogoType = 'Logo' FROM tblSMLogoPreference
	WHERE (ysnDefault = 1 OR  ysnContract = 1)  AND  intCompanyLocationId = @intCompanyLocationId

	SELECT
		intContractHeaderId		= CH.intContractHeaderId
		,blbHeaderLogo			= dbo.[fnCTGetCompanyLogo]('Header', @intContractHeaderId)
		,blbFooterLogo			= dbo.[fnCTGetCompanyFooterLogo]('Footer', @intContractHeaderId)
		,strLogoType			= CASE WHEN dbo.[fnCTGetCompanyLocationCount](@intContractHeaderId) > 1 THEN 'Attachment' 
									   WHEN EXISTS (SELECT 1 FROM tblSMLogoPreference where intCompanyLocationId = @intCompanyLocationId AND  ysnContract = 0 ) THEN 'Attachment' 
								  ELSE ISNULL(@strLogoType,'Attachment') END
		,strLogoFooterType		= CASE WHEN dbo.[fnCTGetCompanyLocationCount](@intContractHeaderId) > 1 THEN 'Attachment' 
									   WHEN EXISTS (SELECT 1 FROM tblSMLogoPreferenceFooter where intCompanyLocationId = @intCompanyLocationId AND  ysnContract = 0 ) THEN 'Attachment' 
								  ELSE ISNULL(@strLogoType,'Attachment') END 
		,strContractTypeNumber	= /*TP.strContractType + ' Contract Nr. ' +*/ CH.strContractNumber
		,dtmContractDate		= CH.dtmContractDate
		,strBuyingOffice		= SC.strLocationName	
		,strVendorAdress		= LTRIM(RTRIM(EY.strEntityName)) + ' '+ CHAR(13)+CHAR(10) +
								  ISNULL(LTRIM(RTRIM(EY.strEntityAddress)),'')+' '+ ISNULL(LTRIM(RTRIM(EY.strEntityCity)),'') + ' ' + CHAR(13)+CHAR(10) +
								  ISNULL(LTRIM(RTRIM(EY.strEntityCountry)),'') +  CHAR(13)+CHAR(10) +
								  ISNULL(LTRIM(RTRIM(EY.strEntityZipCode)),'') +  CHAR(13)+CHAR(10) +
								  ISNULL(LTRIM(RTRIM(EY.strEntityPhone)),'') 
		,strVendorNo			= EY.strVendorAccountNum								  
		,strCompanyAddress		= LTRIM(RTRIM(SC.strLocationName)) + ' '+ CHAR(13)+CHAR(10) +
								  ISNULL(LTRIM(RTRIM(SC.strLocationNumber)),'')+' '+ ISNULL(LTRIM(RTRIM(SC.strAddress)),'') + ' ' +   ISNULL(LTRIM(RTRIM(SC.strCity)),'')+ CHAR(13)+CHAR(10) +
								  ISNULL(LTRIM(RTRIM(SC.strCountry)),'') +  CHAR(13)+CHAR(10) +
								  ISNULL(LTRIM(RTRIM(SC.strZipPostalCode)),'') +  CHAR(13)+CHAR(10) +
								  ISNULL(LTRIM(RTRIM(SC.strPhone)),'') 
		,strIncoterm			= CB.strFreightTerm
		,strCurrency			= SQ.strCurrency
		,strPaymentTerm			= TM.strTerm
		,strLocation			= CT.strCity
		,strPurchasingGroup     = SQ.strPurchasingGroup
		,strAmendedColumns		= ' '
		,strGeneralConditionName =@strGeneralConditionName
		,strGeneralCondition =@strGeneralCondition
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
		LEFT JOIN	tblSMCity					SCI WITH (NOLOCK) ON	SCI.intCityId					=	CH.intINCOLocationTypeId
		LEFT JOIN	tblEMEntity					PR	WITH (NOLOCK) ON	PR.intEntityId					=	CH.intProducerId			
		LEFT JOIN	tblCTPosition				PO	WITH (NOLOCK) ON	PO.intPositionId				=	CH.intPositionId
		LEFT JOIN	tblAPVendor					VR	WITH (NOLOCK) ON	VR.intEntityId					=	CH.intEntityId				
		LEFT JOIN	tblARCustomer				CR	WITH (NOLOCK) ON	CR.intEntityId					=	CH.intEntityId					
		LEFT JOIN	tblSMCity					CT	WITH (NOLOCK) ON	CT.intCityId					=	CH.intINCOLocationTypeId
		LEFT JOIN	tblSMCompanyLocationSubLocation		SL	WITH (NOLOCK) ON	SL.intCompanyLocationSubLocationId	=		CH.intWarehouseId
		LEFT JOIN	tblICCommodity				ICC WITH (NOLOCK) ON	ICC.intCommodityId				=	CH.intCommodityId
		LEFT JOIN	tblSMCompanyLocation		SC	WITH (NOLOCK) ON	SC.intCompanyLocationId			=	CH.intCompanyLocationId		
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
								,SCC.strCurrency
								,PG.strName + ' ' + PG.strDescription AS strPurchasingGroup 
					FROM		tblCTContractDetail		CD  WITH (NOLOCK)	
					LEFT JOIN	tblSMCity				LP	WITH (NOLOCK) ON	LP.intCityId				=	CD.intLoadingPortId	
					LEFT JOIN	tblEMEntity				TT	WITH (NOLOCK) ON	TT.intEntityId				=	CD.intShipperId			
					LEFT JOIN	tblSMCity				DP	WITH (NOLOCK) ON	DP.intCityId				=	CD.intDestinationPortId		
					LEFT JOIN	tblRKFutureMarket		MA	WITH (NOLOCK) ON	MA.intFutureMarketId		=	CD.intFutureMarketId
					LEFT JOIN	tblSMCurrency		    SCC	WITH (NOLOCK) ON	SCC.intCurrencyID			=	CD.intCurrencyId
					LEFT JOIN	tblSMPurchasingGroup	PG  WITH (NOLOCK) ON	PG.intPurchasingGroupId		= CD.intPurchasingGroupId
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