CREATE VIEW [dbo].[vyuICMultiCurrencyRevalueReceipt]
AS
SELECT
     strTransactionType				= r.strReceiptType
    ,strTransactionId				= r.strReceiptNumber
    ,strTransactionDate				= r.dtmReceiptDate
    ,strTransactionDueDate			= CAST(NULL AS NVARCHAR(50))
    ,strVendorName					= rLookUp.strVendorName
    ,strCommodity					= c.strDescription
    ,strLineOfBusiness				= lob.strLineOfBusiness
    ,strLocation					= rLookUp.strLocationName
    ,strTicket						= riLookUp.strSourceNumber --st.strTicketNumber
    ,strContractNumber				= riLookUp.strOrderNumber --hd.strContractNumber
    ,strItemId						= i.strItemNo
    ,dblQuantity					= ISNULL(ReceiptItemFormula.dblOpenQty, 0)
    ,dblUnitPrice					= ISNULL(ReceiptItemFormula.dblCost, 0)
    ,dblAmount						= 
			-- 	Transaction Amount = (Qty x Price) + Tax - Discount
			ISNULL(ReceiptItemFormula.dblOpenQty, 0) * ISNULL(ReceiptItemFormula.dblCost, 0) + ISNULL(ReceiptItemFormula.dblOpenTax, 0)
    ,intCurrencyId					= r.intCurrencyId
    ,intForexRateType				= ri.intForexRateTypeId
    ,strForexRateType				= riLookUp.strForexRateType
    ,dblForexRate					= ri.dblForexRate
    ,dblHistoricAmount				= 
			-- Historic Amount = Transaction Amount x Forex Rate
			(ISNULL(ReceiptItemFormula.dblOpenQty, 0) * ISNULL(ReceiptItemFormula.dblCost, 0) + ISNULL(ReceiptItemFormula.dblOpenTax, 0)) * ISNULL(ri.dblForexRate, 0) 
    ,dblNewForexRate				= 0 --Calcuate By GL
    ,dblNewAmount					= 0 --Calcuate By GL
    ,dblUnrealizedDebitGain			= 0 --Calcuate By GL
    ,dblUnrealizedCreditGain		= 0 --Calcuate By GL
    ,dblDebit						= 0 --Calcuate By GL
    ,dblCredit						= 0 --Calcuate By GL
FROM tblICInventoryReceipt r
	INNER JOIN vyuICInventoryReceiptLookUp rLookUp ON rLookUp.intInventoryReceiptId = r.intInventoryReceiptId
    INNER JOIN tblICInventoryReceiptItem ri ON ri.intInventoryReceiptId = r.intInventoryReceiptId
	INNER JOIN vyuICInventoryReceiptItemLookUp riLookUp ON riLookUp.intInventoryReceiptItemId = ri.intInventoryReceiptItemId		
	CROSS APPLY (
		SELECT 
			dblOpenQty = 
				CASE 
					WHEN ri.intWeightUOMId IS NOT NULL THEN 
						CASE 
							WHEN strReceiptType = 'Inventory Return' THEN 
								-(ri.dblNet - ISNULL(ri.dblBillQty, 0) 	)
							ELSE
								ri.dblNet - ISNULL(ri.dblBillQty, 0) 	
						END
						
					ELSE 
						CASE 
							WHEN strReceiptType = 'Inventory Return' THEN 
								-(ri.dblOpenReceive - ISNULL(ri.dblBillQty, 0) 	)
							ELSE
								ri.dblOpenReceive - ISNULL(ri.dblBillQty, 0) 	
						END
						
						
				END 
			,dblCost = 
				CASE 
					WHEN ri.intWeightUOMId IS NOT NULL THEN 
						dbo.fnCalculateCostBetweenUOM(ISNULL(ri.intCostUOMId, ri.intUnitMeasureId), ri.intWeightUOMId, ri.dblUnitCost) 
					ELSE
						dbo.fnCalculateCostBetweenUOM(ISNULL(ri.intCostUOMId, ri.intUnitMeasureId), ri.intUnitMeasureId, ri.dblUnitCost) 
				END 
			,dblOpenTax = 
				
				CASE 
					WHEN strReceiptType = 'Inventory Return' THEN 
						-ri.dblTax 
					ELSE
						ri.dblTax 
				END
				/
				(
					CASE 
						WHEN ri.intWeightUOMId IS NOT NULL THEN 
							CASE WHEN ri.dblNet = 0 THEN NULL ELSE ri.dblNet END 
						ELSE 
							CASE WHEN ri.dblOpenReceive = 0 THEN NULL ELSE ri.dblOpenReceive END 
					END 								
				)
				* (
					CASE 
						WHEN ri.intWeightUOMId IS NOT NULL THEN 
							ri.dblNet - ISNULL(ri.dblBillQty, 0) 	
						ELSE 
							ri.dblOpenReceive - ISNULL(ri.dblBillQty, 0) 	
					END 				
				)	
	) ReceiptItemFormula 
    LEFT JOIN tblICItem i ON i.intItemId = ri.intItemId
    LEFT JOIN tblICCommodity c ON c.intCommodityId = i.intCommodityId
    LEFT JOIN tblICCategory ct ON ct.intCategoryId = i.intCategoryId
    LEFT JOIN tblSMLineOfBusiness lob ON lob.intLineOfBusinessId = ct.intLineOfBusinessId
WHERE 
	r.ysnPosted = 1
    AND ri.dblOpenReceive <> ISNULL(ri.dblBillQty, 0) 
	AND r.intCurrencyId <> dbo.fnSMGetDefaultCurrency('FUNCTIONAL')