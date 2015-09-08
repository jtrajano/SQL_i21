CREATE PROCEDURE [dbo].[uspARGetDefaultComment]
	@intCompanyLocationId	INT = NULL,
	@intEntityCustomerId	INT = NULL,
	@strTransactionType     NVARCHAR(50) = NULL,
	@strType                NVARCHAR(50) = NULL,
	@strDefaultComment		NVARCHAR(250) = NULL OUTPUT
AS

--1. Filter by Transaction, Location, Customer, Type
SELECT TOP 1 @strDefaultComment = strCommentDesc
	FROM tblARCommentMaintenance
	WHERE ((@strTransactionType IS NULL OR @strTransactionType = '') OR strTransactionType = @strTransactionType)
	AND ((@intCompanyLocationId IS NULL OR @intCompanyLocationId = 0) OR intCompanyLocationId = @intCompanyLocationId)
	AND ((@intEntityCustomerId IS NULL OR @intEntityCustomerId = 0) OR intEntityCustomerId = @intEntityCustomerId)	
	AND ((@strType IS NULL OR @strType = '') OR strType = @strType)
ORDER BY intCommentId DESC

--2. Filter by Transaction, Location, Customer
IF @strDefaultComment IS NULL OR @strDefaultComment = ''
	BEGIN
		SELECT TOP 1 @strDefaultComment = strCommentDesc
			FROM tblARCommentMaintenance
			WHERE ((@strTransactionType IS NULL OR @strTransactionType = '') OR strTransactionType = @strTransactionType)
			AND ((@intCompanyLocationId IS NULL OR @intCompanyLocationId = 0) OR intCompanyLocationId = @intCompanyLocationId)
			AND ((@intEntityCustomerId IS NULL OR @intEntityCustomerId = 0) OR intEntityCustomerId = @intEntityCustomerId)	
		ORDER BY intCommentId DESC
	END
ELSE
	RETURN

--3. Filter by Transaction, Location, Type
IF @strDefaultComment IS NULL OR @strDefaultComment = ''
	BEGIN
		SELECT TOP 1 @strDefaultComment = strCommentDesc
			FROM tblARCommentMaintenance
			WHERE ((@strTransactionType IS NULL OR @strTransactionType = '') OR strTransactionType = @strTransactionType)
			AND ((@intCompanyLocationId IS NULL OR @intCompanyLocationId = 0) OR intCompanyLocationId = @intCompanyLocationId)
			AND ((@strType IS NULL OR @strType = '') OR strType = @strType)
		ORDER BY intCommentId DESC
	END
ELSE
	RETURN
	
--4. Filter by Transaction, Customer, Type
IF @strDefaultComment IS NULL OR @strDefaultComment = ''
	BEGIN
		SELECT TOP 1 @strDefaultComment = strCommentDesc
			FROM tblARCommentMaintenance
			WHERE ((@strTransactionType IS NULL OR @strTransactionType = '') OR strTransactionType = @strTransactionType)			
			AND ((@intEntityCustomerId IS NULL OR @intEntityCustomerId = 0) OR intEntityCustomerId = @intEntityCustomerId)	
			AND ((@strType IS NULL OR @strType = '') OR strType = @strType)
		ORDER BY intCommentId DESC
	END
ELSE
	RETURN
	
--5. Filter by Location, Customer, Type
IF @strDefaultComment IS NULL OR @strDefaultComment = ''
	BEGIN
		SELECT TOP 1 @strDefaultComment = strCommentDesc
			FROM tblARCommentMaintenance
			WHERE ((@intCompanyLocationId IS NULL OR @intCompanyLocationId = 0) OR intCompanyLocationId = @intCompanyLocationId)
			AND ((@intEntityCustomerId IS NULL OR @intEntityCustomerId = 0) OR intEntityCustomerId = @intEntityCustomerId)	
			AND ((@strType IS NULL OR @strType = '') OR strType = @strType)
		ORDER BY intCommentId DESC
	END
ELSE
	RETURN

--6. Filter by Transaction, Location
IF @strDefaultComment IS NULL OR @strDefaultComment = ''
	BEGIN
		SELECT TOP 1 @strDefaultComment = strCommentDesc
			FROM tblARCommentMaintenance
			WHERE ((@strTransactionType IS NULL OR @strTransactionType = '') OR strTransactionType = @strTransactionType)
			AND ((@intCompanyLocationId IS NULL OR @intCompanyLocationId = 0) OR intCompanyLocationId = @intCompanyLocationId)			
		ORDER BY intCommentId DESC
	END
ELSE
	RETURN

--7. Filter by Transaction, Customer
IF @strDefaultComment IS NULL OR @strDefaultComment = ''
	BEGIN
		SELECT TOP 1 @strDefaultComment = strCommentDesc
			FROM tblARCommentMaintenance
			WHERE ((@strTransactionType IS NULL OR @strTransactionType = '') OR strTransactionType = @strTransactionType)			
			AND ((@intEntityCustomerId IS NULL OR @intEntityCustomerId = 0) OR intEntityCustomerId = @intEntityCustomerId)	
		ORDER BY intCommentId DESC
	END
ELSE
	RETURN

--8. Filter by Location, Customer
IF @strDefaultComment IS NULL OR @strDefaultComment = ''
	BEGIN
		SELECT TOP 1 @strDefaultComment = strCommentDesc
			FROM tblARCommentMaintenance
			WHERE ((@intCompanyLocationId IS NULL OR @intCompanyLocationId = 0) OR intCompanyLocationId = @intCompanyLocationId)
			AND ((@intEntityCustomerId IS NULL OR @intEntityCustomerId = 0) OR intEntityCustomerId = @intEntityCustomerId)	
		ORDER BY intCommentId DESC
	END
ELSE
	RETURN

--9. Filter by Transaction, Type
IF @strDefaultComment IS NULL OR @strDefaultComment = ''
	BEGIN
		SELECT TOP 1 @strDefaultComment = strCommentDesc
			FROM tblARCommentMaintenance
			WHERE ((@strTransactionType IS NULL OR @strTransactionType = '') OR strTransactionType = @strTransactionType)			
			AND ((@strType IS NULL OR @strType = '') OR strType = @strType)
		ORDER BY intCommentId DESC
	END
ELSE
	RETURN

--10. Filter by Location, Type
IF @strDefaultComment IS NULL OR @strDefaultComment = ''
	BEGIN
		SELECT TOP 1 @strDefaultComment = strCommentDesc
			FROM tblARCommentMaintenance
			WHERE ((@intCompanyLocationId IS NULL OR @intCompanyLocationId = 0) OR intCompanyLocationId = @intCompanyLocationId)
			AND ((@strType IS NULL OR @strType = '') OR strType = @strType)
		ORDER BY intCommentId DESC
	END
ELSE
	RETURN

--11. Filter by Customer, Type
IF @strDefaultComment IS NULL OR @strDefaultComment = ''
	BEGIN
		SELECT TOP 1 @strDefaultComment = strCommentDesc
			FROM tblARCommentMaintenance
			WHERE ((@intEntityCustomerId IS NULL OR @intEntityCustomerId = 0) OR intEntityCustomerId = @intEntityCustomerId)	
			AND ((@strType IS NULL OR @strType = '') OR strType = @strType)
		ORDER BY intCommentId DESC
	END
ELSE
	RETURN

--12. Filter by Transaction
IF @strDefaultComment IS NULL OR @strDefaultComment = ''
	BEGIN
		SELECT TOP 1 @strDefaultComment = strCommentDesc
			FROM tblARCommentMaintenance
			WHERE ((@strTransactionType IS NULL OR @strTransactionType = '') OR strTransactionType = @strTransactionType)			
		ORDER BY intCommentId DESC
	END
ELSE
	RETURN

--13. Filter by Location
IF @strDefaultComment IS NULL OR @strDefaultComment = ''
	BEGIN
		SELECT TOP 1 @strDefaultComment = strCommentDesc
			FROM tblARCommentMaintenance
			WHERE ((@intCompanyLocationId IS NULL OR @intCompanyLocationId = 0) OR intCompanyLocationId = @intCompanyLocationId)
		ORDER BY intCommentId DESC
	END
ELSE
	RETURN

--14. Filter by Customer
IF @strDefaultComment IS NULL OR @strDefaultComment = ''
	BEGIN
		SELECT TOP 1 @strDefaultComment = strCommentDesc
			FROM tblARCommentMaintenance
			WHERE ((@intEntityCustomerId IS NULL OR @intEntityCustomerId = 0) OR intEntityCustomerId = @intEntityCustomerId)	
		ORDER BY intCommentId DESC
	END
ELSE
	RETURN

--15. Filter by Type
IF @strDefaultComment IS NULL OR @strDefaultComment = ''
	BEGIN
		SELECT TOP 1 @strDefaultComment = strCommentDesc
			FROM tblARCommentMaintenance
			WHERE ((@strType IS NULL OR @strType = '') OR strType = @strType)
		ORDER BY intCommentId DESC
	END
ELSE
	RETURN