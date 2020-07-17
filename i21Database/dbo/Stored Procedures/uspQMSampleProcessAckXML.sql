CREATE PROCEDURE [dbo].[uspQMSampleProcessAckXML] @intToCompanyId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strErrorMessage NVARCHAR(MAX)
	DECLARE @intSampleAcknowledgementStageId INT
	DECLARE @strAckHeaderXML NVARCHAR(MAX)
	DECLARE @strAckDetailXML NVARCHAR(MAX)
	DECLARE @strAckTestResultXML NVARCHAR(MAX)
	DECLARE @strSampleNumber NVARCHAR(MAX)
	DECLARE @strTransactionType NVARCHAR(MAX)
	DECLARE @intSampleId INT
	DECLARE @intSampleRefId INT
		,@strRowState NVARCHAR(100)
		,@intTransactionId INT
		,@intCompanyId INT
		,@intTransactionRefId INT
		,@intCompanyRefId INT

	SELECT @intSampleAcknowledgementStageId = MIN(intSampleAcknowledgementStageId)
	FROM tblQMSampleAcknowledgementStage WITH (NOLOCK)
	WHERE strMessage = 'Success'
		AND ISNULL(strFeedStatus, '') = ''
		AND intMultiCompanyId = @intToCompanyId

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
			,@intTransactionId = NULL
			,@intCompanyId = NULL
			,@intTransactionRefId = NULL
			,@intCompanyRefId = NULL

		SELECT @strAckHeaderXML = strAckHeaderXML
			,@strAckDetailXML = strAckDetailXML
			,@strAckTestResultXML = strAckTestResultXML
			,@strTransactionType = strTransactionType
			,@strRowState = strRowState
			,@intTransactionId = intTransactionId
			,@intCompanyId = intCompanyId
			,@intTransactionRefId = intTransactionRefId
			,@intCompanyRefId = intCompanyRefId
		FROM tblQMSampleAcknowledgementStage WITH (NOLOCK)
		WHERE intSampleAcknowledgementStageId = @intSampleAcknowledgementStageId

		BEGIN
			IF ISNULL(@strRowState, '') = 'Delete'
			BEGIN
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
				
				--SELECT @intSampleRefId = intSampleId
				--FROM tblQMSampleAcknowledgementStage
				--WHERE intSampleAcknowledgementStageId = @intSampleAcknowledgementStageId

				EXEC sp_xml_removedocument @idoc

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
			--UPDATE tblQMSampleStage
			--SET strFeedStatus = 'Ack Rcvd'
			--	,strMessage = 'Success'
			--WHERE intSampleId = @intSampleRefId
			--	AND strFeedStatus = 'Awt Ack'

			UPDATE tblQMSamplePreStage
			SET strFeedStatus = 'Ack Rcvd'
				,strMessage = 'Success'
			WHERE intSampleId = @intSampleRefId
				AND strFeedStatus = 'Awt Ack'

			---UPDATE Feed Status in Acknowledgement
			UPDATE tblQMSampleAcknowledgementStage
			SET strFeedStatus = 'Ack Processed'
			WHERE intSampleAcknowledgementStageId = @intSampleAcknowledgementStageId
		END

		IF @strRowState <> 'Delete'
		BEGIN
			IF @intTransactionId IS NULL
			BEGIN
				SELECT @strErrorMessage = 'Current Transaction Id is not available. '

				RAISERROR (
							@strErrorMessage
							,16
							,1
							)
			END
			ELSE
			BEGIN
				EXECUTE dbo.uspSMInterCompanyUpdateMapping @currentTransactionId = @intTransactionId
					,@referenceTransactionId = @intTransactionRefId
					,@referenceCompanyId = @intCompanyRefId
			END
		END

		SELECT @intSampleAcknowledgementStageId = MIN(intSampleAcknowledgementStageId)
		FROM tblQMSampleAcknowledgementStage WITH (NOLOCK)
		WHERE intSampleAcknowledgementStageId > @intSampleAcknowledgementStageId
			AND strMessage = 'Success'
			AND ISNULL(strFeedStatus, '') = ''
			AND intMultiCompanyId = @intToCompanyId
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
