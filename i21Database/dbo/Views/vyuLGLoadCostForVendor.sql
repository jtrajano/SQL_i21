CREATE VIEW vyuLGLoadCostForVendor
AS 
	  SELECT [strTransactionType] = 'Load Schedule'
			,[strTransactionNumber] = L.[strLoadNumber]
			,[strShippedItemId] = 'ld:' + CAST(LD.intLoadDetailId AS NVARCHAR(250))
			,[intEntityVendorId] = LC.intVendorId
			,[strCustomerName] = EME.[strName]
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
			,[intContractHeaderId] = NULL --ISNULL(CH.[intContractHeaderId], CD.[intContractHeaderId])
			,[strContractNumber] = NULL --CH.strContractNumber
			,[intContractDetailId] = NULL --ISNULL(CD.[intContractDetailId], LD.[intPContractDetailId])
			,[intContractSeq] = NULL --CD.[intContractSeq]
			,[intCompanyLocationId] = LD.intSCompanyLocationId
			,[strLocationName] = SMCL.[strLocationName]
			,[intItemId] = ICI.[intItemId]
			,[strItemNo] = ICI.[strItemNo]
			,[strItemDescription] = CASE 
				WHEN ISNULL(ICI.[strDescription], '') = ''
					THEN ICI.[strItemNo]
				ELSE ICI.[strDescription]
				END
			,[intShipmentItemUOMId] = LD.[intItemUOMId]
			,[dblPrice] = SUM(LC.dblAmount)
			,[dblShipmentUnitPrice] = LC.dblRate
			,[dblTotal] = SUM(LC.dblAmount)
			,[intAccountId] = ARIA.[intAccountId]
			,[intCOGSAccountId] = ARIA.[intCOGSAccountId]
			,[intSalesAccountId] = ARIA.[intSalesAccountId]
			,[intInventoryAccountId] = ARIA.[intInventoryAccountId]
			,[intItemUOMId] = LD.intItemUOMId
			,[intWeightItemUOMId] = LD.intWeightItemUOMId
			,[intPriceItemUOMId] = LC.intItemUOMId
			,[dblGross] = LD.dblGross
			,[dblTare] = LD.dblTare
			,[dblNet] = LD.dblNet
			,EME.str1099Form
			,EME.str1099Type
			,CU.strCurrency
			,[strPriceUOM] = UOM.strUnitMeasure
			,[ysnPosted] = L.ysnPosted
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN tblLGLoadCost LC ON LC.intLoadId = L.intLoadId
	JOIN tblAPVendor ARC ON LC.intVendorId = ARC.[intEntityId]
	JOIN tblEMEntity EME ON ARC.[intEntityId] = EME.[intEntityId]
	LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = LC.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IU.intUnitMeasureId
	LEFT JOIN [tblSMCompanyLocation] SMCL ON LD.intSCompanyLocationId = SMCL.[intCompanyLocationId]
	LEFT JOIN tblICItem ICI ON LC.intItemId = ICI.intItemId
	LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = LC.intCurrencyId
	LEFT JOIN vyuARGetItemAccount ARIA ON LD.[intItemId] = ARIA.[intItemId]
		AND LD.intSCompanyLocationId = ARIA.[intLocationId]
	LEFT JOIN tblARInvoiceDetail ARID ON LD.intLoadDetailId = ARID.[intInventoryShipmentItemId]
		GROUP BY L.[strLoadNumber],LD.intLoadDetailId,EME.[strName],
			 L.dtmScheduledDate,L.intLoadId,SMCL.[strLocationName],ICI.strItemNo,
			 ICI.strDescription,
			 LD.intPContractDetailId,LD.intItemUOMId,
			 ARC.[intCurrencyId],LC.intVendorId,
			 LD.intSCompanyLocationId,ICI.intItemId,
			 LD.dblQuantity,
			 LC.dblRate,LD.[intWeightItemUOMId],ARIA.[intAccountId],
			 ARIA.[intCOGSAccountId],ARIA.[intSalesAccountId],ARIA.[intInventoryAccountId],
			 LC.[intCurrencyId],LD.intItemUOMId,LC.intItemUOMId,LD.dblGross,LD.dblTare,
			 LD.dblNet, str1099Form, str1099Type,CU.strCurrency,UOM.strUnitMeasure,L.ysnPosted