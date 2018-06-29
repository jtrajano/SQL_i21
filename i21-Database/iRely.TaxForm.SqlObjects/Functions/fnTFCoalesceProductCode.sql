CREATE FUNCTION [dbo].[fnTFCoalesceProductCode]
(
	@intReportingComponentId int
)
RETURNS NVARCHAR(max)
AS
BEGIN
	DECLARE @strValue nvarchar(max);

	SELECT @strValue = COALESCE(@strValue + ',', '') + strProductCode
	FROM vyuTFGetReportingComponentProductCode
	WHERE intReportingComponentId = @intReportingComponentId

	RETURN @strValue
END
