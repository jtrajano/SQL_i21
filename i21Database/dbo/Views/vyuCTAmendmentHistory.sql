﻿CREATE VIEW [dbo].[vyuCTAmendmentHistory]
AS
SELECT 
	 intSequenceAmendmentLogId = SAL.intSequenceAmendmentLogId
	,intContractHeaderId       = SAL.intContractHeaderId
	,intContractDetailId       = SAL.intContractDetailId
	,dtmHistoryCreated	       = SAL.dtmHistoryCreated
	,strContractNumber         = CH.strContractNumber
	,intContractSeq            = CD.intContractSeq
	,intEntityId		       = CH.intEntityId
	,strEntityName		       = EY.strName
	,intContractTypeId         = CH.intContractTypeId
	,strContractType	       = TP.strContractType
	,strItemChanged		       = SAL.strItemChanged
	,strOldValue		       = SAL.strOldValue
	,strNewValue		       = SAL.strNewValue
	,intCommodityId		       = CH.intCommodityId
	,strCommodityCode	       = CO.strCommodityCode
	,ysnPrinted			       = CH.ysnPrinted
	,intCompanyLocationId      = CD.intCompanyLocationId
	,strLocationName           = CL.strLocationName
	,strAmendmentNumber		   = SAL.strAmendmentNumber
FROM tblCTSequenceAmendmentLog SAL
JOIN tblCTContractHeader	   CH  ON CH.intContractHeaderId = SAL.intContractHeaderId
JOIN tblCTContractDetail	   CD  ON CD.intContractDetailId = SAL.intContractDetailId
JOIN tblEMEntity			   EY  ON EY.intEntityId = CH.intEntityId
JOIN tblCTContractType		   TP  ON TP.intContractTypeId = CH.intContractTypeId
JOIN tblSMCompanyLocation	   CL  ON CL.intCompanyLocationId = CD.intCompanyLocationId
JOIN tblCTAmendmentApproval    AMP ON AMP.intAmendmentApprovalId = SAL.intAmendmentApprovalId AND ISNULL(AMP.ysnAmendment,0) = 1
LEFT JOIN tblICCommodity	   CO  ON CO.intCommodityId = CH.intCommodityId
