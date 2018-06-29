CREATE PROCEDURE [dbo].[uspSMUpdateUserPreferenceEntry]
	@intEntityUserSecurityId INT
AS
BEGIN

	DECLARE @sql NVARCHAR(MAX)
	DECLARE @currentTable NVARCHAR(200)

	IF OBJECT_ID('tempdb..#TempUserPreference') IS NOT NULL DROP TABLE #TempUserPreference
	SELECT TABLE_NAME INTO #TempUserPreference FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] LIKE '%UserPreference' 

	WHILE EXISTS(SELECT TOP 1 1 FROM #TempUserPreference)
	BEGIN
		SELECT TOP 1 @currentTable = TABLE_NAME FROM #TempUserPreference

		SET @sql = 'IF NOT EXISTS(SELECT TOP 1 1 FROM ' + @currentTable + ' WHERE intEntityUserSecurityId = @intEntityUserSecurityId)
					BEGIN
						INSERT INTO ' + @currentTable + ' (intEntityUserSecurityId) VALUES (@intEntityUserSecurityId)
					END'
  
		EXEC sp_executesql @sql, N'@intEntityUserSecurityId INT', @intEntityUserSecurityId = @intEntityUserSecurityId

		DELETE FROM #TempUserPreference WHERE TABLE_NAME = @currentTable
	END

END
