GO
print('/*******************  START UPDATING ACTIVITY SOURCE  *******************/')

SET IDENTITY_INSERT tblSMActivitySource ON


IF OBJECT_ID('tempdb..#TempActivitySource') IS NOT NULL
    DROP TABLE TempActivitySource


Create TABLE #TempActivitySource 
(
	[intActivitySourceId]		INT											NOT NULL,
	[strActivitySource]			NVARCHAR(250) Collate Latin1_General_CI_AS	NOT NULL,
	[intConcurrencyId]			int											NOT NULL, 
)

INSERT INTO [dbo].[#TempActivitySource] VALUES (1, 'General',	1);
INSERT INTO [dbo].[#TempActivitySource] VALUES (2, 'CRM',		1);
INSERT INTO [dbo].[#TempActivitySource] VALUES (3, 'Help Desk',	1);

DECLARE @intActivitySourceId int

DECLARE db_cursor CURSOR FOR  
SELECT intActivitySourceId FROM #TempActivitySource
 

OPEN db_cursor   
FETCH NEXT FROM db_cursor INTO @intActivitySourceId
WHILE @@FETCH_STATUS = 0   
BEGIN
	
	--Check if Exist
	IF EXISTS (SELECT TOP 1 1 FROM [dbo].[tblSMActivitySource] WHERE intActivitySourceId = @intActivitySourceId)
		BEGIN
			UPDATE [dbo].[tblSMActivitySource]
			SET 
				strActivitySource	= ActivitySource.strActivitySource
				FROM (SELECT * FROM #TempActivitySource where intActivitySourceId = @intActivitySourceId) AS ActivitySource
			WHERE [dbo].[tblSMActivitySource].[intActivitySourceId] = @intActivitySourceId;
		END	  
	ELSE --NEW DATABASE, ADD DEFAULT
		BEGIN
			INSERT INTO [dbo].[tblSMActivitySource] 
				   ([intActivitySourceId], [strActivitySource], [intConcurrencyId]) 
			 SELECT [intActivitySourceId], [strActivitySource], [intConcurrencyId] FROM #TempActivitySource WHERE intActivitySourceId = @intActivitySourceId;
		END

FETCH NEXT FROM db_cursor INTO @intActivitySourceId
END   

CLOSE db_cursor   
DEALLOCATE db_cursor

SET IDENTITY_INSERT tblSMActivitySource OFF

print('/*******************  END UPDATING ACTIVITY SOURCE  *******************/')