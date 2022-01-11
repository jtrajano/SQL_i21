CREATE PROCEDURE [dbo].[uspCMGenerateCashFlowReport]
(
	@intCashFlowReportId INT
)
AS
BEGIN
SET NOCOUNT, XACT_ABORT ON;

DECLARE
	@dtmReportDate DATETIME,
	@intReportingCurrencyId INT,
	@intBankId INT,
	@intBankAccountId INT,
	@intCompanyLocationId INT

	-- Get Filters
	SELECT 
		@dtmReportDate = dtmReportDate, 
		@intReportingCurrencyId = intReportingCurrencyId, 
		@intBankId = intBankId,
		@intBankAccountId = intBankAccountId, 
		@intCompanyLocationId = intCompanyLocationId 
	FROM 
		tblCMCashFlowReport 
	WHERE 
		intCashFlowReportId = @intCashFlowReportId

	-- Total Cash
	EXEC [dbo].[uspCMGenerateCMCashFlow] 
		@intCashFlowReportId = @intCashFlowReportId, 
		@dtmReportDate = @dtmReportDate, 
		@intReportingCurrencyId = @intReportingCurrencyId, 
		@intBankId = @intBankId, 
		@intBankAccountId = @intBankAccountId, 
		@intCompanyLocationId = @intCompanyLocationId

	-- Total AP
	EXEC [dbo].[uspCMGenerateAPCashFlow] 
		@intCashFlowReportId = @intCashFlowReportId, 
		@dtmReportDate = @dtmReportDate, 
		@intReportingCurrencyId = @intReportingCurrencyId, 
		@intBankId = @intBankId, 
		@intBankAccountId = @intBankAccountId, 
		@intCompanyLocationId = @intCompanyLocationId

	-- Total AR
	EXEC [dbo].[uspCMGenerateARCashFlow] 
		@intCashFlowReportId = @intCashFlowReportId, 
		@dtmReportDate = @dtmReportDate, 
		@intReportingCurrencyId = @intReportingCurrencyId, 
		@intBankId = @intBankId, 
		@intBankAccountId = @intBankAccountId, 
		@intCompanyLocationId = @intCompanyLocationId
 END
