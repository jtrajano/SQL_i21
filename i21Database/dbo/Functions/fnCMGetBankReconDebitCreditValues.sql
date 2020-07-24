-- @paymentDeposit 
-- 0 = PAYMENT 
-- 1 = DEPOSIT
-- 2 = PAYMENT AND DEPOSIT
CREATE FUNCTION [dbo].[fnCMGetBankReconDebitCreditValues](
    @intBankAccountId INT,
    @dtmStatementDate DATETIME,
    @strDescription NVARCHAR(50)
)
RETURNS TABLE AS
RETURN
WITH A
    AS
    (
        SELECT 1 ysnClr, 0 ysnCheckVoid, 1 ysnPayment, 1 ysnClrOrig, 0 ysnCheckVoidOrig, 'PaymentClearedNotVoid' strDescription
            WHERE @strDescription = 'PaymentClearedNotVoid' or @strDescription  = 'All' or @strDescription = 'Debit'
        UNION
            SELECT 0 ysnClr, 0 ysnCheckVoid, 1 ysnPayment, 0 ysnClrOrig, 0 ysnCheckVoidOrig, 'PaymentNotClearedNotVoid' strDescription
            WHERE @strDescription = 'PaymentNotClearedNotVoid' or @strDescription  = 'All'or @strDescription = 'Debit'
        UNION
            SELECT 1 ysnClr, 1 ysnCheckVoid, 1 ysnPayment, 1 ysnClrOrig, 1 ysnCheckVoidOrig, 'PaymentClearedVoid' strDescription
            WHERE @strDescription = 'PaymentClearedVoid'or @strDescription  = 'All'or @strDescription = 'Debit'
        UNION
            SELECT 0 ysnClr, 0 ysnCheckVoid, 1 ysnPayment, 1 ysnClrOrig, 1 ysnCheckVoidOrig , 'PaymentNotClearedNotVoidYet' strDescription
            WHERE @strDescription = 'PaymentNotClearedNotVoidYet'or @strDescription  = 'All'or @strDescription = 'Debit'

        UNION
            SELECT 0 ysnClr, 0 ysnCheckVoid, 0 ysnPayment, 0 ysnClrOrig, 0 ysnCheckVoidOrig, 'DepositNotClearedNotVoid' strDescription
            WHERE @strDescription = 'DepositNotClearedNotVoid'or @strDescription  = 'All'or @strDescription = 'Credit'
        UNION
            SELECT 1 ysnClr, 0 ysnCheckVoid, 0 ysnPayment, 1 ysnClrOrig, 0 ysnCheckVoidOrig, 'DepositClearedNotVoid' strDescription
            WHERE @strDescription = 'DepositClearedNotVoid'or @strDescription  = 'All'or @strDescription = 'Credit'
    )
SELECT strDescription, strTransactionId, ISNULL(dblAmount,0) dblAmount
FROM
    A
 CROSS APPLY 
 (
	SELECT strTransactionId , dblAmount
    FROM dbo.fnCMGetReconGridResult(@intBankAccountId,@dtmStatementDate,A.ysnPayment,A.ysnCheckVoid,A.ysnClr,ysnClrOrig, ysnCheckVoidOrig) 
 )B


 