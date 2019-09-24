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

	SELECT @intToCompanyId = TC.intToCompanyId
		,@intToEntityId = TC.intEntityId
		,@strInsert = TC.strInsert
		,@strUpdate = TC.strUpdate
		,@strDelete = TC.strDelete
		,@strToTransactionType = TT1.strTransactionType
	FROM tblSMInterCompanyTransactionConfiguration TC
	JOIN tblSMInterCompanyTransactionType TT ON TT.intInterCompanyTransactionTypeId = TC.intFromTransactionTypeId
	JOIN tblSMInterCompanyTransactionType TT1 ON TT1.intInterCompanyTransactionTypeId = TC.intToTransactionTypeId
	WHERE TT.strTransactionType IN (
			'Purchase Price Fixation'
			,'Sales Price Fixation'
			)

	SELECT @intPriceContractPreStageId = MIN(intPriceContractPreStageId)
	FROM tblCTPriceContractPreStage
	WHERE strFeedStatus IS NULL

	WHILE @intPriceContractPreStageId IS NOT NULL
	BEGIN
		SELECT @intPriceContractId = intPriceContractId
		FROM tblCTPriceContractPreStage
		WHERE intPriceContractPreStageId = @intPriceContractPreStageId

		IF EXISTS (
				SELECT 1
				FROM tblCTPriceContract
				WHERE intPriceContractId = @intPriceContractId
					AND intConcurrencyId = 1
				)
			AND @strInsert = 'Insert'
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
			AND @strUpdate = 'Update'
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
		FROM tblCTPriceContractPreStage
		WHERE strFeedStatus IS NULL
			AND intPriceContractPreStageId > @intPriceContractPreStageId
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
