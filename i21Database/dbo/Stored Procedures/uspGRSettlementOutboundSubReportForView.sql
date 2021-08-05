CREATE PROCEDURE [dbo].[uspGRSettlementOutboundSubReportForView]
	@intPaymentId	int
as
begin
	if @intPaymentId is null 
		select * from vyuGRSettlementOutboundSubReport where 1 = 0
	else
		select * from vyuGRSettlementOutboundSubReport where intPaymentId = @intPaymentId
end


GO