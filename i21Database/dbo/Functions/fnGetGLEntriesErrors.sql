﻿/**
* This function will validate the GL entries for post (or unpost) and it will return any error found. 
* 
* Sample usage: 
*	DECLARE @GLEntries AS RecapTableType
*
*	SELECT	*
*	FROM	dbo.fnGetGLEntriesErrors(@GLEntries)
* 
*/

CREATE FUNCTION [dbo].[fnGetGLEntriesErrors] (
	@GLEntriesToValidate RecapTableType READONLY,
	@ysnPost BIT
)
RETURNS  @tbl TABLE (
		strTransactionId nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
		strText nvarchar(150)  COLLATE Latin1_General_CI_AS NULL,
		intErrorCode int, 
		strModuleName nvarchar(100)  COLLATE Latin1_General_CI_AS NULL
	)
AS
BEGIN 
	DECLARE @intDefaultCurrencyId INT
	SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference 
	;WITH BatchError AS (
				SELECT   strTransactionId
					    ,strTransactionId strText
						,60018 intErrorCode
						,strModuleName		
				FROM @GLEntriesToValidate GLEntries
				WHERE (dblCredit <> (ROUND(dblCreditForeign * dblExchangeRate, 2)))
				AND ISNULL(dblCreditForeign,0) <> 0
				AND ISNULL(intCurrencyId,@intDefaultCurrencyId) <> @intDefaultCurrencyId
				UNION ALL
				SELECT   strTransactionId
					    ,strTransactionId strText
						,60018 intErrorCode
						,strModuleName		
				FROM @GLEntriesToValidate GLEntries
				WHERE (dblDebit <> (ROUND(dblDebitForeign * dblExchangeRate, 2)))
				AND ISNULL(dblDebitForeign,0) <> 0
				AND ISNULL(intCurrencyId,@intDefaultCurrencyId) <> @intDefaultCurrencyId
				UNION ALL
				SELECT	strTransactionId
						,'' strText
						,60001 intErrorCode
						,strModuleName
				FROM	@GLEntriesToValidate GLEntries 
				WHERE	NOT EXISTS (SELECT intAccountId FROM dbo.tblGLAccount Account WHERE Account.intAccountId = GLEntries.intAccountId)
		
				-- Debit and credit amounts are not balanced.
				UNION ALL 
				SELECT	SubQuery.strTransactionId
						,'' strText
						,60003 intErrorCode
						,strModuleName
				FROM	(
							SELECT	ToValidate.strTransactionId
									,SUM(ISNULL(ToValidate.dblDebit, 0)) dblDebit
									,SUM(ISNULL(ToValidate.dblCredit, 0)) dblCredit
									,ToValidate.strModuleName
							FROM	@GLEntriesToValidate ToValidate INNER JOIN dbo.tblGLAccount Account
										ON ToValidate.intAccountId = Account.intAccountId
							GROUP BY ToValidate.strTransactionId,ToValidate.strModuleName
						) SubQuery
				
				WHERE	SubQuery.dblDebit <> SubQuery.dblCredit
				UNION ALL 
				SELECT	strTransactionId
						,'' strText
						,60004 intErrorCode
						,GLEntries.strModuleName
				FROM	(SELECT DISTINCT strTransactionId, dtmDate,strModuleName FROM @GLEntriesToValidate
				WHERE 
				ISNULL(strCode, '') <>'AA' 
				AND ISNULL(strCode, '') <>'REVAL'
				AND strTransactionType NOT IN('Origin Journal','Adjusted Origin Journal')) GLEntries
				WHERE	dbo.isOpenAccountingDate(dtmDate) = 0
		
				UNION ALL 

				-- G/L entries are expected. Cannot continue because it is missing.
				SELECT	NULL strTransactionId 
						,'' strText
						,60005 intErrorCode
						,NULL strModuleName
				WHERE	NOT EXISTS (SELECT TOP 1 1 FROM @GLEntriesToValidate)

				--Cannot continue if Module status in fiscal year period is closed (CM,AR,INV,AP)
				UNION ALL 
				SELECT	 strTransactionId
						,GLEntries.strModuleName strText
						,60009 intErrorCode
						,strModuleName
				FROM	(SELECT DISTINCT strTransactionId, dtmDate,strModuleName 
				FROM @GLEntriesToValidate 
				WHERE
				ISNULL(strCode, '') <>'AA' 
				AND ISNULL(strCode, '') <>'REVAL' 
				AND strTransactionType NOT IN('Origin Journal','Adjusted Origin Journal')) GLEntries
				WHERE	dbo.isOpenAccountingDateByModule(dtmDate,strModuleName) = 0
		
				UNION ALL 
				SELECT	A.strTransactionId
						,B.strAccountId strText
						,60015 intErrorCode
						,A.strModuleName
				FROM	@GLEntriesToValidate A JOIN
				dbo.tblGLAccount B ON A.intAccountId = B.intAccountId
				WHERE	B.ysnActive = 0 AND ISNULL( A.ysnRebuild,0) = 0
				AND strTransactionType NOT IN('Origin Journal','Adjusted Origin Journal')
				UNION ALL
				--19.1 GL-6618 GL Posting - Decimal Scale 
				SELECT	A.strTransactionId
						,B.strAccountId strText	
						,60017 intErrorCode
						,A.strModuleName
				FROM	@GLEntriesToValidate A JOIN
				dbo.tblGLAccount B ON A.intAccountId = B.intAccountId
				CROSS APPLY (SELECT  dbo.fnGLCheckScale(A.dblDebit) Passed) DebitScale
				CROSS APPLY (SELECT  dbo.fnGLCheckScale(A.dblCredit) Passed) CreditScale
				WHERE (DebitScale.Passed = -1 OR CreditScale.Passed = -1)
				AND @ysnPost = 1
				AND strTransactionType NOT IN('Origin Journal','Adjusted Origin Journal')
		) --END WITH
		INSERT INTO @tbl 
		SELECT strTransactionId
		,CASE 
				WHEN a.strText  = '' 
					THEN  PostError.strMessage 
				ELSE 
					REPLACE(PostError.strMessage,'{0}',a.strText) END strText
		,a.intErrorCode, strModuleName FROM BatchError a
		CROSS APPLY (SELECT strMessage from dbo.fnGLGetGLEntriesErrorMessage() where intErrorCode = a.intErrorCode)AS  PostError
		GROUP BY strTransactionId,PostError.strMessage,a.strText,a.intErrorCode,strModuleName
		ORDER BY strTransactionId

		RETURN
		
END