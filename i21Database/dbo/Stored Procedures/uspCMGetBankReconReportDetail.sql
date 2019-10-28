CREATE PROCEDURE [dbo].[uspCMGetBankReconReportDetail]
    @intBankAccountId INT,
    @dtmStatementDate DATETIME
AS
DECLARE  @ysnMaskedPCHKPayee BIT
SELECT @ysnMaskedPCHKPayee = ysnMaskEmployeeName from tblPRCompanyPreference  

;WITH A
    AS
    (
        SELECT 1 ysnClr, 0 ysnCheckVoid, 1 ysnPayment, 1 ysnClrOrig, 0 ysnCheckVoidOrig, 'Cleared Payment' strDescription	UNION
		SELECT 0 ysnClr, 0 ysnCheckVoid, 1 ysnPayment, 0 ysnClrOrig, 0 ysnCheckVoidOrig, 'Outstanding Checks' strDescription UNION
		SELECT 1 ysnClr, 1 ysnCheckVoid, 1 ysnPayment, 1 ysnClrOrig, 1 ysnCheckVoidOrig, 'Voided Cleared Payment ' strDescription UNION
        SELECT 0 ysnClr, 0 ysnCheckVoid, 1 ysnPayment, 1 ysnClrOrig, 1 ysnCheckVoidOrig , 'Voided Uncleared Payment' strDescription UNION
        SELECT 0 ysnClr, 0 ysnCheckVoid, 0 ysnPayment, 0 ysnClrOrig, 0 ysnCheckVoidOrig, 'Uncleared Deposit' strDescription UNION
        SELECT 1 ysnClr, 0 ysnCheckVoid, 0 ysnPayment, 1 ysnClrOrig, 0 ysnCheckVoidOrig, 'Cleared Deposit' strDescription UNION
        SELECT 1 ysnClr, 1 ysnCheckVoid, 0 ysnPayment, 1 ysnClrOrig, 1 ysnCheckVoidOrig, 'Voided Deposit' strDescription UNION
        SELECT 0 ysnClr, 0 ysnCheckVoid, 0 ysnPayment, 1 ysnClrOrig, 1 ysnCheckVoidOrig , 'Voided Uncleared Deposit' strDescription
    )
	SELECT	
		P.strDescription
		,BT.intBankAccountId 
		,dtmStatementDate = @dtmStatementDate
		,strCbkNo = BA.strCbkNo
		,P.ysnClr ysnClr
		,dtmDate = BT.dtmDate
		,dtmDateReconciled = BT.dtmDateReconciled
		,strReferenceNo = BT.strReferenceNo
		,strPayee = CASE WHEN  BT.intBankTransactionTypeId IN (21,121) AND @ysnMaskedPCHKPayee = 1 THEN '(restricted information)' ELSE BT.strPayee END 
		,strMemo = BT.strMemo
		,strRecordNo = BT.strTransactionId
		,dblAmount = ABS(BT.dblAmount)
		,intBankTransactionTypeId = BT.intBankTransactionTypeId
		,strBankTransactionTypeName = BTYPE.strBankTransactionTypeName
    FROM 
	tblCMBankTransaction BT 
	JOIN tblCMBankAccount BA ON BA.intBankAccountId = BT.intBankAccountId
	JOIN [dbo].[tblCMBankTransactionType] BTYPE
			ON BT.intBankTransactionTypeId = BTYPE.intBankTransactionTypeId
	CROSS APPLY(
		SELECT q.strDescription, intTransactionId, b.ysnClr from A q
		cross apply dbo.fnCMGetReconGridResult(@intBankAccountId,@dtmStatementDate,q.ysnPayment,q.ysnCheckVoid,q.ysnClr, q.ysnClrOrig, q.ysnCheckVoidOrig) b
		WHERE intTransactionId = BT.intTransactionId
	)P
	