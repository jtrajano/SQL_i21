CREATE PROCEDURE [dbo].[uspRKGetCustomerOwnership]
	@dtmFromTransactionDate DATE = NULL
	, @dtmToTransactionDate DATE = NULL
	, @intCommodityId INT = NULL
	, @intItemId INT = NULL
	, @strPositionIncludes NVARCHAR(100) = NULL
	, @intLocationId INT = NULL

AS

IF OBJECT_ID('tempdb..#tempCustomer') IS NOT NULL
	DROP TABLE #tempCustomer
IF OBJECT_ID('tempdb..##temp1') IS NOT NULL
	DROP TABLE ##temp1
IF OBJECT_ID('tempdb..#final') IS NOT NULL
	DROP TABLE #final

BEGIN
	DECLARE @ysnDisplayAllStorage BIT
	SELECT @ysnDisplayAllStorage = ISNULL(ysnDisplayAllStorage, 0) FROM tblRKCompanyPreference

	SELECT CONVERT(INT, ROW_NUMBER() OVER (ORDER BY strStorageTypeDescription)) intRowNum
		, dtmDate
		, strStorageTypeDescription strDistribution
		, dblIn
		, dblOut
		, dblNet
		, intStorageScheduleTypeId
	INTO #tempCustomer
	FROM (
		SELECT dtmDate
			, strStorageTypeDescription
			, SUM(ROUND(dblInQty, 2)) dblIn
			, SUM(ROUND(ISNULL(dblOutQty, 0) + ISNULL(dblSettleUnit, 0), 2)) dblOut
			, ROUND(SUM(dblInQty), 2) - SUM(ROUND(ISNULL(dblOutQty, 0) + ISNULL(dblSettleUnit, 0), 2)) dblNet
			, intStorageScheduleTypeId
		FROM (
			--UNION ALL --Storages
			SELECT dtmDate
				, strStorageTypeDescription
				, SUM(dblInQty) AS dblInQty
				, SUM(dblOutQty) AS dblOutQty
				, intStorageScheduleTypeId AS intStorageScheduleTypeId
				, 0 AS dblSettleUnit
			FROM (
				SELECT CONVERT(VARCHAR(10),SH.dtmHistoryDate,110) dtmDate
					, S.strStorageTypeDescription
					, CASE WHEN strType = 'From Delivery Sheet'
								OR strType = 'From Scale'
								OR strType = 'From Transfer'
								OR strType = 'From Inventory Adjustment' THEN dblUnits
							ELSE 0 END AS dblInQty
					, CASE WHEN strType = 'Reduced By Inventory Shipment'
								OR strType = 'Settlement'
								OR strType = 'Transfer' THEN ABS(dblUnits)
							WHEN strType = 'Reverse Settlement' THEN ABS(dblUnits) * -1
							ELSE 0 END AS dblOutQty
					, S.intStorageScheduleTypeId
				FROM tblGRCustomerStorage CS
				INNER JOIN tblGRStorageHistory SH ON CS.intCustomerStorageId = SH.intCustomerStorageId
				INNER JOIN tblGRStorageType S ON CS.intStorageTypeId = S.intStorageScheduleTypeId
				WHERE CS.intCommodityId = @intCommodityId
					AND CS.intItemId = CASE WHEN ISNULL(@intItemId, 0) = 0 THEN CS.intItemId ELSE @intItemId END
					AND CS.intCompanyLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
													WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1
																						WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0
																						ELSE isnull(ysnLicensed, 0) END)
					AND CS.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId, 0) = 0 THEN CS.intCompanyLocationId ELSE @intLocationId END
			) t
			GROUP BY dtmDate
				, strStorageTypeDescription
				, intStorageScheduleTypeId
		
			UNION ALL --On Hold without Delivery Sheet
			SELECT CONVERT(VARCHAR(10), st.dtmTicketDateTime, 110) dtmDate
				, 'On Hold' as strStorageTypeDescription
				, CASE WHEN strInOutFlag = 'I' THEN dblNetUnits ELSE 0 END dblInQty
				, CASE WHEN strInOutFlag = 'O' THEN dblNetUnits ELSE 0 END dblOutQty
				, st.intStorageScheduleTypeId
				, NULL dblSettleUnit
			FROM tblSCTicket st
			JOIN tblICItem i on i.intItemId = st.intItemId
			WHERE i.intCommodityId = @intCommodityId
				AND i.intItemId = CASE WHEN ISNULL(@intItemId, 0) = 0 THEN i.intItemId ELSE @intItemId END AND ISNULL(strType,'') <> 'Other Charge'
				AND st.intProcessingLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
													WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1
																						WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0
																						ELSE isnull(ysnLicensed, 0) END)
				AND st.intProcessingLocationId = case when isnull(@intLocationId,0)=0 then st.intProcessingLocationId else @intLocationId end
				AND st.strTicketStatus = 'H' AND st.intDeliverySheetId IS NULL
		) t
		GROUP BY dtmDate
			, strStorageTypeDescription
			, intStorageScheduleTypeId
	) t1
	
	IF (@ysnDisplayAllStorage = 1)
	BEGIN
		DECLARE @intRowNumber INT
		SELECT TOP 1 @intRowNumber = intRowNum FROM #tempCustomer ORDER BY intRowNum DESC
		INSERT INTO #tempCustomer (intRowNum
			, dtmDate
			, strDistribution
			, dblIn
			, dblOut
			, dblNet
			, intStorageScheduleTypeId)
		SELECT CONVERT(INT, ROW_NUMBER() OVER (ORDER BY strStorageTypeDescription)) + ISNULL(@intRowNumber, 0)
			, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110)
			, strStorageTypeDescription
			, 0.0
			, 0.0
			, 0.0
			, intStorageScheduleTypeId
		FROM tblGRStorageScheduleRule SSR
		INNER JOIN tblGRStorageType ST ON SSR.intStorageType = ST.intStorageScheduleTypeId
		WHERE SSR.intCommodity = @intCommodityId
			AND ISNULL(ysnActive,0) = 1
			AND intStorageScheduleTypeId > 0
			AND intStorageScheduleTypeId NOT IN (SELECT DISTINCT intStorageScheduleTypeId FROM #tempCustomer)
		GROUP BY strStorageTypeDescription
			, intStorageScheduleTypeId
	END
	
	DECLARE @TempTableCreate NVARCHAR(MAX) = ''
	
	SELECT @TempTableCreate += '[' + t.strDistribution + '_strDistribution] NVARCHAR(100)  COLLATE Latin1_General_CI_AS  NULL,'
		+ '[' + t.strDistribution + '_In]  NUMERIC(18, 6) NULL,'
		+ '[' + t.strDistribution + '_Out]  NUMERIC(18, 6) NULL,'
		+ '[' + t.strDistribution + '_Net]  NUMERIC(18, 6) NULL,'
	FROM (
		SELECT DISTINCT strDistribution FROM #tempCustomer
	) t

	SET @TempTableCreate = CASE WHEN LEN(@TempTableCreate) > 0 THEN LEFT(@TempTableCreate, LEN(@TempTableCreate)-1) ELSE @TempTableCreate END
	SET @TempTableCreate = 'CREATE TABLE ##tblRKDailyPositionForCustomer1 ([dtmDate] datetime NULL,' + @TempTableCreate + ')'
	
	IF OBJECT_ID('tempdb..##tblRKDailyPositionForCustomer1') IS NOT NULL
		DROP TABLE ##tblRKDailyPositionForCustomer1
		
	EXEC sp_executesql @TempTableCreate
	DELETE FROM tblRKDailyPositionForCustomer

	DECLARE @FinalResult TABLE (intRowNum INT IDENTITY(1,1)
		, dtmDate DATETIME)
	
	INSERT INTO @FinalResult
	SELECT DISTINCT dtmDate FROM #tempCustomer  WHERE strDistribution IS NOT NULL
	
	DECLARE @mRowNumber1 INT = 0
	DECLARE @dtmDate1 DATETIME = ''
	DECLARE @SQL1 NVARCHAR(MAX) = ''
	
	SELECT DISTINCT @mRowNumber1 = MIN(intRowNum) FROM @FinalResult
	WHILE @mRowNumber1 > 0
	BEGIN
		DECLARE @strCumulativeNum NVARCHAR(MAX) = ''
		DECLARE @intColumn_Id INT
		DECLARE @Type NVARCHAR(MAX) = ''
		
		SELECT @dtmDate1 = dtmDate FROM @FinalResult WHERE intRowNum = @mRowNumber1
		
		SET @SQL1 = ''
		DECLARE @intCount INT = 0
		SELECT @intCount = MIN(intRowNum) FROM #tempCustomer
		WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10),dtmDate,110)) = CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmDate1,110))
		
		WHILE @intCount > 0
		BEGIN
			SELECT @Type = strDistribution FROM #tempCustomer
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110)) = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmDate1, 110)) AND intRowNum = @intCount
			
			SET @SQL1 = @SQL1 + '(SELECT strDistribution as '''
				+ CONVERT(NVARCHAR(100), @Type) + '_strDistribution' + ''', dblIn as '''
				+ CONVERT(NVARCHAR(100), @Type) + '_In' + ''',dblOut as '''
				+ CONVERT(NVARCHAR(100), @Type) + '_Out' + ''',dblNet as '''
				+ CONVERT(NVARCHAR(100), @Type) + '_Net' + ''' FROM #tempCustomer WHERE intRowNum= '
				+ CONVERT(NVARCHAR,@intCount) + ') t' + CONVERT(NVARCHAR(100), @intCount) + ' CROSS JOIN'
			
			SELECT @intCount = MIN(intRowNum) FROM #tempCustomer
			WHERE intRowNum > @intCount AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110)) = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmDate1,110))
		END
		
		IF LEN(@SQL1) > 0
		BEGIN
			IF OBJECT_ID('tempdb..##tempRunTime') IS NOT NULL
				DROP TABLE ##tempRunTime
				
			SET @SQL1 = ' SELECT  @dtmDate1 dtmDate,* into ##tempRunTime FROM ' + CASE WHEN LEN(@SQL1)>0 THEN LEFT(@SQL1,LEN(@SQL1)-11) ELSE @SQL1 END
			EXEC sp_executesql @SQL1, N'@dtmDate1 DATETIME', @dtmDate1
			
			SELECT @intColumn_Id = MIN(column_id) FROM tempdb.sys.columns WHERE object_id = object_id('tempdb..##tempRunTime')
			WHILE @intColumn_Id > 0
			BEGIN
				SELECT @strCumulativeNum = @strCumulativeNum + '[' + name + '],' FROM tempdb.sys.columns WHERE object_id = object_id('tempdb..##tempRunTime') AND column_id = @intColumn_Id
				SELECT @intColumn_Id = MIN(column_id) FROM tempdb.sys.columns WHERE object_id = object_id('tempdb..##tempRunTime') AND column_id > @intColumn_Id
			END
			
			IF LEN(@strCumulativeNum) > 0
			BEGIN
				SELECT @strCumulativeNum = CASE WHEN LEN(@strCumulativeNum) > 0 THEN LEFT(@strCumulativeNum, LEN(@strCumulativeNum) -1) ELSE @strCumulativeNum END
				
				DECLARE @Seq NVARCHAR(MAX) = ''
				SET @Seq = @Seq + 'INSERT INTO ##tblRKDailyPositionForCustomer1 (' + @strCumulativeNum + ')  SELECT ' + @strCumulativeNum + ' from ##tempRunTime'
				EXEC sp_executesql @Seq
			END
		END
		
		SELECT @mRowNumber1 = MIN(intRowNum) FROM @FinalResult WHERE intRowNum > @mRowNumber1
	END
	
	DECLARE @intColumn_Id1 INT
	DECLARE @strInsertList NVARCHAR(MAX) = ''
	DECLARE @strPermtableList NVARCHAR(MAX) = ''
	DECLARE @strInsertListBF NVARCHAR(MAX) = '' --For Balance Forward
	DECLARE @strInsertListBFGroupBy NVARCHAR(MAX) = ''
	DECLARE @strPermtableListBF NVARCHAR(MAX) = ''
	DECLARE @intColCount INT
	DECLARE @SQLBalanceForward NVARCHAR(MAX) = ''
	DECLARE @SQLFinal NVARCHAR(MAX) = ''
	
	SELECT @strInsertListBF += CASE WHEN NAME LIKE '%Distribution%' THEN '[' + name + '],' ELSE 'SUM(ISNULL([' + name + '],0)),' END
	FROM tempdb.sys.columns
	WHERE object_id =object_id('tempdb..##tblRKDailyPositionForCustomer1')
		AND (name LIKE '%_Net' OR name LIKE '%Distribution%')

	SELECT @strInsertListBF = CASE WHEN LEN(@strInsertListBF) > 0 THEN LEFT(@strInsertListBF, LEN(@strInsertListBF) -1) ELSE @strInsertListBF END --Remove the comma at the end
	SELECT @strInsertListBFGroupBy += '[' + name + '],' FROM tempdb.sys.columns WHERE object_id = object_id('tempdb..##tblRKDailyPositionForCustomer1') AND name LIKE '%Distribution%'
	SELECT @strInsertListBFGroupBy = CASE WHEN LEN(@strInsertListBFGroupBy) > 0 THEN LEFT(@strInsertListBFGroupBy, LEN(@strInsertListBFGroupBy) -1) ELSE @strInsertListBFGroupBy END  --Remove the comma at the end
	SELECT @strInsertList += '[' + name + '],' FROM tempdb.sys.columns WHERE object_id = object_id('tempdb..##tblRKDailyPositionForCustomer1')
	SELECT @intColCount = COUNT(name) FROM tempdb.sys.columns WHERE object_id = object_id('tempdb..##tblRKDailyPositionForCustomer1')
	SELECT @strInsertList = CASE WHEN LEN(@strInsertList) > 0 THEN LEFT(@strInsertList, LEN(@strInsertList) -1) ELSE @strInsertList END --Remove the comma at the end
	
	SELECT @strPermtableList += '[' + COLUMN_NAME + '],'
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'tblRKDailyPositionForCustomer'
		AND ORDINAL_POSITION <= @intColCount
	ORDER BY ORDINAL_POSITION ASC

	SELECT @strPermtableList = LEFT(@strPermtableList, LEN(@strPermtableList) -1)
	SELECT @strPermtableListBF += '[' + COLUMN_NAME + '],'
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = 'tblRKDailyPositionForCustomer'
		AND ORDINAL_POSITION <= @intColCount
		AND (COLUMN_NAME LIKE '%Net' OR COLUMN_NAME LIKE '%Distribution%')
	ORDER BY ORDINAL_POSITION ASC
	
	SELECT @strPermtableListBF = CASE WHEN LEN(@strPermtableListBF) = 0 THEN '' ELSE LEFT(@strPermtableListBF,LEN(@strPermtableListBF)-1) END
	
	IF LEN(@strPermtableListBF) <> 0
	BEGIN
		SET @SQLBalanceForward = 'INSERT INTO tblRKDailyPositionForCustomer ([dtmDate],' + @strPermtableListBF + ')
		SELECT  ''1900-01-01'',' + @strInsertListBF + '
		FROM ##tblRKDailyPositionForCustomer1 t
		WHERE dtmDate < ''' + CONVERT(VARCHAR(10),@dtmFromTransactionDate,110) + '''
		GROUP BY ' + @strInsertListBFGroupBy + '
		'
		EXEC sp_executesql @SQLBalanceForward
	END
	
	SET @SQLFinal = 'INSERT INTO tblRKDailyPositionForCustomer (' + @strPermtableList + ')
	SELECT  ' + @strInsertList + '
	FROM ##tblRKDailyPositionForCustomer1 t
	WHERE dtmDate between ''' + CONVERT(VARCHAR(10),@dtmFromTransactionDate,110) + ''' AND ''' + CONVERT(VARCHAR(10),@dtmToTransactionDate,110) + '''
	ORDER BY dtmDate'
	EXEC sp_executesql @SQLFinal
END