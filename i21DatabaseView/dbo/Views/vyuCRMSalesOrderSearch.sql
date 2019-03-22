CREATE VIEW [dbo].[vyuCRMSalesOrderSearch]
	AS
		select a.* from vyuSOSalesOrderSearch a where a.intSalesOrderId not in (select b.intSalesOrderId from tblCRMOpportunityQuote b)
