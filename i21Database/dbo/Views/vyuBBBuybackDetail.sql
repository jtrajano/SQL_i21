﻿CREATE VIEW [dbo].[vyuBBBuybackDetail]
AS  
	SELECT 
		A.* 
		,strCustomerNumber =  N.strVendorSoldTo
		,strCustomerLocation = K.strLocationName
		,C.strInvoiceNumber
		,dtmInvoiceDate = C.dtmDate
		,strItemNumber = D.strItemNo
		,strItemDescription = D.strDescription
		,strCategoryCode = F.strCategoryCode
		,strUnitMeasure = H.strUnitMeasure
		,strChargeItemDescription = M.strDescription
		,intChargedItemId = M.intItemId
	FROM tblBBBuybackDetail A
	INNER JOIN tblARInvoiceDetail B
		ON A.intInvoiceDetailId = B.intInvoiceDetailId
	INNER JOIN tblARInvoice C 
		ON B.intInvoiceId = C.intInvoiceId
	INNER JOIN tblICItem D
		ON A.intItemId = D.intItemId
	INNER JOIN tblBBRate E
		ON A.intProgramRateId = E.intRateId
	INNER JOIN tblICCategory F
		ON D.intCategoryId = F.intCategoryId
	INNER JOIN tblICItemUOM G
		ON D.intItemId = G.intItemUOMId
	INNER JOIN tblICUnitMeasure H
	    ON G.intUnitMeasureId = H.intUnitMeasureId
	INNER JOIN tblEMEntity J
		ON C.intEntityCustomerId = J.intEntityId
	INNER JOIN tblEMEntityLocation K
		ON C.intShipToLocationId = K.intEntityLocationId
	INNER JOIN tblBBProgramCharge L
		ON E.intProgramChargeId = L.intProgramChargeId
	INNER JOIN tblICItem M
		ON L.intItemId = M.intItemId
	INNER JOIN tblBBCustomerLocationXref N
		ON C.intShipToLocationId = N.intEntityLocationId

GO

