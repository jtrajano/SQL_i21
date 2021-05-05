CREATE FUNCTION [dbo].[fnGRGetGLEntriesErrors_DPtoDP] (
	@GLEntriesToValidate RecapTableType READONLY,
	@ysnPost BIT
)
RETURNS  @tbl TABLE (
		strText nvarchar(150)  COLLATE Latin1_General_CI_AS NULL,
		intErrorCode int, 
		strModuleName nvarchar(100)  COLLATE Latin1_General_CI_AS NULL
	)
AS
BEGIN 
	;WITH BatchError AS (
				SELECT	'' strText
						,60001 intErrorCode
						,strModuleName
				FROM	@GLEntriesToValidate GLEntries 
				WHERE	NOT EXISTS (SELECT intAccountId FROM dbo.tblGLAccount Account WHERE Account.intAccountId = GLEntries.intAccountId)
		
				-- Debit and credit amounts are not balanced.
				UNION ALL 
				SELECT	'' strText
						,60003 intErrorCode
						,strModuleName
				FROM	(
							SELECT	SUM(ISNULL(ToValidate.dblDebit, 0)) dblDebit
									,SUM(ISNULL(ToValidate.dblCredit, 0)) dblCredit
									,ToValidate.strModuleName
							FROM	@GLEntriesToValidate ToValidate 
							INNER JOIN dbo.tblGLAccount Account
								ON ToValidate.intAccountId = Account.intAccountId
							GROUP BY ToValidate.strModuleName
						) SubQuery
				
				WHERE	SubQuery.dblDebit <> SubQuery.dblCredit		
				
		) --END WITH
		INSERT INTO @tbl 
		SELECT
			CASE 
				WHEN a.strText  = '' 
					THEN  PostError.strMessage 
				ELSE 
					REPLACE(PostError.strMessage,'{0}',a.strText) END strText
		,a.intErrorCode, strModuleName FROM BatchError a
		CROSS APPLY (SELECT strMessage from dbo.fnGLGetGLEntriesErrorMessage() where intErrorCode = a.intErrorCode)AS  PostError

		RETURN
		
END