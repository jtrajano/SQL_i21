CREATE PROCEDURE [dbo].[uspDBMigrateUserPreference]
AS
IF NOT EXISTS(SELECT TOP 1 1 FROM tblDBUserPreference)
BEGIN
	PRINT N'MIGRATING tblDBUserPreference from tblSMPreference'

	DECLARE @intPreferenceID int
	DECLARE @intUserSecurityId int

	DECLARE @AutoPanelWidth bit
	DECLARE @AutoRefresh bit
	DECLARE @AutoRefreshMinute int
	DECLARE @ColumnFiltering bit
	DECLARE @ColumnMoving bit
	DECLARE @ColumnResizing bit
	DECLARE @ColumnSorting bit
	DECLARE @Columns int
	DECLARE @ColumnWidth1 int
	DECLARE @ColumnWidth2 int
	DECLARE @ColumnWidth3 int
	DECLARE @ColumnWidth4 int
	DECLARE @DefaultTabId int
	DECLARE @ExportAll bit
	DECLARE @PrintAll bit
	DECLARE @RefreshTab bit
	DECLARE @SaveGridLayout bit


	DECLARE db_cursor CURSOR FOR  
	select distinct intUserID from tblSMPreferences where intUserID <> 0
 

	OPEN db_cursor   
	FETCH NEXT FROM db_cursor INTO @intUserSecurityId

	WHILE @@FETCH_STATUS = 0   
	BEGIN
		set @AutoPanelWidth = (SELECT strValue FROM tblSMPreferences where intUserID = @intUserSecurityId AND strPreference = 'AutoPanelWidth')
		set @AutoRefresh = (SELECT strValue FROM tblSMPreferences where intUserID = @intUserSecurityId AND strPreference = 'AutoRefresh')
		set @AutoRefreshMinute = (SELECT strValue FROM tblSMPreferences where intUserID = @intUserSecurityId AND strPreference = 'AutoRefreshMinute')
		set @ColumnFiltering = (SELECT strValue FROM tblSMPreferences where intUserID = @intUserSecurityId AND strPreference = 'ColumnFiltering')
		set @ColumnMoving = (SELECT strValue FROM tblSMPreferences where intUserID = @intUserSecurityId AND strPreference = 'ColumnMoving')
		set @ColumnResizing = (SELECT strValue FROM tblSMPreferences where intUserID = @intUserSecurityId AND strPreference = 'ColumnResizing')
		set @ColumnSorting = (SELECT strValue FROM tblSMPreferences where intUserID = @intUserSecurityId AND strPreference = 'ColumnSorting')
		set @Columns = (SELECT strValue FROM tblSMPreferences where intUserID = @intUserSecurityId AND strPreference = 'DashboardColumns')
		set @ColumnWidth1 = (SELECT strValue FROM tblSMPreferences where intUserID = @intUserSecurityId AND strPreference = 'DashboardColumnWidth1')
		set @ColumnWidth2 = (SELECT strValue FROM tblSMPreferences where intUserID = @intUserSecurityId AND strPreference = 'DashboardColumnWidth2')
		set @ColumnWidth3 = (SELECT strValue FROM tblSMPreferences where intUserID = @intUserSecurityId AND strPreference = 'DashboardColumnWidth3')
		set @ColumnWidth4 = (SELECT strValue FROM tblSMPreferences where intUserID = @intUserSecurityId AND strPreference = 'DashboardColumnWidth4')
		set @DefaultTabId = (SELECT strValue FROM tblSMPreferences where intUserID = @intUserSecurityId AND strPreference = 'DefaultTabID')
		set @ExportAll = (SELECT strValue FROM tblSMPreferences where intUserID = @intUserSecurityId AND strPreference = 'ExportAll')
		set @PrintAll = (SELECT strValue FROM tblSMPreferences where intUserID = @intUserSecurityId AND strPreference = 'PrintAll')
		set @RefreshTab = (SELECT strValue FROM tblSMPreferences where intUserID = @intUserSecurityId AND strPreference = 'RefreshTab')
		set @SaveGridLayout = (SELECT strValue FROM tblSMPreferences where intUserID = @intUserSecurityId AND strPreference = 'SaveGridLayout')
		

			
		--Check if User already exist
		IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[tblDBUserPreference] WHERE intUserSecurityId = @intUserSecurityId)			
			BEGIN

				INSERT INTO [dbo].[tblDBUserPreference] 
					   ([intAutoRefreshMinute], [intColumns], [intColumnWidth1], [intColumnWidth2], [intColumnWidth3], [intColumnWidth4], [intDafaultTabId], [intUserSecurityId], [ysnAutoPanelWidth], [ysnAutoRefresh], [ysnColumnFiltering], [ysnColumnMoving], [ysnColumnResizing], [ysnColumnSorting], [ysnExportAll], [ysnPrintAll], [ysnRefreshTab], [ysnSaveGridLayout])
				 VALUES (@AutoRefreshMinute, @Columns, @ColumnWidth1, @ColumnWidth2, @ColumnWidth3, @ColumnWidth4, @DefaultTabId, @intUserSecurityId, @AutoPanelWidth, @AutoRefresh, @ColumnFiltering, @ColumnMoving, @ColumnResizing, @ColumnSorting, @ExportAll, @PrintAll, @RefreshTab, @SaveGridLayout);
			END 

	
	FETCH NEXT FROM db_cursor INTO @intUserSecurityId
	END   

	CLOSE db_cursor   
	DEALLOCATE db_cursor

	DELETE FROM tblSMPreferences
    WHERE strPreference
    IN ('AutoPanelWidth', 'AutoRefresh', 'AutoRefreshMinute', 'ColumnFiltering', 'ColumnMoving'
	, 'FilterValue', 'ColumnResizing', 'ColumnSorting', 'DashboardColumns', 'DashboardColumnWidth1'
	, 'DashboardColumnWidth2', 'DashboardColumnWidth3', 'DashboardColumnWidth4', 'DefaultTabID'
	, 'ExportAll', 'PrintAll', 'RefreshTab', 'SaveGridLayout')

END