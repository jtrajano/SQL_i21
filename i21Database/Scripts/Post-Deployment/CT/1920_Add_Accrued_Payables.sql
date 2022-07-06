GO
	PRINT('CT - 1920_Add_Accrued_Payables Started')

	-- Add Payables if 'Create Other Cost Payable on Save Contract' is set to true
	IF EXISTS(SELECT TOP 1 1 FROM tblCTCompanyPreference WHERE ysnCreateOtherCostPayable = 1)
	BEGIN

	DECLARE
	@id			INT = 0,
	@type		NVARCHAR(10) = 'header',
	@accrue		BIT = 1,
	@remove		BIT = 0

	INSERT INTO tblAPVoucherPayable(  
		[intEntityVendorId]     
		,[intTransactionType] 
		,[strVendorId]   
		,[strName]      
		,[intLocationId]       
		,[intCurrencyId]       
		,[strCurrency]
		,[dtmDate]        
		,[strReference]       
		,[strSourceNumber]      
		,[intContractHeaderId]     
		,[intContractDetailId]     
		,[intContractSeqId]    
		,[intContractCostId]  
		,[strContractNumber]     
		,[strScaleTicketNumber]     
		,[intItemId]        
		,[strItemNo]        
		,[intStorageLocationId]   
		,[strStorageLocationName]   
		,[strMiscDescription]     		
		,[dblOrderQty] 
		,[dblOrderUnitQty]  
		,[intOrderUOMId]       
		,[dblQuantityToBill]      
		,[dblQtyToBillUnitQty]     
		,[intQtyToBillUOMId]      
		,[dblCost]      
		,[dblCostUnitQty]     
		,[intCostUOMId]      
		,[dblNetWeight]    
		,[dblWeightUnitQty]   
		,[intWeightUOMId]      
		,[intCostCurrencyId]
		,[strCostCurrency]
		,[dblTax]  
		,[dblDiscount]  
		,[intCurrencyExchangeRateTypeId]  
		,[strRateType]         
		,[dblExchangeRate] 
		,[ysnSubCurrency]      
		,[intSubCurrencyCents]     
		,[intAccountId]       
		,[strAccountId]       
		,[strAccountDesc]    
		,[intShipViaId]  
		,[intTermId]        
		,[strTerm]        
		,[str1099Form]  
		,[str1099Type]  
		,[ysnReturn]  
	)
	SELECT	DISTINCT TOP 100 PERCENT
		[intEntityVendorId]							=	ISNULL(entity.intEntityId, payable.intEntityVendorId)
		,[intTransactionType]						=	CASE WHEN RT.Item = 0 THEN 1 ELSE 3 END --voucher
		,[strVendorId]								=	LTRIM(CC.intVendorId)  
		,[strName]									=	CC.strVendorName  
		,[intLocationId]							=	NULL --Contract doesn't have location
		,[intCurrencyId]							=	CASE WHEN CY.ysnSubCurrency > 0 
															THEN (SELECT ISNULL(intMainCurrencyId,0) FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(CC.intCurrencyId,0))
															ELSE  ISNULL(CC.intCurrencyId,ISNULL(CU.intMainCurrencyId,CD.intCurrencyId))
														END
		,[strCurrency]								=	CASE WHEN CY.ysnSubCurrency > 0 
															THEN (SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID IN (SELECT intMainCurrencyId FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(CC.intCurrencyId,0)))
															ELSE  ISNULL(CC.strCurrency, ((SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(CU.intMainCurrencyId,CD.intCurrencyId))))
														END	
		,[dtmDate]									=	CD.dtmStartDate
		,[strReference]								=	'' --?
		,[strSourceNumber]							=	LTRIM(CH.strContractNumber)
		,[intContractHeaderId]						=	CD.intContractHeaderId
		,[intContractDetailId]						=	CD.intContractDetailId
		,[intContractSeqId]							=	CD.intContractSeq
		,[intContractCostId]						=	CC.intContractCostId
		,[strContractNumber]						=	CC.strContractNumber
		,[strScaleTicketNumber]						=	CAST(NULL AS NVARCHAR(50))
		,[intItemId]								=	CC.intItemId
		,[strItemNo]								=	CC.strItemNo
		,[intStorageLocationId]						=	CD.intStorageLocationId
		,[strStorageLocationName]					=	SLOC.strName
		,[strMiscDescription]						=	CC.strItemDescription
		,[dblOrderQty]								=	CASE WHEN CC.strCostMethod = 'Per Unit' THEN ISNULL(CD.dblQuantity,0) ELSE 1 END
		,[dblOrderUnitQty]							=	1
		,[intOrderUOMId]							=	ISNULL(ItemUOM.intItemUOMId,CD.intItemUOMId)
		,[dblQuantityToBill]						=	CASE WHEN CC.strCostMethod = 'Per Unit' THEN ISNULL(CD.dblQuantity,0) ELSE 1 END
		,[dblQtyToBillUnitQty]						=	1
		,[intQtyToBillUOMId]						=	ISNULL(ItemUOM.intItemUOMId,CD.intItemUOMId)
		,[dblCost]									=	CASE WHEN CC.strCostMethod = 'Per Unit' THEN ISNULL(CC.dblRate,0) ELSE ISNULL(CC.dblAmount,0) END
		,[dblCostUnitQty]							=	1
		,[intCostUOMId]								=	ISNULL(CostUOM.intItemUOMId,CD.intItemUOMId)
		,[dblNetWeight]								=	CASE 
															WHEN CC.strCostMethod = 'Per Unit' THEN CAST(dbo.fnMFConvertCostToTargetItemUOM(CostUOM.intItemUOMId,WeightUOM.intItemUOMId,ISNULL(CD.dblNetWeight,0)) AS DECIMAL(38,20)) 
															ELSE 
																CASE WHEN CostUOM.intItemUOMId IS NULL THEN 0
																ELSE ISNULL(CC.dblAmount,0) 
															END
														END
		,[dblWeightUnitQty]							=	CAST(1 AS DECIMAL(38,20))
		,[intWeightUOMId]							=	CASE WHEN CC.strCostMethod = 'Per Unit' THEN ISNULL(CostUOM.intItemUOMId,CD.intItemUOMId) ELSE CostUOM.intItemUOMId END
		,[intCostCurrencyId]						=	ISNULL(CC.intCurrencyId,ISNULL(CU.intMainCurrencyId,CD.intCurrencyId))
		,[strCostCurrency]							=	ISNULL(CC.strCurrency, ((SELECT TOP 1 strCurrency FROM dbo.tblSMCurrency WHERE intCurrencyID = ISNULL(CU.intMainCurrencyId,CD.intCurrencyId))))
		,[dblTax]									=	0
		,[dblDiscount]								=	0
		,[intCurrencyExchangeRateTypeId]			=	CC.intRateTypeId
		,[strRateType]								=	rtype.strDescription
		,[dblExchangeRate]							=	ISNULL(CC.dblFX,1)
		,[ysnSubCurrency]							=	ISNULL(CY.ysnSubCurrency,0)
		,[intSubCurrencyCents]						=	CASE WHEN CY.ysnSubCurrency > 0 THEN CY.intCent ELSE 1 END
		,[intAccountId]								=	apClearing.intAccountId
		,[strAccountId]								=	apClearing.strAccountId
		,[strAccountDesc]							=	apClearing.strDescription
		,[intShipViaId]								=	NULL
		,[intTermId]								=	CC.intTermId	
		,[strTerm]									=	term.strTerm
		,[str1099Form]								=	CASE WHEN patron.intEntityId IS NOT NULL 
															AND item.ysn1099Box3 = 1
															AND patron.ysnStockStatusQualified = 1 
															THEN '1099 PATR'
														ELSE D2.str1099Form	END
		,[str1099Type]								=	CASE WHEN patron.intEntityId IS NOT NULL 
															AND item.ysn1099Box3 = 1
															AND patron.ysnStockStatusQualified = 1 
															THEN 'Per-unit retain allocations'
														ELSE D2.str1099Type END
		,[ysnReturn]								=	CAST(RT.Item AS BIT)
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
	LEFT JOIN (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON CC.intVendorId = D1.[intEntityId] 

	INNER JOIN tblICItem item ON item.intItemId = CC.intItemId 
	CROSS APPLY tblSMCompanyPreference compPref
	LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = CD.intCurrencyId
	LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = CC.intItemId AND ItemLoc.intLocationId = CD.intCompanyLocationId
	LEFT JOIN tblICInventoryReceiptCharge RC ON	RC.intContractId = CC.intContractHeaderId AND RC.intChargeId = CC.intItemId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = CD.intItemUOMId
	LEFT JOIN tblICItemUOM CostUOM ON CostUOM.intItemId = CD.intItemId AND CostUOM.intUnitMeasureId = CC.intUnitMeasureId
	LEFT JOIN tblICItemUOM WeightUOM ON WeightUOM.intItemId = CD.intItemId AND WeightUOM.intItemUOMId = CD.intNetWeightUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblICStorageLocation SLOC ON SLOC.intStorageLocationId = CD.intStorageLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation subLoc ON	CD.intSubLocationId = subLoc.intCompanyLocationSubLocationId
	LEFT JOIN tblSMCurrencyExchangeRate F ON  (F.intFromCurrencyId = compPref.intDefaultCurrencyId AND F.intToCurrencyId = CC.intCurrencyId) 
	LEFT JOIN tblSMCurrencyExchangeRateDetail G1 ON F.intCurrencyExchangeRateId = G1.intCurrencyExchangeRateId AND G1.dtmValidFromDate = (SELECT CONVERT(char(10), GETDATE(),126))
	LEFT JOIN tblSMCurrency CY ON CY.intCurrencyID = CC.intCurrencyId
	LEFT JOIN tblSMCurrencyExchangeRate Rate ON Rate.intFromCurrencyId = compPref.intDefaultCurrencyId AND Rate.intToCurrencyId = CU.intMainCurrencyId
	LEFT JOIN tblSMCurrencyExchangeRateDetail RateDetail ON Rate.intCurrencyExchangeRateId = RateDetail.intCurrencyExchangeRateId
	LEFT JOIN vyuPATEntityPatron patron ON patron.intEntityId = CC.intItemId
	LEFT JOIN tblSMCurrencyExchangeRateType rtype ON rtype.intCurrencyExchangeRateTypeId = CC.intRateTypeId
	LEFT JOIN tblSMTerm term ON term.intTermID =  CC.intTermId
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
	OUTER APPLY 
	(
		SELECT TOP 1 dblRate as forexRate from tblSMCurrencyExchangeRateDetail G1
		WHERE F.intCurrencyExchangeRateId = G1.intCurrencyExchangeRateId AND G1.dtmValidFromDate < (SELECT CONVERT(char(10), GETDATE(),126))
		ORDER BY G1.dtmValidFromDate DESC
	) rate
	CROSS JOIN  dbo.fnSplitString('0,1',',') RT
	-- FOR REVIEW
	OUTER APPLY 
	(
		SELECT TOP 1 intEntityVendorId 
		FROM tblAPVoucherPayable
		WHERE CASE 
			WHEN @type = 'cost' AND intContractCostId = @id THEN 1
			ELSE 0
		END = 1
	) payable
	LEFT JOIN
	(
		SELECT intEntityId 
		FROM tblEMEntity
	) entity ON entity.intEntityId = CC.intVendorId OR entity.intEntityId = (CASE WHEN CC.ysnPrice = 1 AND CH.intContractTypeId = 1 THEN CH.intEntityId ELSE CC.intVendorId END)
	WHERE RC.intInventoryReceiptChargeId IS NULL AND CC.ysnAccrue = @accrue AND
	NOT EXISTS(SELECT 1 FROM tblICInventoryShipmentCharge WHERE intContractDetailId = CD.intContractDetailId AND intChargeId = CC.intItemId)
	AND CH.intContractHeaderId in (select intContractHeaderId from tblCTContractHeader)
	AND CASE WHEN @accrue = 0 AND payable.intEntityVendorId IS NOT NULL THEN 1 ELSE @accrue END = 1
	AND ISNULL(entity.intEntityId,ISNULL(payable.intEntityVendorId,0)) <> 0
	AND CC.intContractCostId NOT IN 
	(
		SELECT intContractCostId FROM tblAPBillDetail WHERE intContractCostId IS NOT NULL
		UNION ALL
		SELECT intContractCostId FROM tblAPVoucherPayable WHERE intContractCostId IS NOT NULL
	)
	ORDER BY CD.intContractHeaderId, CD.intContractDetailId, CC.intContractCostId

	UPDATE	CC
	SET		CC.intPrevConcurrencyId = CC.intConcurrencyId
	FROM	tblCTContractCost	CC
	JOIN	tblCTContractDetail	CD	ON	CD.intContractDetailId	=	CC.intContractDetailId
	WHERE	ISNULL(CC.intPrevConcurrencyId,0) <> ISNULL(CC.intConcurrencyId,0)
	
	END

	PRINT('CT - 1920_Add_Accrued_Payables End')
GO

