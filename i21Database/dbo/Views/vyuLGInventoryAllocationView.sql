CREATE VIEW vyuLGInventoryAllocationView
AS 
SELECT intKeyColumn = Convert(INT, ROW_NUMBER() OVER (ORDER BY dtmSStartDate DESC, strCustomer ASC))
	   ,*  
FROM (
	SELECT
		strStatus = 'In-transit' COLLATE Latin1_General_CI_AS
		,intContainerId = Shipment.intLoadContainerId
		,strContainerNumber = Shipment.strContainerNumber
		,strMarks = Shipment.strMarks
		,strLotNumber = CAST(NULL AS NVARCHAR(100))
		,strCargoNo = CAST(NULL AS NVARCHAR(100))
		,strWarrantNo = CAST(NULL AS NVARCHAR(100))
		,dblContainerQty = Shipment.dblContainerQty
		,dblOpenQuantity = CASE WHEN HP.ysnHasPickContainers IS NOT NULL 
							THEN
								CASE WHEN (Shipment.dblContainerQty - ISNULL(Shipment.dblContainerContractReceivedQty, 0.0) - ISNULL(PLD.dblLotPickedQty, 0)) < 0 THEN 0 
								ELSE
									Shipment.dblContainerQty - ISNULL(Shipment.dblContainerContractReceivedQty, 0.0) - ISNULL(PLD.dblLotPickedQty, 0)
								END
							ELSE 
								CASE WHEN (Shipment.dblContainerContractQty - ISNULL(Shipment.dblContainerContractReceivedQty, 0.0) 
									- ISNULL(CD.dblAllocatedQty, 0)) < 0 THEN 0 
								ELSE
									Shipment.dblContainerContractQty - ISNULL (Shipment.dblContainerContractReceivedQty, 0.0) 
									- COALESCE(CD.dblAllocatedQty, 0) 
								END
							END
		,dblAllocatedQty = CASE WHEN HP.ysnHasPickContainers IS NOT NULL 
								THEN ISNULL(PLD.dblLotPickedQty, 0)
								ELSE ISNULL(CD.dblAllocatedQty, 0) END
		,dblPledgedQty = CAST(0 AS NUMERIC(18, 6)) --UPDATE WITH PLEDGED QTY AFTER GL-7326
		,dblAllocatedPledgedQty = CASE WHEN HP.ysnHasPickContainers IS NOT NULL 
									THEN ISNULL(PLD.dblLotPickedQty, 0)
								ELSE ISNULL(CD.dblAllocatedQty, 0) END
						+ CAST(0 AS NUMERIC(18, 6)) --UPDATE WITH PLEDGED QTY AFTER GL-7326

		,strShippingLine = Shipment.strShippingLine
		,strVessel = Shipment.strMVessel
		,strIMONumber = L.strIMONumber
		,strDestinationCity = Shipment.strDestinationCity
		,strDestinationPort = Shipment.strDestinationPort
		,strTerminal = Shipment.strTerminal
		,strLoadSlip = L.strLoadNumber
		,strShippingMonth = CONVERT(NVARCHAR(4), YEAR(Shipment.dtmScheduledDate)) + CONVERT(NVARCHAR(2), Shipment.dtmScheduledDate, 101) 
		,strDeliveryMonth = CONVERT(NVARCHAR(4), YEAR(Shipment.dtmEndDate)) + CONVERT(NVARCHAR(2), Shipment.dtmEndDate, 101) 
		,strBookingReference = L.strBookingReference

		,strContractNumber = Shipment.strContractNumber
		,intContractSeq = Shipment.intContractSeq
		,strContractNumberDashSeq = Shipment.strContractNumber + '-' + CAST(Shipment.intContractSeq AS NVARCHAR(10))
		,strSContractNumber = SCH.strContractNumber
		,intSContractSeq = SCD.intContractSeq
		,strSContractNumberDashSeq = SCH.strContractNumber + '-' + CAST(SCD.intContractSeq AS NVARCHAR(10))
		,strCustomerContract = SCH.strCustomerContract
		,dtmSStartDate = SCD.dtmStartDate
		,strFinancialStatus = CASE WHEN CD.ysnFinalPNL = 1 THEN 'Final P&L Created'
									WHEN CD.ysnProvisionalPNL = 1 THEN 'Provisional P&L Created'
									WHEN BD.intContractDetailId IS NOT NULL THEN 'Purchase Invoice Received' 
									ELSE '' END
		,dblOriginalQty = Shipment.dblPurchaseContractOriginalQty
		,strOriginalQtyUOM = Shipment.strPurchaseContractOriginalUOM
		,dblStockQty = Shipment.dblContainerContractQty - IsNull (Shipment.dblContainerContractReceivedQty, 0.0)
		,strStockUOM = Shipment.strItemUOM

		,strVendor = Shipment.strVendor
		,strCustomer = ISNULL(Shipment.strCustomer, Cus.strName)

		,strCommodity = Shipment.strCommodity
		,strItemNo = Shipment.strItemNo
		,strItemDescription = Shipment.strItemDescription
		,strItemType = Shipment.strType
		,strItemSpecification = Shipment.strItemSpecification
		,strSItemSpecification = SCD.strItemSpecification
		,strGrade = Shipment.strGrade
		,strOrigin = Shipment.strOrigin

		,dtmETAPOL = Shipment.dtmETAPOL
		,dtmETSPOL = Shipment.dtmETSPOL
		,dtmETAPOD = Shipment.dtmETAPOD
		,dtmDeadlineBL = L.dtmDeadlineBL		
		,dtmDeadlineCargo = L.dtmDeadlineCargo
		,strBLNumber = Shipment.strBLNumber
		,dtmBLDate = Shipment.dtmBLDate
		,strBLReceived = CASE WHEN (L.dtmDeadlineBL IS NOT NULL) THEN 'Y' ELSE 'N' END
		,dtmLastFreeDate = Shipment.dtmLastFreeDate
		,dtmEmptyContainerReturn = Shipment.dtmEmptyContainerReturn
		,strCourierTrackingNumber = L.strCourierTrackingNumber
		,strComments = L.strComments
		
		,strWarehouse = Shipment.strSubLocationName
		,strLocationName = Shipment.strLocationName
		,dtmReceiptDate = Shipment.dtmReceiptDate

		,strSampleNumber
		,dtmSampleReceived
		,dtmSampleApproved

		,str4CLicenseNumber = L.str4CLicenseNumber
		,strExternalERPReferenceNumber = L.strExternalERPReferenceNumber

		,strBillId = B.strBillId 
		,strVendorOrderNumber = B.strVendorOrderNumber
		
		,LWC.strID1
		,LWC.strID2
		,LWC.strID3
	FROM vyuLGInboundShipmentView Shipment
		LEFT JOIN tblLGLoad L ON Shipment.intLoadId = L.intLoadId
		LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = Shipment.intContractDetailId
		LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = CD.intCurrencyId			
		LEFT JOIN tblSMCurrency	CY ON CY.intCurrencyID = CU.intMainCurrencyId
		LEFT JOIN tblLGAllocationDetail ALD ON ALD.intPContractDetailId = Shipment.intContractDetailId
		LEFT JOIN tblCTContractDetail SCD ON SCD.intContractDetailId = ALD.intSContractDetailId
		LEFT JOIN tblCTContractHeader SCH ON SCH.intContractHeaderId = SCD.intContractHeaderId
		LEFT JOIN tblEMEntity Cus ON Cus.intEntityId = SCH.intEntityId
		LEFT JOIN tblLGPickLotDetail PLD ON ALD.intAllocationDetailId = PLD.intAllocationDetailId AND PLD.intContainerId = Shipment.intLoadContainerId
		OUTER APPLY 
			(SELECT TOP 1 ysnHasPickContainers = CAST(1 AS BIT) 
				FROM tblLGPickLotDetail PLD1 INNER JOIN tblLGPickLotHeader PLD2 ON PLD2.intPickLotHeaderId = PLD1.intPickLotHeaderId
				WHERE PLD2.intType = 2 AND PLD1.intContainerId IN (SELECT intLoadContainerId FROM tblLGLoadContainer WHERE intLoadId = L.intLoadId)) HP
		LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = Shipment.intLoadContainerId
		OUTER APPLY 
			(SELECT TOP 1
				strSampleNumber,
				strSampleStatus = SS.strStatus, 
				dtmSampleReceived = S.dtmSampleReceivedDate,
				dtmSampleApproved = CASE WHEN (SS.strStatus = 'Approved') THEN dtmTestedOn ELSE NULL END
			FROM tblQMSample S JOIN tblQMSampleStatus AS SS ON SS.intSampleStatusId = S.intSampleStatusId
            WHERE S.intContractDetailId = Shipment.intContractDetailId) S
		LEFT JOIN tblAPBillDetail BD ON BD.intLoadDetailId = Shipment.intLoadDetailId
		LEFT JOIN tblAPBill B ON B.intBillId = BD.intBillId
	WHERE (Shipment.dblContainerContractQty - IsNull(Shipment.dblContainerContractReceivedQty, 0.0)) > 0.0 
	   AND Shipment.ysnInventorized = 1
	   AND Shipment.intLoadId NOT IN (SELECT intLoadId FROM tblARInvoice WHERE intLoadId IS NOT NULL)
	  
	UNION ALL

	SELECT
		strStatus = 'Spot' COLLATE Latin1_General_CI_AS
		,intContainerId = IRI.intContainerId
		,strContainerNumber = LC.strContainerNumber
		,strMarks = LC.strMarks
		,strLotNumber = Spot.strLotNumber
		,strCargoNo = Lot.strCargoNo
		,strWarrantNo = Lot.strWarrantNo
		,dblContainerQty = IRI.dblOpenReceive
		,dblOpenQuantity = Spot.dblQty - ISNULL(PLD.dblLotPickedQty, 0)
		,dblAllocatedQty = ISNULL(PLD.dblLotPickedQty, 0)
		,dblPledgedQty = CAST(0 AS NUMERIC(18, 6)) --UPDATE WITH PLEDGED QTY AFTER GL-7326
		,dblAllocatedPledgedQty = ISNULL(PLD.dblLotPickedQty, 0)
						+ CAST(0 AS NUMERIC(18, 6)) --UPDATE WITH PLEDGED QTY AFTER GL-7326
		,strShippingLine = SL.strName
		,strVessel = L.strMVessel
		,strIMONumber = L.strIMONumber
		,strDestinationCity = L.strDestinationCity
		,strDestinationPort = L.strDestinationPort
		,strTerminal = TM.strName
		,strLoadSlip = Spot.strReceiptNumber
		,strShippingMonth = CONVERT(NVARCHAR(4), YEAR(L.dtmScheduledDate)) + CONVERT(NVARCHAR(2), L.dtmScheduledDate, 101) 
		,strDeliveryMonth = CONVERT(NVARCHAR(4), YEAR(L.dtmEndDate)) + CONVERT(NVARCHAR(2), L.dtmEndDate, 101) 
		,strBookingReference = L.strBookingReference

		,strContractNumber = Spot.strContractNumber
		,intContractSeq = Spot.intContractSeq
		,strContractNumberDashSeq = Spot.strContractNumber + '-' + CAST(Spot.intContractSeq AS NVARCHAR(10))
		,strSContractNumber = SCH.strContractNumber
		,intSContractSeq = SCD.intContractSeq
		,strSContractNumberDashSeq = SCH.strContractNumber + '-' + CAST(SCD.intContractSeq AS NVARCHAR(10))
		,strCustomerContract = SCH.strCustomerContract
		,dtmSStartDate = SCD.dtmStartDate
		,strFinancialStatus = CASE WHEN CD.ysnFinalPNL = 1 THEN 'Final P&L Created'
									WHEN CD.ysnProvisionalPNL = 1 THEN 'Provisional P&L Created'
									WHEN BD.intContractDetailId IS NOT NULL THEN 'Purchase Invoice Received' 
									ELSE '' END
		,dblOriginalQty = Spot.dblOriginalQty
		,strOriginalQtyUOM = Spot.strOriginalQtyUOM
		,dblStockQty = Spot.dblQty
		,strStockUOM = Spot.strItemUOM

		,strVendor = Spot.strVendor
		,strCustomer = ISNULL(Spot.strCustomer, Cus.strName)

		,strCommodity = Spot.strCommodity
		,strItemNo = Spot.strItemNo
		,strItemDescription = Spot.strItemDescription
		,strItemType = Spot.strItemType
		,strItemSpecification = Spot.strItemSpecification
		,strSItemSpecification = SCD.strItemSpecification
		,strGrade = Spot.strGrade
		,strOrigin = Spot.strOrigin

		,dtmETAPOL = Spot.dtmETAPOL
		,dtmETSPOL = Spot.dtmETSPOL
		,dtmETAPOD = Spot.dtmETAPOD
		,dtmDeadlineBL = L.dtmDeadlineBL		
		,dtmDeadlineCargo = L.dtmDeadlineCargo
		,strBLNumber = Spot.strBLNumber
		,dtmBLDate = Spot.dtmBLDate
		,strBLReceived = CASE WHEN (L.dtmDeadlineBL IS NOT NULL) THEN 'Y' ELSE 'N' END
		,dtmLastFreeDate = LW.dtmLastFreeDate
		,dtmEmptyContainerReturn = LW.dtmEmptyContainerReturn
		,strCourierTrackingNumber = L.strCourierTrackingNumber
		,strComments = IRI.strComments
		
		,strWarehouse = Spot.strSubLocationName
		,strLocationName = Spot.strLocationName
		,dtmReceiptDate = Spot.dtmReceiptDate

		,strSampleNumber
		,dtmSampleReceived
		,dtmSampleApproved

		,str4CLicenseNumber = L.str4CLicenseNumber
		,strExternalERPReferenceNumber = L.strExternalERPReferenceNumber

		,strBillId = B.strBillId 
		,strVendorOrderNumber = B.strVendorOrderNumber
		
		,LWC.strID1
		,LWC.strID2
		,LWC.strID3
	FROM vyuLGPickOpenInventoryLots Spot
		LEFT JOIN tblICLot Lot ON Lot.intLotId = Spot.intLotId
		LEFT JOIN tblICInventoryReceiptItemLot IRIL ON IRIL.intLotId = Spot.intLotId
		LEFT JOIN tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptItemId = IRIL.intInventoryReceiptItemId
		LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = IRI.intContainerId
		LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
		LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
		LEFT JOIN tblLGLoad L ON L.intLoadId = LC.intLoadId
		LEFT JOIN tblEMEntity SL ON SL.intEntityId = L.intShippingLineEntityId
		LEFT JOIN tblEMEntity TM ON TM.intEntityId = L.intTerminalEntityId
		LEFT JOIN tblLGPickLotDetail PLD ON PLD.intLotId = Spot.intLotId
		LEFT JOIN tblLGAllocationDetail ALD ON ALD.intAllocationDetailId = PLD.intAllocationDetailId
		LEFT JOIN tblCTContractDetail SCD ON SCD.intContractDetailId = ALD.intSContractDetailId
		LEFT JOIN tblCTContractHeader SCH ON SCH.intContractHeaderId = SCD.intContractHeaderId
		LEFT JOIN tblEMEntity Cus ON Cus.intEntityId = SCH.intEntityId
		LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = Spot.intContractDetailId
		OUTER APPLY 
			(SELECT TOP 1
				strSampleNumber,
				strSampleStatus = SS.strStatus, 
				dtmSampleReceived = S.dtmSampleReceivedDate,
				dtmSampleApproved = CASE WHEN (SS.strStatus = 'Approved') THEN dtmTestedOn ELSE NULL END
			FROM tblQMSample S JOIN tblQMSampleStatus AS SS ON SS.intSampleStatusId = S.intSampleStatusId
            WHERE S.intContractDetailId = Spot.intContractDetailId) S
		OUTER APPLY 
				(SELECT TOP 1 ysnHasPickLots = CAST(1 AS BIT) 
					FROM tblLGPickLotDetail PLD1 INNER JOIN tblLGPickLotHeader PLD2 ON PLD2.intPickLotHeaderId = PLD1.intPickLotHeaderId
					WHERE PLD2.intType = 1 AND PLD1.intLotId = Spot.intLotId) HP
		LEFT JOIN tblAPBillDetail BD ON BD.intInventoryReceiptItemId = IRIL.intInventoryReceiptItemId
		LEFT JOIN tblAPBill B ON B.intBillId = BD.intBillId
	WHERE Spot.dblQty > 0.0

	UNION ALL

	--Drop Ship
	SELECT
		strStatus = 'In-transit' COLLATE Latin1_General_CI_AS
		,intContainerId = LC.intLoadContainerId
		,strContainerNumber = LC.strContainerNumber
		,strMarks = LC.strMarks
		,strLotNumber = CAST(NULL AS NVARCHAR(100))
		,strCargoNo = CAST(NULL AS NVARCHAR(100))
		,strWarrantNo = CAST(NULL AS NVARCHAR(100))
		,dblContainerQty = COALESCE(LC.dblQuantity, LD.dblQuantity, 0)
		,dblOpenQuantity = CAST(0 AS NUMERIC(18, 6))
		,dblAllocatedQty = COALESCE(LC.dblQuantity, LD.dblQuantity, 0)
		,dblPledgedQty = CAST(0 AS NUMERIC(18, 6)) --UPDATE WITH PLEDGED QTY AFTER GL-7326
		,dblAllocatedPledgedQty = COALESCE(LC.dblQuantity, LD.dblQuantity, 0) + CAST(0 AS NUMERIC(18, 6)) --UPDATE WITH PLEDGED QTY AFTER GL-7326
		,strShippingLine = SL.strName
		,strVessel = L.strMVessel
		,strIMONumber = L.strIMONumber
		,strDestinationCity = L.strDestinationCity
		,strDestinationPort = L.strDestinationPort
		,strTerminal = TM.strName
		,strLoadSlip = L.strLoadNumber
		,strShippingMonth = CONVERT(NVARCHAR(4), YEAR(L.dtmScheduledDate)) + CONVERT(NVARCHAR(2), L.dtmScheduledDate, 101) 
		,strDeliveryMonth = CONVERT(NVARCHAR(4), YEAR(PCD.dtmEndDate)) + CONVERT(NVARCHAR(2), PCD.dtmEndDate, 101) 
		,strBookingReference = L.strBookingReference

		,strContractNumber = PCH.strContractNumber
		,intContractSeq = PCD.intContractSeq
		,strContractNumberDashSeq = PCH.strContractNumber + '-' + CAST(PCD.intContractSeq AS NVARCHAR(10))
		,strSContractNumber = SCH.strContractNumber
		,intSContractSeq = SCD.intContractSeq
		,strSContractNumberDashSeq = SCH.strContractNumber + '-' + CAST(SCD.intContractSeq AS NVARCHAR(10))
		,strCustomerContract = SCH.strCustomerContract
		,dtmSStartDate = SCD.dtmStartDate
		,strFinancialStatus = CASE WHEN PCD.ysnFinalPNL = 1 THEN 'Final P&L Created'
									WHEN PCD.ysnProvisionalPNL = 1 THEN 'Provisional P&L Created'
									WHEN BD.intContractDetailId IS NOT NULL THEN 'Purchase Invoice Received' 
									ELSE '' END
		,dblOriginalQty = PCD.dblQuantity
		,strOriginalQtyUOM = PUM.strUnitMeasure
		,dblStockQty = LC.dblQuantity
		,strStockUOM = LDUM.strUnitMeasure

		,strVendor = V.strName
		,strCustomer = C.strName

		,strCommodity = CMDT.strCommodityCode
		,strItemNo = I.strItemNo
		,strItemDescription = I.strDescription
		,strItemType = I.strType
		,strItemSpecification = PCD.strItemSpecification
		,strSItemSpecification = SCD.strItemSpecification
		,strGrade = GRADE.strDescription
		,strOrigin = ORIGIN.strDescription

		,dtmETAPOL = L.dtmETAPOL
		,dtmETSPOL = L.dtmETSPOL
		,dtmETAPOD = L.dtmETAPOD
		,dtmDeadlineBL = L.dtmDeadlineBL		
		,dtmDeadlineCargo = L.dtmDeadlineCargo
		,strBLNumber = L.strBLNumber
		,dtmBLDate = L.dtmBLDate
		,strBLReceived = CASE WHEN (L.dtmDeadlineBL IS NOT NULL) THEN 'Y' ELSE 'N' END
		,dtmLastFreeDate = LW.dtmLastFreeDate
		,dtmEmptyContainerReturn = LW.dtmEmptyContainerReturn
		,strCourierTrackingNumber = L.strCourierTrackingNumber
		,strComments = L.strComments
		
		,strWarehouse = SLOC.strSubLocationName
		,strLocationName = CLOC.strLocationName
		,dtmReceiptDate = CAST(NULL AS DATETIME)

		,strSampleNumber
		,dtmSampleReceived
		,dtmSampleApproved

		,str4CLicenseNumber = L.str4CLicenseNumber
		,strExternalERPReferenceNumber = L.strExternalERPReferenceNumber

		,strBillId = B.strBillId 
		,strVendorOrderNumber = B.strVendorOrderNumber
		
		,LWC.strID1
		,LWC.strID2
		,LWC.strID3
	FROM tblLGLoadDetail LD
		INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
		LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
		LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
		LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
		LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
		LEFT JOIN tblSMCompanyLocationSubLocation SLOC ON SLOC.intCompanyLocationSubLocationId = LW.intSubLocationId
		LEFT JOIN tblSMCompanyLocation CLOC ON CLOC.intCompanyLocationId = SLOC.intCompanyLocationId
		LEFT JOIN tblICItem I ON I.intItemId = LD.intItemId
		LEFT JOIN tblICItemUOM LDUOM ON LDUOM.intItemUOMId = LD.intItemUOMId
		LEFT JOIN tblICUnitMeasure LDUM ON LDUM.intUnitMeasureId = LDUOM.intUnitMeasureId 
		LEFT JOIN tblICCommodity CMDT ON CMDT.intCommodityId = I.intCommodityId
		LEFT JOIN tblICCommodityAttribute GRADE ON GRADE.intCommodityAttributeId = I.intGradeId
		LEFT JOIN tblICCommodityAttribute ORIGIN ON ORIGIN.intCommodityAttributeId = I.intOriginId
		--Purchase
		INNER JOIN tblCTContractDetail PCD ON PCD.intContractDetailId = LD.intPContractDetailId
		INNER JOIN tblCTContractHeader PCH ON PCH.intContractHeaderId = PCD.intContractHeaderId
		LEFT JOIN tblICUnitMeasure PUM ON PUM.intUnitMeasureId = PCD.intUnitMeasureId
		LEFT JOIN tblEMEntity V ON V.intEntityId = LD.intVendorEntityId
		LEFT JOIN tblEMEntity SL ON SL.intEntityId = L.intShippingLineEntityId
		LEFT JOIN tblEMEntity TM ON TM.intEntityId = L.intTerminalEntityId
		LEFT JOIN tblAPBillDetail BD ON BD.intContractDetailId = PCD.intContractDetailId AND LD.intLoadDetailId = BD.intLoadDetailId
		LEFT JOIN tblAPBill B ON B.intBillId = BD.intBillId
		OUTER APPLY 
			(SELECT TOP 1
				strSampleNumber,
				strSampleStatus = SS.strStatus, 
				dtmSampleReceived = S.dtmSampleReceivedDate,
				dtmSampleApproved = CASE WHEN (SS.strStatus = 'Approved') THEN dtmTestedOn ELSE NULL END
			FROM tblQMSample S JOIN tblQMSampleStatus AS SS ON SS.intSampleStatusId = S.intSampleStatusId
            WHERE S.intContractDetailId = PCD.intContractDetailId) S
		--Sales
		INNER JOIN tblCTContractDetail SCD ON SCD.intContractDetailId = LD.intSContractDetailId
		INNER JOIN tblCTContractHeader SCH ON SCH.intContractHeaderId = SCD.intContractHeaderId
		LEFT JOIN tblEMEntity C ON C.intEntityId = LD.intCustomerEntityId
		LEFT JOIN tblARInvoiceDetail ID ON SCD.intContractDetailId = ID.intContractDetailId AND LD.intLoadDetailId = ID.intLoadDetailId
		LEFT JOIN tblARInvoice IV ON IV.intInvoiceId = ID.intInvoiceId
	WHERE L.intPurchaseSale = 3 AND L.ysnPosted = 1
		AND IV.strInvoiceNumber IS NULL
		AND LD.intPickLotDetailId IS NULL
	) t1
