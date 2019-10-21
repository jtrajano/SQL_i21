CREATE VIEW [dbo].[vyuCTGetINCOShipTerm]

AS 

		SELECT  CB.*,
				IB.strInsuranceBy,
				IT.strInvoiceType,
				PO.strPosition
	   FROM		tblCTContractBasis	 CB
  LEFT JOIN		tblCTInsuranceBy	 IB	ON  IB.intInsuranceById	    =   CB.intInsuranceById
  LEFT JOIN		tblCTInvoiceType	 IT ON  IT.intInvoiceTypeId	    =   CB.intInvoiceTypeId
  LEFT JOIN		tblCTPosition		 PO	ON  PO.intPositionId	    =   CB.intPositionId
