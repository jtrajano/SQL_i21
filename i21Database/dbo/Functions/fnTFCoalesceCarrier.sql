CREATE FUNCTION [dbo].[fnTFCoalesceCarrier]
(
	@intReportingComponentId INT,
	@ysnInclude BIT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @strValue NVARCHAR(MAX)
	
	SELECT @strValue = COALESCE(@strValue + '||', '') + strShipVia
	FROM vyuTFGetReportingComponentCarrier
	WHERE intReportingComponentId = @intReportingComponentId
	AND ysnInclude = @ysnInclude 
	
	RETURN @strValue
END