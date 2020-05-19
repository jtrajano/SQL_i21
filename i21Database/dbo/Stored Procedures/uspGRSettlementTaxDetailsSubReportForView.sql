CREATE PROCEDURE [dbo].[uspGRSettlementTaxDetailsSubReportForView]
	@intBillDetailId	int
as
begin
	if @intBillDetailId is null 
		select * from vyuGRSettlementTaxDetailsSubReport where 1 = 0
	else
		select * from vyuGRSettlementTaxDetailsSubReport where intBillDetailId = @intBillDetailId
end


GO