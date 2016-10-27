CREATE PROCEDURE [dbo].[uspCTReportSimultaneous]
		
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
			@intPriceFixationId	INT,
			@xmlDocumentId			INT,
			@strContractDocuments	NVARCHAR(MAX)
			
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
    
	SELECT	@intPriceFixationId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intPriceFixationId' 

	SELECT	@strCompanyName	=	CASE WHEN LTRIM(RTRIM(strCompanyName)) = '' THEN NULL ELSE LTRIM(RTRIM(strCompanyName)) END,
			@strAddress		=	CASE WHEN LTRIM(RTRIM(strAddress)) = '' THEN NULL ELSE LTRIM(RTRIM(strAddress)) END,
			@strCounty		=	CASE WHEN LTRIM(RTRIM(strCounty)) = '' THEN NULL ELSE LTRIM(RTRIM(strCounty)) END,
			@strCity		=	CASE WHEN LTRIM(RTRIM(strCity)) = '' THEN NULL ELSE LTRIM(RTRIM(strCity)) END,
			@strState		=	CASE WHEN LTRIM(RTRIM(strState)) = '' THEN NULL ELSE LTRIM(RTRIM(strState)) END,
			@strZip			=	CASE WHEN LTRIM(RTRIM(strZip)) = '' THEN NULL ELSE LTRIM(RTRIM(strZip)) END,
			@strCountry		=	CASE WHEN LTRIM(RTRIM(strCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(strCountry)) END
	FROM	tblSMCompanySetup
	
	SELECT	PF.intPriceFixationId,
			CH.strCustomerContract,
			MA.strFutMarketName,
			MO.strFutureMonth,
			PF.[dblLotsFixed],
			PD.dtmFixationDate,
			CONVERT(NVARCHAR(50),dtmStartDate,106) + ' - ' + CONVERT(NVARCHAR(50),dtmEndDate,106) strPeriod,
			LTRIM(RTRIM(EY.strEntityName)) + ', ' + CHAR(13)+CHAR(10) +
				ISNULL(LTRIM(RTRIM(EY.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
				ISNULL(LTRIM(RTRIM(EY.strEntityCity)),'') + 
				ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityState)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityState)) END,'') + 
				ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityZipCode)) END,'') + 
				ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityCountry)) END,'')
			AS	strOtherPartyAddress,
			PD.strNotes,
			CASE WHEN CH.intContractTypeId = 1 THEN @strCompanyName ELSE EY.strEntityName END AS strBuyer,
			CASE WHEN CH.intContractTypeId = 2 THEN @strCompanyName ELSE EY.strEntityName END AS strSeller,
			dbo.fnSMGetCompanyLogo('Header') AS blbHeaderLogo
	
	FROM	tblCTPriceFixation			PF
	JOIN	tblCTPriceFixationDetail	PD	ON	PD.intPriceFixationId			=	PF.intPriceFixationId
	JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId			=	PF.intContractHeaderId
	JOIN	(
				SELECT		ROW_NUMBER() OVER (PARTITION BY intContractHeaderId ORDER BY intContractSeq ASC) AS intRowNum, 
							intContractHeaderId,
							dtmStartDate,
							dtmEndDate
				FROM		tblCTContractDetail
			)							CD	ON	CD.intContractHeaderId	=	CH.intContractHeaderId	AND  
												CD.intRowNum			=	1		
	JOIN	vyuCTEntity					EY	ON	EY.intEntityId			=	CH.intEntityId	AND
												EY.strEntityType		=	(CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)	LEFT
	JOIN	tblRKFutureMarket			MA	ON	MA.intFutureMarketId	=	PD.intFutureMarketId	
	JOIN	tblRKFuturesMonth			MO	ON	MO.intFutureMonthId		=	PD.intFutureMonthId															
	WHERE	PF.intPriceFixationId	=	@intPriceFixationId
	

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO