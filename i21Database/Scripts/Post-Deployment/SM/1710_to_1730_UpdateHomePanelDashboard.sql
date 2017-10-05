GO
	PRINT N'START UPDATE HOME PANEL DASHBOARD'


	IF OBJECT_ID('tempdb..#TempSMHomePanelDashboard') IS NOT NULL
    DROP TABLE TempSMHomePanelDashboard


	Create TABLE #TempSMHomePanelDashboard
	(
		[intHomePanelDashboardId]	INT											NOT NULL,
		[strScreenName]				NVARCHAR(250) Collate Latin1_General_CI_AS	NOT NULL,
		[intMenuId]					int											NULL
	)

	
	INSERT INTO #TempSMHomePanelDashboard(intHomePanelDashboardId, strScreenName, intMenuId)
	SELECT intHomePanelDashboardId, strScreenName, intMenuId
	FROM tblSMHomePanelDashboard
	WHERE intMenuId IS NULL AND intGridLayoutId IS NOT NULL AND strType <> 'System'



	DECLARE homepanel_cursor CURSOR FOR
	SELECT intHomePanelDashboardId, strScreenName FROM #TempSMHomePanelDashboard

	
	DECLARE @intHomePanelDashboardId INT;
	DECLARE @screenName NVARCHAR(250)
	DECLARE @intMenuId INT
	DECLARE @intModuleMenuId INT

	OPEN homepanel_cursor
	FETCH NEXT FROM homepanel_cursor into @intHomePanelDashboardId, @screenName 
	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		IF EXISTS(SELECT TOP 1 1 FROM tblSMMasterMenu WHERE strCommand like @screenName+'%' AND intParentMenuID IS NOT NULL)
		BEGIN
			Select TOP 1 @intMenuId = intMenuID FROM tblSMMasterMenu WHERE strCommand like @screenName+'%' AND intParentMenuID IS NOT NULL

			SELECT @intModuleMenuId = intMenuID FROM tblSMMasterMenu WHERE intParentMenuID = 0 and intMenuID in 
			(
				SELECT a.intParentMenuID from tblSMMasterMenu a
				inner join tblSMMasterMenu b on a.intMenuID =  b.intParentMenuID
				where b.intMenuID = @intMenuId
			)

			IF @intModuleMenuId IS NOT NULL
			BEGIN
				update tblSMHomePanelDashboard set intMenuId = @intModuleMenuId where intHomePanelDashboardId = @intHomePanelDashboardId
			END
		END


	FETCH NEXT FROM homepanel_cursor INTO @intHomePanelDashboardId, @screenName;
	END

	CLOSE homepanel_cursor
	DEALLOCATE homepanel_cursor


	PRINT N'END UPDATE HOME PANEL DASHBOARD'



	
	

	
	
GO