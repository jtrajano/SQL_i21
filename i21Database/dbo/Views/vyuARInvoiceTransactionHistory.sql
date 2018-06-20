CREATE VIEW [dbo].[vyuARInvoiceTransactionHistory]
	AS 
	
	SELECT DISTINCT
		A.intInvoiceId
		,A.intInvoiceDetailId
		,dblQtyReceived = A.dblQtyReceived
		,A.dblPrice
		,dblAmountDue = A.dblAmountDue
		,isnull(A.dblInvoicePayment, 0) as dblAmountPaid
		,A.intItemId
		,A.intItemUOMId
		,A.intCompanyLocationId
		,A.intTicketId
		,A.dtmTicketDate
		,A.dtmTransactionDate
		,A.intCurrencyId
		,B.strInvoiceNumber
		,strTicketNumber = ST.strTicketNumber
		,strItemNo = C.strItemNo
		,strUnitMeasure = C.strUnitMeasure
		,strLocationName = D.strLocationName
		,strLocationNumber = D.strLocationNumber
		,strCurrency = E.strCurrency
		,ysnPost = A.ysnPost
		,A.intCommodityId
		,CM.strCommodityCode
		, strEvent = case  (A.ysnPost) when 1 then  'Post' when 0 then 'Unpost' else 'Add/Edit' end
		--, dblBalanceAmount = A.dblInvoiceAmountDue + A.dblInvoicePayment
	FROM
		tblARInvoiceTransactionHistory A
	INNER JOIN tblARInvoice B
		ON B.[intInvoiceId] = A.intInvoiceId
	LEFT JOIN (select (isnull(dblBasePayment, 0) + isnull(dblBaseDiscount,0)) dblPayment, intInvoiceId, P.intPaymentId from tblARPaymentDetail PD INNER JOIN tblARPayment P ON PD.intPaymentId = P.intPaymentId) P
		ON P.intInvoiceId = A.intInvoiceId 
	LEFT JOIN vyuICItemUOM C
		ON C.intItemId = A.intItemId 
			AND C.intItemUOMId = A.intItemUOMId
	LEFT JOIN tblSMCompanyLocation D
		ON A.intCompanyLocationId = D.intCompanyLocationId
	LEFT JOIN tblSMCurrency E
		ON A.intCurrencyId = E.intCurrencyID
	LEFT JOIN (select intCommodityId, strCommodityCode from tblICCommodity with(nolock)) CM
		on CM.intCommodityId = A.intCommodityId
	left join (select intTicketId, dtmTicketDateTime, strTicketNumber from tblSCTicket) ST
		on ST.intTicketId = A.intTicketId
