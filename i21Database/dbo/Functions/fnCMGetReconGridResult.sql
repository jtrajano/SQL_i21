CREATE FUNCTION [dbo].[fnCMGetReconGridResult]
(
	@intBankAccountId INT,
	@dtmStatementDate DATETIME,
	@ysnPayment BIT,
	@ysnCheckVoid BIT,
	@ysnClr BIT,
	@ysnClrOrig BIT = NULL,
	@ysnCheckVoidOrig BIT = NULL
)
RETURNS  @TBL TABLE
(
	dblAmount DECIMAL(18,6),
	dtmCheckPrinted DATETIME,
	dtmClr DATETIME,
	dtmDate DATETIME,
	dtmDateReconciled DATETIME,
	intBankAccountId INT,
	intBankTransactionTypeId INT,
	intTransactionId INT,
	strBankLoanId NVARCHAR(40),
	strBankTransactionTypeName NVARCHAR(40),
	strDescription NVARCHAR(300),
	strPayee NVARCHAR(300),
	strReferenceNo NVARCHAR(20),
	strTransactionId NVARCHAR(40),
	ysnClr BIT,
	ysnCheckVoid BIT
)
AS 
BEGIN
	DECLARE @lastDateReconciled DATETIME
	DECLARE @filterDate DATETIME

	SELECT @lastDateReconciled = MAX(dtmDateReconciled)
	FROM tblCMBankReconciliation
	WHERE intBankAccountId = @intBankAccountId
	
	SET @filterDate = DATEADD(SECOND,-1, (DATEADD(DAY ,1 , @dtmStatementDate)))
	SET @lastDateReconciled = DATEADD(SECOND,-1, (DATEADD(DAY ,1 , @lastDateReconciled)))


	--PAYMENT
	;WITH BT 
		AS
		( 
		SELECT
			  ABS(dblAmount) dblAmount
			, dtmCheckPrinted 
			, dtmClr 
			, dtmDate
			, convert(DATETIME,convert(VARCHAR,dtmDateReconciled,101)) dtmDateReconciled
			, intBankAccountId
			, v.intBankTransactionTypeId
			, intTransactionId
			, intBankLoanId 
			, t.strBankTransactionTypeName
			, strMemo
			, strPayee
			, strReferenceNo
			, strTransactionId
			, ysnClr ysnClrOrig
			, ysnCheckVoid ysnCheckVoidOrig
			, ysnPosted
		FROM [dbo].[tblCMBankTransaction] v
		JOIN tblCMBankTransactionType t ON v.intBankTransactionTypeId = t.intBankTransactionTypeId
		WHERE intBankAccountId = @intBankAccountId AND strDebitCredit = 'D'
		AND @ysnPayment = 1
		UNION
				--DEPOSIT
		SELECT
			  dblAmount
			, dtmCheckPrinted 
			, dtmClr 
			, dtmDate
			, convert(DATETIME,convert(VARCHAR,dtmDateReconciled,101)) dtmDateReconciled
			, intBankAccountId
			, v.intBankTransactionTypeId
			, intTransactionId
			, intBankLoanId 
			, t.strBankTransactionTypeName
			, strMemo
			, strPayee
			, strReferenceNo
			, strTransactionId
			, ysnClr ysnClrOrig
			, ysnCheckVoid ysnCheckVoidOrig
			, ysnPosted
		FROM [dbo].[tblCMBankTransaction] v
		JOIN tblCMBankTransactionType t ON v.intBankTransactionTypeId = t.intBankTransactionTypeId
		WHERE intBankAccountId = @intBankAccountId AND strDebitCredit = 'C'
		AND @ysnPayment = 0
		UNION
				--PAYMENT
		SELECT
			  ABS(dblAmount) dblAmount
			, dtmCheckPrinted 
			, dtmClr 
			, dtmDate 
			, convert(DATETIME,convert(VARCHAR,dtmDateReconciled,101)) dtmDateReconciled
			, intBankAccountId
			, v.intBankTransactionTypeId
			, intTransactionId
			, intBankLoanId 
			, t.strBankTransactionTypeName
			, strMemo
			, strPayee
			, strReferenceNo
			, strTransactionId
			, ysnClr ysnClrOrig
			, ysnCheckVoid ysnCheckVoidOrig
			, ysnPosted
		FROM [dbo].[tblCMBankTransaction] v
		JOIN tblCMBankTransactionType t ON v.intBankTransactionTypeId = t.intBankTransactionTypeId
		WHERE intBankAccountId = @intBankAccountId AND v.intBankTransactionTypeId IN (5, 25) AND @ysnPayment = 1 AND dblAmount < 0
		UNION
				--DEPOSIT
		SELECT
			dblAmount
			, dtmCheckPrinted 
			, dtmClr 
			, dtmDate
			, convert(DATETIME,convert(VARCHAR,dtmDateReconciled,101)) dtmDateReconciled
			, intBankAccountId
			, v.intBankTransactionTypeId
			, intTransactionId
			, intBankLoanId 
			, t.strBankTransactionTypeName
			, strMemo
			, strPayee
			, strReferenceNo
			, strTransactionId
			, ysnClr ysnClrOrig
			, ysnCheckVoid ysnCheckVoidOrig
			, ysnPosted
		FROM [dbo].[tblCMBankTransaction] v
		JOIN tblCMBankTransactionType t ON v.intBankTransactionTypeId = t.intBankTransactionTypeId
		WHERE intBankAccountId = @intBankAccountId AND v.intBankTransactionTypeId IN (5, 25)
		AND ISNULL(@ysnPayment,0) = 0 AND dblAmount > 0
		),

		BT1
		AS
		(
		SELECT
				*
			, ysnClr =  case when  (@lastDateReconciled >= @filterDate AND dtmDateReconciled IS NULL AND ysnClrOrig = 1 ) OR dtmDateReconciled >= @filterDate THEN  0 ELSE ysnClrOrig END 
			, ysnCheckVoid = CASE WHEN ysnCheckVoidOrig = 1 AND @dtmStatementDate >= dtmDateReconciled   THEN 1 ELSE 0 END
		FROM BT
		)

	INSERT INTO @TBL
	SELECT
		ISNULL(dblAmount,0) dblAmount
		, dtmCheckPrinted 
		, dtmClr 
		, dtmDate
		, dtmDateReconciled 
		, bt.intBankAccountId
		, intBankTransactionTypeId
		, intTransactionId
		, strBankLoanId 
		, strBankTransactionTypeName
		, strMemo
		, strPayee
		, strReferenceNo
		, strTransactionId
		, ysnClr
		, ysnCheckVoid
	FROM BT1 bt
	LEFT JOIN tblCMBankLoan BL ON BL.intBankLoanId = bt.intBankLoanId
	WHERE ysnPosted  = 1
	AND ISNULL(dblAmount,0) <> 0
	AND dtmDate <= @dtmStatementDate
	AND isnull(dtmDateReconciled, @dtmStatementDate) >= @dtmStatementDate
	AND ysnCheckVoid = @ysnCheckVoid
	AND ysnClr = @ysnClr
	AND ysnClrOrig = ISNULL(@ysnClrOrig,ysnClrOrig)
	AND ysnCheckVoidOrig = ISNULL(@ysnCheckVoidOrig,ysnCheckVoidOrig)
	
	RETURN

END
GO

