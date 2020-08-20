CREATE FUNCTION [dbo].[fnARGetDefaultCommentTable]
(
	@intCompanyLocationId	INT = NULL,
	@intEntityCustomerId	INT = NULL,
	@strTransactionType     NVARCHAR(50) = NULL,
	@strType                NVARCHAR(50) = NULL,
	@strHeaderFooter		NVARCHAR(50) = NULL,
	@DocumentMaintenanceId	INT = NULL,
	@ysnPrintAsHTML			BIT = 0
)
RETURNS @returntable TABLE
(
	strDefaultComment NVARCHAR(MAX) NULL,
	intDocumentMaintenanceId INT NULL
)
AS
BEGIN
	DECLARE @strDefaultComment NVARCHAR(MAX) = NULL
	DECLARE @intDocumentMaintenanceId INT = NULL

	IF (@strTransactionType = '' OR @strTransactionType IS  NULL)
	BEGIN
		INSERT INTO @returntable(strDefaultComment, intDocumentMaintenanceId)
		VALUES( @strDefaultComment, @intDocumentMaintenanceId)
		RETURN
	END


IF (@DocumentMaintenanceId IS NOT NULL)
BEGIN
	--1. Filter by Transaction, Location, Customer, Type
	SELECT TOP 1 @strDefaultComment = B.strMessage --strMessageDesc
			,@intDocumentMaintenanceId = A.intDocumentMaintenanceId
		FROM [tblSMDocumentMaintenance] A
		INNER JOIN (SELECT intDocumentMaintenanceId
						 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)), @ysnPrintAsHTML)
					FROM tblSMDocumentMaintenanceMessage
					WHERE strHeaderFooter = @strHeaderFooter) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
		WHERE A.intDocumentMaintenanceId = @DocumentMaintenanceId
	ORDER BY A.[intDocumentMaintenanceId] DESC
			, ISNULL(A.intEntityCustomerId, -10 * A.intDocumentMaintenanceId) DESC
			, ISNULL(A.intCompanyLocationId, -100 * A.intDocumentMaintenanceId) DESC

	--2. Filter by Transaction, Location, Customer
	IF @strDefaultComment IS NULL
		BEGIN
			SELECT TOP 1 @strDefaultComment = B.strMessage --strMessageDesc
			,@intDocumentMaintenanceId = A.intDocumentMaintenanceId
				FROM [tblSMDocumentMaintenance] A
				INNER JOIN (SELECT intDocumentMaintenanceId
								 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)), @ysnPrintAsHTML)
							FROM tblSMDocumentMaintenanceMessage
							WHERE strHeaderFooter = @strHeaderFooter) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
				WHERE A.intDocumentMaintenanceId = @DocumentMaintenanceId
			ORDER BY A.[intDocumentMaintenanceId] DESC
				, ISNULL(A.intEntityCustomerId, -10 * A.intDocumentMaintenanceId) DESC
				, ISNULL(A.intCompanyLocationId, -100 * A.intDocumentMaintenanceId) DESC
		END
	ELSE
	BEGIN
		INSERT INTO @returntable(strDefaultComment, intDocumentMaintenanceId)
		VALUES( @strDefaultComment, @intDocumentMaintenanceId)
		RETURN
	END

	--3. Filter by Transaction, Location, Type
	IF @strDefaultComment IS NULL
		BEGIN
			SELECT TOP 1 @strDefaultComment = B.strMessage --strMessageDesc
					,@intDocumentMaintenanceId = A.intDocumentMaintenanceId
				FROM [tblSMDocumentMaintenance] A
				INNER JOIN (SELECT intDocumentMaintenanceId
								 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)), @ysnPrintAsHTML)
							FROM tblSMDocumentMaintenanceMessage
							WHERE strHeaderFooter = @strHeaderFooter) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
				WHERE A.intDocumentMaintenanceId = @DocumentMaintenanceId
			ORDER BY A.[intDocumentMaintenanceId] DESC
				, ISNULL(A.intEntityCustomerId, -10 * A.intDocumentMaintenanceId) DESC
				, ISNULL(A.intCompanyLocationId, -100 * A.intDocumentMaintenanceId) DESC
		END
	ELSE
	BEGIN
		INSERT INTO @returntable(strDefaultComment, intDocumentMaintenanceId)
		VALUES( @strDefaultComment, @intDocumentMaintenanceId)
		RETURN
	END

	--4. Filter by Transaction, Location
	IF @strDefaultComment IS NULL
		BEGIN
			SELECT TOP 1 @strDefaultComment = B.strMessage --strMessageDesc
				,@intDocumentMaintenanceId = A.intDocumentMaintenanceId
				FROM [tblSMDocumentMaintenance] A
				INNER JOIN (SELECT intDocumentMaintenanceId
								 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)), @ysnPrintAsHTML)
							FROM tblSMDocumentMaintenanceMessage
							WHERE strHeaderFooter = @strHeaderFooter) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
				WHERE A.intDocumentMaintenanceId = @DocumentMaintenanceId
			ORDER BY A.[intDocumentMaintenanceId] DESC
				, ISNULL(A.intEntityCustomerId, -10 * A.intDocumentMaintenanceId) DESC
				, ISNULL(A.intCompanyLocationId, -100 * A.intDocumentMaintenanceId) DESC
		END
	ELSE
	BEGIN
		INSERT INTO @returntable(strDefaultComment, intDocumentMaintenanceId)
		VALUES( @strDefaultComment, @intDocumentMaintenanceId)
		RETURN
	END

	--5. Filter by Transaction, Customer, Type
	IF @strDefaultComment IS NULL
		BEGIN
			SELECT TOP 1 @strDefaultComment = B.strMessage--strMessageDesc
				,@intDocumentMaintenanceId = A.intDocumentMaintenanceId
				FROM [tblSMDocumentMaintenance] A
				INNER JOIN (SELECT intDocumentMaintenanceId
								 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)), @ysnPrintAsHTML)
							FROM tblSMDocumentMaintenanceMessage
							WHERE strHeaderFooter = @strHeaderFooter) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
				WHERE A.intDocumentMaintenanceId = @DocumentMaintenanceId
			ORDER BY A.[intDocumentMaintenanceId] DESC
				, ISNULL(A.intEntityCustomerId, -10 * A.intDocumentMaintenanceId) DESC
				, ISNULL(A.intCompanyLocationId, -100 * A.intDocumentMaintenanceId) DESC
		END
	ELSE
	BEGIN
		INSERT INTO @returntable(strDefaultComment, intDocumentMaintenanceId)
		VALUES( @strDefaultComment, @intDocumentMaintenanceId)
		RETURN
	END

	--6. Filter by Transaction, Customer
	IF @strDefaultComment IS NULL
		BEGIN
			SELECT TOP 1 @strDefaultComment = B.strMessage --strMessageDesc
				,@intDocumentMaintenanceId = A.intDocumentMaintenanceId
				FROM [tblSMDocumentMaintenance] A
				INNER JOIN (SELECT intDocumentMaintenanceId
								 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)), @ysnPrintAsHTML)
							FROM tblSMDocumentMaintenanceMessage
							WHERE strHeaderFooter = @strHeaderFooter) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
				WHERE A.intDocumentMaintenanceId = @DocumentMaintenanceId
			ORDER BY A.[intDocumentMaintenanceId] DESC
				, ISNULL(A.intEntityCustomerId, -10 * A.intDocumentMaintenanceId) DESC
				, ISNULL(A.intCompanyLocationId, -100 * A.intDocumentMaintenanceId) DESC
		END
	ELSE
	BEGIN
		INSERT INTO @returntable(strDefaultComment, intDocumentMaintenanceId)
		VALUES( @strDefaultComment, @intDocumentMaintenanceId)
		RETURN
	END

	--7. Filter by Transaction, Type
	IF @strDefaultComment IS NULL
		BEGIN
			SELECT TOP 1 @strDefaultComment = B.strMessage --strMessageDesc
				,@intDocumentMaintenanceId = A.intDocumentMaintenanceId
				FROM [tblSMDocumentMaintenance] A
				INNER JOIN (SELECT intDocumentMaintenanceId
								 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)), @ysnPrintAsHTML)
							FROM tblSMDocumentMaintenanceMessage
							WHERE strHeaderFooter = @strHeaderFooter) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
				WHERE A.intDocumentMaintenanceId = @DocumentMaintenanceId
			ORDER BY A.[intDocumentMaintenanceId] DESC
				, ISNULL(A.intEntityCustomerId, -10 * A.intDocumentMaintenanceId) DESC
				, ISNULL(A.intCompanyLocationId, -100 * A.intDocumentMaintenanceId) DESC
		END
	ELSE
	BEGIN
		INSERT INTO @returntable(strDefaultComment, intDocumentMaintenanceId)
		VALUES( @strDefaultComment, @intDocumentMaintenanceId)
		RETURN
	END

	--8. Filter by Transaction
	IF @strDefaultComment IS NULL
		BEGIN
			SELECT TOP 1 @strDefaultComment = B.strMessage --strMessageDesc
				,@intDocumentMaintenanceId = A.intDocumentMaintenanceId
				FROM [tblSMDocumentMaintenance] A
				INNER JOIN (SELECT intDocumentMaintenanceId
								 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)), @ysnPrintAsHTML)
							FROM tblSMDocumentMaintenanceMessage
							WHERE strHeaderFooter = @strHeaderFooter) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
				WHERE A.intDocumentMaintenanceId = @DocumentMaintenanceId
			ORDER BY A.[intDocumentMaintenanceId] DESC
				, ISNULL(A.intEntityCustomerId, -10 * A.intDocumentMaintenanceId) DESC
				, ISNULL(A.intCompanyLocationId, -100 * A.intDocumentMaintenanceId) DESC
		END
	ELSE
	BEGIN
		INSERT INTO @returntable(strDefaultComment, intDocumentMaintenanceId)
		VALUES( @strDefaultComment, @intDocumentMaintenanceId)
		RETURN
	END

	--9. No Hiearchy
	IF @strDefaultComment IS NULL
		BEGIN
			SELECT TOP 1 @strDefaultComment = B.strMessage --strMessageDesc
				,@intDocumentMaintenanceId = A.intDocumentMaintenanceId
				FROM [tblSMDocumentMaintenance] A
				INNER JOIN (SELECT intDocumentMaintenanceId
								 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)), @ysnPrintAsHTML)
							FROM tblSMDocumentMaintenanceMessage
							WHERE strHeaderFooter = @strHeaderFooter) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
				WHERE [strSource] IS NULL AND A.intDocumentMaintenanceId = @DocumentMaintenanceId
			ORDER BY A.[intDocumentMaintenanceId] DESC
				, ISNULL(A.intEntityCustomerId, -10 * A.intDocumentMaintenanceId) DESC
				, ISNULL(A.intCompanyLocationId, -100 * A.intDocumentMaintenanceId) DESC
		END
	ELSE
	BEGIN
		INSERT INTO @returntable(strDefaultComment, intDocumentMaintenanceId)
		VALUES( @strDefaultComment, @intDocumentMaintenanceId)
		RETURN
	END
END

ELSE
BEGIN
	--1. Filter by Transaction, Location, Customer, Type
	SELECT TOP 1 @strDefaultComment = B.strMessage --strMessageDesc
			,@intDocumentMaintenanceId = A.intDocumentMaintenanceId
		FROM [tblSMDocumentMaintenance] A
		INNER JOIN (SELECT intDocumentMaintenanceId
						 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)), @ysnPrintAsHTML)
					FROM tblSMDocumentMaintenanceMessage
					WHERE strHeaderFooter = @strHeaderFooter) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
		WHERE [strSource] = @strTransactionType
		AND intCompanyLocationId = @intCompanyLocationId
		AND intEntityCustomerId = @intEntityCustomerId
		AND strType = @strType
	ORDER BY A.[intDocumentMaintenanceId] DESC
			, ISNULL(A.intEntityCustomerId, -10 * A.intDocumentMaintenanceId) DESC
			, ISNULL(A.intCompanyLocationId, -100 * A.intDocumentMaintenanceId) DESC

	--2. Filter by Transaction, Location, Customer
	IF @strDefaultComment IS NULL
		BEGIN
			SELECT TOP 1 @strDefaultComment = B.strMessage --strMessageDesc
				,@intDocumentMaintenanceId = A.intDocumentMaintenanceId
				FROM [tblSMDocumentMaintenance] A
				INNER JOIN (SELECT intDocumentMaintenanceId
								 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)), @ysnPrintAsHTML)
							FROM tblSMDocumentMaintenanceMessage
							WHERE strHeaderFooter = @strHeaderFooter) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
				WHERE [strSource] = @strTransactionType
				AND intCompanyLocationId = @intCompanyLocationId
				AND intEntityCustomerId = @intEntityCustomerId
			ORDER BY A.[intDocumentMaintenanceId] DESC
				, ISNULL(A.intEntityCustomerId, -10 * A.intDocumentMaintenanceId) DESC
				, ISNULL(A.intCompanyLocationId, -100 * A.intDocumentMaintenanceId) DESC
		END
	ELSE
	BEGIN
		INSERT INTO @returntable(strDefaultComment, intDocumentMaintenanceId)
		VALUES( @strDefaultComment, @intDocumentMaintenanceId)
		RETURN
	END

	--3. Filter by Transaction, Location, Type
	IF @strDefaultComment IS NULL
		BEGIN
			SELECT TOP 1 @strDefaultComment = B.strMessage --strMessageDesc
				,@intDocumentMaintenanceId = A.intDocumentMaintenanceId
				FROM [tblSMDocumentMaintenance] A
				INNER JOIN (SELECT intDocumentMaintenanceId
								 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)), @ysnPrintAsHTML)
							FROM tblSMDocumentMaintenanceMessage
							WHERE strHeaderFooter = @strHeaderFooter) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
				WHERE [strSource] = @strTransactionType
				AND intCompanyLocationId = @intCompanyLocationId
				AND intEntityCustomerId IS NULL
				AND strType = @strType
			ORDER BY A.[intDocumentMaintenanceId] DESC
				, ISNULL(A.intEntityCustomerId, -10 * A.intDocumentMaintenanceId) DESC
				, ISNULL(A.intCompanyLocationId, -100 * A.intDocumentMaintenanceId) DESC
		END
	ELSE
	BEGIN
		INSERT INTO @returntable(strDefaultComment, intDocumentMaintenanceId)
		VALUES( @strDefaultComment, @intDocumentMaintenanceId)
		RETURN
	END

	--4. Filter by Transaction, Location
	IF @strDefaultComment IS NULL
		BEGIN
			SELECT TOP 1 @strDefaultComment = B.strMessage --strMessageDesc
				,@intDocumentMaintenanceId = A.intDocumentMaintenanceId
				FROM [tblSMDocumentMaintenance] A
				INNER JOIN (SELECT intDocumentMaintenanceId
								 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)), @ysnPrintAsHTML)
							FROM tblSMDocumentMaintenanceMessage
							WHERE strHeaderFooter = @strHeaderFooter) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
				WHERE [strSource] = @strTransactionType
				AND intCompanyLocationId = @intCompanyLocationId
				AND intEntityCustomerId IS NULL
			ORDER BY A.[intDocumentMaintenanceId] DESC
				, ISNULL(A.intEntityCustomerId, -10 * A.intDocumentMaintenanceId) DESC
				, ISNULL(A.intCompanyLocationId, -100 * A.intDocumentMaintenanceId) DESC
		END
	ELSE
	BEGIN
		INSERT INTO @returntable(strDefaultComment, intDocumentMaintenanceId)
		VALUES( @strDefaultComment, @intDocumentMaintenanceId)
		RETURN
	END

	--5. Filter by Transaction, Customer, Type
	IF @strDefaultComment IS NULL
		BEGIN
			SELECT TOP 1 @strDefaultComment = B.strMessage--strMessageDesc
				,@intDocumentMaintenanceId = A.intDocumentMaintenanceId
				FROM [tblSMDocumentMaintenance] A
				INNER JOIN (SELECT intDocumentMaintenanceId
								 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)), @ysnPrintAsHTML)
							FROM tblSMDocumentMaintenanceMessage
							WHERE strHeaderFooter = @strHeaderFooter) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
				WHERE [strSource] = @strTransactionType
				AND intCompanyLocationId IS NULL
				AND intEntityCustomerId = @intEntityCustomerId
				AND strType = @strType
			ORDER BY A.[intDocumentMaintenanceId] DESC
				, ISNULL(A.intEntityCustomerId, -10 * A.intDocumentMaintenanceId) DESC
				, ISNULL(A.intCompanyLocationId, -100 * A.intDocumentMaintenanceId) DESC
		END
	ELSE
	BEGIN
		INSERT INTO @returntable(strDefaultComment, intDocumentMaintenanceId)
		VALUES( @strDefaultComment, @intDocumentMaintenanceId)
		RETURN
	END

	--6. Filter by Transaction, Customer
	IF @strDefaultComment IS NULL
		BEGIN
			SELECT TOP 1 @strDefaultComment = B.strMessage --strMessageDesc
				,@intDocumentMaintenanceId = A.intDocumentMaintenanceId
				FROM [tblSMDocumentMaintenance] A
				INNER JOIN (SELECT intDocumentMaintenanceId
								 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)), @ysnPrintAsHTML)
							FROM tblSMDocumentMaintenanceMessage
							WHERE strHeaderFooter = @strHeaderFooter) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
				WHERE [strSource] = @strTransactionType
				AND intCompanyLocationId IS NULL
				AND intEntityCustomerId = @intEntityCustomerId
			ORDER BY A.[intDocumentMaintenanceId] DESC
				, ISNULL(A.intEntityCustomerId, -10 * A.intDocumentMaintenanceId) DESC
				, ISNULL(A.intCompanyLocationId, -100 * A.intDocumentMaintenanceId) DESC
		END
	ELSE
	BEGIN
		INSERT INTO @returntable(strDefaultComment, intDocumentMaintenanceId)
		VALUES( @strDefaultComment, @intDocumentMaintenanceId)
		RETURN
	END

	--7. Filter by Transaction, Type
	IF @strDefaultComment IS NULL
		BEGIN
			SELECT TOP 1 @strDefaultComment = B.strMessage --strMessageDesc
				,@intDocumentMaintenanceId = A.intDocumentMaintenanceId
				FROM [tblSMDocumentMaintenance] A
				INNER JOIN (SELECT intDocumentMaintenanceId
								 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)), @ysnPrintAsHTML)
							FROM tblSMDocumentMaintenanceMessage
							WHERE strHeaderFooter = @strHeaderFooter) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
				WHERE [strSource] = @strTransactionType
				AND intCompanyLocationId IS NULL
				AND intEntityCustomerId IS NULL		
				AND strType = @strType
			ORDER BY A.[intDocumentMaintenanceId] DESC
				, ISNULL(A.intEntityCustomerId, -10 * A.intDocumentMaintenanceId) DESC
				, ISNULL(A.intCompanyLocationId, -100 * A.intDocumentMaintenanceId) DESC
		END
	ELSE
	BEGIN
		INSERT INTO @returntable(strDefaultComment, intDocumentMaintenanceId)
		VALUES( @strDefaultComment, @intDocumentMaintenanceId)
		RETURN
	END

	--8. Filter by Transaction
	IF @strDefaultComment IS NULL
		BEGIN
			SELECT TOP 1 @strDefaultComment = B.strMessage --strMessageDesc
				,@intDocumentMaintenanceId = A.intDocumentMaintenanceId
				FROM [tblSMDocumentMaintenance] A
				INNER JOIN (SELECT intDocumentMaintenanceId
								 , strMessage = dbo.fnEliminateHTMLTags(CAST(blbMessage AS VARCHAR(MAX)), @ysnPrintAsHTML)
							FROM tblSMDocumentMaintenanceMessage
							WHERE strHeaderFooter = @strHeaderFooter) B ON A.intDocumentMaintenanceId = B.intDocumentMaintenanceId
				WHERE [strSource] = @strTransactionType AND A.strType=@strType
				AND intCompanyLocationId IS NULL
				AND intEntityCustomerId IS NULL		
			ORDER BY A.[intDocumentMaintenanceId] DESC
				, ISNULL(A.intEntityCustomerId, -10 * A.intDocumentMaintenanceId) DESC
				, ISNULL(A.intCompanyLocationId, -100 * A.intDocumentMaintenanceId) DESC
		END
	ELSE
	BEGIN
		INSERT INTO @returntable(strDefaultComment, intDocumentMaintenanceId)
		VALUES( @strDefaultComment, @intDocumentMaintenanceId)
		RETURN
	END

	IF @strDefaultComment IS NOT NULL	
	BEGIN
		INSERT INTO @returntable(strDefaultComment, intDocumentMaintenanceId)
		VALUES( @strDefaultComment, @intDocumentMaintenanceId)
		RETURN
	END


END
	
	RETURN
END