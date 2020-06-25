CREATE VIEW [dbo].[vyuAPRptWeightClaims]
AS

SELECT 
CAST(ROW_NUMBER() OVER(ORDER BY intContractDetailId) AS INT) AS intClaimId,
(SELECT TOP 1 strCompanyName FROM dbo.tblSMCompanySetup) AS strCompanyName,
(SELECT TOP 1 dbo.[fnAPFormatAddress](strCompanyName, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) COLLATE Latin1_General_CI_AS as strCompanyAddress,
CASE WHEN Claim.ysnSubCurrency > 0 THEN (Claim.dblWeightLoss - Claim.dblFranchiseWeight) * Claim.dblCost / ISNULL(Claim.intCent,1)  ELSE (Claim.dblWeightLoss - Claim.dblFranchiseWeight) * Claim.dblCost END AS dblClaim,
((Claim.dblWeightLoss - Claim.dblFranchiseWeight) * (Claim.dblCost / NULLIF(ISNULL(Claim.intCent,1), 0))  - Claim.dblTotalClaimAmount) * -1 AS  dblFranchiseAmount,
(Claim.dblWeightLoss - Claim.dblFranchiseWeight) AS dblQtyToBill ,
ISNULL(ItemContractCountry.strCountry,CommodityAttr.strDescription) AS strCountryOrigin,
strShipFrom = (SELECT strFullAddress = [dbo].[fnAPFormatAddress](Claim.strName,NULL, A.strShipFromAttention, A.strShipFromAddress, A.strShipFromCity, A.strShipFromState, A.strShipFromZipCode, A.strShipFromCountry, A.strShipFromPhone)) COLLATE Latin1_General_CI_AS,
strShipTo = (SELECT strFullAddress = [dbo].[fnAPFormatAddress](NULL,(SELECT TOP 1 strCompanyName FROM dbo.tblSMCompanySetup), A.strShipToAttention, A.strShipToAddress, A.strShipToCity, A.strShipToState, A.strShipToZipCode, A.strShipToCountry, A.strShipToPhone)) COLLATE Latin1_General_CI_AS,
CreatedBy.strName AS strContactName,
CreatedBy.strEmail AS strContactEmail,
strDateLocation = VoucherLocation.strLocationName + ', ' + CONVERT(VARCHAR(12), GETDATE(), 107),
Term.strTerm,
A.strRemarks,
Bank.strBankName,
BankAccount.strBankAccountHolder,
BankAccount.strIBAN,
BankAccount.strSWIFT,
Bank.strCountry + ', ' + Bank.strCity + ' ' + Bank.strState COLLATE Latin1_General_CI_AS AS strBankAddress,
(SELECT blbFile FROM tblSMUpload WHERE intAttachmentId = 
	(	
	  SELECT TOP 1
	  intAttachmentId
	  FROM tblSMAttachment
	  WHERE strScreen = 'SystemManager.CompanyPreference'
	  AND strComment = 'Footer'
	  ORDER BY intAttachmentId DESC
	)) AS strFooter,
Claim.* 
FROM (
	SELECT
		intTransactionType,
		RTRIM(LTRIM(strVendorId)) + ' - ' + strName AS strVendorName,
		strName,
		strItemNo,  
		SUM(dblNetShippedWeight) AS dblNetShippedWeight,
		SUM(dblGrossShippedWeight) AS dblGrossShippedWeight,
		SUM(dblNetShippedWeight) - SUM(dblNetQtyReceived) AS dblWeightLoss,
		SUM(dblTareShippedWeight) AS dblShipmentWeightLoss,
		dblAmountPaid,
		SUM(dblAppliedPrepayment) AS dblAppliedPrepayment,
		SUM(dblQtyBillCreated) AS dblQtyBillCreated,
		SUM(dblNetQtyReceived) AS dblNetQtyReceived,
		SUM(dblGrossQtyReceived) AS dblGrossQtyReceived,
		SUM(dblGrossQtyReceived) - SUM(dblNetQtyReceived) AS dblIRWeightLoss,
		CASE 
		WHEN dblFranchise > 0
			THEN SUM(dblNetShippedWeight) * (dblFranchise / 100)
		ELSE 0 END AS dblFranchiseWeight,		
		(SUM(dblNetShippedWeight) - SUM(dblNetQtyReceived) - SUM(dblNetShippedWeight) * (dblFranchise / 100)) dblClaimQuantity,
		ISNULL((SUM(dblAmountPaid) - SUM(dblAppliedPrepayment)),0) AS dblTotalClaimAmount,
		0.00000 dblDamageQty,
		0.00000 dblAdjustments,
		dblTotal,
		dblCost,
		dblQtyReceived,
		dblCostUnitQty,
		dblWeightUnitQty,
		dblContractItemQty,
		dblPrepaidTotal,
		dblWeightLoss AS dblDetailWeightLoss,
		strUnitMeasure AS strUOM,
		strCostUOM,
		strgrossNetUOM,
		strContractNumber,
		strDescription,
		strAccountId,
		strAccountDesc,
		strVendorOrderNumber AS strInvoiceNo,
		strBillOfLading,
		strCurrency,
		strBillId,
		dtmDueDate, 
		dtmDate,
		intBillId,      
		intCostUOMId,
		intWeightUOMId,
		intUnitOfMeasureId,
		intItemId,
		intOriginId AS intOriginCountryId,
		intContractDetailId,
		intContractHeaderId,
		intItemContractId,
		intEntityVendorId,
		intShipToId,
		intAccountId,
		intContractSeq,
		strContainerNumber,
		strWeightGradeDesc,
		strMiscDescription,
		strComment,
		intCent,
		intCurrencyId,
		strCostCurrency,
		ysnSubCurrency,
		strERPPONumber
	FROM (
		SELECT *
		FROM [vyuAPClaimsRptDetails] A
	) tmpClaim
	GROUP BY 
		dblTotal,
		dblCost,
		dblCostUnitQty,
		dblWeightUnitQty,
		dblQtyReceived,
		dblFranchise,
		dblContractItemQty,
		dblAmountPaid,
		dblPrepaidTotal,
		dtmDueDate,
		dtmDate,
		dblWeightLoss,
		intTransactionType,
		intBillId,
		intCostUOMId,
		intWeightUOMId,
		intUnitOfMeasureId,
		intItemId,
		intOriginId,
		intContractDetailId,
		intContractHeaderId,
		intItemContractId,
		intEntityVendorId,
		intShipToId,
		intCurrencyId,
		intAccountId,
		intContractSeq,
		strBillId,
		strUnitMeasure,
		strCostUOM,
		strgrossNetUOM,
		strItemNo,
		strContractNumber,
		strVendorId,		
		strAccountId,
		strAccountDesc,
		strMiscDescription,
		strName,
		str1099Form,
		str1099Type,
		strDescription,
		strVendorOrderNumber,
		strBillOfLading,		
		strCurrency,
		strContainerNumber,
		strWeightGradeDesc,
		strComment,
		intCent,
		strCostCurrency,
		ysnSubCurrency,
		strERPPONumber
) Claim
INNER JOIN tblAPBill A
	ON A.intBillId = Claim.intBillId
LEFT JOIN tblICItemContract ItemContract INNER JOIN tblSMCountry ItemContractCountry ON ItemContract.intCountryId = ItemContractCountry.intCountryID
	ON Claim.intItemContractId = ItemContract.intItemContractId
LEFT JOIN tblICCommodityAttribute CommodityAttr 
	ON CommodityAttr.intCommodityAttributeId = Claim.intOriginCountryId
LEFT JOIN tblEMEntity CreatedBy 
	ON A.intEntityId = CreatedBy.intEntityId
LEFT JOIN tblSMCompanyLocation VoucherLocation 
	ON VoucherLocation.intCompanyLocationId = A.intStoreLocationId
LEFT JOIN tblSMTerm Term 
	ON A.intTermsId = Term.intTermID
LEFT JOIN tblCMBankAccount BankAccount 
	ON BankAccount.intBankAccountId = A.intBankInfoId
LEFT JOIN tblCMBank Bank 
	ON BankAccount.intBankId = Bank.intBankId
WHERE 1= CASE WHEN Claim.dblPrepaidTotal IS NULL THEN 1 ELSE 
			CASE WHEN Claim.dblQtyBillCreated = Claim.dblContractItemQty THEN 1 ELSE 0 END--make sure we fully billed the contract item
		END
AND 1 = CASE WHEN Claim.intTransactionType = 11 AND Claim.dblWeightLoss > 0 THEN 1 
			 WHEN Claim.intTransactionType = 3 THEN 1
		ELSE 0 END -- Make sure the weight loss is greater then the tolerance if weight claim