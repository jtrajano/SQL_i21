GO
	PRINT('CT - 1920_FinancialStatus Started')

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblCTContractDetail WHERE strFinancialStatus <> '')
	BEGIN

		UPDATE CD SET strFinancialStatus = FS.strFinancialStatus
		FROM tblARInvoiceDetail ID
		INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = ID.intContractDetailId
		CROSS APPLY dbo.fnCTGetFinancialStatus(ID.intContractDetailId) FS

	END

	PRINT('CT - 1920_FinancialStatus End')
GO

