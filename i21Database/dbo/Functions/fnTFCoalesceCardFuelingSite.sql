CREATE FUNCTION [dbo].[fnTFCoalesceCardFuelingSite]
(
	@intReportingComponentId INT,
	@ysnInclude BIT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @strValue NVARCHAR(MAX)
	
	SELECT @strValue = COALESCE(@strValue + ',', '') + strTransactionType
	FROM vyuTFGetReportingComponentCardFuelingSiteType
	WHERE intReportingComponentId = @intReportingComponentId
	AND ysnInclude = @ysnInclude 

	SELECT @strValue = COALESCE(@strValue + ',', '') + strSiteNumber
	FROM vyuTFGetReportingComponentCardFuelingSite
	WHERE intReportingComponentId = @intReportingComponentId
	AND ysnInclude = @ysnInclude 
	
	RETURN @strValue
END