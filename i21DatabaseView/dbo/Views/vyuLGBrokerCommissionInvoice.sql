CREATE VIEW vyuLGBrokerCommissionInvoice ("Broker", "Broker No", "SO-No.", "Customer Name", "Customer-No", "Item Description", "Quantity(bags)", "Prov.Invoice", "Final Invoice", "Final net weight", "Broker Reference", "Rate", "Currency","Amount") AS 
SELECT  
	 BROKER_NAME "Broker"
	,BCCNO "Broker No"
	,POSO_NUMBER "SO-No."
	,CUST_VEN_NAME "Customer Name"
	,ACCNO "Customer-No"
	,ITEM_NAME "Item Description"
	,InvQty "Quantity(bags)"
	,PINV "Prov.Invoice"
	,INVOICE_NUMBER "Final Invoice"
	,dblNetWt "Final net weight"
	,BROKER_REFERENCE "Broker Reference"
	,CASE WHEN strCostMethod ='Percentage' THEN CAST(dblRate as nvarchar)+'%' WHEN strCostMethod ='Per Unit' THEN CAST(dblRate as nvarchar)+' '+Currency+'/'+strUnitMeasure ELSE 'NIL' END  "Rate"
	,CurrencyM "Currency"
	,Amount
FROM
	(SELECT '1' GBY
		,BV.strVendorAccountNum BCCNO 
		,EC.strName CUST_VEN_NAME
		,Item.strDescription ITEM_NAME
		,BC.strAccountNumber ACCNO
		,EB.strName BROKER_NAME
		,BrokerCost.strReference BROKER_REFERENCE
		,CH.strContractNumber+'-'+cast(CD.intContractSeq as nvarchar(10)) POSO_NUMBER
        ,ARQty.InvQty
		,AR.strInvoiceNumber INVOICE_NUMBER
		,CASE WHEN CR.ysnSubCurrency=1 THEN CRM.strCurrency ELSE CR.strCurrency END CurrencyM
        ,CR.strCurrency Currency
		,ARP.strInvoiceNumber PINV
		,cast(ARD.dblShipmentNetWt as nvarchar)+' '+UnitMeasure.strUnitMeasure dblNetWt
		,BrokerCost.dblRate
		,BrokerCost.strCostMethod
		,UnitMeasureB.strUnitMeasure
		,CASE WHEN CR.ysnSubCurrency=1 
		 THEN
			((ARD.dblShipmentNetWt*BrokerCost.dblRate)*dbo.fnCTConvertQtyToTargetItemUOM(ARD.intItemWeightUOMId,BrokerCost.intItemUOMId,1))/100 
		 ELSE
			(ARD.dblShipmentNetWt*BrokerCost.dblRate)*dbo.fnCTConvertQtyToTargetItemUOM(ARD.intItemWeightUOMId,BrokerCost.intItemUOMId,1) 
		 END Amount
		FROM tblCTContractDetail CD JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId AND CH.intContractTypeId=2
		JOIN tblCTContractCost BrokerCost ON CD.intContractDetailId = BrokerCost.intContractDetailId
		JOIN tblICItem Itemb ON BrokerCost.intItemId = Itemb.intItemId AND Itemb.strCostType='Commission' 
		JOIN tblARInvoiceDetail ARD ON CD.intContractDetailId = ARD.intContractDetailId
		JOIN tblARInvoice AR ON ARD.intInvoiceId = AR.intInvoiceId
		JOIN  (SELECT ROUND(SUM(ARD.dblQtyOrdered), 2) InvQty, ARD.intInvoiceId, ARD.intContractDetailId
		       FROM tblARInvoiceDetail ARD JOIN tblCTContractDetail CD ON ARD.intContractDetailId = CD.intContractDetailId 
			   GROUP BY ARD.intInvoiceId, ARD.intContractDetailId) ARQty ON CD.intContractDetailId = ARQty.intContractDetailId AND AR.intInvoiceId = ARQty.intInvoiceId
		JOIN tblEMEntity EB ON BrokerCost.intVendorId = EB.intEntityId 
		JOIN tblAPVendor BV ON BrokerCost.intVendorId = BV.intEntityId
		JOIN tblEMEntity EC ON CH.intEntityId = EC.intEntityId
		JOIN tblARCustomer BC ON EC.intEntityId = BC.intEntityId
		JOIN tblICItem Item ON CD.intItemId = Item.intItemId
		JOIN tblCTContractStatus CS ON CD.intContractStatusId = CS.intContractStatusId
		JOIN tblSMCurrency CR ON BrokerCost.intCurrencyId = CR.intCurrencyID
		LEFT JOIN tblSMCurrency CRM ON CR.intMainCurrencyId = CRM.intCurrencyID
		JOIN tblICItemUOM ItemUOM ON ARD.intItemWeightUOMId = ItemUOM.intItemUOMId
		JOIN tblICUnitMeasure UnitMeasure ON ItemUOM.intUnitMeasureId = UnitMeasure.intUnitMeasureId
		JOIN tblICItemUOM ItemUOMB ON BrokerCost.intItemUOMId = ItemUOMB.intItemUOMId
		JOIN tblICUnitMeasure UnitMeasureB ON ItemUOMB.intUnitMeasureId = UnitMeasureB.intUnitMeasureId
		LEFT JOIN (SELECT intInvoiceId,strInvoiceNumber FROM tblARInvoice WHERE ISNULL(ysnCancelled,0)=0 AND ISNULL(strType,'Standard')='Provisional')ARP ON AR.intOriginalInvoiceId = ARP.intInvoiceId
		WHERE CS.strContractStatus NOT IN ('Cancelled') AND BrokerCost.dblRate IS NOT NULL AND ISNULL(AR.ysnCancelled,0)=0 AND ISNULL(AR.strType,'Standard')='Standard'
     
	  UNION
	  /*********************Reversal part************************/
		SELECT '1' GBY
		,BV.strVendorAccountNum BCCNO 
		,EC.strName CUST_VEN_NAME
		,Item.strDescription ITEM_NAME
		,BC.strAccountNumber ACCNO
		,EB.strName BROKER_NAME
		,BrokerCost.strReference BROKER_REFERENCE
		,CH.strContractNumber+'-'+cast(CD.intContractSeq as nvarchar(10)) POSO_NUMBER
        ,ARQty.InvQty
		,AR.strInvoiceNumber INVOICE_NUMBER
		,CASE WHEN CR.ysnSubCurrency=1 THEN CRM.strCurrency ELSE CR.strCurrency END CurrencyM
		,CR.strCurrency Currency
		,ARP.strInvoiceNumber PINV
		,cast(ARD.dblShipmentNetWt as nvarchar)+' '+UnitMeasure.strUnitMeasure dblNetWt
		,BrokerCost.dblRate
		,BrokerCost.strCostMethod
		,UnitMeasureB.strUnitMeasure
		,CASE WHEN CR.ysnSubCurrency=1 
		 THEN
			-1*(((ARD.dblShipmentNetWt*BrokerCost.dblRate)*dbo.fnCTConvertQtyToTargetItemUOM(ARD.intItemWeightUOMId,BrokerCost.intItemUOMId,1))/100) 
		 ELSE
			-1*((ARD.dblShipmentNetWt*BrokerCost.dblRate)*dbo.fnCTConvertQtyToTargetItemUOM(ARD.intItemWeightUOMId,BrokerCost.intItemUOMId,1)) 
		 END Amount
		FROM tblCTContractDetail CD JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId AND CH.intContractTypeId=2
		JOIN tblCTContractCost BrokerCost ON CD.intContractDetailId = BrokerCost.intContractDetailId
		JOIN tblICItem Itemb ON BrokerCost.intItemId = Itemb.intItemId AND Itemb.strCostType='Commission' 
		JOIN tblARInvoiceDetail ARD ON CD.intContractDetailId = ARD.intContractDetailId
		JOIN tblARInvoice AR ON ARD.intInvoiceId = AR.intInvoiceId
		JOIN  (SELECT ROUND(SUM(ARD.dblQtyOrdered), 2) InvQty, ARD.intInvoiceId, ARD.intContractDetailId
		        FROM tblARInvoiceDetail ARD JOIN tblCTContractDetail CD ON ARD.intContractDetailId = CD.intContractDetailId 
				GROUP BY ARD.intInvoiceId, ARD.intContractDetailId) ARQty ON CD.intContractDetailId = ARQty.intContractDetailId AND AR.intInvoiceId = ARQty.intInvoiceId
		JOIN tblEMEntity EB ON BrokerCost.intVendorId = EB.intEntityId 
		JOIN tblAPVendor BV ON BrokerCost.intVendorId = BV.intEntityId
		JOIN tblEMEntity EC ON CH.intEntityId = EC.intEntityId
		JOIN tblARCustomer BC ON EC.intEntityId = BC.intEntityId
		JOIN tblICItem Item ON CD.intItemId = Item.intItemId
		JOIN tblCTContractStatus CS ON CD.intContractStatusId = CS.intContractStatusId
		JOIN tblSMCurrency CR ON BrokerCost.intCurrencyId = CR.intCurrencyID
		LEFT JOIN tblSMCurrency CRM ON CR.intMainCurrencyId = CRM.intCurrencyID
		JOIN tblICItemUOM ItemUOM ON ARD.intItemWeightUOMId = ItemUOM.intItemUOMId
		JOIN tblICUnitMeasure UnitMeasure ON ItemUOM.intUnitMeasureId = UnitMeasure.intUnitMeasureId
		JOIN tblICItemUOM ItemUOMB ON BrokerCost.intItemUOMId = ItemUOMB.intItemUOMId
		JOIN tblICUnitMeasure UnitMeasureB ON ItemUOMB.intUnitMeasureId = UnitMeasureB.intUnitMeasureId
		LEFT JOIN (SELECT intInvoiceId,strInvoiceNumber FROM tblARInvoice WHERE ISNULL(ysnCancelled,0)=0 AND ISNULL(strType,'Standard')='Provisional')ARP ON AR.intOriginalInvoiceId = ARP.intInvoiceId
		WHERE CS.strContractStatus NOT IN ('Cancelled') AND BrokerCost.dblRate IS NOT NULL AND strTransactionType='Credit Note' AND ISNULL(AR.strType,'Standard')='Standard')a;