﻿CREATE FUNCTION [dbo].[fnAPGetPaymentDetailPayment]
(
    @paymentDetailId INT
)
RETURNS NUMERIC(18,6)
AS
BEGIN
    DECLARE @payment NUMERIC(18,6)
    SELECT @payment = 
        CASE WHEN B.intTransactionType = 3 OR B.intTransactionType = 2 OR B.intTransactionType = 8 --DEBIT MEMO
        THEN
            (CASE WHEN A.dblPayment < 0
                    THEN A.dblPayment
                    ELSE A.dblPayment * -1 
            END)
        ELSE
            (CASE WHEN (A.dblAmountDue = CAST(((A.dblPayment + A.dblDiscount) - A.dblInterest) AS DECIMAL(18,2))) --add discount only if fully paid
                    THEN A.dblPayment + A.dblDiscount - A.dblInterest
                    ELSE A.dblPayment 
            END)
        END
    FROM tblAPPaymentDetail A
    INNER JOIN tblAPBill B ON A.intBillId = B.intBillId
    WHERE A.intPaymentDetailId = @paymentDetailId

    RETURN @payment;
END