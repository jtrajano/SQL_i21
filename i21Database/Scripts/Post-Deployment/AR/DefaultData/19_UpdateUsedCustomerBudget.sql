print('/*******************  BEGIN Update tblARCustomerBudget.ysnUsedBudget *******************/')
GO

UPDATE tblARCustomerBudget SET ysnUsedBudget = 1 WHERE intCustomerBudgetId
IN (SELECT DISTINCT intCustomerBudgetId 
	FROM tblARCustomerBudget CB INNER JOIN tblARPayment P 
		ON CB.intEntityCustomerId = P.intEntityCustomerId
		AND P.ysnPosted = 1
		AND P.ysnApplytoBudget = 1
		AND P.dtmDatePaid BETWEEN CB.dtmBudgetDate AND DATEADD(DAY, -1, DATEADD(MONTH, 1, dtmBudgetDate)))

GO
print('/*******************  END Update tblARCustomerBudget.ysnUsedBudget *******************/')