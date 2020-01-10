CREATE PROCEDURE uspIPFutOptTransactionProcessAckXML @intToCompanyId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intFutOptTransactionHeaderAckStageId INT
	DECLARE @strAckHeaderXML NVARCHAR(MAX)
	DECLARE @strAckFutOptTransactionXML NVARCHAR(MAX)
	DECLARE @strTransactionType NVARCHAR(MAX)
	DECLARE @intFutOptTransactionHeaderId INT
	DECLARE @intFutOptTransactionHeaderRefId INT
		,@strRowState NVARCHAR(100)
		,@intTransactionId INT
		,@intCompanyId INT
		,@intTransactionRefId INT
		,@intCompanyRefId INT

	SELECT @intFutOptTransactionHeaderAckStageId = MIN(intFutOptTransactionHeaderAckStageId)
	FROM tblRKFutOptTransactionHeaderAckStage
	WHERE strMessage = 'Success'
		AND ISNULL(strFeedStatus, '') = ''
		AND intMultiCompanyId = @intToCompanyId

	WHILE @intFutOptTransactionHeaderAckStageId > 0
	BEGIN
		SELECT @strAckHeaderXML = NULL
			,@strAckFutOptTransactionXML = NULL
			,@strTransactionType = NULL
			,@intFutOptTransactionHeaderId = NULL
			,@intFutOptTransactionHeaderRefId = NULL
			,@strRowState = NULL
			,@intTransactionId = NULL
			,@intCompanyId = NULL
			,@intTransactionRefId = NULL
			,@intCompanyRefId = NULL

		SELECT @strAckHeaderXML = strAckHeaderXML
			,@strAckFutOptTransactionXML = strAckFutOptTransactionXML
			,@strTransactionType = strTransactionType
			,@strRowState = strRowState
			,@intTransactionId = intTransactionId
			,@intCompanyId = intCompanyId
			,@intTransactionRefId = intTransactionRefId
			,@intCompanyRefId = intCompanyRefId
		FROM tblRKFutOptTransactionHeaderAckStage
		WHERE intFutOptTransactionHeaderAckStageId = @intFutOptTransactionHeaderAckStageId

		BEGIN
			IF ISNULL(@strRowState, '') = 'Delete'
			BEGIN
				SELECT @intFutOptTransactionHeaderRefId = intFutOptTransactionHeaderId
				FROM tblRKFutOptTransactionHeaderAckStage
				WHERE intFutOptTransactionHeaderAckStageId = @intFutOptTransactionHeaderAckStageId

				GOTO ext
			END

			------------------Header------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strAckHeaderXML

			SELECT @intFutOptTransactionHeaderId = intFutOptTransactionHeaderId
				,@intFutOptTransactionHeaderRefId = intFutOptTransactionHeaderRefId
			FROM OPENXML(@idoc, 'vyuIPGetFutOptTransactionHeaders/vyuIPGetFutOptTransactionHeader', 2) WITH (
					intFutOptTransactionHeaderId INT
					,intFutOptTransactionHeaderRefId INT
					)

			--UPDATE tblRKFutOptTransactionHeader
			--SET intFutOptTransactionHeaderRefId = @intFutOptTransactionHeaderId
			--WHERE intFutOptTransactionHeaderId = @intFutOptTransactionHeaderRefId
			--	AND intFutOptTransactionHeaderRefId IS NULL

			EXEC sp_xml_removedocument @idoc

			-----------------------------------Detail-------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strAckFutOptTransactionXML

			UPDATE SD
			SET SD.intFutOptTransactionRefId = XMLDetail.intFutOptTransactionId
			FROM OPENXML(@idoc, 'vyuIPGetFutOptTransactions/vyuIPGetFutOptTransaction', 2) WITH (
					intFutOptTransactionId INT
					,intFutOptTransactionRefId INT
					) XMLDetail
			JOIN tblRKFutOptTransaction SD ON SD.intFutOptTransactionId = XMLDetail.intFutOptTransactionRefId
			WHERE SD.intFutOptTransactionHeaderId = @intFutOptTransactionHeaderRefId
				AND SD.intFutOptTransactionRefId IS NULL

			EXEC sp_xml_removedocument @idoc

			ext:

			---UPDATE Feed Status in Staging
			UPDATE tblRKFutOptTransactionHeaderStage
			SET strFeedStatus = 'Ack Rcvd'
				,strMessage = 'Success'
			WHERE intFutOptTransactionHeaderId = @intFutOptTransactionHeaderRefId
				AND strFeedStatus = 'Awt Ack'

			---UPDATE Feed Status in Acknowledgement
			UPDATE tblRKFutOptTransactionHeaderAckStage
			SET strFeedStatus = 'Ack Processed'
			WHERE intFutOptTransactionHeaderAckStageId = @intFutOptTransactionHeaderAckStageId
		END

		EXECUTE dbo.uspSMInterCompanyUpdateMapping @currentTransactionId = @intTransactionId
			,@referenceTransactionId = @intTransactionRefId
			,@referenceCompanyId = @intCompanyRefId

		SELECT @intFutOptTransactionHeaderAckStageId = MIN(intFutOptTransactionHeaderAckStageId)
		FROM tblRKFutOptTransactionHeaderAckStage
		WHERE intFutOptTransactionHeaderAckStageId > @intFutOptTransactionHeaderAckStageId
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
