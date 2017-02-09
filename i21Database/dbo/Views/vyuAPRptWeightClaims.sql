CREATE VIEW [dbo].[vyuAPRptWeightClaims]
AS

SELECT 
CAST(ROW_NUMBER() OVER(ORDER BY intContractDetailId) AS INT) AS intClaimId,
(SELECT TOP 1	strCompanyName FROM dbo.tblSMCompanySetup) AS strCompanyName,
(SELECT TOP 1 dbo.[fnAPFormatAddress](NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL) FROM tblSMCompanySetup) as strCompanyAddress,
CASE WHEN ysnSubCurrency > 0 THEN (dblWeightLoss - dblFranchiseWeight) * dblCost / ISNULL(intCent,1)  ELSE (dblWeightLoss - dblFranchiseWeight) * dblCost END AS dblClaim,
((dblWeightLoss - dblFranchiseWeight) * (dblCost / NULLIF(ISNULL(intCent,1), 0))  - dblTotalClaimAmount) * -1 AS  dblFranchiseAmount,
(dblWeightLoss - dblFranchiseWeight) AS dblQtyToBill ,
* 
FROM (
	SELECT
		RTRIM(LTRIM(strVendorId)) + ' - ' + strName AS strVendorName,
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
		(SUM(dblAmountPaid) - SUM(dblAppliedPrepayment)) AS dblTotalClaimAmount,
		0.00000 dblDamageQty,
		0.00000 dblAdjustments,
		dblCost,
		dblQtyReceived,
		dblCostUnitQty,
		dblWeightUnitQty,
		dblContractItemQty,
		dblPrepaidTotal,
		strUnitMeasure AS strUOM,
		strContractNumber,
		strDescription,
		strAccountId,
		strAccountDesc,
		strVendorOrderNumber AS strInvoiceNo,
		strBillOfLading,
		strCurrency,
		dtmDueDate, 
		dtmDate,
		intBillId,      
		intCostUOMId,
		intWeightUOMId,
		intUnitOfMeasureId,
		intItemId,
		intContractDetailId,
		intContractHeaderId,
		intEntityVendorId,
		intShipToId,
		intAccountId,
		--strBankAccountNo,
		--strBankName,
		--strBankAddress,
		--strNotes,
		strContainerNumber,
		strWeightGradeDesc,
		strComment,
		intCent,
		intCurrencyId,
		strCostCurrency,
		ysnSubCurrency
	FROM (
		SELECT 
			 A.intBillId
			,A.dblCost
			,A.dblBillCost
			,A.dblGrossShippedWeight
		    ,A.dblNetShippedWeight
			,A.dblTareShippedWeight
			,A.dblNetQtyReceived
			,A.dblGrossQtyReceived
			,A.dblAppliedPrepayment
			,A.dblQtyReceived
			,A.dblQtyBillCreated
			,A.intUnitOfMeasureId
			,A.strUnitMeasure
			,A.intCostUOMId
			,A.strCostUOM
			,A.intWeightUOMId
			,A.strgrossNetUOM
			,A.dblCostUnitQty
			,A.dblWeightUnitQty 
			,A.dblUnitQty 
			,A.strItemNo
			,A.intItemId
			,A.intContractDetailId
			,A.intContractHeaderId
			,A.intContractSeq
			,A.dblAmountPaid
			,A.dblContractItemQty
			,A.strContractNumber
			,A.dblFranchise
			,A.intEntityVendorId
			,A.intShipToId
			,A.dblPrepaidTotal
			,A.strVendorId
			,A.intAccountId
			,A.strAccountId
			,A.strAccountDesc
			,A.strName
			,A.str1099Form
			,A.str1099Type
			,A.strDescription
			,A.intCent
			,A.intCurrencyId
			,A.strCostCurrency
			,A.ysnSubCurrency
			,A.strContainerNumber
			,A.strWeightGradeDesc
			,A.strVendorOrderNumber
			,A.strBillOfLading
			,A.strCurrency
			,A.dtmDueDate
			,A.dtmDate
			,A.strComment
			
		FROM [vyuAPClaimsRptDetails] A
		
	) tmpClaim
	GROUP BY dblCost,
		dblCostUnitQty,
		dblWeightUnitQty,
		dblQtyReceived,
		dblFranchise,
		dblContractItemQty,
		dblAmountPaid,
		dblPrepaidTotal,
		dtmDueDate,
		dtmDate,
		intBillId,
		intCostUOMId,
		intWeightUOMId,
		intUnitOfMeasureId,
		intItemId,
		intContractDetailId,
		intContractHeaderId,
		intEntityVendorId,
		intShipToId,
		intCurrencyId,
		intAccountId,
		strUnitMeasure,
		strItemNo,
		strContractNumber,
		strVendorId,		
		strAccountId,
		strAccountDesc,
		strName,
		str1099Form,
		str1099Type,
		strDescription,
		strVendorOrderNumber,
		strBillOfLading,		
		strCurrency,
		--strBankAccountNo,
		--strBankName,
		--strBankAddress,		
		--strNotes,
		strContainerNumber,
		strWeightGradeDesc,
		strComment,
		intCent,
		strCostCurrency,
		ysnSubCurrency
) Claim
WHERE 1= CASE WHEN dblPrepaidTotal IS NULL THEN 1 ELSE 
			CASE WHEN dblQtyBillCreated = dblContractItemQty THEN 1 ELSE 0 END--make sure we fully billed the contract item
		END
AND dblWeightLoss > dblFranchiseWeight -- Make sure the weight loss is greater then the tolerance