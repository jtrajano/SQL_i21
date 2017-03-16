CREATE PROCEDURE [dbo].[uspCMGetBankAccountRegister] 
@intBankAccountId  INT,
@skip INT,
@take INT,
@totalCount AS INT = 0 OUTPUT 

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @openingBalance AS NUMERIC(18,6),
		@runningBalance AS NUMERIC(18,6) = 0,
		@intTransactionId AS INT,
		@strTransactionId AS NVARCHAR(50),
		@dblPayment AS NUMERIC(18,6),
		@dblDeposit AS NUMERIC(18,6),
		@dblBalance AS NUMERIC(18,6),
		@dtmDate AS DATETIME,
		@dtmDateReconciled AS DATETIME,
		@ysnCheckVoid AS BIT,
		@ysnClr AS BIT,
		@intCompanyLocationId AS INT,
		@strLocationName AS NVARCHAR(100),
		@intBankTransactionTypeId AS INT,
		@strBankTransactionTypeName AS NVARCHAR(100),
		@strReferenceNo AS NVARCHAR(50),
		@strMemo AS NVARCHAR(250),
		@strPayee AS NVARCHAR(100),
		@ysnMaskEmployeeName AS BIT,
		@RowNum BIGINT = 0


-- Get the opening balance from the first bank reconciliation record. 
SELECT TOP 1 
		@openingBalance = dblStatementOpeningBalance
FROM	tblCMBankReconciliation
WHERE 	intBankAccountId = @intBankAccountId


--Get PR Company preference
SELECT TOP 1
	@ysnMaskEmployeeName = ysnMaskEmployeeName
FROM tblPRCompanyPreference

SET @runningBalance = ISNULL(@openingBalance,0)

DECLARE @BankAccountRegister TABLE (
intTransactionId INT 
,intBankAccountId INT
,intCompanyLocationId INT
,strLocationName NVARCHAR(100)
,intBankTransactionTypeId INT
,strBankTransactionTypeName NVARCHAR(100)
,strMemo NVARCHAR(250)
,strPayee NVARCHAR(100)
,strReferenceNo NVARCHAR(50)
,strTransactionId NVARCHAR(50)
,dblPayment NUMERIC(18,6)
,dblDeposit NUMERIC(18,6)
,dblBalance NUMERIC(18,6)
,ysnCheckVoid BIT
,ysnClr BIT
,dtmDate DATETIME
,dtmDateReconciled DATETIME
)

SELECT 
intTransactionId
,strTransactionId
,intCompanyLocationId
,strLocationName = ISNULL((SELECT strLocationName FROM tblSMCompanyLocation WHERE intCompanyLocationId = A.intCompanyLocationId),'')
,intBankTransactionTypeId
,strBankTransactionTypeName = (SELECT strBankTransactionTypeName FROM tblCMBankTransactionType WHERE intBankTransactionTypeId = A.intBankTransactionTypeId)
,strReferenceNo
,CASE WHEN strMemo = '' AND ysnCheckVoid = 1 THEN  'Void' 
	ELSE
		strMemo
	END AS strMemo
,CASE WHEN @ysnMaskEmployeeName = 1  AND intBankTransactionTypeId IN (21,23) THEN 
	'(restricted information)'
	ELSE
	strPayee
	END AS strPayee
,dtmDate
,dtmDateReconciled
,CASE WHEN intBankTransactionTypeId IN (2,3,9,12,13,14,15,16,20,21,22,23)  THEN dblAmount 
	WHEN intBankTransactionTypeId = 5 AND dblAmount < 0 THEN dblAmount
	ELSE 0 
	END AS dblPayment
,CASE WHEN intBankTransactionTypeId IN (1,10,11,18,19,103,116,121,123)  THEN dblAmount 
	WHEN intBankTransactionTypeId = 5 AND dblAmount > 0 THEN dblAmount
	ELSE 0 
	END AS dblDeposit
,ysnCheckVoid
,ysnClr
,ROW_NUMBER() OVER (ORDER BY dtmDate,intTransactionId) AS RowNum
INTO #tempTransaction
FROM tblCMBankTransaction A
WHERE intBankAccountId = @intBankAccountId
AND (ysnPosted = 1 OR ysnCheckVoid = 1)
ORDER BY dtmDate, intTransactionId

CREATE NONCLUSTERED  INDEX cx_tempTransaction ON #tempTransaction (intTransactionId,dtmDate);

WHILE EXISTS (SELECT TOP 1 1 FROM #tempTransaction)
BEGIN

	SET @RowNum = @RowNum + 1

	SELECT TOP 1 
		@intTransactionId = intTransactionId
		,@strTransactionId = strTransactionId
		,@intCompanyLocationId = intCompanyLocationId
		,@strLocationName = strLocationName
		,@intBankTransactionTypeId = intBankTransactionTypeId
		,@strBankTransactionTypeName = strBankTransactionTypeName
		,@strReferenceNo = strReferenceNo
		,@strMemo = strMemo
		,@strPayee = strPayee
		,@dblPayment = ABS(dblPayment)
		,@dblDeposit = dblDeposit
		,@dtmDate = dtmDate
		,@dtmDateReconciled = dtmDateReconciled
		,@ysnCheckVoid = ysnCheckVoid
		,@ysnClr = ysnClr
	FROM #tempTransaction 
	WHERE RowNum = @RowNum

	IF @ysnCheckVoid = 0 AND CAST(FLOOR(CAST(@dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(GETDATE(),@dtmDate) AS FLOAT)) AS DATETIME)	
	BEGIN
		IF @dblPayment <> 0 
		BEGIN
			SET @runningBalance = @runningBalance + (@dblPayment * -1)
		END

		IF @dblDeposit <> 0 
		BEGIN
			SET @runningBalance = @runningBalance + @dblDeposit 
		END
	END

	INSERT INTO @BankAccountRegister
	(
	intTransactionId
	,strTransactionId
	,intCompanyLocationId
	,strLocationName
	,intBankTransactionTypeId
	,strBankTransactionTypeName
	,strReferenceNo
	,strMemo
	,strPayee
	,dtmDate
	,dtmDateReconciled
	,dblPayment
	,dblDeposit
	,dblBalance
	,ysnCheckVoid
	,ysnClr
	,intBankAccountId
	)
	VALUES
	(
	@intTransactionId
	,@strTransactionId
	,@intCompanyLocationId
	,@strLocationName
	,@intBankTransactionTypeId
	,@strBankTransactionTypeName
	,@strReferenceNo
	,@strMemo
	,@strPayee
	,@dtmDate
	,@dtmDateReconciled
	,@dblPayment
	,@dblDeposit
	,@runningBalance
	,@ysnCheckVoid
	,@ysnClr
	,@intBankAccountId
	)

	

	DELETE FROM #tempTransaction WHERE intTransactionId = @intTransactionId
			
END
		
		SELECT @totalCount = COUNT(intTransactionId) FROM @BankAccountRegister

		IF @skip IS NOT NULL AND @take IS NOT NULL 
			BEGIN
				WITH Results_CTE AS
				(
					SELECT
						*,
						ROW_NUMBER() OVER (ORDER BY intTransactionId) AS RowNum
					FROM @BankAccountRegister
				)
				SELECT *
				FROM Results_CTE
				WHERE RowNum > @skip
				AND RowNum <  CASE WHEN @skip = 0 THEN 1 ELSE @skip END + @take
				--SELECT * FROM @BankAccountRegister  ORDER BY intTransactionId OFFSET @skip ROWS FETCH NEXT @take ROWS ONLY
				
			END
		ELSE
			BEGIN
				SELECT * FROM @BankAccountRegister 
			END
    
	drop table #tempTransaction
