CREATE PROCEDURE [dbo].[uspQMReportCuppingForm]
     @strCuppingSessionDetailId NVARCHAR(MAX) = NULL
AS

BEGIN TRY
	DECLARE @ErrMsg			NVARCHAR(MAX),
			@xmlDocumentId	INT

	SELECT
		 QMCS.intCuppingSessionId
		,QMS.intSampleId
		,intContractDetailId			= ISNULL(CTC.intContractDetailId, 0)
		,strContractNumberSequence		= CTC.strContractNumber + '/' + CAST(CTC.intContractSeq AS NVARCHAR(MAX))
		,strSampleNumber				= ISNULL(QMSP.strSampleNumber, QMS.strSampleNumber)
		,strChildSampleNumber			= QMS.strSampleNumber
		,strVendorName					= EME.strName
		,QMS.strSentBy
		,dtmSampleSentDate				= CASE WHEN CAST(QMS.dtmSampleSentDate AS DATE) IN ('12/30/1899', '1900-01-01') THEN NULL ELSE QMS.dtmSampleSentDate END
		,ICI.strItemNo
		,strCommodity					= ICC.strDescription
		,QMS.strRepresentLotNumber
		,QMS.strSendSampleTo
		,QMCS.strCuppingSessionNumber
		,QMCS.dtmCuppingDate
		,QMCS.dtmCuppingTime
		,QMCSD.intRank
		,strOrigin						= ICCAO.strDescription
		,dtmSampleReceivedDate			= CASE WHEN CAST(QMS.dtmSampleReceivedDate AS DATE) IN ('12/30/1899', '1900-01-01') THEN NULL ELSE QMS.dtmSampleReceivedDate END
		,strExtension					= ICCPL.strDescription
		,strVisualAspect				= VISUAL_ASPECT.strPropertyValue
		,strHumidity					= HUMIDITY.strPropertyValue
		,strRoasting					= ROASTING.strPropertyValue
		,QMST.strSampleTypeName
		,strProductType					= ICCAPT.strDescription
		,strShipmentPeriod				= CONVERT(VARCHAR(10), CTC.dtmStartDate, 104) + ' - ' + CONVERT(VARCHAR(10), CTC.dtmEndDate, 104)
		,QMS.strCourier
		,QMS.strCourierRef
		,QMSC.strSamplingCriteria
	FROM tblQMCuppingSession QMCS
	INNER JOIN tblQMCuppingSessionDetail QMCSD ON QMCS.intCuppingSessionId = QMCSD.intCuppingSessionId AND QMCSD.intCuppingSessionDetailId IN (SELECT [intID] AS intTransactionId FROM [dbo].fnGetRowsFromDelimitedValues(@strCuppingSessionDetailId))
	INNER JOIN tblQMSample QMS ON QMCSD.intSampleId = QMS.intSampleId
	INNER JOIN tblQMSampleType QMST ON QMS.intSampleTypeId = QMST.intSampleTypeId
	LEFT JOIN tblQMSample QMSP ON QMS.intParentSampleId = QMSP.intSampleId
	LEFT JOIN tblQMSamplingCriteria QMSC WITH (NOLOCK) ON QMS.intSamplingCriteriaId = QMSC.intSamplingCriteriaId
	LEFT JOIN (
		SELECT 
			 intContractDetailId
			,CTCH.strContractNumber
			,CTCD.intContractSeq
			,CTCD.dtmStartDate
			,CTCD.dtmEndDate
			,CTCH.intCommodityId
		FROM tblCTContractDetail CTCD 
		LEFT JOIN tblCTContractHeader CTCH ON CTCD.intContractHeaderId = CTCH.intContractHeaderId
	) CTC ON QMS.intContractDetailId = CTC.intContractDetailId
	LEFT JOIN tblICItem ICI WITH (NOLOCK) ON QMS.intItemId = ICI.intItemId
	LEFT JOIN tblICCommodityAttribute ICCAO	ON	ICCAO.intCommodityAttributeId =	ICI.intOriginId
	LEFT JOIN tblICCommodity ICC ON	CTC.intCommodityId = ICC.intCommodityId
	LEFT JOIN tblICCommodityProductLine ICCPL ON ICI.intProductLineId = ICCPL.intCommodityProductLineId
	LEFT JOIN tblICCommodityAttribute ICCAPT ON ICI.intProductTypeId = ICCAPT.intCommodityAttributeId AND ICCAPT.strType = 'ProductType'
	LEFT JOIN tblEMEntity EME ON QMS.intEntityId = EME.intEntityId
	OUTER APPLY (
		SELECT TOP 1 strPropertyValue
		FROM tblQMTestResult QMTR
		INNER JOIN tblQMProductProperty QMPP ON QMPP.intPropertyId = QMTR.intPropertyId AND QMTR.intProductId = QMPP.intProductId
		INNER JOIN tblQMProperty QMP ON QMPP.intPropertyId = QMP.intPropertyId AND QMP.strPropertyName = 'Visual Aspect'
		INNER JOIN tblQMSample QMSR ON QMTR.intSampleId = QMSR.intSampleId AND QMTR.intSampleId = QMS.intSampleId
	) VISUAL_ASPECT
	OUTER APPLY (
		SELECT TOP 1 strPropertyValue
		FROM tblQMTestResult QMTR
		INNER JOIN tblQMProductProperty QMPP ON QMPP.intPropertyId = QMTR.intPropertyId AND QMTR.intProductId = QMPP.intProductId
		INNER JOIN tblQMProperty QMP ON QMPP.intPropertyId = QMP.intPropertyId AND QMP.strPropertyName = 'Humidity'
		INNER JOIN tblQMSample QMSR ON QMTR.intSampleId = QMSR.intSampleId AND QMTR.intSampleId = QMS.intSampleId
	) HUMIDITY
	OUTER APPLY (
		SELECT TOP 1 strPropertyValue
		FROM tblQMTestResult QMTR
		INNER JOIN tblQMProductProperty QMPP ON QMPP.intPropertyId = QMTR.intPropertyId AND QMTR.intProductId = QMPP.intProductId
		INNER JOIN tblQMProperty QMP ON QMPP.intPropertyId = QMP.intPropertyId AND QMP.strPropertyName = 'Roasting'
		INNER JOIN tblQMSample QMSR ON QMTR.intSampleId = QMSR.intSampleId AND QMTR.intSampleId = QMS.intSampleId
	) ROASTING

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH