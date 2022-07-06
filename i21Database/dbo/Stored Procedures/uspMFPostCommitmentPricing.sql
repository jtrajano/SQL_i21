CREATE PROCEDURE uspMFPostCommitmentPricing @intCommitmentPricingId INT
	,@ysnPost BIT
	,@intUserId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)

	IF EXISTS (
			SELECT 1
			FROM tblMFCommitmentPricingStage
			WHERE intCommitmentPricingId = @intCommitmentPricingId
				AND ISNULL(intStatusId, 1) <> 1
			)
	BEGIN
		DELETE
		FROM tblMFCommitmentPricingStage
		WHERE intCommitmentPricingId = @intCommitmentPricingId
			AND ysnPost = @ysnPost
			AND ISNULL(intStatusId, 1) = 1
	END
	ELSE
	BEGIN
		DELETE
		FROM tblMFCommitmentPricingStage
		WHERE intCommitmentPricingId = @intCommitmentPricingId
			AND ISNULL(intStatusId, 1) = 1
	END

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
