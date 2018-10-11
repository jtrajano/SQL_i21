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
    ,[strAccountCategory]   = GLAD.[strAccountCategory]
    ,[ysnActive]            = GLAD.[ysnActive]
FROM
    #ARPostPaymentHeader ARPH
INNER JOIN
    vyuGLAccountDetail GLAD
        ON ARPH.[intUndepositedFundsId] = GLAD.[intAccountId]

INSERT INTO #ARPaymentAccount
	([intAccountId]
    ,[strAccountId]
    ,[strAccountCategory]
    ,[ysnActive])
SELECT DISTINCT
     [intAccountId]         = GLAD.[intAccountId]
    ,[strAccountId]         = GLAD.[strAccountId]
    ,[strAccountCategory]   = GLAD.[strAccountCategory]
    ,[ysnActive]            = GLAD.[ysnActive]
FROM
    #ARPostPaymentHeader ARPH
INNER JOIN
	tblCMBankAccount CMBA
        ON ARPH.[intBankAccountId] = CMBA.[intBankAccountId]
INNER JOIN
    vyuGLAccountDetail GLAD
        ON CMBA.[intGLAccountId] = GLAD.[intAccountId]
WHERE
	ARPH.[intBankAccountId] IS NULL
	AND NOT EXISTS (SELECT NULL FROM #ARPaymentAccount A WHERE GLAD.[intAccountId] = A.[intAccountId])

INSERT INTO #ARPaymentAccount
	([intAccountId]
    ,[strAccountId]
    ,[strAccountCategory]
    ,[ysnActive])
SELECT DISTINCT
     [intAccountId]         = GLAD.[intAccountId]
    ,[strAccountId]         = GLAD.[strAccountId]
    ,[strAccountCategory]   = GLAD.[strAccountCategory]
    ,[ysnActive]            = GLAD.[ysnActive]
FROM
    #ARPostPaymentHeader ARPH
INNER JOIN
	tblCMBankAccount CMBA
        ON ARPH.[intBankAccountId] = CMBA.[intBankAccountId]
INNER JOIN
    vyuGLAccountDetail GLAD
        ON CMBA.[intGLAccountId] = GLAD.[intAccountId]
WHERE
	ARPH.[intBankAccountId] IS NOT NULL
	AND NOT EXISTS (SELECT NULL FROM #ARPaymentAccount A WHERE GLAD.[intAccountId] = A.[intAccountId])


RETURN 1
