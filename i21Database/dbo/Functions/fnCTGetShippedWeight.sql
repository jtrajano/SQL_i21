CREATE FUNCTION [dbo].[fnCTGetShippedWeight]
(
	@intLoadDetailId	INT
)
RETURNS @returntable	TABLE
(
	dblShippedWeight	NUMERIC(18,6)
)
AS
BEGIN

	DECLARE @dblShippedWeight NUMERIC(38,20)
	
	SELECT @dblShippedWeight = dblGross
	FROM tblLGLoadDetail
	WHERE intLoadDetailId = @intLoadDetailId

	INSERT	@returntable (dblShippedWeight)
	SELECT 	@dblShippedWeight 

	RETURN;
END