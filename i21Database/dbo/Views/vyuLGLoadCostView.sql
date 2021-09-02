CREATE VIEW vyuLGLoadCostView
AS
SELECT LC.intLoadCostId
	  ,LC.intLoadId
	  ,LC.intItemId
	  ,LC.intVendorId AS intEntityId
	  ,LC.strEntityType
	  ,LC.strCostMethod
	  ,LC.intCurrencyId
	  ,C.strCurrency
	  ,LC.dblRate
	  ,LC.dblAmount
	  ,LC.intItemUOMId
	  ,LC.ysnAccrue
	  ,LC.ysnMTM
	  ,LC.ysnPrice
	  ,E.strName AS strEntityName
	  ,L.strLoadNumber
	  ,strShipmentStatus = CASE L.intShipmentStatus
			WHEN 1 THEN 
				CASE WHEN (L.dtmLoadExpiration IS NOT NULL AND GETDATE() > L.dtmLoadExpiration AND L.intShipmentType = 1
						AND L.intTicketId IS NULL AND L.intLoadHeaderId IS NULL)
				THEN 'Expired'
				ELSE 'Scheduled' END
			WHEN 2 THEN 'Dispatched'
			WHEN 3 THEN 
				CASE WHEN (L.ysnDocumentsApproved = 1 
						AND L.dtmDocumentsApproved IS NOT NULL
						AND ((L.dtmDocumentsApproved > L.dtmArrivedInPort OR L.dtmArrivedInPort IS NULL)
						AND (L.dtmDocumentsApproved > L.dtmCustomsReleased OR L.dtmCustomsReleased IS NULL))) 
						THEN 'Documents Approved'
					WHEN (L.ysnCustomsReleased = 1) THEN 'Customs Released'
					WHEN (L.ysnArrivedInPort = 1) THEN 'Arrived in Port'
					ELSE 'Inbound Transit' END
			WHEN 4 THEN 'Received'
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
					ELSE 'Delivered' END
			WHEN 7 THEN 
				CASE WHEN (ISNULL(L.strBookingReference, '') <> '') THEN 'Booked'
						ELSE 'Shipping Instruction Created' END
			WHEN 8 THEN 'Partial Shipment Created'
			WHEN 9 THEN 'Full Shipment Created'
			WHEN 10 THEN 'Cancelled'
			WHEN 11 THEN 'Invoiced'
			ELSE '' END COLLATE Latin1_General_CI_AS
	  ,UM.strUnitMeasure
	  ,I.strItemNo
	  ,B.strBillId
	  ,LC.intBillId
	  ,L.ysnArrivedInPort
	  ,L.ysnDocumentsApproved
	  ,L.ysnCustomsReleased
	  ,L.dtmArrivedInPort
	  ,L.dtmDocumentsApproved
	  ,L.dtmCustomsReleased
	  ,L.intBookId
	  ,BO.strBook
	  ,L.intSubBookId
	  ,SB.strSubBook
FROM tblLGLoadCost LC
JOIN tblEMEntity E ON E.intEntityId = LC.intVendorId
JOIN tblLGLoad L ON L.intLoadId = LC.intLoadId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = LC.intItemUOMId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblICItem I ON I.intItemId = LC.intItemId
LEFT JOIN tblSMCurrency C ON C.intCurrencyID = LC.intCurrencyId
LEFT JOIN tblAPBill B ON B.intBillId = LC.intBillId
LEFT JOIN tblCTBook BO ON BO.intBookId = L.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = L.intSubBookId