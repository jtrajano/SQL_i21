/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					

 This script is needed due to following reason(s)
 If a panel was given a copy to other users by using User Access in panel settings and somehow one of those users was suddenly deleted
 The copied panel will remain in tblDBPanel and now an orpant
 DASH-2266
--------------------------------------------------------------------------------------
*/
PRINT '*START DELETION OF ALL FLOATING PANELS*'
IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblDBPanel' and [COLUMN_NAME] = 'intUserId')
	
	IF OBJECT_ID('tempdb..#TempDBPanel') IS NOT NULL
		DROP TABLE #TempDBPanel


	Create TABLE #TempDBPanel
	(
		[intPanelId]            INT             NOT NULL,
		[intUserId]             INT             NOT NULL
	)

	-- Get all FLOATING Panels / Panels whose user is deleted
	INSERT INTO #TempDBPanel(intPanelId, intUserId)
	SELECT intPanelId, intUserId
	FROM tblDBPanel a
	left join tblEMEntity b on a.intUserId = b.intEntityId
	WHERE intUserId IS NOT NULL and intUserId <> 0 and b.strName IS NULL

	DECLARE panel_cursor CURSOR FOR
	SELECT intPanelId, intUserId
	FROM #TempDBPanel

	DECLARE @intPanelId INT 
	DECLARE @intUserId INT

	OPEN panel_cursor
	FETCH NEXT FROM panel_cursor into @intPanelId, @intUserId
	WHILE @@FETCH_STATUS = 0
	BEGIN
		--Level 1: Entity
		--check if entity approval details (tblEMEntityRequireApprovalFor) is the same with intApproverId/intApproverGroupId of tblSMApproval
		IF @intPanelId IS NOT NULL and @intPanelId <> 0 and @intUserId IS NOT NULL and @intUserId <> 0
		BEGIN
			delete from tblDBPanel where intPanelId = @intPanelId
		END
	FETCH NEXT FROM panel_cursor into @intPanelId, @intUserId
	END

	CLOSE panel_cursor
	DEALLOCATE panel_cursor

PRINT '*END DELETION OF ALL FLOATING PANELS*'