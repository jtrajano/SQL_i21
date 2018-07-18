
CREATE PROCEDURE [dbo].[uspCMGetBankBalance]
	@intBankAccountId INT = NULL,
	@dtmDate DATETIME = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @isForeignCurrency AS BIT = 1
DECLARE @intDefaultCurrencyId INT , @intCurrencyId INT

SELECT TOP 1 @intCurrencyId = intCurrencyId FROM tblCMBankAccount  WHERE intBankAccountId = @intBankAccountId 
SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference

IF @intCurrencyId IS NULL 
BEGIN
	RAISERROR('Bank Currency was not set.', 11, 1)
	RETURN 0
END
IF @intDefaultCurrencyId IS NULL 
BEGIN
	RAISERROR('Default Currency was not set.', 11, 1)
	RETURN 0
END
IF @intCurrencyId = @intDefaultCurrencyId SET @isForeignCurrency = 0


SELECT	intBankAccountId = @intBankAccountId,
		dblBalance = [dbo].[fnCMGetBankBalance] (@intBankAccountId, @dtmDate, @isForeignCurrency)
