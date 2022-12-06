CREATE VIEW vyuQMSearchApprovedPreInvoiceReconciliation
AS   --HEADER
SELECT intCatalogueReconciliationId			= CR.intCatalogueReconciliationId
     , strReconciliationNumber				= CR.strReconciliationNumber
     , strComments							= CR.strComments
     , dtmReconciliationDate				     = CR.dtmReconciliationDate	 
     , dtmPostDate							= CR.dtmPostDate
     , ysnPosted							= CR.ysnPosted
     , ysnApproved							= CASE WHEN SMT.intTransactionId IS NULL OR SMT.strApprovalStatus NOT IN ('No Need for Approval', 'Approved') THEN CAST(0 AS BIT) ELSE CAST(1 AS BIT) END
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
     , strSampleNumber                            = S.strSampleNumber

	 --NOT MAPPED
     , intSaleYear							= BD.intSaleYear
     , strBuyingCenter						= CL.strLocationName
     , strSaleNumber						= BD.strSaleNumber
     , strTeaType							= CT.strCatalogueType
     , strSupplier							= E.strName
     , strChannel							= SB.strSubBook
     , strCompanyCode						= PG.strName
     , dtmPromptDate						= BD.dtmExpectedDate
     , dtmSaleDate							= BD.dtmSaleDate
     , strLotNo							= BD.strVendorLotNumber
     , dblSupplierPreInvoicePrice			     = BD.dblCost
     , dblPreInvoiceLotQty					= BD.dblQtyReceived
     , dblTotalNoPackageBreakups			     = BD.dblPackageBreakups
     , strPreInvoiceGardenInvoiceNo			= BD.strPreInvoiceGardenNumber
     , strPreInvoicePurchaseType			     = CASE WHEN B.intTransactionType = 2 THEN CAST('Vendor Prepayment' AS NVARCHAR(100))
                                                         WHEN B.intTransactionType = 3 THEN CAST('Debit Memo' AS NVARCHAR(100))
                                                         ELSE CAST('Voucher' AS NVARCHAR(100))
                                                    END
     , strPreInvoiceDocumentNo				= B.strBillId
     , dblNetWtPackages						= CAST(BD.intNumOfPackagesUOM AS NUMERIC(18,6)) --BD.dblNetWeightPerPackage
     , dblNoPackages						= BD.dblNumberOfPackages
     , dblNetWt2ndPackages					= CAST(BD.intNumOfPackagesUOM2 AS NUMERIC(18,6)) --BD.dblNetWeightPerPackage2
     , dblNo2ndPackages						= BD.dblNumberOfPackages2
     , dblNetWt3rdPackages					= CAST(BD.intNumOfPackagesUOM3 AS NUMERIC(18,6)) --BD.dblNetWeightPerPackage3
     , dblNo3rdPackages						= BD.dblNumberOfPackages3
     , strWarehouseCode						= SL.strName
	, strGarden							= GM.strGardenMark
     , strPreInvoiceGarden					= PIGM.strGardenMark
     , strGrade							= CA.strDescription
     , strPreInvoiceGrade					= PGCA.strDescription
FROM tblQMCatalogueReconciliationDetail CRD 
INNER JOIN tblQMCatalogueReconciliation CR ON CR.intCatalogueReconciliationId = CRD.intCatalogueReconciliationId
INNER JOIN tblAPBillDetail BD ON BD.intBillDetailId = CRD.intBillDetailId
INNER JOIN tblAPBill B ON BD.intBillId = B.intBillId
INNER JOIN tblQMSample S ON CRD.intSampleId = S.intSampleId
LEFT JOIN tblEMEntity E ON B.intEntityVendorId = E.intEntityId
LEFT JOIN tblSMCompanyLocation CL ON B.intShipToId = CL.intCompanyLocationId
LEFT JOIN tblICStorageLocation SL ON BD.intStorageLocationId = SL.intStorageLocationId
LEFT JOIN tblCTSubBook SB ON BD.intSubBookId = SB.intSubBookId
LEFT JOIN tblSMPurchasingGroup PG ON BD.intPurchasingGroupId = PG.intPurchasingGroupId
LEFT JOIN tblQMCatalogueType CT ON BD.intCatalogueTypeId = CT.intCatalogueTypeId
LEFT JOIN tblSMTransaction SMT ON SMT.intRecordId = CR.intCatalogueReconciliationId AND SMT.strTransactionNo = CR.strReconciliationNumber
LEFT JOIN tblQMGardenMark GM ON CRD.intGardenMarkId = GM.intGardenMarkId
LEFT JOIN tblQMGardenMark PIGM ON CRD.intPreInvoiceGardenMarkId = PIGM.intGardenMarkId
LEFT JOIN tblICCommodityAttribute CA ON CRD.intGradeId = CA.intCommodityAttributeId AND CA.strType = 'Grade'
LEFT JOIN tblICCommodityAttribute PGCA ON CRD.intPreInvoiceGradeId = PGCA.intCommodityAttributeId AND PGCA.strType = 'Grade'
LEFT JOIN tblSMScreen SMS ON SMS.intScreenId = SMT.intScreenId AND SMS.strScreenName = 'CatalogueReconciliation'