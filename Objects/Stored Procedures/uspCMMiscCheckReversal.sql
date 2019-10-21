
CREATE PROCEDURE uspCMMiscCheckReversal
	@strTransactionId NVARCHAR(100),
	@dtmReverseDate DATETIME,
	@intUserId INT,
	@isReversingSuccessful BIT = 0 OUTPUT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

/* Create Temporary Table required by uspCMBankTransactionReversal */
CREATE TABLE #tmpCMBankTransaction (
    [strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL,
UNIQUE (strTransactionId))

/* Populate #tmpCMBankTransaction */
INSERT INTO #tmpCMBankTransaction (strTransactionId)
SELECT @strTransactionId

-- Calling the stored procedure
EXEC dbo.uspCMBankTransactionReversal @intUserId, @dtmReverseDate, @isReversingSuccessful OUTPUT

-- Clean-up routines:
IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpCMBankTransaction')) DROP TABLE #tmpCMBankTransaction

GO
