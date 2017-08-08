GO
	/* ADD DEFAULT FAVORITE GROUP */
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMMigrationLog WHERE strModule = 'System Manager' AND strEvent = 'Add Default Favorite Group (System Manager) - 1730')
	BEGIN
		DECLARE @currentId INT
		
		IF OBJECT_ID('tempdb..#TempEntityMenuFavorite') IS NOT NULL DROP TABLE #TempUserPreference

		SELECT intEntityId INTO TempEntityMenuFavorite 
		FROM tblSMEntityMenuFavorite
		WHERE intParentEntityMenuFavoriteId is null
		GROUP BY intEntityId
		ORDER BY intEntityId

		WHILE EXISTS(SELECT TOP 1 1 FROM TempEntityMenuFavorite)
		BEGIN
			SELECT TOP 1 @currentId = intEntityId FROM TempEntityMenuFavorite

			INSERT INTO tblSMEntityMenuFavorite(strMenuName, intEntityId, intSort)
			VALUES('My Favorites', @currentId, 0)

			UPDATE tblSMEntityMenuFavorite SET intParentEntityMenuFavoriteId = SCOPE_IDENTITY()
			WHERE intParentEntityMenuFavoriteId IS NULL
			AND intMenuId IS NOT NULL
			AND intEntityId = @currentId
	
			DELETE FROM TempEntityMenuFavorite WHERE intEntityId = @currentId

		END
		
		
		PRINT N'ADD DEFAULT FAVORITE GROUP'
		INSERT INTO tblSMMigrationLog([strModule], [strEvent], [strDescription], [dtmMigrated]) 
		VALUES('System Manager', 'Add Default Favorite Group (System Manager) - 1730', 'Add Default Favorite Group (System Manager) - 1730', GETDATE())
	END
GO