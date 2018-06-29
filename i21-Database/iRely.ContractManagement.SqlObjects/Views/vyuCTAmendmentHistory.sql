CREATE VIEW [dbo].[vyuCTAmendmentHistory]
AS
SELECT 
	 intSequenceAmendmentLogId      =  SAL.intSequenceAmendmentLogId
	,intContractHeaderId            =  SAL.intContractHeaderId
	,intContractDetailId            =  SAL.intContractDetailId
	,dtmHistoryCreated	            =  SAL.dtmHistoryCreated
	,strContractNumber              =  CH.strContractNumber
	,intContractSeq                 =  CD.intContractSeq
	,intEntityId		            =  CH.intEntityId
	,strEntityName		            =  EY.strName
	,intContractTypeId              =  CH.intContractTypeId
	,strContractType	            =  TP.strContractType
	,strItemChanged		            =  SAL.strItemChanged
	,strOldValue		            =  SAL.strOldValue
	,strNewValue		            =  SAL.strNewValue
	,intCommodityId		            =  CH.intCommodityId
	,strCommodityCode	            =  CO.strCommodityCode
	,ysnPrinted			            =  CASE WHEN ISNULL(SAL.strAmendmentNumber,'') <>'' THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
	,intCompanyLocationId           =  CD.intCompanyLocationId
	,strLocationName                =  CL.strLocationName
	,strAmendmentNumber		        =  SAL.strAmendmentNumber
	,ysnSigned						=  SAL.ysnSigned
	,dtmSigned					    =  SAL.dtmSigned
FROM tblCTSequenceAmendmentLog	   SAL
JOIN tblCTContractHeader		   CH  ON CH.intContractHeaderId     = SAL.intContractHeaderId
JOIN tblEMEntity				   EY  ON EY.intEntityId		     = CH.intEntityId
JOIN tblCTContractType			   TP  ON TP.intContractTypeId       = CH.intContractTypeId
JOIN tblCTAmendmentApproval        AMP ON AMP.intAmendmentApprovalId = SAL.intAmendmentApprovalId  AND ISNULL(AMP.ysnAmendment,0) = 1
LEFT JOIN tblCTContractDetail	   CD  ON CD.intContractDetailId     = SAL.intContractDetailId
LEFT JOIN tblICCommodity	       CO  ON CO.intCommodityId			 = CH.intCommodityId
LEFT JOIN tblSMCompanyLocation	   CL  ON CL.intCompanyLocationId    = CD.intCompanyLocationId