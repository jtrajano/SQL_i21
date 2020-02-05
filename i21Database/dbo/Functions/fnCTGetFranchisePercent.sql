CREATE FUNCTION [dbo].[fnCTGetFranchisePercent]
(
	@intContractDetailId	INT
)
RETURNS @returntable	TABLE
(
	dblFranchisePercent	NUMERIC(18,6)
)
AS
BEGIN

	DECLARE @dblFranchisePercent NUMERIC(38,20)

	SELECT @dblFranchisePercent = ((dblFromNet - dblToNet) / dblFromNet) * 100 -- Franchise (%)
	FROM tblLGWeightClaimDetail
	WHERE intContractDetailId = @intContractDetailId

	INSERT	@returntable (dblFranchisePercent)
	SELECT 	@dblFranchisePercent 

	RETURN;

END