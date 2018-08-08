CREATE VIEW [dbo].[vyuAPBasisAdvanceTicket]
AS SELECT 
	AP.intBillId
	,AP.strBillId
	,APBD.ysnRestricted
	,AP.ysnPosted
	,APBD.intScaleTicketId
	,SC.strTicketNumber
FrOM tblAPBill AP
INNER JOIN tblAPBillDetail APBD ON APBD.intBillId = AP.intBillId
INNER JOIN tblSCTicket SC ON SC.intTicketId = APBD.intScaleTicketId
WHERE intTransactionType = 13  AND APBD.ysnRestricted = 1

GO