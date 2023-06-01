CREATE VIEW vyuQMSearchPreInvoiceCatalogueReconciliation
AS
SELECT intBillDetailId					    = BD.intBillDetailId 
	 , intSaleYear							= BD.intSaleYear
	 , strBuyingCenter						= CL.strLocationName
	 , strSaleNumber						= BD.strSaleNumber
	 , strTeaType							= CT.strCatalogueType
     , strSupplier							= E.strName
     , strChannel							= MZ.strMarketZoneCode
     , strSupplierPreInvoiceNo				= B.strVendorOrderNumber
	 , strCompanyCode						= PG.strName
	 , dtmSupplierPreInvoiceDate			= B.dtmDate
	 , dtmPromptDate						= BD.dtmExpectedDate
	 , dtmSaleDate							= BD.dtmSaleDate
	 , strLotNo								= BD.strVendorLotNumber
     , dblSupplierPreInvoicePrice			= BD.dblCost
	 , dblSupplierPrice						= S.dblB1Price
     , dblPreInvoiceLotQty					= BD.dblQtyReceived
	 , dblLotQty							= MFB.dblTotalQuantity 
     , dblTotalNoPackageBreakups			= ISNULL(BD.dblPackageBreakups, 0)
	 , intPreInvoiceGardenMarkId			= GM.intGardenMarkId
     , strPreInvoiceGarden					= GM.strGardenMark
	 , intGardenMarkId						= S.intGardenMarkId
	 , strGarden							= GMS.strGardenMark
	 , intPreInvoiceGradeId					= CA.intCommodityAttributeId
     , strPreInvoiceGrade					= CA.strDescription
	 , intGradeId							= S.intGradeId
	 , strGrade								= CAS.strDescription
     , strPreInvoiceGardenInvoiceNo			= BD.strPreInvoiceGardenNumber
	 , strGardenInvoiceNo					= S.strChopNumber
     , strPreInvoicePurchaseType			= BD.strPreInvoicePurchaseType
     , strPreInvoiceDocumentNo				= BD.strBillOfLading
     , dblNetWtPackages						= CAST(BD.intNumOfPackagesUOM AS NUMERIC(18,6)) --BD.dblNetWeightPerPackage
     , dblNoPackages						= BD.dblNumberOfPackages
     , dblNetWt2ndPackages					= CAST(BD.intNumOfPackagesUOM2 AS NUMERIC(18,6)) --BD.dblNetWeightPerPackage2
     , dblNo2ndPackages						= BD.dblNumberOfPackages2
     , dblNetWt3rdPackages					= CAST(BD.intNumOfPackagesUOM3 AS NUMERIC(18,6)) --BD.dblNetWeightPerPackage3
     , dblNo3rdPackages						= BD.dblNumberOfPackages3
     , strWarehouseCode						= SL.strName
	 , intSampleId							= S.intSampleId
	 , strSampleNumber						= S.strSampleNumber
	 , ysnApproved							= CASE WHEN SMT.intTransactionId IS NULL OR SMT.strApprovalStatus NOT IN ('No Need for Approval', 'Approved') THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END
	 , strApprovalStatus					= SMT.strApprovalStatus
	 , intCatalogueReconciliationId			= CR.intCatalogueReconciliationId
	 , strReconciliationNumber				= CR.strReconciliationNumber
	 , strBatchId							= MFB.strBatchId
	 , intBatchId							= MFB.intBatchId
FROM tblAPBillDetail BD
INNER JOIN tblAPBill B ON BD.intBillId = B.intBillId
INNER JOIN tblQMSaleYear SY ON CAST(BD.intSaleYear AS NVARCHAR(10)) = SY.strSaleYear
INNER JOIN tblQMSample S ON S.intSaleYearId = SY.intSaleYearId 
		                AND S.intLocationId = BD.intLocationId
						AND S.strSaleNumber = BD.strSaleNumber
						AND S.intCatalogueTypeId = BD.intCatalogueTypeId
						AND S.intEntityId = B.intEntityVendorId
						AND S.intMarketZoneId = BD.intMarketZoneId
						AND S.strRepresentLotNumber = BD.strVendorLotNumber
LEFT JOIN tblEMEntity E ON B.intEntityVendorId = E.intEntityId
LEFT JOIN tblSMCompanyLocation CL ON B.intShipToId = CL.intCompanyLocationId
LEFT JOIN tblQMCatalogueReconciliationDetail CRD ON BD.intBillDetailId = CRD.intBillDetailId
LEFT JOIN tblQMCatalogueReconciliation CR ON CRD.intCatalogueReconciliationId = CR.intCatalogueReconciliationId
LEFT JOIN tblICStorageLocation SL ON BD.intStorageLocationId = SL.intStorageLocationId
LEFT JOIN tblARMarketZone MZ ON BD.intMarketZoneId = MZ.intMarketZoneId
LEFT JOIN tblSMPurchasingGroup PG ON BD.intPurchasingGroupId = PG.intPurchasingGroupId
LEFT JOIN tblQMCatalogueType CT ON BD.intCatalogueTypeId = CT.intCatalogueTypeId
LEFT JOIN tblQMGardenMark GM ON BD.intGardenMarkId = GM.intGardenMarkId
LEFT JOIN tblQMGardenMark GMS ON S.intGardenMarkId = GMS.intGardenMarkId
LEFT JOIN tblICCommodityAttribute CA ON BD.strComment = CA.strDescription AND CA.strType = 'Grade'
LEFT JOIN tblICCommodityAttribute CAS ON S.intGradeId = CAS.intCommodityAttributeId AND CAS.strType = 'Grade'
LEFT JOIN tblSMTransaction SMT ON CR.strReconciliationNumber = SMT.strTransactionNo AND CR.intCatalogueReconciliationId = SMT.intRecordId
LEFT JOIN tblMFBatch MFB ON S.intSampleId = MFB.intSampleId AND MFB.intLocationId = MFB.intBuyingCenterLocationId
WHERE (CRD.intCatalogueReconciliationDetailId IS NULL
    OR (CRD.intCatalogueReconciliationDetailId IS NOT NULL 
	  AND (SMT.intTransactionId IS NOT NULL AND SMT.strApprovalStatus NOT IN ('No Need for Approval', 'Approved')))
	  )