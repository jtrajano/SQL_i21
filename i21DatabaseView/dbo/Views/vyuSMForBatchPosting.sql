CREATE VIEW [dbo].[vyuSMForBatchPosting]
AS 
SELECT CAST (ROW_NUMBER() OVER (ORDER BY ForBatchPosting.dtmDate DESC) AS INT)	AS	intBatchPostingId, 
ForBatchPosting.strTransactionType	AS	strTransactionType, 
intTransactionId					AS	intTransactionId, 
strTransactionId					AS	strTransactionId, 
ForBatchPosting.intEntityId			AS	intEntityId, 
ISNULL(dblAmount, 0.0)				AS	dblAmount,
strVendorInvoiceNumber				AS	strVendorInvoiceNumber,
ISNULL(Entity.strName, '')			AS	strVendorName,
UserSecurity.strUserName			AS	strUserName,
ForBatchPosting.strDescription		AS	strDescription,
ForBatchPosting.dtmDate				AS	dtmDate,
strBatchId							AS  strBatchId
FROM 
(
	SELECT Journal.strTransactionType, Journal.intTransactionId, Journal.strTransactionId, Total.dblDebit as dblAmount, '' as strVendorInvoiceNumber, null as intEntityVendorId, Journal.intEntityId, Journal.dtmDate, Journal.strDescription, CONVERT(NVARCHAR(100), Journal.guid) as strBatchId
	FROM tblGLForBatchPosting Journal CROSS APPLY(SELECT SUM(dblDebit) dblDebit FROM tblGLJournalDetail Detail WHERE Detail.intJournalId = Journal.intTransactionId) Total
	UNION ALL
	SELECT strTransactionType, intTransactionId, strTransactionId, dblAmount, strVendorInvoiceNumber, intEntityVendorId, intEntityId, dtmDate, strDescription, strBatchId
	FROM tblSMForBatchPosting
) ForBatchPosting
LEFT JOIN tblEMEntity Entity ON ForBatchPosting.intEntityVendorId = Entity.intEntityId
INNER JOIN tblSMUserSecurity UserSecurity ON ForBatchPosting.intEntityId = UserSecurity.[intEntityId]
GO

