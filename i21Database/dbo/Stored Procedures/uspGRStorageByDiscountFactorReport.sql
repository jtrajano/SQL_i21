CREATE PROCEDURE [dbo].[uspGRStorageByDiscountFactorReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN TRY
	SET FMTONLY OFF

	DECLARE @ErrMsg NVARCHAR(MAX)

	DECLARE @strCommodityCode NVARCHAR(40)
	DECLARE @strDiscountCode NVARCHAR(40)

	IF LTRIM(RTRIM(@xmlParam)) = ''
		SET @xmlParam = NULL

	DECLARE @temp_xml_table TABLE 
	(
		[fieldname] NVARCHAR(50)
		,[condition] NVARCHAR(20)
		,[from] NVARCHAR(MAX)
		,[to] NVARCHAR(MAX)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
	)
	DECLARE @xmlDocumentId AS INT

	EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT,@xmlParam

	INSERT INTO @temp_xml_table
	SELECT *
	FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2) WITH 
	(
		[fieldname] NVARCHAR(50)
		,[condition] NVARCHAR(20)
		,[from] NVARCHAR(50)
		,[to] NVARCHAR(50)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
	)

	DECLARE @intCommodityId INT
	DECLARE @intLocationId INT
	DECLARE @dtmReportDate DATETIME

	SELECT @strCommodityCode = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strCommodityCode'

	SELECT @strDiscountCode = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strDiscountCode'

	--for pivoting
	DECLARE @cols NVARCHAR(MAX), 
			@query NVARCHAR(MAX),
			@cnt INT = 0, 
			@sql VARCHAR(max), 
			@columnName VARCHAR(MAX)
	
	IF OBJECT_ID (N'tempdb.dbo.##StorageDiscounts') IS NOT NULL
		DROP TABLE ##StorageDiscounts

	SET @sql = 'CREATE TABLE ##StorageDiscounts (ReadingRange VARCHAR(50),PivotColumn VARCHAR(100),Units DECIMAL(18,6),strCommodityCode NVARCHAR(40),strDiscountCode NVARCHAR(40), PivotColumnId INT)';
	EXEC(@sql);

	INSERT INTO ##StorageDiscounts
	SELECT
		strReadingRange
		,strLocationName
		,dblSubTotalByLocation
		,strCommodityCode
		,strDiscountCode
		,intCompanyLocationId
	FROM vyuGRStorageByDiscountReport 
	WHERE strCommodityCode = ISNULL(@strCommodityCode,strCommodityCode)
		AND strDiscountCode = ISNULL(@strDiscountCode,strDiscountCode)

	--pivoting process
	IF OBJECT_ID('tempdb..##TableFinalResult2') IS NOT NULL
		DROP TABLE ##TableFinalResult2
	IF OBJECT_ID('tempdb..##TempTableHeaders2') IS NOT NULL
		DROP TABLE ##TempTableHeaders2
	IF OBJECT_ID('tempdb..##TempTableAddColumns') IS NOT NULL
		DROP TABLE ##TempTableAddColumns

	SET @cols = STUFF(
                 (
		            SELECT ',' + QUOTENAME(d.PivotColumn)
					FROM (
							SELECT DISTINCT REPLACE(c.[PivotColumn], '''', '''''') PivotColumn, c.[PivotColumnId]
							FROM (							
									SELECT *
									FROM ##StorageDiscounts
							) c
					) d
					ORDER BY d.PivotColumnId
					FOR XML PATH(''), TYPE
                 ).value('.', 'nvarchar(max)'), 1, 1, '');
	SET @query = 'SELECT [1] = 0, [strCommodityCode],[strDiscountCode], [ReadingRange] AS [Reading Range], ' + @cols + '
					INTO ##TempTableHeaders2
					FROM (
							SELECT strCommodityCode
								,PivotColumn AS columns
								,strDiscountCode 
								,Units
								,PivotColumnId
								,ReadingRange
							FROM ##StorageDiscounts
						)x pivot (max(Units) for columns in ('+@cols+')) p';
	EXECUTE (@query);	

	SET @sql = 'CREATE TABLE ##TableFinalResult2 (col_1 VARCHAR(50), col_2 VARCHAR(50), col_3 VARCHAR(50), col_4 VARCHAR(50), col_5 VARCHAR(50), 
									col_6 VARCHAR(50), col_7 VARCHAR(50), col_8 VARCHAR(50), col_9 VARCHAR(50), col_10 VARCHAR(50), 
									col_11 VARCHAR(50), col_12 VARCHAR(50), col_13 VARCHAR(50), col_14 VARCHAR(50), col_15 VARCHAR(50), 
									col_16 VARCHAR(50), col_17 VARCHAR(50), col_18 VARCHAR(50), col_19 VARCHAR(50), col_20 VARCHAR(50),
									col_21 VARCHAR(50), col_22 VARCHAR(50), col_23 VARCHAR(50), col_24 VARCHAR(50), col_25 VARCHAR(50),
									col_26 VARCHAR(50), col_27 VARCHAR(50), col_28 VARCHAR(50), col_29 VARCHAR(50), col_30 VARCHAR(50))';
	EXEC(@sql);

	SELECT @cnt = (COUNT(*) + 1)
	FROM tempdb.sys.columns
	WHERE object_id = object_id('tempdb..##TempTableHeaders2')

	--create the table that will be outer applied to pivoted table (#TempTable)
	SET @sql = 'CREATE TABLE ##TempTableAddColumns(col_' + CAST(@cnt AS VARCHAR(2)) + ' VARCHAR(50) NULL)'
	EXEC (@sql);

	IF @cnt > 1
	BEGIN
		WHILE (@cnt < 30)
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
									WHERE object_id = object_id('tempdb..##TempTableHeaders2') 
									UNION ALL
									SELECT name
									FROM tempdb.sys.columns
									WHERE object_id = object_id('tempdb..##TempTableAddColumns')
							) c
							FOR XML PATH('')), 1, 1, '''');
		SET @columnName = RIGHT(@columnName, LEN(@columnName) - 2)

		SET @sql = 'INSERT INTO ##TableFinalResult2 SELECT ' + @columnName + ''''
		EXEC (@sql);
				
		INSERT INTO ##TableFinalResult2
		SELECT DISTINCT
			t1.col_1, S.strCommodityCode, S.strDiscountCode
			, t1.col_4, t1.col_5, t1.col_6, t1.col_7, t1.col_8
			, t1.col_9, t1.col_10, t1.col_11, t1.col_12, t1.col_13
			, t1.col_14, t1.col_15, t1.col_16, t1.col_17, t1.col_18
			, t1.col_19, t1.col_20, t1.col_21, t1.col_22, t1.col_23
			, t1.col_24, t1.col_25, t1.col_26, t1.col_27, t1.col_28
			, t1.col_29, t1.col_30
		FROM ##StorageDiscounts S
		OUTER APPLY (
			SELECT * FROM ##TableFinalResult2
		) t1
		
		INSERT INTO ##TableFinalResult2
		SELECT * 
		FROM ##TempTableHeaders2
		OUTER APPLY (
			SELECT * FROM ##TempTableAddColumns
		) TTAD
		
		SELECT *
		FROM ##TableFinalResult2
		WHERE col_1 = '1' 
			AND col_2 <> 'strCommodityCode'
			AND col_3 <> 'strDiscountCode'
		UNION ALL
		SELECT	col_1
				, col_2
				, col_3
				, col_4
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_5,0)))) col_5
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_6,0)))) col_6
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_7,0)))) col_7
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_8,0)))) col_8
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_9,0)))) col_9
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_10,0)))) col_10
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_11,0)))) col_11
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_12,0)))) col_12
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_13,0)))) col_13
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_14,0)))) col_14
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_15,0)))) col_15
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_16,0)))) col_16
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_17,0)))) col_17
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_18,0)))) col_18
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_19,0)))) col_19
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_20,0)))) col_20
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_21,0)))) col_21
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_22,0)))) col_22
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_23,0)))) col_23
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_24,0)))) col_24
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_25,0)))) col_25
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_26,0)))) col_26
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_27,0)))) col_27
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_28,0)))) col_28
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_29,0)))) col_29
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_30,0)))) col_30
		FROM ##TableFinalResult2 
		WHERE col_1 <> '1'
		GROUP BY col_1,col_2,col_3,col_4 --fixed columns
		UNION ALL
		SELECT	-1
				, col_2
				, col_3
				, 'Total'
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_5,0)))) col_5
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_6,0)))) col_6
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_7,0)))) col_7
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_8,0)))) col_8
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_9,0)))) col_9
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_10,0)))) col_10
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_11,0)))) col_11
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_12,0)))) col_12
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_13,0)))) col_13
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_14,0)))) col_14
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_15,0)))) col_15
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_16,0)))) col_16
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_17,0)))) col_17
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_18,0)))) col_18
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_19,0)))) col_19
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_20,0)))) col_20
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_21,0)))) col_21
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_22,0)))) col_22
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_23,0)))) col_23
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_24,0)))) col_24
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_25,0)))) col_25
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_26,0)))) col_26
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_27,0)))) col_27
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_28,0)))) col_28
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_29,0)))) col_29
				, CONVERT(NVARCHAR(MAX),SUM(CONVERT(NUMERIC(18,2),ISNULL(col_30,0)))) col_30
		FROM ##TableFinalResult2 
		WHERE col_1 <> '1'
		GROUP BY col_1,col_2,col_3 --fixed columns
		ORDER BY col_4 DESC
	END
	ELSE
	BEGIN
		SELECT * FROM ##TableFinalResult2
		ORDER BY col_4 DESC
	END
END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH