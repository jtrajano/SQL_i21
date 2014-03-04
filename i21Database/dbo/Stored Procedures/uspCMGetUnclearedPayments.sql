
CREATE PROCEDURE uspCMGetUnclearedPayments
	@intBankAccountId INT = NULL,
	@dtmStatementDate AS DATETIME = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

SELECT dblAmount = [dbo].[fnCMGetUnclearedPayments](@intBankAccountId, @dtmStatementDate)