CREATE FUNCTION [dbo].[fnCMGetACHTransactionCode]
(
	@intTransactionId int
)
RETURNS NVARCHAR(1)
AS
BEGIN
	-- Declare the return variable here
DECLARE @Code NVARCHAR(1)

	-- Add the T-SQL statements to compute the return value here;with result as (
;with result as (
select trns.intTransactionId, CASE WHEN dbo.fnARGetInvoiceAmountMultiplier(strTransactionType) = 1 THEN '7' ELSE '2' END Code from tblARInvoice invoice join 
tblARPaymentDetail paymentdetail on paymentdetail.intInvoiceId = invoice.intInvoiceId
join tblAPPayment payment on payment.intPaymentId = paymentdetail.intPaymentId
join tblCMUndepositedFund uf on uf.intSourceTransactionId  = payment.intPaymentId
join tblCMBankTransaction trns on trns.intTransactionId = uf.intBankDepositId
union
select trns.intTransactionId, case when intTransactionType in (1,14) then '2' else '7' end Code
from tblAPBill bill join tblAPBillDetail billdetail on bill.intBillId = billdetail.intBillId
join tblAPPaymentDetail paymentdetail on paymentdetail.intBillId = billdetail.intBillId
join tblAPPayment payment on payment.intPaymentId = paymentdetail.intPaymentId
join tblCMBankTransaction trns on trns.strTransactionId = payment.strPaymentRecordNum
)select @Code =Code from result
WHERE intTransactionId = @intTransactionId

	-- Return the result of the function
RETURN @Code

END