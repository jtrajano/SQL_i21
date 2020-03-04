CREATE VIEW [dbo].[vyuCTGetINCOShipTerm]

AS 

SELECT 
				intContractBasisId = CB.intFreightTermId,
				strContractBasis = CB.strFreightTerm,
				CB.strDescription,
				CB.ysnDefault,
				CB.intInsuranceById,
				CB.intInvoiceTypeId,
				CB.intPositionId,
				CB.intConcurrencyId,
				CB.strINCOLocationType,
				CB.ysnActive,
				IB.strInsuranceBy,
				IT.strInvoiceType,
				PO.strPosition
	   FROM		tblSMFreightTerms	 CB
  LEFT JOIN		tblCTInsuranceBy	 IB	ON  IB.intInsuranceById	    =   CB.intInsuranceById
  LEFT JOIN		tblCTInvoiceType	 IT ON  IT.intInvoiceTypeId	    =   CB.intInvoiceTypeId
  LEFT JOIN		tblCTPosition		 PO	ON  PO.intPositionId	    =   CB.intPositionId
