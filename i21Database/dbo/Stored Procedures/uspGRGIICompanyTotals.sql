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
		SELECT *
		INTO #Vouchers
		FROM (
			SELECT IC.intCommodityId
				,dblQty = SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(UM_REF.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,BD.dblQtyReceived))		
			FROM tblAPBillDetail BD
			INNER JOIN tblAPBill AP
				ON AP.intBillId = BD.intBillId
			INNER JOIN tblICItem IC
				ON IC.intItemId = BD.intItemId
					AND IC.strType = 'Inventory'
			INNER JOIN tblICItemUOM UOM	
				ON UOM.intItemUOMId = BD.intUnitOfMeasureId
			OUTER APPLY (
				SELECT TOP 1 intCommodityUnitMeasureId
				FROM tblICCommodityUnitMeasure
				WHERE intCommodityId = IC.intCommodityId
					AND intUnitMeasureId = ISNULL(UOM.intUnitMeasureId,@intCommodityUnitMeasureId)
			) UM_REF
			INNER JOIN tblGRSettleStorageBillDetail SBD
				ON SBD.intBillId = BD.intBillId		
			INNER JOIN tblSMCompanyLocation CL
				ON CL.intCompanyLocationId = AP.intShipToId
					AND CL.ysnLicensed = 1
			WHERE (
					((AP.ysnPosted = 0 OR AP.ysnPaid = 0) AND dbo.fnRemoveTimeOnDate(AP.dtmDateCreated) < @dtmReportDate)
					OR 
					(dbo.fnRemoveTimeOnDate(AP.dtmDateCreated) < @dtmReportDate AND AP.ysnPaid = 1 AND dbo.fnRemoveTimeOnDate(AP.dtmDatePaid) = @dtmReportDate)
				)
				AND IC.intCommodityId = @intCommodityId
			GROUP BY IC.intCommodityId
				,UM_REF.intCommodityUnitMeasureId
			UNION ALL
			SELECT IC.intCommodityId
				,dblQty = SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(UM_REF.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,BD.dblQtyReceived))		
			FROM tblAPBillDetail BD
			INNER JOIN tblAPBill AP
				ON AP.intBillId = BD.intBillId
			INNER JOIN tblICItem IC
				ON IC.intItemId = BD.intItemId
					AND IC.strType = 'Inventory'
			INNER JOIN tblICItemUOM UOM	
				ON (UOM.intItemUOMId = BD.intUnitOfMeasureId
					OR (UOM.intItemId = IC.intItemId
						AND UOM.ysnStockUnit = 1)
					)
			OUTER APPLY (
				SELECT TOP 1 intCommodityUnitMeasureId
				FROM tblICCommodityUnitMeasure
				WHERE intCommodityId = IC.intCommodityId
					AND intUnitMeasureId = ISNULL(UOM.intUnitMeasureId,@intCommodityUnitMeasureId)
			) UM_REF
			LEFT JOIN tblICInventoryReceiptItem IR
				ON IR.intInventoryReceiptItemId = BD.intInventoryReceiptItemId
			WHERE (
					((AP.ysnPosted = 0 OR AP.ysnPaid = 0) AND dbo.fnRemoveTimeOnDate(AP.dtmDateCreated) < @dtmReportDate)
					OR 
					(dbo.fnRemoveTimeOnDate(AP.dtmDateCreated) < @dtmReportDate AND AP.ysnPaid = 1 AND dbo.fnRemoveTimeOnDate(AP.dtmDatePaid) = @dtmReportDate)
				)
				AND IC.intCommodityId = @intCommodityId
				AND AP.intTransactionType = 1
				AND ((BD.intSettleStorageId IS NULL AND BD.intCustomerStorageId IS NULL AND BD.intInventoryReceiptItemId IS NULL AND BD.intContractDetailId IS NULL)
						OR (BD.intSettleStorageId IS NULL AND BD.intCustomerStorageId IS NULL AND BD.intInventoryReceiptItemId IS NOT NULL AND IR.intOwnershipType = 1)
					)
			GROUP BY IC.intCommodityId
				,UM_REF.intCommodityUnitMeasureId
		) A

		DECLARE @dblDPReversedSettlementsWithNoPayment DECIMAL(18,6)
		DECLARE @dblDPReversedSettlementsWithPayment DECIMAL(18,6)
		DECLARE @dblDPSettlementsWithDeletedPayment DECIMAL(18,6)
		DECLARE @dblSettlementsWithDeletedPayment DECIMAL(18,6)
		SELECT @dblDPReversedSettlementsWithNoPayment = SUM(dblUnpaid)
			,@dblDPReversedSettlementsWithPayment = SUM(dblPaid)
			,@dblDPSettlementsWithDeletedPayment = SUM(dblPaid2)
			,@dblSettlementsWithDeletedPayment = SUM(dblPaid3) --must be added only on the unpaid decrease if reversal was done on the same day that the settlement was processed
		FROM (
			SELECT dblUnpaid = CASE WHEN AP.intBillId IS NULL AND SH.strType = 'Reverse Settlement' THEN SUM(ISNULL(SH.dblUnits,0)) ELSE 0 END
				,dblPaid = CASE WHEN AP.intBillId IS NOT NULL AND SH.strType = 'Reverse Settlement' THEN SUM(ISNULL(SH.dblUnits,0)) ELSE 0 END
				,dblPaid2 = CASE WHEN AP.intBillId IS NOT NULL AND SH.strType = 'Settlement' THEN SUM(ISNULL(SH.dblUnits,0)) ELSE 0 END
				,dblPaid3 = CASE WHEN AP.intBillId IS NOT NULL AND dbo.fnRemoveTimeOnDate(SH_2.dtmHistoryDate) = dbo.fnRemoveTimeOnDate(SH.dtmHistoryDate) AND SH.strType = 'Reverse Settlement' THEN SUM(ISNULL(SH.dblUnits,0)) ELSE 0 END
			FROM tblGRStorageHistory SH
			INNER JOIN tblGRCustomerStorage CS
				ON CS.intCustomerStorageId = SH.intCustomerStorageId
			INNER JOIN tblGRStorageType ST
				ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
			INNER JOIN tblICCommodity IC
				ON IC.intCommodityId = CS.intCommodityId
			INNER JOIN tblSMCompanyLocation CL
				ON CL.intCompanyLocationId = CS.intCompanyLocationId
			INNER JOIN tblICItemUOM UOM
				ON UOM.intItemUOMId = CS.intItemUOMId
			INNER JOIN tblICUnitMeasure UM
				ON UM.intUnitMeasureId = UOM.intUnitMeasureId
			LEFT JOIN tblAPBill AP
				ON (AP.strVendorOrderNumber = SH.strSettleTicket OR AP.strVendorOrderNumber = CS.strStorageTicketNumber)
					AND AP.intTransactionType = 2 --VPRE
			LEFT JOIN tblGRStorageHistory SH_2
				ON SH_2.strSettleTicket = SH.strSettleTicket
					AND SH_2.strType = 'Settlement'
			WHERE ((SH.strType = 'Reverse Settlement' AND SH.intSettleStorageId IS NULL) OR (SH.strType = 'Settlement' AND SH.intSettleStorageId IS NOT NULL))
				AND CS.intCommodityId = @intCommodityId
				AND dbo.fnRemoveTimeOnDate(SH.dtmHistoryDate) = @dtmReportDate
			GROUP BY AP.intBillId, SH.strType, SH_2.dtmHistoryDate,SH.dtmHistoryDate
		) A

		
		--DECLARE @dblSettlementsFromYesterday DECIMAL(18,6) --settlements from yesterday that were reversed the next day
		--DECLARE @dblSettlementsFromYesterday2 DECIMAL(18,6) --get the reversed settlements from the next day when the report is printed prior to the current date
		----SELECT @dblSettlementsFromYesterday = SUM(dblUnpaid)
		----FROM (
		--	SELECT @dblSettlementsFromYesterday = SUM(A.dblSettlementsFromYesterday)
		--		,@dblSettlementsFromYesterday2 = SUM(A.dblSettlementsFromYesterday2)
		--	FROM (
		--		SELECT dblSettlementsFromYesterday = CASE WHEN dbo.fnRemoveTimeOnDate(SH.dtmHistoryDate) = @dtmReportDate THEN SUM(ISNULL(SH.dblUnits,0)) ELSE 0 END
		--			,dblSettlementsFromYesterday2 = CASE WHEN dbo.fnRemoveTimeOnDate(SH.dtmHistoryDate) > @dtmReportDate THEN SUM(ISNULL(SH.dblUnits,0)) ELSE 0 END
		--		FROM tblGRStorageHistory SH
		--		INNER JOIN tblGRCustomerStorage CS
		--			ON CS.intCustomerStorageId = SH.intCustomerStorageId
		--		INNER JOIN tblGRStorageType ST
		--			ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
		--		INNER JOIN tblICCommodity IC
		--			ON IC.intCommodityId = CS.intCommodityId
		--		INNER JOIN tblSMCompanyLocation CL
		--			ON CL.intCompanyLocationId = CS.intCompanyLocationId
		--		INNER JOIN tblICItemUOM UOM
		--			ON UOM.intItemUOMId = CS.intItemUOMId
		--		INNER JOIN tblICUnitMeasure UM
		--			ON UM.intUnitMeasureId = UOM.intUnitMeasureId
		--		INNER JOIN (
		--			SELECT dtmHistoryDate = dbo.fnRemoveTimeOnDate(dtmHistoryDate) 
		--				,strSettleTicket
		--			FROM tblGRStorageHistory 
		--			WHERE strType = 'Settlement'
		--		) STRS
		--			ON STRS.strSettleTicket = SH.strSettleTicket
		--		WHERE (SH.strType = 'Reverse Settlement' AND SH.intSettleStorageId IS NULL)
		--			AND CS.intCommodityId = @intCommodityId
		--			AND dbo.fnRemoveTimeOnDate(SH.dtmHistoryDate) > STRS.dtmHistoryDate
		--			--AND dbo.fnRemoveTimeOnDate(SH.dtmHistoryDate) = @dtmReportDate
		--		GROUP BY SH.dtmHistoryDate
		--	) A

		/****BEGINNING****/
		INSERT INTO @CompanyOwnedData
		SELECT 2
			,@dtmReportDate
			,V.intCommodityId
			,'   COMPANY OWNERSHIP (UNPAID)'
			,SUM(V.dblQty) --+ ISNULL(@dblSettlementsFromYesterday,0)
			,0
			,0
			,0
			,@strUOM
		FROM #Vouchers V
		INNER JOIN tblICCommodity CO
			ON CO.intCommodityId = V.intCommodityId
		GROUP BY V.intCommodityId

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

		/******DECREASE*******/
		DECLARE @dblVoidedPayment DECIMAL(18,6)
		SELECT @dblVoidedPayment = SUM(dblQty) FROM (
		SELECT dblQty = SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(SS.intCommodityStockUomId,@intCommodityUnitMeasureId,BD.dblQtyReceived))
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
		) ON PD.intOrigBillId = AP.intBillId
			AND PYMT.ysnNewFlag = 1
		WHERE ISNULL(PYMT.strPaymentInfo,'') <> ''
			AND IC.intCommodityId = @intCommodityId
			AND dbo.fnRemoveTimeOnDate(PYMT.dtmDatePaid) = @dtmReportDate
		GROUP BY IC.intCommodityId
			,SS.intCommodityStockUomId
		UNION ALL
		SELECT dblQty = SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(UM_REF.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,BD.dblQtyReceived))		
		FROM tblAPBillDetail BD
		INNER JOIN tblAPBill AP
			ON AP.intBillId = BD.intBillId
		INNER JOIN tblICItem IC
			ON IC.intItemId = BD.intItemId
				AND IC.strType = 'Inventory'
		INNER JOIN tblICItemUOM UOM	
			ON (UOM.intItemUOMId = BD.intUnitOfMeasureId
				OR (UOM.intItemId = IC.intItemId
					AND UOM.ysnStockUnit = 1)
				)
		OUTER APPLY (
			SELECT TOP 1 intCommodityUnitMeasureId
			FROM tblICCommodityUnitMeasure
			WHERE intCommodityId = IC.intCommodityId
				AND intUnitMeasureId = ISNULL(UOM.intUnitMeasureId,@intCommodityUnitMeasureId)
		) UM_REF
		LEFT JOIN tblICInventoryReceiptItem IR
			ON IR.intInventoryReceiptItemId = BD.intInventoryReceiptItemId
		INNER JOIN (
			tblAPPaymentDetail PD
			INNER JOIN tblAPPayment PYMT
				ON PYMT.intPaymentId = PD.intPaymentId
		) ON PD.intOrigBillId = AP.intBillId
			AND PYMT.ysnNewFlag = 1
		WHERE ISNULL(PYMT.strPaymentInfo,'') <> ''
			AND IC.intCommodityId = @intCommodityId
			AND dbo.fnRemoveTimeOnDate(PYMT.dtmDatePaid) = @dtmReportDate
			AND AP.intTransactionType = 1
			AND ((BD.intSettleStorageId IS NULL AND BD.intCustomerStorageId IS NULL AND BD.intInventoryReceiptItemId IS NULL AND BD.intContractDetailId IS NULL)
					OR (BD.intSettleStorageId IS NULL AND BD.intCustomerStorageId IS NULL AND BD.intInventoryReceiptItemId IS NOT NULL AND IR.intOwnershipType = 1)
				)
		GROUP BY IC.intCommodityId
			,UM_REF.intCommodityUnitMeasureId
		) A

		--SELECT ISNULL(@dblVoidedPayment,0),ISNULL(@dblSettlementsFromYesterday2,0),ISNULL(@dblDPSettlementsWithDeletedPayment,0),ISNULL(@dblDPReversedSettlementsWithPayment,0),ISNULL(@dblDPReversedSettlementsWithNoPayment,0),ISNULL(@dblSettlementsWithDeletedPayment,0)

		UPDATE C
		SET dblTotalDecrease = ISNULL(A.dblQty,0) + ISNULL(@dblVoidedPayment,0) + ISNULL(@dblDPSettlementsWithDeletedPayment,0) + ISNULL(@dblSettlementsWithDeletedPayment,0)
		FROM @CompanyOwnedData C
		LEFT JOIN (
			SELECT AA.intCommodityId
				,dblQty = SUM(AA.dblQty) FROM (
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
			UNION ALL
			SELECT IC.intCommodityId
				,dblQty = SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(UM_REF.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,BD.dblQtyReceived))		
			FROM tblAPBillDetail BD
			INNER JOIN tblAPBill AP
				ON AP.intBillId = BD.intBillId
			INNER JOIN tblICItem IC
				ON IC.intItemId = BD.intItemId
					AND IC.strType = 'Inventory'
			INNER JOIN tblICItemUOM UOM	
				ON (UOM.intItemUOMId = BD.intUnitOfMeasureId
					OR (UOM.intItemId = IC.intItemId
						AND UOM.ysnStockUnit = 1)
					)
			OUTER APPLY (
				SELECT TOP 1 intCommodityUnitMeasureId
				FROM tblICCommodityUnitMeasure
				WHERE intCommodityId = IC.intCommodityId
					AND intUnitMeasureId = ISNULL(UOM.intUnitMeasureId,@intCommodityUnitMeasureId)
			) UM_REF
			LEFT JOIN tblICInventoryReceiptItem IR
				ON IR.intInventoryReceiptItemId = BD.intInventoryReceiptItemId
			INNER JOIN (
				tblAPPaymentDetail PD
				INNER JOIN tblAPPayment PYMT
					ON PYMT.intPaymentId = PD.intPaymentId
			) ON PD.intBillId = AP.intBillId
			WHERE ISNULL(PYMT.strPaymentInfo,'') <> ''
				AND IC.intCommodityId = @intCommodityId
				AND dbo.fnRemoveTimeOnDate(PYMT.dtmDatePaid) = @dtmReportDate
				AND AP.intTransactionType = 1
				AND ((BD.intSettleStorageId IS NULL AND BD.intCustomerStorageId IS NULL AND BD.intInventoryReceiptItemId IS NULL AND BD.intContractDetailId IS NULL)
						OR (BD.intSettleStorageId IS NULL AND BD.intCustomerStorageId IS NULL AND BD.intInventoryReceiptItemId IS NOT NULL AND IR.intOwnershipType = 1)
					)
			GROUP BY IC.intCommodityId
				,UM_REF.intCommodityUnitMeasureId
			) AA
			GROUP BY intCommodityId
		) A ON A.intCommodityId = C.intCommodityId
		WHERE C.intOrderNo = 2
			AND C.dtmReportDate = @dtmReportDate

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

		/*GET IA*/
		DECLARE @dblDPIA DECIMAL(18,6)
		SELECT @dblDPIA = ABS(SUM(dblIn) - SUM(dblOut))
		FROM #DelayedPricingALL AA
		WHERE strTransactionType = 'Inventory Adjustment'
			AND dtmDate = @dtmReportDate

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
		SET dblTotalIncrease = ISNULL(A.dblTotalIncrease,0)
			,dblTotalDecrease = ISNULL(A.dblTotalDecrease,0)
		FROM @CompanyOwnedData C
		OUTER APPLY (			
			SELECT dblTotalIncrease = SUM(dblIn)
				,dblTotalDecrease = SUM(dblOut)
			FROM #DelayedPricingIncDec C
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) = CONVERT(DATETIME, @dtmReportDate)
			GROUP BY strCommodityCode
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
		DECLARE @dblIACompanyOwned DECIMAL(18,6)
		DECLARE @dblIACustomerOwned DECIMAL(18,6)
		SET @dblPhysicalInventory = NULL
		SELECT @dblPhysicalInventory = SUM(dblBegInventory) 
			,@dblIACompanyOwned = SUM(dblIACompanyOwned)
			,@dblIACustomerOwned = SUM(dblIACustomerOwned)
		FROM tblGRGIIPhysicalInventory 
		WHERE intCommodityId = @intCommodityId 
			AND strUOM = @strUOM 
			AND dtmReportDate = @dtmReportDate
		GROUP BY intCommodityId
			,strUOM

		--CUSTOMER STORAGE TOTAL
		DECLARE @dblCustomerStorage DECIMAL(18,6)
		DECLARE @dblSODecrease DECIMAL(18,6)
		SET @dblCustomerStorage = NULL		
		SELECT @dblCustomerStorage = SUM(dblBeginningBalance)
		FROM tblGRGIICustomerStorage 
		WHERE intCommodityId = @intCommodityId 
			AND strUOM = @strUOM 
			AND dtmReportDate = @dtmReportDate
		GROUP BY intCommodityId
			,strUOM

		--SET @dblSODecrease = NULL
		--SELECT @dblSODecrease = SUM(dblDecrease)
		--FROM tblGRGIICustomerStorage CS
		--INNER JOIN tblGRStorageType ST
		--	ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
		--		AND ST.ysnReceiptedStorage = 0
		--		AND ST.ysnCustomerStorage = 0
		--		AND ST.ysnDPOwnedType = 0
		--		AND ST.ysnGrainBankType = 0
		--		AND ST.strOwnedPhysicalStock = 'Customer'
		--WHERE intCommodityId = @intCommodityId 
		--	AND strUOM = @strUOM 
		--	AND dtmReportDate = @dtmReportDate
		--GROUP BY intCommodityId
		--	,strUOM

		SET @dblSODecrease = NULL
		SELECT @dblSODecrease = SUM(dblDecrease) - (ISNULL(@dblIACustomerOwned,0) * -1)
		FROM tblGRGIICustomerStorage CS
		INNER JOIN tblGRStorageType ST
			ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
				AND ST.ysnReceiptedStorage = 0
				AND ST.ysnCustomerStorage = 0
				AND ST.ysnDPOwnedType = 0
				AND ST.ysnGrainBankType = 0
				AND ST.strOwnedPhysicalStock = 'Customer'		
		WHERE intCommodityId = @intCommodityId 
			AND strUOM = @strUOM 
			AND dtmReportDate = @dtmReportDate
		GROUP BY intCommodityId
			,strUOM		

		--GET SHIPPED, IT RECEIVED AND SHIPPED FOR THE DAY
		DECLARE @dblShipped DECIMAL(18,6)
		DECLARE @dblInternalTransfersReceived DECIMAL(18,6)
		DECLARE @dblInternalTransfersShipped DECIMAL(18,6)
		DECLARE @dblInternalTransfersDiff DECIMAL(18,6)
		SET @dblShipped = NULL
		SET @dblInternalTransfersReceived = NULL
		SET @dblInternalTransfersShipped = NULL
		SET @dblInternalTransfersDiff = NULL

		SELECT @dblShipped = SUM(ISNULL(dblShipped,0))
			,@dblInternalTransfersReceived = SUM(ISNULL(dblInternalTransfersReceived,0))
			,@dblInternalTransfersShipped = SUM(ISNULL(dblInternalTransfersShipped,0))
		FROM tblGRGIIPhysicalInventory 
		WHERE intCommodityId = @intCommodityId 
			AND strUOM = @strUOM 
			AND dtmReportDate = @dtmReportDate

		SET @dblInternalTransfersDiff = @dblInternalTransfersReceived - @dblInternalTransfersShipped

		--GET RECEIVED THAT ARE COMPANY OWNED
		--DECLARE @dblReceivedCompanyOwned DECIMAL(18,6)
		--SET @dblReceivedCompanyOwned = NULL
		--SELECT @dblReceivedCompanyOwned = SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal))
		--FROM dbo.fnRKGetBucketCompanyOwned(@dtmReportDate,@intCommodityId,NULL) CompOwn
		--INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CompOwn.intLocationId AND CL.ysnLicensed = 1
		--LEFT JOIN tblCTContractDetail CD
		--	ON CD.intContractDetailId = CompOwn.intContractDetailId
		--WHERE intCommodityId = @intCommodityId
		--	AND CONVERT(DATETIME,CONVERT(VARCHAR(10),dtmTransactionDate,110),110) = @dtmReportDate
		--	AND CompOwn.strTransactionType = 'Inventory Receipt'
		--	AND ISNULL(CD.intPricingTypeId,0) <> 5 --EXCLUDE DP

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
			,dblTotalBeginning = 0--ISNULL(@dblPhysicalInventory,0) - ISNULL(@dblCustomerStorage,0) - ISNULL(CO.total,0)
			,dblTotalIncrease = CU.total + 
								CASE WHEN ISNULL(@dblIACompanyOwned,0) < 0 THEN 0 ELSE ISNULL(@dblIACompanyOwned,0) END + 
								CASE WHEN ISNULL(@dblInternalTransfersDiff,0) < 0 THEN 0 ELSE ISNULL(@dblInternalTransfersDiff,0) END --+ 
								--ISNULL(@dblReceivedCompanyOwned,0)
								--ISNULL(@dblDPReversedSettlementsWithPayment,0) --+ 
								--ISNULL(@dblDPSettlementsWithDeletedPayment,0)
			,dblTotalDecrease = ABS(
								(ISNULL(@dblShipped,0) + ISNULL(@dblTransfers,0)) +
								CASE WHEN ISNULL(@dblIACompanyOwned,0) < 0 THEN ISNULL(@dblIACompanyOwned,0) ELSE 0 END + 
								CASE WHEN ISNULL(@dblInternalTransfersDiff,0) < 0 THEN ISNULL(@dblInternalTransfersDiff,0) ELSE 0 END +
								ISNULL(@dblDPReversedSettlementsWithPayment,0) + 
								ISNULL(@dblVoidedPayment,0) +
								ISNULL(@dblDPSettlementsWithDeletedPayment,0)
								) - ISNULL(@dblDPIA,0)
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
		LEFT JOIN (
			SELECT total = SUM(A.dblTotalDecrease)
				,A.intCommodityId
			FROM @CompanyOwnedData A
			WHERE intOrderNo = 3
				AND A.intCommodityId = @intCommodityId
			GROUP BY A.intCommodityId
		) DP
			ON DP.intCommodityId = CO.intCommodityId


	END
	/*******END******COMPANY OWNERSHIP (PAID)*************/

	/*******START******UPDATE COMPANY OWNERSHIP (UNPAID)*************/
	
	/******INCREASE*******/
	UPDATE C
	--SET dblTotalIncrease = ISNULL(@dblSODecrease,0) + ISNULL(@dblIACustomerOwned,0) + ISNULL(DP.total,0) + ISNULL(RS.dblUnits,0)
	SET dblTotalIncrease = (ISNULL(@dblSODecrease,0) + ISNULL(DP.total,0) + ISNULL(@dblVoidedPayment,0) + ISNULL(@dblDPSettlementsWithDeletedPayment,0)) - ISNULL(@dblDPIA,0) - ISNULL(TS.dblUnits,0)
		,dblTotalDecrease = dblTotalDecrease + ISNULL(@dblDPReversedSettlementsWithNoPayment,0)
	FROM @CompanyOwnedData C
	LEFT JOIN (
		SELECT total = SUM(A.dblTotalDecrease)
			,A.intCommodityId
		FROM @CompanyOwnedData A
		WHERE intOrderNo = 3
			AND A.intCommodityId = @intCommodityId
		GROUP BY A.intCommodityId
	) DP
		ON DP.intCommodityId = C.intCommodityId
	OUTER APPLY (
		SELECT SUM(ISNULL(dblDeductedUnits,0)) dblUnits
		FROM vyuGRTransferStorageSearchView TS
		INNER JOIN tblGRStorageType ST_FROM
			ON ST_FROM.intStorageScheduleTypeId = TS.intFromStorageTypeId
		INNER JOIN tblGRStorageType ST_TO
			ON ST_TO.intStorageScheduleTypeId = TS.intToStorageTypeId
		INNER JOIN tblGRCustomerStorage CS
			ON CS.intCustomerStorageId = TS.intFromCustomerStorageId
		INNER JOIN tblICItemUOM UOM
			ON UOM.intItemUOMId = CS.intItemUOMId
		INNER JOIN tblICUnitMeasure UM
			ON UM.intUnitMeasureId = UOM.intUnitMeasureId
		/*
			Transfer from Company owned to customer owned
		*/
		WHERE ST_FROM.strOwnedPhysicalStock = 'Company'
			AND ST_TO.strOwnedPhysicalStock = 'Customer'
			AND TS.intCommodityId = @intCommodityId
			AND dbo.fnRemoveTimeOnDate(TS.dtmTransferStorageDate) = @dtmReportDate
	) TS
	WHERE C.dtmReportDate = @dtmReportDate
		AND C.intOrderNo = 2

	/*******END******UPDATE COMPANY OWNERSHIP (UNPAID)*************/

	/*******START******TOTAL COMPANY OWNED*************/
	BEGIN
		INSERT INTO @CompanyOwnedData
		SELECT 4
			,@dtmReportDate
			,intCommodityId
			,'              Total Company Owned'
			,ISNULL(@dblPhysicalInventory,0) - ISNULL(@dblCustomerStorage,0) --SUM(ISNULL(dblTotalBeginning,0))
			,SUM(ISNULL(dblTotalIncrease,0))
			,SUM(ISNULL(dblTotalDecrease,0))
			,0
			,@strUOM
		FROM @CompanyOwnedData
		WHERE intCommodityId = @intCommodityId
		GROUP BY intCommodityId
	END
	/*******END******TOTAL COMPANY OWNED*************/

	/*******START******UPDATE COMPANY OWNERSHIP (PAID)*************/
	
	/******BEGINNING*******/
	DECLARE @totalCO DECIMAL(18,6)
	DECLARE @totalDP DECIMAL(18,6)
	DECLARE @totalCOUnpaid DECIMAL(18,6)

	SET @totalCO = (SELECT dblTotalBeginning FROM @CompanyOwnedData WHERE intOrderNo = 4)
	SET @totalDP = (SELECT dblTotalBeginning FROM @CompanyOwnedData WHERE intOrderNo = 3)
	SET @totalCOUnpaid = (SELECT dblTotalBeginning FROM @CompanyOwnedData WHERE intOrderNo = 2)

	UPDATE C
	SET dblTotalBeginning = ISNULL(@totalCO,0) - ISNULL(@totalDP,0) - ISNULL(@totalCOUnpaid,0)
	FROM @CompanyOwnedData C
	WHERE C.dtmReportDate = @dtmReportDate
		AND C.intOrderNo = 1

	/*******END******UPDATE COMPANY OWNERSHIP (PAID)*************/

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
			,0
			,@strUOM
		FROM @CompanyOwnedData CO
		INNER JOIN (
			SELECT dblCustomerBeginning = SUM(dblBeginningBalance)
				,dblCustomerIncrease = SUM(dblIncrease)
				,dblCustomerDecrease = SUM(dblDecrease)
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