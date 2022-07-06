CREATE PROCEDURE uspQMReportCuppingFormResult
     @intSampleId INT
AS

DECLARE @ErrMsg NVARCHAR(MAX)

BEGIN TRY
	SELECT 
		 QMCS.intCuppingSessionId
		,QMCS.strCuppingSessionNumber
		,QMP.strPropertyName
		,QMTR.strPropertyValue
		,QMTR.strResult
	FROM tblQMCuppingSession QMCS
	INNER JOIN tblQMCuppingSessionDetail QMCSD ON QMCS.intCuppingSessionId = QMCSD.intCuppingSessionId
	INNER JOIN tblQMSample QMS ON QMCSD.intCuppingSessionDetailId = QMS.intCuppingSessionDetailId AND QMS.intParentSampleId = @intSampleId
	INNER JOIN  tblQMTestResult QMTR ON QMS.intSampleId = QMTR.intSampleId
	INNER JOIN tblQMProductProperty QMPP ON QMPP.intPropertyId = QMTR.intPropertyId AND QMPP.ysnPrintInCuppingForm = 1 AND QMTR.intProductId = QMPP.intProductId
	INNER JOIN tblQMProperty QMP ON QMPP.intPropertyId = QMP.intPropertyId AND QMP.strPropertyName NOT IN ('Visual Aspect', 'Humidity', 'Roasting')

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  

END CATCH