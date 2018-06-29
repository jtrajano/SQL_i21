CREATE FUNCTION [dbo].[fnTFCoalesceAccountStatusCode]
(
    @intReportingComponentId INT,
    @ysnInclude BIT
)
RETURNS NVARCHAR(max)
AS
BEGIN
    DECLARE @strValue nvarchar(max)

    SELECT @strValue = COALESCE(@strValue + ',', '') + strAccountStatusCode
    from vyuTFGetReportingComponentAccountStatusCode
    where intReportingComponentId = @intReportingComponentId
    and ysnInclude = @ysnInclude 
    
    RETURN @strValue
END
