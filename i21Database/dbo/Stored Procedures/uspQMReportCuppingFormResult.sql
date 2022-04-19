CREATE PROCEDURE uspQMReportCuppingFormResult
     @intSampleId INT
AS

DECLARE @ErrMsg NVARCHAR(MAX)

BEGIN TRY
	SELECT 
		 QMP.strPropertyName
		,QMTR.strPropertyValue
		,QMTR.strResult
	FROM tblQMTestResult QMTR
	INNER JOIN tblQMProductProperty QMPP ON QMPP.intPropertyId = QMTR.intPropertyId AND QMPP.ysnPrintInCuppingForm = 1 AND QMTR.intProductId = QMPP.intProductId
	INNER JOIN tblQMProperty QMP ON QMPP.intPropertyId = QMP.intPropertyId AND QMP.strPropertyName NOT IN ('Visual Aspect', 'Humidity', 'Roasting')
	INNER JOIN tblQMSample QMS ON QMTR.intSampleId = QMS.intSampleId AND QMTR.intSampleId = @intSampleId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  

END CATCH