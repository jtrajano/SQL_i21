CREATE PROCEDURE [dbo].[uspQMReportSampleInstruction]
	
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
			@ContractDetailId		Id,
			@intLaguageId			INT,
			@intSrCurrentUserId		INT,
			@strCurrentUser			NVARCHAR(100),
			@strReportDateFormat	NVARCHAR(50)

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
    
	INSERT INTO @ContractDetailId
	SELECT	[from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intContractDetailId'
	
	SELECT	@intLaguageId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intSrLanguageId'
	
	SELECT	@intSrCurrentUserId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intSrCurrentUserId'

	SELECT	@strCurrentUser = strName FROM tblEMEntity WHERE intEntityId = @intSrCurrentUserId;
	SELECT TOP 1 @strReportDateFormat = strReportDateFormat from tblSMCompanyPreference;

	SELECT	@strCompanyName	=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) = '' THEN NULL ELSE LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) END,
			@strAddress		=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strAddress)) = '' THEN NULL ELSE LTRIM(RTRIM(tblSMCompanySetup.strAddress)) END,
			@strCounty		=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(isnull(rtrt9.strTranslation,tblSMCompanySetup.strCountry))) END,
			@strCity		=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strCity)) = '' THEN NULL ELSE LTRIM(RTRIM(tblSMCompanySetup.strCity)) END,
			@strState		=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strState)) = '' THEN NULL ELSE LTRIM(RTRIM(tblSMCompanySetup.strState)) END,
			@strZip			=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strZip)) = '' THEN NULL ELSE LTRIM(RTRIM(tblSMCompanySetup.strZip)) END,
			@strCountry		=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(isnull(rtrt9.strTranslation,tblSMCompanySetup.strCountry))) END
	FROM	tblSMCompanySetup WITH (NOLOCK)
	LEFT JOIN tblSMCountry				rtc9 WITH (NOLOCK) on lower(rtrim(ltrim(rtc9.strCountry))) = lower(rtrim(ltrim(tblSMCompanySetup.strCountry)))
	LEFT JOIN tblSMScreen				rts9 WITH (NOLOCK) on rts9.strNamespace = 'i21.view.Country'
	LEFT JOIN tblSMTransaction			rtt9 WITH (NOLOCK) on rtt9.intScreenId = rts9.intScreenId and rtt9.intRecordId = rtc9.intCountryID
	LEFT JOIN tblSMReportTranslation	rtrt9 WITH (NOLOCK) on rtrt9.intLanguageId = @intLaguageId and rtrt9.intTransactionId = rtt9.intTransactionId and rtrt9.strFieldName = 'Country'


	SELECT	 intContractHeaderId					=	CH.intContractHeaderId
			,strBuyerRefNo							=	CASE WHEN CH.intContractTypeId = 1 THEN CH.strContractNumber ELSE CH.strCustomerContract END
			,strSellerRefNo							=	CASE WHEN CH.intContractTypeId = 2 THEN CH.strContractNumber ELSE CH.strCustomerContract END
			,strContractNumber						=	CH.strContractNumber + ' / ' + CAST(CD.intContractSeq AS NVARCHAR(5))
			,strDestinationPointName				=	SQ.strDestinationPointName
			,strItemDescription						=   strItemDescription
			,strQuantity							=	dbo.fnRemoveTrailingZeroes(CD.dblQuantity) + ' ' + UM.strUnitMeasure
			--,strShipment							=	LEFT(DATENAME(MONTH, SQ.dtmEndDate), 3) + ' ' + DATENAME(YEAR, SQ.dtmEndDate) + ' ' + (case when pos.strPositionType = 'Shipment' then 'shipment' when pos.strPositionType = 'Spot' then 'delivery' else 'shipment' end) + CASE WHEN NULLIF(SQ.strFixationBy, '') IS NOT NULL THEN ' at '+ SQ.strFixationBy+'''s option' ELSE '' END
			,strShipment							=	replace(convert(varchar,SQ.dtmStartDate,103),' ','/') + ' - ' + replace(convert(varchar,SQ.dtmEndDate,103),' ','/') + ' ' + (case when pos.strPositionType = 'Shipment' then 'shipment' when pos.strPositionType = 'Spot' then 'delivery' else 'shipment' end) + CASE WHEN NULLIF(SQ.strFixationBy, '') IS NOT NULL THEN ' at '+ SQ.strFixationBy+'''s option' ELSE '' END

		    ,strEntityAddress      					=   LTRIM(RTRIM(EY.strEntityName)) + ', '    + CHAR(13)+CHAR(10) +  
										                ISNULL(LTRIM(RTRIM(EY.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +  
										                ISNULL(LTRIM(RTRIM(EY.strEntityCity)),'') +   
										                ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityState)) = ''   THEN NULL ELSE LTRIM(RTRIM(EY.strEntityState))   END,'') +   
										                ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityZipCode)) END,'')
		  
		    ,strEntityCountry      					=   CASE WHEN LTRIM(RTRIM(EY.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityCountry)) END
													  	
			,strBookEntityAddress					=  	LTRIM(RTRIM(EV.strEntityName)) + ', '				+ CHAR(13)+CHAR(10) +
													  	ISNULL(LTRIM(RTRIM(EV.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
													  	ISNULL(LTRIM(RTRIM(EV.strEntityCity)),'') + 
													  	ISNULL(', '+CASE WHEN LTRIM(RTRIM(EV.strEntityState)) = ''   THEN NULL ELSE LTRIM(RTRIM(EV.strEntityState))   END,'') + 
													  	ISNULL(', '+CASE WHEN LTRIM(RTRIM(EV.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EV.strEntityZipCode)) END,'') + 
													  	ISNULL(', '+CASE WHEN LTRIM(RTRIM(EV.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EV.strEntityCountry)) END,'')
			,strLocationWithDate					=	SQ.strLocationName+', '+ CONVERT (VARCHAR,CH.dtmContractDate,106)
			,strLocationWithOutDate					=	SQ.strLocationName+', '
			,strLocationDate						=	GETDATE()--CH.dtmContractDate
			,strReportDateFormat					=	@strReportDateFormat
			,strCustomerContract					=	CH.strCustomerContract
			,strStraussText1						=	'<p>Pls arrange for pre-shipment samples for the above mentioned consignment. Samples of 250 grams per lot should be drawn and sent by Courier <span style="text-decoration: underline;"><strong>21 days prior</strong></span> to shipment to the below stated address.</p>'
			,strCompanyName							=	@strCompanyName
			,strCurrentUser							=	@strCurrentUser
			,strReportTitle							=   (case when pos.strPositionType = 'Shipment' then 'PRE-SHIPMENT SAMPLE INSTRUCTIONS' when pos.strPositionType = 'Spot' then 'SAMPLE INSTRUCTIONS' else '' end)
			,strPositionLabel						=   (case when pos.strPositionType = 'Shipment' then 'Shipment' when pos.strPositionType = 'Spot' then 'Delivery' else '' end)
			,strContractCondtionDescription			=	(select top 1 a.strConditionDescription from tblCTContractCondition a, tblCTCondition b where a.intContractHeaderId = CH.intContractHeaderId and b.intConditionId = a.intConditionId and b.strConditionName like '%_SAMPLE_INSTRUCTION%')
			--, blbFooterLogo = dbo.fnSMGetCompanyLogo('Footer')
			,blbFooterLogo = ISNULL((SELECT TOP 1 imgLogo FROM tblSMLogoPreferenceFooter WHERE ysnAllOtherReports = 1 AND intCompanyLocationId = CD.intCompanyLocationId AND DATALENGTH(imgLogo) > 0), dbo.fnSMGetCompanyLogo('Footer'))
			,strLogoFooterType = CASE WHEN (SELECT TOP 1 1 FROM tblSMLogoPreferenceFooter WHERE ysnAllOtherReports = 1 AND intCompanyLocationId = CD.intCompanyLocationId) IS NOT NULL THEN 'Logo' ELSE 'Attachment' END
			,blbHeaderLogo = ISNULL((SELECT TOP 1 imgLogo FROM tblSMLogoPreference WHERE ysnAllOtherReports = 1 AND intCompanyLocationId = CD.intCompanyLocationId AND DATALENGTH(imgLogo) > 0), dbo.fnSMGetCompanyLogo('Header'))
			,strLogoType = CASE WHEN (SELECT TOP 1 1 FROM tblSMLogoPreference WHERE ysnAllOtherReports = 1 AND intCompanyLocationId = CD.intCompanyLocationId) IS NOT NULL THEN 'Logo' ELSE 'Attachment' END

			,strStraussEntityName = LTRIM(RTRIM(EY.strEntityName))
			,strStraussStreetAddress = ISNULL(LTRIM(RTRIM(EY.strEntityAddress)),'')
			,strStraussZipCodeAndCity = ISNULL(CASE WHEN LTRIM(RTRIM(EY.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityZipCode)) + ' ' END,'') + ISNULL(LTRIM(RTRIM(EY.strEntityCity)),'')
			/*For strStraussState, replace the value with Country if the value is null or empty - this is to eliminate the gap between City and Country if no State is define*/
			,strStraussState = ISNULL(CASE WHEN LTRIM(RTRIM(EY.strEntityState)) = ''   THEN (CASE WHEN LTRIM(RTRIM(EY.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityCountry)) END) ELSE LTRIM(RTRIM(EY.strEntityState))   END,'')
			/*For strStraussCountry, replace the value with null if the strStraussState is null or empty - this is to eliminate the gap between City and Country if no State is define*/
			,strStraussCountry = CASE WHEN LTRIM(RTRIM(EY.strEntityState)) = '' THEN null else CASE WHEN LTRIM(RTRIM(EY.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityCountry)) END end

		FROM	tblCTContractHeader				CH
		JOIN	tblCTContractDetail				CD	WITH (NOLOCK)	ON	CH.intContractHeaderId	= CD.intContractHeaderId
		JOIN	vyuCTEntity						EY	WITH (NOLOCK)	ON	EY.intEntityId			=	CH.intEntityId	
																	AND	EY.strEntityType		=	(CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)
LEFT	JOIN	tblCTBookVsEntity				BE	WITH (NOLOCK)	ON	BE.intBookId			=	CH.intBookId AND BE.intEntityId = CH.intEntityId
LEFT	JOIN	vyuCTEntity						EV	WITH (NOLOCK)	ON	EV.intEntityId			=	BE.intEntityId        
																	AND EV.strEntityType	IN	('Vendor', 'Customer')
LEFT	JOIN	tblICUnitMeasure				UM	WITH (NOLOCK)	ON	UM.intUnitMeasureId				=	CD.intUnitMeasureId
--LEFT	JOIN	tblICCommodityUnitMeasure		CU	WITH (NOLOCK)	ON	CU.intCommodityUnitMeasureId	=	CH.intCommodityUOMId
--LEFT	JOIN	tblICUnitMeasure				UM	WITH (NOLOCK)	ON	UM.intUnitMeasureId				=	CU.intUnitMeasureId
LEFT	JOIN	(
					SELECT		ROW_NUMBER() OVER (PARTITION BY CD.intContractHeaderId ORDER BY CD.intContractSeq ASC) AS intRowNum, 
								CD.intContractDetailId,
								CD.intContractHeaderId,
								CL.strLocationName,
								LP.strCity								AS	strLoadingPointName,
								DP.strCity								AS	strDestinationPointName,
								CD.strPackingDescription				AS strPackingDescription,
								CD.dtmStartDate,
								CD.dtmEndDate,
								IM.strDescription AS strItemDescription,
								CD.strFixationBy

					FROM		tblCTContractDetail		CD  WITH (NOLOCK)
					JOIN		tblICItem				IM	WITH (NOLOCK) ON	IM.intItemId				=	CD.intItemId
					JOIN		tblSMCompanyLocation	CL	WITH (NOLOCK) ON	CL.intCompanyLocationId		=	CD.intCompanyLocationId		
					LEFT JOIN	tblSMCity				LP	WITH (NOLOCK) ON	LP.intCityId				=	CD.intLoadingPortId			
					LEFT JOIN	tblSMCity				DP	WITH (NOLOCK) ON	DP.intCityId				=	CD.intDestinationPortId	
				)										SQ	ON	SQ.intContractDetailId		=	CD.intContractDetailId
														--AND SQ.intRowNum = 1
LEFT	JOIN tblCTPosition pos on pos.intPositionId = CH.intPositionId
WHERE	CD.intContractDetailId IN (SELECT intId FROM @ContractDetailId)


END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH