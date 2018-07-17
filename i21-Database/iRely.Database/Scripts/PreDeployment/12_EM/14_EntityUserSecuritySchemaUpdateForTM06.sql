
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

-- type 1 - 1
IF OBJECT_ID('tempdb..##XXEntityForTM') IS NOT NULL  	
BEGIN
	DECLARE @CurStatementTM1 NVARCHAR(MAX)
	PRINT ' executing collected update commands  0001-0001'
	DECLARE @FlavorFour INT 
	SET @FlavorFour = 0
	WHILE EXISTS(SELECT TOP 1 1 FROM ##XXEntityForTM where xtype = 1) and @FlavorFour < 10
	BEGIN
		SET @CurStatementTM1 = ''
		SELECT TOP 1 @CurStatementTM1 = cmd  FROM ##XXEntityForTM where xtype = 1			 
		--PRINT (@CurStatementTM1)

		set @CurStatementTM1 = @CurStatementTM1
		EXEC(@CurStatementTM1)

		DELETE FROM ##XXEntityForTM WHERE cmd = @CurStatementTM1 and xtype = 1
		set @FlavorFour = @FlavorFour + 1
	END	
END

GO

-- type 1 - 2
IF OBJECT_ID('tempdb..##XXEntityForTM') IS NOT NULL  	
BEGIN
	DECLARE @CurStatementTM1 NVARCHAR(MAX)
	PRINT ' executing collected update commands  0001-0002'
	DECLARE @FlavorFour INT 
	SET @FlavorFour = 0
	WHILE EXISTS(SELECT TOP 1 1 FROM ##XXEntityForTM where xtype = 1) and @FlavorFour < 10
	BEGIN
		SET @CurStatementTM1 = ''
		SELECT TOP 1 @CurStatementTM1 = cmd  FROM ##XXEntityForTM where xtype = 1			 
		--PRINT (@CurStatementTM1)

		set @CurStatementTM1 = @CurStatementTM1
		EXEC(@CurStatementTM1)

		DELETE FROM ##XXEntityForTM WHERE cmd = @CurStatementTM1 and xtype = 1
		set @FlavorFour = @FlavorFour + 1
	END	
END

GO


-- type 1 - 3
IF OBJECT_ID('tempdb..##XXEntityForTM') IS NOT NULL  	
BEGIN
	DECLARE @CurStatementTM1 NVARCHAR(MAX)
	PRINT ' executing collected update commands  0001-0003'
	DECLARE @FlavorFour INT 
	SET @FlavorFour = 0
	WHILE EXISTS(SELECT TOP 1 1 FROM ##XXEntityForTM where xtype = 1) and @FlavorFour < 10
	BEGIN
		SET @CurStatementTM1 = ''
		SELECT TOP 1 @CurStatementTM1 = cmd  FROM ##XXEntityForTM where xtype = 1			 
		--PRINT (@CurStatementTM1)

		set @CurStatementTM1 = @CurStatementTM1
		EXEC(@CurStatementTM1)

		DELETE FROM ##XXEntityForTM WHERE cmd = @CurStatementTM1 and xtype = 1
		set @FlavorFour = @FlavorFour + 1
	END	
END

GO

-- type 1 - 4
IF OBJECT_ID('tempdb..##XXEntityForTM') IS NOT NULL  	
BEGIN
	DECLARE @CurStatementTM1 NVARCHAR(MAX)
	PRINT ' executing collected update commands  0001-0004'
	DECLARE @FlavorFour INT 
	SET @FlavorFour = 0
	WHILE EXISTS(SELECT TOP 1 1 FROM ##XXEntityForTM where xtype = 1)
	BEGIN
		SET @CurStatementTM1 = ''
		SELECT TOP 1 @CurStatementTM1 = cmd  FROM ##XXEntityForTM where xtype = 1			 
		--PRINT (@CurStatementTM1)

		set @CurStatementTM1 = @CurStatementTM1
		EXEC(@CurStatementTM1)

		DELETE FROM ##XXEntityForTM WHERE cmd = @CurStatementTM1 and xtype = 1
		set @FlavorFour = @FlavorFour + 1
	END	
END

GO


--type 2 - 1
IF OBJECT_ID('tempdb..##XXEntityForTM') IS NOT NULL  	
BEGIN
	DECLARE @CurStatementTM1 NVARCHAR(MAX)
	PRINT ' executing collected update commands 0002-0001'
	DECLARE @FlavorFour INT 
	SET @FlavorFour = 0
	WHILE EXISTS(SELECT TOP 1 1 FROM ##XXEntityForTM where xtype = 2) and @FlavorFour < 10
	BEGIN
		SET @CurStatementTM1 = ''
		SELECT TOP 1 @CurStatementTM1 = cmd  FROM ##XXEntityForTM where xtype = 2			 
		--PRINT (@CurStatementTM1)

		set @CurStatementTM1 = @CurStatementTM1
		EXEC(@CurStatementTM1)		

		DELETE FROM ##XXEntityForTM WHERE cmd = @CurStatementTM1 and xtype = 2
		set @FlavorFour = @FlavorFour + 1
	END
END
GO
--type 2 - 2
IF OBJECT_ID('tempdb..##XXEntityForTM') IS NOT NULL  	
BEGIN
	DECLARE @CurStatementTM1 NVARCHAR(MAX)
	PRINT ' executing collected update commands 0002-0002'
	DECLARE @FlavorFour INT 
	SET @FlavorFour = 0
	WHILE EXISTS(SELECT TOP 1 1 FROM ##XXEntityForTM where xtype = 2) and @FlavorFour < 10
	BEGIN
		SET @CurStatementTM1 = ''
		SELECT TOP 1 @CurStatementTM1 = cmd  FROM ##XXEntityForTM where xtype = 2			 
		--PRINT (@CurStatementTM1)

		set @CurStatementTM1 = @CurStatementTM1
		EXEC(@CurStatementTM1)		

		DELETE FROM ##XXEntityForTM WHERE cmd = @CurStatementTM1 and xtype = 2
		set @FlavorFour = @FlavorFour + 1
	END
END
GO

--type 2 - 3
IF OBJECT_ID('tempdb..##XXEntityForTM') IS NOT NULL  	
BEGIN
	DECLARE @CurStatementTM1 NVARCHAR(MAX)
	PRINT ' executing collected update commands 0002-0003'
	DECLARE @FlavorFour INT 
	SET @FlavorFour = 0
	WHILE EXISTS(SELECT TOP 1 1 FROM ##XXEntityForTM where xtype = 2) and @FlavorFour < 10
	BEGIN
		SET @CurStatementTM1 = ''
		SELECT TOP 1 @CurStatementTM1 = cmd  FROM ##XXEntityForTM where xtype = 2			 
		--PRINT (@CurStatementTM1)

		set @CurStatementTM1 = @CurStatementTM1
		EXEC(@CurStatementTM1)		

		DELETE FROM ##XXEntityForTM WHERE cmd = @CurStatementTM1 and xtype = 2
		set @FlavorFour = @FlavorFour + 1
	END
END
GO
--type 2 - 4
IF OBJECT_ID('tempdb..##XXEntityForTM') IS NOT NULL  	
BEGIN
	DECLARE @CurStatementTM1 NVARCHAR(MAX)
	PRINT ' executing collected update commands 0002-0004'
	DECLARE @FlavorFour INT 
	SET @FlavorFour = 0
	WHILE EXISTS(SELECT TOP 1 1 FROM ##XXEntityForTM where xtype = 2) 
	BEGIN
		SET @CurStatementTM1 = ''
		SELECT TOP 1 @CurStatementTM1 = cmd  FROM ##XXEntityForTM where xtype = 2			 
		--PRINT (@CurStatementTM1)

		set @CurStatementTM1 = @CurStatementTM1
		EXEC(@CurStatementTM1)		

		DELETE FROM ##XXEntityForTM WHERE cmd = @CurStatementTM1 and xtype = 2
		set @FlavorFour = @FlavorFour + 1
	END
END

GO
--type 3 - 1
IF OBJECT_ID('tempdb..##XXEntityForTM') IS NOT NULL  	
BEGIN
	DECLARE @CurStatementTM1 NVARCHAR(MAX)
	PRINT ' executing collected update commands 0003-0001'
	DECLARE @FlavorFour INT 
	SET @FlavorFour = 0
	WHILE EXISTS(SELECT TOP 1 1 FROM ##XXEntityForTM where xtype = 3) and @FlavorFour < 10
	BEGIN
		SET @CurStatementTM1 = ''
		SELECT TOP 1 @CurStatementTM1 = cmd  FROM ##XXEntityForTM where xtype = 3			 
		--PRINT (@CurStatementTM1)

		set @CurStatementTM1 = @CurStatementTM1
		EXEC(@CurStatementTM1)

		DELETE FROM ##XXEntityForTM WHERE cmd = @CurStatementTM1 and xtype = 3
		set @FlavorFour = @FlavorFour + 1
	END
	
END

GO

--type 3 - 2
IF OBJECT_ID('tempdb..##XXEntityForTM') IS NOT NULL  	
BEGIN
	DECLARE @CurStatementTM1 NVARCHAR(MAX)
	PRINT ' executing collected update commands 0003-0002'
	DECLARE @FlavorFour INT 
	SET @FlavorFour = 0
	WHILE EXISTS(SELECT TOP 1 1 FROM ##XXEntityForTM where xtype = 3) and @FlavorFour < 10
	BEGIN
		SET @CurStatementTM1 = ''
		SELECT TOP 1 @CurStatementTM1 = cmd  FROM ##XXEntityForTM where xtype = 3			 
		--PRINT (@CurStatementTM1)

		set @CurStatementTM1 = @CurStatementTM1
		EXEC(@CurStatementTM1)

		DELETE FROM ##XXEntityForTM WHERE cmd = @CurStatementTM1 and xtype = 3
		set @FlavorFour = @FlavorFour + 1
	END
	
END

GO


--type 3 - 3
IF OBJECT_ID('tempdb..##XXEntityForTM') IS NOT NULL  	
BEGIN
	DECLARE @CurStatementTM1 NVARCHAR(MAX)
	PRINT ' executing collected update commands 0003-0003'
	DECLARE @FlavorFour INT 
	SET @FlavorFour = 0
	WHILE EXISTS(SELECT TOP 1 1 FROM ##XXEntityForTM where xtype = 3) and @FlavorFour < 10
	BEGIN
		SET @CurStatementTM1 = ''
		SELECT TOP 1 @CurStatementTM1 = cmd  FROM ##XXEntityForTM where xtype = 3			 
		--PRINT (@CurStatementTM1)

		set @CurStatementTM1 = @CurStatementTM1
		EXEC(@CurStatementTM1)

		DELETE FROM ##XXEntityForTM WHERE cmd = @CurStatementTM1 and xtype = 3
		set @FlavorFour = @FlavorFour + 1
	END
	
END

GO


--type 3 - 4
IF OBJECT_ID('tempdb..##XXEntityForTM') IS NOT NULL  	
BEGIN
	DECLARE @CurStatementTM1 NVARCHAR(MAX)
	PRINT ' executing collected update commands 0003-0004'
	DECLARE @FlavorFour INT 
	SET @FlavorFour = 0
	WHILE EXISTS(SELECT TOP 1 1 FROM ##XXEntityForTM where xtype = 3)
	BEGIN
		SET @CurStatementTM1 = ''
		SELECT TOP 1 @CurStatementTM1 = cmd  FROM ##XXEntityForTM where xtype = 3			 
		--PRINT (@CurStatementTM1)

		set @CurStatementTM1 = @CurStatementTM1
		EXEC(@CurStatementTM1)

		DELETE FROM ##XXEntityForTM WHERE cmd = @CurStatementTM1 and xtype = 3
		set @FlavorFour = @FlavorFour + 1
	END
	
END

GO

--type 4 - 1
IF OBJECT_ID('tempdb..##XXEntityForTM') IS NOT NULL  	
BEGIN
	DECLARE @CurStatementTM1 NVARCHAR(MAX)
	PRINT ' executing collected update commands 0004-0001'
	DECLARE @FlavorFour INT 
	SET @FlavorFour = 0
	WHILE EXISTS(SELECT TOP 1 1 FROM ##XXEntityForTM where xtype = 4) and @FlavorFour < 10
	BEGIN
		SET @CurStatementTM1 = ''
		SELECT TOP 1 @CurStatementTM1 = cmd  FROM ##XXEntityForTM where xtype = 4			 
		--PRINT (@CurStatementTM1)

		set @CurStatementTM1 = @CurStatementTM1
		EXEC(@CurStatementTM1)

		DELETE FROM ##XXEntityForTM WHERE cmd = @CurStatementTM1 and xtype = 4
		set @FlavorFour = @FlavorFour + 1
	END
END

GO

--type 4 - 2
IF OBJECT_ID('tempdb..##XXEntityForTM') IS NOT NULL  	
BEGIN
	DECLARE @CurStatementTM1 NVARCHAR(MAX)
	PRINT ' executing collected update commands 0004-0002'
	DECLARE @FlavorFour INT 
	SET @FlavorFour = 0
	WHILE EXISTS(SELECT TOP 1 1 FROM ##XXEntityForTM where xtype = 4) and @FlavorFour < 10
	BEGIN
		SET @CurStatementTM1 = ''
		SELECT TOP 1 @CurStatementTM1 = cmd  FROM ##XXEntityForTM where xtype = 4			 
		--PRINT (@CurStatementTM1)

		set @CurStatementTM1 = @CurStatementTM1
		EXEC(@CurStatementTM1)

		DELETE FROM ##XXEntityForTM WHERE cmd = @CurStatementTM1 and xtype = 4
		set @FlavorFour = @FlavorFour + 1
	END
END

GO

--type 4 - 3
IF OBJECT_ID('tempdb..##XXEntityForTM') IS NOT NULL  	
BEGIN
	DECLARE @CurStatementTM1 NVARCHAR(MAX)
	PRINT ' executing collected update commands 0004-0003'
	DECLARE @FlavorFour INT 
	SET @FlavorFour = 0
	WHILE EXISTS(SELECT TOP 1 1 FROM ##XXEntityForTM where xtype = 4) and @FlavorFour < 10
	BEGIN
		SET @CurStatementTM1 = ''
		SELECT TOP 1 @CurStatementTM1 = cmd  FROM ##XXEntityForTM where xtype = 4			 
		--PRINT (@CurStatementTM1)

		set @CurStatementTM1 = @CurStatementTM1
		EXEC(@CurStatementTM1)

		DELETE FROM ##XXEntityForTM WHERE cmd = @CurStatementTM1 and xtype = 4
		set @FlavorFour = @FlavorFour + 1
	END
END

GO

--type 4 - 4
IF OBJECT_ID('tempdb..##XXEntityForTM') IS NOT NULL  	
BEGIN
	DECLARE @CurStatementTM1 NVARCHAR(MAX)
	PRINT ' executing collected update commands 0004-0004'
	DECLARE @FlavorFour INT 
	SET @FlavorFour = 0
	WHILE EXISTS(SELECT TOP 1 1 FROM ##XXEntityForTM where xtype = 4)
	BEGIN
		SET @CurStatementTM1 = ''
		SELECT TOP 1 @CurStatementTM1 = cmd  FROM ##XXEntityForTM where xtype = 4			 
		--PRINT (@CurStatementTM1)

		set @CurStatementTM1 = @CurStatementTM1
		EXEC(@CurStatementTM1)

		DELETE FROM ##XXEntityForTM WHERE cmd = @CurStatementTM1 and xtype = 4
		set @FlavorFour = @FlavorFour + 1
	END
END

GO

--type 5 - 1
IF OBJECT_ID('tempdb..##XXEntityForTM') IS NOT NULL  	
BEGIN
	DECLARE @CurStatementTM1 NVARCHAR(MAX)
	PRINT ' executing collected update commands 0005-0001'
	DECLARE @FlavorFour INT 
	SET @FlavorFour = 0
	WHILE EXISTS(SELECT TOP 1 1 FROM ##XXEntityForTM where xtype = 5) and @FlavorFour < 10
	BEGIN
		SET @CurStatementTM1 = ''
		SELECT TOP 1 @CurStatementTM1 = cmd  FROM ##XXEntityForTM where xtype = 5			 
		--PRINT (@CurStatementTM1)

		set @CurStatementTM1 = @CurStatementTM1
		EXEC(@CurStatementTM1)		

		DELETE FROM ##XXEntityForTM WHERE cmd = @CurStatementTM1 and xtype = 5
		set @FlavorFour = @FlavorFour + 1
	END

END

GO

--type 5 - 2
IF OBJECT_ID('tempdb..##XXEntityForTM') IS NOT NULL  	
BEGIN
	DECLARE @CurStatementTM1 NVARCHAR(MAX)
	PRINT ' executing collected update commands 0005-0002'
	DECLARE @FlavorFour INT 
	SET @FlavorFour = 0
	WHILE EXISTS(SELECT TOP 1 1 FROM ##XXEntityForTM where xtype = 5) and @FlavorFour < 10
	BEGIN
		SET @CurStatementTM1 = ''
		SELECT TOP 1 @CurStatementTM1 = cmd  FROM ##XXEntityForTM where xtype = 5			 
		--PRINT (@CurStatementTM1)

		set @CurStatementTM1 = @CurStatementTM1
		EXEC(@CurStatementTM1)		

		DELETE FROM ##XXEntityForTM WHERE cmd = @CurStatementTM1 and xtype = 5
		set @FlavorFour = @FlavorFour + 1
	END
END

GO

--type 5 - 3
IF OBJECT_ID('tempdb..##XXEntityForTM') IS NOT NULL  	
BEGIN
	DECLARE @CurStatementTM1 NVARCHAR(MAX)
	PRINT ' executing collected update commands 0005-0003'
	DECLARE @FlavorFour INT 
	SET @FlavorFour = 0
	WHILE EXISTS(SELECT TOP 1 1 FROM ##XXEntityForTM where xtype = 5) and @FlavorFour < 10
	BEGIN
		SET @CurStatementTM1 = ''
		SELECT TOP 1 @CurStatementTM1 = cmd  FROM ##XXEntityForTM where xtype = 5			 
		--PRINT (@CurStatementTM1)

		set @CurStatementTM1 = @CurStatementTM1
		EXEC(@CurStatementTM1)		

		DELETE FROM ##XXEntityForTM WHERE cmd = @CurStatementTM1 and xtype = 5
		set @FlavorFour = @FlavorFour + 1
	END
END

GO

--type 5 - 1
IF OBJECT_ID('tempdb..##XXEntityForTM') IS NOT NULL  	
BEGIN
	DECLARE @CurStatementTM1 NVARCHAR(MAX)
	PRINT ' executing collected update commands 0005-0004'
	DECLARE @FlavorFour INT 
	SET @FlavorFour = 0
	WHILE EXISTS(SELECT TOP 1 1 FROM ##XXEntityForTM where xtype = 5) 
	BEGIN
		SET @CurStatementTM1 = ''
		SELECT TOP 1 @CurStatementTM1 = cmd  FROM ##XXEntityForTM where xtype = 5			 
		--PRINT (@CurStatementTM1)

		set @CurStatementTM1 = @CurStatementTM1
		EXEC(@CurStatementTM1)		

		DELETE FROM ##XXEntityForTM WHERE cmd = @CurStatementTM1 and xtype = 5
		set @FlavorFour = @FlavorFour + 1
	END

	DROP TABLE ##XXEntityForTM	
END

GO