
CREATE PROCEDURE uspRKInterCompanyDerivativeEntryProcessAckXML
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc								INT
	DECLARE @ErrMsg								NVARCHAR(MAX)
	DECLARE @intDerivativeEntryAcknowledgementStageId	INT
	DECLARE @strHeaderCondition					NVARCHAR(MAX)
	DECLARE @strAckHeaderXML					NVARCHAR(MAX)
	DECLARE @strAckDetailXML					NVARCHAR(MAX)
	DECLARE @strContractNumber					NVARCHAR(MAX)
	DECLARE @strTransactionType					NVARCHAR(MAX)
	DECLARE @intFutOptTransactionHeaderId		INT
	DECLARE @intFutOptTransactionHeaderRefId	INT

	

	SELECT @intDerivativeEntryAcknowledgementStageId = MIN(intDerivativeEntryAcknowledgementStageId)
	FROM tblRKInterCompanyDerivativeEntryAcknowledgementStage
	WHERE strMessage = 'Success'
		AND ISNULL(strFeedStatus, '') = ''

	WHILE @intDerivativeEntryAcknowledgementStageId > 0
	BEGIN
		SET @strAckHeaderXML	 = NULL
		SET @strAckDetailXML	 = NULL
		SET @strTransactionType  = NULL

		SELECT @strAckHeaderXML  = strAckHeaderXML
			,@strAckDetailXML	 = strAckDetailXML
			,@strTransactionType = strTransactionType
		FROM tblRKInterCompanyDerivativeEntryAcknowledgementStage
		WHERE intDerivativeEntryAcknowledgementStageId = @intDerivativeEntryAcknowledgementStageId

	
			------------------Header------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strAckHeaderXML

			SELECT @intFutOptTransactionHeaderId  = intFutOptTransactionHeaderId
				,@intFutOptTransactionHeaderRefId = intFutOptTransactionHeaderRefId
			FROM OPENXML(@idoc, 'tblRKFutOptTransactionHeaders/tblRKFutOptTransactionHeader', 2) WITH 
			(
					 intFutOptTransactionHeaderId INT
					,intFutOptTransactionHeaderRefId INT
			)

			UPDATE tblRKFutOptTransactionHeader
			SET  intFutOptTransactionHeaderRefId = @intFutOptTransactionHeaderId 
			WHERE intFutOptTransactionHeaderId   = @intFutOptTransactionHeaderRefId
				AND intFutOptTransactionHeaderRefId IS NULL

			-----------------------------------Detail-------------------------------------------
			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strAckDetailXML

			UPDATE CD
			SET CD.intFutOptTransactionRefId = XMLDetail.intFutOptTransactionId
			FROM OPENXML(@idoc, 'tblRKFutOptTransactions/tblRKFutOptTransaction', 2) WITH 
			(
					 intFutOptTransactionId INT
					,intFutOptTransactionRefId INT
			) XMLDetail
			JOIN tblRKFutOptTransaction CD ON CD.intFutOptTransactionId = XMLDetail.intFutOptTransactionRefId
			WHERE CD.intFutOptTransactionHeaderId = @intFutOptTransactionHeaderRefId
				AND CD.intFutOptTransactionRefId IS NULL

			

			---UPDATE Feed Status in Staging
			UPDATE tblRKInterCompanyDerivativeEntryStage
			SET strFeedStatus = 'Ack Rcvd'
				,strMessage = 'Success'
			WHERE intFutOptTransactionHeaderId = @intFutOptTransactionHeaderRefId AND strFeedStatus = 'Awt Ack'

			---UPDATE Feed Status in Acknowledgement
			UPDATE tblRKInterCompanyDerivativeEntryAcknowledgementStage
			SET strFeedStatus = 'Ack Processed'
			WHERE intDerivativeEntryAcknowledgementStageId = @intDerivativeEntryAcknowledgementStageId
		
		
		SELECT @intDerivativeEntryAcknowledgementStageId = MIN(intDerivativeEntryAcknowledgementStageId)
		FROM tblRKInterCompanyDerivativeEntryAcknowledgementStage
		WHERE intDerivativeEntryAcknowledgementStageId > intDerivativeEntryAcknowledgementStageId
			AND strMessage = 'Success'
			AND ISNULL(strFeedStatus, '') = ''

	END

		

	
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
