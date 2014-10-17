CREATE FUNCTION [dbo].[fnGetGLAccountIdFromProfitCenter]
(
	@intNaturalAccount INT
	,@intProfitCenterId INT
)
RETURNS INT
AS 
BEGIN
	DECLARE @intGLAccountId AS INT;

	-- This function expects to return only one record. 
	-- If it returns more than one record, then let SQL throw the error. 
	SELECT	@intGLAccountId = Accnt.intAccountId
	FROM	tblGLAccount Accnt 
	WHERE	-- Condition for the natural account (Primary segment)
			Accnt.intAccountId IN (
				SELECT TOP 1 intAccountId FROM tblGLAccountSegmentMapping WHERE intAccountSegmentId = @intNaturalAccount
			) 
			-- Condition for the segment/s (profit center) 
			AND Accnt.intAccountId IN (
					SELECT intAccountId FROM tblGLAccountSegmentMapping WHERE intAccountSegmentId IN (
							NULL 
							-- TODO: Select the segments from the profit center table. 
							-- For example: 
							-- SELECT intAccountSegmentId FROM ProfitCenterDetail WHERE intProfitCenterId = @intProfitCenterId
						)
			);

	RETURN @intGLAccountId;
END 

GO
