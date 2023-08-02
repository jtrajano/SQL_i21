CREATE PROCEDURE dbo.uspGRDPRSettledAndUnsettledCommodity 
	-- Add the parameters for the stored procedure here
	@intCommodityId			int,	
	@intLocationId			int,
	@dtmDate				datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @CompanyOwnedData AS TABLE (
	id int IDENTITY(1,1) NOT NULL,
	dtmDate DATETIME
	,dblIncrease DECIMAL(18,6) DEFAULT 0
	,dblDecrease DECIMAL(18,6) DEFAULT 0
	,strType NVARCHAR(40) COLLATE Latin1_General_CI_AS
)

	DECLARE @intCommodityUnitMeasureId AS INT
	,@strUOM NVARCHAR(20)
	--,@dblVoidedPayment DECIMAL(18,6)
	--,@dblVoidedPaymentOldVoucher DECIMAL(18,6)
	--,@dblVoidedPaymentOldVoucherAddInBeginning DECIMAL(18,6)	

		/*******START******COMPANY OWNERSHIP (UNPAID)*************/
	BEGIN
		--VOIDED PAYMENTS ***SETTLEMENTS ARE NOT REVERSED YET
			
		
		SELECT @intCommodityUnitMeasureId = intCommodityUnitMeasureId
		,@strUOM = UOM.strUnitMeasure
		FROM tblICCommodityUnitMeasure UM
		INNER JOIN tblICUnitMeasure UOM
			ON UOM.intUnitMeasureId = UM.intUnitMeasureId
		WHERE intCommodityId = @intCommodityId
			AND ysnStockUnit = 1

	
		SELECT * into #VoidPayment FROM (
			SELECT 			
			dblVoidedPayment = SUM(dblQty1)
			,dblVoidedPaymentOldVoucher =sum(dblQty2)
			,dtmDate = dtmDatePaid
			FROM (			
				SELECT dblQty1 = CASE WHEN PYMT.dtmDatePaid = PYMT2.dtmDatePaid  THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(SS.intCommodityStockUomId,@intCommodityUnitMeasureId,BD.dblQtyReceived) ELSE 0 END
				,dblQty2 = CASE WHEN PYMT.dtmDatePaid <> PYMT2.dtmDatePaid  THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(SS.intCommodityStockUomId,@intCommodityUnitMeasureId,BD.dblQtyReceived) ELSE 0 END
				,PYMT.dtmDatePaid
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
				AND PYMT.strPaymentRecordNum LIKE '%V'
			LEFT JOIN (
				tblAPPaymentDetail PD2
				INNER JOIN tblAPPayment PYMT2
					ON PYMT2.intPaymentId = PD2.intPaymentId
			) ON PD.intOrigBillId = AP.intBillId
				AND PYMT2.strPaymentRecordNum = LEFT(PYMT.strPaymentRecordNum,LEN(PYMT.strPaymentRecordNum)-1)
				AND PD2.intOrigBillId = PD.intOrigBillId
			WHERE ISNULL(PYMT.strPaymentInfo,'') <> ''
				AND IC.intCommodityId = @intCommodityId
				AND dbo.fnRemoveTimeOnDate(PYMT.dtmDatePaid) <= @dtmDate
				and (CL.intCompanyLocationId = @intLocationId or @intLocationId = 0)
			--GROUP BY IC.intCommodityId
			--	,SS.intCommodityStockUomId
			UNION ALL
			SELECT dblQty1 = CASE WHEN PYMT.dtmDatePaid = PYMT2.dtmDatePaid  THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(UM_REF.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,BD.dblQtyReceived) ELSE 0 END
				,dblQty2 = CASE WHEN PYMT.dtmDatePaid <> PYMT2.dtmDatePaid   THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(UM_REF.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,BD.dblQtyReceived) ELSE 0 END
				,PYMT.dtmDatePaid
			FROM tblAPBillDetail BD
			INNER JOIN tblAPBill AP
				ON AP.intBillId = BD.intBillId
			INNER JOIN tblSMCompanyLocation CL
				ON CL.intCompanyLocationId = AP.intShipToId
					AND CL.ysnLicensed = 1
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
				AND PYMT.strPaymentRecordNum LIKE '%V'
			LEFT JOIN (
				tblAPPaymentDetail PD2
				INNER JOIN tblAPPayment PYMT2
					ON PYMT2.intPaymentId = PD2.intPaymentId
			) ON PD.intOrigBillId = AP.intBillId
				AND PYMT2.strPaymentRecordNum = LEFT(PYMT.strPaymentRecordNum,LEN(PYMT.strPaymentRecordNum)-1)
				AND PD2.intOrigBillId = PD.intOrigBillId
			WHERE ISNULL(PYMT.strPaymentInfo,'') <> ''
				AND IC.intCommodityId = @intCommodityId
				AND dbo.fnRemoveTimeOnDate(PYMT.dtmDatePaid) <= @dtmDate
				and (CL.intCompanyLocationId = @intLocationId or @intLocationId = 0)
				AND AP.intTransactionType = 1
				AND ((BD.intSettleStorageId IS NULL AND BD.intCustomerStorageId IS NULL AND BD.intInventoryReceiptItemId IS NULL AND BD.intContractDetailId IS NULL)
						OR (BD.intSettleStorageId IS NULL AND BD.intCustomerStorageId IS NULL AND BD.intInventoryReceiptItemId IS NOT NULL AND IR.intOwnershipType = 1)
					)
				AND PYMT.strPaymentRecordNum LIKE '%V'

				--union all
				--SELECT dblTotal /*dblReversedSettlementsWithVoidedPayment*/ = SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityStockUOMId,@intCommodityUnitMeasureId,dblUnits))
				--,dtmDatePaid = dtmVoidPaymentDate
				--,strType = 'dblReversedSettlementsWithVoidedPayment'
				--FROM tblGRReversedSettlementsWithVoidedPayments
				--WHERE intCommodityId = @intCommodityId AND dbo.fnRemoveTimeOnDate(dtmVoidPaymentDate) <= @dtmDate
				--group by dtmVoidPaymentDate
			) A group by A.dtmDatePaid
		) X

		 
		select * into #CompanyToCustomer 
			from (
				SELECT SUM(ISNULL(dblDeductedUnits,0)) dblUnits
			FROM vyuGRTransferStorageSearchView TS
			INNER JOIN tblGRStorageType ST_FROM
				ON ST_FROM.intStorageScheduleTypeId = TS.intFromStorageTypeId
			INNER JOIN tblGRStorageType ST_TO
				ON ST_TO.intStorageScheduleTypeId = TS.intToStorageTypeId
			INNER JOIN tblGRCustomerStorage CS
				ON CS.intCustomerStorageId = TS.intFromCustomerStorageId
			INNER JOIN tblSMCompanyLocation CL
				ON CL.intCompanyLocationId = CS.intCompanyLocationId
					AND CL.ysnLicensed = 1
			INNER JOIN tblICItemUOM UOM
				ON UOM.intItemUOMId = CS.intItemUOMId
			INNER JOIN tblICUnitMeasure UM
				ON UM.intUnitMeasureId = UOM.intUnitMeasureId
			/*
				Transfer from Company owned to customer owned
			*/
			WHERE (ST_FROM.strOwnedPhysicalStock = 'Company' AND ST_TO.strOwnedPhysicalStock = 'Customer')
				AND TS.intCommodityId = @intCommodityId
				and (CL.intCompanyLocationId = @intLocationId or @intLocationId = 0)
				AND dbo.fnRemoveTimeOnDate(TS.dtmTransferStorageDate) = @dtmDate
		) t

		 
		--select * into #SODecrease from (
		--	SELECT
		--	dblUnits = SUM(dblDecrease) -- - (ISNULL(sum(giipi.dblIACustomerOwned),0) * -1) - ISNULL(sum(TS.dblUnits),0)
		--	,dtmDate = CS.dtmReportDate
		--	FROM tblGRGIICustomerStorage CS
		--	INNER JOIN tblGRStorageType ST
		--	ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
		--		AND ST.ysnReceiptedStorage = 0
		--		AND ST.ysnCustomerStorage = 0
		--		AND ST.ysnDPOwnedType = 0
		--		AND ST.ysnGrainBankType = 0
		--		AND ST.strOwnedPhysicalStock = 'Customer'
		--	WHERE intCommodityId = @intCommodityId 
		--	AND strUOM = @strUOM  
		--	AND CS.dtmReportDate <= @dtmDate
		--union ALL (
		--	select dblUnits = TS.dblDeductedUnits * -1 
		--		from (
		--		SELECT SUM(ISNULL(dblDeductedUnits,0)) dblDeductedUnits
		--		,TS.dtmTransferStorageDate
		--		,ST_FROM.intStorageScheduleTypeId
		--		FROM vyuGRTransferStorageSearchView TS
		--		INNER JOIN tblGRStorageType ST_FROM
		--			ON ST_FROM.intStorageScheduleTypeId = TS.intFromStorageTypeId
		--		INNER JOIN tblGRStorageType ST_TO
		--			ON ST_TO.intStorageScheduleTypeId = TS.intToStorageTypeId
		--		INNER JOIN tblGRCustomerStorage CS
		--			ON CS.intCustomerStorageId = TS.intFromCustomerStorageId
		--		INNER JOIN tblSMCompanyLocation CL
		--			ON CL.intCompanyLocationId = CS.intCompanyLocationId
		--				AND CL.ysnLicensed = 1
		--		INNER JOIN tblICItemUOM UOM
		--			ON UOM.intItemUOMId = CS.intItemUOMId
		--		INNER JOIN tblICUnitMeasure UM
		--			ON UM.intUnitMeasureId = UOM.intUnitMeasureId
		--		/*
		--			Transfer from Company owned to customer owned
		--		*/					
		--		WHERE (ST_FROM.strOwnedPhysicalStock = 'Customer' AND ST_TO.strOwnedPhysicalStock = 'Customer')
		--		AND TS.intCommodityId = @intCommodityId
		--		AND dbo.fnRemoveTimeOnDate(TS.dtmTransferStorageDate) <= @dtmDate
		--		AND (ST_FROM.intStorageScheduleTypeId <> ST_TO.intStorageScheduleTypeId)
		--		group by TS.dtmTransferStorageDate,ST_FROM.intStorageScheduleTypeId
		--	) TS group by dtmDate
		--)  
		--union all (
		--	SELECT
		--	dblUnits = SUM(dblIACustomerOwned) 
		--	,dtmDate = dtmReportDate
		--	FROM tblGRGIIPhysicalInventory 
		--	WHERE intCommodityId = @intCommodityId 
		--		AND strUOM = @strUOM 
		--		AND dtmReportDate <= @dtmDate
		--	GROUP BY intCommodityId, dtmReportDate
		--		--,strUOM
		--		) 
		
		--) t

		 
		select * into #CompanyOwnedIRVoucher from (
		SELECT dblCompanyOwnedIRVoucher = SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(UM_REF.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,BD.dblQtyReceived))
		,dtmDate = dbo.fnRemoveTimeOnDate(AP.dtmDateCreated)
		FROM tblAPBillDetail BD
		INNER JOIN tblAPBill AP
			ON AP.intBillId = BD.intBillId
		INNER JOIN tblSMCompanyLocation CL
			ON CL.intCompanyLocationId = AP.intShipToId
				AND CL.ysnLicensed = 1
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
				((AP.ysnPosted = 0 OR AP.ysnPaid = 0))
				OR 
				( AP.ysnPaid = 1 AND dbo.fnRemoveTimeOnDate(AP.dtmDatePaid) >= AP.dtmDateCreated)
			)
			and dbo.fnRemoveTimeOnDate(AP.dtmDateCreated) <= @dtmDate
			AND IC.intCommodityId = @intCommodityId
			and (CL.intCompanyLocationId = @intLocationId or @intLocationId = 0)
			AND AP.intTransactionType = 1
			AND ((BD.intSettleStorageId IS NULL AND BD.intCustomerStorageId IS NULL AND BD.intInventoryReceiptItemId IS NULL AND BD.intContractDetailId IS NULL)
					OR (BD.intSettleStorageId IS NULL AND BD.intCustomerStorageId IS NULL AND BD.intInventoryReceiptItemId IS NOT NULL AND IR.intOwnershipType = 1)
				)

			group by AP.dtmDateCreated
		) t
		--select '@dblVoidedPayment'=@dblVoidedPayment,'@dblVoidedPaymentOldVoucher'=@dblVoidedPaymentOldVoucher,'@dblVoidedPaymentOldVoucherAddInBeginning'=@dblVoidedPaymentOldVoucherAddInBeginning

		--REVERSED SETTLEMENTS WITH VOIDED PAYMENTS
		--DECLARE @dblReversedSettlementsWithVoidedPayment DECIMAL(18,6) --add in paid decrease
		--SELECT @dblReversedSettlementsWithVoidedPayment = SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityStockUOMId,@intCommodityUnitMeasureId,dblUnits))
		--FROM tblGRReversedSettlementsWithVoidedPayments
		--WHERE intCommodityId = @intCommodityId
		--	AND dbo.fnRemoveTimeOnDate(dtmVoidPaymentDate) = @dtmDate

		

		--DECLARE @dblReversedSettlementsWithNoPayment DECIMAL(18,6)
		--DECLARE @dblDPReversedSettlementsWithPayment DECIMAL(18,6)
		--DECLARE @dblSettlementsWithDeletedPayment DECIMAL(18,6)
		--DECLARE @dblSettlementsWithDeletedPaymentSameDay DECIMAL(18,6)
		--DECLARE @dblSettlementReversedOnDiffDay DECIMAL(18,6)

		 
		select * into #settlements from (			
			SELECT dtmDate = dbo.fnRemoveTimeOnDate(dtmHistoryDate)
			,dblReversedSettlementsWithNoPayment = dblUnpaid
			,dblDPReversedSettlementsWithPayment = dblPaid
			,dblSettlementsWithDeletedPayment = dblPaid2
			,dblSettlementsWithDeletedPaymentSameDay = dblPaid3 --must be added only on the unpaid decrease if reversal was done on the same day that the settlement was processed
			--,dblSettlementReversedOnDiffDay = SUM(dblPaid4) --add on the unpaid beginning when a settlement is reversed on a different day
			FROM (
				SELECT 
				SH.dtmHistoryDate
				,dblUnpaid = CASE WHEN AP.intBillId IS NULL AND SH.strType = 'Reverse Settlement' THEN SUM(ISNULL(SH.dblUnits,0)) ELSE 0 END
					,dblPaid = CASE WHEN AP.intBillId IS NOT NULL AND SH.strType = 'Reverse Settlement' THEN SUM(ISNULL(SH.dblUnits,0)) ELSE 0 END
					,dblPaid2 = CASE WHEN AP.intBillId IS NOT NULL AND SH.strType = 'Settlement' THEN SUM(ISNULL(SH.dblUnits,0)) ELSE 0 END
					,dblPaid3 = CASE WHEN AP.intBillId IS NOT NULL AND dbo.fnRemoveTimeOnDate(SH_2.dtmHistoryDate) = dbo.fnRemoveTimeOnDate(SH.dtmHistoryDate) AND SH.strType = 'Reverse Settlement' THEN SUM(ISNULL(SH.dblUnits,0)) ELSE 0 END
					--,dblPaid4 = CASE WHEN AP.intBillId IS NULL AND (
					--	dbo.fnRemoveTimeOnDate(SH_2.dtmHistoryDate) < dbo.fnRemoveTimeOnDate(SH.dtmHistoryDate) 
					--		AND dbo.fnRemoveTimeOnDate(SH.dtmHistoryDate) >= @dtmDate AND dbo.fnRemoveTimeOnDate(SH_2.dtmHistoryDate) < @dtmDate) AND SH.strType = 'Reverse Settlement' THEN SUM(ISNULL(SH.dblUnits,0)) ELSE 0 END
				FROM tblGRStorageHistory SH
				INNER JOIN tblGRCustomerStorage CS
					ON CS.intCustomerStorageId = SH.intCustomerStorageId
				INNER JOIN tblGRStorageType ST
					ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
				INNER JOIN tblICCommodity IC
					ON IC.intCommodityId = CS.intCommodityId
				INNER JOIN tblSMCompanyLocation CL
					ON CL.intCompanyLocationId = CS.intCompanyLocationId
						AND CL.ysnLicensed = 1
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
					and (CL.intCompanyLocationId = @intLocationId or @intLocationId = 0)
					AND dbo.fnRemoveTimeOnDate(SH.dtmHistoryDate) <= @dtmDate
					AND SH.strSettleTicket NOT IN (SELECT strSettleStorageTicket FROM tblGRReversedSettlementsWithVoidedPayments)
				GROUP BY AP.intBillId, SH.strType, SH_2.dtmHistoryDate,SH.dtmHistoryDate
			) A
		)t


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
				FROM dbo.fnRKGetBucketDelayedPricing(@dtmDate,@intCommodityId,NULL) DP
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
						FROM dbo.fnRKGetBucketDelayedPricing(@dtmDate,@intCommodityId,NULL) OH
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

				
			

			

				
			END
			/*******END******DELAYED PRICING*************/


		/*unpaid*/	
		 
		select * into #unpaidDecrease from (
			SELECT AA.intCommodityId
			,dblQty = SUM(AA.dblQty) 
			,dtmDate = dtmDatePaid
				FROM (
				SELECT IC.intCommodityId
					,dblQty = SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(SS.intCommodityStockUomId,@intCommodityUnitMeasureId,BD.dblQtyReceived))
					,PYMT.dtmDatePaid
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
				and (CL.intCompanyLocationId = @intLocationId or @intLocationId = 0)
				AND dbo.fnRemoveTimeOnDate(PYMT.dtmDatePaid) <= @dtmDate
			GROUP BY IC.intCommodityId, PYMT.dtmDatePaid
				,SS.intCommodityStockUomId
		UNION ALL
			SELECT IC.intCommodityId
				,dblQty = SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(UM_REF.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,BD.dblQtyReceived))	
				,PYMT.dtmDatePaid
			FROM tblAPBillDetail BD
			INNER JOIN tblAPBill AP
				ON AP.intBillId = BD.intBillId
			INNER JOIN tblSMCompanyLocation CL
				ON CL.intCompanyLocationId = AP.intShipToId
					AND CL.ysnLicensed = 1
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
				AND (CL.intCompanyLocationId = @intLocationId or @intLocationId = 0)
				AND dbo.fnRemoveTimeOnDate(PYMT.dtmDatePaid) <= @dtmDate
				AND AP.intTransactionType = 1
				AND ((BD.intSettleStorageId IS NULL AND BD.intCustomerStorageId IS NULL AND BD.intInventoryReceiptItemId IS NULL AND BD.intContractDetailId IS NULL)
						OR (BD.intSettleStorageId IS NULL AND BD.intCustomerStorageId IS NULL AND BD.intInventoryReceiptItemId IS NOT NULL AND IR.intOwnershipType = 1)
					)
			GROUP BY IC.intCommodityId, PYMT.dtmDatePaid
				,UM_REF.intCommodityUnitMeasureId
			) AA
			GROUP BY intCommodityId ,dtmDatePaid
		
		) t


		/*Unpaid Start*/
		begin
			insert into @CompanyOwnedData
			select dtmDate
				,abs(SUM(increase))
				,abs(sUM(decrease))
				,strType = 'Unpaid'
				from (				
				select 
					dtmDate
					,increase = dblSettlementsWithDeletedPayment 
					,decrease = dblSettlementsWithDeletedPayment +  dblSettlementsWithDeletedPaymentSameDay + dblSettlementsWithDeletedPayment  + dblReversedSettlementsWithNoPayment
				from #settlements
				union all 
				select 
					dtmDate
					,increase = 0 
					,decrease = dblQty
				from #unpaidDecrease	
				union all 
				select 
					dtmDate
					,increase = dblVoidedPayment + dblVoidedPaymentOldVoucher
					,decrease = dblVoidedPayment 
				
				from #VoidPayment
				UNION ALL
				SELECT 
					dtmDate
					,increase = dblCompanyOwnedIRVoucher 
					,decrease = 0
				FROM #CompanyOwnedIRVoucher
				
				UNION ALL

				/*GET IA*/				
				SELECT 
				dtmDate
				,increase = dblIn - dblOut
				,decrease = 0
				FROM #DelayedPricingALL AA
				WHERE strTransactionType = 'Inventory Adjustment'
				
				UNION ALL
				SELECT 
				dtmDate
				,increase = dblOut
				,decrease = 0
				FROM #DelayedPricingIncDec C
				--WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) = CONVERT(DATETIME, @dtmReportDate)
				--UNION ALL
				--SELECT 
				--dtmDate
				--,increase = dblUnits 
				--,decrease = 0
				--FROM #SODecrease
			) t GROUP BY dtmDate
		end
		/*Unpaid End*/

		 --ISNULL(A.dblQty,0) + ISNULL(@dblSettlementsWithDeletedPayment,0) + ISNULL(@dblSettlementsWithDeletedPaymentSameDay,0) + ISNULL(@dblVoidedPayment,0)
		/*Paid Start*/
		begin
			insert into @CompanyOwnedData
			select dtmDate
				,abs(SUM(increase))
				,abs(sUM(decrease))
				,strType = 'Paid'
				from (				
				select 
					dtmDate
					,increase = dblSettlementsWithDeletedPayment +  dblSettlementsWithDeletedPaymentSameDay  + dblDPReversedSettlementsWithPayment
					,decrease = dblDPReversedSettlementsWithPayment + dblSettlementsWithDeletedPaymentSameDay
				from #settlements
				
				union all 
				select 
					dtmDate
					,increase = dblVoidedPayment 
					,decrease = dblVoidedPayment + dblVoidedPaymentOldVoucher 
				
				from #VoidPayment				
				
				UNION ALL
				SELECT 
				dtmDate = CONVERT(DATETIME,CONVERT(VARCHAR(10),dtmTransactionDate,110),110)
				,increase = dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal)
				,decrease = 0
				FROM dbo.fnRKGetBucketCompanyOwned(@dtmDate,@intCommodityId,NULL) CompOwn
				INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CompOwn.intLocationId AND CL.ysnLicensed = 1
				LEFT JOIN tblCTContractDetail CD
					ON CD.intContractDetailId = CompOwn.intContractDetailId
				WHERE intCommodityId = @intCommodityId
					AND CONVERT(DATETIME,CONVERT(VARCHAR(10),dtmTransactionDate,110),110) <= @dtmDate
					AND CompOwn.strTransactionType = 'Inventory Receipt'
					AND ISNULL(CD.intPricingTypeId,0) <> 5 --EXCLUDE DP
					
				union all
				SELECT 
				dtmDatePaid = dtmVoidPaymentDate
				,increase = 0 
				,decrease /*dblReversedSettlementsWithVoidedPayment*/ = SUM(dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityStockUOMId,@intCommodityUnitMeasureId,dblUnits))				
				
				FROM tblGRReversedSettlementsWithVoidedPayments
				WHERE intCommodityId = @intCommodityId AND dbo.fnRemoveTimeOnDate(dtmVoidPaymentDate) <= @dtmDate
				group by dtmVoidPaymentDate
				) t GROUP BY dtmDate

				
		end
		/*Paid Start*/

		--drop table #SODecrease
		drop table #settlements
		drop table #CompanyOwnedIRVoucher
		drop table #unpaidDecrease
		drop table #VoidPayment
		DROP TABLE #DelayedPricingALL
		DROP TABLE #DelayedPricingBal
		DROP TABLE #DelayedPricingIncDec
	END


	drop table #CompanyToCustomer
	
	/*******END******UPDATE COMPANY OWNERSHIP (UNPAID)*************/

	--SELECT * FROM @CompanyOwnedData --ORDER BY intOrderNo

	
	TRUNCATE TABLE tblGRGIIPhysicalInventory
	TRUNCATE TABLE tblGRGIICustomerStorage

	--UPDATE @CompanyOwnedData SET dblTotalEnding = ISNULL(dblTotalBeginning,0) + ISNULL(dblTotalIncrease,0) - ISNULL(dblTotalDecrease,0) WHERE strLabel <> ''

	SELECT * FROM @CompanyOwnedData-- ORDER BY intOrderNo
END