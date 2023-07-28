--liquibase formatted sql

-- changeset Von:fnARGetInvoiceAmountMultiplier.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnARGetInvoiceAmountMultiplier]
(
	@TransactionType	NVARCHAR(25)
)
RETURNS NUMERIC(18,6)
AS
BEGIN
	
	IF @TransactionType IN ('Credit Memo', 'Overpayment', 'Credit', 'Customer Prepayment')
		RETURN -1.000000
	
	RETURN 1.000000
END



