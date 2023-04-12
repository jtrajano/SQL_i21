CREATE PROCEDURE [dbo].[uspSCCreateTicketLoadCostPayable]
	@TICKET_ID INT	
	,@POST BIT
AS
BEGIN
	DECLARE @LOAD_ID INT
	DECLARE @DefaultCurrencyId INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
	DECLARE @voucherPayable VoucherPayable

	SELECT
		@LOAD_ID = intLoadId
	FROM tblSCTicket
	WHERE intTicketId = @TICKET_ID 
	INSERT INTO @voucherPayable(
			[intEntityVendorId]
			,[intTransactionType]
			,[intLocationId]
			,[intCurrencyId]
			,[dtmDate]
			,[strVendorOrderNumber]
			,[strReference]
			,[strSourceNumber]
			,[intContractHeaderId]
			,[intContractDetailId]
			,[intContractSeqId]
			,[intContractCostId]
			,[intInventoryReceiptItemId]
			,[intLoadShipmentId]
			,[strLoadShipmentNumber]
			,[intLoadShipmentDetailId]
			,[intLoadShipmentCostId]
			,[intItemId]
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
			,[intFreightTermId]
			,[dblTax]
			,[dblDiscount]
			,[dblExchangeRate]
			,[ysnSubCurrency]
			,[intSubCurrencyCents]
			,[intAccountId]
			,[strBillOfLading]
			,[ysnReturn]
			,[ysnStage]
			,[intStorageLocationId]
			,[intSubLocationId])
		


	SELECT
			[intEntityVendorId] = LOAD_COST_FOR_VENDOR.intEntityVendorId
			,[intTransactionType] = 1
			,[intLocationId] = TICKET.intProcessingLocationId
			,[intCurrencyId] = LOAD_COST_FOR_VENDOR.intCurrencyId
			,[dtmDate] = LOAD_COST_FOR_VENDOR.dtmProcessDate
			,[strVendorOrderNumber] = ''
			,[strReference] = ''
			,[strSourceNumber] = LTRIM(LOAD_COST_FOR_VENDOR.strLoadNumber)
			,[intContractHeaderId] = NULL
			,[intContractDetailId] = NULL
			,[intContractSeqId] = NULL
			,[intContractCostId] = NULL
			,[intInventoryReceiptItemId] = NULL
			,[intLoadShipmentId] = LOAD_COST_FOR_VENDOR.intLoadId
			,[strLoadShipmentNumber] = LTRIM(LG_LOAD.strLoadNumber)
			,[intLoadShipmentDetailId] = LOAD_COST_FOR_VENDOR.intLoadDetailId
			,[intLoadShipmentCostId] = LOAD_COST_FOR_VENDOR.intLoadCostId
			,[intItemId] = LOAD_COST_FOR_VENDOR.intItemId
			,[strMiscDescription] = LOAD_COST_FOR_VENDOR.strItemDescription
			,[dblOrderQty] = CASE WHEN LOAD_COST_FOR_VENDOR.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE TICKET.dblNetUnits END
			,[dblOrderUnitQty] = CASE WHEN LOAD_COST_FOR_VENDOR.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE ISNULL(ItemUOM.dblUnitQty,1) END
			,[intOrderUOMId] = LOAD_COST_FOR_VENDOR.intItemUOMId
			,[dblQuantityToBill] = CASE WHEN LOAD_COST_FOR_VENDOR.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE TICKET.dblNetUnits END
			,[dblQtyToBillUnitQty] = CASE WHEN LOAD_COST_FOR_VENDOR.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE ISNULL(ItemUOM.dblUnitQty,1) END
			,[intQtyToBillUOMId] = LOAD_COST_FOR_VENDOR.intItemUOMId
			,[dblCost] = CASE WHEN LOAD_COST_FOR_VENDOR.strCostMethod IN ('Amount','Percentage') THEN ISNULL(LOAD_COST_FOR_VENDOR.dblTotal, LOAD_COST_FOR_VENDOR.dblPrice) ELSE ISNULL(LOAD_COST_FOR_VENDOR.dblPrice, LOAD_COST_FOR_VENDOR.dblTotal) END 
			,[dblCostUnitQty] = CASE WHEN LOAD_COST_FOR_VENDOR.strCostMethod IN ('Amount','Percentage') THEN 1 ELSE ISNULL(ItemCostUOM.dblUnitQty,1) END
			,[intCostUOMId] = CASE WHEN LOAD_COST_FOR_VENDOR.strCostMethod IN ('Amount','Percentage') THEN NULL ELSE LOAD_COST_FOR_VENDOR.intPriceItemUOMId END
			,[dblNetWeight] = 0
			,[dblWeightUnitQty] = 1
			,[intWeightUOMId] = NULL
			,[intCostCurrencyId] = LOAD_COST_FOR_VENDOR.intCurrencyId
			,[intFreightTermId] = NULL
			,[dblTax] = 0
			,[dblDiscount] = 0
			,[dblExchangeRate] = CASE WHEN (LOAD_COST_FOR_VENDOR.intCurrencyId <> @DefaultCurrencyId) THEN 0 ELSE 1 END
			,[ysnSubCurrency] =	CC.ysnSubCurrency
			,[intSubCurrencyCents] = ISNULL(CC.intCent,0)
			,[intAccountId] = apClearing.intAccountId
			,[strBillOfLading] = LG_LOAD.strBLNumber
			,[ysnReturn] = CAST(0 AS BIT)
			,[ysnStage] = CAST(1 AS BIT)
			,[intStorageLocationId] = NULL
			,[intSubLocationId] = NULL

		FROM (
			SELECT [strTransactionType] = 'Load Schedule' COLLATE Latin1_General_CI_AS
			,[strTransactionNumber] = L.[strLoadNumber]
			--,[strShippedItemId] = 'ld:' + CAST(LD.intLoadDetailId AS NVARCHAR(250)) COLLATE Latin1_General_CI_AS
			,[intEntityVendorId] = LC.intVendorId
			,[strCustomerName] = EME.[strName]
			,[intLoadCostId] = LC.intLoadCostId
			,[intCurrencyId] = ISNULL(ISNULL(LC.[intCurrencyId], ARC.[intCurrencyId]), (
					SELECT TOP 1 intDefaultCurrencyId
					FROM tblSMCompanyPreference
					WHERE intDefaultCurrencyId IS NOT NULL
						AND intDefaultCurrencyId <> 0
					))
			,[dtmProcessDate] = L.dtmScheduledDate
			,L.intLoadId
			,NULL intLoadDetailId
			,L.[strLoadNumber]
			,[intContractHeaderId] = NULL --CH.intContractHeaderId
			,[strContractNumber] = NULL --CH.strContractNumber
			,[intContractDetailId] = NULL --CD.intContractDetailId
			,[intContractSeq] = NULL --CD.intContractSeq
			,[intCompanyLocationId] = TICKET.intProcessingLocationId
			,[strLocationName] = SMCL.[strLocationName]
			,[intItemId] = ICI.[intItemId]
			,[strItemNo] = ICI.[strItemNo]
			,[strItemDescription] = CASE 
				WHEN ISNULL(ICI.[strDescription], '') = ''
					THEN ICI.[strItemNo]
				ELSE ICI.[strDescription]
				END
			,[intShipmentItemUOMId] = TICKET.intItemUOMIdTo
			,[dblPrice] = LC.dblRate
			,[dblShipmentUnitPrice] = LC.dblRate
			,[dblTotal] = SUM(LC.dblAmount)
			,[intAccountId] = ARIA.[intAccountId]
			,[intCOGSAccountId] = ARIA.[intCOGSAccountId]
			,[intSalesAccountId] = ARIA.[intSalesAccountId]
			,[intInventoryAccountId] = ARIA.[intInventoryAccountId]
			,[intItemUOMId] = dbo.fnGetMatchingItemUOMId(ICI.[intItemId], TICKET.intItemUOMIdTo)
			,[intWeightItemUOMId] = dbo.fnGetMatchingItemUOMId(ICI.[intItemId], TICKET.intItemUOMIdTo)
			,[intPriceItemUOMId] = LC.intItemUOMId
			,[dblGross] = TICKET.dblGrossWeight
			,[dblTare] = TICKET.dblTareWeight
			,[dblNet] = TICKET.dblNetUnits
			,EME.str1099Form
			,EME.str1099Type
			,CU.strCurrency
			,[strPriceUOM] = UOM.strUnitMeasure
			,[ysnPosted] = L.ysnPosted
			,LC.strCostMethod
			,LC.ysnAccrue
			,LC.ysnPrice
			,LC.ysnMTM
			,LC.intBillId
			,intSubLocationId = ISNULL(LW.intSubLocationId, TICKET.intSubLocationId)
			,intStorageLocationId = ISNULL(LW.intStorageLocationId, TICKET.intStorageLocationId)
			,strSubLocationName = ISNULL(LW.strSubLocation, CLSL.strSubLocationName)
			,strStorageLocationName = ISNULL(LW.strStorageLocation, SL.strName)
		FROM tblLGLoad L
			--JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
			JOIN tblSCTicket TICKET
				ON L.intLoadId = TICKET.intLoadId
			JOIN tblLGLoadCost LC ON LC.intLoadId = L.intLoadId
			JOIN tblAPVendor ARC ON LC.intVendorId = ARC.[intEntityId]
			JOIN tblEMEntity EME ON ARC.[intEntityId] = EME.[intEntityId] AND ISNULL(LC.strEntityType, '') <> 'Customer'
			OUTER APPLY tblLGCompanyPreference CP			
			
			LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = LC.intItemUOMId
			LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IU.intUnitMeasureId
			LEFT JOIN tblSMCompanyLocation SMCL ON TICKET.intProcessingLocationId= SMCL.intCompanyLocationId
			LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = TICKET.intSubLocationId
			LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = TICKET.intStorageLocationId
			LEFT JOIN tblICItem ICI ON LC.intItemId = ICI.intItemId
			LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = LC.intCurrencyId
			LEFT JOIN vyuARGetItemAccount ARIA ON TICKET.[intItemId] = ARIA.[intItemId]
				AND TICKET.intProcessingLocationId= ARIA.[intLocationId]
			OUTER APPLY (SELECT TOP 1 W.intSubLocationId, W.intStorageLocationId, 
					strSubLocation = CLSL.strSubLocationName, strStorageLocation = SL.strName FROM tblLGLoadWarehouse W
					LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = W.intStorageLocationId
					LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = W.intSubLocationId
					WHERE intLoadId = L.intLoadId) LW
		GROUP BY L.[strLoadNumber],EME.[strName],L.intPurchaseSale,
				L.dtmScheduledDate,L.intLoadId,SMCL.[strLocationName],ICI.strItemNo,
				ICI.strDescription,
				TICKET.intItemUOMIdTo,
				ARC.[intCurrencyId],LC.intVendorId,
				TICKET.intProcessingLocationId,ICI.intItemId,				
				LC.dblRate,ARIA.[intAccountId],
				ARIA.[intCOGSAccountId],ARIA.[intSalesAccountId],ARIA.[intInventoryAccountId],
				LC.[intCurrencyId],LC.intItemUOMId, str1099Form, str1099Type,CU.strCurrency,UOM.strUnitMeasure,L.ysnPosted,LC.intLoadCostId,LC.strCostMethod
			,LC.ysnAccrue
			,LC.ysnPrice
			,LC.ysnMTM
			,LC.intBillId
			, TICKET.dblGrossWeight
			, TICKET.dblTareWeight
			, TICKET.dblNetUnits
			,ISNULL(LW.intSubLocationId, TICKET.intSubLocationId)
			,ISNULL(LW.intStorageLocationId, TICKET.intStorageLocationId)
			,ISNULL(LW.strSubLocation, CLSL.strSubLocationName)
			,ISNULL(LW.strStorageLocation, SL.strName)
		
		)LOAD_COST_FOR_VENDOR
				OUTER APPLY tblLGCompanyPreference LG_COMPANY_PREFERENCE
			JOIN tblLGLoad LG_LOAD ON LOAD_COST_FOR_VENDOR.intLoadId = LG_LOAD.intLoadId 
			--JOIN tblLGLoadDetail LOAD_DETAIL ON LG_LOAD.intLoadId = LOAD_DETAIL.intLoadId 
			JOIN tblSCTicket TICKET
				ON LG_LOAD.intLoadId = TICKET.intLoadId

			LEFT JOIN tblSMCurrency CC ON CC.intCurrencyID = LOAD_COST_FOR_VENDOR.intCurrencyId
			LEFT JOIN tblICItemLocation ItemLoc ON ItemLoc.intItemId = LOAD_COST_FOR_VENDOR.intItemId and ItemLoc.intLocationId = LOAD_COST_FOR_VENDOR.intCompanyLocationId
			LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LOAD_COST_FOR_VENDOR.intItemUOMId
			LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
			LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = LOAD_COST_FOR_VENDOR.intWeightItemUOMId
			LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
			LEFT JOIN tblICItemUOM ItemCostUOM ON ItemCostUOM.intItemUOMId = LOAD_COST_FOR_VENDOR.intPriceItemUOMId
			LEFT JOIN tblICUnitMeasure CostUOM ON CostUOM.intUnitMeasureId = ItemCostUOM.intUnitMeasureId
			INNER JOIN  (tblAPVendor D1 INNER JOIN tblEMEntity D2 ON D1.[intEntityId] = D2.intEntityId) ON LOAD_COST_FOR_VENDOR.[intEntityVendorId] = D1.[intEntityId]
			OUTER APPLY dbo.fnGetItemGLAccountAsTable(LOAD_COST_FOR_VENDOR.intItemId, ItemLoc.intItemLocationId, 'AP Clearing') itemAccnt
			LEFT JOIN dbo.tblGLAccount apClearing ON apClearing.intAccountId = itemAccnt.intAccountId
			OUTER APPLY (SELECT TOP 1 ysnCreateOtherCostPayable = ISNULL(ysnCreateOtherCostPayable, 0) FROM tblCTCompanyPreference) COC			
			/*	*/
			WHERE LOAD_COST_FOR_VENDOR.intLoadId = @LOAD_ID
				AND TICKET.intTicketId = @TICKET_ID
				--AND A.intLoadCostId = ISNULL(NULL, A.intLoadCostId)
				
				AND LOAD_COST_FOR_VENDOR.intLoadId NOT IN 
					(SELECT IsNull(BD.intLoadId, 0) FROM tblAPBillDetail BD JOIN tblICItem Item ON Item.intItemId = BD.intItemId
					WHERE BD.intItemId = LOAD_COST_FOR_VENDOR.intItemId AND Item.strType = 'Other Charge' AND ISNULL(LOAD_COST_FOR_VENDOR.ysnAccrue,0) = 1)
					/**/
				--AND NOT (COC.ysnCreateOtherCostPayable = 1 AND CTC.intContractCostId IS NOT NULL)


	SELECT * FROM @voucherPayable

	DECLARE @ERROR_MESSAGE NVARCHAR(1000)
	IF (@POST = 1)
	BEGIN
		EXEC uspAPUpdateVoucherPayableQty @voucherPayable, DEFAULT, 1, 1, @ERROR_MESSAGE OUTPUT
		
	END
	ELSE
	BEGIN
		EXEC uspAPRemoveVoucherPayable @voucherPayable, 1, @ERROR_MESSAGE OUTPUT
	END

	
	/*
	SELECT top 10 * FROM tblAPVoucherPayable ORDER by intVoucherPayableId DESC
	SELECT top 10  * FROM tblAPVoucherPayableCompleted ORDER BY intVoucherPayableId DESC
	DELETE FROM tblAPVoucherPayableCompleted WHERE intVoucherPayableId = 19136
	DELETE FROM tblAPVoucherPayable WHERE intVoucherPayableId = 28127
	*/

END
