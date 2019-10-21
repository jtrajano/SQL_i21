CREATE FUNCTION [dbo].[fnTFCoalesceVendor]
(
	@intReportingComponentId INT,
	@ysnInclude BIT
)
RETURNS NVARCHAR(max)
AS
BEGIN
	DECLARE @strValue nvarchar(max)

	SELECT @strValue = COALESCE(@strValue + ',', '') + strVendorName
	from vyuTFGetReportingComponentVendor
	where intReportingComponentId = @intReportingComponentId
	and ysnInclude = @ysnInclude 
	
	RETURN @strValue
END
