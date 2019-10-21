CREATE PROCEDURE [dbo].[uspCTUpdateFinancialStatus]
	@id int,
	@type nvarchar(10)
AS
BEGIN
	-- Invoice
	IF lower(@type) = 'invoice'
	BEGIN
		UPDATE CD SET strFinancialStatus = FS.strFinancialStatus
		FROM tblARInvoiceDetail ID
		INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = ID.intContractDetailId
		CROSS APPLY dbo.fnCTGetFinancialStatus(ID.intContractDetailId) FS
		WHERE ID.intInvoiceId = @id
	END
	-- Voucher
END