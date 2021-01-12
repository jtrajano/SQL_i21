CREATE VIEW [dbo].[vyuPATClearingItem]
AS 
SELECT strRefundNo			= R.strRefundNo
	 , intRefundId			= R.intRefundId
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
	 , strAccountId			= GL.strAccountId
FROM tblPATRefund R
INNER JOIN tblPATRefundCustomer RC ON R.intRefundId = RC.intRefundId 
LEFT JOIN tblAPBill B ON RC.intBillId = B.intBillId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = B.intShipToId
CROSS APPLY (
	SELECT TOP 1 GL.intAccountId
			   , GLAD.strAccountId			   
	FROM tblGLDetail GL
	INNER JOIN vyuGLAccountDetail GLAD ON GL.intAccountId = GLAD.intAccountId
	WHERE GL.ysnIsUnposted = 0
	  AND GLAD.strAccountCategory = 'AP Clearing'
	  AND R.strRefundNo = GL.strTransactionId
	  AND R.intRefundId = GL.intTransactionId
) GL 
WHERE R.ysnPosted = 1
  AND RC.ysnEligibleRefund = 1