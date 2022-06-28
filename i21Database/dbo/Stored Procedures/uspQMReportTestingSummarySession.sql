CREATE PROCEDURE [dbo].[uspQMReportTestingSummarySession]
	@xmlParam NVARCHAR(MAX) = NULL
AS

BEGIN TRY
	
	DECLARE @ErrMsg			NVARCHAR(MAX),
			@xmlDocumentId	INT

	DECLARE @CuppingSessionDetailId		Id,
			@strPrintType				NVARCHAR(MAX),
			@strCuppingSessionDetailId	NVARCHAR(MAX)

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
	
	INSERT INTO @CuppingSessionDetailId
	SELECT	[from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intCuppingSessionDetailId'

	SELECT	@strPrintType = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'strPrintType'

	select @strCuppingSessionDetailId = COALESCE(@strCuppingSessionDetailId + ',', '') + CAST(intId AS NVARCHAR(MAX))
	from @CuppingSessionDetailId

	SELECT
		 strPrintType					= @strPrintType
		,strCuppingSessionDetailId		= RTRIM(LTRIM(@strCuppingSessionDetailId))
		,QMCS.intCuppingSessionId
		,strSampleNumber				= ISNULL(QMSP.strSampleNumber, QMS.strSampleNumber)
		,strChildSampleNumber			= QMS.strSampleNumber
		,ICI.strItemNo
		,strOrigin = ICCAO.strDescription
		,QMCS.dtmCuppingDate
		,QMCS.dtmCuppingTime
		,strPContractNumber				= CTC.strContractNumber + ' / ' + CAST(CTC.intContractSeq AS NVARCHAR(MAX))
		,strVendorName					= EME.strName
		,QMCSD.intRank
		,QMCS.strCuppingSessionNumber
		,strProductType					= ICCAPT.strDescription
		,strBuyer						= CASE WHEN LGACC.intCount > 1 THEN 'Multiple' ELSE LGAC.strBuyer END
		,strSContractNumber				= CASE WHEN LGACC.intCount > 1 THEN 'Multiple' ELSE LGAC.strSContractNumber END
		,strProductLine					= ICCPL.strDescription
	FROM tblQMCuppingSession QMCS
	INNER JOIN tblQMCuppingSessionDetail QMCSD ON QMCS.intCuppingSessionId = QMCSD.intCuppingSessionId AND QMCSD.intCuppingSessionDetailId IN (SELECT intId FROM @CuppingSessionDetailId)
	INNER JOIN tblQMSample QMS ON QMCSD.intCuppingSessionDetailId = QMS.intCuppingSessionDetailId
	INNER JOIN tblICItem ICI WITH (NOLOCK) ON QMS.intItemId = ICI.intItemId
	LEFT JOIN tblQMSample QMSP ON QMS.intParentSampleId = QMSP.intSampleId
	LEFT JOIN (
		SELECT 
			 intContractDetailId
			,CTCH.strContractNumber
			,CTCD.intContractSeq
		FROM tblCTContractDetail CTCD 
		LEFT JOIN tblCTContractHeader CTCH ON CTCD.intContractHeaderId = CTCH.intContractHeaderId
	) CTC ON QMS.intContractDetailId = CTC.intContractDetailId
	LEFT JOIN tblICCommodityAttribute ICCAO	ON	ICCAO.intCommodityAttributeId =	ICI.intOriginId
	LEFT JOIN tblICCommodityProductLine ICCPL ON ICI.intProductLineId = ICCPL.intCommodityProductLineId
	LEFT JOIN tblICCommodityAttribute ICCAPT ON ICI.intProductTypeId = ICCAPT.intCommodityAttributeId AND ICCAPT.strType = 'ProductType'
	LEFT JOIN tblEMEntity EME ON QMS.intEntityId = EME.intEntityId
	OUTER APPLY (
		SELECT TOP 1 
			 intPContractDetailId
			,strBuyer
			,strSContractNumber = strSalesContractNumber + ' / ' + CAST(intSContractSeq AS NVARCHAR(MAX))
		FROM vyuLGAllocatedContracts
		WHERE intPContractDetailId = QMS.intContractDetailId
	) LGAC
	OUTER APPLY (
		SELECT intCount = COUNT(intAllocationDetailId)
		FROM tblLGAllocationDetail
		WHERE intPContractDetailId = QMS.intContractDetailId
	) LGACC

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH