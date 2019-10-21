CREATE VIEW [dbo].[vyuCTContractInvoice]
AS	

SELECT		CI.intContractInvoiceId,
			CI.intContractDetailId,	
			CI.strInvoiceNumber,		
			CI.dtmDate,				
			CI.strDescription,		
			CI.intCurrencyId,			
			CI.dblAmount,				
			CI.strCounterParty,		
			CI.strRemark,				
			CI.intConcurrencyId,
			C.strCurrency

FROM		tblCTContractInvoice	CI	
LEFT JOIN	tblSMCurrency			C		ON		C.intCurrencyID = CI.intCurrencyId
