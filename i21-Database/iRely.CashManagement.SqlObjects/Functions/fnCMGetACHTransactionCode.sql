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

	
;with r as (
select trns.strTransactionId, CASE WHEN dbo.fnARGetInvoiceAmountMultiplier(strTransactionType) = 1 THEN '7' ELSE '2' END Code from tblARInvoice invoice join 
tblARPaymentDetail paymentdetail on paymentdetail.intInvoiceId = invoice.intInvoiceId
join tblARPayment payment on payment.intPaymentId = paymentdetail.intPaymentId
join tblCMUndepositedFund uf on uf.intSourceTransactionId  = payment.intPaymentId
join tblCMBankTransaction trns on trns.intTransactionId = uf.intBankDepositId
union
select trns.strTransactionId, case when intTransactionType in (1,14) then '2' else '7' end Code
from tblAPBill bill join tblAPBillDetail billdetail on bill.intBillId = billdetail.intBillId
join tblAPPaymentDetail paymentdetail on paymentdetail.intBillId = billdetail.intBillId
join tblAPPayment payment on payment.intPaymentId = paymentdetail.intPaymentId
join tblCMBankTransaction trns on trns.strTransactionId = payment.strPaymentRecordNum
union
select trns.strTransactionId,'2' Code from tblPRPaycheck pchk  
join tblCMBankTransaction trns on trns.strTransactionId = pchk.strPaycheckId
)select @Code =Code from r
WHERE strTransactionId = @strTransactionId

	-- Return the result of the function
IF (@ysnVoid =1)
BEGIN
	SELECT @Code = CASE WHEN @Code = '7' THEN '2' ELSE '7' END
END

RETURN @Code

END