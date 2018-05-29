CREATE PROCEDURE [dbo].[uspCTProvisionalCommission]
  @xmlParam NVARCHAR(MAX) = NULL  
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	DECLARE	 @intBrkgCommnId		INT,
			 @xmlDocumentId			INT,
			 @intContractDetailId	INT,
			 @dblRcvdPaidAmount		NUMERIC(18,6),
			 @strInvoiceNumber		NVARCHAR(50),
			 @strCurrency			NVARCHAR(50),
			 @strCity				NVARCHAR(50),
			 @strAddress			NVARCHAR(MAX),
			 @intVendorId			INT,
			 @blbFile				VARBINARY(MAX),
			@intLaguageId			INT,
			@strExpressionLabelName	NVARCHAR(50) = 'Expression',
			@strMonthLabelName		NVARCHAR(50) = 'Month'
			
    IF  LTRIM(RTRIM(@xmlParam)) = ''   
	   SET @xmlParam = NULL   
      
	DECLARE @temp_xml_table TABLE 
	(  
			[fieldname]		NVARCHAR(50),  
			condition		VARCHAR(20),        
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
	WITH 
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
    
	SELECT	@intBrkgCommnId =	  [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname]	   =	  'intBrkgCommnId' 
    
	SELECT	@intLaguageId =	  [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname]	   =	  'intSrLanguageId' 

	SELECT	@blbFile		=	  B.blbFile 
	FROM	tblSMAttachment	A 
	JOIN	tblSMUpload		B ON A.intAttachmentId = B.intAttachmentId
	WHERE	A.strScreen		=	 'SystemManager.CompanyPreference'
	AND		A.strComment	=	 'Header'
	
	SELECT	@intVendorId	   =	    intVendorId
	FROM	vyuCTGridBrokerageCommissionDetail
	WHERE	intBrkgCommnId = @intBrkgCommnId

	SELECT	@strAddress =
			LTRIM(RTRIM(CH.strEntityName)) + ', ' + CHAR(13)+CHAR(10) +
			ISNULL(LTRIM(RTRIM(CH.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
			ISNULL(LTRIM(RTRIM(CH.strEntityCity)),'') + 
			ISNULL(', '+CASE WHEN LTRIM(RTRIM(CH.strEntityState)) = '' THEN NULL ELSE LTRIM(RTRIM(CH.strEntityState)) END,'') + 
			ISNULL(', '+CASE WHEN LTRIM(RTRIM(CH.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(CH.strEntityZipCode)) END,'') + 
			ISNULL(', '+CASE WHEN LTRIM(RTRIM(CH.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(isnull(rtrt9.strTranslation,CH.strEntityCountry))) END,'')
	FROM	vyuCTEntity CH
	left join tblSMCountry				rtc9 on lower(rtrim(ltrim(rtc9.strCountry))) = lower(rtrim(ltrim(CH.strEntityCountry)))
	left join tblSMScreen				rts9 on rts9.strNamespace = 'i21.view.Country'
	left join tblSMTransaction			rtt9 on rtt9.intScreenId = rts9.intScreenId and rtt9.intRecordId = rtc9.intCountryID
	left join tblSMReportTranslation	rtrt9 on rtrt9.intLanguageId = @intLaguageId and rtrt9.intTransactionId = rtt9.intTransactionId and rtrt9.strFieldName = 'Country'

	WHERE	CH.intEntityId =   @intVendorId

	SELECT	@strCity    =   CASE WHEN LTRIM(RTRIM(strCity)) = '' THEN NULL ELSE LTRIM(RTRIM(strCity)) END
	FROM	tblSMCompanySetup

	SELECT	@blbFile    AS  blbFile,
			@strAddress AS  strAddress,
			--@strCity + ', ' + CONVERT(NVARCHAR(15),GETDATE(),106) AS strCity,
			@strCity + ', ' + FORMAT(GETDATE(), 'dd') + ' ' + isnull(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,FORMAT(getdate(), 'MMM')),FORMAT(getdate(), 'MMM')) + ' ' + FORMAT(GETDATE(), 'yyyy') AS strCity,
			ch.strContractNumber,
			strSellerRef,
			strSeller,
			dbo.fnRemoveTrailingZeroes(BD.dblQuantity) + ' (' + isnull(rtrt2.strTranslation,BD.strItemUOM) + ')' AS strQuantity,
			dbo.fnRemoveTrailingZeroes(BD.dblRate) + ' ' + BD.strCurrency + '/' + isnull(rtrt3.strTranslation,BD.strRateUOM) AS strRate,
			ISNULL(isnull(rtrt4.strTranslation,IG.strCountry),isnull(rtrt5.strTranslation,OG.strCountry))	AS	strOrigin,
			strCurrency,
			dblReqstdAmount

	FROM	vyuCTGridBrokerageCommissionDetail  BD
	JOIN	tblCTContractDetail		CD  ON	CD.intContractDetailId		=   BD.intContractDetailId			   
	JOIN	tblICItem				IM	ON	IM.intItemId				=	CD.intItemId			LEFT	
	JOIN	tblICItemContract		IC	ON	IC.intItemContractId		=	CD.intItemContractId	LEFT
	JOIN	tblSMCountry			IG	ON	IG.intCountryID				=	IC.intCountryId			LEFT
	JOIN	tblICCommodityAttribute EO	ON	EO.intCommodityAttributeId	=	IM.intOriginId			LEFT
	JOIN	tblSMCountry			OG	ON	OG.intCountryID				=	EO.intCountryID			LEFT
	JOIN	tblCTContractHeader		ch	ON ch.intContractHeaderId		=	CD.intContractHeaderId
	
	inner join tblSMScreen				rts2 on rts2.strNamespace = 'Inventory.view.ReportTranslation'
	left join tblSMTransaction			rtt2 on rtt2.intScreenId = rts2.intScreenId and rtt2.intRecordId = BD.intItemReportUOMId
	left join tblSMReportTranslation	rtrt2 on rtrt2.intLanguageId = @intLaguageId and rtrt2.intTransactionId = rtt2.intTransactionId and rtrt2.strFieldName = 'Name'
	
	inner join tblSMScreen				rts3 on rts3.strNamespace = 'Inventory.view.ReportTranslation'
	left join tblSMTransaction			rtt3 on rtt3.intScreenId = rts3.intScreenId and rtt3.intRecordId = BD.intRateUOMId
	left join tblSMReportTranslation	rtrt3 on rtrt3.intLanguageId = @intLaguageId and rtrt3.intTransactionId = rtt3.intTransactionId and rtrt2.strFieldName = 'Name'
	
	left join tblSMScreen				rts4 on rts4.strNamespace = 'i21.view.Country'
	left join tblSMTransaction			rtt4 on rtt4.intScreenId = rts4.intScreenId and rtt4.intRecordId = IG.intCountryID
	left join tblSMReportTranslation	rtrt4 on rtrt4.intLanguageId = @intLaguageId and rtrt4.intTransactionId = rtt4.intTransactionId and rtrt4.strFieldName = 'Country'
	
	left join tblSMScreen				rts5 on rts5.strNamespace = 'i21.view.Country'
	left join tblSMTransaction			rtt5 on rtt5.intScreenId = rts5.intScreenId and rtt5.intRecordId = OG.intCountryID
	left join tblSMReportTranslation	rtrt5 on rtrt5.intLanguageId = @intLaguageId and rtrt5.intTransactionId = rtt5.intTransactionId and rtrt5.strFieldName = 'Country'

	WHERE	intBrkgCommnId		=	  @intBrkgCommnId			


END TRY

BEGIN CATCH
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  	
	-- EXEC uspCTReportCmmerciaInvoice '<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>intBrkgCommnId</fieldname><condition>Equal To</condition><from>7</from><to /><join>And</join><begingroup /><endgroup /><datatype>Integer</datatype></filter></filters><options /></xmlparam>'
END CATCH
GO