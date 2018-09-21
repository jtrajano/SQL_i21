CREATE PROCEDURE [dbo].[uspGRItemsSettlementReport]
	@intEntityId INT
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @xmlDocumentId INT

	--for pivoting
	DECLARE @cols NVARCHAR(MAX), 
			@query NVARCHAR(MAX),
			@cnt INT = 0, 
			@sql VARCHAR(max), 
			@columnName VARCHAR(MAX)
	
	DECLARE @ysnShowOpenContract BIT
			, @ysnShowStorage BIT
	SELECT @ysnShowStorage = ysnShowStorage
			, @ysnShowOpenContract = ysnShowOpenContract
	FROM tblGRCompanyPreference

	IF OBJECT_ID (N'tempdb.dbo.##ItemsSettlement') IS NOT NULL
		DROP TABLE ##ItemsSettlement

	SET @sql = 'CREATE TABLE ##ItemsSettlement (ItemName VARCHAR(50),PivotColumn VARCHAR(50),Amount NUMERIC(18,6), UnitMeasure VARCHAR(50), intEntityId INT, PivotColumnId INT)';
	EXEC(@sql);

	IF @ysnShowStorage = 1 AND @ysnShowOpenContract = 1
		INSERT INTO ##ItemsSettlement
		SELECT * FROM vyuGRItemsSettlementStorageReport WHERE intEntityId = @intEntityId
		UNION ALL
		SELECT * FROM vyuGRItemsSettlementOpenContractReport WHERE intEntityId = @intEntityId
	ELSE IF @ysnShowStorage = 1 AND @ysnShowOpenContract = 0
		INSERT INTO ##ItemsSettlement
		SELECT * FROM vyuGRItemsSettlementStorageReport WHERE intEntityId = @intEntityId
	ELSE IF @ysnShowStorage = 0 AND @ysnShowOpenContract = 1
		INSERT INTO ##ItemsSettlement
		SELECT * FROM vyuGRItemsSettlementOpenContractReport WHERE intEntityId = @intEntityId	

	--pivoting process
	IF OBJECT_ID('tempdb..##TableFinalResult') IS NOT NULL
		DROP TABLE ##TableFinalResult
	IF OBJECT_ID('tempdb..##TempTableHeaders') IS NOT NULL
		DROP TABLE ##TempTableHeaders
	IF OBJECT_ID('tempdb..##TempTableAddColumns') IS NOT NULL
		DROP TABLE ##TempTableAddColumns

	SET @cols = STUFF(
                 (
		            SELECT ',' + QUOTENAME(d.PivotColumn)
					FROM (
							SELECT DISTINCT c.[PivotColumn] PivotColumn, c.[PivotColumnId]
							FROM (							
									SELECT *
									FROM ##ItemsSettlement
							) c
					) d
					ORDER BY d.PivotColumnId
					FOR XML PATH(''), TYPE
                 ).value('.', 'nvarchar(max)'), 1, 1, '');
	SET @query = 'SELECT [1] = 0, [intEntityId], [ItemName] AS Item, [UnitMeasure] AS UOM, ' + @cols + '
					INTO ##TempTableHeaders
					FROM (
							SELECT ItemName
								,PivotColumn AS columns
								,Amount 
								,UnitMeasure 
								,intEntityId 
								,PivotColumnId 
							FROM ##ItemsSettlement
						)x pivot (max(Amount) for columns in ('+@cols+')) p';
	EXECUTE (@query);	

	SET @sql = 'CREATE TABLE ##TableFinalResult (col_1 VARCHAR(50), col_2 VARCHAR(50), col_3 VARCHAR(50), col_4 VARCHAR(50), col_5 VARCHAR(50), 
									col_6 VARCHAR(50), col_7 VARCHAR(50), col_8 VARCHAR(50), col_9 VARCHAR(50), col_10 VARCHAR(50), 
									col_11 VARCHAR(50), col_12 VARCHAR(50), col_13 VARCHAR(50), col_14 VARCHAR(50), col_15 VARCHAR(50))';
	EXEC(@sql);

	SELECT @cnt = (COUNT(*) + 1)
	FROM tempdb.sys.columns
	WHERE object_id = object_id('tempdb..##TempTableHeaders')

	--create the table that will be outer applied to pivoted table (#TempTable)
	SET @sql = 'CREATE TABLE ##TempTableAddColumns(col_' + CAST(@cnt AS VARCHAR(2)) + ' VARCHAR(50) NULL)'
	EXEC (@sql);

	IF @cnt > 1
	BEGIN
		WHILE (@cnt < 15)
		BEGIN
			SET @cnt = @cnt + 1;

			SET @sql = 'ALTER TABLE ##TempTableAddColumns ADD col_' + CAST(@cnt AS VARCHAR(2)) + ' VARCHAR(50) NULL';	
			EXEC (@sql)	
		END

		SET @columnName = STUFF(
						 (
							SELECT ''','''+ c.name
							FROM (						
									SELECT name
									FROM tempdb.sys.columns
									WHERE object_id = object_id('tempdb..##TempTableHeaders') 
									UNION ALL
									SELECT name
									FROM tempdb.sys.columns
									WHERE object_id = object_id('tempdb..##TempTableAddColumns')
							) c
							FOR XML PATH('')), 1, 1, '''');
		SET @columnName = RIGHT(@columnName, LEN(@columnName) - 2)

		SET @sql = 'INSERT INTO ##TableFinalResult SELECT ' + @columnName + ''''
		EXEC (@sql);

		INSERT INTO ##TableFinalResult
		SELECT * FROM ##TempTableHeaders
		OUTER APPLY (
						SELECT * 
						FROM ##TempTableAddColumns
					) TTAD

		SELECT TOP 1 *
		FROM ##TableFinalResult
		UNION ALL
		SELECT	col_1
				, col_2
				, col_3
				, col_4
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),col_5))) col_5
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),col_6))) col_6
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),col_7))) col_7
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),col_8))) col_8
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),col_9))) col_9
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),col_10))) col_10
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),col_11))) col_11
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),col_12))) col_12
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),col_13))) col_13
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),col_14))) col_14
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),col_15))) col_15
		FROM ##TableFinalResult 
		WHERE col_1 <> '1'
		GROUP BY col_1,col_2,col_3,col_4 --fixed columns
	
	END
	ELSE
	BEGIN
		SELECT * 
		FROM ##TableFinalResult
	END
END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH

--EXEC uspGRItemsSettlementReport 16
--select * from tblEMEntity where intEntityId = 16