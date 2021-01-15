CREATE PROCEDURE uspLGGetDebitNoteDetailReport 
	@intWeightClaimId INT = NULL
AS
DECLARE @xmlDocumentId INT
DECLARE @strUserName NVARCHAR(100)
DECLARE @intLoadId INT

DECLARE @temp_xml_table TABLE (
	[fieldname] NVARCHAR(50)
	,condition NVARCHAR(20)
	,[from] NVARCHAR(50)
	,[to] NVARCHAR(50)
	,[join] NVARCHAR(10)
	,[begingroup] NVARCHAR(50)
	,[endgroup] NVARCHAR(50)
	,[datatype] NVARCHAR(50)
	)

SELECT @intLoadId = intLoadId
FROM tblLGWeightClaim
WHERE intWeightClaimId = @intWeightClaimId

SELECT DISTINCT WC.intWeightClaimId, 
	   strWeightClaimNumber = WC.strReferenceNumber,
	   L.strLoadNumber,
	   L.intLoadId,
	   LD.intLoadDetailId,
	   strContainerNumber = LC.strContainerNumber,
	   strMarks = LC.strMarks,
	   CD.intContractDetailId,
	   CH.intContractHeaderId,
	   CH.strContractNumber,
	   CD.intContractSeq,
	   CH.strContractNumber +'/'+LTRIM(CD.intContractSeq) strContractNumberWithSeq,
	   WCD.dblFromNet,
	   WCD.dblToNet,
	   ABS(((WCD.dblFromNet-WCD.dblToNet)/WCD.dblFromNet)*100) AS dblLossPercentage,
	   ABS((WCD.dblClaimableWt)) dblWeightLossExceedingFranchise,
	   CDV.dblSeqPrice,
	   CDV.strSeqPriceUOM,
	   CDV.strSeqCurrency,
	   dbo.fnRemoveTrailingZeroes(CDV.dblSeqPrice) + ' ' + CDV.strSeqCurrency + '/' + CDV.strSeqPriceUOM AS strSeqPrice,
	   ROUND(WCD.dblClaimAmount,2) AS dblClaimAmount,
	   B.intBillId,
	   B.strBillId,
	   CH.strCustomerContract,
	   I.strItemNo, 
	   I.strDescription AS strItemDescription,
	   dblQuantity = ISNULL(LC.dblQuantity, CD.dblQuantity),
	   L.strMVessel
FROM tblLGWeightClaim WC
JOIN tblLGWeightClaimDetail WCD ON WC.intWeightClaimId = WCD.intWeightClaimId
JOIN tblCTContractDetail CD ON CD.intContractDetailId = WCD.intContractDetailId
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
JOIN tblLGLoad L ON WC.intLoadId = L.intLoadId
JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
	AND (
		CASE 
			WHEN CH.intContractTypeId = 1
				THEN LD.intPContractDetailId
			ELSE LD.intSContractDetailId
			END
		) = CD.intContractDetailId
JOIN vyuLGAdditionalColumnForContractDetailView CDV ON CDV.intContractDetailId = CD.intContractDetailId
LEFT JOIN tblAPBill B ON B.intBillId = WCD.intBillId
LEFT JOIN tblICItem I ON I.intItemId = CD.intItemId
LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = WCD.intLoadContainerId
WHERE WC.intWeightClaimId = @intWeightClaimId