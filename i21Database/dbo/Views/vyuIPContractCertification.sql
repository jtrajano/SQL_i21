CREATE VIEW [dbo].[vyuIPContractCertification]
AS
SELECT CC.intContractCertificationId
	,CC.intContractDetailId
	,CC.strCertificationId
	,CC.strTrackingNumber
	,CC.dblQuantity
	,PR.strName AS strProducer
	,CF.strCertificationName
FROM tblCTContractCertification CC
LEFT JOIN tblEMEntity PR ON PR.intEntityId = CC.intProducerId
LEFT JOIN tblICCertification CF ON CF.intCertificationId = CC.intCertificationId

