CREATE PROCEDURE [dbo].[uspARPopulatePaymentAccountForPosting]
AS
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF  


INSERT INTO #ARPaymentAccount
	([intAccountId]
    ,[strAccountId]
    ,[strAccountCategory]
    ,[ysnActive])
SELECT  DISTINCT
     [intAccountId]         = GLAD.[intAccountId]
    ,[strAccountId]         = GLAD.[strAccountId]
    ,[strAccountCategory]   = GLS.[strAccountCategory]
    ,[ysnActive]            = GLAD.[ysnActive]
FROM #ARPostPaymentHeader ARPH
INNER JOIN tblGLAccount GLAD ON ARPH.[intUndepositedFundsId] = GLAD.[intAccountId]
CROSS APPLY (
	SELECT CAT.strAccountCategory
	FROM dbo.tblGLAccountSegmentMapping M 
	LEFT JOIN dbo.tblGLAccountSegment S ON S.intAccountSegmentId = M.intAccountSegmentId
	LEFT JOIN dbo.tblGLAccountCategory CAT ON S.intAccountCategoryId = CAT.intAccountCategoryId
	INNER JOIN dbo.tblGLAccountStructure ST ON S.intAccountStructureId = ST.intAccountStructureId AND ST.strType = 'Primary'
	WHERE intAccountId = GLAD.intAccountId
) GLS





INSERT INTO #ARPaymentAccount
	([intAccountId]
    ,[strAccountId]
    ,[strAccountCategory]
    ,[ysnActive])
SELECT DISTINCT
     [intAccountId]         = GLAD.[intAccountId]
    ,[strAccountId]         = GLAD.[strAccountId]
    ,[strAccountCategory]   = GLS.[strAccountCategory]
    ,[ysnActive]            = GLAD.[ysnActive]
FROM #ARPostPaymentHeader ARPH
INNER JOIN tblCMBankAccount CMBA ON ARPH.[intBankAccountId] = CMBA.[intBankAccountId]
INNER JOIN tblGLAccount GLAD ON CMBA.[intGLAccountId] = GLAD.[intAccountId]
CROSS APPLY (
	SELECT CAT.strAccountCategory
	FROM dbo.tblGLAccountSegmentMapping M 
	LEFT JOIN dbo.tblGLAccountSegment S ON S.intAccountSegmentId = M.intAccountSegmentId
	LEFT JOIN dbo.tblGLAccountCategory CAT ON S.intAccountCategoryId = CAT.intAccountCategoryId
	INNER JOIN dbo.tblGLAccountStructure ST ON S.intAccountStructureId = ST.intAccountStructureId AND ST.strType = 'Primary'
	WHERE intAccountId = GLAD.intAccountId
) GLS
WHERE ARPH.[intBankAccountId] IS NULL
 AND NOT EXISTS (SELECT NULL FROM #ARPaymentAccount A WHERE GLAD.[intAccountId] = A.[intAccountId])


--INSERT INTO #ARPaymentAccount
--	([intAccountId]
--    ,[strAccountId]
--    ,[strAccountCategory]
--    ,[ysnActive])
--SELECT DISTINCT
--     [intAccountId]         = GLAD.[intAccountId]
--    ,[strAccountId]         = GLAD.[strAccountId]
--    ,[strAccountCategory]   = GLAD.[strAccountCategory]
--    ,[ysnActive]            = GLAD.[ysnActive]
--FROM
--    #ARPostPaymentHeader ARPH
--INNER JOIN
--	tblCMBankAccount CMBA
--        ON ARPH.[intBankAccountId] = CMBA.[intBankAccountId]
--INNER JOIN
--    vyuGLAccountDetail GLAD
--        ON CMBA.[intGLAccountId] = GLAD.[intAccountId]
--WHERE
--	ARPH.[intBankAccountId] IS NOT NULL
--	AND NOT EXISTS (SELECT NULL FROM #ARPaymentAccount A WHERE GLAD.[intAccountId] = A.[intAccountId])


RETURN 1
