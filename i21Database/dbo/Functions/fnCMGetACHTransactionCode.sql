CREATE FUNCTION [dbo].[fnCMGetACHTransactionCode]
(
	@strTransactionId NVARCHAR(30)

)
RETURNS NVARCHAR(1)
AS
BEGIN
	-- Declare the return variable here
DECLARE @Code NVARCHAR(1)
DECLARE @ysnVoid BIT
DECLARE @prefix NVARCHAR(10)

SELECT @prefix=SUBSTRING(@strTransactionId,LEN(@strTransactionId),1)
IF @prefix = 'V'
BEGIN
	SELECT @strTransactionId= SUBSTRING(@strTransactionId,1, LEN(@strTransactionId)-1)
	SET @ysnVoid = 1
END


;WITH r AS (
SELECT trns.strTransactionId,

CASE WHEN dbo.fnARGetInvoiceAmountMultiplier(ISNULL(strTransactionType,'Customer Prepayment')) = 1 THEN '7' ELSE '2' END Code from
tblARPayment payment
JOIN tblCMUndepositedFund uf ON uf.intSourceTransactionId  = payment.intPaymentId
JOIN tblCMBankTransaction trns ON trns.intTransactionId = uf.intBankDepositId
LEFT JOIN tblARInvoice invoice ON payment.intPaymentId = invoice.intPaymentId
UNION
SELECT trns.strTransactionId, CASE WHEN intTransactionType in (1,14) then '2' else '7' end Code
FROM tblAPBill bill JOIN tblAPBillDetail billdetail on bill.intBillId = billdetail.intBillId
JOIN tblAPPaymentDetail paymentdetail ON paymentdetail.intBillId = billdetail.intBillId
JOIN tblAPPayment payment ON payment.intPaymentId = paymentdetail.intPaymentId
JOIN tblCMBankTransaction trns ON trns.strTransactionId = payment.strPaymentRecordNum
UNION
SELECT  trns.strTransactionId,'2' Code FROM tblPRPaycheck pchk
JOIN tblCMBankTransaction trns ON trns.strTransactionId = pchk.strPaycheckId
)SELECT @Code=Code FROM r
WHERE strTransactionId = @strTransactionId

	-- Return the result of the function
IF (@ysnVoid =1)
BEGIN
	SELECT @Code = CASE WHEN @Code = '7' THEN '2' ELSE '7' END
END

RETURN @Code

END