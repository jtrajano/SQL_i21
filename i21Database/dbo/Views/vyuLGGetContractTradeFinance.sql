CREATE VIEW [dbo].[vyuLGGetContractTradeFinance]
AS
SELECT
	CD.intContractDetailId
	,CD.intContractSeq
	,CH.strContractNumber
	,CD.strFinanceTradeNo
	,CD.intBankAccountId
	,intBankId = BK.intBankId
	,BK.strBankName
	,BA.strBankAccountNo
	,CD.intBorrowingFacilityId
	,FA.strBorrowingFacilityId
	,CD.intBorrowingFacilityLimitId
	,FL.strBorrowingFacilityLimit
	,CD.intBorrowingFacilityLimitDetailId
	,FLD.strLimitDescription
	,CD.dblLoanAmount
	,CD.intBankValuationRuleId
	,BVR.strBankValuationRule
	,CD.strReferenceNo
	,CD.strBankReferenceNo
	,FL.dblLimit
	,dblSublimit = FLD.dblLimit
	,CD.strComments
	,CD.ysnSubmittedToBank
	,CD.dtmDateSubmitted
	,ASTF.intApprovalStatusId
	,ASTF.strApprovalStatus
	,CD.dtmDateApproved
FROM tblCTContractDetail CD
	INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN vyuCMBankAccount BA ON BA.intBankAccountId = CD.intBankAccountId
	LEFT JOIN tblCMBank BK ON BK.intBankId = ISNULL(CD.intBankId, BA.intBankId)
	LEFT JOIN tblCMBorrowingFacility FA ON FA.intBorrowingFacilityId = CD.intBorrowingFacilityId
	LEFT JOIN tblCMBorrowingFacilityLimit FL ON FL.intBorrowingFacilityLimitId = CD.intBorrowingFacilityLimitId
	LEFT JOIN tblCMBorrowingFacilityLimitDetail FLD ON FLD.intBorrowingFacilityLimitDetailId = CD.intBorrowingFacilityLimitDetailId
	LEFT JOIN tblCMBankValuationRule BVR ON BVR.intBankValuationRuleId = CD.intBankValuationRuleId
	LEFT JOIN tblCTApprovalStatusTF ASTF on ASTF.intApprovalStatusId = CD.intApprovalStatusId

GO