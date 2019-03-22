CREATE VIEW [dbo].[vyuCFCustomerReportMessage]
AS
SELECT        
intCustomerId, 
intAccountId, 
ISNULL(dbo.fnCFGetDefaultComment(NULL, intCustomerId, N'CF Quote', NULL, N'Header', NULL, 1),'') AS strHtmlQuoteReportHeaderMessage, 
ISNULL(dbo.fnCFGetDefaultComment(NULL, intCustomerId, N'CF Quote', NULL,  N'Footer', NULL, 1),'') AS strHtmlQuoteReportFooterMessage,
ISNULL(dbo.fnCFGetDefaultComment(NULL, intCustomerId, N'CF Quote', NULL, N'Header', NULL, 0),'') AS strQuoteReportHeaderMessage, 
ISNULL(dbo.fnCFGetDefaultComment(NULL, intCustomerId, N'CF Quote', NULL,  N'Footer', NULL, 0),'') AS strQuoteReportFooterMessage
FROM            dbo.tblCFAccount