CREATE PROCEDURE [dbo].[uspCTInterCompanyPriceContract] @intPriceContractId INT
	,@ysnApprove BIT = 0
	,@strRowState NVARCHAR(50)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strInsert NVARCHAR(100)
		,@strUpdate NVARCHAR(100)
		,@strDelete NVARCHAR(100)
		,@intToCompanyId INT
		,@strTransactionType NVARCHAR(50)
		,@intCompanyId INT

	SELECT @intCompanyId = intCompanyId
	FROM dbo.tblIPMultiCompany
	WHERE ysnCurrentCompany = 1

	UPDATE dbo.tblCTPriceContract
	SET intCompanyId = @intCompanyId
	WHERE intCompanyId IS NULL

	IF EXISTS (
			SELECT 1
			FROM tblSMInterCompanyTransactionConfiguration TC
			JOIN tblSMInterCompanyTransactionType TT ON TT.intInterCompanyTransactionTypeId = TC.intFromTransactionTypeId
			JOIN tblSMInterCompanyTransactionType TT1 ON TT1.intInterCompanyTransactionTypeId = TC.intToTransactionTypeId
			JOIN tblCTPriceContract PC ON PC.intCompanyId = TC.intFromCompanyId
			JOIN tblCTPriceFixation PF ON PF.intPriceContractId = PC.intPriceContractId
			JOIN tblCTContractHeader CH ON CH.intContractHeaderId = PF.intContractHeaderId
				AND CH.intBookId = TC.intToBookId
			WHERE TT.strTransactionType = 'Sales Price Fixation'
				AND PC.intPriceContractId = @intPriceContractId
				AND CH.intContractTypeId = 2
			)
	BEGIN
		SELECT @strInsert = TC.strInsert
			,@strUpdate = TC.strUpdate
			,@strDelete = TC.strDelete
			,@intToCompanyId = intToCompanyId
			,@strTransactionType = TT1.strTransactionType
		FROM tblSMInterCompanyTransactionConfiguration TC
		JOIN tblSMInterCompanyTransactionType TT ON TT.intInterCompanyTransactionTypeId = TC.intFromTransactionTypeId
		JOIN tblSMInterCompanyTransactionType TT1 ON TT1.intInterCompanyTransactionTypeId = TC.intToTransactionTypeId
		JOIN tblCTPriceContract PC ON PC.intCompanyId = TC.intFromCompanyId
		JOIN tblCTPriceFixation PF ON PF.intPriceContractId = PC.intPriceContractId
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = PF.intContractHeaderId
			AND CH.intBookId = TC.intToBookId
		WHERE TT.strTransactionType = 'Sales Price Fixation'
			AND PC.intPriceContractId = @intPriceContractId
			AND CH.intContractTypeId = 2

		IF (
				(
					@strInsert = 'Insert'
					AND @ysnApprove = 0
					)
				OR (
					@strUpdate = 'Update'
					AND @ysnApprove = 0
					)
				OR (
					@strDelete = 'Delete'
					AND @ysnApprove = 0
					)
				OR (
					@strInsert = 'Insert on Approval'
					AND @ysnApprove = 1
					)
				OR (
					@strUpdate = 'Update on Approval'
					AND @ysnApprove = 1
					)
				)
		BEGIN
			DELETE
			FROM tblCTPriceContractPreStage
			WHERE intPriceContractId = @intPriceContractId
				AND strFeedStatus IS NULL

			INSERT INTO dbo.tblCTPriceContractPreStage (
				intPriceContractId
				,strRowState
				,intMultiCompanyId
				,strTransactionType
				)
			SELECT @intPriceContractId
				,@strRowState
				,@intToCompanyId
				,@strTransactionType
		END
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
