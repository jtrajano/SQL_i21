
Create PROCEDURE [dbo].[uspCTReportContractPrintAgSource]
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

	SELECT	--@strCompanyName + CHAR(13)+CHAR(10) +
			ISNULL(@strAddress,'') + CHAR(13)+CHAR(10) +
			ISNULL(@strCity,'') +ISNULL(', '+@strState,'') + ISNULL('  '+@strZip,'') + CHAR(13)+CHAR(10) +  
			ISNULL(@strCountry,'')
			AS	strA,
			--LTRIM(RTRIM(CH.strEntityName))+ CHAR(13)+CHAR(10) +
			ISNULL(LTRIM(RTRIM(CH.strEntityAddress)),'')+ CHAR(13)+CHAR(10) +
			ISNULL(LTRIM(RTRIM(CH.strEntityCity)),'') + 
			ISNULL(', '+CASE WHEN LTRIM(RTRIM(CH.strEntityState)) = '' THEN NULL ELSE LTRIM(RTRIM(CH.strEntityState)) END,'') + 
			ISNULL('  '+CASE WHEN LTRIM(RTRIM(CH.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(CH.strEntityZipCode)) END,'') + CHAR(13)+CHAR(10) + 
			ISNULL(CASE WHEN LTRIM(RTRIM(CH.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(CH.strEntityCountry)) END,'')
			AS	strB,
			LTRIM(RTRIM(CH.strEntityName)) AS strCustomerName,
			@strCompanyName AS strCompanyName,
			ISNULL(@strAddress,'') AS strCompanyAddress,
			ISNULL(@strCity, '') AS strCompanyCity,
			ISNULL(@strState, '') AS strCompanyState,
			ISNULL(@strZip, '') AS strCompanyZipCode,
			ISNULL(@strCountry, '') AS strCompanyCountry,
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
			ISNULL((SELECT TOP 1 Sig.blbFile FROM tblSMUpload Sig  WITH (NOLOCK) WHERE Sig.intAttachmentId=CH.intAttachmentSignatureId), CAST('' as VarBinary)) SalespersonSignature,
			ISNULL(TX.strText,'') strText ,
			ISNULL(CH.strContractBasis,'') +
			ISNULL(', '+CASE WHEN LTRIM(RTRIM(CH.strINCOLocation)) = '' THEN NULL ELSE LTRIM(RTRIM(CH.strINCOLocation)) END,'') + 
			ISNULL(', '+CASE WHEN LTRIM(RTRIM(CH.strCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(CH.strCountry)) END,'') strContractBasis ,
			ISNULL(CH.strWeight,'') strWeight,
			ISNULL(CH.strGrade, '') strGrade,
			ISNULL(dbo.fnSMGetCompanyLogo('Header'), CAST('' as Varbinary)) AS blbHeaderLogo,
			'Remarks : '+ strRemark as strPrintableRemarks,
			CH.strTerm
		   ,lblCustomerContract					=	CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor Ref' ELSE 'Customer Ref' END
		   ,strCustomerContract					=   ISNULL(CH.strCustomerContract,'')
		   ,ISNULL(CH.strFreightTerm,'') strFreightTerm
		   ,CH.strSalesperson
	FROM	vyuCTContractHeaderView CH
	LEFT
	JOIN	tblCTContractText		TX	ON	TX.intContractTextId	=	CH.intContractTextId
	OUTER APPLY (
		SELECT TOP 1 strRemark from tblCTContractDetail where intContractHeaderId  IN (SELECT Item FROM dbo.fnSplitString(@intContractHeaderId,','))
	)remarks
	WHERE	intContractHeaderId	IN (SELECT Item FROM dbo.fnSplitString(@intContractHeaderId,','))
	
	UPDATE tblCTContractHeader SET ysnPrinted = 1 WHERE intContractHeaderId	IN (SELECT Item FROM dbo.fnSplitString(@intContractHeaderId,','))

END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspCTReportContractPrintAgSource - ' + ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH