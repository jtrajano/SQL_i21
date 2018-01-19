CREATE FUNCTION [dbo].[fnSTRebateDepartment](@intStoreId INT)
RETURNS @TempTableDepartments TABLE 
(
	strStatus NVARCHAR(100)
	, strDepartment NVARCHAR(100)
)
AS 
BEGIN
	
	--// Get Department Id from Store
	DECLARE @strDepartments AS NVARCHAR(MAX)
	SELECT @strDepartments = strDepartment 
	FROM tblSTStore
	WHERE intStoreId = @intStoreId

	IF(@strDepartments = '')
	BEGIN
		INSERT INTO @TempTableDepartments (strStatus, strDepartment)
		VALUES ('ERROR', 'Store does not have setup for Tobacco Department')
		RETURN
	RETURN
	END

	--// Insert to tempTable
	INSERT @TempTableDepartments
	SELECT 'Success' AS strStatus
			, strCategoryCode 
	FROM tblICCategory 
	WHERE intCategoryId IN (SELECT Item FROM dbo.fnSTSeparateStringToColumns(@strDepartments,','))

	IF NOT EXISTS (SELECT * FROM @TempTableDepartments)
	BEGIN
		INSERT INTO @TempTableDepartments (strStatus, strDepartment)
		VALUES ('ERROR', 'Tobacco department does not exist')
		RETURN
	END

RETURN
END