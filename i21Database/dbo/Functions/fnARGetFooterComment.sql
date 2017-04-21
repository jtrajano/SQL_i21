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
			SELECT TOP 1 @footerComment = B.strMessage --strCommentDesc
			FROM [tblSMDocumentMaintenance] A
			INNER JOIN (SELECT intDocumentMaintenanceId
							 , strHeaderFooter
						     , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)))
						FROM tblSMDocumentMaintenanceMessage
						WHERE strHeaderFooter = 'Footer') B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
			WHERE strSource = @strTransactionType
				AND intCompanyLocationId = @intCompanyLocationId
				AND intEntityCustomerId = @intEntityCustomerId
			ORDER BY A.intDocumentMaintenanceId DESC

			IF (@footerComment IS NULL)
				BEGIN
					SELECT TOP 1 @footerComment = B.strMessage --strCommentDesc
					FROM [tblSMDocumentMaintenance] A
					INNER JOIN (SELECT intDocumentMaintenanceId
									 , strHeaderFooter
									 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)))
								FROM tblSMDocumentMaintenanceMessage
								WHERE strHeaderFooter = 'Footer') B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
					WHERE strSource = @strTransactionType
					  AND intCompanyLocationId = @intCompanyLocationId
					  AND intEntityCustomerId IS NULL
					ORDER BY A.intDocumentMaintenanceId DESC
				END

			IF (@footerComment IS NULL)
				BEGIN
					SELECT TOP 1 @footerComment = B.strMessage --strCommentDesc
					FROM [tblSMDocumentMaintenance]	A
					INNER JOIN (SELECT intDocumentMaintenanceId
									 , strHeaderFooter 
									 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)))
								FROM tblSMDocumentMaintenanceMessage
								WHERE strHeaderFooter = 'Footer') B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
					WHERE strSource = @strTransactionType
					  AND intCompanyLocationId IS NULL
					  AND intEntityCustomerId = @intEntityCustomerId
					ORDER BY A.intDocumentMaintenanceId DESC
				END

			IF (@footerComment IS NULL)
				BEGIN
					SELECT TOP 1 @footerComment = B.strMessage--strCommentDesc
					FROM [tblSMDocumentMaintenance] A
					INNER JOIN (SELECT intDocumentMaintenanceId
									 , strHeaderFooter
									 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)))
								FROM tblSMDocumentMaintenanceMessage
								WHERE strHeaderFooter = 'Footer') B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
					WHERE strSource = @strTransactionType
					  AND intCompanyLocationId IS NULL
					  AND intEntityCustomerId IS NULL
					ORDER BY A.intDocumentMaintenanceId DESC
				END
		END

	RETURN @footerComment	
END