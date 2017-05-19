CREATE PROCEDURE [dbo].[uspARGetDefaultComment]
	@intCompanyLocationId	INT = NULL,
	@intEntityCustomerId	INT = NULL,
	@strTransactionType     NVARCHAR(50) = NULL,
	@strType                NVARCHAR(50) = NULL,
	@strDefaultComment		NVARCHAR(500) = NULL OUTPUT,
	@DocumentMaintenanceId	INT = NULL
AS


SET @strDefaultComment = [dbo].[fnARGetDefaultComment](@intCompanyLocationId, @intEntityCustomerId, @strTransactionType, @strType, @DocumentMaintenanceId)


