CREATE VIEW vyuLGLoadCostForVendor
AS 
SELECT [strTransactionType] = 'Load Schedule' COLLATE Latin1_General_CI_AS
	,[strTransactionNumber] = L.[strLoadNumber]
	,[strShippedItemId] = 'ld:' + CAST(LD.intLoadDetailId AS NVARCHAR(250)) COLLATE Latin1_General_CI_AS
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
	,LD.intLoadDetailId
	,L.[strLoadNumber]
	,[intContractHeaderId] = NULL --CH.intContractHeaderId
	,[strContractNumber] = NULL --CH.strContractNumber
	,[intContractDetailId] = NULL --CD.intContractDetailId
	,[intContractSeq] = NULL --CD.intContractSeq
	,[intCompanyLocationId] = CASE WHEN (L.intPurchaseSale = 2) THEN LD.intSCompanyLocationId ELSE LD.intPCompanyLocationId END
	,[strLocationName] = SMCL.[strLocationName]
	,[intItemId] = ICI.[intItemId]
	,[strItemNo] = ICI.[strItemNo]
	,[strItemDescription] = CASE 
		WHEN ISNULL(ICI.[strDescription], '') = ''
			THEN ICI.[strItemNo]
		ELSE ICI.[strDescription]
		END
	,[intShipmentItemUOMId] = LD.[intItemUOMId]
	,[dblPrice] = LC.dblRate
	,[dblShipmentUnitPrice] = LC.dblRate
	,[dblTotal] = SUM(LC.dblAmount)
	,[intAccountId] = ARIA.[intAccountId]
	,[intCOGSAccountId] = ARIA.[intCOGSAccountId]
	,[intSalesAccountId] = ARIA.[intSalesAccountId]
	,[intInventoryAccountId] = ARIA.[intInventoryAccountId]
	,[intItemUOMId] = dbo.fnGetMatchingItemUOMId(ICI.[intItemId], LD.intItemUOMId)
	,[intWeightItemUOMId] = dbo.fnGetMatchingItemUOMId(ICI.[intItemId], LD.intWeightItemUOMId)
	,[intPriceItemUOMId] = LC.intItemUOMId
	,[dblGross] = LD.dblGross
	,[dblTare] = LD.dblTare
	,[dblNet] = LD.dblNet
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
	,intSubLocationId = ISNULL(LW.intSubLocationId, CD.intSubLocationId)
	,intStorageLocationId = ISNULL(LW.intStorageLocationId, CD.intStorageLocationId)
	,strSubLocationName = ISNULL(LW.strSubLocation, CLSL.strSubLocationName)
	,strStorageLocationName = ISNULL(LW.strStorageLocation, SL.strName)
	,LC.dblFX
	,LC.ysnInventoryCost
	,L.dtmPostedDate
FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN tblLGLoadCost LC ON LC.intLoadId = L.intLoadId
	JOIN tblAPVendor ARC ON LC.intVendorId = ARC.[intEntityId]
	JOIN tblEMEntity EME ON ARC.[intEntityId] = EME.[intEntityId] AND ISNULL(LC.strEntityType, '') <> 'Customer'
	OUTER APPLY tblLGCompanyPreference CP
	LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE WHEN (CP.ysnEnableAccrualsForOutbound = 1 AND L.intPurchaseSale = 2 AND LC.ysnAccrue = 1 AND LC.intVendorId IS NOT NULL) 
																	THEN LD.intSContractDetailId ELSE LD.intPContractDetailId END
	LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = LC.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IU.intUnitMeasureId
	LEFT JOIN tblSMCompanyLocation SMCL ON LD.intPCompanyLocationId = SMCL.intCompanyLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = CD.intSubLocationId
	LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = CD.intStorageLocationId
	LEFT JOIN tblICItem ICI ON LC.intItemId = ICI.intItemId
	LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = LC.intCurrencyId
	LEFT JOIN vyuARGetItemAccount ARIA ON LD.[intItemId] = ARIA.[intItemId]
		AND LD.intPCompanyLocationId = ARIA.[intLocationId]
	OUTER APPLY (SELECT TOP 1 W.intSubLocationId, W.intStorageLocationId, 
			strSubLocation = CLSL.strSubLocationName, strStorageLocation = SL.strName FROM tblLGLoadWarehouse W
			LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = W.intStorageLocationId
			LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = W.intSubLocationId
			WHERE intLoadId = L.intLoadId) LW
GROUP BY L.[strLoadNumber],LD.intLoadDetailId,EME.[strName],L.intPurchaseSale,
		L.dtmScheduledDate,L.intLoadId,SMCL.[strLocationName],ICI.strItemNo,
		ICI.strDescription,
		LD.intItemUOMId,
		ARC.[intCurrencyId],LC.intVendorId,
		LD.intPCompanyLocationId,LD.intSCompanyLocationId,ICI.intItemId,
		LD.dblQuantity,
		LC.dblRate,LD.[intWeightItemUOMId],ARIA.[intAccountId],
		ARIA.[intCOGSAccountId],ARIA.[intSalesAccountId],ARIA.[intInventoryAccountId],
		LC.[intCurrencyId],LD.intItemUOMId,LC.intItemUOMId,LD.dblGross,LD.dblTare,
		LD.dblNet, str1099Form, str1099Type,CU.strCurrency,UOM.strUnitMeasure,L.ysnPosted,LC.intLoadCostId,LC.strCostMethod
	,LC.ysnAccrue
	,LC.ysnPrice
	,LC.ysnMTM
	,LC.intBillId
	,CH.intContractHeaderId,CH.strContractNumber
	,CD.intContractDetailId,CD.intContractSeq
	,ISNULL(LW.intSubLocationId, CD.intSubLocationId)
	,ISNULL(LW.intStorageLocationId, CD.intStorageLocationId)
	,ISNULL(LW.strSubLocation, CLSL.strSubLocationName)
	,ISNULL(LW.strStorageLocation, SL.strName)
	,LC.dblFX
	,LC.ysnInventoryCost
	,L.dtmPostedDate