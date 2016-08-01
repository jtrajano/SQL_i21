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
			SELECT TOP 1 @footerComment = B.strComment --strCommentDesc
			FROM [tblSMCommentMaintenance] A
			INNER JOIN (SELECT intCommentMaintenanceId, strComment 
						FROM tblSMCommentMaintenanceComment) B ON A.intCommentMaintenanceId = B.intCommentMaintenanceId
			WHERE [strSource] = @strTransactionType
				AND intCompanyLocationId = @intCompanyLocationId
				AND intEntityCustomerId = @intEntityCustomerId
			ORDER BY A.[intCommentMaintenanceId] DESC

			IF (@footerComment IS NULL)
				BEGIN
					SELECT TOP 1 @footerComment = B.strComment --strCommentDesc
					FROM [tblSMCommentMaintenance] A
					INNER JOIN (SELECT intCommentMaintenanceId, strComment 
								FROM tblSMCommentMaintenanceComment) B ON A.intCommentMaintenanceId = B.intCommentMaintenanceId
					WHERE [strSource] = @strTransactionType
					  AND intCompanyLocationId = @intCompanyLocationId
					  AND intEntityCustomerId IS NULL
					ORDER BY A.[intCommentMaintenanceId] DESC
				END

			IF (@footerComment IS NULL)
				BEGIN
					SELECT TOP 1 @footerComment = B.strComment --strCommentDesc
					FROM [tblSMCommentMaintenance]	A
					INNER JOIN (SELECT intCommentMaintenanceId, strComment 
								FROM tblSMCommentMaintenanceComment) B ON A.intCommentMaintenanceId = B.intCommentMaintenanceId
					WHERE [strSource] = @strTransactionType
					  AND intCompanyLocationId IS NULL
					  AND intEntityCustomerId = @intEntityCustomerId
					ORDER BY A.[intCommentMaintenanceId] DESC
				END

			IF (@footerComment IS NULL)
				BEGIN
					SELECT TOP 1 @footerComment = B.strComment--strCommentDesc
					FROM [tblSMCommentMaintenance] A
					INNER JOIN (SELECT intCommentMaintenanceId, strComment 
								FROM tblSMCommentMaintenanceComment) B ON A.intCommentMaintenanceId = B.intCommentMaintenanceId
					WHERE [strSource] = @strTransactionType
					  AND intCompanyLocationId IS NULL
					  AND intEntityCustomerId IS NULL
					ORDER BY A.[intCommentMaintenanceId] DESC
				END
		END

	RETURN @footerComment	
END