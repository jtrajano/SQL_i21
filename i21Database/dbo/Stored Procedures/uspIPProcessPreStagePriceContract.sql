CREATE PROCEDURE [dbo].[uspIPProcessPreStagePriceContract]
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

	Declare @tblCTPriceContractPreStage table(intPriceContractPreStageId int)
	Insert into @tblCTPriceContractPreStage
	SELECT intPriceContractPreStageId
	FROM tblCTPriceContractPreStage
	WHERE strFeedStatus IS NULL

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

		SELECT @intPriceContractId = intPriceContractId
		FROM tblCTPriceContractPreStage
		WHERE intPriceContractPreStageId = @intPriceContractPreStageId

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
		END
		ELSE IF NOT EXISTS (
				SELECT 1
				FROM tblCTPriceContract
				WHERE intPriceContractId = @intPriceContractId
				)
		BEGIN
			SELECT @strToTransactionType=strTransactionType
				,@intToCompanyId = intMultiCompanyId
			FROM tblCTPriceContractPreStage
			WHERE intPriceContractId = @intPriceContractId

			EXEC uspCTPriceContractPopulateStgXML @intPriceContractId
				,@intToEntityId
				,@strToTransactionType
				,@intToCompanyId
				,'Delete'
				,0
		END

		UPDATE tblCTPriceContractPreStage
		SET strFeedStatus = 'Processed'
		WHERE intPriceContractPreStageId = @intPriceContractPreStageId

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
