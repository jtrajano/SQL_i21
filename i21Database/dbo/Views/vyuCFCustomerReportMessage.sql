CREATE VIEW [dbo].[vyuCFCustomerReportMessage]
AS
SELECT        
intCustomerId, 
intAccountId, 
ISNULL(dbo.fnCFGetDefaultComment(NULL, intCustomerId, N'CF Quote', NULL, N'Header', NULL, 1),'')  COLLATE Latin1_General_CI_AS AS strHtmlQuoteReportHeaderMessage, 
ISNULL(dbo.fnCFGetDefaultComment(NULL, intCustomerId, N'CF Quote', NULL,  N'Footer', NULL, 1),'') COLLATE Latin1_General_CI_AS AS strHtmlQuoteReportFooterMessage,
ISNULL(dbo.fnCFGetDefaultComment(NULL, intCustomerId, N'CF Quote', NULL, N'Header', NULL, 0),'')  COLLATE Latin1_General_CI_AS AS strQuoteReportHeaderMessage, 
ISNULL(dbo.fnCFGetDefaultComment(NULL, intCustomerId, N'CF Quote', NULL,  N'Footer', NULL, 0),'') COLLATE Latin1_General_CI_AS AS strQuoteReportFooterMessage
FROM            dbo.tblCFAccount