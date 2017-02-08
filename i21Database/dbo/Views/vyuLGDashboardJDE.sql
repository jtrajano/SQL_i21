CREATE VIEW [dbo].[vyuLGDashboardJDE]
AS
SELECT DISTINCT 
 LH.strLoadNumber
,CP.strPositionType
,LH.dblQuantity AS dblLoadQuantity
,LH.dtmBLDate
,CASE 
	WHEN (SELECT COUNT(1) FROM tblLGLoadDocuments T WHERE T.intLoadId=LH.intLoadId AND ISNULL(T.ysnReceived,0)=0 )>0 THEN 'N' 
	ELSE 'Y' 
END 
AS strDocumentsReceived
,CTDash.*
FROM 
tblLGLoadDetail LD
JOIN tblLGLoad LH ON LH.intLoadId=LD.intLoadId
JOIN vyuCTDashboardJDE CTDash ON CTDash.intContractDetailId = LD.intPContractDetailId
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CTDash.intContractHeaderId
JOIN [tblCTPosition] CP ON CP.intPositionId=CH.intPositionId
WHERE LH.dtmBLDate IS NOT NULL
