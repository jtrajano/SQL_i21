CREATE PROCEDURE uspQMReportCuppingFormResult
     @intSampleId INT
AS

DECLARE @ErrMsg NVARCHAR(MAX)

BEGIN TRY
	SELECT 
		 QMCS.intCuppingSessionId
		,QMCS.strCuppingSessionNumber
		,QMTRNM.strPropertyName
		,QMTR.strPropertyValue
		,QMTR.strResult
	FROM tblQMCuppingSession QMCS
	INNER JOIN tblQMCuppingSessionDetail QMCSD ON QMCS.intCuppingSessionId = QMCSD.intCuppingSessionId
	INNER JOIN tblQMSample QMS ON QMCSD.intCuppingSessionDetailId = QMS.intCuppingSessionDetailId AND QMS.intParentSampleId = @intSampleId
	INNER JOIN tblQMTestResult QMTR ON QMS.intSampleId = QMTR.intSampleId
	LEFT JOIN vyuQMTestResultNotMapped QMTRNM ON QMTR.intTestResultId = QMTRNM.intTestResultId AND QMTRNM.strPropertyName NOT IN ('Visual Aspect', 'Humidity', 'Roasting')

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  

END CATCH