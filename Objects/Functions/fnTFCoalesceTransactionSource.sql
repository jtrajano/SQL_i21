CREATE FUNCTION [dbo].[fnTFCoalesceTransactionSource]
(
	@intReportingComponentId INT,
	@ysnInclude BIT
)
RETURNS NVARCHAR(max)
AS
BEGIN
	DECLARE @strValue nvarchar(max)

	SELECT @strValue = COALESCE(@strValue + ',', '') + strTransactionSource
	from vyuTFGetReportingComponentTransactionSource
	where intReportingComponentId = @intReportingComponentId
	and ysnInclude = @ysnInclude 
	
	RETURN @strValue
END
