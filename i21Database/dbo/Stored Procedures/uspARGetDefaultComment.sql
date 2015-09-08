CREATE PROCEDURE [dbo].[uspARGetDefaultComment]
	@intCompanyLocationId	INT = NULL,
	@intEntityCustomerId	INT = NULL,
	@strTransactionType     NVARCHAR(50) = NULL,
	@strType                NVARCHAR(50) = NULL,
	@strDefaultComment		NVARCHAR(250) = NULL OUTPUT
AS

--FILTER ALL
SELECT TOP 1 @strDefaultComment = strCommentDesc
	FROM tblARCommentMaintenance
	WHERE ((@intCompanyLocationId IS NULL OR @intCompanyLocationId = 0) OR intCompanyLocationId = @intCompanyLocationId)
	AND ((@intEntityCustomerId IS NULL OR @intEntityCustomerId = 0) OR intEntityCustomerId = @intEntityCustomerId)
	AND ((@strTransactionType IS NULL OR @strTransactionType = '') OR strTransactionType = @strTransactionType)
	AND ((@strType IS NULL OR @strType = '' OR @strTransactionType <> 'Invoice') OR strType = @strType)
ORDER BY intCommentId DESC

--FILTER BY COMPANY LOC, CUSTOMER, TRANSACTION TYPE
IF @strDefaultComment IS NULL OR @strDefaultComment = ''
	BEGIN
		SELECT TOP 1 @strDefaultComment = strCommentDesc
			FROM tblARCommentMaintenance
			WHERE ((@intCompanyLocationId IS NULL OR @intCompanyLocationId = 0) OR intCompanyLocationId = @intCompanyLocationId)
			AND ((@intEntityCustomerId IS NULL OR @intEntityCustomerId = 0) OR intEntityCustomerId = @intEntityCustomerId)
			AND ((@strTransactionType IS NULL OR @strTransactionType = '') OR strTransactionType = @strTransactionType)			
		ORDER BY intCommentId DESC
	END

--FILTER BY COMPANY LOC, TRANSACTION TYPE
IF @strDefaultComment IS NULL OR @strDefaultComment = ''
	BEGIN
		SELECT TOP 1 @strDefaultComment = strCommentDesc
			FROM tblARCommentMaintenance
			WHERE ((@intCompanyLocationId IS NULL OR @intCompanyLocationId = 0) OR intCompanyLocationId = @intCompanyLocationId)
			AND ((@strTransactionType IS NULL OR @strTransactionType = '') OR strTransactionType = @strTransactionType)
		ORDER BY intCommentId DESC
	END

--FILTER BY TRANSACTION TYPE
IF @strDefaultComment IS NULL OR @strDefaultComment = ''
	BEGIN
		SELECT TOP 1 @strDefaultComment = strCommentDesc
			FROM tblARCommentMaintenance
			WHERE ((@strTransactionType IS NULL OR @strTransactionType = '') OR strTransactionType = @strTransactionType)			
		ORDER BY intCommentId DESC
	END

IF @strDefaultComment IS NULL OR @strDefaultComment = ''
	BEGIN
		SELECT TOP 1 @strDefaultComment = strCommentDesc
			FROM tblARCommentMaintenance ORDER BY intCommentId DESC
	END