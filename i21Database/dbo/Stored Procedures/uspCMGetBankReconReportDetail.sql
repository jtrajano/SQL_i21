CREATE PROCEDURE [dbo].[uspCMGetBankReconReportDetail]
    @intBankAccountId INT,
    @dtmStatementDate DATETIME,
	@ysnClr BIT,
	@ysnPayment BIT,
	@ysnCheckVoid BIT= 0
AS
DECLARE  @ysnMaskedPCHKPayee BIT
SELECT @ysnMaskedPCHKPayee = ysnMaskEmployeeName from tblPRCompanyPreference  

	SELECT	BT.intBankAccountId 
		,dtmStatementDate = @dtmStatementDate
		,strCbkNo = BA.strCbkNo
		,@ysnClr ysnClr
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
		SELECT  intTransactionId FROM dbo.fnCMGetReconGridResult(@intBankAccountId,@dtmStatementDate,@ysnPayment,@ysnCheckVoid,@ysnClr) 
		WHERE intTransactionId = BT.intTransactionId
	)P