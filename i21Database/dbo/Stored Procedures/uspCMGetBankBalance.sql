
CREATE PROCEDURE uspCMGetBankBalance
	@intBankAccountId INT = NULL,
	@dtmDate AS DATETIME = NULL
AS

SET QUOTED_IdENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

SELECT	intBankAccountId = @intBankAccountId,
		dblBalance = [dbo].[fnCMGetBankBalance] (@intBankAccountId, @dtmDate)