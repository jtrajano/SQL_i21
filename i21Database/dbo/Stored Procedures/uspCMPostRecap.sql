﻿CREATE PROCEDURE uspCMPostRecap
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
				A.strTransactionId = B.strTransactionId
				OR A.intTransactionId = B.intTransactionId
			)
			AND  A.strCode = B.strCode

-- INSERT THE RECAP DATA. 
-- THE RECAP DATA WILL BE STORED IN A PERMANENT TABLE SO THAT WE CAN QUERY IT LATER USING A BUFFERED STORE. 
INSERT INTO tblGLDetailRecap (
		[strTransactionId]		
		,[intTransactionId]		
		,[dtmDate]				
		,[strBatchId]			
		,[intAccountId]			
		,[strAccountGroup]		
		,[dblDebit]				
		,[dblCredit]			
		,[dblDebitUnit]			
		,[dblCreditUnit]		
		,[strDescription]		
		,[strCode]				
		,[strReference]			
		,[strJobId]				
		,[intCurrencyId]		
		,[dblExchangeRate]		
		,[dtmDateEntered]		
		,[dtmTransactionDate]	
		,[ysnIsUnposted]		
		,[intConcurrencyId]		
		,[intUserId]			
		,[strTransactionForm]	
		,[strModuleName]		
		,[strUOMCode]
		,[intEntityId]
)
-- RETRIEVE THE DATA FROM THE TABLE VARIABLE. 
SELECT	[strTransactionId]		
		,[intTransactionId]		
		,[dtmDate]				
		,[strBatchId]			
		,[intAccountId]			
		,[strAccountGroup]		
		,[dblDebit]				
		,[dblCredit]			
		,[dblDebitUnit]			
		,[dblCreditUnit]		
		,[strDescription]		
		,[strCode]				
		,[strReference]			
		,[strJobId]				
		,[intCurrencyId]		
		,[dblExchangeRate]		
		,[dtmDateEntered]		
		,[dtmTransactionDate]	
		,[ysnIsUnposted]		
		,[intConcurrencyId]		
		,[intUserId]			
		,[strTransactionForm]	
		,[strModuleName]		
		,[strUOMCode]
		,[intEntityId]
FROM	@RecapTable