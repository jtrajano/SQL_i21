CREATE PROCEDURE [dbo].[uspCMRefreshUndepositedFundsFromOrigin]
	@intBankAccountId INT
	,@intUserId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
--SET ANSI_WARNINGS OFF

DECLARE	@SOURCE_SYSTEM_DEPOSIT_ENTRY AS NVARCHAR(20) = 'aptrxmst'

BEGIN TRANSACTION 

-- Delete any outdated records from the Deposit Entry table. 
DELETE	tblCMUndepositedFund 
FROM	tblCMUndepositedFund f 
WHERE	f.strSourceSystem = @SOURCE_SYSTEM_DEPOSIT_ENTRY
		AND f.intBankDepositId IS NULL 
		AND NOT EXISTS (
			SELECT	TOP 1 1 
			FROM	vyuCMOriginDepositEntry v
			WHERE	f.strSourceTransactionId = ( 
							CAST(v.aptrx_vnd_no AS NVARCHAR(10)) 
							+ CAST(v.aptrx_ivc_no AS NVARCHAR(18)) 
							+ CAST(v.aptrx_cbk_no AS NVARCHAR(2)) 
							+ CAST(v.aptrx_chk_no AS NVARCHAR(8))
						) COLLATE Latin1_General_CI_AS
		)

UPDATE U SET intBankDepositId = D.intTransactionId FROM tblCMUndepositedFund U JOIN tblCMBankTransactionDetail D ON D.intUndepositedFundId = U.intUndepositedFundId
JOIN tblCMBankTransaction B ON B.intTransactionId = D.intTransactionId
-- set intBankDepositId to null if Bank Deposit is non-existing/ deleted.
UPDATE A SET intBankDepositId = NULL FROM tblCMUndepositedFund A LEFT JOIN tblCMBankTransaction B on A.intBankDepositId = B.intTransactionId
WHERE B.intTransactionId IS NULL AND A.intBankDepositId IS NOT NULL

DELETE FROM tblCMUndepositedFund WHERE intBankDepositId IS NULL

IF @@ERROR <> 0	GOTO uspCMRefreshUndepositedFundsFromOrigin_Rollback

IF @intBankAccountId IS NOT NULL
BEGIN
-- Update any outdated records from the Deposit Entry table that does not have bank account.
	UPDATE tblCMUndepositedFund
	set intBankAccountId = @intBankAccountId
	WHERE strSourceSystem = 'AR'
		AND intSourceTransactionId IN (SELECT intPaymentId FROM tblARPayment WHERE ysnPosted = 1 AND intBankAccountId IS NULL)
		AND intBankDepositId IS NULL

	-- Update any outdated records from the Deposit Entry table that came from Invoice.
	UPDATE tblCMUndepositedFund
	set intBankAccountId = @intBankAccountId
	WHERE strSourceSystem = 'AR'
		AND strSourceTransactionId LIKE 'SI-%'
		AND intBankDepositId IS NULL

	IF @@ERROR <> 0	GOTO uspCMRefreshUndepositedFundsFromOrigin_Rollback

END

-- remove duplicates
;WITH dup AS(
	SELECT  ROW_NUMBER() OVER ( PARTITION BY d.strSourceTransactionId ORDER BY d.intUndepositedFundId ) rowId, d.intUndepositedFundId
	FROM	dbo.tblCMUndepositedFund d 
	LEFT JOIN tblCMBankTransactionDetail CM 
	ON CM.intUndepositedFundId = d.intUndepositedFundId
	WHERE CM.intUndepositedFundId is null
)
DELETE A FROM tblCMUndepositedFund A JOIN dup B ON A.intUndepositedFundId = B.intUndepositedFundId
WHERE B.rowId > 1

-- Insert records from the Deposit Entry
;WITH CTE AS (
SELECT	
		b.intBankAccountId
		,strSourceTransactionId = (
				CAST(v.aptrx_vnd_no AS NVARCHAR(10)) 
				+ CAST(v.aptrx_ivc_no AS NVARCHAR(18)) 
				+ CAST(v.aptrx_cbk_no AS NVARCHAR(2)) 
				+ CAST(v.aptrx_chk_no AS NVARCHAR(8))
			) COLLATE Latin1_General_CI_AS
		,intSourceTransactionId = NULL
		,intLocationId = NULL
		,dtmDate = dbo.fnConvertOriginDateToSQLDateTime(v.aptrx_chk_rev_dt) -- Use aptrx_chk_rev_dt because this is the deposit entry date. 
		,dblAmount = ABS(v.aptrx_net_amt)
		,strName = v.aptrx_name COLLATE Latin1_General_CI_AS
		,strSourceSystem = @SOURCE_SYSTEM_DEPOSIT_ENTRY
		,strPaymentMethod = 'Origin'
		,intCreatedUserId = @intUserId
		,dtmCreated = GETDATE()
		,intLastModifiedUserId = @intUserId
		,dtmLastModified = GETDATE()
		,strPaymentSource = '' COLLATE Latin1_General_CI_AS  
		,strEODNumber = ''  COLLATE Latin1_General_CI_AS  
		,strEODDrawer = '' COLLATE Latin1_General_CI_AS   
		,ysnEODComplete = NULL
		,strPaymentInfo = '' COLLATE Latin1_General_CI_AS
		,b.intCurrencyId
		,intAccountId = 0
FROM	vyuCMOriginDepositEntry v INNER JOIN tblCMBankAccount b
			ON b.strCbkNo = v.aptrx_cbk_no COLLATE Latin1_General_CI_AS
UNION SELECT DISTINCT
	ISNULL(v.intBankAccountId,@intBankAccountId)  intBankAccountId,
	strSourceTransactionId,
	intSourceTransactionId,
	v.intLocationId,
	dtmDate,
	dblAmount,
	strName,
	strSourceSystem,
	v.strPaymentMethod,
	intCreatedUserId = intEntityEnteredById,
	dtmCreated = GETDATE(),
	intLastModifiedUserId = intEntityEnteredById,
	dtmLastModified = GETDATE(),
	strPaymentSource,			
	strEODNumber,
	strEODDrawer = strDrawerName ,		
    ysnEODComplete = ysnCompleted ,
	v.strPaymentInfo,
	v.intCurrencyId,
	v.intAccountId
FROM vyuARUndepositedPayment v
LEFT JOIN tblARPayment p on p.strRecordNumber = v.strSourceTransactionId
WHERE isnull(p.intPaymentMethodId,0) <> 9 -- EXEMPT CF INVOICE
)

INSERT INTO tblCMUndepositedFund (
		intBankAccountId
		,strSourceTransactionId
		,intSourceTransactionId
		,intLocationId
		,dtmDate
		,dblAmount
		,strName
		,strSourceSystem
		,strPaymentMethod
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		,strPaymentSource
		,strEODNumber
		,strEODDrawer
    	,ysnEODComplete
		,strReferenceNo
		,intCurrencyId
		,intAccountId
)
SELECT 
		intBankAccountId
		,strSourceTransactionId
		,intSourceTransactionId
		,intLocationId
		,dtmDate
		,dblAmount
		,strName
		,strSourceSystem
		,strPaymentMethod
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
		,strPaymentSource
		,strEODNumber
		,strEODDrawer
    	,ysnEODComplete 
		,strPaymentInfo
		,intCurrencyId
		,intAccountId
		
FROM CTE
WHERE 
strSourceTransactionId NOT IN (SELECT strSourceTransactionId FROM tblCMUndepositedFund)
AND dblAmount <> 0


IF @@ERROR <> 0	GOTO uspCMRefreshUndepositedFundsFromOrigin_Rollback

-- Update the Undeposited Fund records from the Deposit Entry
IF @intBankAccountId IS NOT NULL
	UPDATE	tblCMUndepositedFund
	SET		dtmDate = dbo.fnConvertOriginDateToSQLDateTime(v.aptrx_chk_rev_dt) -- Use aptrx_chk_rev_dt because this is the deposit entry date. 
			,dblAmount = ABS(v.aptrx_net_amt)
			,strName = v.aptrx_name COLLATE Latin1_General_CI_AS
			,strSourceSystem = @SOURCE_SYSTEM_DEPOSIT_ENTRY
			,intLastModifiedUserId = @intUserId
			,dtmLastModified = GETDATE()
	FROM	tblCMUndepositedFund f INNER JOIN vyuCMOriginDepositEntry v
				ON f.strSourceTransactionId = ( 
								CAST(v.aptrx_vnd_no AS NVARCHAR(10)) 
								+ CAST(v.aptrx_ivc_no AS NVARCHAR(18)) 
								+ CAST(v.aptrx_cbk_no AS NVARCHAR(2)) 
								+ CAST(v.aptrx_chk_no AS NVARCHAR(8))
							) COLLATE Latin1_General_CI_AS
			INNER JOIN tblCMBankAccount b
				ON b.strCbkNo = v.aptrx_cbk_no COLLATE Latin1_General_CI_AS 
	WHERE	f.strSourceSystem = @SOURCE_SYSTEM_DEPOSIT_ENTRY
			AND f.intBankAccountId = @intBankAccountId
			AND f.intBankDepositId IS NULL 
			
IF @@ERROR <> 0	GOTO uspCMRefreshUndepositedFundsFromOrigin_Rollback

--=====================================================================================================================================
-- 	EXIT ROUTINES
---------------------------------------------------------------------------------------------------------------------------------------
uspCMRefreshUndepositedFundsFromOrigin_Commit:
	COMMIT TRANSACTION
	GOTO uspCMRefreshUndepositedFundsFromOrigin_Exit
	
uspCMRefreshUndepositedFundsFromOrigin_Rollback:
	ROLLBACK TRANSACTION 
	
uspCMRefreshUndepositedFundsFromOrigin_Exit: