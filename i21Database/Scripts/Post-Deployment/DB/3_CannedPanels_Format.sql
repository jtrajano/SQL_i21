﻿GO
/*******************  BEGIN UPDATING canned panels on table Panel Format*******************/
print('/*******************  BEGIN UPDATING canned panels format *******************/')

IF OBJECT_ID('tempdb..#TempCannedPanelFormat') IS NOT NULL
    DROP TABLE #TempCannedPanelFormat

print('/*******************  CREATE TEMPORARY table for canned panels format *******************/')
Create TABLE #TempCannedPanelFormat 
(

	[intPanelFormatId]  INT            NOT NULL,
    [strColumn]         NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCondition]      NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strValue1]         NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strValue2]         NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strBackColor]      NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strFontStyle]      NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strFontColor]      NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strApplyTo]        NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intPanelId]        INT            NOT NULL,
    [intUserId]         INT            NOT NULL,
    [intSort]           SMALLINT       NOT NULL,
    [strType]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [ysnVisible]        BIT            NOT NULL,
	[intConcurrencyId] INT			   NOT NULL,
    [intCannedPanelId]  INT			   NOT NULL DEFAULT ((0)), 
	
)

print('/*******************  BEGIN INSERTING canned panels on temporary panel format table  *******************/')

INSERT INTO #TempCannedPanelFormat VALUES (13311, N'gacnt_due_rev_dt', N'>', N'0', N'', N'-657931', N'Regular', N'0', N'Cell', 32, 0, 2, N'', 0, 1, 17)
 
INSERT INTO #TempCannedPanelFormat VALUES (13312, N'gacnt_due_rev_dt', N'>', N'0', N'', N'-657931', N'Regular', N'0', N'Cell', 32, 0, 2, N'', 0, 1, 17)

print('/*******************  END INSERTING canned panels on temporary panel format table  *******************/')

print('/*******************  BEGIN DELETE old panel format records  *******************/')

DELETE tblDBPanelFormat WHERE intCannedPanelId != 0

print('/*******************  END DELETE old panel format records  *******************/')


print('/*******************  BEGIN UPDATING canned panels on table Panel Format  *******************/')
DECLARE @intPanelFormatId int
DECLARE @intCannedPanelId int
DECLARE @intCurrentPanelId int

DECLARE db_cursor CURSOR FOR  
SELECT intPanelFormatId, intCannedPanelId FROM #TempCannedPanelFormat
 

OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @intPanelFormatId, @intCannedPanelId

WHILE @@FETCH_STATUS = 0   
BEGIN
	SET @intCurrentPanelId = (SELECT TOP 1 intPanelId FROM tblDBPanel WHERE intCannedPanelId = @intCannedPanelId)
		
	INSERT INTO [dbo].[tblDBPanelFormat] 
		([strColumn], [strCondition], [strValue1], [strValue2], [strBackColor], [strFontStyle], [strFontColor], [strApplyTo], [intPanelId], [intUserId], [intSort], [strType], [ysnVisible], [intConcurrencyId], [intCannedPanelId])
	SELECT [strColumn], [strCondition], [strValue1], [strValue2], [strBackColor], [strFontStyle], [strFontColor], [strApplyTo], @intCurrentPanelId, [intUserId], [intSort], [strType], [ysnVisible], [intConcurrencyId], [intCannedPanelId]
	FROM #TempCannedPanelFormat 
	WHERE intPanelFormatId = @intPanelFormatId

	
FETCH NEXT FROM db_cursor INTO @intPanelFormatId, @intCannedPanelId
END   

CLOSE db_cursor   
DEALLOCATE db_cursor

DROP TABLE #TempCannedPanelFormat
print('/*******************  END UPDATING canned panels on table Panel Format  *******************/')
/*******************  END UPDATING canned panels on table Panel Format*******************/
GO