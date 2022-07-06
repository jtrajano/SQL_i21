CREATE FUNCTION [dbo].[fnGetItemCompanySegment]
(
	@intLocationId INT
)
RETURNS INT
AS 
BEGIN 
	DECLARE @intProfitCenter AS INT

	-- Get the COMPANY segment from the company location
	SELECT	@intProfitCenter = intCompanySegment
	FROM	dbo.tblSMCompanyLocation 
	WHERE	intCompanyLocationId = @intLocationId

	RETURN @intProfitCenter 
END
GO