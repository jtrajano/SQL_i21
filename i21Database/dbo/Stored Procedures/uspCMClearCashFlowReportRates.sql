CREATE PROCEDURE [dbo].[uspCMClearCashFlowReportRates]
(
	@intCashFlowReportId INT
)
AS
	DELETE tblCMCashFlowReportRate WHERE intCashFlowReportId = @intCashFlowReportId
	DELETE tblCMCashFlowReportRateType WHERE intCashFlowReportId = @intCashFlowReportId

RETURN 0
