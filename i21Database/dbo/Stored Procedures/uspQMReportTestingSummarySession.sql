CREATE PROCEDURE [dbo].[uspQMReportTestingSummarySession]
	
	@xmlParam NVARCHAR(MAX) = NULL  
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX),
					@xmlDocumentId	INT

	DECLARE @intCuppingSessionId	INT

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
	
	SELECT	@intCuppingSessionId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intCuppingSessionId'

	SELECT
		 QMCS.intCuppingSessionId
		,QMS.intSampleId
		,QMS.strSampleNumber
		,strItem = CTCDV.strItemDescription
		,CTCDV.strItemOrigin
		,QMCS.dtmCuppingDate
		,QMCS.dtmCuppingTime
		,QMA.strContractNumberP
		,QMA.strContractNumberS
		,strVendorName = QMA.strEntityNameP
		,strCustomerName = QMA.strEntityNameS
		,strRankCuppingNumber = CAST(QMCSD.intRank AS NVARCHAR(MAX)) + ' / ' + QMCS.strCuppingSessionNumber
	FROM tblQMCuppingSession QMCS
	INNER JOIN tblQMCuppingSessionDetail QMCSD ON QMCS.intCuppingSessionId = QMCSD.intCuppingSessionId AND QMCS.intCuppingSessionId = @intCuppingSessionId
	INNER JOIN tblQMSample QMS ON QMCSD.intSampleId = QMS.intSampleId
	INNER JOIN tblQMSampleType QMST ON QMS.intSampleTypeId = QMST.intSampleTypeId
	LEFT JOIN vyuQMAllocation QMA ON QMS.intSampleId = QMA.intSampleId 
	LEFT JOIN vyuCTContractDetailView CTCDV WITH (NOLOCK) ON QMS.intContractDetailId = CTCDV.intContractDetailId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH