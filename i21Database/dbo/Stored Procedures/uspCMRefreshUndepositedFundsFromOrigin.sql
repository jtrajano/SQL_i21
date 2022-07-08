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
		
FROM	vyuCMOriginDepositEntry v INNER JOIN tblCMBankAccount b
			ON b.strCbkNo = v.aptrx_cbk_no COLLATE Latin1_General_CI_AS 
WHERE	NOT EXISTS (
			SELECT TOP 1 1
			FROM	tblCMUndepositedFund f
			WHERE	f.strSourceTransactionId = ( 
							CAST(v.aptrx_vnd_no AS NVARCHAR(10)) 
							+ CAST(v.aptrx_ivc_no AS NVARCHAR(18)) 
							+ CAST(v.aptrx_cbk_no AS NVARCHAR(2)) 
							+ CAST(v.aptrx_chk_no AS NVARCHAR(8))
						) COLLATE Latin1_General_CI_AS
		)

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
	v.intCurrencyId
FROM vyuARUndepositedPayment v

LEFT JOIN tblARPayment p on p.strRecordNumber = v.strSourceTransactionId
WHERE	NOT EXISTS (
			SELECT TOP 1 1
			FROM	tblCMUndepositedFund f
			WHERE	f.strSourceTransactionId = v.strSourceTransactionId)
		AND isnull(p.intPaymentMethodId,0) <> 9 -- EXEMPT CF INVOICE
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
		
FROM CTE
WHERE dblAmount <> 0


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