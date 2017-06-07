CREATE VIEW vyuLGLoadStorageCostForInvoice
AS
SELECT strTransactionType
	,strTransactionNumber
	,NULL AS strShippedItemId
	,intEntityCustomerId
	,strCustomerName
	,intCurrencyId
	,dtmProcessDate
	,intLoadId
	,NULL AS intLoadDetailId
	,strLoadNumber
	,NULL AS intContractHeaderId
	,'' COLLATE Latin1_General_CI_AS AS strContractNumber
	,NULL AS intContractDetailId
	,NULL AS intContractSeq
	,intCompanyLocationId
	,strLocationName
	,intItemId
	,strItemNo
	,strItemDescription
	,NULL AS intShipmentItemUOMId
	,SUM(dblPrice) AS dblPrice
	,SUM(dblShipmentUnitPrice) AS dblShipmentUnitPrice
	,SUM(dblTotal) AS dblTotal
	,intAccountId
	,intCOGSAccountId
	,intSalesAccountId
	,intInventoryAccountId
	,ysnPosted
FROM (
	SELECT [strTransactionType] = 'Load Schedule'
		,[strTransactionNumber] = L.[strLoadNumber]
		,[strShippedItemId] = 'ld:' + CAST(LD.intLoadDetailId AS NVARCHAR(250))
		,[intEntityCustomerId] = LD.intCustomerEntityId
		,[strCustomerName] = EME.[strName]
		,[intCurrencyId] = ISNULL(ISNULL(LSC.[intCurrency], ARC.[intCurrencyId]), (
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
		,[intShipmentItemUOMId] = LD.[intItemUOMId]
		,[dblPrice] = (
			Sum(LSC.dblAmount) / (
				SELECT SUM(dblNet)
				FROM tblLGLoadDetail D
				WHERE L.intLoadId = D.intLoadId
				) * SUM(LD.dblNet)
			)
		,[dblShipmentUnitPrice] = (
			Sum(LSC.dblAmount) / (
				SELECT SUM(dblNet)
				FROM tblLGLoadDetail D
				WHERE L.intLoadId = D.intLoadId
				) * SUM(LD.dblNet)
			)
		,[dblTotal] = (
			Sum(LSC.dblAmount) / (
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
	JOIN tblLGLoadStorageCost LSC ON LSC.intLoadId = L.intLoadId
	JOIN tblLGLoadDetailLot LDL ON LSC.intLoadDetailLotId = LDL.intLoadDetailLotId
	JOIN tblICLot LOT ON LOT.intLotId = LDL.intLotId
	JOIN tblARCustomer ARC ON LD.intCustomerEntityId = ARC.[intEntityId]
	JOIN tblEMEntity EME ON ARC.[intEntityId] = EME.[intEntityId]
	LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intSContractDetailId
	LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN [tblSMCompanyLocation] SMCL ON LD.intSCompanyLocationId = SMCL.[intCompanyLocationId]
	LEFT JOIN tblICItem ICI ON LSC.intCostType = ICI.intItemId
	LEFT JOIN vyuARGetItemAccount ARIA ON LD.[intItemId] = ARIA.[intItemId]
		AND LD.intSCompanyLocationId = ARIA.[intLocationId]
	LEFT JOIN tblARInvoiceDetail ARID ON LD.intLoadDetailId = ARID.[intInventoryShipmentItemId]
	WHERE ISNULL(LSC.dblAmount,0) > 0
	GROUP BY L.[strLoadNumber]
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
		,LSC.dblPrice
		,LD.[intWeightItemUOMId]
		,ARIA.[intAccountId]
		,ARIA.[intCOGSAccountId]
		,ARIA.[intSalesAccountId]
		,ARIA.[intInventoryAccountId]
		,LSC.[intCurrency]
		,L.ysnPosted
	) tbl
GROUP BY strTransactionType
	,strTransactionNumber
	,intEntityCustomerId
	,strCustomerName
	,intCurrencyId
	,dtmProcessDate
	,intLoadId
	,strLoadNumber
	,intCompanyLocationId
	,strLocationName
	,intItemId
	,strItemNo
	,strItemDescription
	,intAccountId
	,intCOGSAccountId
	,intSalesAccountId
	,intInventoryAccountId
	,ysnPosted