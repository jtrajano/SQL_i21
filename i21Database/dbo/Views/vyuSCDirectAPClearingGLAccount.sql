CREATE VIEW [dbo].[vyuSCDirectAPClearingGLAccount]
	AS 


SELECT

	DETAIL.strTransactionId,
	DETAIL.strTransactionForm,
	DETAIL.strTransactionType, 
	DETAIL.dblDebit,
	DETAIL.dblCredit,
	DETAIL.dblDebitUnit,
	DETAIL.dblCreditUnit,
	DETAIL.strCode,
	ACCOUNT_DETAIL.intAccountCategoryId,
	DETAIL.strReference,
	ACCOUNT_DETAIL.strAccountId,
	ACCOUNT_DETAIL.strAccountId1,
	ACCOUNT_DETAIL.strAccountCategory,
	DETAIL.ysnIsUnposted,
	TICKET.strTicketNumber AS strSourceTransactionId,
	DETAIL.dtmDate,
	DETAIL.dtmTransactionDate


FROM tblGLDetail DETAIL 
	JOIN tblSCTicket TICKET
		ON DETAIL.intTransactionId = TICKET.intTicketId
	JOIN vyuGLAccountDetail ACCOUNT_DETAIL
		ON DETAIL.intAccountId = ACCOUNT_DETAIL.intAccountId

WHERE DETAIL.strCode = 'SCTKT' 

UNION ALL



--SELECT intBillId, * FROM tblSCTicket WHERE strTicketNumber = '070122'
SELECT DETAIL.strTransactionId,
	DETAIL.strTransactionForm,
	DETAIL.strTransactionType, 
	DETAIL.dblDebit,
	DETAIL.dblCredit,
	DETAIL.dblDebitUnit,
	DETAIL.dblCreditUnit,
	DETAIL.strCode,
	ACCOUNT_DETAIL.intAccountCategoryId,
	DETAIL.strReference,
	ACCOUNT_DETAIL.strAccountId,
	ACCOUNT_DETAIL.strAccountId1,
	ACCOUNT_DETAIL.strAccountCategory,
	DETAIL.ysnIsUnposted,
	TICKET.strTicketNumber AS strSourceTransactionId,
	DETAIL.dtmDate,
	DETAIL.dtmTransactionDate

FROM tblSCTicket TICKET
		
	JOIN vyuSCDirectAPClearing AP_CLEARING
		ON TICKET.intTicketId = AP_CLEARING.intTicketId
			AND AP_CLEARING.intBillId IS NOT NULL
	JOIN tblGLDetail DETAIL 
		ON AP_CLEARING.intBillId = DETAIL.intTransactionId 
	JOIN vyuGLAccountDetail ACCOUNT_DETAIL
		ON DETAIL.intAccountId = ACCOUNT_DETAIL.intAccountId
WHERE DETAIL.strCode = 'AP' 