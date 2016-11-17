CREATE VIEW [dbo].[vyuARPrepaymentContractDefault]
AS

SELECT 
	 CustCon.[intContractHeaderId]	
	,CustCon.[intContractDetailId]	
	,CustCon.[strContractNumber]	
	,CustCon.[intContractSeq]		
	,CustCon.[strContractType]		
	,CustCon.[dtmStartDate]			
	,CustCon.[dtmEndDate]			
	,CustCon.[strContractStatus]	
	,CustCon.[intEntityCustomerId]	
	,CustCon.[intCurrencyId]		
	,CustCon.[intCompanyLocationId]	
	,CustCon.[intItemId]			
	,CustCon.[strItemNo]			
	,CustCon.[strItemDescription]	
	,CustCon.[intOrderUOMId]		
	,CustCon.[strOrderUnitMeasure]	
	,CustCon.[intItemUOMId]			
	,CustCon.[strUnitMeasure]		
	,CustCon.[intPricingTypeId]		
	,CustCon.[strPricingType]		
	,CustCon.[dblOrderPrice]		
	,CustCon.[dblCashPrice]			
	,CustCon.[intSubCurrencyId]		
	,CustCon.[dblSubCurrencyRate]	
	,CustCon.[strSubCurrency]		
	,CustCon.[intPriceItemUOMId]	
	,CustCon.[dblBalance]			
	,CustCon.[dblScheduleQty]		
	,CustCon.[dblAvailableQty]		
	,CustCon.[dblDetailQuantity]	
	,CustCon.[dblOrderQuantity]		
	,CustCon.[dblShipQuantity]		
	,CustCon.[ysnUnlimitedQuantity]	
	,CustCon.[ysnLoad]				
	,CustCon.[ysnAllowedToShow]		
	,CustCon.[intFreightTermId]		
	,CustCon.[intTermId]			
	,CustCon.[intShipViaId]			
	,ARC.intBillToId
	,ARC.intShipToId
	,ARC.intEntityContactId
FROM [vyuARCustomerContract] CustCon
INNER JOIN [vyuARCustomerSearch] ARC ON CustCon.intEntityCustomerId = ARC.intEntityCustomerId
WHERE CustCon.intCurrencyId = (SELECT TOP 1 intCurrencyId 
								FROM tblCTContractDetail CTD 
									INNER JOIN tblSMCurrency SMC
								ON CTD.intCurrencyId IN (SMC.intCurrencyID, SMC.intMainCurrencyId )
								WHERE CustCon.intContractHeaderId = CTD.intContractHeaderId 				
								ORDER BY intContractSeq ASC) 
