CREATE PROCEDURE [dbo].[uspCTPriceContractProcessAckXML]
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc									INT
	DECLARE @ErrMsg									NVARCHAR(MAX)
	DECLARE @intPriceContractAcknowledgementStageId INT
	DECLARE @strHeaderCondition						NVARCHAR(MAX)
	DECLARE @strCostCondition						NVARCHAR(MAX)
	DECLARE @strContractDetailAllId					NVARCHAR(MAX)
	DECLARE @strAckPriceContractXML					NVARCHAR(MAX)
	DECLARE @strAckPriceFixationXML					NVARCHAR(MAX)
	DECLARE @strAckPriceFixationDetailXML			NVARCHAR(MAX)
	DECLARE @strTransactionType						NVARCHAR(MAX)
	DECLARE @intPriceContractId						INT
	DECLARE @intPriceContractRefId					INT
	DECLARE @intPriceFixationId						INT
	DECLARE @intPriceFixationRefId					INT

	

	SELECT @intPriceContractAcknowledgementStageId = MIN(intPriceContractAcknowledgementStageId)
	FROM tblCTPriceContractAcknowledgementStage
	WHERE strMessage = 'Success'
		AND ISNULL(strFeedStatus, '') = ''

	WHILE @intPriceContractAcknowledgementStageId > 0
	BEGIN
		SET @strAckPriceContractXML		  = NULL
		SET @strAckPriceFixationXML		  = NULL
		SET @strAckPriceFixationDetailXML = NULL
		SET @strTransactionType			  = NULL

		SELECT @strAckPriceContractXML	    = strAckPriceContractXML
			,@strAckPriceFixationXML	    = strAckPriceFixationXML
			,@strAckPriceFixationDetailXML  = strAckPriceFixationDetailXML
			,@strTransactionType			= strTransactionType
		FROM tblCTPriceContractAcknowledgementStage
		WHERE intPriceContractAcknowledgementStageId = @intPriceContractAcknowledgementStageId

		IF @strTransactionType = 'Sales Price Fixation'
		BEGIN
			-------------------------PriceContract-----------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT,@strAckPriceContractXML

			SELECT @intPriceContractId = intPriceContractId
				,@intPriceContractRefId = intPriceContractRefId
			FROM OPENXML(@idoc, 'tblCTPriceContracts/tblCTPriceContract', 2) WITH (
					intPriceContractId INT
					,intPriceContractRefId INT
					)
			
			UPDATE tblCTPriceContract
			SET intPriceContractRefId = @intPriceContractId
			WHERE intPriceContractId = @intPriceContractRefId
				AND intPriceContractRefId IS NULL

			---------------------------------------------PriceFixation------------------------------------------
			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT,@strAckPriceFixationXML

			UPDATE PriceFixation
			SET PriceFixation.intPriceFixationRefId = XMLDetail.intPriceFixationId
			FROM OPENXML(@idoc, 'tblCTPriceFixations/tblCTPriceFixation', 2) WITH (
					intPriceFixationId INT
					,intPriceFixationRefId INT
					) XMLDetail
			JOIN tblCTPriceFixation PriceFixation ON PriceFixation.intPriceFixationId = XMLDetail.intPriceFixationRefId
			WHERE PriceFixation.intPriceContractId = @intPriceContractRefId
				AND PriceFixation.intPriceFixationRefId IS NULL

			---------------------------------------------PriceFixationDetail-----------------------------------------------
			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT,@strAckPriceFixationDetailXML

			SELECT * FROM OPENXML(@idoc, 'tblCTPriceFixationDetails/tblCTPriceFixationDetail', 2) WITH 
			(
					intPriceFixationDetailId INT
					,intPriceFixationDetailRefId INT
					,intPriceFixationId INT
			) XMLCost

			UPDATE PFD
			SET PFD.intPriceFixationDetailRefId = XMLCost.intPriceFixationDetailId
			FROM OPENXML(@idoc, 'tblCTPriceFixationDetails/tblCTPriceFixationDetail', 2) WITH 
			(
					intPriceFixationDetailId INT
					,intPriceFixationDetailRefId INT
					,intPriceFixationId INT
			) XMLCost
			JOIN tblCTPriceFixationDetail PFD ON PFD.intPriceFixationDetailId = XMLCost.intPriceFixationDetailRefId
			--JOIN tblCTPriceFixation PF ON PF.intPriceFixationId = PFD.intPriceFixationId
			--					       AND PF.intPriceFixationRefId = XMLCost.intPriceFixationId
			WHERE PFD.intPriceFixationDetailRefId IS NULL

			

			---UPDATE Feed Status in Staging
			UPDATE tblCTPriceContractStage
			SET strFeedStatus = 'Ack Rcvd'
				,strMessage = 'Success'
			WHERE intPriceContractId = @intPriceContractRefId
				AND strFeedStatus = 'Awt Ack'

			---UPDATE Feed Status in Acknowledgement
			UPDATE tblCTPriceContractAcknowledgementStage
			SET strFeedStatus = 'Ack Processed'
			WHERE intPriceContractAcknowledgementStageId = intPriceContractAcknowledgementStageId
		END

		SELECT @intPriceContractAcknowledgementStageId = MIN(intPriceContractAcknowledgementStageId)
		FROM tblCTPriceContractAcknowledgementStage
		WHERE intPriceContractAcknowledgementStageId > intPriceContractAcknowledgementStageId
			AND strMessage = 'Success'
			AND ISNULL(strFeedStatus, '') = ''
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')

END CATCH
