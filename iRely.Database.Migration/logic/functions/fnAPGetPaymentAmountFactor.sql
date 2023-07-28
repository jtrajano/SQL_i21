--liquibase formatted sql

-- changeset Von:fnAPGetPaymentAmountFactor.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

/**
    This will compute the payment of voucher line detail
    Ex. 
    voucher line 1 = 50 (payment would be 25)
    voucher line 2 = 10 (payment would be 5) 
    voucher total = 60
    voucher payment = 30
*/
CREATE OR ALTER FUNCTION [dbo].[fnAPGetPaymentAmountFactor]
(
    @amount DECIMAL(18,6),
    @totalPayment DECIMAL (18,6),
    @totalAmount DECIMAL(18, 6)
)
RETURNS DECIMAL(18,6)
AS
BEGIN

    DECLARE @paymentFactor DECIMAL(18,6);

    SET @paymentFactor = @amount / @totalAmount * @totalPayment

    RETURN @paymentFactor;

END



