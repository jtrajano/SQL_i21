CREATE FUNCTION [dbo].[fnARGetDefaultComment]
(
	@intCompanyLocationId	INT = NULL,
	@intEntityCustomerId	INT = NULL,
	@strTransactionType     NVARCHAR(50) = NULL,
	@strType                NVARCHAR(50) = NULL,
	@DocumentMaintenanceId	INT = NULL
)
RETURNS NVARCHAR(MAX) AS
BEGIN
	DECLARE @strDefaultComment NVARCHAR(MAX) = NULL

	IF (@strTransactionType = '' OR @strTransactionType IS  NULL)
	BEGIN
		RETURN @strDefaultComment
	END


IF (@DocumentMaintenanceId IS NOT NULL)
BEGIN
	--1. Filter by Transaction, Location, Customer, Type
	SELECT TOP 1 @strDefaultComment = B.strMessage --strMessageDesc
		FROM [tblSMDocumentMaintenance] A
		INNER JOIN (SELECT intDocumentMaintenanceId
						 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)))
					FROM tblSMDocumentMaintenanceMessage) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
		WHERE A.intDocumentMaintenanceId = @DocumentMaintenanceId
		AND [strSource] <> 'Statement Footer'
	ORDER BY A.[intDocumentMaintenanceId] DESC

	--2. Filter by Transaction, Location, Customer
	IF @strDefaultComment IS NULL
		BEGIN
			SELECT TOP 1 @strDefaultComment = B.strMessage --strMessageDesc
				FROM [tblSMDocumentMaintenance] A
				INNER JOIN (SELECT intDocumentMaintenanceId
								 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)))
							FROM tblSMDocumentMaintenanceMessage) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
				WHERE A.intDocumentMaintenanceId = @DocumentMaintenanceId
				AND [strSource] <> 'Statement Footer'
			ORDER BY A.[intDocumentMaintenanceId] DESC
		END
	ELSE
		RETURN @strDefaultComment

	--3. Filter by Transaction, Location, Type
	IF @strDefaultComment IS NULL
		BEGIN
			SELECT TOP 1 @strDefaultComment = B.strMessage --strMessageDesc
				FROM [tblSMDocumentMaintenance] A
				INNER JOIN (SELECT intDocumentMaintenanceId
								 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)))
							FROM tblSMDocumentMaintenanceMessage) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
				WHERE A.intDocumentMaintenanceId = @DocumentMaintenanceId
				AND [strSource] <> 'Statement Footer'
			ORDER BY A.[intDocumentMaintenanceId] DESC
		END
	ELSE
		RETURN @strDefaultComment

	--4. Filter by Transaction, Location
	IF @strDefaultComment IS NULL
		BEGIN
			SELECT TOP 1 @strDefaultComment = B.strMessage --strMessageDesc
				FROM [tblSMDocumentMaintenance] A
				INNER JOIN (SELECT intDocumentMaintenanceId
								 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)))
							FROM tblSMDocumentMaintenanceMessage) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
				WHERE A.intDocumentMaintenanceId = @DocumentMaintenanceId
				AND [strSource] <> 'Statement Footer'
			ORDER BY A.[intDocumentMaintenanceId] DESC
		END
	ELSE
		RETURN @strDefaultComment

	--5. Filter by Transaction, Customer, Type
	IF @strDefaultComment IS NULL
		BEGIN
			SELECT TOP 1 @strDefaultComment = B.strMessage--strMessageDesc
				FROM [tblSMDocumentMaintenance] A
				INNER JOIN (SELECT intDocumentMaintenanceId
								 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)))
							FROM tblSMDocumentMaintenanceMessage) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
				WHERE A.intDocumentMaintenanceId = @DocumentMaintenanceId
				AND [strSource] <> 'Statement Footer'
			ORDER BY A.[intDocumentMaintenanceId] DESC
		END
	ELSE
		RETURN @strDefaultComment

	--6. Filter by Transaction, Customer
	IF @strDefaultComment IS NULL
		BEGIN
			SELECT TOP 1 @strDefaultComment = B.strMessage --strMessageDesc
				FROM [tblSMDocumentMaintenance] A
				INNER JOIN (SELECT intDocumentMaintenanceId
								 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)))
							FROM tblSMDocumentMaintenanceMessage) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
				WHERE A.intDocumentMaintenanceId = @DocumentMaintenanceId
				AND [strSource] <> 'Statement Footer'
			ORDER BY A.[intDocumentMaintenanceId] DESC
		END
	ELSE
		RETURN @strDefaultComment

	--7. Filter by Transaction, Type
	IF @strDefaultComment IS NULL
		BEGIN
			SELECT TOP 1 @strDefaultComment = B.strMessage --strMessageDesc
				FROM [tblSMDocumentMaintenance] A
				INNER JOIN (SELECT intDocumentMaintenanceId
								 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)))
							FROM tblSMDocumentMaintenanceMessage) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
				WHERE A.intDocumentMaintenanceId = @DocumentMaintenanceId
				AND [strSource] <> 'Statement Footer'
			ORDER BY A.[intDocumentMaintenanceId] DESC
		END
	ELSE
		RETURN @strDefaultComment

	--8. Filter by Transaction
	IF @strDefaultComment IS NULL
		BEGIN
			SELECT TOP 1 @strDefaultComment = B.strMessage --strMessageDesc
				FROM [tblSMDocumentMaintenance] A
				INNER JOIN (SELECT intDocumentMaintenanceId
								 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)))
							FROM tblSMDocumentMaintenanceMessage) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
				WHERE A.intDocumentMaintenanceId = @DocumentMaintenanceId
				AND [strSource] <> 'Statement Footer'
			ORDER BY A.[intDocumentMaintenanceId] DESC
		END
	ELSE
		RETURN @strDefaultComment

	--9. No Hiearchy
	IF @strDefaultComment IS NULL
		BEGIN
			SELECT TOP 1 @strDefaultComment = B.strMessage --strMessageDesc
				FROM [tblSMDocumentMaintenance] A
				INNER JOIN (SELECT intDocumentMaintenanceId
								 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)))
							FROM tblSMDocumentMaintenanceMessage) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
				WHERE [strSource] IS NULL AND A.intDocumentMaintenanceId = @DocumentMaintenanceId
			ORDER BY A.[intDocumentMaintenanceId] DESC
		END
	ELSE
		RETURN @strDefaultComment
END

ELSE
BEGIN
	--1. Filter by Transaction, Location, Customer, Type
	SELECT TOP 1 @strDefaultComment = B.strMessage --strMessageDesc
		FROM [tblSMDocumentMaintenance] A
		INNER JOIN (SELECT intDocumentMaintenanceId
						 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)))
					FROM tblSMDocumentMaintenanceMessage) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
		WHERE [strSource] = @strTransactionType
		AND intCompanyLocationId = @intCompanyLocationId
		AND intEntityCustomerId = @intEntityCustomerId
		AND strType = @strType
		AND [strSource] <> 'Statement Footer'
	ORDER BY A.[intDocumentMaintenanceId] DESC

	--2. Filter by Transaction, Location, Customer
	IF @strDefaultComment IS NULL
		BEGIN
			SELECT TOP 1 @strDefaultComment = B.strMessage --strMessageDesc
				FROM [tblSMDocumentMaintenance] A
				INNER JOIN (SELECT intDocumentMaintenanceId
								 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)))
							FROM tblSMDocumentMaintenanceMessage) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
				WHERE [strSource] = @strTransactionType
				AND intCompanyLocationId = @intCompanyLocationId
				AND intEntityCustomerId = @intEntityCustomerId
				AND [strSource] <> 'Statement Footer'
			ORDER BY A.[intDocumentMaintenanceId] DESC
		END
	ELSE
		RETURN @strDefaultComment

	--3. Filter by Transaction, Location, Type
	IF @strDefaultComment IS NULL
		BEGIN
			SELECT TOP 1 @strDefaultComment = B.strMessage --strMessageDesc
				FROM [tblSMDocumentMaintenance] A
				INNER JOIN (SELECT intDocumentMaintenanceId
								 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)))
							FROM tblSMDocumentMaintenanceMessage) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
				WHERE [strSource] = @strTransactionType
				AND intCompanyLocationId = @intCompanyLocationId
				AND intEntityCustomerId IS NULL
				AND strType = @strType
				AND [strSource] <> 'Statement Footer'
			ORDER BY A.[intDocumentMaintenanceId] DESC
		END
	ELSE
		RETURN @strDefaultComment

	--4. Filter by Transaction, Location
	IF @strDefaultComment IS NULL
		BEGIN
			SELECT TOP 1 @strDefaultComment = B.strMessage --strMessageDesc
				FROM [tblSMDocumentMaintenance] A
				INNER JOIN (SELECT intDocumentMaintenanceId
								 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)))
							FROM tblSMDocumentMaintenanceMessage) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
				WHERE [strSource] = @strTransactionType
				AND intCompanyLocationId = @intCompanyLocationId
				AND intEntityCustomerId IS NULL
				AND [strSource] <> 'Statement Footer'
			ORDER BY A.[intDocumentMaintenanceId] DESC
		END
	ELSE
		RETURN @strDefaultComment

	--5. Filter by Transaction, Customer, Type
	IF @strDefaultComment IS NULL
		BEGIN
			SELECT TOP 1 @strDefaultComment = B.strMessage--strMessageDesc
				FROM [tblSMDocumentMaintenance] A
				INNER JOIN (SELECT intDocumentMaintenanceId
								 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)))
							FROM tblSMDocumentMaintenanceMessage) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
				WHERE [strSource] = @strTransactionType
				AND intCompanyLocationId IS NULL
				AND intEntityCustomerId = @intEntityCustomerId
				AND strType = @strType
				AND [strSource] <> 'Statement Footer'
			ORDER BY A.[intDocumentMaintenanceId] DESC
		END
	ELSE
		RETURN @strDefaultComment

	--6. Filter by Transaction, Customer
	IF @strDefaultComment IS NULL
		BEGIN
			SELECT TOP 1 @strDefaultComment = B.strMessage --strMessageDesc
				FROM [tblSMDocumentMaintenance] A
				INNER JOIN (SELECT intDocumentMaintenanceId
								 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)))
							FROM tblSMDocumentMaintenanceMessage) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
				WHERE [strSource] = @strTransactionType
				AND intCompanyLocationId IS NULL
				AND intEntityCustomerId = @intEntityCustomerId
				AND [strSource] <> 'Statement Footer'
			ORDER BY A.[intDocumentMaintenanceId] DESC
		END
	ELSE
		RETURN @strDefaultComment

	--7. Filter by Transaction, Type
	IF @strDefaultComment IS NULL
		BEGIN
			SELECT TOP 1 @strDefaultComment = B.strMessage --strMessageDesc
				FROM [tblSMDocumentMaintenance] A
				INNER JOIN (SELECT intDocumentMaintenanceId
								 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)))
							FROM tblSMDocumentMaintenanceMessage) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
				WHERE [strSource] = @strTransactionType
				AND intCompanyLocationId IS NULL
				AND intEntityCustomerId IS NULL		
				AND strType = @strType
				AND [strSource] <> 'Statement Footer'
			ORDER BY A.[intDocumentMaintenanceId] DESC
		END
	ELSE
		RETURN @strDefaultComment

	--8. Filter by Transaction
	IF @strDefaultComment IS NULL
		BEGIN
			SELECT TOP 1 @strDefaultComment = B.strMessage --strMessageDesc
				FROM [tblSMDocumentMaintenance] A
				INNER JOIN (SELECT intDocumentMaintenanceId
								 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)))
							FROM tblSMDocumentMaintenanceMessage) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
				WHERE [strSource] = @strTransactionType
				AND intCompanyLocationId IS NULL
				AND intEntityCustomerId IS NULL		
				AND [strSource] <> 'Statement Footer'
			ORDER BY A.[intDocumentMaintenanceId] DESC
		END
	ELSE
		RETURN @strDefaultComment

	--9. No Hiearchy
	IF @strDefaultComment IS NULL
		BEGIN
			SELECT TOP 1 @strDefaultComment = B.strMessage --strMessageDesc
				FROM [tblSMDocumentMaintenance] A
				INNER JOIN (SELECT intDocumentMaintenanceId
								 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)))
							FROM tblSMDocumentMaintenanceMessage) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
				WHERE [strSource] IS NULL
			ORDER BY A.[intDocumentMaintenanceId] DESC
		END
	ELSE
		RETURN @strDefaultComment

END

RETURN @strDefaultComment
	
END