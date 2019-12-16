CREATE PROCEDURE [dbo].[uspCTReportSampleInstruction]
	
	@xmlParam NVARCHAR(MAX) = NULL  
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX),
			@xmlDocumentId	INT
		

	DECLARE @strCompanyName			NVARCHAR(500),
			@strAddress				NVARCHAR(500),
			@strCounty				NVARCHAR(500),
			@strCity				NVARCHAR(500),
			@strState				NVARCHAR(500),
			@strZip					NVARCHAR(500),
			@strCountry				NVARCHAR(500),
			@intContractHeaderId	INT,
			@intLaguageId			INT,
			@intSrCurrentUserId		INT,
			@strCurrentUser			NVARCHAR(100)

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
    
	SELECT	@intContractHeaderId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intContractHeaderId'
	
	SELECT	@intLaguageId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intSrLanguageId'
	
	SELECT	@intSrCurrentUserId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intSrCurrentUserId'

	SELECT	@strCurrentUser = strName FROM tblEMEntity WHERE intEntityId = @intSrCurrentUserId

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

	

	SELECT	 intContractHeaderId					=	CH.intContractHeaderId
			,strBuyerRefNo							=	CASE WHEN CH.intContractTypeId = 1 THEN CH.strContractNumber ELSE CH.strCustomerContract END
			,strSellerRefNo							=	CASE WHEN CH.intContractTypeId = 2 THEN CH.strContractNumber ELSE CH.strCustomerContract END
			,strContractNumber						=	CH.strContractNumber
			,strDestinationPointName				=	SQ.strDestinationPointName
			,strItemDescription						=	strItemDescription
			,strQuantity							=	dbo.fnRemoveTrailingZeroes(CH.dblQuantity) + ' ' + UM.strUnitMeasure + ' ' + ISNULL(SQ.strPackingDescription, '')
			,strShipment							=	REPLACE(CONVERT (VARCHAR,GETDATE(),107),LTRIM(DAY (GETDATE())) + ', ' ,'') + ' shipment at '+ SQ.strFixationBy+'''s option'

			,strEntityAddress						=  	LTRIM(RTRIM(EY.strEntityName)) + ', '				+ CHAR(13)+CHAR(10) +
													  	ISNULL(LTRIM(RTRIM(EY.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
													  	ISNULL(LTRIM(RTRIM(EY.strEntityCity)),'') + 
													  	ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityState)) = ''   THEN NULL ELSE LTRIM(RTRIM(EY.strEntityState))   END,'') + 
													  	ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityZipCode)) END,'') + 
													  	ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityCountry)) END,'')
													  	
			,strBookEntityAddress					=  	LTRIM(RTRIM(EV.strEntityName)) + ', '				+ CHAR(13)+CHAR(10) +
													  	ISNULL(LTRIM(RTRIM(EV.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
													  	ISNULL(LTRIM(RTRIM(EV.strEntityCity)),'') + 
													  	ISNULL(', '+CASE WHEN LTRIM(RTRIM(EV.strEntityState)) = ''   THEN NULL ELSE LTRIM(RTRIM(EV.strEntityState))   END,'') + 
													  	ISNULL(', '+CASE WHEN LTRIM(RTRIM(EV.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EV.strEntityZipCode)) END,'') + 
													  	ISNULL(', '+CASE WHEN LTRIM(RTRIM(EV.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EV.strEntityCountry)) END,'')
			,strLocationWithDate					=	SQ.strLocationName+', '+ CONVERT (VARCHAR,CH.dtmContractDate,106)
			,strCustomerContract					=	CH.strCustomerContract
			,strStraussText1						=	'<p>Pls arrange for pre-shipment samples for the above mentioned consignment. Samples of 250 grams per lot should be drawn and sent by Courier <span style="text-decoration: underline;"><strong>21 days prior</strong></span> to shipment to the below stated address.</p>'
			,strCompanyName							=	@strCompanyName
			,strCurrentUser							=	@strCurrentUser
			,strReportTitle							=   (case when pos.strPositionType = 'Shipment' then 'PRE-SHIPMENT SAMPLE INSTRUCTIONS' when pos.strPositionType = 'Spot' then 'SAMPLE INSTRUCTIONS' else '' end)
			,strPositionLabel						=   (case when pos.strPositionType = 'Shipment' then 'Shipment' when pos.strPositionType = 'Spot' then 'Delivery' else '' end)
			,strContractCondtionDescription			=	(select top 1 a.strConditionDescription from tblCTContractCondition a, tblCTCondition b where a.intContractHeaderId = CH.intContractHeaderId and b.intConditionId = a.intConditionId and b.strConditionName like '%_SAMPLE_INSTRUCTION')

		FROM	tblCTContractHeader				CH
		JOIN	vyuCTEntity						EY	WITH (NOLOCK)	ON	EY.intEntityId		=	CH.intEntityId	
																	AND	EY.strEntityType	=	(CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)
LEFT	JOIN	tblCTBookVsEntity				BE	WITH (NOLOCK)	ON	BE.intBookId		=	CH.intBookId AND BE.intEntityId = CH.intEntityId
LEFT	JOIN	vyuCTEntity						EV	WITH (NOLOCK)	ON	EV.intEntityId		=	BE.intEntityId        
																	AND EV.strEntityType	IN	('Vendor', 'Customer')
LEFT	JOIN	tblICCommodityUnitMeasure		CU	WITH (NOLOCK)	ON	CU.intCommodityUnitMeasureId	=	CH.intCommodityUOMId		
LEFT	JOIN	tblICUnitMeasure				UM	WITH (NOLOCK)	ON	UM.intUnitMeasureId				=	CU.intUnitMeasureId																									
LEFT	JOIN	(
					SELECT		ROW_NUMBER() OVER (PARTITION BY CD.intContractHeaderId ORDER BY CD.intContractSeq ASC) AS intRowNum, 
								CD.intContractHeaderId,
								CL.strLocationName,
								LP.strCity								AS	strLoadingPointName,
								DP.strCity								AS	strDestinationPointName,
								CD.strPackingDescription				AS strPackingDescription,
								CD.dtmStartDate,
								IM.strDescription AS strItemDescription,
								CD.strFixationBy

					FROM		tblCTContractDetail		CD  WITH (NOLOCK)
					JOIN		tblICItem				IM	WITH (NOLOCK) ON	IM.intItemId				=	CD.intItemId
					JOIN		tblSMCompanyLocation	CL	WITH (NOLOCK) ON	CL.intCompanyLocationId		=	CD.intCompanyLocationId		
					LEFT JOIN	tblSMCity				LP	WITH (NOLOCK) ON	LP.intCityId				=	CD.intLoadingPortId			
					LEFT JOIN	tblSMCity				DP	WITH (NOLOCK) ON	DP.intCityId				=	CD.intDestinationPortId	
				)										SQ	ON	SQ.intContractHeaderId		=	CH.intContractHeaderId	
														AND SQ.intRowNum = 1
left join tblCTPosition pos on pos.intPositionId = CH.intPositionId
WHERE	CH.intContractHeaderId	=	@intContractHeaderId


END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH