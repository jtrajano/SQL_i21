CREATE PROCEDURE [dbo].[uspCFOptimizeFiltering](
		@tableName NVARCHAR(MAX)
		,@field NVARCHAR(MAX)
		,@guid NVARCHAR(MAX)
	)
	AS
	BEGIN 

	BEGIN TRY

	
	DECLARE @dynamicsql NVARCHAR(MAX)
	DECLARE @temptable NVARCHAR(MAX)
	SET @temptable = '##'+REPLACE(@guid,'-','')
	
	

	IF OBJECT_ID('tempdb..' + @temptable) IS NOT NULL
	BEGIN
		SET @dynamicsql = 'DROP TABLE ' + @temptable
		EXEC(@dynamicsql)
	END

	DECLARE @tblCFOptFilterParamTemp TABLE
	(
		 intOptFilterParamId		int	
		,strFilter				nvarchar(max)
		,strDataType			nvarchar(max)
		,strGuid				nvarchar(max)
	)

	INSERT INTO @tblCFOptFilterParamTemp
	(
		 intOptFilterParamId
		,strFilter			
		,strDataType		
		,strGuid
	)
	SELECT 
		 intOptFilterParamId
		,strFilter			
		,strDataType	
		,strGuid	
	FROM tblCFOptFilterParam
	WHERE strGuid = @guid


	WHILE EXISTS(SELECT TOP 1 NULL FROM @tblCFOptFilterParamTemp)
	BEGIN
		
		DECLARE @loopFilter NVARCHAR(MAX)
		DECLARE @loopDataType NVARCHAR(MAX)
		DECLARE @loopOptFilterParamId INT
		
		

		PRINT @loopFilter
		PRINT @loopDataType

		SELECT TOP 1 @loopFilter = strFilter , @loopDataType = strDataType , @loopOptFilterParamId = intOptFilterParamId FROM @tblCFOptFilterParamTemp WHERE strGuid = @guid
		INSERT INTO tblCFOptFilterCountResult
		(
			strFilter
			,strDataType
			,intOptFilterParamId
			,strGuid
		)
		SELECT 
			@loopFilter
			,@loopDataType
			,@loopOptFilterParamId
			,@guid

		SET @dynamicsql = 'UPDATE tblCFOptFilterCountResult SET intRecordCount = (' + 'SELECT COUNT(*) FROM ' 
		+ @tableName 
		+ ' WHERE ' 
		+  @loopFilter 
		+ ')' 
		+ 'WHERE intOptFilterParamId = ' 
		+ CONVERT(NVARCHAR,@loopOptFilterParamId)

		EXEC (@dynamicsql)

		DELETE FROM @tblCFOptFilterParamTemp WHERE intOptFilterParamId = @loopOptFilterParamId
		
	END
	
	--SELECT * FROM tblCFOptFilterCountResult

	DECLARE @intProcess AS INT = 0
	DECLARE @tblCFOptFilterCountResultTemp TABLE
	(
		 intOptFilterCountResultId	  int
		,intOptFilterParamId		  int
		,strFilter					  nvarchar(max)
		,strDataType				  nvarchar(max)
		,intRecordCount				  int
	)

	FILTERTABLE: 

	WHILE EXISTS(SELECT TOP 1 NULL FROM @tblCFOptFilterCountResultTemp)
	BEGIN

		DECLARE @loop2Filter					NVARCHAR(MAX)
		DECLARE @loop2DataType					NVARCHAR(MAX)
		DECLARE @loop2OptFilterParamId			INT
		DECLARE @loop2OptFilterCountResultId	INT
		DECLARE @loop2Count						INT
		

		SELECT TOP 1 
		@loop2Filter = strFilter 
		,@loop2DataType = strDataType 
		,@loop2OptFilterParamId = intOptFilterParamId 
		,@loop2OptFilterCountResultId = intOptFilterCountResultId 
		,@loop2Count = intRecordCount
		FROM @tblCFOptFilterCountResultTemp


		IF OBJECT_ID('tempdb..' + @temptable) IS NULL
		BEGIN
			SET @dynamicsql = 'SELECT * INTO ' + @temptable + ' FROM ' 
						+ @tableName
						+ ' WHERE '
						+ @loop2Filter
		END
		ELSE
		BEGIN
			SET @dynamicsql = 'DELETE FROM ' + @temptable + ' WHERE ' + @field + ' NOT IN (SELECT ' + @field + ' FROM '+@temptable+' WHERE ' 
						 + @loop2Filter 
						 + ' )'
		END


		EXEC(@dynamicsql)
		

		DELETE FROM @tblCFOptFilterCountResultTemp WHERE intOptFilterCountResultId = @loop2OptFilterCountResultId


	END
	--FILTER COUNT INT 



	IF (@intProcess = 0)
	BEGIN
		SET @intProcess = 1
		INSERT INTO @tblCFOptFilterCountResultTemp
		(
			 intOptFilterCountResultId	
			,intOptFilterParamId		
			,strFilter					
			,strDataType				
			,intRecordCount				
		)
		SELECT TOP 1
		 intOptFilterCountResultId	
		,intOptFilterParamId		
		,strFilter					
		,strDataType				
		,intRecordCount				
		FROM tblCFOptFilterCountResult 
		ORDER BY intRecordCount ASC
		GOTO FILTERTABLE
	END

	

	IF (@intProcess = 1)
	BEGIN
		SET @intProcess = 2
		INSERT INTO @tblCFOptFilterCountResultTemp
		(
			 intOptFilterCountResultId	
			,intOptFilterParamId		
			,strFilter					
			,strDataType				
			,intRecordCount				
		)
		SELECT 
		 intOptFilterCountResultId	
		,intOptFilterParamId		
		,strFilter					
		,strDataType				
		,intRecordCount				
		FROM tblCFOptFilterCountResult 
		WHERE strDataType = 'int' ORDER BY intRecordCount ASC
		GOTO FILTERTABLE
	END

	IF (@intProcess = 2)
	BEGIN
		SET @intProcess = 3
		INSERT INTO @tblCFOptFilterCountResultTemp
		(
			 intOptFilterCountResultId	
			,intOptFilterParamId		
			,strFilter					
			,strDataType				
			,intRecordCount				
		)
		SELECT 
		 intOptFilterCountResultId	
		,intOptFilterParamId		
		,strFilter					
		,strDataType				
		,intRecordCount				
		FROM tblCFOptFilterCountResult 
		WHERE strDataType = 'string' ORDER BY intRecordCount ASC
		GOTO FILTERTABLE
	END
	

	IF (@intProcess = 3)
	BEGIN
		SET @intProcess = 4
		INSERT INTO @tblCFOptFilterCountResultTemp
		(
			 intOptFilterCountResultId	
			,intOptFilterParamId		
			,strFilter					
			,strDataType				
			,intRecordCount				
		)
		SELECT 
		 intOptFilterCountResultId	
		,intOptFilterParamId		
		,strFilter					
		,strDataType				
		,intRecordCount				
		FROM tblCFOptFilterCountResult 
		WHERE strDataType = 'date' ORDER BY intRecordCount ASC
		GOTO FILTERTABLE
	END

	IF (@intProcess = 4)
	BEGIN
		SET @intProcess = 5
		INSERT INTO @tblCFOptFilterCountResultTemp
		(
			 intOptFilterCountResultId	
			,intOptFilterParamId		
			,strFilter					
			,strDataType				
			,intRecordCount				
		)
		SELECT 
		 intOptFilterCountResultId	
		,intOptFilterParamId		
		,strFilter					
		,strDataType				
		,intRecordCount				
		FROM tblCFOptFilterCountResult 
		WHERE strDataType = 'boolean' ORDER BY intRecordCount ASC
		GOTO FILTERTABLE
	END

	--SELECT * FROM ##tblCFOptFilterResultTemp

	--INSERT RECORD TO OUTPUT TABLE
	
	SET @dynamicsql = 'SELECT ' + @field + ' FROM ' + @temptable
	EXEC(@dynamicsql)


	--DROP TEMP TABLE
	IF OBJECT_ID('tempdb..' + @temptable) IS NOT NULL
	BEGIN
		SET @dynamicsql = 'DROP TABLE ' + @temptable
		EXEC(@dynamicsql)
	END

	DELETE FROM tblCFOptFilterParam WHERE strGuid = @guid
	DELETE FROM tblCFOptFilterCountResult WHERE strGuid = @guid
	--DELETE FROM tblCFOptFilterResult WHERE strGuid = @guid


	END TRY

	BEGIN CATCH 
		PRINT ERROR_MESSAGE()
		IF OBJECT_ID('tempdb..' + @temptable) IS NOT NULL
		BEGIN
			SET @dynamicsql = 'DROP TABLE ' + @temptable
			EXEC(@dynamicsql)
		END

		DELETE FROM tblCFOptFilterParam WHERE strGuid = @guid
		DELETE FROM tblCFOptFilterCountResult WHERE strGuid = @guid
		--DELETE FROM tblCFOptFilterResult WHERE strGuid = @guid

	END CATCH

	

	END
