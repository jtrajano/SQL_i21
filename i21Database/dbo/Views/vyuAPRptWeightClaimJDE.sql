/*
Separate stored procedure for the report of JDE report.
This will prevent the JDE from being affected on any changes made on other 
report data source especially on performance.
*/
CREATE VIEW [dbo].[vyuAPRptWeightClaimJDE]
AS 

SELECT DISTINCT
	A.intBillId
	,companySetup.strCompanyName AS strCompanyName
	,strCompanyAddress = ISNULL(RTRIM(companySetup.strCompanyName) + CHAR(13) + char(10), '')
					 + ISNULL(RTRIM(companySetup.strAddress) + CHAR(13) + char(10), '')
					 + ISNULL(RTRIM(companySetup.strZip),'') + ' ' + ISNULL(RTRIM(companySetup.strCity), '') + ' ' + ISNULL(RTRIM(companySetup.strState), '') + CHAR(13) + char(10)
					 + ISNULL('' + RTRIM(companySetup.strCountry) + CHAR(13) + char(10), '')
					 + ISNULL(RTRIM(companySetup.strPhone)+ CHAR(13) + char(10), '')
	,strShipFrom = [dbo].[fnAPFormatAddress](B2.strName,NULL, A.strShipFromAttention, A.strShipFromAddress, A.strShipFromCity, A.strShipFromState, A.strShipFromZipCode, A.strShipFromCountry, A.strShipFromPhone) COLLATE Latin1_General_CI_AS
	-- ,strShipTo = [dbo].[fnAPFormatAddress](NULL,companySetup.strCompanyName, A.strShipToAttention, A.strShipToAddress, A.strShipToCity, A.strShipToState, A.strShipToZipCode, A.strShipToCountry, A.strShipToPhone) COLLATE Latin1_General_CI_AS
	-- ,dbo.fnTrim(ISNULL(B.strVendorId, B2.strEntityNo) + ' - ' + ISNULL(B2.strName,'')) as strVendorIdName 
	-- ,ISNULL(B2.strName,'') AS strVendorName 
	-- ,ISNULL(B.strVendorId, B2.strEntityNo) AS strVendorId
	,ContactEntity.strName AS strContactName
	,ContactEntity.strEmail AS strContactEmail
	,strDateLocation = TranLoc.strLocationName + ', ' + CONVERT(VARCHAR(12), GETDATE(), 106)
	,strLocationName = TranLoc.strLocationName
	,Bank.strBankName
	,BankAccount.strBankAccountHolder
	-- ,dbo.fnAPMaskBankAccountNos(dbo.fnAESDecryptASym(BankAccount.strBankAccountNo)) AS strBankAccountNo
	,BankAccount.strIBAN
	,BankAccount.strSWIFT
	,Term.strTerm
	,A.strRemarks
	,A.strBillId
	,A.dtmDate
	,A.dtmDueDate--CONVERT(VARCHAR(10), A.dtmDueDate, 103) AS dtmDueDate
	,Bank.strCity + ', ' + Bank.strState +  ' ' + Bank.strCountry AS strBankAddress
	/*Item Details Info*/
	,strContractNumber 		= 	ContractHeader.strContractNumber
	,strMiscDescription		=	CASE WHEN A2.intContractDetailId > 0
												AND ContractDetail.intItemContractId > 0
												AND A2.intContractCostId IS NULL
										THEN ItemContract.strContractItemName
										ELSE ISNULL(Item.strDescription,'')
									END
	,strItemNo				=	Item.strItemNo
	,strBillOfLading		=	Loads.strBLNumber
	,strCountryOrigin		=	ISNULL(ItemOriginCountry.strCountry, CommAttr.strDescription)
	,strCurrency			=	MainCurrency.strCurrency
	,strConcern				=	'Weight Claim' COLLATE Latin1_General_CI_AS
	,strUOM					=	QtyUOMDetails.strUnitMeasure
	,strClaimUOM			=	QtyUOMDetails.strUnitMeasure
	,strCostUOM				=	CASE 
									WHEN A2.intCostUOMId > 0 THEN ItemCostUOMMeasure.strUnitMeasure 
									WHEN A2.intWeightUOMId > 0 THEN QtyUOMWeightDetails.strUnitMeasure  --use weight uom if intCostUOMId is blank
									ELSE QtyUOMDetails.strUnitMeasure --use received uom if intCostUOMId is blank
								END
	,strLPlant				=	LPlant.strSubLocationName
	,intContractSeqId		=	ContractDetail.intContractSeq
	,dblQtyReceived			=	A2.dblWeightLoss - A2.dblFranchiseWeight
	,dblCost				=	A2.dblCost
	,dblTotal				=	A2.dblTotal + A2.dblTax
	,dblNetShippedWeight	=	A2.dblNetShippedWeight
	,dblWeightLoss			=	dblWeightLoss
	,dblLandedWeight		=	CASE WHEN A2.intWeightUOMId > 0 THEN A2.dblNetWeight ELSE A2.dblQtyReceived END
	,dblFranchiseWeight		=	A2.dblFranchiseWeight
	,dblClaimAmount			=	A2.dblClaimAmount
	,strERPPONumber			=	ContractDetail.strERPPONumber
FROM tblAPBill A 
INNER JOIN tblAPBillDetail A2
	ON A.intBillId = A2.intBillId
INNER JOIN tblICItem Item ON Item.intItemId = A2.intItemId
INNER JOIN (tblAPVendor B INNER JOIN tblEMEntity B2 ON B.intEntityId = B2.intEntityId)
	ON A.intEntityVendorId = B.intEntityId
CROSS JOIN tblSMCompanySetup companySetup
INNER JOIN tblSMCurrency MainCurrency ON MainCurrency.intCurrencyID = A2.intCurrencyId
LEFT JOIN (tblCTContractDetail ContractDetail INNER JOIN tblCTContractHeader ContractHeader ON ContractHeader.intContractHeaderId = ContractDetail.intContractHeaderId)
			ON A2.intContractDetailId = ContractDetail.intContractDetailId
LEFT JOIN (tblICItemContract ItemContract INNER JOIN tblSMCountry ItemOriginCountry ON ItemContract.intCountryId = ItemOriginCountry.intCountryID)
			ON ContractDetail.intItemContractId = ItemContract.intItemContractId
LEFT JOIN tblSMCompanyLocationSubLocation LPlant ON ContractDetail.intSubLocationId = LPlant.intCompanyLocationSubLocationId
LEFT JOIN tblICCommodityAttribute CommAttr ON CommAttr.intCommodityAttributeId = Item.intOriginId
LEFT JOIN tblEMEntityToContact EntityToContact ON A.intEntityId = EntityToContact.intEntityId AND EntityToContact.ysnDefaultContact = 1
LEFT JOIN tblEMEntity ContactEntity ON EntityToContact.intEntityContactId = ContactEntity.intEntityId
LEFT JOIN tblSMCompanyLocation TranLoc ON A.intStoreLocationId = TranLoc.intCompanyLocationId
LEFT JOIN tblCMBankAccount BankAccount ON BankAccount.intBankAccountId = A.intBankInfoId
LEFT JOIN tblCMBank Bank ON BankAccount.intBankId = Bank.intBankId
LEFT JOIN tblSMTerm Term ON A.intTermsId = Term.intTermID
LEFT JOIN (tblICItemUOM QtyUOM INNER JOIN tblICUnitMeasure QtyUOMDetails ON QtyUOM.intUnitMeasureId = QtyUOMDetails.intUnitMeasureId) 
		ON A2.intUnitOfMeasureId = QtyUOM.intItemUOMId
LEFT JOIN (tblICItemUOM QtyUOMWeight INNER JOIN tblICUnitMeasure QtyUOMWeightDetails ON QtyUOMWeight.intUnitMeasureId = QtyUOMWeightDetails.intUnitMeasureId) 
		ON QtyUOMWeight.intItemUOMId = A2.intWeightUOMId
LEFT JOIN (tblICItemUOM ItemCostUOM INNER JOIN tblICUnitMeasure ItemCostUOMMeasure ON ItemCostUOM.intUnitMeasureId = ItemCostUOMMeasure.intUnitMeasureId) 
		ON A2.intCostUOMId = ItemCostUOM.intItemUOMId
LEFT JOIN tblLGLoad Loads ON Loads.intLoadId = A2.intLoadId
