CREATE FUNCTION [dbo].[fnARGetInvoiceFooterComment]
(
	@intCompanyLocationId	INT = NULL,
	@intEntityCustomerId	INT = NULL,
	@strTransactionType     NVARCHAR(50) = NULL,
	@strType                NVARCHAR(50) = NULL
)
RETURNS NVARCHAR(MAX) AS
BEGIN
	DECLARE @footerComment NVARCHAR(MAX) = NULL

	IF (@strTransactionType <> '' AND @strTransactionType IS NOT NULL)
		BEGIN
			SELECT TOP 1 @footerComment = strCommentDesc
			FROM tblARCommentMaintenance
			WHERE strTransactionType = @strTransactionType
			  AND intCompanyLocationId = @intCompanyLocationId
			  AND intEntityCustomerId = @intEntityCustomerId
			ORDER BY intCommentId DESC

			IF (@footerComment IS NULL)
				BEGIN
					SELECT TOP 1 @footerComment = strCommentDesc
					FROM tblARCommentMaintenance
					WHERE strTransactionType = @strTransactionType
					  AND ((@intCompanyLocationId IS NULL OR @intCompanyLocationId = 0) OR intCompanyLocationId = @intCompanyLocationId)
					  AND ((@intEntityCustomerId IS NULL OR @intEntityCustomerId = 0) OR intEntityCustomerId = @intEntityCustomerId)
					ORDER BY intCommentId DESC
				END

			IF (@footerComment IS NULL)
				BEGIN
					SELECT TOP 1 @footerComment = strCommentDesc
					FROM tblARCommentMaintenance
					WHERE strTransactionType = @strTransactionType
					  AND ((@intCompanyLocationId IS NULL OR @intCompanyLocationId = 0) OR intCompanyLocationId = @intCompanyLocationId)
					ORDER BY intCommentId DESC
				END

			IF (@footerComment IS NULL)
				BEGIN
					SELECT TOP 1 @footerComment = strCommentDesc
					FROM tblARCommentMaintenance
					WHERE strTransactionType = @strTransactionType
					ORDER BY intCommentId DESC
				END
		END

	RETURN @footerComment	
END