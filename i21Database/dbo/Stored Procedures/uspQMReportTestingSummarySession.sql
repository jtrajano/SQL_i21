CREATE PROCEDURE [dbo].[uspQMReportTestingSummarySession]
	
	@xmlParam NVARCHAR(MAX) = NULL  
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX),
			@xmlDocumentId	INT

	DECLARE @intCuppingSessionId INT
	DECLARE @strPrintType NVARCHAR(MAX)

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

	SELECT	@strPrintType = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'strPrintType'

	SELECT
		 strPrintType = @strPrintType
		,QMCS.intCuppingSessionId
		,QMS.intSampleId
		,QMS.strSampleNumber
		,strItem				= CTCDV.strItemDescription
		,CTCDV.strItemOrigin
		,QMCS.dtmCuppingDate
		,QMCS.dtmCuppingTime
		,strContractNumber = CTCDV.strContractNumber + ' / ' + CAST(CTCDV.intContractSeq AS NVARCHAR(MAX))
		,strVendorName = strEntityName
		,QMCSD.intRank
		,QMCS.strCuppingSessionNumber
		,strProductType			= ICCA.strDescription
		,strBuyer = CASE WHEN LGAC1.intCount > 1 THEN 'Multiple' ELSE LGAC.strBuyer END
		,strSContractNumber = CASE WHEN LGAC1.intCount > 1 THEN 'Multiple' ELSE LGAC.strSContractNumber END
	FROM tblQMCuppingSession QMCS
	INNER JOIN tblQMCuppingSessionDetail QMCSD ON QMCS.intCuppingSessionId = QMCSD.intCuppingSessionId AND QMCS.intCuppingSessionId = @intCuppingSessionId
	INNER JOIN tblQMSample QMS ON QMCSD.intSampleId = QMS.intSampleId
	LEFT JOIN vyuCTContractDetailView CTCDV WITH (NOLOCK) ON QMS.intContractDetailId = CTCDV.intContractDetailId
	LEFT JOIN tblICItem ICI WITH (NOLOCK) ON CTCDV.intItemId = ICI.intItemId
	LEFT JOIN tblICCommodityAttribute ICCA ON ICI.intProductTypeId = ICCA.intCommodityAttributeId AND ICCA.strType = 'ProductType'
	OUTER APPLY (
		SELECT TOP 1 intPContractDetailId, strSContractNumber, strBuyer
		FROM vyuLGAllocatedContracts
		WHERE intPContractDetailId = QMS.intContractDetailId
	) LGAC
	OUTER APPLY (
		SELECT intCount = COUNT(intAllocationDetailId)
		FROM vyuLGAllocatedContracts
		WHERE intPContractDetailId = QMS.intContractDetailId
	) LGAC1

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH