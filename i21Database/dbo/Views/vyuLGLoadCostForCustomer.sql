CREATE VIEW vyuLGLoadCostForCustomer
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
	,intPriceItemUOMId
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
		,[intCurrencyId] = ISNULL(ISNULL(LC.[intCurrencyId], ARC.[intCurrencyId]), (
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
		,[intShipmentItemUOMId] = LC.intItemUOMId
		,[dblPrice] = Sum(LC.dblAmount)
		,[dblShipmentUnitPrice] = Sum(LC.dblAmount)
		,[dblTotal] = Sum(LC.dblAmount)
		,[intPriceItemUOMId] = LC.intItemUOMId
		,[intAccountId] = ARIA.[intAccountId]
		,[intCOGSAccountId] = ARIA.[intCOGSAccountId]
		,[intSalesAccountId] = ARIA.[intSalesAccountId]
		,[intInventoryAccountId] = ARIA.[intInventoryAccountId]
		,[ysnPosted] = L.ysnPosted
	FROM tblLGLoad L
	JOIN tblLGLoadCost LC ON LC.intLoadId = L.intLoadId AND strEntityType = 'Customer'
	JOIN tblARCustomer ARC ON LC.intVendorId = ARC.[intEntityId]
	JOIN tblEMEntity EME ON ARC.[intEntityId] = EME.[intEntityId]
	JOIN tblEMEntityType EMT ON EMT.intEntityId = EME.intEntityId AND EMT.strType = 'Customer'
	LEFT JOIN [tblSMCompanyLocation] SMCL ON SMCL.[intCompanyLocationId] = (
			SELECT TOP 1 LD.intSCompanyLocationId
			FROM tblLGLoadDetail LD
			WHERE LD.intLoadId = L.intLoadId
			)
	LEFT JOIN tblICItem ICI ON LC.intItemId = ICI.intItemId
	LEFT JOIN vyuARGetItemAccount ARIA ON LC.intItemId = ARIA.[intItemId]
		AND SMCL.intCompanyLocationId = ARIA.[intLocationId]
	GROUP BY L.[strLoadNumber]
		,EME.[strName]
		,L.dtmScheduledDate
		,L.intLoadId
		,SMCL.[strLocationName]
		,ICI.strItemNo
		,ICI.strDescription
		,ARC.[intCurrencyId]
		,ARC.[intSalespersonId]
		,ICI.intItemId
		,LC.dblRate
		,ARIA.[intAccountId]
		,ARIA.[intCOGSAccountId]
		,ARIA.[intSalesAccountId]
		,ARIA.[intInventoryAccountId]
		,LC.[intCurrencyId]
		,L.ysnPosted
		,ARC.intEntityId
		,SMCL.intCompanyLocationId
		,LC.intItemUOMId
		,LC.intItemUOMId
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
	,intPriceItemUOMId