CREATE VIEW [dbo].[vyuAPClaims]
AS

SELECT 
CAST(ROW_NUMBER() OVER(ORDER BY intContractDetailId) AS INT) AS intClaimId,
* ,
CASE WHEN ysnSubCurrency > 0 THEN (dblWeightLoss - dblFranchiseWeight) * dblCost / ISNULL(intCent,1)  ELSE (dblWeightLoss - dblFranchiseWeight) * dblCost END AS dblClaim,
(dblWeightLoss - dblFranchiseWeight) AS dblQtyToBill 
FROM (
	SELECT
		SUM(dblNetQtyReceived) AS dblNetQtyReceived,
		SUM(dblAppliedPrepayment) AS dblAppliedPrepayment,
		SUM(dblNetShippedWeight) AS dblNetShippedWeight,
		SUM(dblQtyBillCreated) AS dblQtyBillCreated,
		CASE 
		WHEN dblFranchise > 0
			THEN SUM(dblNetShippedWeight) * (dblFranchise / 100)
		ELSE 0 END AS dblFranchiseWeight,
		dblCost,
		dblBillCost,
		dblQtyReceived,
		dblCostUnitQty,
		dblWeightUnitQty,
		dblUnitQty,
		intCostUOMId,
		strCostUOM,
		intWeightUOMId,
		strgrossNetUOM,
		intUnitOfMeasureId,
		strUnitMeasure AS strUOM,
		strItemNo,
		strVendorId,
		strName,
		str1099Form,
		str1099Type,
		strContractNumber,
		strDescription,
		intItemId,
		intContractDetailId,
		intContractHeaderId,
		dblAmountPaid,
		dblContractItemQty,
		intEntityVendorId,
		intShipToId,
		SUM(dblNetShippedWeight) - SUM(dblNetQtyReceived) AS dblWeightLoss,
		dblPrepaidTotal,
		intAccountId,
		strAccountId,
		strAccountDesc,
		intCent,
		intCurrencyId,
		strCostCurrency,
		ysnSubCurrency,
		strTerm,
		intTermID
	FROM (
		SELECT 
			 A.intBillId
			,A.dblCost
			,A.dblBillCost
		    ,A.dblNetShippedWeight
			,A.dblNetQtyReceived
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
			,A.strTerm
			,A.intTermID
		FROM vyuAPClaimsDetails A
	) tmpClaim
	GROUP BY dblCost,
		dblBillCost,
		dblCostUnitQty,
		dblWeightUnitQty,
		dblUnitQty,
		dblQtyReceived,
		strCostUOM,
		strgrossNetUOM,
		intCostUOMId,
		intWeightUOMId,
		intUnitOfMeasureId,
		strUnitMeasure,
		dblFranchise,
		strItemNo,
		strContractNumber,
		intItemId,
		intContractDetailId,
		intContractHeaderId,
		dblContractItemQty,
		dblAmountPaid,
		intEntityVendorId,
		intShipToId,
		intCurrencyId,
		dblPrepaidTotal,
		strVendorId,
		intAccountId,
		strAccountId,
		strAccountDesc,
		strName,
		str1099Form,
		str1099Type,
		strDescription,
		ysnSubCurrency,
		intCent,
		strCostCurrency,
		strTerm,
		intTermID
) Claim
WHERE dblQtyBillCreated = dblContractItemQty --make sure we fully billed the contract item
AND dblWeightLoss > dblFranchiseWeight -- Make sure the weight loss is greater then the tolerance