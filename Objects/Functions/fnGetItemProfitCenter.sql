CREATE FUNCTION [dbo].[fnGetItemProfitCenter]
(
	@intLocationId INT
)
RETURNS INT
AS 
BEGIN 
	DECLARE @intProfitCenter AS INT

	-- Get the profit center from the company location
	SELECT	@intProfitCenter = intProfitCenter
	FROM	dbo.tblSMCompanyLocation 
	WHERE	intCompanyLocationId = @intLocationId

	RETURN @intProfitCenter 
END
GO