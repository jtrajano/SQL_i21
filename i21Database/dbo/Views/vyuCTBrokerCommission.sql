CREATE VIEW [dbo].[vyuCTBrokerCommission]
	AS SELECT ard.strTitle, bcp.* from tblCTBrkgCommn bcp 
	left join vyuARDocumentMaintenanceMessage ard on bcp.strComments = ard.strCode

