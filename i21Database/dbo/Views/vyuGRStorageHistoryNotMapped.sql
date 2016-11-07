CREATE VIEW [dbo].[vyuGRStorageHistoryNotMapped]
AS
SELECT    
 a.intStorageHistoryId
,a.intEntityId  
,E.strName  
,a.intCompanyLocationId  
,c.strLocationName
,a.intContractHeaderId
,CH.strContractNumber
,a.intInvoiceId
,Inv.strInvoiceNumber
,a.intBillId
,Bill.strBillId
FROM tblGRStorageHistory a
LEFT JOIN tblEMEntity E ON E.intEntityId = a.intEntityId
LEFT JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = a.intCompanyLocationId
LEFT JOIN vyuCTContractHeaderView CH ON CH.intContractHeaderId=a.intContractHeaderId
LEFT JOIN tblARInvoice Inv ON Inv.intInvoiceId=a.intInvoiceId
LEFT JOIN tblAPBill Bill ON Bill.intBillId=a.intBillId
