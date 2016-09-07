CREATE VIEW [dbo].[vyuARServiceChargeRecap]
AS
SELECT SCR.*
     , SCRD.intSCRecapDetailId
	 , SCRD.strInvoiceNumber
	 , SCRD.strBudgetDescription
	 , SCRD.dblAmount
	 , strCustomerName	= EM.strName
	 , strSCAccount		= GL.strAccountId
	 , strSCAccountDesc = GL.strDescription
FROM tblARServiceChargeRecap SCR
	INNER JOIN tblARServiceChargeRecapDetail SCRD ON SCR.intSCRecapId = SCRD.intSCRecapId
	LEFT JOIN tblEMEntity EM ON SCR.intEntityId = EM.intEntityId
	LEFT JOIN tblGLAccount GL ON SCR.intServiceChargeAccountId = GL.intAccountId
