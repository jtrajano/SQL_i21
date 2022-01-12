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
		[dbo].[tblCMCashFlowReport]
	WHERE 
		intCashFlowReportId = @intCashFlowReportId

	-- Get Rate and Rate Type Filters
	DECLARE 
		@tblRateFilters [dbo].[CMCashFlowReportFilterRateTable],
		@tblRateTypeFilters [dbo].[CMCashFlowReportFilterRateTypeTable]

	INSERT INTO @tblRateFilters
	SELECT 
		intFilterCurrencyId,
		dblRateBucket1,
		dblRateBucket2,
		dblRateBucket3,
		dblRateBucket4,
		dblRateBucket5,
		dblRateBucket6,
		dblRateBucket7,
		dblRateBucket8,
		dblRateBucket9
	FROM tblCMCashFlowReportRate
	WHERE intCashFlowReportId = @intCashFlowReportId

	INSERT INTO @tblRateTypeFilters
	SELECT
		intFilterCurrencyId,
		intRateTypeBucket1,
		intRateTypeBucket2,
		intRateTypeBucket3,
		intRateTypeBucket4,
		intRateTypeBucket5,
		intRateTypeBucket6,
		intRateTypeBucket7,
		intRateTypeBucket8,
		intRateTypeBucket9
	FROM tblCMCashFlowReportRateType
	WHERE intCashFlowReportId = @intCashFlowReportId

	-- Total Cash
	EXEC [dbo].[uspCMGenerateCMCashFlow]
		@tblRateTypeFilters = @tblRateTypeFilters,
		@tblRateFilters = @tblRateFilters,
		@intCashFlowReportId = @intCashFlowReportId, 
		@dtmReportDate = @dtmReportDate, 
		@intReportingCurrencyId = @intReportingCurrencyId, 
		@intBankId = @intBankId, 
		@intBankAccountId = @intBankAccountId, 
		@intCompanyLocationId = @intCompanyLocationId

	-- Total AP
	EXEC [dbo].[uspCMGenerateAPCashFlow]
		@tblRateTypeFilters = @tblRateTypeFilters,
		@tblRateFilters = @tblRateFilters,
		@intCashFlowReportId = @intCashFlowReportId, 
		@dtmReportDate = @dtmReportDate, 
		@intReportingCurrencyId = @intReportingCurrencyId, 
		@intBankId = @intBankId, 
		@intBankAccountId = @intBankAccountId, 
		@intCompanyLocationId = @intCompanyLocationId

	-- Total AR
	EXEC [dbo].[uspCMGenerateARCashFlow]
		@tblRateTypeFilters = @tblRateTypeFilters,
		@tblRateFilters = @tblRateFilters,
		@intCashFlowReportId = @intCashFlowReportId, 
		@dtmReportDate = @dtmReportDate, 
		@intReportingCurrencyId = @intReportingCurrencyId, 
		@intBankId = @intBankId, 
		@intBankAccountId = @intBankAccountId, 
		@intCompanyLocationId = @intCompanyLocationId

	-- Logistics Shipments
	EXEC [dbo].[uspCMGenerateLGCashFlow]
		@tblRateTypeFilters = @tblRateTypeFilters,
		@tblRateFilters = @tblRateFilters,
		@intCashFlowReportId = @intCashFlowReportId, 
		@dtmReportDate = @dtmReportDate, 
		@intReportingCurrencyId = @intReportingCurrencyId, 
		@intBankId = @intBankId, 
		@intBankAccountId = @intBankAccountId, 
		@intCompanyLocationId = @intCompanyLocationId
 END
