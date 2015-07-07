CREATE PROCEDURE [dbo].[uspSMUpdateUserPreferenceEntry]
	@intUserSecurityId int
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

	SET @sql = 'IF NOT EXISTS(SELECT TOP 1 1 FROM ' + @tableName + ' WHERE intUserSecurityId = @intUserSecurityId)
				BEGIN
					INSERT INTO ' + @tableName + ' (intUserSecurityId) VALUES (@intUserSecurityId)
				END'
	EXEC sp_executesql @sql, N'@intUserSecurityId INT', @intUserSecurityId = @intUserSecurityId

	SET @currentRow = @currentRow + 1
	END

END
