CREATE PROCEDURE [dbo].[uspARGetDefaultComment]
	@intCompanyLocationId	INT = NULL,
	@intEntityCustomerId	INT = NULL,
	@strTransactionType     NVARCHAR(50) = NULL,
	@strType                NVARCHAR(50) = NULL,
	@strDefaultComment		NVARCHAR(500) = NULL OUTPUT
AS

IF (@strTransactionType = '' OR @strTransactionType IS  NULL)
	BEGIN
		RETURN NULL
	END

--1. Filter by Transaction, Location, Customer, Type
SELECT TOP 1 @strDefaultComment = strCommentDesc
	FROM tblARCommentMaintenance
	WHERE strTransactionType = @strTransactionType
	AND intCompanyLocationId = @intCompanyLocationId
	AND intEntityCustomerId = @intEntityCustomerId
	AND strType = @strType
	AND strTransactionType <> 'Statement Footer'
ORDER BY intCommentId DESC

--2. Filter by Transaction, Location, Customer
IF @strDefaultComment IS NULL
	BEGIN
		SELECT TOP 1 @strDefaultComment = strCommentDesc
			FROM tblARCommentMaintenance
			WHERE strTransactionType = @strTransactionType
			AND intCompanyLocationId = @intCompanyLocationId
			AND intEntityCustomerId = @intEntityCustomerId
			AND strTransactionType <> 'Statement Footer'
		ORDER BY intCommentId DESC
	END
ELSE
	RETURN

--3. Filter by Transaction, Location, Type
IF @strDefaultComment IS NULL
	BEGIN
		SELECT TOP 1 @strDefaultComment = strCommentDesc
			FROM tblARCommentMaintenance
			WHERE strTransactionType = @strTransactionType
			AND intCompanyLocationId = @intCompanyLocationId
			AND strType = @strType
			AND strTransactionType <> 'Statement Footer'
		ORDER BY intCommentId DESC
	END
ELSE
	RETURN

--4. Filter by Transaction, Location
IF @strDefaultComment IS NULL
	BEGIN
		SELECT TOP 1 @strDefaultComment = strCommentDesc
			FROM tblARCommentMaintenance
			WHERE strTransactionType = @strTransactionType
			AND intCompanyLocationId = @intCompanyLocationId
			AND strTransactionType <> 'Statement Footer'
		ORDER BY intCommentId DESC
	END
ELSE
	RETURN

--5. Filter by Transaction, Customer, Type
IF @strDefaultComment IS NULL
	BEGIN
		SELECT TOP 1 @strDefaultComment = strCommentDesc
			FROM tblARCommentMaintenance
			WHERE strTransactionType = @strTransactionType
			AND intEntityCustomerId = @intEntityCustomerId
			AND strType = @strType
			AND strTransactionType <> 'Statement Footer'
		ORDER BY intCommentId DESC
	END
ELSE
	RETURN

--6. Filter by Transaction, Customer
IF @strDefaultComment IS NULL
	BEGIN
		SELECT TOP 1 @strDefaultComment = strCommentDesc
			FROM tblARCommentMaintenance
			WHERE strTransactionType = @strTransactionType	
			AND intEntityCustomerId = @intEntityCustomerId
			AND strTransactionType <> 'Statement Footer'
		ORDER BY intCommentId DESC
	END
ELSE
	RETURN

--7. Filter by Transaction, Type
IF @strDefaultComment IS NULL
	BEGIN
		SELECT TOP 1 @strDefaultComment = strCommentDesc
			FROM tblARCommentMaintenance
			WHERE strTransactionType = @strTransactionType		
			AND strType = @strType
			AND strTransactionType <> 'Statement Footer'
		ORDER BY intCommentId DESC
	END
ELSE
	RETURN

--8. Filter by Transaction
IF @strDefaultComment IS NULL
	BEGIN
		SELECT TOP 1 @strDefaultComment = strCommentDesc
			FROM tblARCommentMaintenance
			WHERE strTransactionType = @strTransactionType
			AND intEntityCustomerId IS NULL
			AND intCompanyLocationId IS NULL
			AND strTransactionType <> 'Statement Footer'
		ORDER BY intCommentId DESC
	END
ELSE
	RETURN

--9. No Hiearchy
IF @strDefaultComment IS NULL
	BEGIN
		SELECT TOP 1 @strDefaultComment = strCommentDesc
			FROM tblARCommentMaintenance
			WHERE strTransactionType IS NULL
		ORDER BY intCommentId DESC
	END
ELSE
	RETURN