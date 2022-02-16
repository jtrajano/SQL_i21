CREATE PROCEDURE [dbo].[uspGRSettlementSubReportForView]
	@intBillDetailId	int
as
begin
	if @intBillDetailId is null 
		select * from vyuGRSettlementSubNoTaxClassReport where 1 = 0
	else
		select * from vyuGRSettlementSubNoTaxClassReport where intBillDetailId = @intBillDetailId
end


GO