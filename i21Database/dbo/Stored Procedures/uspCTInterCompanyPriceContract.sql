CREATE PROCEDURE [dbo].[uspCTInterCompanyPriceContract] @intPriceContractId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	IF EXISTS (
			SELECT 1
			FROM tblSMInterCompanyTransactionConfiguration TC
			JOIN tblSMInterCompanyTransactionType TT ON TT.intInterCompanyTransactionTypeId = TC.intFromTransactionTypeId
			WHERE TT.strTransactionType IN (
					'Purchase Price Fixation'
					,'Sales Price Fixation'
					)
			)
	BEGIN
		INSERT INTO dbo.tblCTPriceContractPreStage (intPriceContractId)
		SELECT @intPriceContractId
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
