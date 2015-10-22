
IF OBJECT_ID('tempdb..##XXEntityForTM') IS NOT NULL  	
BEGIN
	PRINT ' Executing collected security commands'

	

	WHILE EXISTS(SELECT TOP 1 1 FROM @AlterTables)
	BEGIN
		SET @CurStatementTM1 = ''
		SELECT TOP 1 @CurStatementTM1 = cmd  FROM @AlterTables			
		
		--PRINT (@CurStatementTM1)

		EXECUTE sp_executesql @CurStatementTM1

		DELETE FROM @AlterTables WHERE cmd = @CurStatementTM1
	END

	EXEC('alter table tblTMEvent drop constraint PK_tblTMEvent')
	EXEC('alter table tblTMDeliveryHistory drop constraint PK_tblTMDeliveryHistory;')
	EXEC('alter table tblTMWorkOrder drop constraint PK_tblTMWork')
	EXEC('alter table tblTMSite drop constraint PK_tblTMSite')
	EXEC('alter table tblTMDispatch drop constraint PK_tblTMDispatch')
	
	TRUNCATE TABLE ##XXEntityForTM

	IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = '##XXEntityForTM' and [COLUMN_NAME] = 'cmd')
	BEGIN
		ALTER TABLE ##XXEntityForTM
		ADD cmd nvarchar(max)
	END	

	IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = '##XXEntityForTM' and [COLUMN_NAME] = 'xtype')
	BEGIN
		ALTER TABLE ##XXEntityForTM
		ADD xtype int
	END	

	insert into ##XXEntityForTM(cmd,xtype)
	select cmd,case when CHARINDEX('tblTMEvent', cmd) > 0 then 1
				when CHARINDEX('tblTMDeliveryHistory', cmd) > 0 then 2   
				when CHARINDEX('tblTMWork', cmd) > 0 then 3   
				when CHARINDEX('tblTMSite', cmd) > 0 then 4   
				when CHARINDEX('tblTMDispatch', cmd) > 0 then 5   
				else 0
				end	 xtype		
	FROM @FinalDestination	
END

GO

IF OBJECT_ID('tempdb..##XXEntityForTM') IS NOT NULL  	
BEGIN
	DECLARE @CurStatementTM1 NVARCHAR(MAX)
	PRINT ' executing collected update commands  0000'
	WHILE EXISTS(SELECT TOP 1 1 FROM ##XXEntityForTM where xtype = 0)
	BEGIN
		SET @CurStatementTM1 = ''
		SELECT TOP 1 @CurStatementTM1 = cmd  FROM ##XXEntityForTM where xtype = 0			 
		--PRINT (@CurStatementTM1)

		set @CurStatementTM1 = @CurStatementTM1
		--EXECUTE sp_executesql @CurStatementTM1
		EXEC(@CurStatementTM1)


		DELETE FROM ##XXEntityForTM WHERE cmd = @CurStatementTM1 and xtype = 0
	END

	
END

GO

IF OBJECT_ID('tempdb..##XXEntityForTM') IS NOT NULL  	
BEGIN
	DECLARE @CurStatementTM1 NVARCHAR(MAX)
	PRINT ' executing collected update commands  0001'
	WHILE EXISTS(SELECT TOP 1 1 FROM ##XXEntityForTM where xtype = 1)
	BEGIN
		SET @CurStatementTM1 = ''
		SELECT TOP 1 @CurStatementTM1 = cmd  FROM ##XXEntityForTM where xtype = 1			 
		--PRINT (@CurStatementTM1)

		set @CurStatementTM1 = @CurStatementTM1
		EXEC(@CurStatementTM1)

		DELETE FROM ##XXEntityForTM WHERE cmd = @CurStatementTM1 and xtype = 1
	END

	
END

GO



IF OBJECT_ID('tempdb..##XXEntityForTM') IS NOT NULL  	
BEGIN
	DECLARE @CurStatementTM1 NVARCHAR(MAX)
	PRINT ' executing collected update commands 0002'
	WHILE EXISTS(SELECT TOP 1 1 FROM ##XXEntityForTM where xtype = 2)
	BEGIN
		SET @CurStatementTM1 = ''
		SELECT TOP 1 @CurStatementTM1 = cmd  FROM ##XXEntityForTM where xtype = 2			 
		--PRINT (@CurStatementTM1)

		set @CurStatementTM1 = @CurStatementTM1
		EXEC(@CurStatementTM1)		

		DELETE FROM ##XXEntityForTM WHERE cmd = @CurStatementTM1 and xtype = 2
	END
END

GO

IF OBJECT_ID('tempdb..##XXEntityForTM') IS NOT NULL  	
BEGIN
	DECLARE @CurStatementTM1 NVARCHAR(MAX)
	PRINT ' executing collected update commands 0003'
	WHILE EXISTS(SELECT TOP 1 1 FROM ##XXEntityForTM where xtype = 3)
	BEGIN
		SET @CurStatementTM1 = ''
		SELECT TOP 1 @CurStatementTM1 = cmd  FROM ##XXEntityForTM where xtype = 3			 
		--PRINT (@CurStatementTM1)

		set @CurStatementTM1 = @CurStatementTM1
		EXEC(@CurStatementTM1)

		DELETE FROM ##XXEntityForTM WHERE cmd = @CurStatementTM1 and xtype = 3
	END
	
END

GO

IF OBJECT_ID('tempdb..##XXEntityForTM') IS NOT NULL  	
BEGIN
	DECLARE @CurStatementTM1 NVARCHAR(MAX)
	PRINT ' executing collected update commands 0004'
	WHILE EXISTS(SELECT TOP 1 1 FROM ##XXEntityForTM where xtype = 4)
	BEGIN
		SET @CurStatementTM1 = ''
		SELECT TOP 1 @CurStatementTM1 = cmd  FROM ##XXEntityForTM where xtype = 4			 
		--PRINT (@CurStatementTM1)

		set @CurStatementTM1 = @CurStatementTM1
		EXEC(@CurStatementTM1)


		DELETE FROM ##XXEntityForTM WHERE cmd = @CurStatementTM1 and xtype = 4
	END
END

GO

IF OBJECT_ID('tempdb..##XXEntityForTM') IS NOT NULL  	
BEGIN
	DECLARE @CurStatementTM1 NVARCHAR(MAX)
	PRINT ' executing collected update commands 0005'
	WHILE EXISTS(SELECT TOP 1 1 FROM ##XXEntityForTM where xtype = 5)
	BEGIN
		SET @CurStatementTM1 = ''
		SELECT TOP 1 @CurStatementTM1 = cmd  FROM ##XXEntityForTM where xtype = 5			 
		--PRINT (@CurStatementTM1)

		set @CurStatementTM1 = @CurStatementTM1
		EXEC(@CurStatementTM1)		

		DELETE FROM ##XXEntityForTM WHERE cmd = @CurStatementTM1 and xtype = 5
	END

	DROP TABLE ##XXEntityForTM	
END

GO