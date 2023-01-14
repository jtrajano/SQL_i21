CREATE VIEW vyuTMGetOrder

AS  

SELECT D.intDispatchID
	, strTMOrder = D.strOrderNumber
	, D.intSiteID
	, strSiteNumber = RIGHT('000' + CAST(S.intSiteNumber AS NVARCHAR(4)),4) COLLATE Latin1_General_CI_AS 
	, intCustomerId = E.intEntityId
	, strCustomerNumber = E.strEntityNo
	, strCustomerName = E.strName
	, intContractDetailId = D.intContractId
	, CH.strContractNumber
	, CD.intContractSeq
	, strContractNo = CH.strContractNumber + '-' + CAST(CD.intContractSeq AS NVARCHAR)
	, intItemId = ISNULL(D.intSubstituteProductID, D.intProductID)
	, strItemNo = ISNULL(SI.strItemNo, OI.strItemNo)
	, dblQuantity =  CASE WHEN ISNULL(D.dblMinimumQuantity, 0) = 0 THEN ISNULL(D.dblQuantity, 0) ELSE D.dblMinimumQuantity END
	, dblPrice = ISNULL(D.dblPrice, 0.00)
	, dblTotal = ISNULL(D.dblTotal, 0.00)
	, dblOverageQty = ISNULL(D.dblOverageQty, 0.00)
	, dblOveragePrice = ISNULL(D.dblOveragePrice, 0.00)
	, D.intDriverID
	, strDriverName = G.strName
FROM tblTMDispatch D
JOIN tblTMSite S ON S.intSiteID = D.intSiteID
JOIN tblTMCustomer C ON C.intCustomerID = S.intCustomerID
JOIN tblEMEntity E ON E.intEntityId = C.intCustomerNumber
LEFT JOIN tblEMEntity G ON D.intDriverID = G.intEntityId
LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = D.intContractId
LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
LEFT JOIN tblICItem OI ON OI.intItemId = D.intProductID
LEFT JOIN tblICItem SI ON SI.intItemId = D.intSubstituteProductID