CREATE PROCEDURE [uspLGProcessWeightClaimAckXML]
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc								INT
	DECLARE @ErrMsg								NVARCHAR(MAX)
	DECLARE @intAcknowledgementStageId			INT
	DECLARE @strContractDetailAllId				NVARCHAR(MAX)
	
	DECLARE @strAckWeightClaimXML				NVARCHAR(MAX)
	DECLARE @strAckWeightClaimDetailXML			NVARCHAR(MAX)
	DECLARE @intWeightClaimId					INT
	DECLARE @intWeightClaimRefId				INT
	DECLARE @strWeightClaimNumber				NVARCHAR(100)

	DECLARE @strLoadNumber						NVARCHAR(MAX)
	DECLARE @strTransactionType					NVARCHAR(MAX)
	DECLARE @intContractHeaderId				INT
	DECLARE @intContractHeaderRefId				INT

	SELECT @intAcknowledgementStageId = MIN(intId)
	FROM tblLGIntrCompWeightClaimsAck
	WHERE ISNULL(strFeedStatus, '') = ''

	WHILE @intAcknowledgementStageId > 0
	BEGIN
		SET @strAckWeightClaimXML = NULL
		SET @strAckWeightClaimDetailXML = NULL

		SELECT @strAckWeightClaimXML = strWeightClaim
			,@strAckWeightClaimDetailXML = strWeightClaimDetail
			,@strTransactionType = strTransactionType
		FROM tblLGIntrCompWeightClaimsAck
		WHERE intId = @intAcknowledgementStageId

		--IF @strTransactionType = 'Sales Contract'
		BEGIN
			
			------------------Header------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strAckWeightClaimXML

			SELECT @intWeightClaimId = intWeightClaimId
				,@intWeightClaimRefId = intWeightClaimRefId
				,@strWeightClaimNumber = strReferenceNumber
			FROM OPENXML(@idoc, 'tblLGWeightClaims/tblLGWeightClaim', 2) WITH (
					intWeightClaimId INT
					,intWeightClaimRefId INT
					,strReferenceNumber NVARCHAR(100)
					)

			UPDATE tblLGWeightClaim
			SET intWeightClaimRefId = @intWeightClaimId
			WHERE intWeightClaimId = @intWeightClaimRefId
				AND intWeightClaimRefId IS NULL

			-----------------------------------Detail-------------------------------------------
			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strAckWeightClaimDetailXML

			UPDATE WCD
			SET intWeightClaimDetailRefId = XMLDetail.intWeightClaimDetailId
			FROM OPENXML(@idoc, 'tblLGWeightClaimDetails/tblLGWeightClaimDetail', 2) WITH (
					intWeightClaimDetailId INT
					,intWeightClaimDetailRefId INT
					) XMLDetail
			JOIN tblLGWeightClaimDetail WCD ON WCD.intWeightClaimDetailId = XMLDetail.intWeightClaimDetailRefId
			WHERE WCD.intWeightClaimDetailId = @intWeightClaimRefId
				AND WCD.intWeightClaimDetailRefId IS NULL

			-----------------------------------NotifyParty--------------------------------------
			EXEC sp_xml_removedocument @idoc

		END

		UPDATE tblLGIntrCompWeightClaimsAck 
		SET strFeedStatus = 'Processed'
		WHERE intId > @intAcknowledgementStageId

		SELECT @intAcknowledgementStageId = MIN(intId)
		FROM tblLGIntrCompWeightClaimsAck
		WHERE intId > @intAcknowledgementStageId
			AND ISNULL(strFeedStatus, '') = ''
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH