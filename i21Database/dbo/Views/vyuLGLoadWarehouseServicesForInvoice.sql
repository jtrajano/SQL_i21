CREATE VIEW vyuLGLoadWarehouseServicesForInvoice
AS 
SELECT * FROM (
	SELECT [strTransactionType] = 'Load Schedule'
		,[strTransactionNumber] = L.[strLoadNumber]
		,[strShippedItemId] = 'ld:' + CAST(LD.intLoadDetailId AS NVARCHAR(250))
		,[intEntityCustomerId] = LD.intCustomerEntityId
		,[strCustomerName] = EME.[strName]
		,[intCurrencyId] = ISNULL(ISNULL(CD.[intCurrencyId], ARC.[intCurrencyId]), (
				SELECT TOP 1 intDefaultCurrencyId
				FROM tblSMCompanyPreference
				WHERE intDefaultCurrencyId IS NOT NULL
					AND intDefaultCurrencyId <> 0
				))
		,[dtmProcessDate] = L.dtmScheduledDate
		,L.intLoadId
		,LD.intLoadDetailId
		,L.[strLoadNumber]
		,[intContractHeaderId] = ISNULL(CH.[intContractHeaderId], CD.[intContractHeaderId])
		,[strContractNumber] = CH.strContractNumber
		,[intContractDetailId] = ISNULL(CD.[intContractDetailId], LD.[intPContractDetailId])
		,[intContractSeq] = CD.[intContractSeq]
		,[intCompanyLocationId] = LD.intSCompanyLocationId
		,[strLocationName] = SMCL.[strLocationName]
		,[intItemId] = ICI.[intItemId]
		,[strItemNo] = ICI.[strItemNo]
		,[strItemDescription] = CASE 
			WHEN ISNULL(ICI.[strDescription], '') = ''
				THEN ICI.[strItemNo]
			ELSE ICI.[strDescription]
			END
		,[intShipmentItemUOMId] = NULL
		,[dblPrice] = (
			Sum(LWS.dblBillAmount) / (
				SELECT SUM(dblNet)
				FROM tblLGLoadDetail D
				WHERE L.intLoadId = D.intLoadId
				) * SUM(LD.dblNet)
			)
		,[dblShipmentUnitPrice] = (
			Sum(LWS.dblBillAmount) / (
				SELECT SUM(dblNet)
				FROM tblLGLoadDetail D
				WHERE L.intLoadId = D.intLoadId
				) * SUM(LD.dblNet)
			)
		,[dblTotal] = (
			Sum(LWS.dblBillAmount) / (
				SELECT SUM(dblNet)
				FROM tblLGLoadDetail D
				WHERE L.intLoadId = D.intLoadId
				) * SUM(LD.dblNet)
			)
		,[intAccountId] = ARIA.[intAccountId]
		,[intCOGSAccountId] = ARIA.[intCOGSAccountId]
		,[intSalesAccountId] = ARIA.[intSalesAccountId]
		,[intInventoryAccountId] = ARIA.[intInventoryAccountId]
		,[ysnPosted] = L.ysnPosted
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN tblARCustomer ARC ON LD.intCustomerEntityId = ARC.intEntityCustomerId
	JOIN tblEMEntity EME ON ARC.[intEntityCustomerId] = EME.[intEntityId]
	LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
	LEFT JOIN tblLGLoadWarehouseServices LWS ON LWS.intLoadWarehouseId = LW.intLoadWarehouseId
	LEFT JOIN tblICItem ICI ON LWS.intItemId = ICI.intItemId
	LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intSContractDetailId
	LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN vyuARGetItemAccount ARIA ON LD.[intItemId] = ARIA.[intItemId]
		AND LD.intSCompanyLocationId = ARIA.[intLocationId]
	LEFT JOIN tblARInvoiceDetail ARID ON LD.intLoadDetailId = ARID.[intInventoryShipmentItemId]
	LEFT JOIN [tblSMCompanyLocation] SMCL ON LD.intSCompanyLocationId = SMCL.[intCompanyLocationId]
	GROUP BY LWS.intLoadWarehouseServicesId
		,L.[strLoadNumber]
		,LD.intLoadDetailId
		,EME.[strName]
		,CD.intCurrencyId
		,L.dtmScheduledDate
		,L.intLoadId
		,SMCL.[strLocationName]
		,ICI.strItemNo
		,ICI.strDescription
		,CD.intContractHeaderId
		,CH.strContractNumber
		,LD.intPContractDetailId
		,CD.intContractSeq
		,LD.intItemUOMId
		,ARC.[intCurrencyId]
		,ARC.[intSalespersonId]
		,LD.intCustomerEntityId
		,LD.intSCompanyLocationId
		,CH.intTermId
		,CD.intFreightTermId
		,CD.intShipViaId
		,ICI.intItemId
		,CD.intItemUOMId
		,CD.dblQuantity
		,LD.dblQuantity
		,CH.intContractHeaderId
		,CD.intContractDetailId
		,CD.dblCashPrice
		,LD.[intWeightItemUOMId]
		,ARIA.[intAccountId]
		,ARIA.[intCOGSAccountId]
		,ARIA.[intSalesAccountId]
		,ARIA.[intInventoryAccountId]
		,L.ysnPosted
		,LWS.dblUnitRate
	) tbl
WHERE dblTotal > 0