CREATE PROCEDURE [dbo].[uspQMSampleProcessAckXML]
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intSampleAcknowledgementStageId INT
	DECLARE @strAckHeaderXML NVARCHAR(MAX)
	DECLARE @strAckDetailXML NVARCHAR(MAX)
	DECLARE @strAckTestResultXML NVARCHAR(MAX)
	DECLARE @strSampleNumber NVARCHAR(MAX)
	DECLARE @strTransactionType NVARCHAR(MAX)
	DECLARE @intSampleId INT
	DECLARE @intSampleRefId INT
		,@strRowState NVARCHAR(100)

	SELECT @intSampleAcknowledgementStageId = MIN(intSampleAcknowledgementStageId)
	FROM tblQMSampleAcknowledgementStage
	WHERE strMessage = 'Success'
		AND ISNULL(strFeedStatus, '') = ''

	WHILE @intSampleAcknowledgementStageId > 0
	BEGIN
		SELECT @strAckHeaderXML = NULL
			,@strAckDetailXML = NULL
			,@strAckTestResultXML = NULL
			,@strTransactionType = NULL
			,@intSampleId = NULL
			,@intSampleRefId = NULL
			,@strSampleNumber = NULL
			,@strRowState = NULL

		SELECT @strAckHeaderXML = strAckHeaderXML
			,@strAckDetailXML = strAckDetailXML
			,@strAckTestResultXML = strAckTestResultXML
			,@strTransactionType = strTransactionType
			,@strRowState = strRowState
		FROM tblQMSampleAcknowledgementStage
		WHERE intSampleAcknowledgementStageId = @intSampleAcknowledgementStageId

		BEGIN
			IF ISNULL(@strRowState, '') = 'Delete'
			BEGIN
				SELECT @intSampleRefId = intSampleId
				FROM tblQMSampleAcknowledgementStage
				WHERE intSampleAcknowledgementStageId = @intSampleAcknowledgementStageId

				GOTO ext
			END

			------------------Header------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strAckHeaderXML

			SELECT @intSampleId = intSampleId
				,@intSampleRefId = intSampleRefId
				,@strSampleNumber = strSampleNumber
			FROM OPENXML(@idoc, 'tblQMSamples/tblQMSample', 2) WITH (
					intSampleId INT
					,intSampleRefId INT
					,strSampleNumber NVARCHAR(100)
					)

			UPDATE tblQMSample
			SET intSampleRefId = @intSampleId
				,strSampleRefNo = @strSampleNumber
			WHERE intSampleId = @intSampleRefId
				AND intSampleRefId IS NULL

			EXEC sp_xml_removedocument @idoc

			-----------------------------------Detail-------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strAckDetailXML

			UPDATE SD
			SET SD.intSampleDetailRefId = XMLDetail.intSampleDetailId
			FROM OPENXML(@idoc, 'tblQMSampleDetails/tblQMSampleDetail', 2) WITH (
					intSampleDetailId INT
					,intSampleDetailRefId INT
					) XMLDetail
			JOIN tblQMSampleDetail SD ON SD.intSampleDetailId = XMLDetail.intSampleDetailRefId
			WHERE SD.intSampleId = @intSampleRefId
				AND SD.intSampleDetailRefId IS NULL

			EXEC sp_xml_removedocument @idoc

			-----------------------------------Test Result-------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strAckTestResultXML

			UPDATE TR
			SET TR.intTestResultRefId = XMLResult.intTestResultId
			FROM OPENXML(@idoc, 'tblQMTestResults/tblQMTestResult', 2) WITH (
					intTestResultId INT
					,intTestResultRefId INT
					) XMLResult
			JOIN tblQMTestResult TR ON TR.intTestResultId = XMLResult.intTestResultRefId
			WHERE TR.intSampleId = @intSampleRefId
				AND TR.intTestResultRefId IS NULL

			EXEC sp_xml_removedocument @idoc

			ext:

			---UPDATE Feed Status in Staging
			UPDATE tblQMSampleStage
			SET strFeedStatus = 'Ack Rcvd'
				,strMessage = 'Success'
			WHERE intSampleId = @intSampleRefId
				AND strFeedStatus = 'Awt Ack'

			---UPDATE Feed Status in Acknowledgement
			UPDATE tblQMSampleAcknowledgementStage
			SET strFeedStatus = 'Ack Processed'
			WHERE intSampleAcknowledgementStageId = @intSampleAcknowledgementStageId
		END

		SELECT @intSampleAcknowledgementStageId = MIN(intSampleAcknowledgementStageId)
		FROM tblQMSampleAcknowledgementStage
		WHERE intSampleAcknowledgementStageId > @intSampleAcknowledgementStageId
			AND strMessage = 'Success'
			AND ISNULL(strFeedStatus, '') = ''
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
