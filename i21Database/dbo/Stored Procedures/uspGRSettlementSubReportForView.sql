CREATE PROCEDURE [dbo].[uspGRSettlementSubReportForView]
	@intBillDetailId	int
as
begin
	if @intBillDetailId is null 
		select * from vyuGRSettlementSubReport where 1 = 0
	else
		select * from vyuGRSettlementSubReport where intBillDetailId = @intBillDetailId
end


GO