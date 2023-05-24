CREATE PROCEDURE [dbo].[uspGRGIICompanyOwnedTotals]
	@xmlParam NVARCHAR(MAX)
AS
BEGIN
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
DECLARE @dtmReportDate DATETIME

DECLARE @CompanyOwnedData AS TABLE (
	intOrderNo INT
	,dtmReportDate DATETIME
	,intCommodityId INT
	,strLabel NVARCHAR(200) COLLATE Latin1_General_CI_AS
	,dblTotalBeginning DECIMAL(18,6) DEFAULT 0
	,dblTotalIncrease DECIMAL(18,6) DEFAULT 0
	,dblTotalDecrease DECIMAL(18,6) DEFAULT 0
	,dblTotalEnding DECIMAL(18,6) DEFAULT 0
	,strUOM NVARCHAR(40) COLLATE Latin1_General_CI_AS
)

--DECLARE @tblCommodities Id

DECLARE @strCommodityCode NVARCHAR(20)
DECLARE @strCommodityDescription NVARCHAR(100)
DECLARE @strUOM NVARCHAR(20)
DECLARE @intCommodityUnitMeasureId AS INT
DECLARE @Locs Id

SELECT @dtmReportDate = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'dtmReportDate'

SELECT @intCommodityId = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'intCommodityId'

SET @dtmReportDate = CASE WHEN @dtmReportDate IS NULL THEN dbo.fnRemoveTimeOnDate(GETDATE()) ELSE @dtmReportDate END
SET @intCommodityId = CASE WHEN @intCommodityId = 0 THEN NULL ELSE @intCommodityId END

INSERT INTO @Locs
SELECT intCompanyLocationId
FROM tblSMCompanyLocation
WHERE ysnLicensed = 1
;
DECLARE @intCompanyLocationId INT
DECLARE @strLocationName NVARCHAR(200)
DECLARE @intCommodityId2 INT
DECLARE @intLocationId INT

--INSERT INTO @tblCommodities
--SELECT DISTINCT intCommodityId FROM tblGRGIIPhysicalInventory

--WHILE EXISTS(SELECT TOP 1 1 FROM @tblCommodities)
BEGIN
	--SET @intCommodityId = NULL

	--SELECT TOP 1 @intCommodityId = intId FROM @tblCommodities

	SELECT @intCommodityUnitMeasureId = intCommodityUnitMeasureId
		,@strUOM = UOM.strUnitMeasure
	FROM tblICCommodityUnitMeasure UM
	INNER JOIN tblICUnitMeasure UOM
		ON UOM.intUnitMeasureId = UM.intUnitMeasureId
	WHERE intCommodityId = @intCommodityId
		AND ysnStockUnit = 1
	
	/*******START******COMPANY OWNERSHIP (UNPAID)*************/
	BEGIN
		SELECT dtmPostDate = dbo.fnRemoveTimeOnDate(AP.dtmDate)
			,IC.intCommodityId
			,dblQty = SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(SS.intCommodityStockUomId,@intCommodityUnitMeasureId,BD.dblQtyReceived))
		INTO #Vouchers
		FROM tblAPBillDetail BD
		INNER JOIN tblAPBill AP
			ON AP.intBillId = BD.intBillId
		INNER JOIN tblICItem IC
			ON IC.intItemId = BD.intItemId
				AND IC.strType = 'Inventory'
		INNER JOIN tblGRSettleStorageBillDetail SBD
			ON SBD.intBillId = BD.intBillId
		INNER JOIN tblGRSettleStorage SS
			ON SS.intSettleStorageId = SBD.intSettleStorageId
		INNER JOIN tblSMCompanyLocation CL
			ON CL.intCompanyLocationId = AP.intShipToId
				AND CL.ysnLicensed = 1
		LEFT JOIN (
			tblAPPaymentDetail PD
			INNER JOIN tblAPPayment PYMT
				ON PYMT.intPaymentId = PD.intPaymentId
		) ON PD.intBillId = AP.intBillId
		WHERE (AP.ysnPosted = 0
				OR ISNULL(PYMT.ysnPosted,0) = 0
				OR ISNULL(PYMT.strPaymentInfo,'') = ''
			)
			AND IC.intCommodityId = @intCommodityId
		GROUP BY AP.dtmDate
			,IC.intCommodityId
			,SS.intCommodityStockUomId

		/****BEGINNING****/
		INSERT INTO @CompanyOwnedData
		SELECT 2
			,@dtmReportDate
			,V.intCommodityId
			,'   COMPANY OWNERSHIP (UNPAID)'
			,SUM(V.dblQty)
			,0
			,0
			,0
			,@strUOM
		FROM #Vouchers V
		INNER JOIN tblICCommodity CO
			ON CO.intCommodityId = V.intCommodityId
		WHERE V.dtmPostDate < @dtmReportDate
		GROUP BY V.intCommodityId

		/******INCREASE*******/
		UPDATE C
		SET dblTotalIncrease = V.total
		FROM @CompanyOwnedData C
		INNER JOIN (
			SELECT intCommodityId
				,total = SUM(dblQty)
			FROM #Vouchers
			WHERE dtmPostDate = @dtmReportDate
			GROUP BY intCommodityId
		) V
			ON C.intCommodityId = V.intCommodityId
		WHERE C.dtmReportDate = @dtmReportDate
			AND C.intOrderNo = 2

		/******DECREASE*******/
		UPDATE C
		SET dblTotalDecrease = A.dblQty
		FROM @CompanyOwnedData C
		INNER JOIN (
			SELECT IC.intCommodityId
				,dblQty = SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(SS.intCommodityStockUomId,@intCommodityUnitMeasureId,BD.dblQtyReceived))
			FROM tblAPBillDetail BD
			INNER JOIN tblAPBill AP
				ON AP.intBillId = BD.intBillId
			INNER JOIN tblICItem IC
				ON IC.intItemId = BD.intItemId
					AND IC.strType = 'Inventory'
			INNER JOIN tblGRSettleStorageBillDetail SBD
				ON SBD.intBillId = BD.intBillId
			INNER JOIN tblGRSettleStorage SS
				ON SS.intSettleStorageId = SBD.intSettleStorageId
			INNER JOIN tblSMCompanyLocation CL
				ON CL.intCompanyLocationId = AP.intShipToId
					AND CL.ysnLicensed = 1
			INNER JOIN (
				tblAPPaymentDetail PD
				INNER JOIN tblAPPayment PYMT
					ON PYMT.intPaymentId = PD.intPaymentId
			) ON PD.intBillId = AP.intBillId
			WHERE ISNULL(PYMT.strPaymentInfo,'') <> ''
				AND IC.intCommodityId = @intCommodityId
				AND dbo.fnRemoveTimeOnDate(PYMT.dtmDatePaid) = @dtmReportDate
			GROUP BY IC.intCommodityId
				,SS.intCommodityStockUomId
		) A ON A.intCommodityId = C.intCommodityId
		WHERE C.intOrderNo = 2
			AND C.dtmReportDate = @dtmReportDate

		--ADD IF DP DOES NOT EXIST FOR THE COMMODITY
		IF NOT EXISTS(SELECT 1 FROM @CompanyOwnedData WHERE intOrderNo = 2)
		BEGIN
			INSERT INTO @CompanyOwnedData
			SELECT 2
				,@dtmReportDate
				,@intCommodityId
				,'   COMPANY OWNERSHIP (UNPAID)'
				,0
				,0
				,0
				,0
				,@strUOM
		END

		DROP TABLE #Vouchers
	END
	/*******END******COMPANY OWNERSHIP (UNPAID)*************/

	/*******START******DELAYED PRICING*************/
	BEGIN
		SELECT
			dtmDate = CONVERT(VARCHAR(10),dtmTransactionDate,110)
			,strTransactionNumber
			,strDistributionType
			,dblIn = CASE WHEN dblTotal > 0 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal) ELSE 0 END
			,dblOut = CASE WHEN dblTotal < 0 THEN ABS(dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal)) ELSE 0 END
			,ST.intStorageScheduleTypeId
			,DP.strStorageTypeCode
			,DP.strCommodityCode
			,DP.strTransactionType
		INTO #DelayedPricingALL
		FROM dbo.fnRKGetBucketDelayedPricing(@dtmReportDate,@intCommodityId,NULL) DP
		INNER JOIN tblSMCompanyLocation CL
			ON CL.intCompanyLocationId = DP.intLocationId
				AND CL.ysnLicensed = 1
		JOIN tblGRStorageType ST 
			ON ST.strStorageTypeDescription = DP.strDistributionType 
				AND ysnDPOwnedType = 1
				AND ysnCustomerStorage = 0
				AND strOwnedPhysicalStock = 'Company'
		WHERE DP.intCommodityId = @intCommodityId			

		SELECT
			intRowNum = ROW_NUMBER() OVER (ORDER BY strDistributionType)
			,dtmDate
			,strDistributionType
			,dblIn = SUM(dblIn)
			,dblOut = SUM(dblOut)
			,dblNet = SUM(dblIn) - SUM(dblOut)
			,intStorageScheduleTypeId
			,strCommodityCode
		INTO #DelayedPricingBal
		FROM #DelayedPricingALL AA
		GROUP BY
			dtmDate
			,strDistributionType
			,intStorageScheduleTypeId
			,strCommodityCode

		SELECT *
		INTO #DelayedPricingIncDec
		FROM (
			SELECT
				intRowNum = ROW_NUMBER() OVER (ORDER BY strDistributionType)
				,dtmDate
				,strDistributionType
				,dblIn = SUM(dblIn)
				,dblOut = SUM(dblOut)
				,dblNet = SUM(dblIn) - SUM(dblOut)
				,intStorageScheduleTypeId
				,strCommodityCode		
			FROM #DelayedPricingALL AA
			INNER JOIN (
				SELECT strTransactionNumber,strStorageTypeCode
					,total = SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal)) 
				FROM dbo.fnRKGetBucketDelayedPricing(@dtmReportDate,@intCommodityId,NULL) OH
				WHERE strTransactionType <> 'Storage Settlement'
				GROUP BY strTransactionNumber,strStorageTypeCode
			) A ON A.strTransactionNumber = AA.strTransactionNumber 
				AND A.total <> 0 
				AND A.strStorageTypeCode = AA.strStorageTypeCode
			GROUP BY
				dtmDate
				,strDistributionType
				,intStorageScheduleTypeId
				,strCommodityCode
			UNION ALL
			SELECT
				intRowNum = ROW_NUMBER() OVER (ORDER BY strDistributionType)
				,dtmDate
				,strDistributionType
				,dblIn = SUM(dblIn)
				,dblOut = SUM(dblOut)
				,dblNet = SUM(dblIn) - SUM(dblOut)
				,intStorageScheduleTypeId
				,strCommodityCode		
			FROM #DelayedPricingALL AA
			WHERE strTransactionType = 'Storage Settlement'
			GROUP BY
				dtmDate
				,strDistributionType
				,intStorageScheduleTypeId
				,strCommodityCode
		) A

		/*****BEGINNING*****/
		INSERT INTO @CompanyOwnedData
		SELECT 3
			,@dtmReportDate
			,@intCommodityId
			,'   ' + strDistributionType
			,NET = SUM(dblIn) - SUM(dblOut)
			,0
			,0
			,0
			,@strUOM
		FROM #DelayedPricingBal D
		WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) < CONVERT(DATETIME, @dtmReportDate)
		GROUP BY strDistributionType

		--ADD IF DP DOES NOT EXIST FOR THE COMMODITY
		IF NOT EXISTS(SELECT 1 FROM @CompanyOwnedData WHERE intOrderNo = 3)
		BEGIN
			INSERT INTO @CompanyOwnedData
			SELECT 3
				,@dtmReportDate
				,@intCommodityId
				,'   ' + strStorageTypeDescription
				,0
				,0
				,0
				,0
				,@strUOM
			FROM tblGRStorageType
			WHERE ysnDPOwnedType = 1
				AND ysnCustomerStorage = 0
				AND strOwnedPhysicalStock = 'Company'
		END

		--INCREASE AND DECREASE
		UPDATE C
		SET dblTotalIncrease = A.dblTotalIncrease
			,dblTotalDecrease = A.dblTotalDecrease
		FROM @CompanyOwnedData C
		OUTER APPLY (			
			SELECT dblTotalIncrease = SUM(dblIn)
				,dblTotalDecrease = SUM(dblOut)
			FROM #DelayedPricingIncDec
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) = CONVERT(DATETIME, @dtmReportDate)
		) A
		WHERE C.intCommodityId = @intCommodityId
			AND C.intOrderNo = 3		

		DROP TABLE #DelayedPricingALL
		DROP TABLE #DelayedPricingBal
		DROP TABLE #DelayedPricingIncDec
	END
	/*******END******DELAYED PRICING*************/

	/*******START******COMPANY OWNERSHIP (PAID)*************/
	BEGIN
		/*****BEGINNING*****/
		--PHYSICAL INVENTORY TOTAL
		DECLARE @dblPhysicalInventory DECIMAL(18,6)
		SET @dblPhysicalInventory = NULL
		SELECT @dblPhysicalInventory = SUM(dblBegInventory) 
		FROM tblGRGIIPhysicalInventory 
		WHERE intCommodityId = @intCommodityId 
			AND strUOM = @strUOM 
			AND dtmReportDate = @dtmReportDate
		GROUP BY intCommodityId
			,strUOM

		--CUSTOMER STORAGE TOTAL
		DECLARE @dblCustomerStorage DECIMAL(18,6)
		SET @dblPhysicalInventory = NULL
		SELECT @dblCustomerStorage = SUM(dblBeginningBalance) 
		FROM tblGRGIICustomerStorage 
		WHERE intCommodityId = @intCommodityId 
			AND strUOM = @strUOM 
			AND dtmReportDate = @dtmReportDate
		GROUP BY intCommodityId
			,strUOM

		--GET SHIPPED FOR THE DAY
		DECLARE @dblShipped DECIMAL(18,6)
		SET @dblShipped = NULL
		SELECT @dblPhysicalInventory = SUM(dblShipped)
		FROM tblGRGIIPhysicalInventory 
		WHERE intCommodityId = @intCommodityId 
			AND strUOM = @strUOM 
			AND dtmReportDate = @dtmReportDate
		GROUP BY intCommodityId
			,strUOM

		--GET TRANSFERS FROM LICENSED TO NON-LICENSED LOCATIONS FOR THE DAY
		DECLARE @dblTransfers DECIMAL(18,6)
		SET @dblTransfers = NULL
		SELECT @dblTransfers = SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(CO_UOM.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,ITD.dblQuantity))
		FROM tblICInventoryTransferDetail ITD
		INNER JOIN tblICInventoryTransfer IT
			ON IT.intInventoryTransferId = ITD.intInventoryTransferId
		INNER JOIN tblSMCompanyLocation CL_LICENSED
			ON CL_LICENSED.intCompanyLocationId = IT.intFromLocationId
				AND CL_LICENSED.ysnLicensed = 1
		INNER JOIN tblSMCompanyLocation CL_UNLICENSED
			ON CL_UNLICENSED.intCompanyLocationId = IT.intToLocationId
				AND CL_UNLICENSED.ysnLicensed = 0
		INNER JOIN tblICItem IC
			ON IC.intItemId = ITD.intItemId
		INNER JOIN tblICItemUOM ITEM_UOM
			ON ITEM_UOM.intItemUOMId = ITD.intItemUOMId
		INNER JOIN tblICCommodityUnitMeasure CO_UOM
			ON CO_UOM.intCommodityId = IC.intItemId
				AND CO_UOM.intUnitMeasureId = ITEM_UOM.intUnitMeasureId
		WHERE dbo.fnRemoveTimeOnDate(IT.dtmTransferDate) = @dtmReportDate
			AND IC.intCommodityId = @intCommodityId

		INSERT INTO @CompanyOwnedData
		SELECT 1
			,@dtmReportDate
			,@intCommodityId
			,'   COMPANY OWNERSHIP (PAID)'
			,dblTotalBeginning = ISNULL(@dblPhysicalInventory,0) - ISNULL(@dblCustomerStorage,0) - ISNULL(CO.total,0)
			,dblTotalIncrease = CU.total
			,dblTotalDecrease = ISNULL(@dblShipped,0) + ISNULL(@dblTransfers,0)
			,0
			,@strUOM
		FROM (
			SELECT total = SUM(A.dblTotalBeginning)
				,A.intCommodityId
			FROM @CompanyOwnedData A
			WHERE intOrderNo IN (2,3) --COMPANY OWNERSHIP (UNPAID) AND DELAYED PRICING
				AND A.intCommodityId = @intCommodityId
			GROUP BY A.intCommodityId
		) CO
		INNER JOIN (
			SELECT total = A.dblTotalDecrease
				,A.intCommodityId
			FROM @CompanyOwnedData A
			WHERE intOrderNo = 2 --COMPANY OWNERSHIP (UNPAID)
				AND A.intCommodityId = @intCommodityId
		) CU
			ON CU.intCommodityId = CO.intCommodityId
	END
	/*******END******COMPANY OWNERSHIP (PAID)*************/

	/*******START******TOTAL COMPANY OWNED*************/
	BEGIN
		INSERT INTO @CompanyOwnedData
		SELECT 4
			,@dtmReportDate
			,intCommodityId
			,'              Total Company Owned'
			,SUM(ISNULL(dblTotalBeginning,0))
			,SUM(ISNULL(dblTotalIncrease,0))
			,SUM(ISNULL(dblTotalDecrease,0))
			,0
			,@strUOM
		FROM @CompanyOwnedData
		WHERE intCommodityId = @intCommodityId
		GROUP BY intCommodityId
	END
	/*******END******TOTAL COMPANY OWNED*************/

	/*******START******BLANK*************/
	BEGIN
		INSERT INTO @CompanyOwnedData
		SELECT 5
			,@dtmReportDate
			,@intCommodityId
			,''
			,NULL
			,NULL
			,NULL
			,NULL
			,@strUOM
	END
	/*******END******BLANK*************/

	/*******START******BLANK*************/
	BEGIN
		INSERT INTO @CompanyOwnedData
		SELECT 6
			,@dtmReportDate
			,@intCommodityId
			,'TOTALS - ALL INVENTORY TYPES AT LICENSED LOCATIONS'
			,CO.dblTotalBeginning + CS.dblCustomerBeginning
			,CO.dblTotalIncrease + CS.dblCustomerIncrease
			,CO.dblTotalDecrease + CS.dblCustomerDecrease
			,CO.dblTotalEnding + CS.dblCustomerEnding
			,@strUOM
		FROM @CompanyOwnedData CO
		INNER JOIN (
			SELECT dblCustomerBeginning = SUM(dblBeginningBalance)
				,dblCustomerIncrease = SUM(dblIncrease)
				,dblCustomerDecrease = SUM(dblDecrease)
				,dblCustomerEnding = SUM(dblEndingBalance)
				,intCommodityId
			FROM tblGRGIICustomerStorage
			WHERE intCommodityId = @intCommodityId
				AND dtmReportDate = @dtmReportDate
				AND strUOM = @strUOM
			GROUP BY intCommodityId
		) CS
			ON CS.intCommodityId = CO.intCommodityId
		WHERE intOrderNo = 4
	END
	/*******END******BLANK*************/

	

	--DELETE FROM @tblCommodities WHERE intId = @intCommodityId
END

--DROP TABLE #PhysicalInventory
TRUNCATE TABLE tblGRGIIPhysicalInventory
TRUNCATE TABLE tblGRGIICustomerStorage

UPDATE @CompanyOwnedData SET dblTotalEnding = ISNULL(dblTotalBeginning,0) + ISNULL(dblTotalIncrease,0) - ISNULL(dblTotalDecrease,0) WHERE strLabel <> ''

SELECT * FROM @CompanyOwnedData ORDER BY intOrderNo

END