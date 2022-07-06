CREATE VIEW [dbo].[vyuICGetTransferDetailSource]
AS

SELECT
intInventoryTransferDetailId = Detail.intInventoryTransferDetailId,
intInventoryTransferId = Detail.intInventoryTransferId,
strTransferNo = Transfer.strTransferNo,
intSourceType = Transfer.intSourceType,
intSourceId = 
CASE
    WHEN Transfer.intSourceType = 1 THEN Ticket.intTicketId
    --Transfer.intSourceType = 2 OBSOLETE
    WHEN Transfer.intSourceType = 3 THEN LoadHeader.intLoadHeaderId
    ELSE NULL
END
,
strSourceTransactionNo = 
CASE
    WHEN Transfer.intSourceType = 1 THEN Ticket.strTicketNumber
    --Transfer.intSourceType = 2 OBSOLETE
    WHEN Transfer.intSourceType = 3 THEN LoadHeader.strTransaction
    ELSE NULL
END COLLATE Latin1_General_CI_AS
,
strSourceModule = 
CASE
    WHEN Transfer.intSourceType = 1 THEN 'Ticket Management'
    --Transfer.intSourceType = 2 OBSOLETE
    WHEN Transfer.intSourceType = 3 THEN 'Transports'
    ELSE NULL
END COLLATE Latin1_General_CI_AS
,
strSourceScreen = 
CASE
    WHEN Transfer.intSourceType = 1 THEN 'Scale Ticket'
    --Transfer.intSourceType = 2 OBSOLETE
    WHEN Transfer.intSourceType = 3 THEN 'Transport Loads'
    ELSE NULL
END COLLATE Latin1_General_CI_AS
FROM
tblICInventoryTransferDetail Detail
INNER JOIN tblICInventoryTransfer Transfer
ON Detail.intInventoryTransferId = Transfer.intInventoryTransferId
LEFT JOIN tblSCTicket Ticket
ON Ticket.intTicketId = Detail.intSourceId AND Transfer.intSourceType = 1
LEFT JOIN tblTRLoadReceipt LoadReceipt
ON LoadReceipt.intLoadReceiptId = Detail.intSourceId AND Transfer.intSourceType = 3
LEFT JOIN tblTRLoadHeader LoadHeader
ON LoadHeader.intLoadHeaderId = LoadReceipt.intLoadHeaderId AND Transfer.intSourceType = 3