CREATE PROCEDURE uspIPCoverageEntryProcessAckXML
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intCoverageEntryAckStageId INT
	DECLARE @strAckHeaderXML NVARCHAR(MAX)
	DECLARE @strAckDetailXML NVARCHAR(MAX)
	DECLARE @strTransactionType NVARCHAR(MAX)
	DECLARE @intCoverageEntryId INT
	DECLARE @intCoverageEntryRefId INT
		,@strRowState NVARCHAR(100)
		,@intTransactionId INT
		,@intCompanyId INT
		,@intTransactionRefId INT
		,@intCompanyRefId INT

	SELECT @intCoverageEntryAckStageId = MIN(intCoverageEntryAckStageId)
	FROM tblRKCoverageEntryAckStage
	WHERE strMessage = 'Success'
		AND ISNULL(strFeedStatus, '') = ''

	WHILE @intCoverageEntryAckStageId > 0
	BEGIN
		SELECT @strAckHeaderXML = NULL
			,@strAckDetailXML = NULL
			,@strTransactionType = NULL
			,@intCoverageEntryId = NULL
			,@intCoverageEntryRefId = NULL
			,@strRowState = NULL
			,@intTransactionId = NULL
			,@intCompanyId = NULL
			,@intTransactionRefId = NULL
			,@intCompanyRefId = NULL

		SELECT @strAckHeaderXML = strAckHeaderXML
			,@strAckDetailXML = strAckDetailXML
			,@strTransactionType = strTransactionType
			,@strRowState = strRowState
			,@intTransactionId = intTransactionId
			,@intCompanyId = intCompanyId
			,@intTransactionRefId = intTransactionRefId
			,@intCompanyRefId = intCompanyRefId
		FROM tblRKCoverageEntryAckStage
		WHERE intCoverageEntryAckStageId = @intCoverageEntryAckStageId

		BEGIN
			IF ISNULL(@strRowState, '') = 'Delete'
			BEGIN
				SELECT @intCoverageEntryRefId = intCoverageEntryId
				FROM tblRKCoverageEntryAckStage
				WHERE intCoverageEntryAckStageId = @intCoverageEntryAckStageId

				GOTO ext
			END

			------------------Header------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strAckHeaderXML

			SELECT @intCoverageEntryId = intCoverageEntryId
				,@intCoverageEntryRefId = intCoverageEntryRefId
			FROM OPENXML(@idoc, 'vyuIPGetCoverageEntrys/vyuIPGetCoverageEntry', 2) WITH (
					intCoverageEntryId INT
					,intCoverageEntryRefId INT
					)

			UPDATE tblRKCoverageEntry
			SET intCoverageEntryRefId = @intCoverageEntryId
			WHERE intCoverageEntryId = @intCoverageEntryRefId
				AND intCoverageEntryRefId IS NULL

			EXEC sp_xml_removedocument @idoc

			-----------------------------------Detail-------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strAckDetailXML

			UPDATE SD
			SET SD.intCoverageEntryDetailRefId = XMLDetail.intCoverageEntryDetailId
			FROM OPENXML(@idoc, 'vyuIPGetCoverageEntryDetails/vyuIPGetCoverageEntryDetail', 2) WITH (
					intCoverageEntryDetailId INT
					,intCoverageEntryDetailRefId INT
					) XMLDetail
			JOIN tblRKCoverageEntryDetail SD ON SD.intCoverageEntryDetailId = XMLDetail.intCoverageEntryDetailRefId
			WHERE SD.intCoverageEntryId = @intCoverageEntryRefId
				AND SD.intCoverageEntryDetailRefId IS NULL

			EXEC sp_xml_removedocument @idoc

			ext:

			---UPDATE Feed Status in Staging
			UPDATE tblRKCoverageEntryStage
			SET strFeedStatus = 'Ack Rcvd'
				,strMessage = 'Success'
			WHERE intCoverageEntryId = @intCoverageEntryRefId
				AND strFeedStatus = 'Awt Ack'

			---UPDATE Feed Status in Acknowledgement
			UPDATE tblRKCoverageEntryAckStage
			SET strFeedStatus = 'Ack Processed'
			WHERE intCoverageEntryAckStageId = @intCoverageEntryAckStageId
		END

		--EXECUTE dbo.uspSMInterCompanyUpdateMapping @currentTransactionId = @intTransactionId
		--	,@referenceTransactionId = @intTransactionRefId
		--	,@referenceCompanyId = @intCompanyRefId

		SELECT @intCoverageEntryAckStageId = MIN(intCoverageEntryAckStageId)
		FROM tblRKCoverageEntryAckStage
		WHERE intCoverageEntryAckStageId > @intCoverageEntryAckStageId
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
