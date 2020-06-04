CREATE PROCEDURE [dbo].[uspGRDiscountTableReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN TRY
	SET FMTONLY OFF

	DECLARE @ErrMsg NVARCHAR(MAX)

	DECLARE @intDiscountScheduleCodeId INT;

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

	SELECT @intDiscountScheduleCodeId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intDiscountScheduleCodeId';

	-- Set to show the incremental or the extended tab
	DECLARE @ysnDisplayIncremental BIT = 1;

	IF @ysnDisplayIncremental = 1
	BEGIN
		WITH tmpIncrementalTable AS (
			SELECT
				SCHED.intDiscountScheduleId
				,COMMODITY.strCommodityCode
				,SCHED.strDiscountDescription
				,ITEM.intItemId
				,ITEM.strItemNo
				,ITEM.strDescription
				,SCHEDLINE.intDiscountScheduleLineId
				,SCHEDLINE.intDiscountScheduleCodeId
				,SCHEDLINE.dblRangeEndingValue
				,SCHEDLINE.dblRangeStartingValue
				,SCHEDLINE.dblIncrementValue
				,[dblDiscountValueInc] = ((SCHEDLINE.dblRangeEndingValue - SCHEDLINE.dblRangeStartingValue) / SCHEDLINE.dblIncrementValue) * SCHEDLINE.dblDiscountValue
				,[dblShrinkValueInc] = ((SCHEDLINE.dblRangeEndingValue - SCHEDLINE.dblRangeStartingValue) / SCHEDLINE.dblIncrementValue) * SCHEDLINE.dblShrinkValue
				,UOM.strUnitMeasure
				,SHRINK.ysnHasShrink
				,SCHEDCODE.dtmEffectiveDate
				,SCHEDCODE.dtmTerminationDate
				,[intRow] = ROW_NUMBER() OVER (ORDER BY
					CASE WHEN SCHEDLINE.dblRangeStartingValue < SCHEDLINE.dblRangeEndingValue
					THEN SCHEDLINE.dblRangeStartingValue END ASC,
					CASE WHEN SCHEDLINE.dblRangeStartingValue >= SCHEDLINE.dblRangeEndingValue
					THEN SCHEDLINE.dblRangeStartingValue END DESC)
			FROM tblGRDiscountScheduleCode SCHEDCODE
			INNER JOIN tblGRDiscountSchedule SCHED
				ON SCHED.intDiscountScheduleId = SCHEDCODE.intDiscountScheduleId
			INNER JOIN tblICItem ITEM
				ON ITEM.intItemId = SCHEDCODE.intItemId
			INNER JOIN tblICCommodity COMMODITY
				ON COMMODITY.intCommodityId = ITEM.intCommodityId
			LEFT JOIN tblGRDiscountScheduleLine SCHEDLINE
				ON SCHEDLINE.intDiscountScheduleCodeId = SCHEDCODE.intDiscountScheduleCodeId
			LEFT JOIN tblICItemUOM IUOM
				ON IUOM.intItemId = ITEM.intItemId
				AND IUOM.ysnStockUnit = 1
			LEFT JOIN tblICUnitMeasure UOM
				ON UOM.intUnitMeasureId = ISNULL(SCHEDCODE.intUnitMeasureId, IUOM.intUnitMeasureId)
			OUTER APPLY (
				SELECT [ysnHasShrink] = CAST((CASE WHEN MAX(dblShrinkValue) = 0 THEN 0 ELSE 1 END) AS BIT)
				FROM tblGRDiscountScheduleLine
				WHERE intDiscountScheduleCodeId = SCHEDCODE.intDiscountScheduleCodeId
			) SHRINK
			WHERE SCHEDCODE.intDiscountScheduleCodeId = @intDiscountScheduleCodeId
		)
		SELECT
			T1.intDiscountScheduleId
			,T1.strCommodityCode
			,T1.strDiscountDescription
			,T1.intItemId
			,T1.strItemNo
			,T1.strDescription
			,T1.intDiscountScheduleLineId
			,T1.intDiscountScheduleCodeId
			,T1.dblRangeEndingValue
			,T1.dblRangeStartingValue
			,T1.dblIncrementValue
			,T1.strUnitMeasure
			,T1.ysnHasShrink
			,T1.dtmEffectiveDate
			,T1.dtmTerminationDate
			,[dblDiscountValue] = SUM(T2.dblDiscountValueInc)
			,[dblShrinkValue] =	SUM(T2.dblShrinkValueInc)
		FROM tmpIncrementalTable T1
		INNER JOIN tmpIncrementalTable T2
			ON T1.intRow >= T2.intRow
		GROUP BY
			T1.intDiscountScheduleId
			,T1.strCommodityCode
			,T1.strDiscountDescription
			,T1.intItemId
			,T1.strItemNo
			,T1.strDescription
			,T1.intDiscountScheduleLineId
			,T1.intDiscountScheduleCodeId
			,T1.dblRangeEndingValue
			,T1.dblRangeStartingValue
			,T1.dblIncrementValue
			,T1.strUnitMeasure
			,T1.ysnHasShrink
			,T1.dtmEffectiveDate
			,T1.dtmTerminationDate
			,T1.intRow
		ORDER BY T1.intRow ASC
	END
	ELSE
	BEGIN
		IF OBJECT_ID (N'tempdb.dbo.##tmpGRDiscountTableIncremental') IS NOT NULL
			DROP TABLE ##tmpGRDiscountTableIncremental
		IF OBJECT_ID (N'tempdb.dbo.##tmpGRDiscountTableExtended') IS NOT NULL
			DROP TABLE ##tmpGRDiscountTableExtended

		SELECT
			SCHED.intDiscountScheduleId
			,COMMODITY.strCommodityCode
			,SCHED.strDiscountDescription
			,ITEM.intItemId
			,ITEM.strItemNo
			,ITEM.strDescription
			,SCHEDLINE.intDiscountScheduleLineId
			,SCHEDLINE.intDiscountScheduleCodeId
			,SCHEDLINE.dblRangeEndingValue
			,SCHEDLINE.dblRangeStartingValue
			,SCHEDLINE.dblIncrementValue
			,SCHEDLINE.dblDiscountValue
			,SCHEDLINE.dblShrinkValue
			,UOM.strUnitMeasure
			,SHRINK.ysnHasShrink
		INTO ##tmpGRDiscountTableIncremental
		FROM tblGRDiscountScheduleCode SCHEDCODE
		INNER JOIN tblGRDiscountSchedule SCHED
			ON SCHED.intDiscountScheduleId = SCHEDCODE.intDiscountScheduleId
		INNER JOIN tblICItem ITEM
			ON ITEM.intItemId = SCHEDCODE.intItemId
		INNER JOIN tblICCommodity COMMODITY
			ON COMMODITY.intCommodityId = ITEM.intCommodityId
		LEFT JOIN tblGRDiscountScheduleLine SCHEDLINE
			ON SCHEDLINE.intDiscountScheduleCodeId = SCHEDCODE.intDiscountScheduleCodeId
		LEFT JOIN tblICItemUOM IUOM
			ON IUOM.intItemId = ITEM.intItemId
			AND IUOM.ysnStockUnit = 1
		LEFT JOIN tblICUnitMeasure UOM
			ON UOM.intUnitMeasureId = ISNULL(SCHEDCODE.intUnitMeasureId, IUOM.intUnitMeasureId)
		OUTER APPLY (
			SELECT [ysnHasShrink] = CAST((CASE WHEN MAX(dblShrinkValue) = 0 THEN 0 ELSE 1 END) AS BIT)
			FROM tblGRDiscountScheduleLine
			WHERE intDiscountScheduleCodeId = SCHEDCODE.intDiscountScheduleCodeId
		) SHRINK
		WHERE SCHEDCODE.intDiscountScheduleCodeId = @intDiscountScheduleCodeId
		-- Create empty temp table for extended list
		SELECT TOP 0 *
		INTO ##tmpGRDiscountTableExtended
		FROM ##tmpGRDiscountTableIncremental;

		DECLARE 
			@intCursorDiscountScheduleLineId INT
			,@dblRangeStartingValue NUMERIC(24, 10) 
			,@dblRangeEndingValue NUMERIC(24, 10) 
			,@dblIncrementValue NUMERIC(24, 10) 
			,@dblDiscountValue NUMERIC(24, 10) 
			,@dblShrinkValue NUMERIC(24, 10)
			,@dblNextRangeStartingValue NUMERIC(24, 10)
			,@dblNewDiscountValue NUMERIC(24, 10)
			,@dblNewShrinkValue NUMERIC(24, 10)
			,@dblNewEndingValue NUMERIC(24, 10)
			,@ysnIsAscending BIT;

		SET @dblNewDiscountValue = 0;
		SET @dblNewShrinkValue = 0;

		-- Loop through each discount schedule lines along with the starting value from the next row
		DECLARE intListCursor CURSOR LOCAL FAST_FORWARD
		FOR
		WITH TMP AS (
			SELECT 
				*
				-- Conditionally sort the schedule lines based on sblRangeStartingValue
				,[intRow] = ROW_NUMBER() OVER (ORDER BY
					CASE WHEN dblRangeStartingValue < dblRangeEndingValue
					THEN dblRangeStartingValue END ASC,
					CASE WHEN dblRangeStartingValue >= dblRangeEndingValue
					THEN dblRangeStartingValue END DESC)
			FROM ##tmpGRDiscountTableIncremental
		)
		SELECT
			TMP.intDiscountScheduleLineId
			,TMP.dblRangeStartingValue
			,TMP.dblRangeEndingValue
			,TMP.dblIncrementValue
			,TMP.dblDiscountValue
			,TMP.dblShrinkValue
			,[dblNextRangeStartingValue]=NEXTROW.dblRangeStartingValue
			,[ysnIsAscending] = CAST((CASE WHEN TMP.dblRangeStartingValue < TMP.dblRangeEndingValue THEN 1 ELSE 0 END) AS BIT)
		FROM TMP
		LEFT JOIN TMP NEXTROW
			ON NEXTROW.intRow = TMP.intRow + 1
			AND TMP.intDiscountScheduleCodeId = NEXTROW.intDiscountScheduleCodeId;

		OPEN intListCursor;
		FETCH NEXT FROM intListCursor
		INTO 
			@intCursorDiscountScheduleLineId
			,@dblRangeStartingValue
			,@dblRangeEndingValue
			,@dblIncrementValue
			,@dblDiscountValue
			,@dblShrinkValue
			,@dblNextRangeStartingValue
			,@ysnIsAscending;
		
		WHILE @@FETCH_STATUS = 0
		BEGIN
			-- Ascending logic
			IF @ysnIsAscending = 1
			BEGIN
				WHILE @dblRangeStartingValue < @dblRangeEndingValue
				BEGIN
					SET @dblNewEndingValue = CASE
						WHEN (@dblRangeStartingValue + @dblIncrementValue) > @dblRangeEndingValue
							THEN @dblRangeEndingValue - (CASE WHEN @dblRangeEndingValue = @dblNextRangeStartingValue THEN 0.01 ELSE 0 END)
						WHEN (@dblRangeStartingValue + @dblIncrementValue) >= @dblNextRangeStartingValue AND @dblNextRangeStartingValue > 0
							THEN @dblNextRangeStartingValue - 0.01
						WHEN (@dblRangeStartingValue + @dblIncrementValue) < @dblRangeEndingValue
							THEN (@dblRangeStartingValue + @dblIncrementValue) - 0.01
						WHEN @dblRangeEndingValue < @dblNextRangeStartingValue AND @dblNextRangeStartingValue > 0
							THEN @dblNextRangeStartingValue - 0.01
						ELSE @dblRangeStartingValue + @dblIncrementValue END
					
					IF @dblIncrementValue <= 0
						SET @dblNewEndingValue = @dblRangeEndingValue;

					SET @dblNewDiscountValue += @dblDiscountValue;
					SET @dblNewShrinkValue += @dblShrinkValue;

					-- Insert entry to extended table
					INSERT INTO ##tmpGRDiscountTableExtended
					SELECT
						INC.intDiscountScheduleId
						,INC.strCommodityCode
						,INC.strDiscountDescription
						,INC.intItemId
						,INC.strItemNo
						,INC.strDescription
						,INC.intDiscountScheduleLineId
						,INC.intDiscountScheduleCodeId
						,@dblNewEndingValue
						,@dblRangeStartingValue
						,INC.dblIncrementValue
						,@dblNewDiscountValue
						,@dblNewShrinkValue
						,INC.strUnitMeasure
						,INC.ysnHasShrink
					FROM ##tmpGRDiscountTableIncremental INC
					WHERE intDiscountScheduleLineId = @intCursorDiscountScheduleLineId
					
					SET @dblRangeStartingValue += @dblIncrementValue;
					IF @dblIncrementValue <= 0
						BREAK;
				END
			END
			ELSE
			-- Descending logic
			BEGIN
				WHILE @dblRangeStartingValue > @dblRangeEndingValue
				BEGIN
					SET @dblNewEndingValue = CASE
						WHEN (@dblRangeStartingValue) > (@dblRangeEndingValue - @dblIncrementValue)
							THEN @dblRangeStartingValue + @dblIncrementValue
								+ (CASE WHEN (@dblRangeStartingValue + @dblIncrementValue) >= @dblNextRangeStartingValue
									OR @dblNextRangeStartingValue IS NULL
									THEN 0.01 ELSE 0 END)
						WHEN @dblRangeStartingValue <= (@dblRangeEndingValue - @dblIncrementValue) THEN
							CASE WHEN @dblNextRangeStartingValue IS NOT NULL THEN
								CASE WHEN @dblRangeEndingValue = @dblNextRangeStartingValue
								THEN @dblRangeEndingValue + 0.01
								ELSE
									CASE WHEN @dblNextRangeStartingValue > 0 THEN @dblNextRangeStartingValue + 0.01 ELSE @dblRangeEndingValue END
								END
							ELSE @dblRangeEndingValue END
						END;
					
					IF @dblIncrementValue = 0
						SET @dblNewEndingValue = @dblRangeEndingValue;
					
					SET @dblNewDiscountValue += @dblDiscountValue;
					SET @dblNewShrinkValue += @dblShrinkValue;

					-- Insert entry to extended table
					INSERT INTO ##tmpGRDiscountTableExtended
					SELECT
						INC.intDiscountScheduleId
						,INC.strCommodityCode
						,INC.strDiscountDescription
						,INC.intItemId
						,INC.strItemNo
						,INC.strDescription
						,INC.intDiscountScheduleLineId
						,INC.intDiscountScheduleCodeId
						,@dblNewEndingValue
						,@dblRangeStartingValue
						,INC.dblIncrementValue
						,@dblNewDiscountValue
						,@dblNewShrinkValue
						,INC.strUnitMeasure
						,INC.ysnHasShrink
					FROM ##tmpGRDiscountTableIncremental INC
					WHERE intDiscountScheduleLineId = @intCursorDiscountScheduleLineId
					
					SET @dblRangeStartingValue += @dblIncrementValue;
					IF @dblIncrementValue = 0
						BREAK;
				END
			END

			FETCH NEXT FROM intListCursor 
			INTO 
				@intCursorDiscountScheduleLineId
				,@dblRangeStartingValue
				,@dblRangeEndingValue
				,@dblIncrementValue
				,@dblDiscountValue
				,@dblShrinkValue
				,@dblNextRangeStartingValue
				,@ysnIsAscending;
		END

		CLOSE intListCursor;
		DEALLOCATE intListCursor;
		
		-- Fetch final result
		SELECT * FROM ##tmpGRDiscountTableExtended
	END
END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH