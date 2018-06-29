CREATE PROCEDURE [dbo].[uspCTSubagentStatement]

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
			 @blbFile				VARBINARY(MAX)
			
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
    
	SELECT	@intBrkgCommnId =	  [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname]	   =	  'intBrkgCommnId' 

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
			ISNULL(', '+CASE WHEN LTRIM(RTRIM(CH.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(CH.strEntityCountry)) END,'')
	FROM	vyuCTEntity CH
	WHERE	intEntityId =   @intVendorId

	SELECT	@strCity    =   CASE WHEN LTRIM(RTRIM(strCity)) = '' THEN NULL ELSE LTRIM(RTRIM(strCity)) END
	FROM	tblSMCompanySetup

	SELECT	@blbFile    AS  blbFile,
			@strAddress AS  strAddress,
			@strCity + ', ' + CONVERT(NVARCHAR(15),GETDATE(),106) AS strCity,
			'Estratto conto commissioni al:' + CONVERT(NVARCHAR,dtmDueDate,103)  strEstratto,
			strContractNumber,
			strSellerRef,
			strSeller,
			strBuyer,
			dbo.fnRemoveTrailingZeroes(BD.dblQuantity) + ' (' + BD.strItemUOM + ')' AS strQuantity,
			dbo.fnRemoveTrailingZeroes(BD.dblRate) + ' ' + BD.strCurrency + '/' + strRateUOM AS strRate,
			strItemNo,
			strCurrency,
			dblReqstdAmount

	FROM	  vyuCTGridBrokerageCommissionDetail  BD
	WHERE  intBrkgCommnId =	  @intBrkgCommnId			


END TRY

BEGIN CATCH
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  	
	-- EXEC uspCTReportCmmerciaInvoice '<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>intBrkgCommnId</fieldname><condition>Equal To</condition><from>7</from><to /><join>And</join><begingroup /><endgroup /><datatype>Integer</datatype></filter></filters><options /></xmlparam>'
END CATCH
GO