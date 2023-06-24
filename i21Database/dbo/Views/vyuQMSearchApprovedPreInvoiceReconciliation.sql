CREATE VIEW vyuQMSearchApprovedPreInvoiceReconciliation
AS   --HEADER
SELECT intCatalogueReconciliationId			= CR.intCatalogueReconciliationId
     , strReconciliationNumber				= CR.strReconciliationNumber
     , strComments							= CR.strComments
     , dtmReconciliationDate				     = CR.dtmReconciliationDate	 
     , dtmPostDate							= CR.dtmPostDate
     , ysnPosted							= CR.ysnPosted
     , ysnApproved							= CASE WHEN SMT.intTransactionId IS NULL OR SMT.strApprovalStatus NOT IN ('No Need for Approval', 'Approved') THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END
     , strApprovalStatus                          = SMT.strApprovalStatus
     --DETAILS
     , intCatalogueReconciliationDetailId	     = CRD.intCatalogueReconciliationDetailId
     , intBillDetailId						= BD.intBillDetailId 
     , intConcurrencyId						= CRD.intConcurrencyId
     , strSupplierPreInvoiceNumber			     = CRD.strSupplierPreInvoiceNumber
     , dtmSupplierPreInvoiceDate			     = CRD.dtmSupplierPreInvoiceDate
     , dblBasePrice							= CRD.dblBasePrice
     , dblPreInvoicePrice					= CRD.dblPreInvoicePrice
     , dblQuantity							= CRD.dblQuantity
     , dblPreInvoiceQuantity				     = CRD.dblPreInvoiceQuantity
     , intGardenMarkId						= CRD.intGardenMarkId	
     , intPreInvoiceGardenMarkId			     = CRD.intPreInvoiceGardenMarkId
     , intGradeId							= CRD.intGradeId
     , intPreInvoiceGradeId					= CRD.intPreInvoiceGradeId
     , strChopNo							= CRD.strChopNo
     , strPreInvoiceChopNo					= CRD.strPreInvoiceChopNo
     , intSampleId                                = CRD.intSampleId    
     , ysnMismatched                              = ISNULL(CRD.ysnMismatched, 0)

	 --NOT MAPPED
     , intSaleYear							= BD.intSaleYear
     , strBuyingCenter						= CL.strLocationName
     , strSaleNumber						= BD.strSaleNumber
     , strTeaType							= CT.strCatalogueType
     , strSupplier							= E.strName
     , strChannel							= MZ.strMarketZoneCode
     , strCompanyCode						= PG.strName
     , dtmPromptDate						= BD.dtmExpectedDate
     , dtmSaleDate							= BD.dtmSaleDate
     , strLotNo							= BD.strVendorLotNumber
     , dblSupplierPreInvoicePrice			     = BD.dblCost
     , dblPreInvoiceLotQty					= BD.dblQtyReceived
     , dblTotalNoPackageBreakups			     = BD.dblPackageBreakups
     , strPreInvoiceGardenInvoiceNo			= BD.strPreInvoiceGardenNumber
     , strPreInvoicePurchaseType			     = BD.strPreInvoicePurchaseType
     , strPreInvoiceDocumentNo				= BD.strBillOfLading
     , dblNetWtPackages						= CAST(BD.intNumOfPackagesUOM AS NUMERIC(18,6)) --BD.dblNetWeightPerPackage
     , dblNoPackages						= BD.dblNumberOfPackages
     , dblNetWt2ndPackages					= CAST(BD.intNumOfPackagesUOM2 AS NUMERIC(18,6)) --BD.dblNetWeightPerPackage2
     , dblNo2ndPackages						= BD.dblNumberOfPackages2
     , dblNetWt3rdPackages					= CAST(BD.intNumOfPackagesUOM3 AS NUMERIC(18,6)) --BD.dblNetWeightPerPackage3
     , dblNo3rdPackages						= BD.dblNumberOfPackages3
     , strWarehouseCode						= SL.strName
     , strSampleNumber                            = S.strSampleNumber
	, strGarden							= GM.strGardenMark
     , strPreInvoiceGarden					= PIGM.strGardenMark
     , strGrade							= CA.strDescription
     , strPreInvoiceGrade					= PGCA.strDescription
     , dblValue                                   = ISNULL(CRD.dblBasePrice, 0) * ISNULL(CRD.dblQuantity, 0)
     , dblInvoiceValue                            = ISNULL(CRD.dblPreInvoicePrice, 0) * ISNULL(CRD.dblPreInvoiceQuantity, 0)
     , strERPPONumber                             = MFB.strERPPONumber
     , ysnIBDReceived                             = CASE WHEN MFB.strERPPONumber IS NULL OR MFB.strERPPONumber = '' THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END
     , strBatchId							= MFB.strBatchId
	, intBatchId							= MFB.intBatchId
     , intBrokerId							= S.intBrokerId
     , strBrokerName						= EB.strName
FROM tblQMCatalogueReconciliationDetail CRD 
INNER JOIN tblQMCatalogueReconciliation CR ON CR.intCatalogueReconciliationId = CRD.intCatalogueReconciliationId
INNER JOIN tblAPBillDetail BD ON BD.intBillDetailId = CRD.intBillDetailId
INNER JOIN tblAPBill B ON BD.intBillId = B.intBillId
INNER JOIN tblQMSample S ON CRD.intSampleId = S.intSampleId
LEFT JOIN tblEMEntity E ON B.intEntityVendorId = E.intEntityId
LEFT JOIN tblSMCompanyLocation CL ON B.intShipToId = CL.intCompanyLocationId
LEFT JOIN tblICStorageLocation SL ON BD.intStorageLocationId = SL.intStorageLocationId
LEFT JOIN tblARMarketZone MZ ON BD.intMarketZoneId = MZ.intMarketZoneId
LEFT JOIN tblSMPurchasingGroup PG ON BD.intPurchasingGroupId = PG.intPurchasingGroupId
LEFT JOIN tblQMCatalogueType CT ON BD.intCatalogueTypeId = CT.intCatalogueTypeId
LEFT JOIN tblSMTransaction SMT ON SMT.intRecordId = CR.intCatalogueReconciliationId AND SMT.strTransactionNo = CR.strReconciliationNumber
LEFT JOIN tblQMGardenMark GM ON CRD.intGardenMarkId = GM.intGardenMarkId
LEFT JOIN tblQMGardenMark PIGM ON CRD.intPreInvoiceGardenMarkId = PIGM.intGardenMarkId
LEFT JOIN tblICCommodityAttribute CA ON CRD.intGradeId = CA.intCommodityAttributeId AND CA.strType = 'Grade'
LEFT JOIN tblICCommodityAttribute PGCA ON CRD.intPreInvoiceGradeId = PGCA.intCommodityAttributeId AND PGCA.strType = 'Grade'
LEFT JOIN tblSMScreen SMS ON SMS.intScreenId = SMT.intScreenId AND SMS.strScreenName = 'CatalogueReconciliation'
LEFT JOIN tblMFBatch MFB ON S.intSampleId = MFB.intSampleId AND MFB.intLocationId = MFB.intBuyingCenterLocationId
LEFT JOIN tblEMEntity EB ON S.intBrokerId = EB.intEntityId