CREATE VIEW [dbo].[vyuPATClearingItemGL]
AS 
SELECT DISTINCT 
	   strRefundNo			= GL.strTransactionId
	 , intRefundId			= GL.intTransactionId
	 , dtmDate				= R.dtmRefundDate
	 , intRefundCustomerId	= RC.intRefundCustomerId
	 , intUnitMeasureId		= NULL
	 , strUnitMeasure		= NULL
	 , intItemId			= NULL
	 , dblQty				= 1.000000
	 , dblAmount			= dblCashRefund
	 , dblAmountForeign		= dblCashRefund
	 , dblTaxForeign		= 0.000000
	 , intLocationId		= B.intShipToId
	 , strLocationName		= CL.strLocationName
	 , intAccountId			= GL.intAccountId
	 , strAccountId			= GLAD.strAccountId
FROM tblGLDetail GL
INNER JOIN vyuGLAccountDetail GLAD ON GL.intAccountId = GLAD.intAccountId
LEFT JOIN tblPATRefund R ON GL.strTransactionId = R.strRefundNo AND GL.intTransactionId = R.intRefundId
LEFT JOIN tblPATRefundCustomer RC ON R.intRefundId = RC.intRefundId 
LEFT JOIN tblAPBill B ON RC.intBillId = B.intBillId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = B.intShipToId
WHERE GL.ysnIsUnposted = 0
  AND GLAD.strAccountCategory = 'AP Clearing'
  AND GL.strTransactionForm = 'Refund'
  AND GL.strModuleName = 'Patronage'
  AND RC.intBillId IS NOT NULL