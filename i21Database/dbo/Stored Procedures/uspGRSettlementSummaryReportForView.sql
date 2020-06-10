CREATE PROCEDURE [dbo].[uspGRSettlementSummaryReportForView]
	@intPaymentId	int
as
begin
	if @intPaymentId is null 
		select * from vyuGRSettlementSummaryReport where 1 = 0
	else
		select * from vyuGRSettlementSummaryReport where intPaymentId = @intPaymentId
end


GO