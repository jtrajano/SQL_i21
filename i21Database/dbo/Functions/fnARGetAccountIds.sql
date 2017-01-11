CREATE FUNCTION [dbo].[fnARGetAccountIds]
(
	@strAccountCategory NVARCHAR(50)
)
RETURNS NVARCHAR(MAX) AS
BEGIN
	DECLARE @strAccountIds NVARCHAR(MAX) = NULL
	
	SELECT @strAccountIds = COALESCE(@strAccountIds + ', ', '') + strAccountId FROM vyuGLAccountDetail WHERE strAccountCategory IN (@strAccountCategory)
	
	RETURN ISNULL(@strAccountIds, '')
END