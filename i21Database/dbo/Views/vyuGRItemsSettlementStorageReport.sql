CREATE VIEW [dbo].[vyuGRItemsSettlementStorageReport]
AS
SELECT B.* 
FROM tblGRStorageType ST 
INNER JOIN (
		SELECT
			ItemName		= A.strItemNo		
			, PivotColumn	= CONVERT(NVARCHAR,A.strDistributionType)
			, CONVERT(NVARCHAR, CONVERT(DECIMAL(18,2), ISNULL(SUM(A.dblQtyReceived),0))) COLLATE Latin1_General_CI_AS as Amount
			, UnitMeasure	= UM.strUnitMeasure
			, CONVERT(NVARCHAR,A.intEntityVendorId)  COLLATE Latin1_General_CI_AS as intEntityId
			, PivotColumnId = A.intStorageScheduleTypeId
		FROM (
				SELECT 
						BD.intBillId
						, Bill.intEntityVendorId
						, BD.intItemId
						, ItemUOM.intItemUOMId
						, Item.strItemNo
						, dblQtyReceived = dbo.fnCTConvertQtyToTargetItemUOM(BD.intUnitOfMeasureId, ItemUOM.intItemUOMId, BD.dblQtyReceived)
						, SD.strDistributionType
						, SD.intStorageScheduleTypeId
						, ItemUOM.intUnitMeasureId
				FROM tblAPBillDetail BD
				JOIN tblAPBill Bill 
					ON BD.intBillId = Bill.intBillId
				LEFT JOIN tblAPPaymentDetail PD 
					ON BD.intBillId = PD.intBillId
				LEFT JOIN tblICItem Item 
					ON BD.intItemId = Item.intItemId						
				LEFT JOIN tblICItemUOM ItemUOM 
					ON Item.intItemId = ItemUOM.intItemId
						AND ItemUOM.ysnStockUnit = 1		
				LEFT JOIN vyuSCGetScaleDistribution SD 
					ON (BD.intInventoryReceiptItemId = SD.intInventoryReceiptItemId 
						OR BD.intCustomerStorageId = SD.intCustomerStorageId)
				WHERE	PD.dblAmountDue = 0
						AND Item.strType = 'Inventory'
						AND Item.ysnUseWeighScales = 1
						AND SD.strDistributionType IS NOT NULL
						AND BD.dblQtyReceived > 1
				GROUP BY 
						BD.intItemId
						, Bill.intEntityVendorId
						, BD.intBillId
						, Item.strItemNo
						, BD.dblQtyReceived
						, SD.strDistributionType
						, ItemUOM.intItemUOMId
						, BD.intUnitOfMeasureId
						, SD.intStorageScheduleTypeId
						, ItemUOM.intUnitMeasureId
			) A
		LEFT JOIN tblICUnitMeasure UM 
			ON A.intUnitMeasureId = UM.intUnitMeasureId
		GROUP BY A.intItemId
				, A.strItemNo
				, A.intEntityVendorId
				, A.strDistributionType
				, A.intItemUOMId
				, A.intEntityVendorId
				, A.intStorageScheduleTypeId
				, UM.strUnitMeasure
) B ON ST.intStorageScheduleTypeId = B.PivotColumnId
WHERE ST.intStorageScheduleTypeId > -1