CREATE VIEW [dbo].[vyuICCompactInventoryTransferDetail]
AS

	SELECT 
	TransferDetail.intInventoryTransferId
	, TransferDetail.intInventoryTransferDetailId
	, [Transfer].strTransferNo
	, strSourceNumber =
		(
			CASE 
				WHEN [Transfer].intSourceType = 1 THEN -- Scale
					ScaleTicket.strTicketNumber
				WHEN [Transfer].intSourceType = 2 THEN -- Inbound Shipment
					LGShipment.strTrackingNumber
				WHEN [Transfer].intSourceType = 3 THEN -- Transports
					TransportLoad.strTransaction
				ELSE 
					NULL
			END
		) COLLATE Latin1_General_CI_AS

	, strUnitMeasure = ItemUOM.strUnitMeasure
	, dblItemUOMCF = ItemUOM.dblUnitQty
	, TransferDetail.dblQuantity

	FROM tblICInventoryTransferDetail TransferDetail
		LEFT JOIN tblICInventoryTransfer [Transfer] ON [Transfer].intInventoryTransferId = TransferDetail.intInventoryTransferId
		LEFT JOIN vyuICGetItemUOM ItemUOM ON ItemUOM.intItemUOMId = TransferDetail.intItemUOMId
		OUTER APPLY (					
			SELECT TOP 1
				strTicketNumber
			FROM 
				tblSCTicket
			WHERE 
				intTicketId = TransferDetail.intSourceId
				AND [Transfer].intSourceType = 1 -- Scale Ticket 
		) ScaleTicket
		OUTER APPLY (
			SELECT TOP 1
				strTrackingNumber = CAST(ISNULL(intTrackingNumber, 'Inbound Shipment not found!') AS NVARCHAR(50))
			FROM 
				tblLGShipment lg
			WHERE 
				lg.intShipmentId = TransferDetail.intSourceId
				AND [Transfer].intSourceType = 2 -- Inbound Shipment			
		) LGShipment
		OUTER APPLY (				
			SELECT TOP 1
				strTransaction = CAST(ISNULL(TransportView.strTransaction, 'Transport not found!') AS NVARCHAR(50))
			FROM vyuTRGetTransportLoadReceipt TransportView
			WHERE 
				[Transfer].intSourceType = 3 -- Transports
				AND TransportView.intLoadReceiptId = TransferDetail.intSourceId					
		) TransportLoad 