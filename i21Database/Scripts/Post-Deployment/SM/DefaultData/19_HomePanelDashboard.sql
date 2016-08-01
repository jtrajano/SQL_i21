GO
print('/*******************  START UPDATING HOME PANELS  *******************/')

SET IDENTITY_INSERT tblSMHomePanelDashboard ON


IF OBJECT_ID('tempdb..#TempHomePanels') IS NOT NULL
    DROP TABLE #TempHomePanels


Create TABLE #TempHomePanels 
(
	[intHomePanelDashboardId]	INT											NOT NULL,
	[strPanelName]				NVARCHAR(250) Collate Latin1_General_CI_AS	NOT NULL,
	[strType]					NVARCHAR(100) Collate Latin1_General_CI_AS	NULL,
	[ysnVisible]				bit											NOT NULL		DEFAULT 0,
	[ysnDefaultPanel]			bit											NULL			DEFAULT 0,
	[intPanelHeight]			int											NOT NULL		DEFAULT 0,
	[intColumnIndex]			int											NOT NULL,
	[intRowIndex]				int											NOT NULL,
	[strPanelStyle]				NVARCHAR(100) COllate Latin1_General_CI_AS	NULL			DEFAULT '',
	[strChartStyle]				NVARCHAR(100) COllate Latin1_General_CI_AS	NULL			DEFAULT '',
	[intPanelWidth]				int											NULL,
	[intGridLayoutId]			int											NULL,
	[strWidgetName]				NVARCHAR(100) Collate Latin1_General_CI_AS	NULL			DEFAULT '',
	[intEntityId]				int											NOT NULL, 
	[ysnCollapse]				bit											NULL,
	[strGridLayoutUrl]			NVARCHAR(MAX) Collate Latin1_General_CI_AS	NULL,
	[intConcurrencyId]			int											NOT NULL, 
)

INSERT INTO [dbo].[#TempHomePanels] VALUES (1, 'Comments',				'System', 1, 1, 500, 0, 0, 'Grid', N'', NULL, NULL, 'commentsform',			1, 0, N'', 1);
INSERT INTO [dbo].[#TempHomePanels] VALUES (2, 'Recently Viewed',		'System', 1, 1, 500, 1, 0, 'Grid', N'', NULL, NULL, 'recentlyviewedform',	1, 0, N'', 1);
INSERT INTO [dbo].[#TempHomePanels] VALUES (3, 'Messages',				'System', 1, 1, 500, 0, 1, 'Grid', N'', NULL, NULL, 'messagesform',			1, 0, N'', 1);
INSERT INTO [dbo].[#TempHomePanels] VALUES (4, 'Audit Log History',		'System', 1, 1, 500, 1, 1, 'Grid', N'', NULL, NULL, 'auditloghistoryform',	1, 0, N'', 1);
INSERT INTO [dbo].[#TempHomePanels] VALUES (5, 'Alerts',				'System', 1, 1, 500, 0, 2, 'Grid', N'', NULL, NULL, 'alertsform',			1, 0, N'', 1);
INSERT INTO [dbo].[#TempHomePanels] VALUES (6, 'Online Users',			'System', 1, 1, 500, 1, 2, 'Grid', N'', NULL, NULL, 'onlineusersform',		1, 0, N'', 1);

DECLARE @intHomePanelDashboardId int

DECLARE db_cursor CURSOR FOR  
SELECT intHomePanelDashboardId FROM #TempHomePanels
 

OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @intHomePanelDashboardId
WHILE @@FETCH_STATUS = 0   
BEGIN
	
	--Check if System Panel Exist
	IF EXISTS (SELECT TOP 1 1 FROM [dbo].[tblSMHomePanelDashboard] WHERE intHomePanelDashboardId = @intHomePanelDashboardId)
		BEGIN
			UPDATE [dbo].[tblSMHomePanelDashboard]
			SET 
				strPanelName	= HomePanels.strPanelName,
				strType			= HomePanels.strType,
				ysnDefaultPanel	= HomePanels.ysnDefaultPanel,
				strPanelStyle	= HomePanels.strPanelStyle,
				strChartStyle	= HomePanels.strChartStyle,
				strWidgetName	= HomePanels.strWidgetName,
				intEntityId		= HomePanels.intEntityId
				FROM (SELECT * FROM #TempHomePanels where intHomePanelDashboardId = @intHomePanelDashboardId) AS HomePanels
			WHERE [dbo].[tblSMHomePanelDashboard].[intHomePanelDashboardId] = @intHomePanelDashboardId;
		END	  
	ELSE --NEW DATABASE, ADD DEFAULT
		BEGIN
			INSERT INTO [dbo].[tblSMHomePanelDashboard] 
				   ([intHomePanelDashboardId],[strPanelName],[strType],[ysnVisible],[ysnDefaultPanel],[intPanelHeight],[intColumnIndex],[intRowIndex],[strPanelStyle],[strChartStyle],[intPanelWidth],[intGridLayoutId],[strWidgetName], [intEntityId], [ysnCollapse], [strGridLayoutUrl], [intConcurrencyId]) 
			 SELECT [intHomePanelDashboardId],[strPanelName],[strType],[ysnVisible],[ysnDefaultPanel],[intPanelHeight],[intColumnIndex],[intRowIndex],[strPanelStyle],[strChartStyle],[intPanelWidth],[intGridLayoutId],[strWidgetName], [intEntityId], [ysnCollapse], [strGridLayoutUrl], [intConcurrencyId]
			 FROM #TempHomePanels 
			 WHERE intHomePanelDashboardId = @intHomePanelDashboardId;
		END

FETCH NEXT FROM db_cursor INTO @intHomePanelDashboardId
END   

CLOSE db_cursor   
DEALLOCATE db_cursor

SET IDENTITY_INSERT tblSMHomePanelDashboard OFF

print('/*******************  END UPDATING HOME PANELS  *******************/')