CREATE FUNCTION [dbo].[fnCTGetFranchisePercent]
(
	@intContractDetailId	INT
)
RETURNS @returntable	TABLE
(
	dblFranchisePercent	NUMERIC(18,6),
	ysnAbove BIT
)
AS
BEGIN

	DECLARE @dblFranchisePercent NUMERIC(38,20),
			@dblFranchise NUMERIC(38,20)

	SELECT @dblFranchisePercent = ((dblFromNet - dblToNet) / dblFromNet) * 100 -- Franchise (%)
	,@dblFranchise =  dblFranchise
	FROM tblLGWeightClaimDetail
	WHERE intContractDetailId = @intContractDetailId

	INSERT	@returntable (dblFranchisePercent,ysnAbove)
	SELECT 	@dblFranchisePercent,CASE WHEN @dblFranchisePercent > @dblFranchise THEN 1 ELSE 0 END

	RETURN;

END