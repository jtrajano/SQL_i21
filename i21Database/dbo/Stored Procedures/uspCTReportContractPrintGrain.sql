CREATE PROCEDURE uspCTReportContractPrintGrain

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
			@intContractHeaderId	INT,
			@xmlDocumentId			INT 
			
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

	SELECT	@strCompanyName + ', '  + CHAR(13)+CHAR(10) +
			ISNULL(@strAddress,'') + ', ' + CHAR(13)+CHAR(10) +
			ISNULL(@strCity,'') + ISNULL(', '+@strState,'') + ISNULL(', '+@strZip,'') + ISNULL(', '+@strCountry,'')
			AS	strA,
			LTRIM(RTRIM(EY.strName)) + ', ' + CHAR(13)+CHAR(10) +
			ISNULL(LTRIM(RTRIM(EY.strAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
			ISNULL(LTRIM(RTRIM(EY.strCity)),'') + 
			ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strState)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strState)) END,'') + 
			ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strZipCode)) END,'') + 
			ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strCountry)) END,'')
			AS	strB,
			CH.dtmContractDate,
			CH.intContractNumber,
			CH.intContractHeaderId,
			EY.strNumber,
			CASE	WHEN	CH.intContractTypeId  =	1	
					THEN	'We confirm PURCHASE from you as follows :'
					WHEN	CH.intContractTypeId  =	2
					THEN	'We confirm SALES to you as follows :'
			END		AS	strConfirm,
			@strCompanyName AS	strE,
			EY.strName		AS	strF,
			CASE	WHEN	CH.intContractTypeId  =	1	
					THEN	'PURCHASE CONTRACT CONFIRMATION'
					WHEN	CH.intContractTypeId  =	2
					THEN	'SALES CONTRACT CONFIRMATION'
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
			TX.strText,
			CH.strContractBasis,
			CH.strWeight,
			CH.strGrade

	FROM	vyuCTContractHeaderView CH
	JOIN	vyuCTEntity				EY	ON	EY.intEntityId	=	CH.intEntityId	LEFT
	JOIN	tblCTContractText		TX	ON	TX.intContractTextId	=	CH.intContractTextId
	WHERE	intContractHeaderId	=	@intContractHeaderId
	
	UPDATE tblCTContractHeader SET ysnPrinted = 1 WHERE intContractHeaderId	= @intContractHeaderId

END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspCTReportContractPrintGrain - ' + ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO