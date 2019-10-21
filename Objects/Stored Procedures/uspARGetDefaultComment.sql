CREATE PROCEDURE [dbo].[uspARGetDefaultComment]
	@intCompanyLocationId	INT = NULL,
	@intEntityCustomerId	INT = NULL,
	@strTransactionType     NVARCHAR(50) = NULL,
	@strType                NVARCHAR(50) = NULL,
	@strHeaderComment		NVARCHAR(MAX) = NULL OUTPUT,
	@strFooterComment		NVARCHAR(MAX) = NULL OUTPUT,
	@DocumentMaintenanceId	INT = NULL,
	@intDocumentUsedId		INT = NULL OUTPUT,
	@strDocumentUsedCode	NVARCHAR(10) = NULL OUTPUT,
	@strDocumentUsedTitle	NVARCHAR(50) = NULL OUTPUT
AS

SELECT TOP 1 @strHeaderComment =  strDefaultComment,
		@intDocumentUsedId = intDocumentMaintenanceId
	FROM 
		[dbo].[fnARGetDefaultCommentTable](@intCompanyLocationId, @intEntityCustomerId, @strTransactionType, @strType, 'Header', @DocumentMaintenanceId, 1)

IF @intDocumentUsedId IS NOT NULL
BEGIN
	SELECT TOP 1 @strDocumentUsedCode = strCode,
		@strDocumentUsedTitle = strTitle FROM tblSMDocumentMaintenance 
		WHERE intDocumentMaintenanceId = @intDocumentUsedId
END

SET @strFooterComment = [dbo].[fnARGetDefaultComment](@intCompanyLocationId, @intEntityCustomerId, @strTransactionType, @strType, 'Footer', @DocumentMaintenanceId, 1)