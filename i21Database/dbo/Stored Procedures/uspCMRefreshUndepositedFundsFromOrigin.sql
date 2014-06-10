CREATE PROCEDURE [dbo].[uspCMRefreshUndepositedFundsFromOrigin]
	@intBankAccountId INT
	,@intUserId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE	@SOURCE_SYSTEM_DEPOSIT_ENTRY AS NVARCHAR(20) = 'aptrxmst'

BEGIN TRANSACTION 

-- Delete any outdated records from the Deposit Entry table. 
DELETE	tblCMUndepositedFund 
FROM	tblCMUndepositedFund f 
WHERE	f.strSourceSystem = @SOURCE_SYSTEM_DEPOSIT_ENTRY
		AND f.intBankAccountId = @intBankAccountId
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

-- Insert records from the Deposit Entry
INSERT INTO tblCMUndepositedFund (
		intBankAccountId
		,strSourceTransactionId
		,dtmDate
		,dblAmount
		,strName
		,strSourceSystem
		,intCreatedUserId
		,dtmCreated
		,intLastModifiedUserId
		,dtmLastModified
)
SELECT	@intBankAccountId
		,strSourceTransactionId = (
				CAST(v.aptrx_vnd_no AS NVARCHAR(10)) 
				+ CAST(v.aptrx_ivc_no AS NVARCHAR(18)) 
				+ CAST(v.aptrx_cbk_no AS NVARCHAR(2)) 
				+ CAST(v.aptrx_chk_no AS NVARCHAR(8))
			) COLLATE Latin1_General_CI_AS
		,dtmDate = dbo.fnConvertOriginDateToSQLDateTime(v.aptrx_chk_rev_dt) -- Use aptrx_chk_rev_dt because this is the deposit entry date. 
		,dblAmount = ABS(v.aptrx_net_amt)
		,strName = v.aptrx_name COLLATE Latin1_General_CI_AS
		,strSourceSystem = @SOURCE_SYSTEM_DEPOSIT_ENTRY
		,intCreatedUserId = @intUserId
		,dtmCreated = GETDATE()
		,intLastModifiedUserId = @intUserId
		,dtmLastModified = GETDATE()
FROM	vyuCMOriginDepositEntry v INNER JOIN tblCMBankAccount b
			ON b.strCbkNo = v.aptrx_cbk_no COLLATE Latin1_General_CI_AS 
WHERE	b.intBankAccountId = @intBankAccountId
		AND NOT EXISTS (
			SELECT TOP 1 1
			FROM	tblCMUndepositedFund f
			WHERE	f.strSourceTransactionId = ( 
							CAST(v.aptrx_vnd_no AS NVARCHAR(10)) 
							+ CAST(v.aptrx_ivc_no AS NVARCHAR(18)) 
							+ CAST(v.aptrx_cbk_no AS NVARCHAR(2)) 
							+ CAST(v.aptrx_chk_no AS NVARCHAR(8))
						) COLLATE Latin1_General_CI_AS
		)

IF @@ERROR <> 0	GOTO uspCMRefreshUndepositedFundsFromOrigin_Rollback

-- Update the Undeposited Fund records from the Deposit Entry
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