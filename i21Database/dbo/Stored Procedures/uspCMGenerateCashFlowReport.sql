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
	@intBankAccountId INT,
	@intCompanyLocationId INT

	-- Get Filters
	SELECT @dtmReportDate = dtmReportDate, @intReportingCurrencyId = intReportingCurrencyId, @intBankAccountId = intBankAccountId, @intCompanyLocationId = intCompanyLocationId FROM tblCMCashFlowReport WHERE intCashFlowReportId = @intCashFlowReportId

	-- Total Cash
	EXEC [dbo].[uspCMGetTotalCashForecastReport] @intCashFlowReportId = @intCashFlowReportId, @dtmReportDate = @dtmReportDate, @intReportingCurrencyId = @intReportingCurrencyId, @intBankAccountId = @intBankAccountId, @intCompanyLocationId = @intCompanyLocationId
		

 END
