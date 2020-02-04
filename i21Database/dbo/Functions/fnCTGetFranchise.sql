CREATE FUNCTION [dbo].[fnCTGetFranchise]
(
	@intLoadDetailId	INT
)
RETURNS @returntable	TABLE
(
	dblFranchise	NUMERIC(18,6)
)
AS
BEGIN

	DECLARE @dblFranchise NUMERIC(38,20)
	
	SELECT @dblFranchise = dblGross
	FROM tblLGLoadDetail
	WHERE intLoadDetailId = @intLoadDetailId

	INSERT	@returntable (dblFranchise)
	SELECT 	@dblFranchise 

	RETURN;
END
