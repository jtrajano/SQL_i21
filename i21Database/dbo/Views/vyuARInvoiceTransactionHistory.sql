CREATE VIEW [dbo].[vyuARInvoiceTransactionHistory]
	AS 
	
	SELECT 
		A.intInvoiceId
		,A.intInvoiceDetailId
		,A.dblQtyReceived
		,A.dblPrice
		,A.dblAmountDue
		,A.intItemId
		,A.intItemUOMId
		,A.intCompanyLocationId
		,A.intTicketId
		,A.dtmTicketDate
		,A.dtmTransactionDate
		,A.intCurrencyId
		,B.strInvoiceNumber

		,strItemNo = C.strItemNo
		,strUnitMeasure = C.strUnitMeasure
		,strLocationName = D.strLocationName
		,strLocationNumber = D.strLocationNumber
		,strCurrency = E.strCurrency
		,ysnPost = A.ysnPost
		,A.intCommodityId
		,CM.strCommodityCode
	FROM
		tblARInvoiceTransactionHistory A
	INNER JOIN tblARInvoice B
		ON B.[intInvoiceId] = A.intInvoiceId
	LEFT JOIN vyuICItemUOM C
		ON C.intItemId = A.intItemId 
			AND C.intItemUOMId = A.intItemUOMId
	LEFT JOIN tblSMCompanyLocation D
		ON A.intCompanyLocationId = D.intCompanyLocationId
	LEFT JOIN tblSMCurrency E
		ON A.intCurrencyId = E.intCurrencyID
	LEFT JOIN (select intCommodityId, strCommodityCode from tblICCommodity with(nolock)) CM
		on CM.intCommodityId = A.intCommodityId
