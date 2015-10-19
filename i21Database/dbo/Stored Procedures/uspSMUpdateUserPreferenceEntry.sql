CREATE PROCEDURE [dbo].[uspSMUpdateUserPreferenceEntry]
	@intEntityUserSecurityId int
AS
BEGIN

	DECLARE @currentRow INT
	DECLARE @totalRows INT
	DECLARE @sql NVARCHAR(MAX)

	SET @currentRow = 1
	SELECT @totalRows = Count(DISTINCT(TABLE_NAME)) FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] LIKE '%UserPreference'

	WHILE (@currentRow <= @totalRows)
	BEGIN

	Declare @tableName NVARCHAR(50)
	SELECT @tableName = TABLE_NAME FROM (  
		SELECT ROW_NUMBER() OVER(ORDER BY TABLE_NAME ASC) AS 'ROWID', *
		FROM 
		(
			SELECT DISTINCT(TABLE_NAME) FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] LIKE '%UserPreference'
		) a
	) b
	WHERE ROWID = @currentRow

	SET @sql = 'IF NOT EXISTS(SELECT TOP 1 1 FROM ' + @tableName + ' WHERE intEntityUserSecurityId = @intEntityUserSecurityId)
				BEGIN
					INSERT INTO ' + @tableName + ' (intEntityUserSecurityId) VALUES (@intEntityUserSecurityId)
				END'
	EXEC sp_executesql @sql, N'@intEntityUserSecurityId INT', @intEntityUserSecurityId = @intEntityUserSecurityId

	SET @currentRow = @currentRow + 1
	END

END
