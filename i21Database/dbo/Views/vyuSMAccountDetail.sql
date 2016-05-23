﻿CREATE VIEW [dbo].[vyuSMAccountDetail]
AS 
SELECT [AccountDetail].[intAccountId]
	  ,[AccountDetail].[strAccountId]
	  ,[AccountDetail].[strDescription]
	  ,[AccountDetail].[strAccountGroup]
	  ,[AccountDetail].[strAccountType]
	  ,[AccountDetail].[strAccountCategory]
	  ,[AccountDetail].[strComments]
	  ,[AccountDetail].[strCashFlow]
	  ,[AccountDetail].[ysnActive]
	  ,[AccountDetail].[ysnSystem]
	  ,[AccountDetail].[ysnRevalue]
	  ,[AccountDetail].[intAccountUnitId]
	  ,[AccountDetail].[strUOMCode]
	  ,[AccountDetail].[intCurrencyID]
	  ,[AccountDetail].[intCurrencyExchangeRateTypeId]
	  ,[AccountDetail].[strNote]
	  ,[AccountDetail].[strCurrency]
	  ,[AccountDetail].[strCurrencyExchangeRateType]
	  ,[AccountDetail].[intAccountGroupId]
	  ,[AccountDetail].[intAccountCategoryId]
	  ,ISNULL([BankAccount].[ysnActive], 1) AS [ysnBankActive]
FROM [vyuGLAccountDetail] [AccountDetail]
INNER JOIN [tblCMBankAccount] [BankAccount] ON [AccountDetail].[intAccountId] = [BankAccount].[intGLAccountId]
WHERE [BankAccount].[ysnActive] = 1 OR [BankAccount].[ysnActive] IS NULL
