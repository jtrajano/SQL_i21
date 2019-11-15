
CREATE PROCEDURE [dbo].[uspCMGetBankBalance]
	@intBankAccountId INT = NULL,
	@dtmDate DATETIME = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


SELECT	intBankAccountId = @intBankAccountId,
		dblBalance = [dbo].[fnCMGetBankBalance] (@intBankAccountId, @dtmDate)
