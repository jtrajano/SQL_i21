CREATE VIEW vyuGRItemsSettlementReport
AS
SELECT --ITEMS.intItemId
		ITEMS.strItemNo AS ItemName
		, SUM(ITEMS.dblQtyReceived) AS Amount
		, ITEMS.strDistributionType AS PivotColumn
		, (
			SELECT strUnitMeasure 
			FROM tblICUnitMeasure UM
			LEFT JOIN tblICItemUOM ItemUOM ON
				UM.intUnitMeasureId = ItemUOM.intUnitMeasureId
			WHERE ItemUOM.intItemId = ITEMS.intItemId
				AND ItemUOM.ysnStockUOM = 1
			) AS UnitMeasure
		, ITEMS.intEntityVendorId
FROM (
		SELECT 
				BD.intBillId
				, Bill.intEntityVendorId
				, BD.intItemId
				, ItemUOM.intItemUOMId
				, Item.strItemNo
				, dbo.fnCTConvertQtyToTargetItemUOM(BD.intUnitOfMeasureId,
						(
						SELECT intItemUOMId 
						FROM tblICItemUOM 
						WHERE intItemId = BD.intItemId 
								AND ysnStockUOM = 1
						),
						BD.dblQtyReceived) 
					AS dblQtyReceived
				, SD.strDistributionType
		FROM tblAPBillDetail BD
		JOIN tblAPBill Bill ON 
			BD.intBillId = Bill.intBillId
		LEFT JOIN tblAPPaymentDetail PD ON 
			BD.intBillId = PD.intBillId
		LEFT JOIN tblICItem Item ON 
			BD.intItemId = Item.intItemId						
		LEFT JOIN tblICItemUOM ItemUOM ON 
			Item.intItemId = ItemUOM.intItemId 
			AND BD.intUnitOfMeasureId = ItemUOM.intItemUOMId
		LEFT JOIN tblICUnitMeasure UM ON ItemUOM.intUnitMeasureId = UM.intUnitMeasureId
		LEFT JOIN vyuSCGetScaleDistribution SD ON (BD.intInventoryReceiptItemId = SD.intInventoryReceiptItemId OR BD.intCustomerStorageId = SD.intCustomerStorageId)
		WHERE	PD.dblAmountDue = 0
				AND Item.strType = 'Inventory'
				AND Item.ysnUseWeighScales = 1
		GROUP BY 
				BD.intItemId
				, Bill.intEntityVendorId
				, BD.intBillId
				, Item.strItemNo
				, BD.dblQtyReceived
				, SD.strDistributionType
				, ItemUOM.intItemUOMId
				, BD.intUnitOfMeasureId
	) ITEMS
--WHERE ITEMS.intItemId = 625
GROUP BY ITEMS.intItemId
		, ITEMS.strItemNo
		, ITEMS.intEntityVendorId
		, ITEMS.strDistributionType
		, ITEMS.intItemUOMId
		, ITEMS.intEntityVendorId

UNION ALL

SELECT --CD.intItemId
		Item.strItemNo AS ItemName
		, dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,
				(
				SELECT intItemUOMId 
				FROM tblICItemUOM 
				WHERE intItemId = CD.intItemId 
						AND ysnStockUOM = 1
				),
				SUM(CD.dblBalance)) 
			AS Amount
		 , CTT.strContractType AS PivotColumn
		 , (
			SELECT strUnitMeasure 
			FROM tblICUnitMeasure UM
			LEFT JOIN tblICItemUOM ItemUOM ON
				UM.intUnitMeasureId = ItemUOM.intUnitMeasureId
			WHERE ItemUOM.intItemId = CD.intItemId
				AND ItemUOM.ysnStockUOM = 1
			) AS UnitMeasure
		, CH.intEntityId
FROM tblCTContractDetail CD
JOIN tblCTContractHeader CH ON
	CD.intContractHeaderId = CH.intContractHeaderId
LEFT JOIN tblCTPricingType PT ON
	CD.intPricingTypeId = PT.intPricingTypeId
LEFT JOIN tblCTContractType CTT ON
	CH.intContractTypeId = CTT.intContractTypeId
LEFT JOIN tblICItem Item ON
	CD.intItemId = Item.intItemId 
LEFT JOIN tblICItemUOM ItemUOM ON 
	Item.intItemId = ItemUOM.intItemId 
	AND CD.intItemUOMId = ItemUOM.intItemUOMId
LEFT JOIN tblICUnitMeasure UM ON ItemUOM.intUnitMeasureId = UM.intUnitMeasureId
WHERE PT.strPricingType IN ('Priced','Basis','HTA')
	AND CD.dblBalance > 0
	AND Item.ysnUseWeighScales = 1
GROUP BY CD.intItemId
		, Item.strItemNo
		, CD.intItemUOMId
		, CTT.strContractType
		, CD.dblBalance
		, CH.intEntityId