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
	DECLARE @ysnLicensed BIT

	SELECT @strCommodityCode = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strCommodityCode'

	SELECT @strDiscountCode = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strDiscountCode'

	SELECT @ysnLicensed = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'ysnLicensed'

	--for pivoting
	DECLARE @cols NVARCHAR(MAX), 
			@query NVARCHAR(MAX),
			@cnt INT = 0, 
			@sql VARCHAR(max), 
			@columnName VARCHAR(MAX)
	
	-- This variable will control the max number of locations per table
	DECLARE @intLocationsPerTable INT = 12;

	IF OBJECT_ID (N'tempdb.dbo.##StorageDiscounts') IS NOT NULL
		DROP TABLE ##StorageDiscounts

	SET @sql = 'CREATE TABLE ##StorageDiscounts (ReadingRange VARCHAR(50),PivotColumn VARCHAR(100),Units DECIMAL(18,6),strCommodityCode NVARCHAR(40),strDiscountCode NVARCHAR(40), PivotColumnId INT, ysnLicensed BIT)';
	EXEC(@sql);

	INSERT INTO ##StorageDiscounts
	SELECT
		strReadingRange
		,strLocationName
		,dblSubTotalByLocation
		,strCommodityCode
		,strDiscountCode
		,intCompanyLocationId
		,ysnLicensed
	FROM vyuGRStorageByDiscountReport 
	WHERE strCommodityCode = ISNULL(@strCommodityCode,strCommodityCode)
		AND strDiscountCode = ISNULL(@strDiscountCode,strDiscountCode)
		AND ysnLicensed = ISNULL(@ysnLicensed,ysnLicensed)

	--pivoting process
	IF OBJECT_ID('tempdb..##TableFinalResultTemp') IS NOT NULL
		DROP TABLE ##TableFinalResultTemp
	IF OBJECT_ID('tempdb..##TableFinalResult2') IS NOT NULL
		DROP TABLE ##TableFinalResult2
	IF OBJECT_ID('tempdb..##TempTableHeaders2') IS NOT NULL
		DROP TABLE ##TempTableHeaders2
	IF OBJECT_ID('tempdb..##TempTableAddColumns') IS NOT NULL
		DROP TABLE ##TempTableAddColumns

	SET @sql = 'CREATE TABLE ##TableFinalResult2 (col_1 VARCHAR(50), col_2 VARCHAR(50), col_3 VARCHAR(50), col_4 VARCHAR(50), col_5 VARCHAR(50), 
									col_6 VARCHAR(50), col_7 VARCHAR(50), col_8 VARCHAR(50), col_9 VARCHAR(50), col_10 VARCHAR(50), 
									col_11 VARCHAR(50), col_12 VARCHAR(50), col_13 VARCHAR(50), col_14 VARCHAR(50), col_15 VARCHAR(50), 
									col_16 VARCHAR(50), col_17 VARCHAR(50), col_18 VARCHAR(50), col_19 VARCHAR(50), col_20 VARCHAR(50),
									col_21 VARCHAR(50), col_22 VARCHAR(50), col_23 VARCHAR(50), col_24 VARCHAR(50), col_25 VARCHAR(50),
									col_26 VARCHAR(50), col_27 VARCHAR(50), col_28 VARCHAR(50), col_29 VARCHAR(50), col_30 VARCHAR(50))';
	EXEC(@sql);

	SELECT @cnt = (COUNT(DISTINCT [PivotColumn]))
	FROM ##StorageDiscounts

	IF @cnt > 1
	BEGIN
		-- Loop through each Discount Code/Commodity Code header
		DECLARE @strCommodityCodeHeader NVARCHAR(40)
		DECLARE @strDiscountCodeHeader NVARCHAR(40)

		DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
		FOR
		SELECT DISTINCT strDiscountCode, strCommodityCode FROM ##StorageDiscounts;

		DECLARE @tblLocations AS TABLE(
				PivotColumn NVARCHAR(100),
				PivotColumnId INT,
				intRow INT
			);

		OPEN intListCursor;
		-- Initial fetch attempt
		FETCH NEXT FROM intListCursor INTO @strDiscountCodeHeader, @strCommodityCodeHeader;
		WHILE @@FETCH_STATUS = 0
		BEGIN
			DELETE FROM @tblLocations;
			-- Get all of the retrieved locations along with row number
			INSERT INTO @tblLocations
			SELECT *, ROW_NUMBER() OVER (ORDER BY [PivotColumn]) AS intRow
			FROM (
				SELECT DISTINCT REPLACE(c.[PivotColumn], '''', '''''') PivotColumn, c.[PivotColumnId]
				FROM (							
						SELECT *
						FROM ##StorageDiscounts
						WHERE strDiscountCode = @strDiscountCodeHeader
						AND strCommodityCode = @strCommodityCodeHeader
				) c
			) t;

			-- Get the total number of locations
			DECLARE @intLocationCount INT;
			SELECT @intLocationCount = COUNT(*) FROM @tblLocations;

			DECLARE @intTableCounter INT = 0;

			-- SET @cols = STUFF(
			-- 			(
			-- 				SELECT ',' + QUOTENAME(d.PivotColumn)
			-- 				FROM @tblLocations d
			-- 				ORDER BY d.PivotColumnId
			-- 				FOR XML PATH(''), TYPE
			-- 			).value('.', 'nvarchar(max)'), 1, 1, '');

			-- Fetch only the records from locations in the current table
			WHILE @intLocationCount > (@intTableCounter * @intLocationsPerTable)
			BEGIN
				SET @cols = STUFF(
						(
							SELECT ',' + QUOTENAME(d.PivotColumn)
							FROM @tblLocations d
							WHERE d.intRow BETWEEN (@intTableCounter * @intLocationsPerTable) + 1 AND ((@intTableCounter + 1) * @intLocationsPerTable)
							ORDER BY d.PivotColumn
							FOR XML PATH(''), TYPE
						).value('.', 'nvarchar(max)'), 1, 1, '');

				DECLARE @intTableTag INT = @intTableCounter + 10;

				SET @query = 'SELECT [1] = 0, [strCommodityCode],[strDiscountCode], [ReadingRange] AS [Reading Range], [' + CAST(@intTableTag AS NVARCHAR(3)) + '] = @intTableNum, ' + @cols + '
								INTO ##TempTableHeaders2
								FROM (
										SELECT strCommodityCode
											,PivotColumn AS columns
											,strDiscountCode 
											,Units
											,PivotColumnId
											,ReadingRange
										FROM ##StorageDiscounts
										WHERE strDiscountCode =  @strDiscountCode2
										AND strCommodityCode = @strCommodityCode2
									)x pivot (max(Units) for columns in ('+@cols+')) p';
				-- EXECUTE (@query);
				EXECUTE sp_executesql @query
					, N'@intTableNum INT, @strCommodityCode2 NVARCHAR(40), @strDiscountCode2 NVARCHAR(40)'
					, @intTableNum = @intTableTag
					, @strDiscountCode2 = @strDiscountCodeHeader
					, @strCommodityCode2 = @strCommodityCodeHeader;

				DECLARE @cnt2 AS INT;

				SELECT @cnt2 = COUNT(PivotColumnId)
				FROM @tblLocations
				WHERE intRow BETWEEN (@intTableCounter * @intLocationsPerTable) + 1 AND ((@intTableCounter + 1) * @intLocationsPerTable)

				-- Initialize column count for empty columns
				SET @cnt2 = @cnt2 + 6;
				--create the table that will be outer applied to pivoted table (#TempTable)
				SET @sql = 'CREATE TABLE ##TempTableAddColumns(col_' + CAST(@cnt2 AS VARCHAR(2)) + ' VARCHAR(50) NULL)'
				EXEC (@sql);

				WHILE (@cnt2 < 30)
				BEGIN
					SET @cnt2 = @cnt2 + 1;
					SET @sql = 'ALTER TABLE ##TempTableAddColumns ADD col_' + CAST(@cnt2 AS VARCHAR(2)) + ' VARCHAR(50) NULL';	
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
				SET @columnName = RIGHT(@columnName, LEN(@columnName) - 2);

				SET @sql = 'CREATE TABLE ##TableFinalResultTemp (col_1 VARCHAR(50), col_2 VARCHAR(50), col_3 VARCHAR(50), col_4 VARCHAR(50), col_5 VARCHAR(50), 
										col_6 VARCHAR(50), col_7 VARCHAR(50), col_8 VARCHAR(50), col_9 VARCHAR(50), col_10 VARCHAR(50), 
										col_11 VARCHAR(50), col_12 VARCHAR(50), col_13 VARCHAR(50), col_14 VARCHAR(50), col_15 VARCHAR(50), 
										col_16 VARCHAR(50), col_17 VARCHAR(50), col_18 VARCHAR(50), col_19 VARCHAR(50), col_20 VARCHAR(50),
										col_21 VARCHAR(50), col_22 VARCHAR(50), col_23 VARCHAR(50), col_24 VARCHAR(50), col_25 VARCHAR(50),
										col_26 VARCHAR(50), col_27 VARCHAR(50), col_28 VARCHAR(50), col_29 VARCHAR(50), col_30 VARCHAR(50))';
				EXEC(@sql);

				SET @sql = 'INSERT INTO ##TableFinalResultTemp SELECT ' + @columnName + ''''
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
					SELECT * FROM ##TableFinalResultTemp
				) t1
				WHERE strDiscountCode = @strDiscountCodeHeader
				AND strCommodityCode = @strCommodityCodeHeader
				
				INSERT INTO ##TableFinalResult2
				SELECT * 
				FROM ##TempTableHeaders2
				OUTER APPLY (
					SELECT * FROM ##TempTableAddColumns
				) TTAD

				IF OBJECT_ID('tempdb..##TableFinalResultTemp') IS NOT NULL
					DROP TABLE ##TableFinalResultTemp;
				IF OBJECT_ID('tempdb..##TempTableHeaders2') IS NOT NULL
					DROP TABLE ##TempTableHeaders2;
				IF OBJECT_ID('tempdb..##TempTableAddColumns') IS NOT NULL
					DROP TABLE ##TempTableAddColumns;
			
				SET @intTableCounter = @intTableCounter + 1;
			END

			FETCH NEXT FROM intListCursor INTO @strDiscountCodeHeader, @strCommodityCodeHeader;
		END;

		CLOSE intListCursor;
		DEALLOCATE intListCursor;

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
				, col_5 -- Table Counter
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
		GROUP BY col_1,col_2,col_3,col_4,col_5 --fixed columns
		UNION ALL
		SELECT	-1
				, col_2
				, col_3
				, 'Total'
				, col_5 -- Table Counter
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
		GROUP BY col_1,col_2,col_3,col_5 --fixed columns
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