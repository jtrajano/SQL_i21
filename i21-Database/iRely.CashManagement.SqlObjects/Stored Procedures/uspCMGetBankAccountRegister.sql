CREATE PROCEDURE [dbo].[uspCMGetBankAccountRegister] 
@intBankAccountId  INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @openingBalance AS NUMERIC(18,6),
		@runningOpeningBalance AS NUMERIC(18,6) = 0,
		@runningEndingBalance AS NUMERIC(18,6) = 0,
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

SET @runningOpeningBalance = ISNULL(@openingBalance,0)
SET @runningEndingBalance = ISNULL(@openingBalance,0)

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
,dblOpeningBalance NUMERIC(18,6)
,dblPayment NUMERIC(18,6)
,dblDeposit NUMERIC(18,6)
,dblEndingBalance NUMERIC(18,6)
,ysnCheckVoid BIT
,ysnClr BIT
,dtmDate DATETIME
,dtmDateReconciled DATETIME
)

DECLARE rt_cursor CURSOR
FOR
SELECT 
intTransactionId
,strTransactionId
,intCompanyLocationId
,strLocationName = ISNULL((SELECT strLocationName FROM tblSMCompanyLocation WHERE intCompanyLocationId = A.intCompanyLocationId),'')
,intBankTransactionTypeId
,strBankTransactionTypeName = (SELECT strBankTransactionTypeName FROM tblCMBankTransactionType WHERE intBankTransactionTypeId = A.intBankTransactionTypeId)
,ISNULL(strReferenceNo,'') as strReferenceNo
,CASE WHEN strMemo = '' AND ysnCheckVoid = 1 THEN  'Void' 
	ELSE
		ISNULL(strMemo,'')
	END AS strMemo
,CASE WHEN @ysnMaskEmployeeName = 1  AND intBankTransactionTypeId IN (21,23) THEN 
	'(restricted information)'
	ELSE
	ISNULL(strPayee,'')
	END AS strPayee
,CAST(dtmDate AS DATE) AS dtmDate
,dtmDateReconciled
,CASE WHEN intBankTransactionTypeId IN (3,9,12,13,14,15,16,20,21,22,23)  THEN dblAmount 
	WHEN intBankTransactionTypeId IN (2,5) AND dblAmount < 0 THEN dblAmount * -1
	ELSE 0 
	END AS dblPayment
,CASE WHEN intBankTransactionTypeId IN (1,10,11,18,19,103,116,121,122,123)  THEN dblAmount 
	WHEN intBankTransactionTypeId = 5 AND dblAmount > 0 THEN dblAmount
	ELSE 0 
	END AS dblDeposit
,ysnCheckVoid
,ysnClr
FROM tblCMBankTransaction A
WHERE intBankAccountId = @intBankAccountId
AND (ysnPosted = 1 OR ysnCheckVoid = 1)
ORDER BY CAST(dtmDate AS DATE), intTransactionId

OPEN rt_cursor

FETCH NEXT FROM  rt_cursor INTO 
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
	,@ysnCheckVoid
	,@ysnClr


WHILE @@FETCH_STATUS = 0
BEGIN

	

	IF @ysnCheckVoid = 0 AND CAST(FLOOR(CAST(@dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(GETDATE(),@dtmDate) AS FLOAT)) AS DATETIME)	
	BEGIN
		IF @dblPayment <> 0 
		BEGIN
			SET @runningEndingBalance = @runningEndingBalance + (@dblPayment * -1)
		END

		IF @dblDeposit <> 0 
		BEGIN
			SET @runningEndingBalance = @runningEndingBalance + @dblDeposit 
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
	,dblOpeningBalance
	,dblPayment
	,dblDeposit
	,dblEndingBalance
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
	,@runningOpeningBalance
	,@dblPayment
	,@dblDeposit
	,@runningEndingBalance
	,@ysnCheckVoid
	,@ysnClr
	,@intBankAccountId
	)

	SET @runningOpeningBalance = @runningEndingBalance

	FETCH NEXT FROM  rt_cursor INTO 
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
	,@ysnCheckVoid
	,@ysnClr
			
END

CLOSE rt_cursor
DEALLOCATE rt_cursor
		
	
SELECT * FROM @BankAccountRegister
	