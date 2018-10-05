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
;WITH x AS (
	SELECT strRecordNumber strTransactionId,dblAmountPaid , 'AR' strSource from tblARPayment  UNION
	SELECT strPaymentRecordNum strTransactionId,dblAmountPaid , 'AP' strSource from tblAPPayment  UNION
	SELECT  strPaycheckId strTransactionId,dblNetPayTotal dblAmountPaid, 'PR' strSource FROM tblPRPaycheck
)

SELECT   @Code = 
CASE WHEN strSource = 'AR'
	THEN
		CASE WHEN	dblAmountPaid < 0 THEN '2' ELSE '7' END
ELSE
	CASE WHEN dblAmountPaid > 0 THEN '2' ELSE '7' END
END

FROM x
WHERE strTransactionId = @strTransactionId

IF (@ysnVoid =1)
BEGIN
	SELECT @Code = CASE WHEN @Code = '7' THEN '2' ELSE '7' END
END
RETURN @Code
END

