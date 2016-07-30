CREATE FUNCTION [dbo].[fnARGetFooterComment]
(
	@intCompanyLocationId	INT = NULL,
	@intEntityCustomerId	INT = NULL,
	@strTransactionType     NVARCHAR(50) = NULL
)
RETURNS NVARCHAR(MAX) AS
BEGIN
	DECLARE @footerComment NVARCHAR(MAX) = NULL

	IF (@strTransactionType <> '' AND @strTransactionType IS NOT NULL)
		BEGIN
			SELECT TOP 1 @footerComment = ''--strCommentDesc
			FROM [tblSMCommentMaintenance]
			WHERE [strSource] = @strTransactionType
			  AND intCompanyLocationId = @intCompanyLocationId
			  AND intEntityCustomerId = @intEntityCustomerId
			ORDER BY [intCommentMaintenanceId] DESC

			IF (@footerComment IS NULL)
				BEGIN
					SELECT TOP 1 @footerComment = ''--strCommentDesc
					FROM [tblSMCommentMaintenance]
					WHERE [strSource] = @strTransactionType
					  AND intCompanyLocationId = @intCompanyLocationId
					  AND intEntityCustomerId IS NULL
					ORDER BY [intCommentMaintenanceId] DESC
				END

			IF (@footerComment IS NULL)
				BEGIN
					SELECT TOP 1 @footerComment = ''--strCommentDesc
					FROM [tblSMCommentMaintenance]
					WHERE [strSource] = @strTransactionType
					  AND intCompanyLocationId IS NULL
					  AND intEntityCustomerId = @intEntityCustomerId
					ORDER BY [intCommentMaintenanceId] DESC
				END

			IF (@footerComment IS NULL)
				BEGIN
					SELECT TOP 1 @footerComment = ''--strCommentDesc
					FROM [tblSMCommentMaintenance]
					WHERE [strSource] = @strTransactionType
					  AND intCompanyLocationId IS NULL
					  AND intEntityCustomerId IS NULL
					ORDER BY [intCommentMaintenanceId] DESC
				END
		END

	RETURN @footerComment	
END