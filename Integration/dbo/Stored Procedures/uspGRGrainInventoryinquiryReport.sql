CREATE PROCEDURE [dbo].[uspGRGrainInventoryInquiryReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS
SET FMTONLY OFF

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

SELECT @dtmReportDate = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'dtmReportDate'

SELECT @intCommodityId = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'intCommodityId'

SELECT @intLocationId = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'intLocationId'

DECLARE @ReportData TABLE
(
	intRowNum INT
	,strLabel NVARCHAR(500)
	,strSign NVARCHAR(2)
	,dblUnits DECIMAL(18,6)
	,strCommodityCode NVARCHAR(20)
	,intCommodityId INT
	,dtmReportDate DATETIME
)

DECLARE @guid UNIQUEIDENTIFIER = NEWID()
DECLARE @InventoryData TABLE
(
	intRowNum INT
	,strLabel NVARCHAR(500)
	,strSign NVARCHAR(2)
	,dblUnits DECIMAL(18,6)
	,strCommodityCode NVARCHAR(20)
	,intCommodityId INT
)

DECLARE @intCommodityId2 INT
DECLARE @strCommodityCode NVARCHAR(20)
DECLARE @tblCommodities TABLE
(
	intCommodityId INT
	,strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
)

SET @dtmReportDate = CASE WHEN @dtmReportDate IS NULL THEN dbo.fnRemoveTimeOnDate(GETDATE()) ELSE @dtmReportDate END
SET @intCommodityId = CASE WHEN @intCommodityId = 0 THEN NULL ELSE @intCommodityId END
SET @intLocationId = CASE WHEN @intLocationId = 0 THEN NULL ELSE @intLocationId END

DECLARE @dateToday DATETIME
SET @dateToday = dbo.fnRemoveTimeOnDate(GETDATE())

/*==START==INVENTORY BALANCE==*/
IF(SELECT TOP 1 dtmDate FROM tblICStagingDailyStockPosition) <> @dtmReportDate
BEGIN
	EXEC uspICGetDailyStockPosition @dtmReportDate, @guid
END

INSERT INTO @InventoryData
SELECT 
	1
	,'INVENTORY BALANCE' AS label
	,'' AS [Sign]
	,SUM(dblOpeningQty)
	,strCommodityCode
	,intCommodityId
FROM tblICStagingDailyStockPosition
WHERE intCommodityId = ISNULL(@intCommodityId,intCommodityId)
	AND intLocationId = ISNULL(@intLocationId,intLocationId)
GROUP BY strCommodityCode
	,intCommodityId
/*==END==INVENTORY BALANCE==*/

/*==START==RECEIVED AND SHIPPED==*/
DECLARE @tblDateList TABLE (Id INT IDENTITY(1,1), DateData DATETIME)
DECLARE @StartDateTime DATETIME
DECLARE @EndDateTime DATETIME
SET @StartDateTime = @dtmReportDate
SET @EndDateTime = @dateToday;

WITH DateRange(DateData) AS (
    SELECT @StartDateTime as Date
    UNION ALL
    SELECT DATEADD(d,1,DateData)
    FROM DateRange 
    WHERE DateData < @EndDateTime
)
INSERT INTO @tblDateList(DateData)
SELECT DateData FROM DateRange
OPTION (MAXRECURSION 0)

DECLARE @tblResult TABLE 
(
	Id INT IDENTITY(1,1)
	,intRowNum INT
	,dtmDate DATETIME
	,[Distribution] NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,[Unpaid IN] NUMERIC(24,10)
	,[Unpaid Out] NUMERIC(24,10)
	,[Unpaid Balance] NUMERIC(24,10)
	,[Paid Balance] NUMERIC(24,10)
	,[InventoryBalanceCarryForward] NUMERIC(24,10)
	,strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,intReceiptId INT
)

DECLARE @tblFirstResult TABLE
 (
	Id INT identity(1,1)
	,intRowNum INT
	,dtmDate DATETIME
	,tranShipQty NUMERIC(24,10)
	,tranRecQty NUMERIC(24,10)
	,dblAdjustmentQty NUMERIC(24,10)
	,dblCountQty NUMERIC(24,10)
	,dblInvoiceQty NUMERIC(24,10)
	,BalanceForward NUMERIC(24,10)
	,dblSalesInTransit NUMERIC(24,10)
	,tranDSInQty NUMERIC(24,10)
)

DECLARE @tblResultFinal TABLE 
(
	Id INT IDENTITY(1,1)
	,dtmDate DATETIME
	,strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
	,dblUnpaidIn NUMERIC(24,10)
	,dblUnpaidOut NUMERIC(24,10)
	,dblUnpaidBalance NUMERIC(24,10)
	,dblPaidBalance NUMERIC(24,10)
	,BalanceForward NUMERIC(24,10)
	,InventoryBalanceCarryForward NUMERIC(24,10)
)

DECLARE @tblConsolidatedResult TABLE 
(
	Id INT IDENTITY(1,1)
	,dtmDate DATETIME
	,[Receive In] NUMERIC(24,10)
	,[Ship Out] NUMERIC(24,10)
	,tranDSInQty NUMERIC(24,10)
)

INSERT INTO @tblCommodities
SELECT DISTINCT
	CO.intCommodityId
	,ID.strCommodityCode
FROM @InventoryData ID
INNER JOIN tblICCommodity CO
	ON CO.strCommodityCode = ID.strCommodityCode COLLATE Latin1_General_CI_AS
WHERE strLabel = 'INVENTORY BALANCE'

WHILE EXISTS(SELECT TOP 1 1 FROM @tblCommodities)
BEGIN
	SET @intCommodityId2 = NULL
	SET @strCommodityCode = NULL
	
	SELECT TOP 1
		@intCommodityId2	= intCommodityId
		,@strCommodityCode	= strCommodityCode
	FROM @tblCommodities

	-- Customer Ownership START
	EXEC uspRKGetCustomerOwnership @dtmFromTransactionDate = @dtmReportDate
		,@dtmToTransactionDate = @dateToday
		,@intCommodityId = @intCommodityId2
		,@intItemId = 0
		,@strPositionIncludes = 'All storage'
		,@intLocationId = @intLocationId
	
	DELETE FROM @tblResult
	-- Customer ownershiip END
	INSERT INTO @tblResult 
	(
		intRowNum
		,dtmDate
		,[Distribution]
		,[Unpaid IN]
		,[Unpaid Out]
		,[Unpaid Balance]
		,[Paid Balance]
		,InventoryBalanceCarryForward
		,strReceiptNumber
		,intReceiptId
	)
	EXEC uspRKGetCompanyOwnership @dtmFromTransactionDate = @dtmReportDate
		,@dtmToTransactionDate = @dateToday
		,@intCommodityId = @intCommodityId2
		,@intItemId = 0
		,@strPositionIncludes = 'All storage'
		,@intLocationId = @intLocationId

	DELETE FROM @tblFirstResult
	INSERT INTO @tblFirstResult 
	(
		dtmDate
		,tranShipQty
		,tranRecQty
		,dblAdjustmentQty
		,dblCountQty
		,dblInvoiceQty
		,BalanceForward
		,dblSalesInTransit
		,tranDSInQty
	)
	EXEC uspRKGetInventoryBalance @dtmFromTransactionDate = @dtmReportDate
		, @dtmToTransactionDate = @dateToday
		, @intCommodityId = @intCommodityId2
		, @intItemId = 0
		, @strPositionIncludes = 'All storage'
		, @intLocationId = @intLocationId
	
	DELETE FROM @tblResultFinal 
	INSERT INTO @tblResultFinal 
	(
		dtmDate
		,dblUnpaidIn
		,dblUnpaidOut
		,BalanceForward
		,dblUnpaidBalance
		,dblPaidBalance
		,InventoryBalanceCarryForward
	)
	SELECT
		dtmDate
		,tranRecQty						= SUM([Unpaid IN])
		,tranShipQty					= SUM([Unpaid Out])
		,dblUnpaidBalance				= SUM([Unpaid Balance])
		,[Unpaid Balance]				= (SELECT SUM([Unpaid Balance]) FROM @tblResult AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(T1.dtmDate,'01/01/1900'))
		,dblPaidBalance					= SUM(T1.[Paid Balance])
		,InventoryBalanceCarryForward	= SUM(InventoryBalanceCarryForward)
	FROM @tblResult T1 
	GROUP BY dtmDate	

	DELETE FROM @tblConsolidatedResult 
	INSERT INTO @tblConsolidatedResult 
	(
		dtmDate
		,[Receive In]
		,[Ship Out]
	)
	SELECT 
		ISNULL(a.dtmDate,b.dtmDate) [Date]
		,ISNULL(a.tranRecQty, 0) [Receive In]
		,ISNULL(a.tranShipQty, 0) [Ship Out]
	FROM @tblFirstResult a
	FULL JOIN @tblResultFinal b 
		ON a.dtmDate = b.dtmDate 
	ORDER BY b.dtmDate
		,a.dtmDate ASC

	SELECT CONVERT(INT,ROW_NUMBER() OVER (ORDER BY dtmDate)) intRowNum
		, *
	INTO #final
	FROM (
		SELECT DISTINCT 
			dtmDate
			,dblReceiveIn	= [Receive In] + ISNULL(tranDSInQty, 0)
			,dblShipOut		= ISNULL([Ship Out], 0)
		FROM (
			SELECT 
				dtmDate
				,[Receive In]
				,tranDSInQty
				,[Ship Out]
			FROM (
				SELECT DateData dtmDate
					,[Receive In]
					,tranDSInQty
					,[Ship Out]
				FROM @tblConsolidatedResult T1
				FULL JOIN @tblDateList list 
					ON T1.dtmDate = list.DateData
			)t 
		)t1
	)t2 ORDER BY dtmDate

	INSERT INTO @InventoryData
	SELECT 
		2
		,'RECEIVED'
		,'+'
		,CASE WHEN dblReceiveIn = 0 THEN NULL ELSE dblReceiveIn END
		,@strCommodityCode
		,@intCommodityId2
	FROM (
		SELECT 
			dblReceiveIn = SUM(dblReceiveIn)
		FROM (	
			SELECT	 	
				dtmDate
				,dblReceiveIn
			FROM (
				SELECT 
					dtmDate			= list.dtmDate
					,dblReceiveIn
				FROM #final list
				FULL JOIN tblRKDailyPositionForCustomer t 
					ON ISNULL(t.dtmDate,'1900-01-01') = ISNULL(list.dtmDate,'1900-01-01')
				WHERE list.dtmDate > @dtmReportDate
			)t
		) A
	) B


	INSERT INTO @InventoryData
	SELECT 
		3
		,'SHIPPED'
		,'-'
		,CASE WHEN dblShipOut = 0 THEN NULL ELSE dblShipOut END
		,@strCommodityCode
		,@intCommodityId2
	FROM (
		SELECT
			dblShipOut = SUM(dblShipOut)
		FROM (	
			SELECT	 	
				dtmDate
				,dblShipOut
			FROM (
				SELECT 
					dtmDate			= list.dtmDate
					,dblShipOut		= ABS(dblShipOut)
				FROM #final list
				FULL JOIN tblRKDailyPositionForCustomer t 
					ON ISNULL(t.dtmDate,'1900-01-01') = ISNULL(list.dtmDate,'1900-01-01')
				WHERE list.dtmDate > @dtmReportDate
			)t
		) A
	)B

	DELETE FROM @tblCommodities WHERE intCommodityId = @intCommodityId2
END
/*==END==RECEIVED AND SHIPPED==*/

/*==START==NET AND TOTAL INVENTORY==*/
INSERT INTO @InventoryData
SELECT
	4
	,'NET ELEVATOR INVENTORY'
	,''
	,SUM(CASE WHEN strSign = '-' THEN -dblUnits ELSE dblUnits END)
	,strCommodityCode
	,intCommodityId
FROM @InventoryData
GROUP BY strCommodityCode
	,intCommodityId

INSERT INTO @ReportData
SELECT
	5
	,''
	,''
	,NULL
	,strCommodityCode
	,intCommodityId
	,@dtmReportDate
FROM @InventoryData
GROUP BY strCommodityCode
	,intCommodityId

INSERT INTO @InventoryData
SELECT 
	6
	,'TOTAL INVENTORY'
	,''
	,SUM(CASE WHEN strSign = '-' THEN -dblUnits ELSE dblUnits END)
	,strCommodityCode
	,intCommodityId
FROM @InventoryData
WHERE strLabel <> 'NET ELEVATOR INVENTORY'
GROUP BY strCommodityCode
	,intCommodityId

INSERT INTO @ReportData
SELECT
	7
	,''
	,''
	,NULL
	,strCommodityCode
	,intCommodityId
	,@dtmReportDate
FROM @InventoryData
GROUP BY strCommodityCode
	,intCommodityId

/*==END==NET AND TOTAL INVENTORY==*/

DECLARE @StorageTypes TABLE
(
	intStorageScheduleTypeId INT
	,strStorageTypeDescription NVARCHAR(60)
)

DECLARE @intCnt INT = 1
DECLARE @intOrigCnt INT = 0
DECLARE @intStorageTypeNum INT 
DECLARE @intTotalRowCnt INT

/*==START==STORAGE OBLIGATION==*/
INSERT INTO @StorageTypes
SELECT 
	intStorageScheduleTypeId
	,strStorageTypeDescription 
FROM tblGRStorageType 
WHERE intStorageScheduleTypeId > 0 
	AND ysnCustomerStorage = 0 
	AND ysnDPOwnedType = 0

DECLARE @StorageObligationData TABLE
(
	intRowNum INT
	,intStorageScheduleTypeId INT
	,strLabel NVARCHAR(100)
	,strSign NVARCHAR(2)
	,dblUnits DECIMAL(18,6)
	,strCommodityCode NVARCHAR(20)
	,intCommodityId INT
)
DECLARE @intStorageScheduleTypeId INT
DECLARE @strStorageTypeDescription NVARCHAR(60)

INSERT INTO @tblCommodities
SELECT DISTINCT
	CO.intCommodityId
	,ID.strCommodityCode
FROM @InventoryData ID
INNER JOIN tblICCommodity CO
	ON CO.strCommodityCode = ID.strCommodityCode COLLATE Latin1_General_CI_AS
WHERE strLabel = 'INVENTORY BALANCE'

WHILE EXISTS(SELECT TOP 1 1 FROM @tblCommodities)
BEGIN
	SET @intCommodityId2 = NULL
	SET @strCommodityCode = NULL
	SET @intCnt = 1

	SELECT TOP 1
		@intCommodityId2	= intCommodityId
		,@strCommodityCode	= strCommodityCode		
	FROM @tblCommodities

	WHILE @intCnt <= (SELECT COUNT(*) FROM @StorageTypes)
	BEGIN
		SET @intStorageScheduleTypeId = NULL
		SET @strStorageTypeDescription = NULL		

		SELECT
			@intStorageScheduleTypeId	= intStorageScheduleTypeId
			,@strStorageTypeDescription	= strStorageTypeDescription
			,@intStorageTypeNum			= intRowCnt
		FROM (
			SELECT
				*
				,intRowCnt = ROW_NUMBER() OVER (ORDER BY intStorageScheduleTypeId)
			FROM @StorageTypes
		) ST		
		WHERE intRowCnt = @intCnt

		SET @intTotalRowCnt = CASE WHEN (SELECT ISNULL(MAX(intRowNum),0) FROM @StorageObligationData) = 0 THEN 8 ELSE (SELECT MAX(intRowNum) FROM @StorageObligationData) END

		INSERT INTO @StorageObligationData
		SELECT 
			@intTotalRowCnt + 1
			,@intStorageScheduleTypeId
			,@strStorageTypeDescription + ' BALANCE'
			,'' AS [Sign]
			,0
			,@strCommodityCode
			,@intCommodityId2

		UPDATE @StorageObligationData
		SET dblUnits = CASE WHEN A.Units = 0 THEN NULL ELSE A.Units END
		FROM (
			SELECT
				SUM(A.dblOpenBalance) AS Units
			FROM tblGRCustomerStorage  A
			INNER JOIN tblGRStorageType B
				ON A. intStorageTypeId = B.intStorageScheduleTypeId  
			INNER JOIN tblICCommodity C
				ON A.intCommodityId = C.intCommodityId
			INNER JOIN tblSMCompanyLocation CL
				ON CL.intCompanyLocationId = A.intCompanyLocationId 
			WHERE C.intCommodityId = @intCommodityId2
				AND A.intCompanyLocationId = ISNULL(@intLocationId,A.intCompanyLocationId)
				AND A.dtmDeliveryDate BETWEEN @dtmReportDate AND @dateToday
				AND A.intStorageTypeId = @intStorageScheduleTypeId
		) A
		WHERE strCommodityCode = @strCommodityCode
			AND strLabel = @strStorageTypeDescription + ' BALANCE'

		INSERT INTO @StorageObligationData
		SELECT
			@intTotalRowCnt + 2
			,@intStorageScheduleTypeId
			,@strStorageTypeDescription + ' ISSUED'
			,'+' AS [Sign]
			,0
			,@strCommodityCode
			,@intCommodityId2

		UPDATE @StorageObligationData
		SET dblUnits = B.Units
		FROM (
			SELECT
				SUM(ABS(A.dblUnits)) AS Units
			FROM tblGRStorageHistory A 
			INNER JOIN tblGRCustomerStorage B
				ON A.intCustomerStorageId  = B.intCustomerStorageId
			INNER JOIN tblGRStorageType C
				ON B.intStorageTypeId = C.intStorageScheduleTypeId
			INNER JOIN tblICCommodity D
				ON D.intCommodityId = B.intCommodityId
			INNER JOIN tblSMCompanyLocation CL
				ON CL.intCompanyLocationId = B.intCompanyLocationId 
			WHERE (A.intTransactionTypeId = 5 OR A.strType = 'From Transfer')
				AND D.intCommodityId = @intCommodityId2
				AND A.dtmHistoryDate BETWEEN @dtmReportDate AND @dateToday
				AND B.intCompanyLocationId = ISNULL(@intLocationId,B.intCompanyLocationId)
				AND B.intStorageTypeId = @intStorageScheduleTypeId
		) B
		WHERE strCommodityCode = @strCommodityCode
			AND strLabel = @strStorageTypeDescription + ' ISSUED'
	
		INSERT INTO @StorageObligationData
		SELECT
			@intTotalRowCnt + 3
			,@intStorageScheduleTypeId
			,@strStorageTypeDescription + ' CANCELLED'
			,'-' AS [Sign]
			,0
			,@strCommodityCode
			,@intCommodityId2
		
		UPDATE @StorageObligationData
		SET dblUnits = C.Units
		FROM (
			SELECT
				SUM(CASE WHEN B.ysnTransferStorage = 1 AND A.strType = 'Transfer' THEN 0 ELSE ABS(A.dblUnits) END) AS Units
			FROM tblGRStorageHistory A 
			INNER JOIN tblGRCustomerStorage B
				ON A.intCustomerStorageId  = B.intCustomerStorageId
			INNER JOIN tblGRStorageType C
				ON B.intStorageTypeId = C.intStorageScheduleTypeId
			INNER JOIN tblICCommodity D
				ON D.intCommodityId = B.intCommodityId
			INNER JOIN tblSMCompanyLocation CL
				ON CL.intCompanyLocationId = B.intCompanyLocationId 
			WHERE A.intTransactionTypeId NOT IN (2,6)
				AND A.strType IN ('Settlement', 'Transfer', 'Storage Adjustment', 'From Inventory Adjustment')
				AND D.intCommodityId = @intCommodityId2
				AND A.dtmHistoryDate BETWEEN @dtmReportDate AND @dateToday
				AND B.intCompanyLocationId = ISNULL(@intLocationId,B.intCompanyLocationId)
				AND B.intStorageTypeId = @intStorageScheduleTypeId
		) C
		WHERE strCommodityCode = @strCommodityCode
			AND strLabel = @strStorageTypeDescription + ' CANCELLED'

		INSERT INTO @StorageObligationData
		SELECT
			@intTotalRowCnt + 4
			,0
			,'TOTAL ' + @strStorageTypeDescription
			,''
			,SUM(CASE WHEN strSign = '-' THEN -dblUnits ELSE dblUnits END)
			,@strCommodityCode
			,intCommodityId
		FROM @StorageObligationData
		WHERE intStorageScheduleTypeId = @intStorageScheduleTypeId
			AND strCommodityCode = @strCommodityCode
		GROUP BY strCommodityCode
			,intCommodityId

		UPDATE RD
		SET RD.intRowNum = r.intRowNum2
		FROM @StorageObligationData RD
		INNER JOIN (
			SELECT 
				*
				,(ROW_NUMBER() OVER (ORDER BY intRowNum) + 8) intRowNum2
			FROM @StorageObligationData
		) r
			ON r.intRowNum = RD.intRowNum
				AND r.strLabel = RD.strLabel
				AND r.strCommodityCode = RD.strCommodityCode

		INSERT INTO @StorageObligationData 
		SELECT
			(SELECT (MAX(intRowNum) + 1) FROM @StorageObligationData)
			,@intStorageScheduleTypeId
			,''
			,''
			,NULL
			,@strCommodityCode
			,@intCommodityId2

		SET @intCnt = @intCnt + 1
		SET @intOrigCnt = @intOrigCnt + 2
	END

	DELETE FROM @tblCommodities WHERE intCommodityId = @intCommodityId2
END
SET @intTotalRowCnt = (SELECT MAX(intRowNum) FROM @StorageObligationData)

INSERT INTO @StorageObligationData
SELECT
	@intTotalRowCnt + 1
	,0
	,'TOTAL STORAGE OBLIGATION'
	,''
	,SUM(CASE WHEN strSign = '-' THEN -dblUnits ELSE dblUnits END)
	,strCommodityCode
	,intCommodityId
FROM @StorageObligationData
GROUP BY strCommodityCode
	,intCommodityId

INSERT INTO @StorageObligationData
SELECT
	@intTotalRowCnt + 2
	,0
	,''
	,''
	,NULL
	,strCommodityCode
	,intCommodityId
FROM @StorageObligationData
GROUP BY strCommodityCode
	,intCommodityId
/*==END==STORAGE OBLIGATION==*/
SET @intTotalRowCnt = (SELECT MAX(intRowNum) FROM @StorageObligationData)
/*==START==COMPANY-OWNED GRAIN==*/
INSERT INTO @ReportData
SELECT 
	@intTotalRowCnt + (SELECT MAX(intRowNum) FROM @ReportData)
	,'COMPANY-OWNED GRAIN'
	,''
	,SUM(dblUnits)
	,strCommodityCode
	,intCommodityId
	,@dtmReportDate
FROM @ReportData
WHERE strLabel IN ('TOTAL INVENTORY','TOTAL STORAGE OBLIGATON')
GROUP BY strCommodityCode
	,intCommodityId

INSERT INTO @ReportData
SELECT 
	@intTotalRowCnt + 15
	,''
	,''
	,NULL
	,strCommodityCode
	,intCommodityId
	,@dtmReportDate
FROM @ReportData
WHERE strLabel IN ('TOTAL INVENTORY','TOTAL STORAGE OBLIGATON')
GROUP BY strCommodityCode
	,intCommodityId
/*==END==COMPANY-OWNED GRAIN==*/

/*==START==DP STORAGE==*/
INSERT INTO @tblCommodities
SELECT DISTINCT
	CO.intCommodityId
	,ID.strCommodityCode
FROM @InventoryData ID
INNER JOIN tblICCommodity CO
	ON CO.strCommodityCode = ID.strCommodityCode COLLATE Latin1_General_CI_AS
WHERE strLabel = 'INVENTORY BALANCE'

WHILE EXISTS(SELECT TOP 1 1 FROM @tblCommodities)
BEGIN
	SET @intCommodityId2 = NULL
	SET @strCommodityCode = NULL
	SET @intCnt = 1

	SELECT TOP 1
		@intCommodityId2	= intCommodityId
		,@strCommodityCode	= strCommodityCode		
	FROM @tblCommodities

	SELECT
		@intStorageScheduleTypeId	= intStorageScheduleTypeId
		,@strStorageTypeDescription	= strStorageTypeDescription
	FROM tblGRStorageType
	WHERE ysnDPOwnedType = 1

	INSERT INTO @StorageObligationData
	SELECT 
		@intTotalRowCnt + 16
		,@intStorageScheduleTypeId
		,@strStorageTypeDescription + ' BALANCE'
		,'' AS [Sign]
		,0
		,@strCommodityCode
		,@intCommodityId2

	UPDATE @StorageObligationData
	SET dblUnits = A.Units
	FROM (
		SELECT
			SUM(A.dblOpenBalance) AS Units
		FROM tblGRCustomerStorage  A
		INNER JOIN tblGRStorageType B
			ON A. intStorageTypeId = B.intStorageScheduleTypeId  
		INNER JOIN tblICCommodity C
			ON A.intCommodityId = C.intCommodityId
		INNER JOIN tblSMCompanyLocation CL
			ON CL.intCompanyLocationId = A.intCompanyLocationId 
		WHERE C.intCommodityId = @intCommodityId2
			AND A.intCompanyLocationId = ISNULL(@intLocationId,A.intCompanyLocationId)
			AND A.dtmDeliveryDate BETWEEN @dtmReportDate AND @dateToday
			AND A.intStorageTypeId = @intStorageScheduleTypeId
	) A
	WHERE strCommodityCode = @strCommodityCode
		AND strLabel = @strStorageTypeDescription + ' BALANCE'

	INSERT INTO @StorageObligationData
	SELECT
		@intTotalRowCnt + 17
		,@intStorageScheduleTypeId
		,@strStorageTypeDescription + ' ISSUED'
		,'+' AS [Sign]
		,0
		,@strCommodityCode
		,@intCommodityId2

	UPDATE @StorageObligationData
	SET dblUnits = B.Units
	FROM (
		SELECT
			SUM(ABS(A.dblUnits)) AS Units
		FROM tblGRStorageHistory A 
		INNER JOIN tblGRCustomerStorage B
			ON A.intCustomerStorageId  = B.intCustomerStorageId
		INNER JOIN tblGRStorageType C
			ON B.intStorageTypeId = C.intStorageScheduleTypeId
		INNER JOIN tblICCommodity D
			ON D.intCommodityId = B.intCommodityId
		INNER JOIN tblSMCompanyLocation CL
			ON CL.intCompanyLocationId = B.intCompanyLocationId 
		WHERE A.intTransactionTypeId = 5
			AND D.intCommodityId = @intCommodityId2
			AND A.dtmHistoryDate BETWEEN @dtmReportDate AND @dateToday
			AND B.intCompanyLocationId = ISNULL(@intLocationId,B.intCompanyLocationId)
			AND B.intStorageTypeId = @intStorageScheduleTypeId
	) B
	WHERE strCommodityCode = @strCommodityCode
		AND strLabel = @strStorageTypeDescription + ' ISSUED'
	
	INSERT INTO @StorageObligationData
	SELECT
		@intTotalRowCnt + 18
		,@intStorageScheduleTypeId
		,@strStorageTypeDescription + ' CANCELLED'
		,'-' AS [Sign]
		,0
		,@strCommodityCode
		,@intCommodityId2

	UPDATE @StorageObligationData
	SET dblUnits = C.Units
	FROM (
		SELECT
			SUM(CASE WHEN B.ysnTransferStorage = 1 AND A.strType = 'Transfer' THEN 0 ELSE ABS(A.dblUnits) END) AS Units
		FROM tblGRStorageHistory A 
		INNER JOIN tblGRCustomerStorage B
			ON A.intCustomerStorageId  = B.intCustomerStorageId
		INNER JOIN tblGRStorageType C
			ON B.intStorageTypeId = C.intStorageScheduleTypeId
		INNER JOIN tblICCommodity D
			ON D.intCommodityId = B.intCommodityId
		INNER JOIN tblSMCompanyLocation CL
			ON CL.intCompanyLocationId = B.intCompanyLocationId 
		WHERE A.intTransactionTypeId NOT IN (2,6)
			AND A.strType IN ('Settlement', 'Transfer', 'Storage Adjustment')
			AND D.intCommodityId = @intCommodityId2
			AND A.dtmHistoryDate BETWEEN @dtmReportDate AND @dateToday
			AND B.intCompanyLocationId = ISNULL(@intLocationId,B.intCompanyLocationId)
			AND B.intStorageTypeId = @intStorageScheduleTypeId
	) C
	WHERE strCommodityCode = @strCommodityCode
		AND strLabel = @strStorageTypeDescription + ' CANCELLED'

	INSERT INTO @StorageObligationData
	SELECT
		@intTotalRowCnt + 19
		,0
		,'TOTAL ' + @strStorageTypeDescription
		,''
		,SUM(CASE WHEN strSign = '-' THEN -dblUnits ELSE dblUnits END)
		,@strCommodityCode
		,@intCommodityId2
	FROM @StorageObligationData
	WHERE intStorageScheduleTypeId = @intStorageScheduleTypeId
		AND strCommodityCode = @strCommodityCode
	GROUP BY strCommodityCode
		,intCommodityId

	DELETE FROM @tblCommodities WHERE intCommodityId = @intCommodityId2
END
/*==END==DP STORAGE==*/

/*==START==STORAGE CAPACITY AND STORAGE AVAILABLE==*/
INSERT INTO @ReportData
SELECT 
	@intTotalRowCnt + 20
	,''
	,''
	,NULL
	,LD.strCommodityCode
	,CO.intCommodityId
	,@dtmReportDate
FROM vyuICGetSubLocationBinDetails LD
INNER JOIN tblICCommodity CO
	ON CO.strCommodityCode = LD.strCommodityCode
WHERE intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
	AND CO.intCommodityId = ISNULL(@intCommodityId, CO.intCommodityId)
GROUP BY LD.strCommodityCode
	,CO.intCommodityId

INSERT INTO @InventoryData
SELECT 
	@intTotalRowCnt + 21
	,'TOTAL STORAGE CAPACITY'
	,''
	,CASE WHEN SUM(dblCapacity) = 0 THEN NULL ELSE SUM(dblAvailable) END
	,LD.strCommodityCode
	,CO.intCommodityId
FROM vyuICGetSubLocationBinDetails LD
INNER JOIN tblICCommodity CO
	ON CO.strCommodityCode = LD.strCommodityCode
WHERE intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
	AND CO.intCommodityId = ISNULL(@intCommodityId, CO.intCommodityId)
GROUP BY LD.strCommodityCode
	,CO.intCommodityId

INSERT INTO @InventoryData
SELECT 
	@intTotalRowCnt + 22
	,'TOTAL CAPACITY AVAILABLE'
	,''
	,CASE WHEN SUM(dblAvailable) = 0 THEN NULL ELSE SUM(dblAvailable) END
	,LD.strCommodityCode
	,CO.intCommodityId
FROM vyuICGetSubLocationBinDetails LD
INNER JOIN tblICCommodity CO
	ON CO.strCommodityCode = LD.strCommodityCode
WHERE intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
	AND CO.intCommodityId = ISNULL(@intCommodityId, CO.intCommodityId)
GROUP BY LD.strCommodityCode
	,CO.intCommodityId
/*==END==STORAGE CAPACITY AND STORAGE AVAILABLE==*/

/*==START==REPORT DATA==*/
INSERT INTO @ReportData
SELECT 
	intRowNum
	,strLabel
	,strSign
	,dblUnits
	,strCommodityCode
	,intCommodityId
	,@dtmReportDate
FROM @StorageObligationData

INSERT INTO @ReportData
SELECT 
	intRowNum
	,strLabel
	,strSign
	,dblUnits
	,strCommodityCode
	,intCommodityId
	,@dtmReportDate
FROM @InventoryData
WHERE strLabel NOT IN ('TOTAL STORAGE OBLIGATON')
/*==END==REPORT DATA==*/

SELECT * FROM @ReportData ORDER BY strCommodityCode,intRowNum

SET FMTONLY ON