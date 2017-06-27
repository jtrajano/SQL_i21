CREATE VIEW [dbo].[vyuPATStockClassification]
	AS
SELECT	SC.intStockId,
		SC.strStockName,
		SC.strStockDescription,
		SC.dblParValue,
		SC.intDividendsGLAccount,
		strDividendsAccount = GL.strAccountId,
		SC.intDividendsPerShare,
		SC.intConcurrencyId
FROM tblPATStockClassification SC
LEFT JOIN tblGLAccount GL
	ON GL.intAccountId = SC.intDividendsGLAccount