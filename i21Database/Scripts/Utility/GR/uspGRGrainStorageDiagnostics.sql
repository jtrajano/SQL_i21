CREATE PROCEDURE [dbo].[uspGRGrainStorageDiagnostics]
	@emailProfileName AS NVARCHAR(MAX) = NULL
	,@emailRecipient AS NVARCHAR(MAX) = NULL
AS

DECLARE @companyName AS NVARCHAR(MAX) 
 	,@resultAsHTML AS NVARCHAR(MAX)

SELECT TOP 1 @companyName = ISNULL(strCompanyName, '') FROM tblSMCompanySetup

SET @resultAsHTML = '<h1>GRAIN Diagnostic Results for ' + @companyName + '</h1>'

/*---START: SUM TOTALS PER COMMODITY; Query GRN Customer Owned versus Storage---'*/
DECLARE @strName NVARCHAR(500)
DECLARE @strCommodityCode NVARCHAR(50)
DECLARE @strStorageTypeCode NVARCHAR(50)
DECLARE @dblQty DECIMAL(18,6)

DECLARE @tbl1 AS TABLE 
(
	strName NVARCHAR(50)
	,strCommodityCode NVARCHAR(50)
	,strStorageTypeCode NVARCHAR(50)
	,dblQty DECIMAL(18,6)
)

IF OBJECT_ID('tempdb..#ithacatmpCommodity') IS NOT NULL DROP TABLE #ithacatmpCommodity
 
SELECT DISTINCT
      C.intCommodityId
    , C.strCommodityCode
INTO #ithacatmpCommodity
FROM tblICCommodity C
 
DECLARE @intCommodityId INT
 
WHILE EXISTS (SELECT  intCommodityId FROM #ithacatmpCommodity)
BEGIN
	INSERT INTO @tbl1
	select 'Storage Search'
		,b.strCommodityCode
		,c.strStorageTypeCode
		,sum(dblOpenBalance)
	FROM vyuGRStorageSearchView a
	inner join tblICCommodity b on a.intCommodityId = b. intCommodityId
	inner join tblGRStorageType c on c.intStorageScheduleTypeId = a.intStorageTypeId
	where c.strOwnedPhysicalStock ='Customer'
	group by b.strCommodityCode, c.strStorageTypeCode
      
	INSERT INTO @tbl1
	select 'DPR Customer Owned'
		,b.strCommodityCode
		,strStorageTypeCode
		,sum(a.dblTotal)
	from dbo.fnRKGetBucketCustomerOwned(getdate(),@intCommodityId,null) a inner join tblICCommodity b on a.intCommodityId = b. intCommodityId
	group by b.strCommodityCode,  strStorageTypeCode
 
	exec uspICGenerateStockMovementReport 'Commodity', 2, 0
	
	INSERT INTO @tbl1
	select 'Stock Movement'
		,strCommodity
		,'Storage'
		,sum (dblQuantity)
	from vyuICGetStockMovement where strOwnership ='Storage'
	group by strCommodity
    
	DELETE FROM #ithacatmpCommodity WHERE intCommodityId = intCommodityId
END

BEGIN				
	SET @resultAsHTML += 
		'<h3>SUM TOTALS PER COMMODITY - Customer Owned versus Storage</h3>' +
		'<table border="1">' + 
		N'<tr>
			<th>Name</th>
			<th>Commodity</th>
			<th>Storage Type</th>
			<th align=''right''>Quantity</th>
		</tr>' 

	DECLARE c CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT strName
		,strCommodityCode
		,strStorageTypeCode
		,dblQty
	FROM @tbl1

	OPEN c
	FETCH NEXT FROM c INTO 
		@strName
		,@strCommodityCode
		,@strStorageTypeCode
		,@dblQty

	WHILE @@FETCH_STATUS = 0
	BEGIN 
		SET @resultAsHTML += 
			N'<tr>' + 
			N'<td>'+ ISNULL(@strName,'') +'</td>' + 
			N'<td>'+ ISNULL(@strCommodityCode,'') +'</td>' + 
			N'<td>'+ ISNULL(@strStorageTypeCode,'') +'</td>' + 
			N'<td align=''right''>'+ dbo.fnICFormatNumber(@dblQty) +'</td>' +
			N'</tr>'

		FETCH NEXT FROM c INTO 
			@strName
			,@strCommodityCode
			,@strStorageTypeCode
			,@dblQty
	END

	CLOSE c; DEALLOCATE c;

	SET @resultAsHTML += N'</table>'; 
END
/*'---END: SUM TOTALS PER COMMODITY; Query GRN Customer Owned versus Storage---'*/

/*---START: SUM TOTALS PER COMMODITY; Total Customer Storage vs Storage History---'*/

--CUSTOMER STORAGE COMMODITY'S TOTAL RUNNING BALANCE VS TOTAL OPEN BALANCE
DECLARE @tbl2 AS TABLE (
	strStorageTypeDesription NVARCHAR(40)
	,strCommodityCode NVARCHAR(40)
	,dblTotalBalanceByHeader DECIMAL(18,6)
	,dblTotalBalanceByHistory DECIMAL(18,6)
	,dblDiff DECIMAL(18,6)
)

DECLARE @strStorageTypeDesription NVARCHAR(40)
SET @strCommodityCode = NULL
DECLARE @dblTotalBalanceByHeader DECIMAL(18,6)
DECLARE @dblTotalBalanceByHistory DECIMAL(18,6)
DECLARE @dblDiff DECIMAL(18,6)

SET @resultAsHTML += 
	'<h3>SUM TOTALS PER COMMODITY - Customer Storage vs Storage History</h3>' +
	'<h4>Total Open Balance vs Total History Running Balance</h4>' +
	'<table border="1">' + 
	N'<tr>
		<th>Storage Type</th>
		<th>Commodity</th>
		<th align=''right''>Total Open Balance</th>
		<th align=''right''>Total History Running Balance</th>
		<th align=''right''>Difference</th>
	</tr>' 

INSERT INTO @tbl2
SELECT
    A.strStorageTypeDescription
    ,B.strCommodityCode
    ,TotalOpenBalanceHeader
    ,TotalOpenBalanceHistoryDetail
    ,SUM(TotalOpenBalanceHeader- TotalOpenBalanceHistoryDetail) AS DIFF
FROM (
        SELECT
            SUM(A.dblOpenBalance) AS TotalOpenBalanceHeader
            ,B.strStorageTypeDescription
            ,C.strCommodityCode
        FROM tblGRCustomerStorage  A
        INNER JOIN tblGRStorageType B
            ON A. intStorageTypeId = B.intStorageScheduleTypeId 
        INNER JOIN tblICCommodity C
            ON A.intCommodityId = C.intCommodityId
        WHERE (B.strOwnedPhysicalStock IN ('Customer') OR B.ysnDPOwnedType = 1)
        GROUP BY B.strStorageTypeDescription
            ,C.strCommodityCode
) A
INNER JOIN (
            SELECT
                SUM(CASE
                        WHEN (strType = 'Settlement' OR strType ='Reduced By Inventory Shipment') AND dblUnits > 0 THEN -dblUnits
                        ELSE dblUnits
                    END) AS TotalOpenBalanceHistoryDetail
                ,C.strStorageTypeDescription
                ,D.strCommodityCode
            FROM tblGRStorageHistory A
            INNER JOIN tblGRCustomerStorage B
                ON A.intCustomerStorageId = B.intCustomerStorageId
            INNER JOIN tblGRStorageType C
                ON B.intStorageTypeId  = C.intStorageScheduleTypeId
            INNER JOIN tblICCommodity D
                ON B.intCommodityId = D.intCommodityId
            WHERE (C.strOwnedPhysicalStock IN ('Customer') OR C.ysnDPOwnedType = 1)
                AND A.intTransactionTypeId NOT IN (2,6)
            GROUP BY C.strStorageTypeDescription, D.strCommodityCode
    ) B
        ON A.strStorageTypeDescription = B.strStorageTypeDescription
WHERE A.strCommodityCode = B.strCommodityCode
GROUP BY A.strStorageTypeDescription
    ,TotalOpenBalanceHeader
    ,TotalOpenBalanceHistoryDetail
    ,B.strCommodityCode
HAVING SUM(TotalOpenBalanceHeader - TotalOpenBalanceHistoryDetail) <> 0

BEGIN
	DECLARE c CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT strStorageTypeDesription
		,strCommodityCode
		,dblTotalBalanceByHeader
		,dblTotalBalanceByHistory
		,dblDiff
	FROM @tbl2

	OPEN c
	FETCH NEXT FROM c INTO 
		@strStorageTypeDesription
		,@strCommodityCode
		,@dblTotalBalanceByHeader
		,@dblTotalBalanceByHistory
		,@dblDiff

	WHILE @@FETCH_STATUS = 0
	BEGIN 
		SET @resultAsHTML += 
			N'<tr>' + 
			N'<td>'+ ISNULL(@strStorageTypeDesription,'') +'</td>' + 
			N'<td>'+ ISNULL(@strCommodityCode,'') +'</td>' + 
			N'<td align=''right''>'+ dbo.fnICFormatNumber(@dblTotalBalanceByHeader) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(@dblTotalBalanceByHistory) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(@dblDiff) +'</td>' +
			N'</tr>'

		FETCH NEXT FROM c INTO 
			@strStorageTypeDesription
			,@strCommodityCode
			,@dblTotalBalanceByHeader
			,@dblTotalBalanceByHistory
			,@dblDiff
	END

	CLOSE c; DEALLOCATE c;

	SET @resultAsHTML += N'</table>';
END

DELETE FROM @tbl2
--CUSTOMER STORAGE COMMODITY'S TOTAL RUNNING BALANCE VS TOTAL ORIGINAL BALANCE

SET @resultAsHTML += 
	'<h4>Total Original Balance vs Total History Original Balance</h4>' +
	'<table border="1">' + 
	N'<tr>
		<th>Storage Type</th>
		<th>Commodity</th>
		<th align=''right''>Total Original Balance</th>
		<th align=''right''>Total History Original Balance</th>
		<th align=''right''>Difference</th>
	</tr>' 

INSERT INTO @tbl2
SELECT
    A.strStorageTypeDescription
    ,B.strCommodityCode
    ,TotalOriginalBalanceHeader
    ,TotalOriginalBalanceHistoryDetail
    ,SUM(TotalOriginalBalanceHeader- TotalOriginalBalanceHistoryDetail) AS DIFF
FROM (
        SELECT
            SUM(A.dblOriginalBalance) AS TotalOriginalBalanceHeader
            ,B.strStorageTypeDescription
            ,C.strCommodityCode
        FROM tblGRCustomerStorage  A
        INNER JOIN tblGRStorageType B
            ON A. intStorageTypeId = B.intStorageScheduleTypeId
        INNER JOIN tblICCommodity C
            ON A.intCommodityId = C.intCommodityId
        WHERE (B.strOwnedPhysicalStock IN ('Customer') OR B.ysnDPOwnedType = 1)
        GROUP BY B.strStorageTypeDescription
            ,C.strCommodityCode
) A
INNER JOIN (
            SELECT
                SUM(dblUnits) AS TotalOriginalBalanceHistoryDetail
                ,C.strStorageTypeDescription
                ,D.strCommodityCode
            FROM tblGRStorageHistory A
            INNER JOIN tblGRCustomerStorage B
                ON A.intCustomerStorageId = B.intCustomerStorageId
            INNER JOIN tblGRStorageType C
                ON B.intStorageTypeId  = C.intStorageScheduleTypeId
            INNER JOIN tblICCommodity D
                ON B.intCommodityId = D.intCommodityId
            WHERE --C.strStorageTypeDescription IN ('GRAIN BANK','DELAYED PRICING', 'OPEN STORAGE', 'WAREHOUSE RECEIPT', 'TERMINAL') --mcp
                C.intStorageScheduleTypeId > 0 --zeeland
                AND ((A.intTransactionTypeId = 5 --DS
                        OR A.strType = 'From Transfer' --FROM TRANSFER
                        OR (A.strType = 'From Scale' and A.intTransactionTypeId = 1)) --SC; exclude 'From Scale - Datafix'
                        OR (A.intTransactionTypeId = 9 AND (A.strPaidDescription = 'Quantity Adjustment From Delivery Sheet' OR A.strPaidDescription LIKE '%GRN-2593%') AND A.intInventoryAdjustmentId IS NOT NULL)) --IA-XXXX
                AND B.intCommodityId IN (SELECT DISTINCT intCommodityId FROM tblGRCustomerStorage)
            GROUP BY C.strStorageTypeDescription, D.strCommodityCode
    ) B
        ON A.strStorageTypeDescription = B.strStorageTypeDescription
WHERE A.strCommodityCode = B.strCommodityCode
GROUP BY A.strStorageTypeDescription
    ,TotalOriginalBalanceHeader
    ,TotalOriginalBalanceHistoryDetail
    ,B.strCommodityCode
HAVING SUM(TotalOriginalBalanceHeader - TotalOriginalBalanceHistoryDetail) <> 0

BEGIN
	DECLARE c CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT strStorageTypeDesription
		,strCommodityCode
		,dblTotalBalanceByHeader
		,dblTotalBalanceByHistory
		,dblDiff
	FROM @tbl2

	OPEN c
	FETCH NEXT FROM c INTO 
		@strStorageTypeDesription
		,@strCommodityCode
		,@dblTotalBalanceByHeader
		,@dblTotalBalanceByHistory
		,@dblDiff

	WHILE @@FETCH_STATUS = 0
	BEGIN 
		SET @resultAsHTML += 
			N'<tr>' + 
			N'<td>'+ ISNULL(@strStorageTypeDesription,'') +'</td>' + 
			N'<td>'+ ISNULL(@strCommodityCode,'') +'</td>' + 
			N'<td align=''right''>'+ dbo.fnICFormatNumber(@dblTotalBalanceByHeader) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(@dblTotalBalanceByHistory) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(@dblDiff) +'</td>' +
			N'</tr>'

		FETCH NEXT FROM c INTO 
			@strStorageTypeDesription
			,@strCommodityCode
			,@dblTotalBalanceByHeader
			,@dblTotalBalanceByHistory
			,@dblDiff
	END

	CLOSE c; DEALLOCATE c;

	SET @resultAsHTML += N'</table>';
END
/*END: Sum Totals per Commodity*/

/*'---START: 1. DPR vs GRAIN---'*/
DECLARE @tbl3 AS TABLE
(
    intCommodityId INT
    ,intCompanyLocationId INT
    ,intStorageTypeId INT
    ,strCommodityCode NVARCHAR(50) COLLATE Latin1_General_CI_AS
    ,strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
    ,strStorageType NVARCHAR(200) COLLATE Latin1_General_CI_AS
    ,ysnDPOwnedType BIT
    ,dblDPR DECIMAL(18,6)
    ,dblGrainBalance_view DECIMAL (18,6)
    ,dblGrainBalance_table DECIMAL (18,6)
    ,intRec INT IDENTITY(1,1)
)

SET @strCommodityCode = NULL
DECLARE @strLocationName NVARCHAR(200)
DECLARE @strStorageType NVARCHAR(200)
DECLARE @dblDPR DECIMAL(18,6)
DECLARE @dblGrainBalance_view DECIMAL(18,6)
DECLARE @dblGrainBalance_table DECIMAL(18,6)
DECLARE @DIFF_GRAIN_VIEW_VS_TABLE DECIMAL(18,6)
DECLARE @DIFF_DPR_VS_GRAIN_VIEW DECIMAL(18,6)
DECLARE @DIFF_DPR_VS_GRAIN_TABLE DECIMAL(18,6)
 
INSERT INTO @tbl3
SELECT DISTINCT
    CS.intCommodityId
    ,CS.intCompanyLocationId
    ,CS.intStorageTypeId
    ,CO.strCommodityCode
    ,CL.strLocationName
    ,ST.strStorageTypeDescription
    ,ST.ysnDPOwnedType
    ,0,0,0
FROM tblGRCustomerStorage CS
INNER JOIN tblGRStorageType ST
    ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
INNER JOIN tblICCommodity CO
    ON CO.intCommodityId = CS.intCommodityId       
INNER JOIN tblSMCompanyLocation CL
    ON CL.intCompanyLocationId = CS.intCompanyLocationId
 
DECLARE @DPRQty DECIMAL(38,20)
DECLARE @GrainQty_view DECIMAL(38,20)
DECLARE @GrainQty_table DECIMAL(38,20)

SET @intCommodityId = NULL

DECLARE @intCompanyLocationId INT
DECLARE @intStorageTypeId INT
DECLARE @ysnDPOwnedType BIT
DECLARE @intRec INT = 1
DECLARE @rowCnt INT
 
SELECT @rowCnt = COUNT(*) FROM @tbl3
 
WHILE @intRec <> 0 AND @rowCnt <> 0
BEGIN
    SET @intCommodityId = NULL
    SET @intCompanyLocationId = NULL
    SET @intStorageTypeId = NULL
    SET @strStorageType = NULL
    SET @ysnDPOwnedType = NULL
    SET @DPRQty = 0
    SET @GrainQty_view = 0
    SET @GrainQty_table = 0
 
    SELECT TOP 1
        @intCommodityId         = intCommodityId
        ,@intCompanyLocationId  = intCompanyLocationId
        ,@intStorageTypeId      = intStorageTypeId
        ,@strStorageType        = strStorageType
        ,@ysnDPOwnedType        = ysnDPOwnedType
    FROM @tbl3
    WHERE intRec = @intRec
 
    PRINT CAST(@intRec AS NVARCHAR(500)) + ' of ' + CAST(@rowCnt AS NVARCHAR(500))
 
    IF @ysnDPOwnedType = 0
    BEGIN
        select
            @DPRQty = ISNULL(sum(ISNULL(dblTotal,0)),0)
        FROM
            dbo.fnRKGetBucketCustomerOwned(GETDATE(), @intCommodityId, NULL) t
            LEFT JOIN tblSCTicket SC ON t.intTicketId = SC.intTicketId
        WHERE
            ISNULL(strStorageType, '') <> 'ITR' AND intTypeId IN (1, 3, 4, 5, 8, 9)
            AND t.intLocationId = @intCompanyLocationId
            AND t.strDistributionType = @strStorageType
 
        SELECT @GrainQty_table = SUM(dblOpenBalance)
        FROM tblGRCustomerStorage CS
        WHERE intCommodityId = @intCommodityId
            AND intCompanyLocationId = @intCompanyLocationId
            AND intStorageTypeId = @intStorageTypeId
 
        SELECT @GrainQty_view = SUM(dblOpenBalance)
        FROM vyuGRStorageSearchView CS
        WHERE intCommodityId = @intCommodityId
            AND intCompanyLocationId = @intCompanyLocationId
            AND intStorageTypeId = @intStorageTypeId
    END
    ELSE
    BEGIN
        SELECT @DPRQty = SUM(dblTotal)
        FROM dbo.fnRKGetBucketDelayedPricing(GETDATE(),@intCommodityId,NULL) A
        WHERE A.intLocationId = @intCompanyLocationId
 
        SELECT @GrainQty_table = SUM(dblOpenBalance)
        FROM tblGRCustomerStorage CS
        WHERE intCommodityId = @intCommodityId
            AND intCompanyLocationId = @intCompanyLocationId
            AND intStorageTypeId = @intStorageTypeId
 
        SELECT @GrainQty_view = SUM(dblOpenBalance)
        FROM vyuGRStorageSearchView CS
        WHERE intCommodityId = @intCommodityId
            AND intCompanyLocationId = @intCompanyLocationId
            AND intStorageTypeId = @intStorageTypeId
    END
     
    UPDATE @tbl3 SET dblDPR = @DPRQty, dblGrainBalance_view = @GrainQty_view, dblGrainBalance_table = @GrainQty_table WHERE intRec = @intRec
 
    IF @intRec <> @rowCnt
    BEGIN
        SET @intRec = @intRec + 1
    END
    ELSE
    BEGIN
        SET @intRec = 0
    END
END

BEGIN
	SET @resultAsHTML += 
		'<h3>DPR vs Grain</h3>' +
		'<table border="1">' + 
		N'<tr>
			<th>Commodity</th>
			<th>Location</th>
			<th>Storage Type</th>
			<th align=''right''>DPR</th>
			<th align=''right''>Grain Balance (view)</th>
			<th align=''right''>Grain Balance (table)</th>
			<th align=''right''>Diff - Grain Balance view vs table</th>
			<th align=''right''>Diff - DPR vs Grain Balance (view)</th>
			<th align=''right''>Diff - DPR vs Grain Balance (table)</th>
		</tr>' 

	DECLARE c CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT strCommodityCode
		,strLocationName
		,strStorageType
		,dblDPR
		,dblGrainBalance_view
		,dblGrainBalance_table
		,dblGrainBalance_view - dblGrainBalance_table
		,dblGrainBalance_view - dblDPR
		,dblGrainBalance_table - dblDPR
	FROM @tbl3
	ORDER BY strCommodityCode

	OPEN c
	FETCH NEXT FROM c INTO 
		@strCommodityCode
		,@strLocationName
		,@strStorageType
		,@dblDPR
		,@dblGrainBalance_view
		,@dblGrainBalance_table
		,@DIFF_GRAIN_VIEW_VS_TABLE
		,@DIFF_DPR_VS_GRAIN_VIEW
		,@DIFF_DPR_VS_GRAIN_TABLE

	WHILE @@FETCH_STATUS = 0
	BEGIN 
		SET @resultAsHTML += 
			N'<tr>' + 
			N'<td>'+ ISNULL(@strCommodityCode,'') +'</td>' + 
			N'<td>'+ ISNULL(@strLocationName,'') +'</td>' + 
			N'<td>'+ ISNULL(@strStorageType,'') +'</td>' + 				
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@dblDPR,0)) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@dblGrainBalance_view,0)) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@dblGrainBalance_table,0)) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@DIFF_GRAIN_VIEW_VS_TABLE,0)) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@DIFF_DPR_VS_GRAIN_VIEW,0)) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@DIFF_DPR_VS_GRAIN_TABLE,0)) +'</td>' +
			N'</tr>'

		FETCH NEXT FROM c INTO 
			@strCommodityCode
			,@strLocationName
			,@strStorageType
			,@dblDPR
			,@dblGrainBalance_view
			,@dblGrainBalance_table
			,@DIFF_GRAIN_VIEW_VS_TABLE
			,@DIFF_DPR_VS_GRAIN_VIEW
			,@DIFF_DPR_VS_GRAIN_TABLE
	END

	CLOSE c; DEALLOCATE c;

	SET @resultAsHTML += N'</table>'; 
END
/*---END: 1. DPR vs GRAIN---'*/

/*---START: 2. INVENTORY vs DPR CUSTOMER-OWNED---'*/
SET @resultAsHTML += '<h3>Inventory vs DPR Customer Owned</h3>'

DECLARE @LOCATIONS AS TABLE
(
    strLocations NVARCHAR(200)
)
 
DECLARE @COMMODITIES AS TABLE
(
    strCommodity NVARCHAR(200)
)
 
DECLARE @tbl4 AS TABLE
(
	Commodity NVARCHAR(200)
    ,LocationName NVARCHAR(200)
    ,Valuation_Stock_Quantity DECIMAL(18,6)
    ,DPR_CustomerOwned DECIMAL(18,6)
    ,DIFF DECIMAL(18,6)
)
 
DECLARE @loc NVARCHAR(200)
DECLARE @commodity NVARCHAR(200)
DECLARE @commodityPrev NVARCHAR(200)

SET @intCommodityId = NULL
SET @dblDiff = 0

DECLARE @dblRiskStorage DECIMAL(18,6)
DECLARE @dblInventoryStorage DECIMAL(18,6)
--DECLARE @dblDiff DECIMAL(18,6)
 
INSERT INTO @COMMODITIES
SELECT DISTINCT * FROM (
SELECT strCommodityCode
FROM tblRKSummaryLog RK
INNER JOIN tblICCommodity CO   
    ON CO.intCommodityId = RK.intCommodityId
WHERE RK.strBucketType = 'Customer Owned'
UNION ALL
SELECT strCommodityCode
FROM tblICInventoryTransactionStorage IT
INNER JOIN tblICItem IC
    ON IC.intItemId = IT.intItemId
INNER JOIN tblICCommodity CO   
    ON CO.intCommodityId = IC.intCommodityId
) A
ORDER BY strCommodityCode
 
WHILE EXISTS(SELECT 1 FROM @COMMODITIES)
BEGIN
    SELECT TOP 1 @commodity = strCommodity FROM @COMMODITIES

    DELETE FROM @tbl4
 
    INSERT INTO @LOCATIONS
    SELECT strLocationName FROM tblSMCompanyLocation ORDER BY strLocationName
 
    WHILE EXISTS(SELECT 1 FROM @LOCATIONS)
    BEGIN
        SELECT TOP 1 @loc = strLocations FROM @LOCATIONS ORDER BY strLocations
 
        select @dblInventoryStorage = ISNULL(sum(
                    dbo.fnCalculateQtyBetweenUOM (
                        t.intItemUOMId
                        ,iu.intItemUOMId
                        ,t.dblQty
                    )
                ),0)
        from
            tblICInventoryTransactionStorage t inner join tblICItem i
                on t.intItemId = i.intItemId
            inner join tblICItemLocation il
                on il.intItemId = i.intItemId
                and il.intItemLocationId = t.intItemLocationId
            inner join tblICCommodity c    
                on c.intCommodityId = i.intCommodityId
            inner join tblSMCompanyLocation cl
                on cl.intCompanyLocationId = il.intLocationId
            left join tblICItemUOM iu
                on iu.intItemId = i.intItemId
                and iu.ysnStockUnit = 1
        where
            c.strCommodityCode = @commodity
            and cl.strLocationName = @loc
 
        SELECT @intCommodityId = intCommodityId FROM tblICCommodity c WHERE c.strCommodityCode = @commodity
 
        SET @dblRiskStorage = NULL
 
        select
            @dblRiskStorage = ISNULL(sum(ISNULL(dblTotal,0)),0)
        FROM
            dbo.fnRKGetBucketCustomerOwned(GETDATE(), @intCommodityId, NULL) t
            LEFT JOIN tblSCTicket SC ON t.intTicketId = SC.intTicketId
        WHERE
            ISNULL(strStorageType, '') <> 'ITR' AND intTypeId IN (1, 3, 4, 5, 8, 9)
            AND strCommodityCode = @commodity
            AND strLocationName = @loc
 
        INSERT INTO @tbl4
        SELECT @commodity, LocationName = @loc, dblInventoryStorage = @dblInventoryStorage, dblRiskStorage = @dblRiskStorage, DIFF = @dblInventoryStorage - @dblRiskStorage
 
        DELETE FROM @LOCATIONS WHERE strLocations = @loc
    END
 
    BEGIN
		DECLARE c CURSOR LOCAL FAST_FORWARD
		FOR 
		SELECT Commodity
			,LocationName
			,Valuation_Stock_Quantity
			,DPR_CustomerOwned
			,DIFF
		FROM @tbl4

		OPEN c
		FETCH NEXT FROM c INTO 
			@commodity
			,@loc
			,@dblInventoryStorage
			,@dblRiskStorage
			,@dblDiff

		SET @resultAsHTML += '<h4>' + ISNULL(@commodity,'') + '</h4>' +
			'<table border="1">' + 
			N'<tr>
				<th>Location</th>
				<th>Storage Type</th>
				<th align=''right''>Valuation Stock Quantity</th>
				<th align=''right''>DPR Customer Owned</th>
				<th align=''right''>Difference</th>
			</tr>' 

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @resultAsHTML += 
				N'<tr>' + 
				N'<td>'+ ISNULL(@loc,'') +'</td>' + 
				N'<td>'+ ISNULL(@strStorageType,'') +'</td>' +
				N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@dblInventoryStorage,0)) +'</td>' +
				N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@dblRiskStorage,0)) +'</td>' +					
				N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@dblDiff,0)) +'</td>' +
				N'</tr>'

			FETCH NEXT FROM c INTO 
				@commodity
				,@loc
				,@dblInventoryStorage
				,@dblRiskStorage
				,@dblDiff		

		END

		CLOSE c; DEALLOCATE c;	

		SET @resultAsHTML += N'</table>';
	END
 
    DELETE FROM @COMMODITIES WHERE strCommodity = @commodity	
END
/*'---END: 2. INVENTORY vs DPR CUSTOMER-OWNED---'*/

/*---START: 3. VALUATION SUMMARY vs DPR COMPANY-OWNED---'*/
SET @resultAsHTML += '<h3>Inventory vs DPR Company Owned</h3>'		

DELETE FROM @LOCATIONS 
DELETE FROM @COMMODITIES 

DECLARE @tbl5 AS TABLE
(
	Commodity NVARCHAR(200)
    ,LocationName NVARCHAR(200)
    ,Valuation_Stock_Quantity DECIMAL(18,6)
    ,DPR_CompanyOwned DECIMAL(18,6)
    ,DIFF DECIMAL(18,6)
)
 
SET @loc = NULL
SET @commodity = NULL
SET @commodityPrev = NULL
SET @dblDiff = 0

DECLARE @dblRiskCompanyOwned DECIMAL(18,6)
DECLARE @dblValuationSummary DECIMAL(18,6)
DECLARE @fiscalMonth NVARCHAR(200) = 'September 2021'
DECLARE @date DATETIME = '09/30/2021'
 
INSERT INTO @COMMODITIES
SELECT DISTINCT * FROM (
SELECT strCommodityCode
FROM tblRKSummaryLog RK
INNER JOIN tblICCommodity CO   
    ON CO.intCommodityId = RK.intCommodityId
WHERE RK.strBucketType = 'Company Owned'
UNION ALL
SELECT strCommodityCode
FROM tblICInventoryTransactionStorage IT
INNER JOIN tblICItem IC
    ON IC.intItemId = IT.intItemId
INNER JOIN tblICCommodity CO   
    ON CO.intCommodityId = IC.intCommodityId
) A
ORDER BY strCommodityCode
 
WHILE EXISTS(SELECT 1 FROM @COMMODITIES)
BEGIN
    SELECT TOP 1 @commodity = strCommodity FROM @COMMODITIES
 
    --SELECT @commodity
 
    INSERT INTO @LOCATIONS
    SELECT strLocationName FROM tblSMCompanyLocation ORDER BY strLocationName
 
    DELETE FROM @tbl5
 
    WHILE EXISTS(SELECT 1 FROM @LOCATIONS)
    BEGIN
		SELECT TOP 1 @loc = strLocations FROM @LOCATIONS ORDER BY strLocations
 
		PRINT 'Checking ' + @loc + ' location for ' + @commodity
 
		INSERT INTO @tbl5
		select @commodity
			,@loc
			,dblQty = ISNULL(sum(
					dbo.fnCalculateQtyBetweenUOM (
						t.intItemUOMId
						,iu.intItemUOMId
						,t.dblQty
					)
				),0)
				,0,0
			from
				tblICInventoryTransaction t inner join tblICItem i
					on t.intItemId = i.intItemId
				inner join tblICItemLocation il
					on il.intItemId = i.intItemId
					and (
						il.intItemLocationId = t.intItemLocationId
					)
				inner join tblICCommodity c    
					on c.intCommodityId = i.intCommodityId
				inner join tblSMCompanyLocation cl
					on cl.intCompanyLocationId = il.intLocationId
				left join tblICItemUOM iu
					on iu.intItemId = i.intItemId
					and iu.ysnStockUnit = 1
			where
				c.strCommodityCode = @commodity
				and cl.strLocationName = @loc
				and t.intInTransitSourceLocationId is null
 
		select @dblRiskCompanyOwned = ISNULL(sum(ISNULL(l.dblOrigQty,0)),0)
		from [vyuRKGetSummaryLog] l where
			l.strBucketType = 'Company Owned'
			and l.strCommodityCode = @commodity
			and l.strLocationName = @loc
			--and DATEADD(dd, DATEDIFF(dd, 0, dtmTransactionDate), 0) <= @date
 
		UPDATE @tbl5 SET DPR_CompanyOwned = @dblRiskCompanyOwned WHERE LocationName = @loc AND Commodity = @commodity
 
		UPDATE @tbl5 SET DIFF = DPR_CompanyOwned - Valuation_Stock_Quantity WHERE LocationName = @loc AND Commodity = @commodity
 
		DELETE FROM @LOCATIONS WHERE strLocations = @loc
    END
 
    BEGIN
		DECLARE c CURSOR LOCAL FAST_FORWARD
		FOR 
		SELECT Commodity
			,LocationName
			,Valuation_Stock_Quantity
			,DPR_CompanyOwned
			,DIFF
		FROM @tbl5

		OPEN c
		FETCH NEXT FROM c INTO 
			@commodity
			,@loc
			,@dblValuationSummary
			,@dblRiskCompanyOwned
			,@dblDiff

		SET @resultAsHTML += '<h4>' + ISNULL(@commodity,'') + '</h4>' +
			'<table border="1">' + 
			N'<tr>
				<th>Location</th>
				<th>Storage Type</th>
				<th align=''right''>Inventory</th>
				<th align=''right''>DPR Company Owned</th>
				<th align=''right''>Difference</th>
			</tr>' 

		WHILE @@FETCH_STATUS = 0
		BEGIN
			SET @resultAsHTML += 
				N'<tr>' + 
				N'<td>'+ ISNULL(@loc,'') +'</td>' + 
				N'<td>'+ ISNULL(@strStorageType,'') +'</td>' +
				N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@dblValuationSummary,0)) +'</td>' +
				N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@dblRiskCompanyOwned,0)) +'</td>' +					
				N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@dblDiff,0)) +'</td>' +
				N'</tr>'		

			FETCH NEXT FROM c INTO 
				@commodity
				,@loc
				,@dblValuationSummary
				,@dblRiskCompanyOwned
				,@dblDiff		

		END

		CLOSE c; DEALLOCATE c;	
		
		SET @resultAsHTML += N'</table>'; 
	END
 
    DELETE FROM @COMMODITIES WHERE strCommodity = @commodity
END
/*---END: 3. VALUATION SUMMARY vs DPR COMPANY-OWNED---'*/

/*---START: 4. CUSTOMER STORAGE vs HISTORY DIFF---'*/
DECLARE @tbl6 AS TABLE (
	intCustomerStorageId INT
    ,strStorageTicketNumber NVARCHAR(50)
    ,strTransferStorageTicket NVARCHAR(50)
    ,strName NVARCHAR(500)
    ,strEntityNo NVARCHAR(100)
    ,strStorageTypeDescription NVARCHAR(50)
    ,TotalOpenBalanceHeader DECIMAL(18,6)
    ,TotalOpenBalanceHistoryDetail DECIMAL(18,6)
    ,DIFF DECIMAL(18,6)
)

DECLARE @intCustomerStorageId INT
DECLARE @dtmDeliveryDate DATETIME
DECLARE @strStorageTicketNumber NVARCHAR(50)
DECLARE @strTransferStorageTicket NVARCHAR(50)
SET @strName = NULL
DECLARE @strEntityNo NVARCHAR(50)
SET @strStorageType = NULL
DECLARE @TotalBalanceHeader DECIMAL(18,6)
DECLARE @TotalBalanceHistoryDetail DECIMAL(18,6)
DECLARE @DIFF DECIMAL(18,6)

--CUSTOMER STORAGE HISTORY'S RUNNING BALANCE VS OPEN BALANCE
INSERT INTO @tbl6
SELECT
    A.intCustomerStorageId
    ,CS.strStorageTicketNumber
    ,TS_TRANSFER.strTransferStorageTicket
    ,EM.strName
    ,EM.strEntityNo
    ,A.strStorageTypeDescription
    ,A.TotalOpenBalanceHeader
    ,A.TotalOpenBalanceHistoryDetail
    ,A.DIFF
FROM (
SELECT
    A.intCustomerStorageId
    ,A.strStorageTypeDescription
    ,TotalOpenBalanceHeader
    ,TotalOpenBalanceHistoryDetail
    ,SUM(TotalOpenBalanceHeader - TotalOpenBalanceHistoryDetail) AS DIFF
FROM (
        SELECT
            A.intCustomerStorageId
            ,A.dblOpenBalance AS TotalOpenBalanceHeader
            ,B.strStorageTypeDescription
        FROM tblGRCustomerStorage  A
        INNER JOIN tblGRStorageType B
            ON A.intStorageTypeId = B.intStorageScheduleTypeId
        WHERE --B.strStorageTypeDescription IN ('GRAIN BANK','DELAYED PRICING', 'OPEN STORAGE', 'WAREHOUSE RECEIPT', 'TERMINAL') -- mcp
        B.intStorageScheduleTypeId > 0 --zeeland
            AND A.intCommodityId IN (SELECT DISTINCT intCommodityId FROM tblGRCustomerStorage)
    ) A
INNER JOIN (
            SELECT
                A.intCustomerStorageId
                ,SUM(CASE
                        WHEN (strType = 'Settlement' OR strType ='Reduced By Inventory Shipment') AND dblUnits > 0 THEN - dblUnits
                        ELSE dblUnits
                    END) AS TotalOpenBalanceHistoryDetail
                ,C.strStorageTypeDescription
            FROM tblGRStorageHistory A
            INNER JOIN tblGRCustomerStorage B
                ON A.intCustomerStorageId  = B.intCustomerStorageId
            INNER JOIN tblGRStorageType C
                ON B.intStorageTypeId = C.intStorageScheduleTypeId
            WHERE --C.strStorageTypeDescription IN ('GRAIN BANK','DELAYED PRICING', 'OPEN STORAGE', 'WAREHOUSE RECEIPT', 'TERMINAL') --mcp
            C.intStorageScheduleTypeId > 0 --zeeland
                AND A.intTransactionTypeId NOT IN (2,6)
                AND B.intCommodityId IN (SELECT DISTINCT intCommodityId FROM tblGRCustomerStorage)
            GROUP BY A.intCustomerStorageId ,C.strStorageTypeDescription
        ) B
    ON A.intCustomerStorageId = B.intCustomerStorageId
GROUP BY
    A.intCustomerStorageId
    ,A.strStorageTypeDescription
    ,TotalOpenBalanceHeader
    ,TotalOpenBalanceHistoryDetail
) A
INNER JOIN tblGRCustomerStorage CS
    ON CS.intCustomerStorageId = A.intCustomerStorageId
INNER JOIN tblEMEntity EM
    ON EM.intEntityId = CS.intEntityId
INNER JOIN tblICItem IT
    ON IT.intItemId = CS.intItemId
INNER JOIN tblICCommodity IC
    ON IC.intCommodityId = IT.intCommodityId
LEFT JOIN (tblGRTransferStorageReference TSR_TRANSFER
            INNER JOIN tblGRTransferStorage TS_TRANSFER
                ON TS_TRANSFER.intTransferStorageId = TSR_TRANSFER.intTransferStorageId
        )
    ON TSR_TRANSFER.intToCustomerStorageId = CS.intCustomerStorageId
  
WHERE --A.DIFF <> 0
    (A.DIFF > 0.01 OR A.DIFF < -0.01)
    --AND strStorageTicketNumber= '1018-19001'
    --and IC.strCommodityCode = 'SWW'
ORDER BY A.DIFF DESC

SET @resultAsHTML += 
	'<h3>Customer Storage vs History Diff</h3>' +
	'<h4>By Open Balance</h4>' +
	'<table border="1">' + 
	N'<tr>
		<th align=''right''>intCustomerStorageId</th>
		<th>Storage Ticket #</th>
		<th>Transfer Storage Ticket #</th>
		<th>Name</th>
		<th>Entity No.</th>
		<th>strStorageTypeDescription</th>
		<th align=''right''>Open Balance</th>
		<th align=''right''>History Running Balance</th>
		<th align=''right''>Difference</th>
	</tr>' 

BEGIN
	DECLARE c CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT intCustomerStorageId
		,strStorageTicketNumber
		,strTransferStorageTicket
		,strName
		,strEntityNo
		,strStorageTypeDescription
		,TotalOpenBalanceHeader
		,TotalOpenBalanceHistoryDetail
		,DIFF
	FROM @tbl6

	OPEN c
	FETCH NEXT FROM c INTO 
		@intCustomerStorageId
		,@strStorageTicketNumber
		,@strTransferStorageTicket
		,@strName
		,@strEntityNo
		,@strStorageType
		,@TotalBalanceHeader
		,@TotalBalanceHistoryDetail
		,@DIFF

	WHILE @@FETCH_STATUS = 0
	BEGIN 
		SET @resultAsHTML += 
			N'<tr>' + 
			N'<td align=''right''>'+ ISNULL(dbo.fnICFormatNumber(@intCustomerStorageId),'') +'</td>' +
			N'<td>'+ ISNULL(@strStorageTicketNumber,'') +'</td>' + 
			N'<td>'+ ISNULL(@strTransferStorageTicket,'') +'</td>' + 
			N'<td>'+ ISNULL(@strName,'') +'</td>' + 
			N'<td>'+ ISNULL(@strEntityNo,'') +'</td>' + 
			N'<td>'+ ISNULL(@strStorageType,'') +'</td>' + 
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@TotalBalanceHeader,0)) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@TotalBalanceHistoryDetail,0)) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@DIFF,0)) +'</td>' +
			N'</tr>'

		FETCH NEXT FROM c INTO 
			@intCustomerStorageId
			,@strStorageTicketNumber
			,@strTransferStorageTicket
			,@strName
			,@strEntityNo
			,@strStorageType
			,@TotalBalanceHeader
			,@TotalBalanceHistoryDetail
			,@DIFF
	END

	CLOSE c; DEALLOCATE c;

	SET @resultAsHTML += N'</table>'; 
END

DELETE FROM @tbl6

SET @intCustomerStorageId = NULL
SET @dtmDeliveryDate = NULL
SET @strStorageTicketNumber = NULL
SET @strTransferStorageTicket = NULL
SET @strName = NULL
SET @strEntityNo = NULL
SET @strStorageType = NULL
SET @TotalBalanceHeader = 0
SET @TotalBalanceHistoryDetail = 0
SET @DIFF = NULL

--CUSTOMER STORAGE HISTORY'S RUNNING BALANCE VS ORIGINAL BALANCE
INSERT INTO @tbl6
SELECT
    A.intCustomerStorageId
    ,CS.strStorageTicketNumber
	,''
    ,EM.strName
    ,EM.strEntityNo
    ,A.strStorageTypeDescription
    ,A.TotalOriginalBalanceHeader
    ,A.TotalOriginalBalanceHistoryDetail
    ,A.DIFF
FROM (
SELECT
    A.intCustomerStorageId
    ,A.strStorageTypeDescription
    ,TotalOriginalBalanceHeader
    ,TotalOriginalBalanceHistoryDetail
    ,SUM(TotalOriginalBalanceHeader - TotalOriginalBalanceHistoryDetail) AS DIFF
FROM (
        SELECT
            A.intCustomerStorageId
            ,A.dblOriginalBalance AS TotalOriginalBalanceHeader
            ,B.strStorageTypeDescription
        FROM tblGRCustomerStorage  A
        INNER JOIN tblGRStorageType B
            ON A.intStorageTypeId = B.intStorageScheduleTypeId
        WHERE --B.strStorageTypeDescription IN ('GRAIN BANK','DELAYED PRICING', 'OPEN STORAGE', 'WAREHOUSE RECEIPT', 'TERMINAL') -- mcp
        B.intStorageScheduleTypeId > 0 --zeeland
            AND A.intCommodityId IN (SELECT DISTINCT intCommodityId FROM tblGRCustomerStorage)
    ) A
INNER JOIN (
            SELECT
                A.intCustomerStorageId
                ,SUM(A.dblUnits) AS TotalOriginalBalanceHistoryDetail
                ,C.strStorageTypeDescription
            FROM tblGRStorageHistory A
            INNER JOIN tblGRCustomerStorage B
                ON A.intCustomerStorageId  = B.intCustomerStorageId
            INNER JOIN tblGRStorageType C
                ON B.intStorageTypeId = C.intStorageScheduleTypeId
            WHERE --C.strStorageTypeDescription IN ('GRAIN BANK','DELAYED PRICING', 'OPEN STORAGE', 'WAREHOUSE RECEIPT', 'TERMINAL') --mcp
                C.intStorageScheduleTypeId > 0 --zeeland
                AND ((A.intTransactionTypeId = 5 --DS
                        OR A.strType = 'From Transfer' --FROM TRANSFER
                        OR (A.strType = 'From Scale' and A.intTransactionTypeId = 1)) --SC; exclude 'From Scale - Datafix'
                        OR (A.intTransactionTypeId = 9 AND (A.strPaidDescription = 'Quantity Adjustment From Delivery Sheet' OR A.strPaidDescription LIKE '%GRN-2593%') AND A.intInventoryAdjustmentId IS NOT NULL)) --IA-XXXX
                AND B.intCommodityId IN (SELECT DISTINCT intCommodityId FROM tblGRCustomerStorage)
            GROUP BY A.intCustomerStorageId ,C.strStorageTypeDescription
        ) B
    ON A.intCustomerStorageId = B.intCustomerStorageId
GROUP BY
    A.intCustomerStorageId
    ,A.strStorageTypeDescription
    ,TotalOriginalBalanceHeader
    ,TotalOriginalBalanceHistoryDetail
) A
INNER JOIN tblGRCustomerStorage CS
    ON CS.intCustomerStorageId = A.intCustomerStorageId
INNER JOIN tblEMEntity EM
    ON EM.intEntityId = CS.intEntityId
INNER JOIN tblICItem IT
    ON IT.intItemId = CS.intItemId
INNER JOIN tblICCommodity IC
    ON IC.intCommodityId = IT.intCommodityId
WHERE --A.DIFF <> 0
    A.DIFF > 0.1 OR A.DIFF < -0.1
ORDER BY A.DIFF DESC

SET @resultAsHTML += 
	'<h4>By Original Balance</h4>' +
	'<table border="1">' + 
	N'<tr>
		<th align=''right''>intCustomerStorageId</th>
		<th>dtmDeliveryDate</th>
		<th>strStorageTicketNumber</th>
		<th>strTransferStorageTicket</th>
		<th>strName</th>
		<th>strEntityNo</th>
		<th>strStorageTypeDescription</th>
		<th align=''right''>Storage Original Balance</th>
		<th align=''right''>History Original Balance</th>
		<th align=''right''>Difference</th>
	</tr>'

BEGIN
	DECLARE c CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT intCustomerStorageId
		,strStorageTicketNumber
		,strTransferStorageTicket
		,strName
		,strEntityNo
		,strStorageTypeDescription
		,TotalOpenBalanceHeader
		,TotalOpenBalanceHistoryDetail
		,DIFF
	FROM @tbl6

	OPEN c
	FETCH NEXT FROM c INTO 
		@intCustomerStorageId
		,@strStorageTicketNumber
		,@strTransferStorageTicket
		,@strName
		,@strEntityNo
		,@strStorageType
		,@TotalBalanceHeader
		,@TotalBalanceHistoryDetail
		,@DIFF

	WHILE @@FETCH_STATUS = 0
	BEGIN 
		SET @resultAsHTML += 
			N'<tr>' + 
			N'<td align=''right''>'+ ISNULL(dbo.fnICFormatNumber(@intCustomerStorageId),'') +'</td>' + 
			N'<td>'+ ISNULL(@strStorageTicketNumber,'') +'</td>' + 
			N'<td>'+ ISNULL(@strTransferStorageTicket,'') +'</td>' + 
			N'<td>'+ ISNULL(@strName,'') +'</td>' + 
			N'<td>'+ ISNULL(@strEntityNo,'') +'</td>' + 
			N'<td>'+ ISNULL(@strStorageType,'') +'</td>' + 
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@TotalBalanceHeader,0)) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@TotalBalanceHistoryDetail,0)) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@DIFF,0)) +'</td>' +
			N'</tr>'

		FETCH NEXT FROM c INTO 
			@intCustomerStorageId
			,@strStorageTicketNumber
			,@strTransferStorageTicket
			,@strName
			,@strEntityNo
			,@strStorageType
			,@TotalBalanceHeader
			,@TotalBalanceHistoryDetail
			,@DIFF
	END

	CLOSE c; DEALLOCATE c;

	SET @resultAsHTML += N'</table>'; 
END

/*---END: 4. CUSTOMER STORAGE vs HISTORY DIFF---'*/

/*'---START: 5. CUSTOMER STORAGE vs HISTORY DIFF---'*/
DECLARE @tbl7 AS TABLE (
	strStorageTypeDescription NVARCHAR(50)
    ,strCommodityCode NVARCHAR(40)
    ,SOURCE_TRANSFER_QTY DECIMAL(18,6)
    ,TotalHistoryUnits DECIMAL(18,6)
    ,DIFF DECIMAL(18,6)
)

DECLARE @SOURCE_TRANSFER_QTY DECIMAL(18,6)
DECLARE @TotalHistoryUnits DECIMAL(18,6)

SET @strStorageType = NULL
SET @strCommodityCode = NULL
SET @DIFF = 0

SET @resultAsHTML += 
	'<h3>Transfer Storage vs Storage History</h3>' +
	'<h4>By Source Transfer</h4>' +
	'<table border="1">' + 
	N'<tr>
		<th>Storage Type</th>
		<th>Commodity</th>
		<th align=''right''>SOURCE_TRANSFER_QTY</th>
		<th align=''right''>Total History Units</th>
		<th align=''right''>Difference</th>
	</tr>' 

INSERT INTO @tbl7
SELECT
    TRANSFER_FROM.strStorageTypeDescription
    ,STORAGE_HISTORY_TRANSFER.strCommodityCode
    ,TRANSFER_FROM.SOURCE_TRANSFER_QTY
    ,TotalHistoryUnits
    ,DIFF = TRANSFER_FROM.SOURCE_TRANSFER_QTY - TotalHistoryUnits
FROM (
        SELECT
            SOURCE_TRANSFER_QTY = (SUM(TSR.dblUnitQty)) * -1
            ,ST.strStorageTypeDescription
            ,IC.strCommodityCode
        FROM tblGRTransferStorage TS
        INNER JOIN tblGRTransferStorageReference TSR
            ON TSR.intTransferStorageId = TS.intTransferStorageId
        INNER JOIN tblGRCustomerStorage CS_FROM
            ON CS_FROM.intCustomerStorageId = TSR.intSourceCustomerStorageId
        INNER JOIN tblICCommodity IC
            ON IC.intCommodityId = CS_FROM.intCommodityId
        INNER JOIN tblGRStorageType ST
            ON ST.intStorageScheduleTypeId = CS_FROM.intStorageTypeId
        GROUP BY ST.strStorageTypeDescription
            ,IC.strCommodityCode
) TRANSFER_FROM
INNER JOIN (
        SELECT
            TotalHistoryUnits = SUM(dblUnits)
            ,A.strType
            ,C.strStorageTypeDescription
            ,D.strCommodityCode
        FROM tblGRStorageHistory A
        INNER JOIN tblGRCustomerStorage B
            ON A.intCustomerStorageId = B.intCustomerStorageId
        INNER JOIN tblGRStorageType C
            ON B.intStorageTypeId = C.intStorageScheduleTypeId
        INNER JOIN tblICCommodity D
            ON B.intCommodityId = D.intCommodityId
        WHERE (C.strOwnedPhysicalStock IN ('Customer') OR C.ysnDPOwnedType = 1)
            AND A.intTransactionTypeId NOT IN (2,6)
            AND (A.intTransactionTypeId = 3 AND A.strType = 'Transfer')
        GROUP BY C.strStorageTypeDescription, D.strCommodityCode,A.strType
) STORAGE_HISTORY_TRANSFER
        ON TRANSFER_FROM.strStorageTypeDescription = STORAGE_HISTORY_TRANSFER.strStorageTypeDescription
WHERE TRANSFER_FROM.strCommodityCode = STORAGE_HISTORY_TRANSFER.strCommodityCode
GROUP BY TRANSFER_FROM.strStorageTypeDescription
    ,STORAGE_HISTORY_TRANSFER.strCommodityCode
    ,TRANSFER_FROM.SOURCE_TRANSFER_QTY
    ,TotalHistoryUnits

BEGIN
	DECLARE c CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT strStorageTypeDescription
		,strCommodityCode
		,SOURCE_TRANSFER_QTY
		,TotalHistoryUnits
		,DIFF
	FROM @tbl7

	OPEN c
	FETCH NEXT FROM c INTO 
		@strStorageType
		,@strCommodityCode
		,@SOURCE_TRANSFER_QTY
		,@TotalHistoryUnits
		,@DIFF

	WHILE @@FETCH_STATUS = 0
	BEGIN 
		SET @resultAsHTML += 
			N'<tr>' + 
			N'<td>'+ ISNULL(@strStorageType,'') +'</td>' + 
			N'<td>'+ ISNULL(@strCommodityCode,'') +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@SOURCE_TRANSFER_QTY,0)) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@TotalHistoryUnits,0)) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@DIFF,0)) +'</td>' +
			N'</tr>'

		FETCH NEXT FROM c INTO 
			@strStorageType
			,@strCommodityCode
			,@SOURCE_TRANSFER_QTY
			,@TotalHistoryUnits
			,@DIFF
	END

	CLOSE c; DEALLOCATE c;

	SET @resultAsHTML += N'</table>'; 
END

DELETE FROM @tbl7
SET @SOURCE_TRANSFER_QTY = 0
SET @TotalHistoryUnits = 0
SET @strStorageType = NULL
SET @strCommodityCode = NULL
SET @DIFF = 0

SET @resultAsHTML += 
	'<h4>By Transfer To</h4>' +
	'<table border="1">' + 
	N'<tr>
		<th>Storage Type</th>
		<th>Commodity</th>
		<th align=''right''>TRANSFER_TO_QTY</th>
		<th align=''right''>Total History Units</th>
		<th align=''right''>Difference</th>
	</tr>' 

INSERT INTO @tbl7 
SELECT
    TRANSFER_TO.strStorageTypeDescription
    ,STORAGE_HISTORY_TRANSFER.strCommodityCode
    ,TRANSFER_TO.TRANSFER_TO_QTY
    ,TotalHistoryUnits
    ,DIFF = TRANSFER_TO.TRANSFER_TO_QTY - TotalHistoryUnits
FROM (
        SELECT
            TRANSFER_TO_QTY = SUM(TSR.dblUnitQty)
            ,ST.strStorageTypeDescription
            ,IC.strCommodityCode
        FROM tblGRTransferStorage TS
        INNER JOIN tblGRTransferStorageReference TSR
            ON TSR.intTransferStorageId = TS.intTransferStorageId
        INNER JOIN tblGRCustomerStorage CS_TO
            ON CS_TO.intCustomerStorageId = TSR.intToCustomerStorageId
        INNER JOIN tblICCommodity IC
            ON IC.intCommodityId = CS_TO.intCommodityId
        INNER JOIN tblGRStorageType ST
            ON ST.intStorageScheduleTypeId = CS_TO.intStorageTypeId
        GROUP BY ST.strStorageTypeDescription
            ,IC.strCommodityCode
) TRANSFER_TO
INNER JOIN (
        SELECT
            TotalHistoryUnits = SUM(dblUnits)
            ,A.strType
            ,C.strStorageTypeDescription
            ,D.strCommodityCode
        FROM tblGRStorageHistory A
        INNER JOIN tblGRCustomerStorage B
            ON A.intCustomerStorageId = B.intCustomerStorageId
        INNER JOIN tblGRStorageType C
            ON B.intStorageTypeId = C.intStorageScheduleTypeId
        INNER JOIN tblICCommodity D
            ON B.intCommodityId = D.intCommodityId
        WHERE (C.strOwnedPhysicalStock IN ('Customer') OR C.ysnDPOwnedType = 1)
            AND A.intTransactionTypeId NOT IN (2,6)
            AND (A.intTransactionTypeId = 3 AND strType = 'From Transfer')
        GROUP BY C.strStorageTypeDescription, D.strCommodityCode,A.strType
) STORAGE_HISTORY_TRANSFER
        ON TRANSFER_TO.strStorageTypeDescription = STORAGE_HISTORY_TRANSFER.strStorageTypeDescription
WHERE TRANSFER_TO.strCommodityCode = STORAGE_HISTORY_TRANSFER.strCommodityCode
GROUP BY TRANSFER_TO.strStorageTypeDescription
    ,STORAGE_HISTORY_TRANSFER.strCommodityCode
    ,TRANSFER_TO.TRANSFER_TO_QTY
    ,TotalHistoryUnits

BEGIN
	DECLARE c CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT strStorageTypeDescription
		,strCommodityCode
		,SOURCE_TRANSFER_QTY
		,TotalHistoryUnits
		,DIFF
	FROM @tbl7

	OPEN c
	FETCH NEXT FROM c INTO 
		@strStorageType
		,@strCommodityCode
		,@SOURCE_TRANSFER_QTY
		,@TotalHistoryUnits
		,@DIFF

	WHILE @@FETCH_STATUS = 0
	BEGIN 
		SET @resultAsHTML += 
			N'<tr>' + 
			N'<td>'+ ISNULL(@strStorageType,'') +'</td>' + 
			N'<td>'+ ISNULL(@strCommodityCode,'') +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@SOURCE_TRANSFER_QTY,0)) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@TotalHistoryUnits,0)) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@DIFF,0)) +'</td>' +
			N'</tr>'

		FETCH NEXT FROM c INTO 
			@strStorageType
			,@strCommodityCode
			,@SOURCE_TRANSFER_QTY
			,@TotalHistoryUnits
			,@DIFF
	END

	CLOSE c; DEALLOCATE c;

	SET @resultAsHTML += N'</table>'; 
END
/*'---END: 5. CUSTOMER STORAGE vs HISTORY DIFF---'*/

/*---START: 6. SETTLED STORAGES vs STORAGE HISTORY---'*/
DECLARE @tbl8 AS TABLE (
	 strStorageTypeDescription NVARCHAR(100)
    ,strCommodityCode NVARCHAR(50)
    ,TOTAL_SETTLEMENT DECIMAL(18,6)
    ,TotalHistoryUnits DECIMAL(18,6)
    ,DIFF DECIMAL(18,6)
)

DECLARE @TOTAL_SETTLEMENT DECIMAL(18,6)
SET @strStorageType = NULL
SET @strCommodityCode = NULL
SET @TotalHistoryUnits = 0
SET @DIFF = 0

SET @resultAsHTML += 
	'<h3>Settled Storages vs History</h3>' +
	'<table border="1">' + 
	N'<tr>
		<th>Storage Type</th>
		<th>Commodity</th>
		<th align=''right''>Total Settlement</th>
		<th align=''right''>Total History Units</th>
		<th align=''right''>Difference</th>
	</tr>' 

INSERT INTO @tbl8
SELECT
    A.strStorageTypeDescription
    ,B.strCommodityCode
    ,TOTAL_SETTLEMENT
    ,TotalHistoryUnits
    ,DIFF = TOTAL_SETTLEMENT- TotalHistoryUnits
FROM (
        SELECT    
            TOTAL_SETTLEMENT = (SUM(CASE WHEN ISNULL(SS.dblSpotUnits,0) = 0 THEN (CASE WHEN SC.dblUnits < 0 THEN SC.dblUnits * -1 ELSE SC.dblUnits END) ELSE CASE WHEN SS.dblSpotUnits < 0 THEN SS.dblSpotUnits * -1 ELSE SS.dblSpotUnits END END)) * -1                                         
            ,ST.strStorageTypeDescription
            ,IC.strCommodityCode
        FROM tblGRSettleStorage SS
        INNER JOIN tblGRSettleStorageTicket SST
            ON SST.intSettleStorageId = SS.intSettleStorageId
        LEFT JOIN tblGRSettleContract SC
            ON SC.intSettleStorageId = SS.intSettleStorageId
        INNER JOIN tblGRCustomerStorage CS
            ON CS.intCustomerStorageId = SST.intCustomerStorageId
        INNER JOIN tblGRStorageType ST
            ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
        INNER JOIN tblICCommodity IC
            ON IC.intCommodityId = CS.intCommodityId
        WHERE SS.intParentSettleStorageId IS NOT NULL
        GROUP BY ST.strStorageTypeDescription
            ,IC.strCommodityCode
) A
INNER JOIN (
        SELECT
            TotalHistoryUnits = (SUM(dblUnits)) * -1
            ,C.strStorageTypeDescription
            ,D.strCommodityCode
        FROM tblGRStorageHistory A
        INNER JOIN tblGRCustomerStorage B
            ON A.intCustomerStorageId = B.intCustomerStorageId
        INNER JOIN tblGRStorageType C
            ON B.intStorageTypeId  = C.intStorageScheduleTypeId
        INNER JOIN tblICCommodity D
            ON B.intCommodityId = D.intCommodityId
        WHERE (C.strOwnedPhysicalStock IN ('Customer') OR C.ysnDPOwnedType = 1)
            AND A.intTransactionTypeId NOT IN (2,6)
            AND (A.intTransactionTypeId = 4 AND A.intSettleStorageId IS NOT NULL)
        GROUP BY C.strStorageTypeDescription, D.strCommodityCode
) B
    ON A.strStorageTypeDescription = B.strStorageTypeDescription
WHERE A.strCommodityCode = B.strCommodityCode
GROUP BY A.strStorageTypeDescription
    ,TOTAL_SETTLEMENT
    ,TotalHistoryUnits
    ,B.strCommodityCode

BEGIN
	DECLARE c CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT strStorageTypeDescription
		,strCommodityCode
		,TOTAL_SETTLEMENT
		,TotalHistoryUnits
		,DIFF
	FROM @tbl8

	OPEN c
	FETCH NEXT FROM c INTO 
		@strStorageType
		,@strCommodityCode
		,@TOTAL_SETTLEMENT
		,@TotalHistoryUnits
		,@DIFF

	WHILE @@FETCH_STATUS = 0
	BEGIN 
		SET @resultAsHTML += 
			N'<tr>' + 
			N'<td>'+ ISNULL(@strStorageType,'') +'</td>' + 
			N'<td>'+ ISNULL(@strCommodityCode,'') +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@TOTAL_SETTLEMENT,0)) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@TotalHistoryUnits,0)) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@DIFF,0)) +'</td>' +
			N'</tr>'

		FETCH NEXT FROM c INTO 
			@strStorageType
			,@strCommodityCode
			,@TOTAL_SETTLEMENT
			,@TotalHistoryUnits
			,@DIFF
	END

	CLOSE c; DEALLOCATE c;

	SET @resultAsHTML += N'</table>'; 
END

/*'---END: 6. SETTLED STORAGES vs STORAGE HISTORY---'*/

/*---START: 7. CHECK DOUBLED STORAGE---'*/
DECLARE @tbl9 AS TABLE (
	strStorageTicketNumber NVARCHAR(100)
	,cnt INT
)

DECLARE @cnt INT
SET @strStorageTicketNumber = NULL

INSERT INTO @tbl9
SELECT strStorageTicketNumber
    ,CNT = COUNT(strStorageTicketNumber)
FROM tblGRCustomerStorage
WHERE ysnTransferStorage = 0
GROUP BY intEntityId
    ,strStorageTicketNumber
    ,intStorageTypeId
    ,intStorageScheduleId
    ,intCompanyLocationId
HAVING COUNT(strStorageTicketNumber) > 1

SET @resultAsHTML += 
	'<h3>Check doubled Storage</h3>' +
	'<table border="1">' + 
	N'<tr>
		<th>strStorageTicketNumber</th>
		<th align=''right''>COUNT</th>
	</tr>' 

--IF @emailProfileName IS NOT NULL AND @emailRecipient IS NOT NULL 
BEGIN	
	BEGIN
		DECLARE c CURSOR LOCAL FAST_FORWARD
		FOR 
		SELECT strStorageTicketNumber
			,cnt
		FROM @tbl9

		OPEN c
		FETCH NEXT FROM c INTO 
			@strStorageTicketNumber
			,@cnt

		WHILE @@FETCH_STATUS = 0
		BEGIN 
			SET @resultAsHTML += 
				N'<tr>' + 
				N'<td>'+ ISNULL(@strStorageTicketNumber,'') +'</td>' + 
				N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@cnt,0)) +'</td>' +
				N'</tr>'

			FETCH NEXT FROM c INTO 
				@strStorageTicketNumber
				,@cnt
		END

		CLOSE c; DEALLOCATE c;

		SET @resultAsHTML += N'</table>'; 
	END	
END
/*---END: 7. CHECK DOUBLED STORAGE---'*/

/*---START: 8. CHECK IR WITH NO STORAGE---'*/

IF OBJECT_ID('tempdb..#tmpIR') IS NOT NULL DROP TABLE #tmpIR
IF OBJECT_ID('tempdb..#tmpCS') IS NOT NULL DROP TABLE #tmpCS
  
SELECT IR.intInventoryReceiptId
    ,IR.strReceiptNumber
    ,IRI.dblOpenReceive
INTO #tmpIR
FROM tblICInventoryReceipt IR
INNER JOIN tblICInventoryReceiptItem IRI
    ON IRI.intInventoryReceiptId = IR.intInventoryReceiptId
LEFT JOIN tblCTContractHeader CH
    ON CH.intContractHeaderId = IRI.intContractHeaderId
        AND CH.intPricingTypeId = 5 --DP
WHERE IRI.intOwnershipType = 2
    OR (IRI.intOwnershipType = 1 AND CH.intContractHeaderId IS NOT NULL)
  
SELECT SH.intInventoryReceiptId
    --,CS.intCustomerStorageId
    ,SH.dblUnits
INTO #tmpCS
FROM tblGRStorageHistory SH
INNER JOIN tblGRCustomerStorage CS
    ON CS.intCustomerStorageId = SH.intCustomerStorageId
WHERE SH.intTransactionTypeId = 1

DECLARE @tbl10 AS TABLE (
	intInventoryReceiptId INT
	,storage_ir INT
	,strReceiptNumber NVARCHAR(50)
	,dblOpenReceive DECIMAL(18,6)
	,dblUnits DECIMAL(18,6)
	,DIFF DECIMAL(18,6)
	,NOTES NVARCHAR(100)
)

DECLARE @intInventoryReceiptId INT
DECLARE @storage_ir INT
DECLARE @strReceiptNumber NVARCHAR(50)
DECLARE @dblOpenReceive DECIMAL(18,6)
DECLARE @dblUnits DECIMAL(18,6)
SET @DIFF = 0
DECLARE @NOTES NVARCHAR(100)

INSERT INTO @tbl10
SELECT * FROM (
SELECT *
    ,NOTES = CASE
                WHEN intInventoryReceiptId IS NULL THEN 'Storage has no IR'
                WHEN storage_ir IS NULL THEN 'IR has no storage'
                WHEN DIFF > 1 OR DIFF < -1 THEN 'Discrepancy'
                WHEN DIFF < 0.1 OR DIFF > -0.1 THEN 'Rounding off issue'
                ELSE ''
            END
FROM (
    SELECT A.intInventoryReceiptId
        ,storage_ir = B.intInventoryReceiptId
        ,A.strReceiptNumber
        ,A.dblOpenReceive
        ,B.dblUnits
        ,DIFF = ISNULL(A.dblOpenReceive,0) - ISNULL(B.dblUnits,0)
    FROM #tmpIR A
    FULL JOIN #tmpCS B
        ON B.intInventoryReceiptId = A.intInventoryReceiptId
) AA
WHERE DIFF <> 0
) A
WHERE NOTES <> 'Rounding off issue'

SET @resultAsHTML += 
	'<h3>Check IR with No Storage</h3>' +
	'<table border="1">' + 
	N'<tr>
		<th align=''right''>intInventoryReceiptId</th>
		<th align=''right''>storage_ir</th>
		<th>strReceiptNumber</th>
		<th align=''right''>dblOpenReceive</th>
		<th align=''right''>dblUnits</th>
		<th align=''right''>DIFF</th>
		<th>NOTES</th>
	</tr>' 

BEGIN
	DECLARE c CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT intInventoryReceiptId
		,storage_ir
		,strReceiptNumber
		,dblOpenReceive
		,dblUnits
		,DIFF
		,NOTES
	FROM @tbl10

	OPEN c
	FETCH NEXT FROM c INTO 
		@intInventoryReceiptId
		,@storage_ir
		,@strReceiptNumber
		,@dblOpenReceive
		,@dblUnits
		,@DIFF
		,@NOTES

	WHILE @@FETCH_STATUS = 0
	BEGIN 
		SET @resultAsHTML += 
			N'<tr>' + 
			N'<td align=''right''>'+ ISNULL(dbo.fnICFormatNumber(@intInventoryReceiptId),'') +'</td>' +
			N'<td align=''right''>'+ ISNULL(dbo.fnICFormatNumber(@storage_ir),'') +'</td>' +
			N'<td>'+ ISNULL(@strReceiptNumber,'') +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@dblOpenReceive,0)) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@dblUnits,0)) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@DIFF,0)) +'</td>' +
			N'<td>'+ ISNULL(@NOTES,'') +'</td>' +
			N'</tr>'

		FETCH NEXT FROM c INTO 
			@intInventoryReceiptId
			,@storage_ir
			,@strReceiptNumber
			,@dblOpenReceive
			,@dblUnits
			,@DIFF
			,@NOTES
	END

	CLOSE c; DEALLOCATE c;

	SET @resultAsHTML += N'</table>'; 
END

/*---END: 8. CHECK IR WITH NO STORAGE---'*/

/*---START: 9. SETTLEMENT vs HISTORY vs SUMMARY LOG vs INVENTORY---'*/

DECLARE @ComIds AS Id

INSERT INTO @ComIds
SELECT DISTINCT intCommodityId FROM tblGRCustomerStorage

DECLARE @tbl11 AS TABLE (
	strCommodityCode NVARCHAR(40)
	,strStorageTicket NVARCHAR(40)
	,strStorageTypeDescription NVARCHAR(50)
	,Settled_Units DECIMAL(18,6)
	,Storage_History_Units DECIMAL(18,6)
	,Company_owned_summary_total DECIMAL(18,6)
	,Customer_owned_or_DP_reduce DECIMAL(18,6)
	,Valuation_Qty DECIMAL(18,6)
	,Stock_details_Qty DECIMAL(18,6)
	,ysnDPOwnedType BIT
)

SET @strCommodityCode = NULL
DECLARE @strStorageTicket NVARCHAR(40)
DECLARE @strStorageTypeDescription NVARCHAR(50)
DECLARE @Settled_Units DECIMAL(18,6)
DECLARE @Storage_History_Units DECIMAL(18,6)
DECLARE @Company_owned_summary_total DECIMAL(18,6)
DECLARE @Customer_owned_or_DP_reduce DECIMAL(18,6)
DECLARE @Valuation_Qty DECIMAL(18,6)
DECLARE @Stock_details_Qty DECIMAL(18,6)
SET @ysnDPOwnedType = 0

WHILE EXISTS(SELECT 1 FROM @ComIds)
BEGIN
	SET @intCommodityId = NULL
	SET @strCommodityCode = NULL

	SELECT TOP 1 @intCommodityId = intId FROM @ComIds

	SELECT @strCommodityCode = strCommodityCode FROM tblICCommodity WHERE intCommodityId = @intCommodityId

	--SETTLEMENTS
	INSERT INTO @tbl11
	SELECT @strCommodityCode,* FROM (
	SELECT SS.strStorageTicket
		,ST.strStorageTypeDescription
		,Settled_Units = CASE WHEN ISNULL(SS.dblSpotUnits,0) <> 0 THEN SS.dblSpotUnits ELSE CT.Contract_settlements END
		,Storage_History_Units = SH.dblUnits
		,Company_owned_summary_total = RK_company.SummaryTotal
		,Customer_owned_or_DP_reduce = RK_customer.SummaryTotal
		,VALUATION.Valuation_Qty
		,STOCK_DETAILS.Stock_details_Qty
		,ST.ysnDPOwnedType
	FROM tblGRSettleStorage SS
	LEFT JOIN (
		SELECT intSettleStorageId
			,Contract_settlements = SUM(dblUnits)
		FROM tblGRSettleContract
		GROUP BY intSettleStorageId
	) CT
		ON CT.intSettleStorageId = SS.intSettleStorageId
	INNER JOIN tblGRSettleStorageTicket SST
		ON SST.intSettleStorageId = SS.intSettleStorageId
	INNER JOIN tblGRCustomerStorage CS
		ON CS.intCustomerStorageId = SST.intCustomerStorageId
	INNER JOIN tblGRStorageType ST
		ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
	OUTER APPLY (
		SELECT dblUnits = SUM(dblUnits)
		FROM tblGRStorageHistory
		WHERE intSettleStorageId = SS.intSettleStorageId
	) SH
	OUTER APPLY (
		SELECT strDistributionType
			,strBucketType
			,SummaryTotal = SUM(dblOrigQty)
		FROM tblRKSummaryLog
		WHERE strTransactionNumber = SS.strStorageTicket
			AND intTransactionRecordId = SS.intSettleStorageId
			AND strBucketType IN ('Customer Owned', 'Delayed Pricing')
		GROUP BY strDistributionType
			,strBucketType
	) RK_customer
	OUTER APPLY (
		SELECT strDistributionType
			,strBucketType
			,SummaryTotal = SUM(dblOrigQty)
		FROM tblRKSummaryLog
		WHERE strTransactionNumber = SS.strStorageTicket
			AND intTransactionRecordId = SS.intSettleStorageId
			AND strBucketType = 'Company Owned'
		GROUP BY strDistributionType
			,strBucketType
	) RK_company
	OUTER APPLY (
		SELECT Valuation_Qty = ISNULL(SUM(ISNULL(dblQty,0)),0)
		FROM tblICInventoryTransaction
		WHERE strTransactionId = SS.strStorageTicket
			AND intTransactionId = SS.intSettleStorageId
			AND intTransactionTypeId = 44
	) VALUATION
	OUTER APPLY (
		SELECT Stock_details_Qty = ISNULL(SUM(ISNULL(dblQty,0)),0)
		FROM tblICInventoryTransactionStorage
		WHERE strTransactionId = SS.strStorageTicket
			AND intTransactionId = SS.intSettleStorageId
			AND intTransactionTypeId = 44
	) STOCK_DETAILS
	WHERE SS.strStorageTicket LIKE '%/%'
		--AND ISNULL(SS.dblSpotUnits,0) <> 0
		AND CS.intCommodityId = @intCommodityId
	) A
	WHERE (Settled_Units <> Storage_History_Units AND Settled_Units > 0) --handle the newly created settlements to reverse the settlements under closed periods
	  OR (
			CASE
				WHEN ysnDPOwnedType = 0 --Customer-owned storage
					THEN CASE
						WHEN Settled_Units <> ISNULL(Company_owned_summary_total,0) THEN 1
						WHEN Settled_Units <> (ISNULL(Customer_owned_or_DP_reduce,0) * -1) THEN 1
						WHEN Settled_Units <> (ISNULL(Stock_details_Qty,0) * -1) THEN 1
						WHEN Settled_Units <> ISNULL(Valuation_Qty,0) THEN 1
						ELSE 0
					END
				ELSE --ST.ysnDPOwnedType = 1 (DP)
					CASE
						WHEN ISNULL(Company_owned_summary_total,0) <> 0 THEN 1
						WHEN Settled_Units <> (ISNULL(Customer_owned_or_DP_reduce,0) * -1) THEN 1
						WHEN Valuation_Qty <> 0 THEN 1
						ELSE 0
					END
			END
		) = 1

	DELETE FROM @ComIds WHERE intId = @intCommodityId
END

SET @resultAsHTML += 
	'<h3>Settlement vs History vs Summary Log vs Inventory</h3>' +
	'<table border="1">' + 
	N'<tr>
		<th>Commodity</th>
		<th>Storage Ticket</th>
		<th>Storage Type</th>
		<th align=''right''>Settled_Units</th>
		<th align=''right''>Storage_History_Units</th>
		<th align=''right''>Company_owned_summary_total</th>
		<th align=''right''>Customer_owned_or_DP_reduce</th>
		<th align=''right''>Valuation_Qty</th>
		<th align=''right''>Stock_details_Qty</th>
		<th align=''right''>ysnDPOwnedType</th>
	</tr>' 

BEGIN
	DECLARE c CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT strCommodityCode
		,strStorageTicket
		,strStorageTypeDescription
		,Settled_Units
		,Storage_History_Units
		,Company_owned_summary_total
		,Customer_owned_or_DP_reduce
		,Valuation_Qty
		,Stock_details_Qty
		,ysnDPOwnedType
	FROM @tbl11

	OPEN c
	FETCH NEXT FROM c INTO 
		@strCommodityCode
		,@strStorageTicket
		,@strStorageTypeDescription
		,@Settled_Units
		,@Storage_History_Units
		,@Company_owned_summary_total
		,@Customer_owned_or_DP_reduce
		,@Valuation_Qty
		,@Stock_details_Qty
		,@ysnDPOwnedType

	WHILE @@FETCH_STATUS = 0
	BEGIN 
		SET @resultAsHTML += 
			N'<tr>' + 
			N'<td>'+ ISNULL(@strCommodityCode,'') +'</td>' + 
			N'<td>'+ ISNULL(@strStorageTicket,'') +'</td>' + 
			N'<td>'+ ISNULL(@strStorageTypeDescription,'') +'</td>' + 
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@Settled_Units,0)) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@Storage_History_Units,0)) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@Company_owned_summary_total,0)) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@Customer_owned_or_DP_reduce,0)) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@Valuation_Qty,0)) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@Stock_details_Qty,0)) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@ysnDPOwnedType,0)) +'</td>' +
			N'</tr>'

		FETCH NEXT FROM c INTO 
			@strCommodityCode
			,@strStorageTicket
			,@strStorageTypeDescription
			,@Settled_Units
			,@Storage_History_Units
			,@Company_owned_summary_total
			,@Customer_owned_or_DP_reduce
			,@Valuation_Qty
			,@Stock_details_Qty
			,@ysnDPOwnedType
	END

	CLOSE c; DEALLOCATE c;

	SET @resultAsHTML += N'</table>'; 
END

/*---END: 9. SETTLEMENT vs HISTORY vs SUMMARY LOG vs INVENTORY---'*/

/*---START: 10. CONTRACT USED IN SETTLEMENTS AND DP CONTRACTS REDUCED---'*/
DECLARE @tbl12 AS TABLE (
	strStorageTicket NVARCHAR(50)
	,intSettleStorageId INT
    ,strContractNumber NVARCHAR(50)
    ,SettleContractUnits DECIMAL(18,6)
    ,ContractSequenceUnits DECIMAL(18,6)
    ,Header_PricingType NVARCHAR(50)
    ,Detail_PricingType NVARCHAR(50)
)

SET @strStorageTicket = NULL
DECLARE @intSettleStorageId INT
DECLARE @strContractNumber NVARCHAR(50)
DECLARE @SettleContractUnits DECIMAL(18,6)
DECLARE @ContractSequenceUnits DECIMAL(18,6)
DECLARE @Header_PricingType NVARCHAR(50)
DECLARE @Detail_PricingType NVARCHAR(50)

--settled storages against contract
INSERT INTO @tbl12
SELECT SS.strStorageTicket
    ,_CONTRACT.*
FROM tblGRSettleStorage SS
INNER JOIN (
    SELECT SC.intSettleStorageId
        ,CH.strContractNumber
        ,SettleContractUnits = SC.dblUnits
        ,ContractSequenceUnits = SUH.dblTransactionQuantity
        ,Header_PricingType = PT_CH.strPricingType
        ,Detail_PricingType = PT_CD.strPricingType
    FROM tblGRSettleContract SC    
    INNER JOIN tblCTContractDetail CD
        ON CD.intContractDetailId = SC.intContractDetailId
    INNER JOIN tblCTContractHeader CH
        ON CH.intContractHeaderId = CD.intContractHeaderId
    INNER JOIN tblCTPricingType PT_CH
        ON PT_CH.intPricingTypeId = CH.intPricingTypeId
    INNER JOIN tblCTPricingType PT_CD
        ON PT_CD.intPricingTypeId = CD.intPricingTypeId
    INNER JOIN tblCTSequenceUsageHistory SUH
        ON SUH.intExternalHeaderId = SC.intSettleStorageId
            AND SUH.strScreenName = 'Settle Storage'
            AND SUH.strFieldName = 'Balance'
            AND SUH.intContractHeaderId = CH.intContractHeaderId
            AND SUH.intContractSeq = CD.intContractSeq
) _CONTRACT
    ON _CONTRACT.intSettleStorageId = SS.intSettleStorageId
WHERE SettleContractUnits <> (ContractSequenceUnits * -1)

SET @resultAsHTML += 
	'<h3>Contract used in Settlements and DP contracts reduced</h3>' +
	'<h4>Settled Storages against Contracts</h4>' +
	'<table border="1">' + 
	N'<tr>
		<th>Storage Ticket</th>		
		<th align=''right''>intSettleStorageId</th>
		<th>Contract #</th>
		<th align=''right''>SettleContractUnits</th>
		<th align=''right''>ContractSequenceUnits</th>
		<th>Header_PricingType</th>
		<th>Detail_PricingType</th>
	</tr>' 

BEGIN
	DECLARE c CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT strStorageTicket
		,intSettleStorageId
		,strContractNumber
		,SettleContractUnits
		,ContractSequenceUnits
		,Header_PricingType
		,Detail_PricingType
	FROM @tbl12

	OPEN c
	FETCH NEXT FROM c INTO 
		@strStorageTicket
		,@intSettleStorageId
		,@strContractNumber
		,@SettleContractUnits
		,@ContractSequenceUnits
		,@Header_PricingType
		,@Detail_PricingType

	WHILE @@FETCH_STATUS = 0
	BEGIN 
		SET @resultAsHTML += 
			N'<tr>' + 
			N'<td>'+ ISNULL(@strStorageTicket,'') +'</td>' + 
			N'<td align=''right''>'+ ISNULL(dbo.fnICFormatNumber(@intSettleStorageId),'') +'</td>' +
			N'<td>'+ ISNULL(@strContractNumber,0) +'</td>' + 
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@SettleContractUnits,0)) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@ContractSequenceUnits,0)) +'</td>' +
			N'<td>'+ ISNULL(@Header_PricingType,'') +'</td>' + 
			N'<td>'+ ISNULL(@Detail_PricingType,'') +'</td>' +
			N'</tr>'

		FETCH NEXT FROM c INTO 
			@strStorageTicket
			,@intSettleStorageId
			,@strContractNumber
			,@SettleContractUnits
			,@ContractSequenceUnits
			,@Header_PricingType
			,@Detail_PricingType
	END

	CLOSE c; DEALLOCATE c;

	SET @resultAsHTML += N'</table>'; 
END

DECLARE @tbl13 AS TABLE (
	strStorageTicket NVARCHAR(50)
    ,strContractNumber NVARCHAR(50)
    ,SettledUnits DECIMAL(18,6)
    ,dblTransactionQuantity DECIMAL(18,6)
)

SET @strStorageTicket = NULL
SET @strContractNumber = NULL
DECLARE @SettledUnits DECIMAL(18,6)
DECLARE @dblTransactionQuantity DECIMAL(18,6)
 
--DP contracts of settled dp storages
INSERT INTO @tbl13
SELECT SS.strStorageTicket
    ,CH.strContractNumber
    ,SettledUnits = SST.dblUnits
    ,SUH.dblTransactionQuantity--CASE WHEN SS.dblSpotUnits <> 0 THEN SS.dblSpotUnits ELSE SC.dblUnits END
FROM tblGRSettleStorage SS
LEFT JOIN tblGRSettleContract SC
    ON SC.intSettleStorageId = SS.intSettleStorageId
INNER JOIN tblGRSettleStorageTicket SST
    ON SST.intSettleStorageId = SS.intSettleStorageId
INNER JOIN tblGRCustomerStorage CS
    ON CS.intCustomerStorageId = SST.intCustomerStorageId
INNER JOIN tblGRStorageType ST
    ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
        AND ST.ysnDPOwnedType = 1
INNER JOIN tblGRStorageHistory SH
    ON SH.intCustomerStorageId = CS.intCustomerStorageId
        AND (
                SH.intTransactionTypeId = 1
                OR (SH.intTransactionTypeId = 3 AND strType = 'From Transfer')
            )
INNER JOIN tblCTContractHeader CH
        ON CH.intContractHeaderId = SH.intContractHeaderId
INNER JOIN tblCTSequenceUsageHistory SUH
    ON SUH.intExternalHeaderId = SS.intSettleStorageId
        AND SUH.strScreenName = 'Settle Storage'
        AND SUH.strFieldName = 'Balance'
        AND SUH.intContractHeaderId = CH.intContractHeaderId
WHERE SST.dblUnits <> (SUH.dblTransactionQuantity * -1)

SET @resultAsHTML += 
	'<h4>DP contracts of settled dp storages</h4>' +
	'<table border="1">' + 
	N'<tr>
		<th>Storage Ticket</th>		
		<th>Contract #</th>
		<th align=''right''>SettledUnits</th>
		<th align=''right''>dblTransactionQuantity</th>
	</tr>' 

BEGIN
	DECLARE c CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT strStorageTicket
		,strContractNumber
		,SettledUnits
		,dblTransactionQuantity
	FROM @tbl13

	OPEN c
	FETCH NEXT FROM c INTO 
		@strStorageTicket
		,@strContractNumber
		,@SettledUnits
		,@dblTransactionQuantity

	WHILE @@FETCH_STATUS = 0
	BEGIN 
		SET @resultAsHTML += 
			N'<tr>' + 
			N'<td>'+ ISNULL(@strStorageTicket,'') +'</td>' + 
			N'<td>'+ ISNULL(@strContractNumber,'') +'</td>' + 
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@SettledUnits,0)) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@dblTransactionQuantity,0)) +'</td>' +
			N'</tr>'

		FETCH NEXT FROM c INTO 
			@strStorageTicket
			,@strContractNumber
			,@SettledUnits
			,@dblTransactionQuantity
	END

	CLOSE c; DEALLOCATE c;

	SET @resultAsHTML += N'</table>'; 
END
/*---END: 10. CONTRACT USED IN SETTLEMENTS AND DP CONTRACTS REDUCED---'*/

/*---START: 11. TRANSFER STORAGES---'*/
SET @resultAsHTML += '<h3>Transfer Storages</h3>'

DECLARE @tbl14 AS TABLE (
	strTransferStorageTicket NVARCHAR(40)
    ,TotalTransfer DECIMAL(18,6)
    ,SummaryLogUnits DECIMAL(18,6)
    ,StockDetailsUnits DECIMAL(18,6)
    ,ValuationUnits DECIMAL(18,6)
	,AdjustmentNo NVARCHAR(50)
	,NOTES NVARCHAR(100)
)

SET @strTransferStorageTicket = NULL
DECLARE @TotalTransfer DECIMAL(18,6)
DECLARE @SummaryLogUnits DECIMAL(18,6)
DECLARE @StockDetailsUnits DECIMAL(18,6)
DECLARE @ValuationUnits DECIMAL(18,6)
DECLARE @AdjustmentNo NVARCHAR(50)
SET @NOTES = NULL

--Customer owned to company owned
INSERT INTO @tbl14
SELECT *
    ,NOTES = CASE
                WHEN ADJ.strAdjustmentNo IS NOT NULL THEN 'Adjustment has been created.'
                ELSE ''
            END
FROM (
    SELECT TS.strTransferStorageTicket
        ,TotalTransfer = SUM(TSR.dblUnitQty)
        ,SUMMARY_LOG.SummaryLogUnits
        ,StockDetailsUnits = ISNULL(STOCK_DETAILS.StockDetailsUnits,0)
        ,ValuationUnits = ISNULL(VALUATION.ValuationUnits,0)
    FROM tblGRTransferStorage TS
    INNER JOIN tblGRTransferStorageReference TSR
        ON TSR.intTransferStorageId = TS.intTransferStorageId
    INNER JOIN tblGRCustomerStorage CS_FROM
        ON CS_FROM.intCustomerStorageId = TSR.intSourceCustomerStorageId
    INNER JOIN tblGRStorageType ST_FROM
        ON ST_FROM.intStorageScheduleTypeId = CS_FROM.intStorageTypeId
            AND ST_FROM.ysnDPOwnedType = 0
    INNER JOIN tblGRCustomerStorage CS_TO
        ON CS_TO.intCustomerStorageId = TSR.intToCustomerStorageId
    INNER JOIN tblGRStorageType ST_TO
        ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId
            AND ST_TO.ysnDPOwnedType = 1
    OUTER APPLY (
        SELECT SummaryLogUnits = SUM(dblOrigQty)
        FROM tblRKSummaryLog
        WHERE strTransactionNumber = TS.strTransferStorageTicket
    ) SUMMARY_LOG
    OUTER APPLY (
        SELECT StockDetailsUnits = SUM(dblQty)
        FROM tblICInventoryTransactionStorage
        WHERE strTransactionId = TS.strTransferStorageTicket
            AND intTransactionTypeId = 56 --Transfer Storage
    ) STOCK_DETAILS
    OUTER APPLY (
        SELECT ValuationUnits = SUM(dblQty)
        FROM tblICInventoryTransaction
        WHERE strTransactionId = TS.strTransferStorageTicket
            AND intTransactionTypeId = 56 --Transfer Storage
    ) VALUATION
    GROUP BY TS.strTransferStorageTicket
        ,SUMMARY_LOG.SummaryLogUnits
        ,STOCK_DETAILS.StockDetailsUnits
        ,VALUATION.ValuationUnits
) A
OUTER APPLY (
    SELECT strAdjustmentNo FROM tblICInventoryAdjustment WHERE strDescription LIKE '%' + strTransferStorageTicket + '%'
) ADJ
WHERE TotalTransfer <> SummaryLogUnits
    OR TotalTransfer <> (StockDetailsUnits * -1)
    OR TotalTransfer <> ValuationUnits

SET @resultAsHTML += 
	'<h4>Customer Owned to Company Owned</h4>' +
	'<table border="1">' + 
	N'<tr>
		<th>Transfer Storage Ticket</th>
		<th align=''right''>Total Transfer</th>
		<th align=''right''>Summary Log Units</th>
		<th align=''right''>Stock Details Units</th>
		<th align=''right''>Valuation Units</th>
		<th>Adjustment No.</th>
		<th>NOTES</th>
	</tr>' 

BEGIN
	DECLARE c CURSOR LOCAL FAST_FORWARD
	FOR 
	SELECT strTransferStorageTicket
		,TotalTransfer
		,SummaryLogUnits
		,StockDetailsUnits
		,ValuationUnits
		,AdjustmentNo
		,NOTES
	FROM @tbl14

	OPEN c
	FETCH NEXT FROM c INTO 
		@strTransferStorageTicket
		,@TotalTransfer
		,@SummaryLogUnits
		,@StockDetailsUnits
		,@ValuationUnits
		,@AdjustmentNo
		,@NOTES

	WHILE @@FETCH_STATUS = 0
	BEGIN 
		SET @resultAsHTML += 
			N'<tr>' + 
			N'<td>'+ ISNULL(@strTransferStorageTicket,'') +'</td>' + 
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@TotalTransfer,0)) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@SummaryLogUnits,0)) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@StockDetailsUnits,0)) +'</td>' +
			N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@ValuationUnits,0)) +'</td>' +
			N'<td>'+ ISNULL(@AdjustmentNo,'') +'</td>' + 
			N'<td>'+ ISNULL(@NOTES,'') +'</td>' + 
			N'</tr>'

		FETCH NEXT FROM c INTO 
			@strTransferStorageTicket
			,@TotalTransfer
			,@SummaryLogUnits
			,@StockDetailsUnits
			,@ValuationUnits
			,@AdjustmentNo
			,@NOTES
	END

	CLOSE c; DEALLOCATE c;

	SET @resultAsHTML += N'</table>'; 
END

DELETE FROM @tbl14
SET @strTransferStorageTicket = NULL
SET @TotalTransfer = 0
SET @SummaryLogUnits = 0
SET @StockDetailsUnits = 0
SET @ValuationUnits = 0
SET @AdjustmentNo = NULL
SET @NOTES = NULL

--Company owned to customer owned
INSERT INTO @tbl14
SELECT * FROM (
SELECT *
    ,NOTES = CASE
                WHEN ADJ.strAdjustmentNo IS NOT NULL THEN 'Adjustment has been created. See ' + strAdjustmentNo + ' for details.'
                WHEN (ABS(TotalTransfer) - ABS(SummaryLogUnits)) < 0.1
                    OR (ABS(TotalTransfer) - ABS(StockDetailsUnits)) < 0.1
                    OR (ABS(TotalTransfer) - ABS(ValuationUnits)) < 0.1
                    THEN 'Decimal discrepancy'
                ELSE ''
            END
FROM (
    SELECT TS.strTransferStorageTicket
        ,TotalTransfer = SUM(TSR.dblUnitQty)
        ,SUMMARY_LOG.SummaryLogUnits
        ,StockDetailsUnits = ISNULL(STOCK_DETAILS.StockDetailsUnits,0)
        ,ValuationUnits = ISNULL(VALUATION.ValuationUnits,0)
    FROM tblGRTransferStorage TS
    INNER JOIN tblGRTransferStorageReference TSR
        ON TSR.intTransferStorageId = TS.intTransferStorageId
    INNER JOIN tblGRCustomerStorage CS_FROM
        ON CS_FROM.intCustomerStorageId = TSR.intSourceCustomerStorageId
    INNER JOIN tblGRStorageType ST_FROM
        ON ST_FROM.intStorageScheduleTypeId = CS_FROM.intStorageTypeId
            AND ST_FROM.ysnDPOwnedType = 1
    INNER JOIN tblGRCustomerStorage CS_TO
        ON CS_TO.intCustomerStorageId = TSR.intToCustomerStorageId
    INNER JOIN tblGRStorageType ST_TO
        ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId
            AND ST_TO.ysnDPOwnedType = 0
    OUTER APPLY (
        SELECT SummaryLogUnits = SUM(dblOrigQty) * -1
        FROM tblRKSummaryLog
        WHERE strTransactionNumber = TS.strTransferStorageTicket
    ) SUMMARY_LOG
    OUTER APPLY (
        SELECT StockDetailsUnits = SUM(dblQty)
        FROM tblICInventoryTransactionStorage
        WHERE strTransactionId = TS.strTransferStorageTicket
            AND intTransactionTypeId = 56 --Transfer Storage
    ) STOCK_DETAILS
    OUTER APPLY (
        SELECT ValuationUnits = SUM(dblQty)
        FROM tblICInventoryTransaction
        WHERE strTransactionId = TS.strTransferStorageTicket
            AND intTransactionTypeId = 56 --Transfer Storage
    ) VALUATION
    GROUP BY TS.strTransferStorageTicket
        ,SUMMARY_LOG.SummaryLogUnits
        ,STOCK_DETAILS.StockDetailsUnits
        ,VALUATION.ValuationUnits
) A
OUTER APPLY (
    SELECT strAdjustmentNo FROM tblICInventoryAdjustment WHERE strDescription LIKE '%' + strTransferStorageTicket + '%'
) ADJ
WHERE TotalTransfer <> SummaryLogUnits
    OR TotalTransfer <> StockDetailsUnits
    OR TotalTransfer <> (ValuationUnits * -1)
) AA
WHERE NOTES = ''

SET @resultAsHTML += 
	'<h4>Company Owned to Customer Owned</h4>' +
	'<table border="1">' + 
	N'<tr>
		<th>Transfer Storage Ticket</th>
		<th align=''right''>Total Transfer</th>
		<th align=''right''>Summary Log Units</th>
		<th align=''right''>Stock Details Units</th>
		<th align=''right''>Valuation Units</th>
		<th>Adjustment No.</th>
		<th>NOTES</th>
	</tr>' 

--IF @emailProfileName IS NOT NULL AND @emailRecipient IS NOT NULL 
BEGIN	
	BEGIN
		DECLARE c CURSOR LOCAL FAST_FORWARD
		FOR 
		SELECT strTransferStorageTicket
			,TotalTransfer
			,SummaryLogUnits
			,StockDetailsUnits
			,ValuationUnits
			,AdjustmentNo
			,NOTES
		FROM @tbl14

		OPEN c
		FETCH NEXT FROM c INTO 
			@strTransferStorageTicket
			,@TotalTransfer
			,@SummaryLogUnits
			,@StockDetailsUnits
			,@ValuationUnits
			,@AdjustmentNo
			,@NOTES

		WHILE @@FETCH_STATUS = 0
		BEGIN 
			SET @resultAsHTML += 
				N'<tr>' + 
				N'<td>'+ ISNULL(@strTransferStorageTicket,'') +'</td>' + 
				N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@TotalTransfer,0)) +'</td>' +
				N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@SummaryLogUnits,0)) +'</td>' +
				N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@StockDetailsUnits,0)) +'</td>' +
				N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@ValuationUnits,0)) +'</td>' +
				N'<td>'+ ISNULL(@AdjustmentNo,'') +'</td>' + 
				N'<td>'+ ISNULL(@NOTES,'') +'</td>' + 
				N'</tr>'

			FETCH NEXT FROM c INTO 
				@strTransferStorageTicket
				,@TotalTransfer
				,@SummaryLogUnits
				,@StockDetailsUnits
				,@ValuationUnits
				,@AdjustmentNo
				,@NOTES
		END

		CLOSE c; DEALLOCATE c;

		SET @resultAsHTML += N'</table>'; 
	END	
END
 
--Customer owned to customer owned
--Company owned to company owned
DECLARE @tbl15 AS TABLE (
	strTransferStorageTicket NVARCHAR(40)
    ,TotalTransfer DECIMAL(18,6)
    ,SUMMARY_LOG_FROM DECIMAL(18,6)
	,SUMMARY_LOG_TO DECIMAL(18,6)
    ,StorageType_From DECIMAL(18,6)
    ,StorageType_To DECIMAL(18,6)
	,AdjustmentNo NVARCHAR(50)
	,NOTES NVARCHAR(100)
)

SET @strTransferStorageTicket = NULL
SET @TotalTransfer = 0
DECLARE @SUMMARY_LOG_FROM DECIMAL(18,6)
DECLARE @SUMMARY_LOG_TO DECIMAL(18,6)
DECLARE @StorageType_From DECIMAL(18,6)
DECLARE @StorageType_To DECIMAL(18,6)
SET @AdjustmentNo = NULL
SET @NOTES = NULL

INSERT INTO @tbl15
SELECT * FROM (
SELECT *
    ,NOTES = CASE
                WHEN ADJ.strAdjustmentNo IS NOT NULL THEN 'Adjustment has been created. See ' + strAdjustmentNo + ' for details.'
                WHEN (ABS(TotalTransfer) - ABS(SummaryLogUnitsFrom)) < 0.1
                    OR (ABS(TotalTransfer) - ABS(SummaryLogUnitsTo)) < 0.1
                    THEN 'Decimal discrepancy'
                ELSE ''
            END
FROM (
    SELECT TS.strTransferStorageTicket
        ,TotalTransfer = SUM(TSR.dblUnitQty)
        ,SUMMARY_LOG_FROM.SummaryLogUnitsFrom
        ,SUMMARY_LOG_TO.SummaryLogUnitsTo
        ,StorageType_From = ST_FROM.strStorageTypeDescription
        ,StorageType_To = ST_TO.strStorageTypeDescription
    FROM tblGRTransferStorage TS
    INNER JOIN tblGRTransferStorageReference TSR
        ON TSR.intTransferStorageId = TS.intTransferStorageId
    INNER JOIN tblGRCustomerStorage CS_FROM
        ON CS_FROM.intCustomerStorageId = TSR.intSourceCustomerStorageId
    INNER JOIN tblGRStorageType ST_FROM
        ON ST_FROM.intStorageScheduleTypeId = CS_FROM.intStorageTypeId
    INNER JOIN tblGRCustomerStorage CS_TO
        ON CS_TO.intCustomerStorageId = TSR.intToCustomerStorageId
    INNER JOIN tblGRStorageType ST_TO
        ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId
    OUTER APPLY (
        SELECT SummaryLogUnitsFrom = SUM(dblOrigQty)
        FROM tblRKSummaryLog
        WHERE strTransactionNumber = TS.strTransferStorageTicket
            AND strInOut = 'OUT'
            AND strBucketType IN ('Customer Owned', 'Company Owned')
    ) SUMMARY_LOG_FROM
    OUTER APPLY (
        SELECT SummaryLogUnitsTo = SUM(dblOrigQty)
        FROM tblRKSummaryLog
        WHERE strTransactionNumber = TS.strTransferStorageTicket
            AND strInOut = 'IN'
            AND strBucketType IN ('Customer Owned', 'Company Owned')
    ) SUMMARY_LOG_TO
    WHERE (ST_FROM.ysnDPOwnedType = 1 AND ST_TO.ysnDPOwnedType = 1)
        OR (ST_FROM.ysnDPOwnedType = 0 AND ST_TO.ysnDPOwnedType = 0)
    GROUP BY TS.strTransferStorageTicket
        ,SUMMARY_LOG_FROM.SummaryLogUnitsFrom
        ,SUMMARY_LOG_TO.SummaryLogUnitsTo
        ,ST_FROM.strStorageTypeDescription
        ,ST_TO.strStorageTypeDescription
) A
OUTER APPLY (
    SELECT strAdjustmentNo FROM tblICInventoryAdjustment WHERE strDescription LIKE '%' + strTransferStorageTicket + '%'
) ADJ
WHERE TotalTransfer <> (SummaryLogUnitsFrom * -1)
    OR TotalTransfer <> SummaryLogUnitsTo
) AA
WHERE NOTES = ''

SET @resultAsHTML += 
	'<h4>Transfer to Same Ownership Type</h4>' +
	'<table border="1">' + 
	N'<tr>
		<th>Transfer Storage Ticket</th>
		<th align=''right''>Total Transfer</th>
		<th align=''right''>SUMMARY_LOG_FROM</th>
		<th align=''right''>SUMMARY_LOG_TO</th>
		<th align=''right''>StorageType_From</th>
		<th align=''right''>StorageType_To</th>
		<th>Adjustment No.</th>
		<th>NOTES</th>
	</tr>' 

--IF @emailProfileName IS NOT NULL AND @emailRecipient IS NOT NULL 
BEGIN	
	BEGIN
		DECLARE c CURSOR LOCAL FAST_FORWARD
		FOR 
		SELECT strTransferStorageTicket
			,TotalTransfer
			,SUMMARY_LOG_FROM
			,SUMMARY_LOG_TO
			,StorageType_From
			,StorageType_To
			,AdjustmentNo
			,NOTES
		FROM @tbl15

		OPEN c
		FETCH NEXT FROM c INTO 
			@strTransferStorageTicket
			,@TotalTransfer
			,@SUMMARY_LOG_FROM 
			,@SUMMARY_LOG_TO
			,@StorageType_From
			,@StorageType_To
			,@AdjustmentNo
			,@NOTES

		WHILE @@FETCH_STATUS = 0
		BEGIN 
			SET @resultAsHTML += 
				N'<tr>' + 
				N'<td>'+ ISNULL(@strTransferStorageTicket,'') +'</td>' + 
				N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@TotalTransfer,0)) +'</td>' +
				N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@SUMMARY_LOG_FROM,0)) +'</td>' +
				N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@SUMMARY_LOG_TO,0)) +'</td>' +
				N'<td>'+ ISNULL(@StorageType_From,'') +'</td>' +
				N'<td>'+ ISNULL(@StorageType_To,'') +'</td>' +
				N'<td>'+ ISNULL(@AdjustmentNo,'') +'</td>' + 
				N'<td>'+ ISNULL(@NOTES,'') +'</td>' + 
				N'</tr>'

			FETCH NEXT FROM c INTO 
				@strTransferStorageTicket
				,@TotalTransfer
				,@SUMMARY_LOG_FROM 
				,@SUMMARY_LOG_TO
				,@StorageType_From
				,@StorageType_To
				,@AdjustmentNo
				,@NOTES
		END

		CLOSE c; DEALLOCATE c;

		SET @resultAsHTML += N'</table>'; 
	END	
END

DECLARE @tbl16 AS TABLE (
	strTransferStorageTicket NVARCHAR(50)
    ,TransferProcess NVARCHAR(50)
    ,TotalTransfer DECIMAL(18,6)
    ,ContractUnitsFrom DECIMAL(18,6)
    ,ContractUnitsTo DECIMAL(18,6)
    ,ContractNo_FROM NVARCHAR(50)
    ,ContractStatus_FROM NVARCHAR(50)
    ,ContractNo_TO NVARCHAR(50)
    ,ContractStatus_TO NVARCHAR(50)
	,NOTES NVARCHAR(50)
)

SET @strTransferStorageTicket = NULL
DECLARE @TransferProcess NVARCHAR(50)
SET @TotalTransfer = 0
DECLARE @ContractUnitsFrom DECIMAL(18,6)
DECLARE @ContractUnitsTo DECIMAL(18,6)
DECLARE @ContractNo_FROM NVARCHAR(50)
DECLARE @ContractStatus_FROM NVARCHAR(50)
DECLARE @ContractNo_TO NVARCHAR(50)
DECLARE @ContractStatus_TO NVARCHAR(50)
SET @NOTES = NULL

--DP contracts
INSERT INTO @tbl16
SELECT *
    ,NOTES = CASE
                WHEN ContractUnitsFrom = 0 AND ContractUnitsTo = 0 THEN 'No contract history'
                WHEN (ContractUnitsFrom <> 0 AND (ABS(TotalTransfer) - ABS(ContractUnitsFrom)) < 0.1 AND ContractUnitsTo = 0)
                    OR (ContractUnitsTo <> 0 AND (ABS(TotalTransfer) - ABS(ContractUnitsTo)) < 0.1 AND ContractUnitsFrom = 0)
                    THEN 'Decimal discrepancy'
    END
FROM (
    SELECT TS.strTransferStorageTicket
        ,TransferProcess = CASE
                                WHEN (ST_FROM.ysnDPOwnedType = 1 AND ST_TO.ysnDPOwnedType = 0) THEN 'DP-OS'
                                WHEN (ST_FROM.ysnDPOwnedType = 0 AND ST_TO.ysnDPOwnedType = 1) THEN 'OS-DP'
                                WHEN (ST_FROM.ysnDPOwnedType = 1 AND ST_TO.ysnDPOwnedType = 1) THEN 'DP-DP'
                        END
        ,TotalTransfer = SUM(TSR.dblUnitQty)
        ,ContractUnitsFrom = ISNULL(DPContract_FROM.ContractUnitsFrom,0)
        ,ContractUnitsTo = ISNULL(DPContract_TO.ContractUnitsTo,0)
        ,ContractNo_FROM = DPContract_FROM.strContractNumber
        ,ContractStatus_FROM = DPContract_FROM.strContractStatus
        ,ContractNo_TO = DPContract_TO.strContractNumber
        ,ContractStatus_TO = DPContract_TO.strContractStatus           
    FROM tblGRTransferStorage TS
    INNER JOIN tblGRTransferStorageReference TSR
        ON TSR.intTransferStorageId = TS.intTransferStorageId
    INNER JOIN tblGRCustomerStorage CS_FROM
        ON CS_FROM.intCustomerStorageId = TSR.intSourceCustomerStorageId
    INNER JOIN tblGRStorageType ST_FROM
        ON ST_FROM.intStorageScheduleTypeId = CS_FROM.intStorageTypeId
    INNER JOIN tblGRCustomerStorage CS_TO
        ON CS_TO.intCustomerStorageId = TSR.intToCustomerStorageId
    INNER JOIN tblGRStorageType ST_TO
        ON ST_TO.intStorageScheduleTypeId = CS_TO.intStorageTypeId
    OUTER APPLY (
        SELECT ContractUnitsFrom = SUM(SUH.dblTransactionQuantity)
            ,CH.strContractNumber
            ,SS.strContractStatus
        FROM tblGRTransferStorageSourceSplit TS_SOURCE
        INNER JOIN tblCTContractDetail CD
            ON CD.intContractDetailId = TS_SOURCE.intContractDetailId
        INNER JOIN tblCTContractHeader CH
            ON CH.intContractHeaderId = CD.intContractHeaderId
        INNER JOIN tblCTContractStatus SS
            ON SS.intContractStatusId = CD.intContractStatusId
        LEFT JOIN tblCTSequenceUsageHistory SUH
            ON SUH.strNumber = TS.strTransferStorageTicket
                AND SUH.strScreenName = 'Transfer Storage'
                AND SUH.strFieldName = 'Balance'
                AND SUH.intContractHeaderId = CH.intContractHeaderId
        WHERE TS_SOURCE.intTransferStorageId = TS.intTransferStorageId
            AND TS_SOURCE.intSourceCustomerStorageId = CS_FROM.intCustomerStorageId
        GROUP BY CH.strContractNumber
            ,SS.strContractStatus
    ) DPContract_FROM
    OUTER APPLY (
        SELECT ContractUnitsTo = SUM(SUH.dblTransactionQuantity)
            ,CH.strContractNumber
            ,SS.strContractStatus
        FROM tblGRTransferStorageSplit TS_SPLIT
        INNER JOIN tblCTContractDetail CD
            ON CD.intContractDetailId = TS_SPLIT.intContractDetailId
        INNER JOIN tblCTContractHeader CH
            ON CH.intContractHeaderId = CD.intContractHeaderId
        INNER JOIN tblCTContractStatus SS
            ON SS.intContractStatusId = CD.intContractStatusId
        LEFT JOIN tblCTSequenceUsageHistory SUH
            ON SUH.strNumber = TS.strTransferStorageTicket
                AND SUH.strScreenName = 'Transfer Storage'
                AND SUH.strFieldName = 'Balance'
                AND SUH.intContractHeaderId = CH.intContractHeaderId
        WHERE TS_SPLIT.intTransferStorageId = TS.intTransferStorageId
        GROUP BY CH.strContractNumber
            ,SS.strContractStatus
    ) DPContract_TO
    WHERE (ST_FROM.ysnDPOwnedType = 1 AND ST_TO.ysnDPOwnedType = 0)
        OR (ST_FROM.ysnDPOwnedType = 0 AND ST_TO.ysnDPOwnedType = 1)
        OR (ST_FROM.ysnDPOwnedType = 1 AND ST_TO.ysnDPOwnedType = 1)
    GROUP BY TS.strTransferStorageTicket
        ,DPContract_FROM.ContractUnitsFrom
        ,DPContract_TO.ContractUnitsTo
        ,DPContract_FROM.strContractNumber
        ,DPContract_TO.strContractNumber
        ,DPContract_FROM.strContractStatus
        ,DPContract_TO.strContractStatus
        ,ST_FROM.ysnDPOwnedType
        ,ST_TO.ysnDPOwnedType
) A
WHERE (
    CASE
        WHEN TransferProcess = 'DP-OS' AND TotalTransfer <> (ContractUnitsFrom * -1) THEN 1
        WHEN TransferProcess = 'OS-DP' AND TotalTransfer <> ContractUnitsTo THEN 1
        WHEN TransferProcess = 'DP-DP' AND (TotalTransfer <> ContractUnitsFrom OR TotalTransfer <> ContractUnitsTo) THEN 1
        ELSE 0
    END
) = 1

SET @resultAsHTML += 
	'<h4>DP Contracts</h4>' +
	'<table border="1">' + 
	N'<tr>
		<th>Transfer Storage Ticket</th>
		<th>Transfer Process</th>
		<th align=''right''>Total Transfer</th>
		<th align=''right''>ContractUnitsFrom</th>
		<th align=''right''>ContractUnitsTo</th>
		<th>ContractNo_FROM</th>
		<th>ContractStatus_FROM</th>
		<th>ContractNo_TO</th>
		<th>ContractStatus_TO</th>
		<th>NOTES</th>
	</tr>' 

--IF @emailProfileName IS NOT NULL AND @emailRecipient IS NOT NULL 
BEGIN	
	BEGIN
		DECLARE c CURSOR LOCAL FAST_FORWARD
		FOR 
		SELECT strTransferStorageTicket
			,TransferProcess
			,TotalTransfer
			,ContractUnitsFrom
			,ContractUnitsTo
			,ContractNo_FROM
			,ContractStatus_FROM
			,ContractNo_TO
			,ContractStatus_TO
			,NOTES
		FROM @tbl16

		OPEN c
		FETCH NEXT FROM c INTO 
			@strTransferStorageTicket
			,@TransferProcess
			,@TotalTransfer
			,@ContractUnitsFrom
			,@ContractUnitsTo
			,@ContractNo_FROM
			,@ContractStatus_FROM
			,@ContractNo_TO
			,@ContractStatus_TO
			,@NOTES

		WHILE @@FETCH_STATUS = 0
		BEGIN 
			SET @resultAsHTML += 
				N'<tr>' + 
				N'<td>'+ ISNULL(@strTransferStorageTicket,'') +'</td>' + 
				N'<td>'+ ISNULL(@TransferProcess,'') +'</td>' + 
				N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@TotalTransfer,0)) +'</td>' +
				N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@ContractUnitsFrom,0)) +'</td>' +
				N'<td align=''right''>'+ dbo.fnICFormatNumber(ISNULL(@ContractUnitsTo,0)) +'</td>' +
				N'<td>'+ ISNULL(@ContractNo_FROM,'') +'</td>' + 
				N'<td>'+ ISNULL(@ContractStatus_FROM,'') +'</td>' + 
				N'<td>'+ ISNULL(@ContractNo_TO,'') +'</td>' + 
				N'<td>'+ ISNULL(@ContractStatus_TO,'') +'</td>' + 
				N'<td>'+ ISNULL(@NOTES,'') +'</td>' + 
				N'</tr>'

			FETCH NEXT FROM c INTO 
				@strTransferStorageTicket
				,@TransferProcess
				,@TotalTransfer
				,@ContractUnitsFrom
				,@ContractUnitsTo
				,@ContractNo_FROM
				,@ContractStatus_FROM
				,@ContractNo_TO
				,@ContractStatus_TO
				,@NOTES
		END

		CLOSE c; DEALLOCATE c;

		SET @resultAsHTML += N'</table>'; 
	END	
END
/*---END: 11. TRANSFER STORAGES---'*/

EXEC msdb.dbo.sp_send_dbmail
	@profile_name = @emailProfileName
	,@recipients = @emailRecipient
	,@subject = 'GRAIN Diagnostic Results'
	,@body = @resultAsHTML
	,@body_format = 'HTML'

PRINT 'Email Sent to Queue.'
--select @resultAsHTML

