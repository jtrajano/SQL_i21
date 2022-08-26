CREATE PROCEDURE [dbo].[uspIPProcessPreStagePriceContract] (@ysnProcessApproverInfo BIT = 0)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intToCompanyId INT
	DECLARE @intToEntityId INT
	DECLARE @strInsert NVARCHAR(100)
	DECLARE @strUpdate NVARCHAR(100)
		,@strDelete NVARCHAR(50)
	DECLARE @strToTransactionType NVARCHAR(100)
		,@intPriceContractPreStageId INT
		,@intPriceContractId INT
		,@intContractHeaderId INT
		,@ysnApproval BIT
		,@intContractScreenId INT
	DECLARE @tblCTPriceContractPreStage TABLE (intPriceContractPreStageId INT)

	INSERT INTO @tblCTPriceContractPreStage
	SELECT PS.intPriceContractPreStageId
	FROM dbo.tblCTPriceContractPreStage PS
	JOIN dbo.tblCTPriceFixation PF ON PF.intPriceContractId = PS.intPriceContractId
	JOIN dbo.tblCTContractHeader CH ON CH.intContractHeaderId = PF.intContractHeaderId
	WHERE PS.strFeedStatus IS NULL
		AND CH.intContractHeaderRefId IS NOT NULL

	INSERT INTO @tblCTPriceContractPreStage
	SELECT PS.intPriceContractPreStageId
	FROM dbo.tblCTPriceContractPreStage PS
	WHERE PS.strFeedStatus IS NULL
		AND PS.strRowState = 'Delete'
		AND PS.intPriceContractId IN (
			SELECT PS1.intPriceContractId
			FROM tblCTPriceContractPreStage PS1
			WHERE PS1.strFeedStatus = 'Processed'
			)

	SELECT @intPriceContractPreStageId = MIN(intPriceContractPreStageId)
	FROM @tblCTPriceContractPreStage

	IF @intPriceContractPreStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE tblCTPriceContractPreStage
	SET strFeedStatus = 'In-Progress'
	WHERE intPriceContractPreStageId IN (
			SELECT PS.intPriceContractPreStageId
			FROM @tblCTPriceContractPreStage PS
			)

	SELECT @intContractScreenId = NULL

	SELECT @intContractScreenId = intScreenId
	FROM tblSMScreen
	WHERE strNamespace = 'ContractManagement.view.PriceContracts'

	WHILE @intPriceContractPreStageId IS NOT NULL
	BEGIN
		SELECT @intPriceContractId = NULL
			,@intToCompanyId = NULL
			,@intToEntityId = NULL
			,@strInsert = NULL
			,@strUpdate = NULL
			,@strDelete = NULL
			,@strToTransactionType = NULL
			,@intContractHeaderId = NULL
			,@ysnApproval = NULL

		SELECT @intPriceContractId = intPriceContractId
			,@ysnApproval = ysnApproval
		FROM tblCTPriceContractPreStage
		WHERE intPriceContractPreStageId = @intPriceContractPreStageId

		IF @ysnApproval = 0
		BEGIN
			IF NOT EXISTS (
					SELECT TOP 1 1
					FROM dbo.tblSMTransaction
					WHERE strApprovalStatus IN (
							'Approved'
							,'Approved with Modifications'
							,'No Need for Approval'
							)
						AND intRecordId = @intPriceContractId
						AND intScreenId = @intContractScreenId
					)
			BEGIN
				UPDATE dbo.tblCTPriceContractPreStage
				SET strFeedStatus = 'IGNORE'
				WHERE intPriceContractPreStageId = @intPriceContractPreStageId

				GOTO NextContract
			END
		END

		SELECT @intContractHeaderId = intContractHeaderId
		FROM tblCTPriceFixation
		WHERE intPriceContractId = @intPriceContractId

		SELECT @intToCompanyId = TC.intToCompanyId
			,@intToEntityId = TC.intEntityId
			,@strInsert = TC.strInsert
			,@strUpdate = TC.strUpdate
			,@strDelete = TC.strDelete
			,@strToTransactionType = TT1.strTransactionType
		FROM tblSMInterCompanyTransactionConfiguration TC
		JOIN tblSMInterCompanyTransactionType TT ON TT.intInterCompanyTransactionTypeId = TC.intFromTransactionTypeId
		JOIN tblSMInterCompanyTransactionType TT1 ON TT1.intInterCompanyTransactionTypeId = TC.intToTransactionTypeId
		JOIN tblCTContractHeader CH ON CH.intCompanyId = TC.intFromCompanyId
			AND CH.intBookId = TC.intToBookId
		WHERE TT.strTransactionType IN (
				'Purchase Price Fixation'
				,'Sales Price Fixation'
				)
			AND CH.intContractHeaderId = @intContractHeaderId

		IF EXISTS (
				SELECT 1
				FROM tblCTPriceContract
				WHERE intPriceContractId = @intPriceContractId
					AND intConcurrencyId = 1
				)
			--AND @strInsert in('Insert','Insert on Approval')
		BEGIN
			EXEC uspCTPriceContractPopulateStgXML @intPriceContractId
				,@intToEntityId
				,@strToTransactionType
				,@intToCompanyId
				,'Added'
				,0
				,@ysnProcessApproverInfo
				,@ysnApproval
		END
		ELSE IF EXISTS (
				SELECT 1
				FROM tblCTPriceContract
				WHERE intPriceContractId = @intPriceContractId
					AND intConcurrencyId > 1
				)
			--AND @strUpdate in ('Update','Update on Approval')
		BEGIN
			EXEC uspCTPriceContractPopulateStgXML @intPriceContractId
				,@intToEntityId
				,@strToTransactionType
				,@intToCompanyId
				,'Modified'
				,0
				,@ysnProcessApproverInfo
				,@ysnApproval
		END
		ELSE IF NOT EXISTS (
				SELECT 1
				FROM tblCTPriceContract
				WHERE intPriceContractId = @intPriceContractId
				)
		BEGIN
			SELECT @strToTransactionType = strTransactionType
				,@intToCompanyId = intMultiCompanyId
			FROM tblCTPriceContractPreStage
			WHERE intPriceContractId = @intPriceContractId

			EXEC uspCTPriceContractPopulateStgXML @intPriceContractId
				,@intToEntityId
				,@strToTransactionType
				,@intToCompanyId
				,'Delete'
				,0
				,@ysnProcessApproverInfo
				,@ysnApproval
		END

		UPDATE tblCTPriceContractPreStage
		SET strFeedStatus = 'Processed'
		WHERE intPriceContractPreStageId = @intPriceContractPreStageId

		NextContract:

		SELECT @intPriceContractPreStageId = MIN(intPriceContractPreStageId)
		FROM @tblCTPriceContractPreStage
		WHERE intPriceContractPreStageId > @intPriceContractPreStageId
	END

	UPDATE tblCTPriceContractPreStage
	SET strFeedStatus = NULL
	WHERE intPriceContractPreStageId IN (
			SELECT PS.intPriceContractPreStageId
			FROM @tblCTPriceContractPreStage PS
			)
		AND strFeedStatus = 'In-Progress'
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
