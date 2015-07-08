
-- =============================================
-- Author:		mpferrer
-- Create date: 04/01/2015
-- Description:	Audit Script - generic script to check all changes from SSDT schema compare to ensure that the update will/will not fail.
-- =============================================
CREATE PROCEDURE [dbo].[uspSPAuditLogs]
	@Result NVARCHAR(MAX) OUTPUT, 
	@FilePath NVARCHAR(256) = null
AS
BEGIN
SET NOCOUNT ON;

DECLARE @Exists INT
DECLARE @Sql NVARCHAR(512)

EXEC master..xp_fileexist @FilePath, @Exists OUT
IF @Exists = 1
BEGIN

	IF object_id('tempdb..#tempTables') IS NOT NULL
	BEGIN
	   DROP TABLE #tempTables
	END

	CREATE TABLE #tempTables
	(
		[Table] NVARCHAR(max),
		[Column] NVARCHAR(max),
		[IsDelete] NVARCHAR(max),
		[Add] NVARCHAR(max),
		[ColumnChanges] NVARCHAR(MAX),
		[Changes] NVARCHAR(MAX),
		[ForeignKey] NVARCHAR(MAX)
	)

	SET @Result = ''

	SET @Sql = 'BULK INSERT #tempTables FROM ''' + @FilePath + ''' WITH (FIRSTROW=2, MAXERRORS=0,FIELDTERMINATOR = ''\t'',ROWTERMINATOR = ''\n'')'
	EXEC sp_executesql @Sql

	IF((SELECT COUNT(*) FROM #tempTables) = 0)
	BEGIN
		PRINT 'No Tables/Changes were detected.'
		RETURN
	END
	--=====================================================================================================================================
	-- remove unncessesary rows / doesnt have any changes / delete
	--=====================================================================================================================================
	DELETE FROM #tempTables WHERE [Table] IS NULL OR [IsDelete] <> 'No' 
	DELETE FROM #tempTables WHERE [Add] IS NULL AND [ColumnChanges] IS NULL AND [Changes] IS NULL AND [ForeignKey] IS NULL
	DELETE FROM #tempTables WHERE [Column] LIKE '%unnamed%' OR ([Changes] = 'OnDeleteAction' AND ForeignKey IS NULL) 
	--=====================================================================================================================================

	--SELECT DISTINCT [Table], [Column], [IsDelete], [Add],[ColumnChanges], [Changes], [ForeignKey] FROM #tempTables where [add] is null
	
	DECLARE @Table NVARCHAR(MAX), 
			@Column NVARCHAR(MAX), 
			@IsDelete NVARCHAR(MAX),
			@Add NVARCHAR(MAX),
			@ColumnChanges NVARCHAR(MAX),
			@Changes NVARCHAR(MAX),	
			@ForeignKey NVARCHAR(MAX),
			@Ctr INT = 1 
	
	DECLARE @ret NVARCHAR(200), @ret1 NVARCHAR(200)

	--=====================================================================================================================================
	-- DECLARE CURSOR
	DECLARE Cursor_Audit CURSOR FOR 	
	--=====================================================================================================================================
	
	SELECT DISTINCT [Table], [Column], [IsDelete], [Add],[ColumnChanges], [Changes], [ForeignKey] FROM #tempTables
		
	 OPEN Cursor_Audit
	FETCH NEXT FROM Cursor_Audit into @Table, @Column, @IsDelete, @Add, @ColumnChanges, @Changes, @ForeignKey
	
	
	 WHILE (@@FETCH_STATUS <> -1)
	 BEGIN
		 --=====================================================================================================================================
		 -- ADD ITEMS
		 --=====================================================================================================================================
		  IF(@Add <> '' AND @Add <> NULL) 
		  BEGIN
				SET @Column = SUBSTRING(@Column, LEN(@Table) + 2, LEN(@Column))
				BEGIN TRY
					BEGIN TRAN
					SET @Sql = 'ALTER TABLE ' + @Table + ' ADD ' + @Column + ' ' + @Add;
					EXEC sp_executesql @Sql;
					ROLLBACK TRAN
				END TRY
				BEGIN CATCH
					SET @Result = @Result + 'Table:' + REPLACE(@Table,'dbo.','') + 'Column:' + @Column + '. ' + ERROR_MESSAGE() + CHAR(13) + CHAR(10);
					--SET @Result = @Result +  + ERROR_MESSAGE() + CHAR(13) + CHAR(10); 
					ROLLBACK TRAN
				END CATCH	
		  END
		  --=====================================================================================================================================
		  -- Data Type Changes
		  --=====================================================================================================================================
		  ELSE 
			BEGIN
				--=====================================================================================================================================
				-- CHANGE SCALE OF A DECIMAL COLUMN
				--=====================================================================================================================================
				IF(@Changes = 'Scale')
				BEGIN 
					SET @Column = SUBSTRING(@Column, LEN(@Table) + 2, LEN(@Column))
					SET @Sql = N'select @ret=NUMERIC_PRECISION from INFORMATION_SCHEMA.COLUMNS IC where TABLE_NAME = ''' + SUBSTRING(@Table,5,len(@Table)) + ''' and COLUMN_NAME = '''+  @Column  + '''';
					EXEC sp_executesql @Sql,N'@ret NVARCHAR(20) OUTPUT', @ret OUTPUT;
					BEGIN TRY
						BEGIN TRAN
						SET @Sql = 'ALTER TABLE ' + @Table + ' ALTER COLUMN ' + @Column + ' DECIMAL(' + @ret + ',' + @ColumnChanges + ')';
						EXEC sp_executesql @Sql;
						ROLLBACK TRAN
					END TRY
					BEGIN CATCH
						SET @Result = @Result + 'Table:' +REPLACE(@Table,'dbo.','') + 'Column:' + @Column + '. ' + ERROR_MESSAGE() + CHAR(13) + CHAR(10);
						--SET @Result = @Result + ERROR_MESSAGE() + ' Changing scale of the decimal to ' + @ColumnChanges + CHAR(13) + CHAR(10);
						--PRINT CAST(@Ctr AS NVARCHAR(30)) + ') ' + ERROR_MESSAGE() + ' Changing scale of the decimal to ' + @ColumnChanges;
						ROLLBACK TRAN
					END CATCH
				END
				--=====================================================================================================================================
				-- CHANGE PRECISION OF A DECIMAL COLUMN
				--=====================================================================================================================================
				IF(@Changes = 'Precision')
				BEGIN
					SET @Column = SUBSTRING(@Column, LEN(@Table) + 2, LEN(@Column))
					
					SET @Sql = N'select @ret=NUMERIC_SCALE from INFORMATION_SCHEMA.COLUMNS IC where TABLE_NAME = ''' + SUBSTRING(@Table,5,len(@Table)) + ''' 
									and COLUMN_NAME = '''+  @Column  + '''';
					
					EXEC sp_executesql @Sql,N'@ret NVARCHAR(20) OUTPUT', @ret OUTPUT;
					
					BEGIN TRY
						BEGIN TRAN
						SET @Sql = 'ALTER TABLE ' + @Table + ' ALTER COLUMN ' + @Column + ' DECIMAL(' + @ColumnChanges + ',' + @ret + ')';
						EXEC sp_executesql @Sql;
						ROLLBACK TRAN
					END TRY
					BEGIN CATCH
						SET @Result = @Result + 'Table:' + REPLACE(@Table,'dbo.','') + 'Column:' + @Column + '. ' + ERROR_MESSAGE() + CHAR(13) + CHAR(10);
						--SET @Result = @Result + ERROR_MESSAGE() + ' Changing precision of the decimal to ' + @ColumnChanges + CHAR(13) + CHAR(10);
						ROLLBACK TRAN
					END CATCH
				END
				--=====================================================================================================================================
				-- COLUMN SET TO NULL OR NOT NULL
				--=====================================================================================================================================
				IF(@Changes = 'IsNullable')
				BEGIN
					SET @Column = SUBSTRING(@Column, LEN(@Table) + 2, LEN(@Column))
					
					SET @Sql = N'select @ret=DATA_TYPE from INFORMATION_SCHEMA.COLUMNS IC where TABLE_NAME = ''' + SUBSTRING(@Table,5,len(@Table)) + ''' 
									and COLUMN_NAME = '''+  @Column  + '''';
					
					EXEC sp_executesql @Sql,N'@ret NVARCHAR(20) OUTPUT', @ret OUTPUT;
					
					BEGIN TRY
						BEGIN TRAN
						SET @Sql = 'ALTER TABLE ' + @Table + ' ALTER COLUMN ' + @Column + ' ' + @ret + ' ' +  CASE WHEN @ColumnChanges = 'False' THEN 'NOT NULL' ELSE 'NULL' END;
						EXEC sp_executesql @Sql;
						ROLLBACK TRAN
					END TRY
					BEGIN CATCH
						SET @Result = @Result + 'Table:' + REPLACE(@Table,'dbo.','') + 'Column:' + @Column + '. ' + ERROR_MESSAGE() + CHAR(13) + CHAR(10);
						--SET @Result = @Result + ERROR_MESSAGE() + ' Changing isnullable to ' + @ColumnChanges + CHAR(13) + CHAR(10);
						ROLLBACK TRAN
					END CATCH
				END
				--=====================================================================================================================================
				-- NVARCHAR LENGTH
				--=====================================================================================================================================
				IF(@Changes = 'Length')
				BEGIN
					SET @Column = SUBSTRING(@Column, LEN(@Table) + 2, LEN(@Column))
					
					SET @Sql = N'select @ret=IS_NULLABLE from INFORMATION_SCHEMA.COLUMNS IC where TABLE_NAME = ''' + SUBSTRING(@Table,5,len(@Table)) + ''' and 
									COLUMN_NAME = '''+  @Column  + '''';
					
					EXEC sp_executesql @Sql,N'@ret NVARCHAR(20) OUTPUT', @ret OUTPUT;
					
					BEGIN TRY
						BEGIN TRAN
						SET @Sql = 'ALTER TABLE ' + @Table + ' ALTER COLUMN ' + @Column + ' NVARCHAR(' + CASE WHEN @ColumnChanges = 0 THEN 'MAX' ELSE @ColumnChanges END + ') ' + CASE WHEN @ret = 'NO' THEN 'NOT NULL' ELSE 'NULL' END;
						EXEC sp_executesql @Sql;
						ROLLBACK TRAN
					END TRY
					BEGIN CATCH
						SET @Result = @Result + 'Table:' + REPLACE(@Table,'dbo.','') + 'Column:' + @Column + '. ' + ERROR_MESSAGE() + CHAR(13) + CHAR(10);
						--SET @Result = @Result + 'Table: ' + @Table + ' Column: ' + @Column + ' Changing LENGTH to ' + @ColumnChanges + '. ' + ERROR_MESSAGE()  + CHAR(13) + CHAR(10);
						ROLLBACK TRAN
					END CATCH
				END
				--=====================================================================================================================================
				-- UNIQUE KEY CONSTRAINT
				--=====================================================================================================================================
				IF(@Changes = 'IsUnique' AND @ColumnChanges = 'True') 
				BEGIN
					SET @Column = SUBSTRING(@Column, LEN(@Table) + 2, LEN(@Column))
					SET @Column = SUBSTRING(@Column, LEN(@Table) + 1, LEN(@Column))	
					SET @Sql = 'SELECT ' + @Column + ' INTO ##tempData FROM ' + @Table + ' GROUP BY ' + @Column	+ ' HAVING COUNT(*) > 1';
					EXEC sp_executesql @Sql;
					
					IF((SELECT COUNT(*) FROM ##tempData) > 0)
					BEGIN
						SET @Result = @Result + 'Table:' + REPLACE(@Table,'dbo.','') + 'Column:' + @Column + '. ' + 'Adding UNIQUE KEY CONSTRAINT/PRIMARY KEY will cause data error.' + CHAR(13) + CHAR(10);
						--SET @Result = @Result + 'Adding UNIQUE KEY CONSTRAINT/PRIMARY KEY for table ' + @Table + ' and column ' + @Column + ' will cause data error.' + CHAR(13) + CHAR(10);
					END

					DROP TABLE ##tempData
				END
				--=====================================================================================================================================
				-- FOREIGN KEY CONSTRAINT
				--=====================================================================================================================================
				
				IF(@ForeignKey IS NOT NULL)
				BEGIN
					
					declare @tempColumn NVARCHAR(MAX) = parsename(replace(@ForeignKey, '_', '.'), 1)
					declare @tempTable NVARCHAR(MAX) = parsename(replace(@ForeignKey, '_', '.'), 2)
					
					IF(@Table <> ('dbo.' + @tempTable))
					BEGIN
						BEGIN TRY
							BEGIN TRAN
							SET @Sql = 'ALTER TABLE ' + @Table + ' ADD FOREIGN KEY (' + @tempColumn +') REFERENCES ' + @tempTable  +'(' + @tempColumn + ')';
							EXEC sp_executesql @Sql;
							ROLLBACK TRAN
						END TRY
						BEGIN CATCH
							SET @Result = @Result + 'Table:' + REPLACE(@Table,'dbo.','') + ' Foreign Key:' + REPLACE(@ForeignKey,'dbo.','')  + '. ' + ERROR_MESSAGE() + CHAR(13) + CHAR(10);
							ROLLBACK TRAN
					END CATCH
					END
				END
			END
		--=====================================================================================================================================
		SET @Ctr = @Ctr + 1;
		FETCH NEXT FROM Cursor_Audit into @Table, @Column, @IsDelete, @Add, @ColumnChanges, @Changes, @ForeignKey

	END
	
	CLOSE Cursor_Audit
	DEALLOCATE Cursor_Audit
	
	DROP TABLE #tempTables

END
END

GO


