CREATE PROCEDURE uspIPFutOptTransactionProcessAckXML
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strErrorMessage NVARCHAR(MAX)
	DECLARE @intFutOptTransactionHeaderAckStageId INT
	DECLARE @strAckHeaderXML NVARCHAR(MAX)
	DECLARE @strAckFutOptTransactionXML NVARCHAR(MAX)
	DECLARE @strTransactionType NVARCHAR(MAX)
	DECLARE @intFutOptTransactionHeaderId INT
	DECLARE @intFutOptTransactionHeaderRefId INT
		,@strRowState NVARCHAR(100)
		,@intMultiCompanyId INT
		,@intTransactionId INT
		,@intCompanyId INT
		,@intTransactionRefId INT
		,@intCompanyRefId INT
	DECLARE @tblRKFutOptTransactionHeaderAckStage TABLE (intFutOptTransactionHeaderAckStageId INT)

	INSERT INTO @tblRKFutOptTransactionHeaderAckStage (intFutOptTransactionHeaderAckStageId)
	SELECT intFutOptTransactionHeaderAckStageId
	FROM tblRKFutOptTransactionHeaderAckStage
	WHERE strMessage = 'Success'
		AND ISNULL(strFeedStatus, '') = ''
		--AND intMultiCompanyId = @intToCompanyId

	SELECT @intFutOptTransactionHeaderAckStageId = MIN(intFutOptTransactionHeaderAckStageId)
	FROM @tblRKFutOptTransactionHeaderAckStage

	IF @intFutOptTransactionHeaderAckStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE t
	SET t.strFeedStatus = 'In-Progress'
	FROM tblRKFutOptTransactionHeaderAckStage t
	JOIN @tblRKFutOptTransactionHeaderAckStage pt ON pt.intFutOptTransactionHeaderAckStageId = t.intFutOptTransactionHeaderAckStageId

	WHILE @intFutOptTransactionHeaderAckStageId > 0
	BEGIN
		SELECT @strAckHeaderXML = NULL
			,@strAckFutOptTransactionXML = NULL
			,@strTransactionType = NULL
			,@intFutOptTransactionHeaderId = NULL
			,@intFutOptTransactionHeaderRefId = NULL
			,@strRowState = NULL
			,@intMultiCompanyId = NULL
			,@intTransactionId = NULL
			,@intCompanyId = NULL
			,@intTransactionRefId = NULL
			,@intCompanyRefId = NULL

		SELECT @strAckHeaderXML = strAckHeaderXML
			,@strAckFutOptTransactionXML = strAckFutOptTransactionXML
			,@strTransactionType = strTransactionType
			,@strRowState = strRowState
			,@intMultiCompanyId = intMultiCompanyId
			,@intTransactionId = intTransactionId
			,@intCompanyId = intCompanyId
			,@intTransactionRefId = intTransactionRefId
			,@intCompanyRefId = intCompanyRefId
		FROM tblRKFutOptTransactionHeaderAckStage WITH (NOLOCK)
		WHERE intFutOptTransactionHeaderAckStageId = @intFutOptTransactionHeaderAckStageId

		BEGIN
			IF ISNULL(@strRowState, '') = 'Delete'
			BEGIN
				EXEC sp_xml_preparedocument @idoc OUTPUT
					,@strAckHeaderXML

				SELECT @intFutOptTransactionHeaderId = intFutOptTransactionHeaderId
					,@intFutOptTransactionHeaderRefId = intFutOptTransactionHeaderRefId
				FROM OPENXML(@idoc, 'vyuIPGetFutOptTransactionHeaders/vyuIPGetFutOptTransactionHeader', 2) WITH (
						intFutOptTransactionHeaderId INT
						,intFutOptTransactionHeaderRefId INT
						)

				--SELECT @intFutOptTransactionHeaderRefId = intFutOptTransactionHeaderId
				--FROM tblRKFutOptTransactionHeaderAckStage
				--WHERE intFutOptTransactionHeaderAckStageId = @intFutOptTransactionHeaderAckStageId

				EXEC sp_xml_removedocument @idoc

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

			--UPDATE SD
			--SET SD.intFutOptTransactionRefId = XMLDetail.intFutOptTransactionId
			--FROM OPENXML(@idoc, 'vyuIPGetFutOptTransactions/vyuIPGetFutOptTransaction', 2) WITH (
			--		intFutOptTransactionId INT
			--		,intFutOptTransactionRefId INT
			--		) XMLDetail
			--JOIN tblRKFutOptTransaction SD ON SD.intFutOptTransactionId = XMLDetail.intFutOptTransactionRefId
			--WHERE SD.intFutOptTransactionHeaderId = @intFutOptTransactionHeaderRefId
			--	AND SD.intFutOptTransactionRefId IS NULL

			EXEC sp_xml_removedocument @idoc

			ext:

			---UPDATE Feed Status in Staging
			UPDATE tblRKFutOptTransactionHeaderStage
			SET strFeedStatus = 'Ack Rcvd'
				,strMessage = 'Success'
			WHERE intFutOptTransactionHeaderId = @intFutOptTransactionHeaderRefId
				AND strFeedStatus = 'Awt Ack'
				AND intMultiCompanyId = @intMultiCompanyId

			---UPDATE Feed Status in Acknowledgement
			UPDATE tblRKFutOptTransactionHeaderAckStage
			SET strFeedStatus = 'Ack Processed'
			WHERE intFutOptTransactionHeaderAckStageId = @intFutOptTransactionHeaderAckStageId
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

		SELECT @intFutOptTransactionHeaderAckStageId = MIN(intFutOptTransactionHeaderAckStageId)
		FROM @tblRKFutOptTransactionHeaderAckStage
		WHERE intFutOptTransactionHeaderAckStageId > @intFutOptTransactionHeaderAckStageId
			--AND strMessage = 'Success'
			--AND ISNULL(strFeedStatus, '') = ''
			--AND intMultiCompanyId = @intToCompanyId
	END

	UPDATE t
	SET t.strFeedStatus = NULL
	FROM tblRKFutOptTransactionHeaderAckStage t
	JOIN @tblRKFutOptTransactionHeaderAckStage pt ON pt.intFutOptTransactionHeaderAckStageId = t.intFutOptTransactionHeaderAckStageId
		AND t.strFeedStatus = 'In-Progress'
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
