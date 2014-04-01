GO
/*******************  BEGIN UPDATING canned panels on table Panel Format*******************/
print('/*******************  BEGIN UPDATING canned panels format *******************/')
print('/*******************  CREATE TEMPORARY table for canned panels format *******************/')
Create TABLE #TampCannedPanelFormat 
(

	[intPanelFormatId]  INT            NOT NULL,
    [strColumn]         NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCondition]      NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strValue1]         NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strValue2]         NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intBackColor]      INT            NOT NULL,
    [strFontStyle]      NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intFontColor]      INT            NOT NULL,
    [strApplyTo]        NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intPanelId]        INT            NOT NULL,
    [intUserId]         INT            NOT NULL,
    [intSort]           SMALLINT       NOT NULL,
    [strType]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [ysnVisible]        BIT            NOT NULL,
    [intCannedPanelId] INT NOT NULL DEFAULT ((0)), 
	
	--[intConcurrencyId ] INT            DEFAULT ((1)) NOT NULL,
)

print('/*******************  BEGIN INSERTING canned panels on temporary panel format table  *******************/')
INSERT INTO #TampCannedPanelFormat VALUES (1, N'stphy_diff_qty', N'>', N'0', N'', -8388652, N'Bold', 0, N'Cell', 12, 0, 2, N'', 0, 12)
INSERT INTO #TampCannedPanelFormat VALUES (2, N'stphy_diff_qty', N'<', N'0', N'', -65536, N'Bold', 0, N'Cell', 12, 0, 3, N'', 0, 12)
INSERT INTO #TampCannedPanelFormat VALUES (3, N'gacnt_due_rev_dt', N'>', N'0', N'', -657931, N'Regular', 0, N'Cell', 17, 0, 2, N'', 0, 17)
print('/*******************  END INSERTING canned panels on temporary panel format table  *******************/')

print('/*******************  BEGIN DELETE old panel format records  *******************/')

DELETE tblDBPanelFormat WHERE intCannedPanelId != 0

print('/*******************  END DELETE old panel format records  *******************/')


print('/*******************  BEGIN UPDATING canned panels on table Panel Format  *******************/')
DECLARE @intPanelFormatId int
DECLARE @intCannedPanelId int
DECLARE @intCurrentPanelId int

DECLARE db_cursor CURSOR FOR  
SELECT intPanelFormatId, intCannedPanelId FROM #TampCannedPanelFormat
 

OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @intPanelFormatId, @intCannedPanelId

WHILE @@FETCH_STATUS = 0   
BEGIN
	SET @intCurrentPanelId = (SELECT TOP 1 intPanelId FROM tblDBPanel WHERE intCannedPanelId = @intCannedPanelId)
		
	INSERT INTO [dbo].[tblDBPanelFormat] 
		([strColumn], [strCondition], [strValue1], [strValue2], [intBackColor], [strFontStyle], [intFontColor], [strApplyTo], [intPanelId], [intUserId], [intSort], [strType], [ysnVisible], [intCannedPanelId])
	SELECT [strColumn], [strCondition], [strValue1], [strValue2], [intBackColor], [strFontStyle], [intFontColor], [strApplyTo], @intCurrentPanelId, [intUserId], [intSort], [strType], [ysnVisible], [intCannedPanelId]
	FROM #TampCannedPanelFormat 
	WHERE intPanelFormatId = @intPanelFormatId

	
FETCH NEXT FROM db_cursor INTO @intPanelFormatId, @intCannedPanelId
END   

CLOSE db_cursor   
DEALLOCATE db_cursor

DROP TABLE #TampCannedPanelFormat
print('/*******************  END UPDATING canned panels on table Panel Format  *******************/')
/*******************  END UPDATING canned panels on table Panel Format*******************/
GO