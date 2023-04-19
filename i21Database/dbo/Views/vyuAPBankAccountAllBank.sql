CREATE VIEW [dbo].[vyuAPBankAccountAllBank]
AS
SELECT 0 intBankAccountId,
	   'All Bank' strBankAccountNo,
	   NULL strBankAccountHolder,
	   0 intBankId,
	   'All Bank' strBankName,
	   0 intGLAccountId,
	   NULL strCbkNo,
	   0 intCurrencyId,
	   NULL strCurrency,
	   0 intNextCheckNo,
	   CAST(1 AS BIT) ysnActive,
	   NULL strRTN,
	   NULL strGLAccountId,
	   NULL strGLAccountDescription,
	   NULL strIBAN,
	   NULL strSWIFT,
	   NULL strResponsibleEntity,
	   0 intResponsibleEntityId,
	   CAST(0 AS BIT) ysnABREnable,
	   NULL strLocation,
	   0 intLocationSegmentId,
	   NULL strNickname,
	   NULL dtmLastReconciliationDate

UNION

SELECT BA.intBankAccountId,
	   BA.strBankAccountNo,
	   BA.strBankAccountHolder,
	   BA.intBankId,
	   BA.strBankName,
	   BA.intGLAccountId,
       BA.strCbkNo,
	   BA.intCurrencyId,
       BA.strCurrency,
	   intNextCheckNo = BA.intCheckNextNo,
	   BA.ysnActive,
	   BA.strRTN,
	   strGLAccountId = A.strAccountId,
	   strGLAccountDescription = A.strDescription,
	   BA.strIBAN,
	   BA.strSWIFT,
	   BA.strResponsibleEntity,
	   BA.intResponsibleEntityId,
	   CAST(ISNULL(BA.ysnABREnable, 0) AS BIT),
	   strLocation = LA.strCode,
	   intLocationSegmentId = ISNULL(A.intLocationSegmentId, LA.intAccountSegmentId),
	   BA.strNickname,
	   BA.dtmLastReconciliationDate
FROM vyuCMBankAccount BA
INNER JOIN tblGLAccount A ON A.intAccountId = BA.intGLAccountId
INNER JOIN vyuGLLocationAccountId LA ON LA.intAccountId = BA.intGLAccountId