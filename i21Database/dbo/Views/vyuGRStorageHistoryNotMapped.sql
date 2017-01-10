CREATE VIEW [dbo].[vyuGRStorageHistoryNotMapped]
AS
SELECT    
 SH.intStorageHistoryId
,SH.intEntityId  
,E.strName  
,SH.intCompanyLocationId  
,LOC.strLocationName
,SH.intContractHeaderId
,CH.strContractNumber
,SH.intInvoiceId
,Inv.strInvoiceNumber
,SH.intBillId
,Bill.strBillId
FROM tblGRStorageHistory SH
LEFT JOIN tblEMEntity E ON E.intEntityId = SH.intEntityId
LEFT JOIN tblSMCompanyLocation LOC ON LOC.intCompanyLocationId = SH.intCompanyLocationId
LEFT JOIN vyuCTContractHeaderView CH ON CH.intContractHeaderId=SH.intContractHeaderId
LEFT JOIN tblARInvoice Inv ON Inv.intInvoiceId=SH.intInvoiceId
LEFT JOIN tblAPBill Bill ON Bill.intBillId=SH.intBillId
