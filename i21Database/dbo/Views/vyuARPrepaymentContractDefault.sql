﻿CREATE VIEW [dbo].[vyuARPrepaymentContractDefault]
AS

SELECT 
	 [intContractHeaderId]		= CustCon.[intContractHeaderId]
	,[intContractDetailId]		= CustCon.[intContractDetailId]	
	,[strContractNumber]		= CustCon.[strContractNumber]
	,[intContractSeq]			= CustCon.[intContractSeq]
	,[strContractType]			= CustCon.[strContractType]
	,[dtmStartDate]				= CustCon.[dtmStartDate]
	,[dtmEndDate]				= CustCon.[dtmEndDate]
	,[dtmDueDate]				= dbo.fnGetDueDateBasedOnTerm(CAST(CustCon.[dtmStartDate] AS DATE), CustCon.[intTermId])
	,[strContractStatus]		= CustCon.[strContractStatus]
	,[intEntityCustomerId]		= CustCon.[intEntityCustomerId]
	,[strCustomerName]			= ARC.[strName]
	,[intCurrencyId]			= CustCon.[intCurrencyId]
	,[strCurrency]				= CustCon.[strSubCurrency]
	,[intCompanyLocationId]		= CustCon.[intCompanyLocationId]
	,[strCompanyLocationName]	= DLOC.[strLocationName]
	,[intItemId]				= CustCon.[intItemId]
	,[strItemNo]				= CustCon.[strItemNo]
	,[strItemDescription]		= CustCon.[strItemDescription]
	,[intOrderUOMId]			= CustCon.[intOrderUOMId]
	,[strOrderUnitMeasure]		= CustCon.[strOrderUnitMeasure]
	,[intItemUOMId]				= CustCon.[intItemUOMId]
	,[strUnitMeasure]			= CustCon.[strUnitMeasure]
	,[intPricingTypeId]			= CustCon.[intPricingTypeId]
	,[strPricingType]			= CustCon.[strPricingType]	
	,[dblOrderPrice]			= CustCon.[dblOrderPrice]	
	,[dblCashPrice]				= CustCon.[dblCashPrice]
	,[intSubCurrencyId]			= CustCon.[intSubCurrencyId]
	,[dblSubCurrencyRate]		= CustCon.[dblSubCurrencyRate]
	,[strSubCurrency]			= CustCon.[strSubCurrency]
	,[intPriceItemUOMId]		= CustCon.[intPriceItemUOMId]
	,[dblBalance]				= CustCon.[dblBalance]
	,[dblScheduleQty]			= ISNULL(CustCon.[dblScheduleQty], 0.000000)
	,[dblAvailableQty]			= CustCon.[dblAvailableQty]
	,[dblDetailQuantity]		= CustCon.[dblDetailQuantity]
	,[dblOrderQuantity]			= CustCon.[dblOrderQuantity]
	,[dblShipQuantity]			= CustCon.[dblShipQuantity]	
	,[ysnUnlimitedQuantity]		= CustCon.[ysnUnlimitedQuantity]
	,[ysnLoad]					= CustCon.[ysnLoad]
	,[ysnAllowedToShow]			= CustCon.[ysnAllowedToShow]
	,[intFreightTermId]			= CustCon.[intFreightTermId]
	,[intTermId]				= CustCon.[intTermId]
	,[strTerm]					= SMT.[strTerm]
	,[intShipViaId]				= CustCon.[intShipViaId]
	,[intBillToId]				= ARC.[intBillToId]
	,[intShipToId]				= ARC.[intShipToId]
	,[intEntityContactId]		= ARC.[intEntityContactId]
	,[strShipToLocationName]	= ARC.[strShipToLocationName]
    ,[strShipToAddress]			= ARC.[strShipToAddress]
    ,[strShipToCity]			= ARC.[strShipToCity]
    ,[strShipToState]			= ARC.[strShipToState]
    ,[strShipToZipCode]			= ARC.[strShipToZipCode]
    ,[strShipToCountry]			= ARC.[strShipToCountry]
    ,[strBillToLocationName]	= ARC.[strBillToLocationName]
    ,[strBillToAddress]			= ARC.[strBillToAddress]
    ,[strBillToCity]			= ARC.[strBillToCity]
    ,[strBillToState]			= ARC.[strBillToState]
    ,[strBillToZipCode]			= ARC.[strBillToZipCode]
    ,[strBillToCountry]			= ARC.[strBillToCountry]
	,[intDestinationGradeId]	= CustCon.[intDestinationGradeId]
	,[strDestinationGrade]		= CustCon.[strDestinationGrade]
	,[intDestinationWeightId]	= CustCon.[intDestinationWeightId]
	,[strDestinationWeight]		= CustCon.[strDestinationWeight]

FROM [vyuCTCustomerContract] CustCon
INNER JOIN [vyuARCustomerSearch] ARC ON CustCon.intEntityCustomerId = ARC.[intEntityId]
LEFT OUTER JOIN tblSMTerm SMT ON CustCon.[intTermId] = SMT.[intTermID]
left join (select intCompanyLocationId, strLocationName from tblSMCompanyLocation)
	DLOC on CustCon.intCompanyLocationId = DLOC.intCompanyLocationId
WHERE CustCon.intCurrencyId = (SELECT TOP 1 ISNULL(SMC.intMainCurrencyId, SMC.intCurrencyID) [intCurrencyID]
								FROM tblCTContractDetail CTD 
									INNER JOIN tblSMCurrency SMC
								ON CTD.intCurrencyId IN (SMC.intCurrencyID, SMC.intMainCurrencyId )
								WHERE CustCon.intContractHeaderId = CTD.intContractHeaderId 				
								ORDER BY intContractSeq ASC) 
AND strContractStatus NOT IN ('Complete','Cancelled')