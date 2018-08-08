CREATE VIEW [dbo].[vyuAPBasisAdvanceTicket]

AS

SELECT 
AP.intBillId
,AP.strBillId
,APBD.ysnRestricted
,AP.ysnPosted
,APBD.intScaleTicketId
,SC.strTicketNumber
FrOM tblAPBill AP
INNER JOIN tblAPBillDetail APBD ON APBD.intBillId = AP.intBillId
INNER JOIN tblSCTicket SC ON SC.intTicketId = APBD.intScaleTicketId
where intTransactionType = 13 

GO