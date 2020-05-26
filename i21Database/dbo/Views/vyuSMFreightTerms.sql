CREATE VIEW [dbo].[vyuSMFreightTerms]
	AS 

	SELECT  
		FT.intFreightTermId,
		FT.strFreightTerm,
		FT.strFobPoint,
		FT.ysnActive,
		FT.strContractBasis,
		FT.strDescription,
		FT.ysnDefault,
		FT.intInsuranceById,
		FT.intInvoiceTypeId,
		FT.intPositionId,
		FT.strINCOLocationType,
		FT.intConcurrencyId,
		FT.ysnInsuranceCertificateNoRequired,

		IB.strInsuranceBy,
		IT.strInvoiceType,
		PO.strPosition
	   FROM		tblSMFreightTerms	 FT
  LEFT JOIN		tblCTInsuranceBy	 IB	ON  IB.intInsuranceById	    =   FT.intInsuranceById
  LEFT JOIN		tblCTInvoiceType	 IT ON  IT.intInvoiceTypeId	    =   FT.intInvoiceTypeId
  LEFT JOIN		tblCTPosition		 PO	ON  PO.intPositionId	    =   FT.intPositionId