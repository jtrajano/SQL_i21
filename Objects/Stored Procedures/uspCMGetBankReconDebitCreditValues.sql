-- @paymentDeposit 
-- 0 = PAYMENT 
-- 1 = DEPOSIT
-- 2 = PAYMENT AND DEPOSIT
CREATE PROCEDURE [dbo].[uspCMGetBankReconDebitCreditValues]
    @intBankAccountId INT,
    @dtmStatementDate DATETIME,
    @paymentDeposit SMALLINT = 0
AS
;WITH A
    AS
    (
        SELECT 'PaymentClearedNotVoid' strDescription, 1 ysnClr, 0 ysnCheckVoid, 1 ysnPayment
            WHERE @paymentDeposit = 0 OR @paymentDeposit = 2
        UNION
            SELECT'PaymentNotClearedNotVoid' strDescription, 0 ysnClr, 0 ysnCheckVoid, 1 ysnPayment
            WHERE @paymentDeposit = 0 OR @paymentDeposit = 2
        UNION
            SELECT 'PaymentClearedVoid' strDescription, 1 ysnClr, 1 ysnCheckVoid, 1 ysnPayment
            WHERE @paymentDeposit = 0 OR @paymentDeposit = 2
        UNION
            SELECT 'PaymentUnclearedVoid' strDescription, 0 ysnClr, 1 ysnCheckVoid, 1 ysnPayment
            WHERE @paymentDeposit = 0 OR @paymentDeposit = 2

        UNION
            SELECT 'DepositNotClearedNotVoid' strDescription, 0 ysnClr, 0 ysnCheckVoid, 0 ysnPayment
            WHERE @paymentDeposit = 1 OR @paymentDeposit = 2
        UNION
            SELECT 'DepositClearedNotVoid' strDescription, 1 ysnClr, 0 ysnCheckVoid, 0 ysnPayment
            WHERE @paymentDeposit = 1 OR @paymentDeposit = 2


    )
SELECT B.strDescription, totalCount, ISNULL(totalAmount,0) totalAmount
FROM
    A
 CROSS APPLY 
 (
	SELECT A.strDescription, count(1) totalCount, sum(abs(dblAmount)) totalAmount
    FROM dbo.fnCMGetReconGridResult(@intBankAccountId,@dtmStatementDate,A.ysnPayment,A.ysnCheckVoid,A.ysnClr) 
 )B