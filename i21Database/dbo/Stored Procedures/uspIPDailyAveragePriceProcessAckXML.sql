CREATE PROCEDURE uspIPDailyAveragePriceProcessAckXML @intToCompanyId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intDailyAveragePriceAckStageId INT
	DECLARE @strAckHeaderXML NVARCHAR(MAX)
	DECLARE @strAckDetailXML NVARCHAR(MAX)
	DECLARE @strTransactionType NVARCHAR(MAX)
	DECLARE @intDailyAveragePriceId INT
	DECLARE @intDailyAveragePriceRefId INT
		,@strRowState NVARCHAR(100)

	SELECT @intDailyAveragePriceAckStageId = MIN(intDailyAveragePriceAckStageId)
	FROM tblRKDailyAveragePriceAckStage
	WHERE strMessage = 'Success'
		AND ISNULL(strFeedStatus, '') = ''
		AND intMultiCompanyId = @intToCompanyId

	WHILE @intDailyAveragePriceAckStageId > 0
	BEGIN
		SELECT @strAckHeaderXML = NULL
			,@strAckDetailXML = NULL
			,@strTransactionType = NULL
			,@intDailyAveragePriceId = NULL
			,@intDailyAveragePriceRefId = NULL
			,@strRowState = NULL

		SELECT @strAckHeaderXML = strAckHeaderXML
			,@strAckDetailXML = strAckDetailXML
			,@strTransactionType = strTransactionType
			,@strRowState = strRowState
		FROM tblRKDailyAveragePriceAckStage
		WHERE intDailyAveragePriceAckStageId = @intDailyAveragePriceAckStageId

		BEGIN
			IF ISNULL(@strRowState, '') = 'Delete'
			BEGIN
				SELECT @intDailyAveragePriceRefId = intDailyAveragePriceId
				FROM tblRKDailyAveragePriceAckStage
				WHERE intDailyAveragePriceAckStageId = @intDailyAveragePriceAckStageId

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

			--UPDATE tblRKDailyAveragePrice
			--SET intDailyAveragePriceRefId = @intDailyAveragePriceId
			--WHERE intDailyAveragePriceId = @intDailyAveragePriceRefId
			--	AND intDailyAveragePriceRefId IS NULL

			EXEC sp_xml_removedocument @idoc

			-----------------------------------Detail-------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strAckDetailXML

			--UPDATE SD
			--SET SD.intDailyAveragePriceDetailRefId = XMLDetail.intDailyAveragePriceDetailId
			--FROM OPENXML(@idoc, 'vyuIPGetDailyAveragePriceDetails/vyuIPGetDailyAveragePriceDetail', 2) WITH (
			--		intDailyAveragePriceDetailId INT
			--		,intDailyAveragePriceDetailRefId INT
			--		) XMLDetail
			--JOIN tblRKDailyAveragePriceDetail SD ON SD.intDailyAveragePriceDetailId = XMLDetail.intDailyAveragePriceDetailRefId
			--WHERE SD.intDailyAveragePriceId = @intDailyAveragePriceRefId
			--	AND SD.intDailyAveragePriceDetailRefId IS NULL

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

		SELECT @intDailyAveragePriceAckStageId = MIN(intDailyAveragePriceAckStageId)
		FROM tblRKDailyAveragePriceAckStage
		WHERE intDailyAveragePriceAckStageId > @intDailyAveragePriceAckStageId
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
