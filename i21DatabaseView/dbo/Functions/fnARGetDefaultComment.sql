CREATE FUNCTION [dbo].[fnARGetDefaultComment]
(
	@intCompanyLocationId	INT = NULL,
	@intEntityCustomerId	INT = NULL,
	@strTransactionType     NVARCHAR(50) = NULL,
	@strType                NVARCHAR(50) = NULL,
	@strHeaderFooter		NVARCHAR(50) = NULL,
	@DocumentMaintenanceId	INT = NULL,
	@ysnPrintAsHTML			BIT = 0	
)
RETURNS NVARCHAR(MAX) AS
BEGIN
	DECLARE @strDefaultComment NVARCHAR(MAX) = NULL
	
	SELECT TOP 1 @strDefaultComment = strDefaultComment FROM
		[dbo].[fnARGetDefaultCommentTable](@intCompanyLocationId, @intEntityCustomerId, @strTransactionType, @strType, @strHeaderFooter, @DocumentMaintenanceId, @ysnPrintAsHTML)
	RETURN @strDefaultComment
	
END