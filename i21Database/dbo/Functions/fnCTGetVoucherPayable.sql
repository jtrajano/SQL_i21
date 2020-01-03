CREATE FUNCTION [dbo].[fnCTGetVoucherPayable]
(
	@id INT,
	@type NVARCHAR(10),
	@accrue BIT = 1,
	@remove BIT = 0
)
RETURNS TABLE AS RETURN
(
	select top 1
		strMessage = 'Unable to add Cost to Payable because the ' + strItemNo + ' item is missing GL Account setup for ' + strAccountCategory + ' Account Category.'
	from
	(
	SELECT	DISTINCT
		[intAccountId]			=	apClearing.intAccountId
		,[strItemNo]			=	CC.strItemNo
		,[strAccountCategory]	=	(
										case
											when CC.strCostType = 'Other Charges'
																	or (
																			select
																				count(*)
																			from
																				tblICInventoryReceiptItem a
																				,tblICInventoryReceipt b
																			where
																				a.intContractHeaderId = CD.intContractHeaderId
																				and a.intContractDetailId = CD.intContractDetailId
																				and b.intInventoryReceiptId = a.intInventoryReceiptId
																		) = 0
											then 'Other Charge Expense'
											else 'AP Clearing' 
										end
									)
	FROM vyuCTContractCostView CC
	CROSS APPLY ( select ysnMultiplePriceFixation from tblCTCompanyPreference ) CPT
	JOIN tblCTContractDetail CD	ON CD.intContractDetailId = CC.intContractDetailId AND (CC.ysnPrice = 1 AND CD.intPricingTypeId IN (1,6) 
			OR CC.ysnAccrue = CASE 
				WHEN ISNULL(CPT.ysnMultiplePriceFixation,0) = 0 AND @accrue = 1 THEN 1 
				ELSE CC.ysnAccrue 
			END
		) 
		AND (CASE WHEN @remove = 0 AND CC.intConcurrencyId <> ISNULL(CC.intPrevConcurrencyId,0) THEN 1 ELSE @remove END = 1)
	JOIN tblCTContractHeader CH	ON	CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = CC.intItemId AND ItemLoc.intLocationId = CD.intCompanyLocationId
	OUTER APPLY dbo.fnGetItemGLAccountAsTable(CC.intItemId, ItemLoc.intItemLocationId,  case
																						when CC.strCostType = 'Other Charges'
																						or (
																								select
																									count(*)
																								from
																									tblICInventoryReceiptItem a
																									,tblICInventoryReceipt b
																								where
																									a.intContractHeaderId = CD.intContractHeaderId
																									and a.intContractDetailId = CD.intContractDetailId
																									and b.intInventoryReceiptId = a.intInventoryReceiptId
																							) = 0
																						then 'Other Charge Expense'
																						else 'AP Clearing' 
																						end
											) itemAccnt
	LEFT JOIN dbo.tblGLAccount apClearing ON apClearing.intAccountId = itemAccnt.intAccountId
	LEFT JOIN tblICInventoryReceiptCharge RC ON	RC.intContractId = CC.intContractHeaderId AND RC.intChargeId = CC.intItemId
	OUTER APPLY 
	(
		SELECT TOP 1 intEntityVendorId 
		FROM tblAPVoucherPayable
		WHERE CASE 
			WHEN @type = 'cost' AND intContractCostId = @id THEN 1
			ELSE 0
		END = 1
	) payable

	WHERE RC.intInventoryReceiptChargeId IS NULL AND CC.ysnAccrue = @accrue AND
	NOT EXISTS(SELECT 1 FROM tblICInventoryShipmentCharge WHERE intContractDetailId = CD.intContractDetailId AND intChargeId = CC.intItemId) AND
	CASE 
		WHEN @type = 'header' AND CH.intContractHeaderId = @id THEN 1
		WHEN @type = 'detail' AND CD.intContractDetailId = @id THEN 1
		WHEN @type = 'cost' AND CC.intContractCostId = @id THEN 1
	END = 1 
	AND CASE WHEN @accrue = 0 AND payable.intEntityVendorId IS NOT NULL THEN 1 ELSE @accrue END = 1
	) as dataRaw
	where isnull(intAccountId,0) = 0
)