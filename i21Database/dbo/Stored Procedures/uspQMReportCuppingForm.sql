CREATE PROCEDURE [dbo].[uspQMReportCuppingForm]
     @intCuppingSessionId INT
AS

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)

	SELECT
		 QMCS.intCuppingSessionId
		,QMS.intSampleId
		,CTCDV.strContractNumber
		,QMS.strSamplingMethod
		,QMS.strSampleNumber
		,strVendorName				= CTCDV.strEntityName
		,QMS.strSentBy
		,QMS.dtmSampleSentDate
		,strItem					= CTCDV.strItemDescription
		,strCommodity				= CTCDV.strCommodityDescription
		,QMS.strLotNumber
		,QMS.strSendSampleTo
		,strRankCuppingNumber		= QMCS.strCuppingSessionNumber
		,QMCS.dtmCuppingDate
		,QMCS.dtmCuppingTime
		,QMCSD.intRank
		,CTCDV.intContractSeq
		,CTCDV.strItemOrigin
		,QMS.dtmSampleReceivedDate
		,strExtension				= ICCA1.strAttribute1
		,strVisualAspect			= VISUAL_ASPECT.strPropertyValue
		,strHumidity				= HUMIDITY.strPropertyValue
		,strRoasting				= ROASTING.strPropertyValue
		,QMST.strSampleTypeName
		,strProductType				= ICCA.strDescription
		,strShipmentPeriod			= FORMAT(CTCDV.dtmStartDate, 'dd.MM.yyyy') + ' - ' + FORMAT(CTCDV.dtmEndDate, 'dd.MM.yyyy')
		,LGL.strLoadNumber
	FROM tblQMCuppingSession QMCS
	INNER JOIN tblQMCuppingSessionDetail QMCSD ON QMCS.intCuppingSessionId = QMCSD.intCuppingSessionId AND QMCS.intCuppingSessionId = @intCuppingSessionId
	INNER JOIN tblQMSample QMS ON QMCSD.intSampleId = QMS.intSampleId
	INNER JOIN tblQMSampleType QMST ON QMS.intSampleTypeId = QMST.intSampleTypeId
	LEFT JOIN vyuCTContractDetailView CTCDV WITH (NOLOCK) ON QMS.intContractDetailId = CTCDV.intContractDetailId
	LEFT JOIN tblICItem ICI WITH (NOLOCK) ON CTCDV.intItemId = ICI.intItemId
	LEFT JOIN tblICCommodityAttribute1 ICCA1 WITH (NOLOCK) ON ICI.intCommodityAttributeId1 = ICCA1.intCommodityAttributeId1
	LEFT JOIN tblICCommodityAttribute ICCA ON QMS.intProductTypeId = ICCA.intCommodityAttributeId AND ICCA.strType = 'ProductType'
	LEFT JOIN tblLGLoad LGL ON QMS.intLoadId = LGL.intLoadId
	OUTER APPLY (
		SELECT TOP 1 strPropertyValue
		FROM tblQMTestResult QMTR
		INNER JOIN tblQMProductProperty QMPP ON QMPP.intPropertyId = QMTR.intPropertyId AND QMPP.ysnPrintInCuppingForm = 1 AND QMTR.intProductId = QMPP.intProductId
		INNER JOIN tblQMProperty QMP ON QMPP.intPropertyId = QMP.intPropertyId AND QMP.strPropertyName = 'Visual Aspect'
		INNER JOIN tblQMSample QMSR ON QMTR.intSampleId = QMSR.intSampleId AND QMTR.intSampleId = QMS.intSampleId
	) VISUAL_ASPECT
	OUTER APPLY (
		SELECT TOP 1 strPropertyValue
		FROM tblQMTestResult QMTR
		INNER JOIN tblQMProductProperty QMPP ON QMPP.intPropertyId = QMTR.intPropertyId AND QMPP.ysnPrintInCuppingForm = 1 AND QMTR.intProductId = QMPP.intProductId
		INNER JOIN tblQMProperty QMP ON QMPP.intPropertyId = QMP.intPropertyId AND QMP.strPropertyName = 'Humidity'
		INNER JOIN tblQMSample QMSR ON QMTR.intSampleId = QMSR.intSampleId AND QMTR.intSampleId = QMS.intSampleId
	) HUMIDITY
	OUTER APPLY (
		SELECT TOP 1 strPropertyValue
		FROM tblQMTestResult QMTR
		INNER JOIN tblQMProductProperty QMPP ON QMPP.intPropertyId = QMTR.intPropertyId AND QMPP.ysnPrintInCuppingForm = 1 AND QMTR.intProductId = QMPP.intProductId
		INNER JOIN tblQMProperty QMP ON QMPP.intPropertyId = QMP.intPropertyId AND QMP.strPropertyName = 'Roasting'
		INNER JOIN tblQMSample QMSR ON QMTR.intSampleId = QMSR.intSampleId AND QMTR.intSampleId = QMS.intSampleId
	) ROASTING

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH