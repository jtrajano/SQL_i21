CREATE PROCEDURE uspMFPostCommitmentPricing @intCommitmentPricingId INT
	,@ysnPost BIT
	,@intUserId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	INSERT INTO tblMFCommitmentPricingStage (
		intCommitmentPricingId
		,ysnPost
		,intUserId
		)
	SELECT @intCommitmentPricingId
		,@ysnPost
		,@intUserId
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
