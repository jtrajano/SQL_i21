CREATE VIEW [dbo].[vyuARSAByItemClass]
AS
SELECT A.strClassCode
	, dblPTDThisYear = SUM(A.dblPTDThisYear)
	, dblYTDThisYear = SUM(A.dblYTDThisYear)
	, dblPTDLastYear = SUM(A.dblPTDLastYear)
	, dblYTDLastYear = SUM(A.dblYTDLastYear)
	, dblPTDVariance = SUM(A.dblPTDThisYear) - SUM(A.dblPTDLastYear)
	, dblYTDVariance = SUM(A.dblYTDThisYear) - SUM(A.dblYTDLastYear)
FROM 
(SELECT C.strCategoryCode AS strClassCode
     , C.strDescription
	 , dblPTDThisYear = 0
	 , dblYTDThisYear = CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(ID.dblTotal, 0) * -1 ELSE ISNULL(ID.dblTotal, 0) END
	 , dblPTDLastYear = 0
	 , dblYTDLastYear = 0
FROM tblICCategory C
	LEFT JOIN tblICItem IC ON C.intCategoryId = IC.intCategoryId
	LEFT JOIN (tblARInvoiceDetail ID 
		INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
			   AND I.ysnPosted = 1
			   AND YEAR(I.dtmPostDate) =  DATEPART(year, GETDATE())
			   AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
											INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
											WHERE AG.strAccountGroup = 'Receivables')) ON IC.intItemId = ID.intItemId

UNION ALL

SELECT C.strCategoryCode AS strClassCode
     , C.strDescription
	 , dblPTDThisYear = 0
	 , dblYTDThisYear = 0
	 , dblPTDLastYear = 0
	 , dblYTDLastYear = CASE WHEN I.strTransactionType <> 'Invoice' THEN ISNULL(ID.dblTotal, 0) * -1 ELSE ISNULL(ID.dblTotal, 0) END
FROM tblICCategory C
	LEFT JOIN tblICItem IC ON C.intCategoryId = IC.intCategoryId
	LEFT JOIN (tblARInvoiceDetail ID 
		INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
			   AND I.ysnPosted = 1
			   AND YEAR(I.dtmPostDate) =  DATEPART(year, GETDATE()) -1
			   AND I.intAccountId IN (SELECT intAccountId FROM tblGLAccount A
											INNER JOIN tblGLAccountGroup AG ON A.intAccountGroupId = AG.intAccountGroupId
											WHERE AG.strAccountGroup = 'Receivables')) ON IC.intItemId = ID.intItemId) AS A

GROUP BY A.strClassCode, A.strDescription