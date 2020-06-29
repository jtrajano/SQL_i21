CREATE VIEW [dbo].[vyuSCScaleLoadView]
AS 
SELECT 
	A.intLoadDetailId
	,A.intLoadId
	,A.intConcurrencyId
	,A.strType
	,A.strVendor
	,A.strCustomerReference
	,A.strCustomer
	,A.strItemNo
	,A.strSLocationName
	,A.strPLocationName
	,A.dblQuantity
	,A.ysnDispatched
	,A.dtmScheduledDate
	,A.intPContractDetailId
	,A.intSContractDetailId
	,A.intVendorEntityId
	,A.intCustomerEntityId
	,A.intPCompanyLocationId
	,A.intSCompanyLocationId
	,A.intPurchaseSale
	,A.ysnUseWeighScales
	,A.dblDeliveredQuantity
	,A.strShipmentStatus
	,A.strTransUsedBy
	,A.intItemId
	,A.strSContractNumber
	,A.strPContractNumber
	,A.intPContractSeq
	,A.intSContractSeq
	,A.strLoadNumber
	,ysnInProgress = CAST((CASE WHEN ISNULL(B.intLoadDetailId,0) = 0  THEN 0 ELSE 1 END) AS BIT)
	,intTicketId = B.intTicketId
	,A.intItemUOMId
FROM vyuLGLoadDetailViewSearch A
OUTER APPLY (
	SELECT TOP 1
		intLoadDetailId 
		,intTicketId
	FROM ( 
	SELECT TOP 1 
		AA.intLoadDetailId 
		,AA.intTicketId
	FROM tblSCTicketLoadUsed AA 
	INNER JOIN tblSCTicket BB
		ON AA.intTicketId = BB.intTicketId
	WHERE AA.intLoadDetailId = A.intLoadDetailId
		
	UNION ALL

	SELECT TOP 1
		intLoadDetailId 
		,intTicketId
	FROM tblSCTicket 
	WHERE intLoadDetailId = A.intLoadDetailId
		
	)A1
)B

