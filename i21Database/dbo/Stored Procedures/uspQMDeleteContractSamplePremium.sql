CREATE PROCEDURE uspQMDeleteContractSamplePremium @intContractDetailId INT
	,@intSampleId INT
	,@intUserId INT
	,@ysnImpactPricing BIT
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)

	EXEC uspCTSaveContractSamplePremium @intContractDetailId = @intContractDetailId
		,@intSampleId = @intSampleId
		,@intUserId = @intUserId
		,@ysnImpactPricing = @ysnImpactPricing
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
