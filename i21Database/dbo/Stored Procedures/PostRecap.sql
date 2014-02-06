
CREATE PROCEDURE PostRecap
	@RecapTable RecapTableType READONLY 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- DELETE OLD RECAP DATA (IF IT EXISTS)
DELETE tblGLDetailRecap
FROM	tblGLDetailRecap A INNER JOIN @RecapTable B
			ON (
				A.strTransactionID = B.strTransactionID
				OR A.intTransactionID = B.intTransactionID
			)
			AND  A.strCode = B.strCode

-- INSERT THE RECAP DATA. 
-- THE RECAP DATA WILL BE STORED IN A PERMANENT TABLE SO THAT WE CAN QUERY IT LATER USING A BUFFERED STORE. 
INSERT INTO tblGLDetailRecap (
		[strTransactionID]		
		,[intTransactionID]		
		,[dtmDate]				
		,[strBatchID]			
		,[intAccountID]			
		,[strAccountGroup]		
		,[dblDebit]				
		,[dblCredit]			
		,[dblDebitUnit]			
		,[dblCreditUnit]		
		,[strDescription]		
		,[strCode]				
		,[strReference]			
		,[strJobID]				
		,[intCurrencyID]		
		,[dblExchangeRate]		
		,[dtmDateEntered]		
		,[dtmTransactionDate]	
		,[ysnIsUnposted]		
		,[intConcurrencyId]		
		,[intUserID]			
		,[strTransactionForm]	
		,[strModuleName]		
		,[strUOMCode]	
)
-- RETRIEVE THE DATA FROM THE TABLE VARIABLE. 
SELECT	[strTransactionID]		
		,[intTransactionID]		
		,[dtmDate]				
		,[strBatchID]			
		,[intAccountID]			
		,[strAccountGroup]		
		,[dblDebit]				
		,[dblCredit]			
		,[dblDebitUnit]			
		,[dblCreditUnit]		
		,[strDescription]		
		,[strCode]				
		,[strReference]			
		,[strJobID]				
		,[intCurrencyID]		
		,[dblExchangeRate]		
		,[dtmDateEntered]		
		,[dtmTransactionDate]	
		,[ysnIsUnposted]		
		,[intConcurrencyId]		
		,[intUserID]			
		,[strTransactionForm]	
		,[strModuleName]		
		,[strUOMCode]	
FROM	@RecapTable