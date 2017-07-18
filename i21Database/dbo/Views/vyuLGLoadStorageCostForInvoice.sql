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
		,[strShippedItemId] = NULL
		,[intEntityCustomerId] = ARC.intEntityId
		,[strCustomerName] = EME.[strName]
		,[intCurrencyId] = ISNULL(ISNULL(LSC.[intCurrency], ARC.[intCurrencyId]), (
				SELECT TOP 1 intDefaultCurrencyId
				FROM tblSMCompanyPreference
				WHERE intDefaultCurrencyId IS NOT NULL
					AND intDefaultCurrencyId <> 0
				))
		,[dtmProcessDate] = L.dtmScheduledDate
		,L.intLoadId
		,intLoadDetailId = NULL
		,L.[strLoadNumber]
		,[intContractHeaderId] = NULL
		,[strContractNumber] = NULL
		,[intContractDetailId] = NULL
		,[intContractSeq] = NULL
		,[intCompanyLocationId] = SMCL.intCompanyLocationId
		,[strLocationName] = SMCL.[strLocationName]
		,[intItemId] = ICI.[intItemId]
		,[strItemNo] = ICI.[strItemNo]
		,[strItemDescription] = CASE 
			WHEN ISNULL(ICI.[strDescription], '') = ''
				THEN ICI.[strItemNo]
			ELSE ICI.[strDescription]
			END
		,[intShipmentItemUOMId] = NULL
		,[dblPrice] = (Sum(LSC.dblAmount))
		,[dblShipmentUnitPrice] = (Sum(LSC.dblAmount))
		,[dblTotal] = (Sum(LSC.dblAmount))
		,[intAccountId] = ARIA.[intAccountId]
		,[intCOGSAccountId] = ARIA.[intCOGSAccountId]
		,[intSalesAccountId] = ARIA.[intSalesAccountId]
		,[intInventoryAccountId] = ARIA.[intInventoryAccountId]
		,[ysnPosted] = L.ysnPosted
	FROM tblLGLoad L
	JOIN tblLGLoadStorageCost LSC ON LSC.intLoadId = L.intLoadId
	JOIN tblLGLoadDetailLot LDL ON LSC.intLoadDetailLotId = LDL.intLoadDetailLotId
	JOIN tblICLot LOT ON LOT.intLotId = LDL.intLotId
	JOIN tblARCustomer ARC ON ARC.[intEntityId] = (
			SELECT TOP 1 LD.intCustomerEntityId
			FROM tblLGLoadDetail LD
			WHERE LD.intLoadId = L.intLoadId
			)
	JOIN tblEMEntity EME ON ARC.[intEntityId] = EME.[intEntityId]
	LEFT JOIN [tblSMCompanyLocation] SMCL ON SMCL.[intCompanyLocationId] = (
			SELECT TOP 1 LD.intSCompanyLocationId
			FROM tblLGLoadDetail LD
			WHERE LD.intLoadId = L.intLoadId
			)
	LEFT JOIN tblICItem ICI ON LSC.intCostType = ICI.intItemId
	LEFT JOIN vyuARGetItemAccount ARIA ON LOT.[intItemId] = ARIA.[intItemId]
		AND SMCL.intCompanyLocationId = ARIA.[intLocationId]
	WHERE ISNULL(LSC.dblAmount, 0) > 0
	GROUP BY L.[strLoadNumber]
		,EME.[strName]
		,LSC.intCurrency
		,L.dtmScheduledDate
		,L.intLoadId
		,SMCL.[strLocationName]
		,ICI.strItemNo
		,ICI.strDescription
		,ARC.[intCurrencyId]
		,ARC.[intSalespersonId]
		,ICI.intItemId
		,LSC.dblPrice
		,ARIA.[intAccountId]
		,ARIA.[intCOGSAccountId]
		,ARIA.[intSalesAccountId]
		,ARIA.[intInventoryAccountId]
		,LSC.[intCurrency]
		,L.ysnPosted
		,ARC.intEntityId
		,SMCL.intCompanyLocationId
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
