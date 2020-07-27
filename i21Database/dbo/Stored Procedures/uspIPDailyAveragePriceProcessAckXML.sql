CREATE PROCEDURE uspIPDailyAveragePriceProcessAckXML --@intToCompanyId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strErrorMessage NVARCHAR(MAX)
	DECLARE @intDailyAveragePriceAckStageId INT
	DECLARE @strAckHeaderXML NVARCHAR(MAX)
	DECLARE @strAckDetailXML NVARCHAR(MAX)
	DECLARE @strTransactionType NVARCHAR(MAX)
	DECLARE @intDailyAveragePriceId INT
	DECLARE @intDailyAveragePriceRefId INT
		,@strRowState NVARCHAR(100)
		,@intTransactionId INT
		,@intCompanyId INT
		,@intTransactionRefId INT
		,@intCompanyRefId INT
	DECLARE @tblRKDailyAveragePriceAckStage TABLE (intDailyAveragePriceAckStageId INT)

	INSERT INTO @tblRKDailyAveragePriceAckStage (intDailyAveragePriceAckStageId)
	SELECT intDailyAveragePriceAckStageId
	FROM tblRKDailyAveragePriceAckStage
	WHERE strMessage = 'Success'
		AND ISNULL(strFeedStatus, '') = ''
		--AND intMultiCompanyId = @intToCompanyId

	SELECT @intDailyAveragePriceAckStageId = MIN(intDailyAveragePriceAckStageId)
	FROM @tblRKDailyAveragePriceAckStage

	IF @intDailyAveragePriceAckStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE t
	SET t.strFeedStatus = 'In-Progress'
	FROM tblRKDailyAveragePriceAckStage t
	JOIN @tblRKDailyAveragePriceAckStage pt ON pt.intDailyAveragePriceAckStageId = t.intDailyAveragePriceAckStageId

	WHILE @intDailyAveragePriceAckStageId > 0
	BEGIN
		SELECT @strAckHeaderXML = NULL
			,@strAckDetailXML = NULL
			,@strTransactionType = NULL
			,@intDailyAveragePriceId = NULL
			,@intDailyAveragePriceRefId = NULL
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
		FROM tblRKDailyAveragePriceAckStage WITH (NOLOCK)
		WHERE intDailyAveragePriceAckStageId = @intDailyAveragePriceAckStageId

		BEGIN
			IF ISNULL(@strRowState, '') = 'Delete'
			BEGIN
				EXEC sp_xml_preparedocument @idoc OUTPUT
					,@strAckHeaderXML

				SELECT @intDailyAveragePriceId = intDailyAveragePriceId
					,@intDailyAveragePriceRefId = intDailyAveragePriceRefId
				FROM OPENXML(@idoc, 'vyuIPGetDailyAveragePrices/vyuIPGetDailyAveragePrice', 2) WITH (
						intDailyAveragePriceId INT
						,intDailyAveragePriceRefId INT
						)
				--SELECT @intDailyAveragePriceRefId = intDailyAveragePriceId
				--FROM tblRKDailyAveragePriceAckStage
				--WHERE intDailyAveragePriceAckStageId = @intDailyAveragePriceAckStageId

				EXEC sp_xml_removedocument @idoc

				GOTO ext
			END

			------------------Header------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strAckHeaderXML

			SELECT @intDailyAveragePriceId = intDailyAveragePriceId
				,@intDailyAveragePriceRefId = intDailyAveragePriceRefId
			FROM OPENXML(@idoc, 'vyuIPGetDailyAveragePrices/vyuIPGetDailyAveragePrice', 2) WITH (
					intDailyAveragePriceId INT
					,intDailyAveragePriceRefId INT
					)

			UPDATE tblRKDailyAveragePrice
			SET intDailyAveragePriceRefId = @intDailyAveragePriceId
			WHERE intDailyAveragePriceId = @intDailyAveragePriceRefId
				AND intDailyAveragePriceRefId IS NULL

			EXEC sp_xml_removedocument @idoc

			-----------------------------------Detail-------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strAckDetailXML

			UPDATE SD
			SET SD.intDailyAveragePriceDetailRefId = XMLDetail.intDailyAveragePriceDetailId
			FROM OPENXML(@idoc, 'vyuIPGetDailyAveragePriceDetails/vyuIPGetDailyAveragePriceDetail', 2) WITH (
					intDailyAveragePriceDetailId INT
					,intDailyAveragePriceDetailRefId INT
					) XMLDetail
			JOIN tblRKDailyAveragePriceDetail SD ON SD.intDailyAveragePriceDetailId = XMLDetail.intDailyAveragePriceDetailRefId
			WHERE SD.intDailyAveragePriceId = @intDailyAveragePriceRefId
				AND SD.intDailyAveragePriceDetailRefId IS NULL

			EXEC sp_xml_removedocument @idoc

			ext:

			---UPDATE Feed Status in Staging
			UPDATE tblRKDailyAveragePriceStage
			SET strFeedStatus = 'Ack Rcvd'
				,strMessage = 'Success'
			WHERE intDailyAveragePriceId = @intDailyAveragePriceRefId
				AND strFeedStatus = 'Awt Ack'

			---UPDATE Feed Status in Acknowledgement
			UPDATE tblRKDailyAveragePriceAckStage
			SET strFeedStatus = 'Ack Processed'
			WHERE intDailyAveragePriceAckStageId = @intDailyAveragePriceAckStageId
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

		SELECT @intDailyAveragePriceAckStageId = MIN(intDailyAveragePriceAckStageId)
		FROM @tblRKDailyAveragePriceAckStage
		WHERE intDailyAveragePriceAckStageId > @intDailyAveragePriceAckStageId
			--AND strMessage = 'Success'
			--AND ISNULL(strFeedStatus, '') = ''
			--AND intMultiCompanyId = @intToCompanyId
	END

	UPDATE t
	SET t.strFeedStatus = NULL
	FROM tblRKDailyAveragePriceAckStage t
	JOIN @tblRKDailyAveragePriceAckStage pt ON pt.intDailyAveragePriceAckStageId = t.intDailyAveragePriceAckStageId
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
