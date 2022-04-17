CREATE PROCEDURE [dbo].[uspQMReportCuppingForm]
	
	@xmlParam NVARCHAR(MAX) = NULL  
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX),
			@xmlDocumentId	INT

	DECLARE @intLaguageId	INT

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
	
	SELECT	@intLaguageId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intSrLanguageId'

	SELECT
		 QMS.intSampleId
		,CTCDV.strContractNumber
		,QMS.strSamplingMethod
		,QMS.strSampleNumber
		,strVendorName = CTCDV.strEntityName
		,QMS.strSentBy
		,QMS.dtmSampleSentDate
		,strItem = CTCDV.strItemDescription
		,strCommodity = CTCDV.strCommodityDescription
		,QMS.strLotNumber
		,QMS.strSendSampleTo
		,strRankCuppingNumber = QMCS.strCuppingSessionNumber
		,QMCS.dtmCuppingDateTime
		,QMCSD.intRank
		,CTCDV.intContractSeq
		,CTCDV.strItemOrigin
		,QMCS.intCuppingSessionId
		,QMS.dtmSampleReceivedDate
	FROM tblQMSample QMS
	INNER JOIN tblQMCuppingSessionDetail QMCSD ON QMS.intCuppingSessionDetailId = QMCSD.intCuppingSessionDetailId
	INNER JOIN tblQMCuppingSession QMCS ON QMCSD.intCuppingSessionId = QMCS.intCuppingSessionId
	LEFT JOIN vyuCTContractDetailView CTCDV WITH (NOLOCK) ON QMS.intContractDetailId = CTCDV.intContractDetailId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH