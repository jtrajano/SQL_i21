GO
PRINT('/*******************  BEGIN FIXING USER SECURITY *******************/')

IF OBJECT_ID('tempdb..#TempFixUserSecurity') IS NOT NULL
	DROP TABLE #TempFixUserSecurity

CREATE TABLE #TempFixUserSecurity
(
	[intEntityId]			INT NOT NULL,
	[intUserRoleID]			INT NULL,
	[ysnAdmin]				BIT NULL
)

--get all entities with admin rights
INSERT INTO #TempFixUserSecurity
SELECT a.intEntityId, a.intUserRoleID, a.ysnAdmin
FROM tblSMUserSecurity a 
INNER JOIN tblSMUserRole b ON a.intUserRoleID = b.intUserRoleID
WHERE b.strRoleType = 'Administrator'

DECLARE temp_cursor CURSOR FOR
SELECT intEntityId, intUserRoleID, ysnAdmin
FROM #TempFixUserSecurity

DECLARE @intEntityId INT
DECLARE @intUserRoleID  INT
DECLARE @ysnAdmin BIT

OPEN temp_cursor
FETCH NEXT FROM temp_cursor into @intEntityId, @intUserRoleID, @ysnAdmin
WHILE @@FETCH_STATUS = 0
BEGIN
			
	IF ISNULL(@intEntityId, 0) <> 0 AND ISNULL(@intUserRoleID, 0) > 1 AND ISNULL(@ysnAdmin, 0) <> 1
	BEGIN
		UPDATE tblSMUserSecurity SET ysnAdmin = 1 WHERE intEntityId = @intEntityId
	END

	FETCH NEXT FROM temp_cursor into @intEntityId, @intUserRoleID, @ysnAdmin
END

CLOSE temp_cursor
DEALLOCATE temp_cursor



PRINT('/*******************  END FIXING USER SECURITY *******************/')

GO