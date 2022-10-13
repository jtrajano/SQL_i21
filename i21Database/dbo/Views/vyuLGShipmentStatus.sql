CREATE VIEW [dbo].[vyuLGShipmentStatus]
AS
SELECT
L.intLoadId,
strShipmentStatus = CASE L.intShipmentStatus
	WHEN 1 THEN 
		CASE WHEN (L.dtmLoadExpiration IS NOT NULL AND GETDATE() > L.dtmLoadExpiration AND L.intShipmentType = 1
					AND L.intTicketId IS NULL AND L.intLoadHeaderId IS NULL)
			THEN 'Expired'
			ELSE 
				CASE WHEN (L.intTransUsedBy = 3 AND L.intDriverEntityId IS NULL)
				THEN 'Created'
				ELSE 'Scheduled' END
			END
	WHEN 2 THEN 'Dispatched'
	WHEN 3 THEN 
		CASE WHEN (L.ysnDocumentsApproved = 1 
					AND L.dtmDocumentsApproved IS NOT NULL
					AND ((L.dtmDocumentsApproved > L.dtmArrivedInPort OR L.dtmArrivedInPort IS NULL)
					AND (L.dtmDocumentsApproved > L.dtmCustomsReleased OR L.dtmCustomsReleased IS NULL))) 
					THEN 'Documents Approved'
			WHEN (L.ysnCustomsReleased = 1) THEN 'Customs Released'
			WHEN (L.ysnArrivedInPort = 1) THEN 'Arrived in Port'
			ELSE 
				CASE WHEN (L.intTransUsedBy = 3 AND L.intLoadHeaderId IS NOT NULL)
				THEN 'In Progress'
				ELSE 'Inbound Transit' END
			 END
	WHEN 4 THEN 
		CASE WHEN (L.intTransUsedBy = 3)
				THEN 'Completed'
				ELSE 'Received' END
	WHEN 5 THEN 
		CASE WHEN (L.ysnDocumentsApproved = 1 
					AND L.dtmDocumentsApproved IS NOT NULL
					AND ((L.dtmDocumentsApproved > L.dtmArrivedInPort OR L.dtmArrivedInPort IS NULL)
					AND (L.dtmDocumentsApproved > L.dtmCustomsReleased OR L.dtmCustomsReleased IS NULL))) 
					THEN 'Documents Approved'
			WHEN (L.ysnCustomsReleased = 1) THEN 'Customs Released'
			WHEN (L.ysnArrivedInPort = 1) THEN 'Arrived in Port'
			ELSE 'Outbound Transit' END
	WHEN 6 THEN 
		CASE WHEN (L.ysnDocumentsApproved = 1 
					AND L.dtmDocumentsApproved IS NOT NULL
					AND ((L.dtmDocumentsApproved > L.dtmArrivedInPort OR L.dtmArrivedInPort IS NULL)
					AND (L.dtmDocumentsApproved > L.dtmCustomsReleased OR L.dtmCustomsReleased IS NULL))) 
					THEN 'Documents Approved'
			WHEN (L.ysnCustomsReleased = 1) THEN 'Customs Released'
			WHEN (L.ysnArrivedInPort = 1) THEN 'Arrived in Port'
			ELSE 
				CASE WHEN (L.intTransUsedBy = 3)
				THEN 'Completed'
				ELSE 'Delivered' END
			 END
	WHEN 7 THEN 
		CASE WHEN (ISNULL(L.strBookingReference, '') <> '') THEN 'Booked'
				ELSE 'Shipping Instruction Created' END
	WHEN 8 THEN 'Partial Shipment Created'
	WHEN 9 THEN 'Full Shipment Created'
	WHEN 10 THEN 'Cancelled'
	WHEN 11 THEN 'Invoiced'
	WHEN 12 THEN 'Rejected'
	ELSE '' END COLLATE Latin1_General_CI_AS
FROM tblLGLoad L