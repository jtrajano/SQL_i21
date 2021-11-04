CREATE PROCEDURE [dbo].[uspGRAPISettlementReportExportDelete]
	@guiApiUniqueId UniqueIdentifier
AS
	
	delete from tblGRAPISettlementReport where guiApiUniqueId = @guiApiUniqueId
	delete from tblGRAPISettlementSubReport where guiApiUniqueId = @guiApiUniqueId
	delete from tblGRAPISettlementTaxDetailsSubReport where guiApiUniqueId = @guiApiUniqueId
	delete from tblGRAPISettlementSummaryReport where guiApiUniqueId = @guiApiUniqueId
	delete from tblGRAPISettlementInboundSubReport where guiApiUniqueId = @guiApiUniqueId
	delete from tblGRAPISettlementOutboundSubReport where guiApiUniqueId = @guiApiUniqueId
RETURN 0
