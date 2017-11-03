CREATE PROCEDURE [dbo].[uspARGetDefaultComment]
	@intCompanyLocationId	INT = NULL,
	@intEntityCustomerId	INT = NULL,
	@strTransactionType     NVARCHAR(50) = NULL,
	@strType                NVARCHAR(50) = NULL,
	@strHeaderComment		NVARCHAR(500) = NULL OUTPUT,
	@strFooterComment		NVARCHAR(500) = NULL OUTPUT,
	@DocumentMaintenanceId	INT = NULL
AS

SET @strHeaderComment = [dbo].[fnARGetDefaultComment](@intCompanyLocationId, @intEntityCustomerId, @strTransactionType, @strType, 'Header', @DocumentMaintenanceId, 0)
SET @strFooterComment = [dbo].[fnARGetDefaultComment](@intCompanyLocationId, @intEntityCustomerId, @strTransactionType, NULL, 'Footer', @DocumentMaintenanceId, 0)