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
SELECT trns.strTransactionId COLLATE Latin1_General_CI_AS strTransactionId,
CASE WHEN payment.dblAmountPaid < 0 THEN '2' ELSE '7' END Code
FROM tblARPayment payment JOIN
vyuARPaymentBankTransaction trns on payment.intPaymentId = trns.intPaymentId
UNION
SELECT trns.strTransactionId COLLATE Latin1_General_CI_AS strTransactionId,
CASE WHEN payment.dblAmountPaid > 0 THEN '2' ELSE '7' END Code
FROM tblAPPayment payment
JOIN tblCMBankTransaction trns ON trns.strTransactionId = payment.strPaymentRecordNum
UNION
SELECT  trns.strTransactionId COLLATE Latin1_General_CI_AS strTransactionId,
'2' Code FROM tblPRPaycheck pchk
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