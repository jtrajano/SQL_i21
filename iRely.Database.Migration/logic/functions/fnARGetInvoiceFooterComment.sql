--liquibase formatted sql

-- changeset Von:fnARGetInvoiceFooterComment.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnARGetInvoiceFooterComment]
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
					  AND intCompanyLocationId = @intCompanyLocationId
					  AND intEntityCustomerId IS NULL
					ORDER BY intCommentId DESC
				END

			IF (@footerComment IS NULL)
				BEGIN
					SELECT TOP 1 @footerComment = strCommentDesc
					FROM tblARCommentMaintenance
					WHERE strTransactionType = @strTransactionType
					  AND intCompanyLocationId IS NULL
					  AND intEntityCustomerId = @intEntityCustomerId
					ORDER BY intCommentId DESC
				END

			IF (@footerComment IS NULL)
				BEGIN
					SELECT TOP 1 @footerComment = strCommentDesc
					FROM tblARCommentMaintenance
					WHERE strTransactionType = @strTransactionType
					  AND intCompanyLocationId IS NULL
					  AND intEntityCustomerId IS NULL
					ORDER BY intCommentId DESC
				END
		END

	RETURN @footerComment	
END



