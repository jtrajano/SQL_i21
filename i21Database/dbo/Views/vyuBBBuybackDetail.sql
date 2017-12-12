CREATE VIEW [dbo].[vyuBBBuybackDetail]
AS  
	SELECT 
		A.* 
		,strCustomerNumber =  J.strEntityNo
		,strCustomerLocation = K.strLocationName
		,C.strInvoiceNumber
		,dtmInvoiceDate = C.dtmDate
		,strItemNumber = E.strItemNo
		,strItemDescription = E.strDescription
		,strCategoryCode = F.strCategoryCode
		,strUnitMeasure = H.strUnitMeasure
		,strChargeItemDescription = D.strDescription
	FROM tblBBBuybackDetail A
	INNER JOIN tblARInvoiceDetail B
		ON A.intInvoiceDetailId = B.intInvoiceDetailId
	INNER JOIN tblARInvoice C 
		ON B.intInvoiceId = C.intInvoiceId
	INNER JOIN tblICItem D
		ON A.intItemId = A.intItemId
	INNER JOIN tblICItem E
		ON B.intItemId = E.intItemId
	INNER JOIN tblICCategory F
		ON E.intCategoryId = F.intCategoryId
	INNER JOIN tblICItemUOM G
		ON E.intItemId = B.intItemUOMId
	INNER JOIN tblICUnitMeasure H
	    ON G.intUnitMeasureId = H.intUnitMeasureId
	INNER JOIN tblEMEntity J
		ON C.intEntityCustomerId = J.intEntityId
	INNER JOIN tblEMEntityLocation K
		ON C.intShipToLocationId = K.intEntityLocationId

GO

