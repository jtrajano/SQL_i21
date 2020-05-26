CREATE PROCEDURE [dbo].[uspGRSettlementInboundSubReportForView]
	@intPaymentId	int
as
begin
	if @intPaymentId is null 
		select * from vyuGRSettlementInboundSubReport where 1 = 0
	else
		select * from vyuGRSettlementInboundSubReport where intPaymentId = @intPaymentId
end


GO