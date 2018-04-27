CREATE PROCEDURE [dbo].[uspCTContractProcessAckXML]
	@param1 int = 0,
	@param2 int
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc								INT
	DECLARE @ErrMsg								NVARCHAR(MAX)
	DECLARE @intContractAcknowledgementStageId	INT
	DECLARE @strHeaderCondition					NVARCHAR(MAX)
	DECLARE @strCostCondition					NVARCHAR(MAX)
	DECLARE @strContractDetailAllId				NVARCHAR(MAX)
	DECLARE @strAckHeaderXML					NVARCHAR(MAX)
	DECLARE @strAckDetailXML					NVARCHAR(MAX)
	DECLARE @strAckCostXML						NVARCHAR(MAX)
	DECLARE @strAckDocumentXML					NVARCHAR(MAX)
	DECLARE @strContractNumber					NVARCHAR(MAX)
	DECLARE @strTransactionType					NVARCHAR(MAX)
	DECLARE @intContractHeaderId				INT
	DECLARE @intContractHeaderRefId				INT

	

	SELECT @intContractAcknowledgementStageId = MIN(intContractAcknowledgementStageId)
	FROM tblCTContractAcknowledgementStage
	WHERE strMessage = 'Success'
		AND ISNULL(strFeedStatus, '') = ''

	WHILE @intContractAcknowledgementStageId > 0
	BEGIN
		SET @strAckHeaderXML	 = NULL
		SET @strAckDetailXML	 = NULL
		SET @strAckCostXML		 = NULL
		SET @strAckDocumentXML   = NULL
		SET @strTransactionType  = NULL

		SELECT @strAckHeaderXML  = strAckHeaderXML
			,@strAckDetailXML	 = strAckDetailXML
			,@strAckCostXML		 = strAckCostXML
			,@strAckDocumentXML  = strAckDocumentXML
			,@strTransactionType = strTransactionType
		FROM tblCTContractAcknowledgementStage
		WHERE intContractAcknowledgementStageId = @intContractAcknowledgementStageId

		IF @strTransactionType = 'Sales Contract'
		BEGIN
			
			------------------Header------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strAckHeaderXML

			SELECT @intContractHeaderId  = intContractHeaderId
				,@intContractHeaderRefId = intContractHeaderRefId
				,@strContractNumber		 = strContractNumber
			FROM OPENXML(@idoc, 'tblCTContractHeaders/tblCTContractHeader', 2) WITH 
			(
					 intContractHeaderId INT
					,intContractHeaderRefId INT
					,strContractNumber	NvarChar(100)
			)

			UPDATE tblCTContractHeader
			SET  intContractHeaderRefId = @intContractHeaderId 
				,strCustomerContract    = @strContractNumber
			WHERE intContractHeaderId   = @intContractHeaderRefId
				AND intContractHeaderRefId IS NULL

			-----------------------------------Detail-------------------------------------------
			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strAckDetailXML

			UPDATE CD
			SET CD.intContractDetailRefId = XMLDetail.intContractDetailId
			FROM OPENXML(@idoc, 'tblCTContractDetails/tblCTContractDetail', 2) WITH 
			(
					 intContractDetailId INT
					,intContractDetailRefId INT
			) XMLDetail
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = XMLDetail.intContractDetailRefId
			WHERE CD.intContractHeaderId = @intContractHeaderRefId
				AND CD.intContractDetailRefId IS NULL

			-----------------------------------------Cost-------------------------------------------
			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strAckCostXML

			UPDATE tblCTContractCost
			SET tblCTContractCost.intContractCostRefId = XMLCost.intContractCostId
			FROM OPENXML(@idoc, 'tblCTContractCosts/tblCTContractCost', 2) WITH 
			(
					 intContractCostId INT
					,intContractCostRefId INT
					,intContractDetailId INT
			) XMLCost
			JOIN tblCTContractCost ContractCost ON ContractCost.intContractCostId = XMLCost.intContractCostRefId
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = ContractCost.intContractDetailId
								       AND CD.intContractDetailRefId = XMLCost.intContractDetailId
			WHERE ContractCost.intContractCostRefId IS NULL

			------------------------------------------------------------Document-----------------------------------------------------
			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strAckDocumentXML

			UPDATE ContractDocument
			SET ContractDocument.intContractDocumentRefId = XMLDocument.intContractDocumentId
			FROM OPENXML(@idoc, 'tblCTContractDocuments/tblCTContractDocument', 2) WITH 
			(
					 intContractDocumentId INT
					,intContractDocumentRefId INT
			) XMLDocument
			JOIN tblCTContractDocument ContractDocument ON ContractDocument.intContractDocumentId = XMLDocument.intContractDocumentRefId
			WHERE ContractDocument.intContractHeaderId = @intContractHeaderRefId
				AND ContractDocument.intContractDocumentRefId IS NULL

			---UPDATE Feed Status in Staging
			UPDATE tblCTIntrCompContract
			SET strFeedStatus = 'Ack Rcvd'
				,strMessage = 'Success'
			WHERE intContractHeaderId = @intContractHeaderRefId AND strFeedStatus = 'Awt Ack'

			---UPDATE Feed Status in Acknowledgement
			UPDATE tblCTContractAcknowledgementStage
			SET strFeedStatus = 'Ack Processed'
			WHERE intContractAcknowledgementStageId = intContractAcknowledgementStageId
		END

		SELECT @intContractAcknowledgementStageId = MIN(intContractAcknowledgementStageId)
		FROM tblCTContractAcknowledgementStage
		WHERE intContractAcknowledgementStageId > intContractAcknowledgementStageId
			AND strMessage = 'Success'
			AND ISNULL(strFeedStatus, '') = ''
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
