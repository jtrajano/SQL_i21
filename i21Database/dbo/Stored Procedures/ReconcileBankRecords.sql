﻿
CREATE PROCEDURE ReconcileBankRecords
	@intBankAccountId INT = NULL,
	@dtmDate AS DATETIME = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

UPDATE	[dbo].[tblCMBankTransaction]
SET		dtmDateReconciled = @dtmDate
WHERE	intBankAccountId = @intBankAccountId
		AND ysnPosted = 1
		AND ysnClr = 1
		AND dtmDateReconciled IS NULL 
		AND CAST(FLOOR(CAST(dtmDate AS FLOAT)) AS DATETIME) <= CAST(FLOOR(CAST(ISNULL(@dtmDate, dtmDate) AS FLOAT)) AS DATETIME)
		
-- TODO: 
-- MARK AS CLEARED IN THE ORIGIN BANK TRANSACTIONS