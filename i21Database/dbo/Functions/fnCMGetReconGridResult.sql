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

	SET @filterDate = DATEADD(DAY,1,@dtmStatementDate)

	SELECT @lastDateReconciled = MAX(dtmDateReconciled)
	FROM tblCMBankReconciliation
	WHERE intBankAccountId = @intBankAccountId

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
			, intBankTransactionTypeId
			, intTransactionId
			, intBankLoanId 
			, strBankTransactionTypeName
			, strMemo
			, strPayee
			, strReferenceNo
			, strTransactionId
			, ysnClr ysnClrOrig
			, ysnCheckVoid ysnCheckVoidOrig
			, ysnPosted
		FROM [dbo].[vyuCMBankTransaction] v
		WHERE intBankAccountId = @intBankAccountId AND intBankTransactionTypeId IN(2,3,9, 12,13,14,15,16,20,21,22,23,51,52,124)
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
			, intBankTransactionTypeId
			, intTransactionId
			, intBankLoanId 
			, strBankTransactionTypeName
			, strMemo
			, strPayee
			, strReferenceNo
			, strTransactionId
			, ysnClr ysnClrOrig
			, ysnCheckVoid ysnCheckVoidOrig
			, ysnPosted
		FROM [dbo].[vyuCMBankTransaction] v
		WHERE intBankAccountId = @intBankAccountId AND intBankTransactionTypeId IN(1,10,11,18,19,103,116,121,122,123)
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
			, intBankTransactionTypeId
			, intTransactionId
			, intBankLoanId 
			, strBankTransactionTypeName
			, strMemo
			, strPayee
			, strReferenceNo
			, strTransactionId
			, ysnClr ysnClrOrig
			, ysnCheckVoid ysnCheckVoidOrig
			, ysnPosted
		FROM [dbo].[vyuCMBankTransaction] v
		WHERE intBankAccountId = @intBankAccountId AND intBankTransactionTypeId = 5 AND @ysnPayment = 1 AND dblAmount < 0
		UNION
				--DEPOSIT
		SELECT
			dblAmount
			, dtmCheckPrinted 
			, dtmClr 
			, dtmDate
			, convert(DATETIME,convert(VARCHAR,dtmDateReconciled,101)) dtmDateReconciled
			, intBankAccountId
			, intBankTransactionTypeId
			, intTransactionId
			, intBankLoanId 
			, strBankTransactionTypeName
			, strMemo
			, strPayee
			, strReferenceNo
			, strTransactionId
			, ysnClr ysnClrOrig
			, ysnCheckVoid ysnCheckVoidOrig
			, ysnPosted
		FROM [dbo].[vyuCMBankTransaction] v
		WHERE intBankAccountId = @intBankAccountId AND intBankTransactionTypeId = 5
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
		, intBankAccountId
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

