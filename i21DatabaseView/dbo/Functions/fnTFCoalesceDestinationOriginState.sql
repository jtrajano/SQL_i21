CREATE FUNCTION [dbo].[fnTFCoalesceOriginState]
(
	@intReportingComponentId INT,
	@strType NVARCHAR(20)
)
RETURNS NVARCHAR(max)
AS
BEGIN
	DECLARE @strValue nvarchar(max)

	SELECT @strValue = COALESCE(@strValue + ',', '') + strOriginDestinationState
	from vyuTFGetReportingComponentOriginState
	where intReportingComponentId = @intReportingComponentId
	and strType = @strType 
	
	RETURN @strValue
END
