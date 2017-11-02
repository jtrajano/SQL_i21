CREATE FUNCTION [dbo].[fnTFCoalesceCustomer]
(
	@intReportingComponentId INT,
	@ysnInclude BIT
)
RETURNS NVARCHAR(max)
AS
BEGIN
	DECLARE @strValue nvarchar(max)

	SELECT @strValue = COALESCE(@strValue + ',', '') + strCustomerNumber
	from vyuTFGetReportingComponentCustomer
	where intReportingComponentId = @intReportingComponentId
	and ysnInclude = @ysnInclude 
	
	RETURN @strValue
END
