CREATE PROCEDURE [dbo].[uspCTContractProcessAckXML]
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intContractAcknowledgementStageId INT
	DECLARE @strHeaderCondition NVARCHAR(MAX)
	DECLARE @strCostCondition NVARCHAR(MAX)
	DECLARE @strContractDetailAllId NVARCHAR(MAX)
	DECLARE @strAckHeaderXML NVARCHAR(MAX)
	DECLARE @strAckDetailXML NVARCHAR(MAX)
	DECLARE @strAckCostXML NVARCHAR(MAX)
	DECLARE @strAckDocumentXML NVARCHAR(MAX)
	DECLARE @strContractNumber NVARCHAR(MAX)
	DECLARE @strTransactionType NVARCHAR(MAX)
	DECLARE @strBookStatus NVARCHAR(MAX)
	DECLARE @intContractHeaderId INT
	DECLARE @intContractHeaderRefId INT
	DECLARE @intToCompanyId INT
	DECLARE @intToEntityId INT
	DECLARE @intCompanyLocationId INT
	DECLARE @strInsert NVARCHAR(100)
	DECLARE @strUpdate NVARCHAR(100)
	DECLARE @strToTransactionType NVARCHAR(100)
		,@intTransactionId INT
		,@intCompanyId INT
		,@intTransactionRefId INT
		,@intCompanyRefId INT
	DECLARE @tblCTContractAcknowledgementStage TABLE (intContractAcknowledgementStageId INT)

	INSERT INTO @tblCTContractAcknowledgementStage
	SELECT intContractAcknowledgementStageId
	FROM tblCTContractAcknowledgementStage
	WHERE strMessage = 'Success'
		AND strFeedStatus IS NULL

	SELECT @intContractAcknowledgementStageId = MIN(intContractAcknowledgementStageId)
	FROM @tblCTContractAcknowledgementStage

	IF @intContractAcknowledgementStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE tblCTContractAcknowledgementStage
	SET strFeedStatus = 'In-Progress'
	WHERE intContractAcknowledgementStageId IN (
			SELECT PS.intContractAcknowledgementStageId
			FROM @tblCTContractAcknowledgementStage PS
			)

	WHILE @intContractAcknowledgementStageId > 0
	BEGIN
		SET @strAckHeaderXML = NULL
		SET @strAckDetailXML = NULL
		SET @strAckCostXML = NULL
		SET @strAckDocumentXML = NULL
		SET @strTransactionType = NULL
		SET @strBookStatus = NULL

		SELECT @intTransactionId = NULL
			,@intCompanyId = NULL
			,@intTransactionRefId = NULL
			,@intCompanyRefId = NULL

		SELECT @strAckHeaderXML = strAckHeaderXML
			,@strAckDetailXML = strAckDetailXML
			,@strAckCostXML = strAckCostXML
			,@strAckDocumentXML = strAckDocumentXML
			,@strTransactionType = strTransactionType
			,@strBookStatus = strBookStatus
			,@intTransactionId = intTransactionId
			,@intCompanyId = intCompanyId
			,@intTransactionRefId = intTransactionRefId
			,@intCompanyRefId = intCompanyRefId
		FROM tblCTContractAcknowledgementStage
		WHERE intContractAcknowledgementStageId = @intContractAcknowledgementStageId

		IF @strTransactionType = 'Sales Contract'
			OR @strTransactionType = 'Purchase Contract'
		BEGIN
			------------------Header------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strAckHeaderXML

			SELECT @intContractHeaderId = intContractHeaderId
				,@intContractHeaderRefId = intContractHeaderRefId
				,@strContractNumber = strContractNumber
			FROM OPENXML(@idoc, 'tblCTContractHeaders/tblCTContractHeader', 2) WITH (
					intContractHeaderId INT
					,intContractHeaderRefId INT
					,strContractNumber NVARCHAR(100)
					)

			IF @strBookStatus = 'BookChanged'
			BEGIN
				UPDATE tblCTContractDocument
				SET intContractDocumentRefId = NULL
				WHERE intContractHeaderId = @intContractHeaderRefId

				UPDATE Cost
				SET Cost.intContractCostRefId = NULL
				FROM tblCTContractCost Cost
				JOIN tblCTContractDetail CD ON CD.intContractDetailId = Cost.intContractDetailId
				WHERE CD.intContractHeaderId = @intContractHeaderRefId

				UPDATE tblCTContractDetail
				SET intContractDetailRefId = NULL
				WHERE intContractHeaderId = @intContractHeaderRefId

				UPDATE tblCTContractHeader
				SET intContractHeaderRefId = NULL
				WHERE intContractHeaderId = @intContractHeaderRefId

				IF EXISTS (
						SELECT 1
						FROM tblCTContractHeader CH
						JOIN tblCTBookVsEntity BVE ON BVE.intBookId = CH.intBookId
							AND BVE.intEntityId = CH.intEntityId
						WHERE CH.intContractHeaderId = @intContractHeaderRefId
						)
				BEGIN
					SELECT @intToCompanyId = TC.intToCompanyId
						,@intToEntityId = TC.intEntityId
						,@strToTransactionType = TT1.strTransactionType
						,@intCompanyLocationId = TC.intCompanyLocationId
					FROM tblSMInterCompanyTransactionConfiguration TC
					JOIN tblSMInterCompanyTransactionType TT ON TT.intInterCompanyTransactionTypeId = TC.intFromTransactionTypeId
					JOIN tblSMInterCompanyTransactionType TT1 ON TT1.intInterCompanyTransactionTypeId = TC.intToTransactionTypeId
					JOIN tblCTContractHeader CH ON CH.intCompanyId = TC.intFromCompanyId
						AND CH.intBookId = TC.intFromBookId
					WHERE TT.strTransactionType = 'Purchase Contract'
						AND CH.intContractHeaderId = @intContractHeaderRefId

					EXEC uspCTContractPopulateStgXML @intContractHeaderRefId
						,@intToEntityId
						,@intCompanyLocationId
						,@strToTransactionType
						,@intToCompanyId
						,'Added'
				END
			END
			ELSE
			BEGIN
				UPDATE tblCTContractHeader
				SET intContractHeaderRefId = @intContractHeaderId
					,strCustomerContract = @strContractNumber
				WHERE intContractHeaderId = @intContractHeaderRefId
					AND intContractHeaderRefId IS NULL

				-----------------------------------Detail-------------------------------------------
				EXEC sp_xml_removedocument @idoc

				EXEC sp_xml_preparedocument @idoc OUTPUT
					,@strAckDetailXML

				UPDATE CD
				SET CD.intContractDetailRefId = XMLDetail.intContractDetailId
				FROM OPENXML(@idoc, 'tblCTContractDetails/tblCTContractDetail', 2) WITH (
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
				FROM OPENXML(@idoc, 'tblCTContractCosts/tblCTContractCost', 2) WITH (
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
				FROM OPENXML(@idoc, 'tblCTContractDocuments/tblCTContractDocument', 2) WITH (
						intContractDocumentId INT
						,intContractDocumentRefId INT
						) XMLDocument
				JOIN tblCTContractDocument ContractDocument ON ContractDocument.intContractDocumentId = XMLDocument.intContractDocumentRefId
				WHERE ContractDocument.intContractHeaderId = @intContractHeaderRefId
					AND ContractDocument.intContractDocumentRefId IS NULL
			END

			---UPDATE Feed Status in Staging
			UPDATE tblCTContractStage
			SET strFeedStatus = 'Ack Rcvd'
				,strMessage = 'Success'
			WHERE intContractHeaderId = @intContractHeaderRefId
				AND strFeedStatus = 'Awt Ack'

			---UPDATE Feed Status in Acknowledgement
			UPDATE tblCTContractAcknowledgementStage
			SET strFeedStatus = 'Ack Processed'
			WHERE intContractAcknowledgementStageId = @intContractAcknowledgementStageId
		END

		EXECUTE dbo.uspSMInterCompanyUpdateMapping @currentTransactionId = @intTransactionId
			,@referenceTransactionId = @intTransactionRefId
			,@referenceCompanyId = @intCompanyRefId

		SELECT @intContractAcknowledgementStageId = MIN(intContractAcknowledgementStageId)
		FROM @tblCTContractAcknowledgementStage
		WHERE intContractAcknowledgementStageId > @intContractAcknowledgementStageId
	END

	UPDATE tblCTContractAcknowledgementStage
	SET strFeedStatus = NULL
	WHERE intContractAcknowledgementStageId IN (
			SELECT PS.intContractAcknowledgementStageId
			FROM @tblCTContractAcknowledgementStage PS
			)
		AND IsNULL(strFeedStatus, '') = 'In-Progress'
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
