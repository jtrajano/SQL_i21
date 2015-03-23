-- --------------------------------------------------
-- Script for SQL Server 2005, 2008, and Azure
-- Purpose: Insert fresh data for CM transaction types. 
-- --------------------------------------------------
-- Date Created: 10/09/2013 5:32 PM
-- Created by: Feb Montefrio
-- --------------------------------------------------

print('/*******************  BEGIN Populate Bank Transaction Types *******************/')

INSERT INTO dbo.[tblCMBankTransactionType] (
	[intBankTransactionTypeId]
	,[strBankTransactionTypeName]
	,[intConcurrencyId]
)
SELECT 
	[intBankTransactionTypeId]		= 1
	,[strBankTransactionTypeName]	= 'Bank Deposit'
	,[intConcurrencyId]				= 1
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeId] = 1)
	
UNION ALL 
SELECT 
	[intBankTransactionTypeId]		= 2
	,[strBankTransactionTypeName]	= 'Bank Withdrawal'
	,[intConcurrencyId]				= 1
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeId] = 2)
	
UNION ALL 
SELECT 
	[intBankTransactionTypeId]		= 3
	,[strBankTransactionTypeName]	= 'Misc Checks'
	,[intConcurrencyId]				= 1
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeId] = 3)
	
UNION ALL 
SELECT 
	[intBankTransactionTypeId]		= 4
	,[strBankTransactionTypeName]	= 'Bank Transfer'
	,[intConcurrencyId]				= 1
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeId] = 4)

UNION ALL 
SELECT 
	[intBankTransactionTypeId]		= 5
	,[strBankTransactionTypeName]	= 'Bank Transaction'
	,[intConcurrencyId]				= 1
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeId] = 5)
	
UNION ALL 
SELECT 
	[intBankTransactionTypeId]		= 6
	,[strBankTransactionTypeName]	= 'Credit Card Charge'
	,[intConcurrencyId]				= 1
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeId] = 6)
	
UNION ALL 
SELECT 
	[intBankTransactionTypeId]		= 7
	,[strBankTransactionTypeName]	= 'Credit Card Returns'
	,[intConcurrencyId]				= 1
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeId] = 7)
	
UNION ALL 
SELECT 
	[intBankTransactionTypeId]		= 8
	,[strBankTransactionTypeName]	= 'Credit Card Payments'
	,[intConcurrencyId]				= 1
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeId] = 8)	
	
UNION ALL 
SELECT 
	[intBankTransactionTypeId]		= 9
	,[strBankTransactionTypeName]	= 'Bank Transfer (WD)'
	,[intConcurrencyId]				= 1
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeId] = 9)	
	
UNION ALL 
SELECT 
	[intBankTransactionTypeId]		= 10
	,[strBankTransactionTypeName]	= 'Bank Transfer (DEP)'
	,[intConcurrencyId]				= 1
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeId] = 10)		
	
UNION ALL 
SELECT 
	[intBankTransactionTypeId]		= 11
	,[strBankTransactionTypeName]	= 'Origin Deposit'
	,[intConcurrencyId]				= 1	
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeId] = 11)	
	
UNION ALL 
SELECT 
	[intBankTransactionTypeId]		= 12
	,[strBankTransactionTypeName]	= 'Origin Checks'
	,[intConcurrencyId]				= 1	
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeId] = 12)	
UNION ALL 
SELECT 
	[intBankTransactionTypeId]		= 13
	,[strBankTransactionTypeName]	= 'Origin EFT'
	,[intConcurrencyId]				= 1			
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeId] = 13)
UNION ALL 
SELECT 
	[intBankTransactionTypeId]		= 14
	,[strBankTransactionTypeName]	= 'Origin Withdrawal'
	,[intConcurrencyId]				= 1			
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeId] = 14)
UNION ALL 
SELECT 
	[intBankTransactionTypeId]		= 15
	,[strBankTransactionTypeName]	= 'Origin Wire'
	,[intConcurrencyId]				= 1			
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeId] = 15)
UNION ALL 
SELECT 
	[intBankTransactionTypeId]		= 16
	,[strBankTransactionTypeName]	= 'AP Payment'
	,[intConcurrencyId]				= 1			
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeId] = 16)
UNION ALL 
SELECT 
	[intBankTransactionTypeId]		= 17
	,[strBankTransactionTypeName]	= 'Bank Stmt Import'
	,[intConcurrencyId]				= 1			
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeId] = 17)
UNION ALL 
SELECT 
	[intBankTransactionTypeId]		= 18
	,[strBankTransactionTypeName]	= 'AR Payment'
	,[intConcurrencyId]				= 1			
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeId] = 18)
UNION ALL 
SELECT 
	[intBankTransactionTypeId]		= 19
	,[strBankTransactionTypeName]	= 'Void Check'
	,[intConcurrencyId]				= 1			
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeId] = 19)
SELECT 
	[intBankTransactionTypeId]		= 20
	,[strBankTransactionTypeName]	= 'AP eCheck'
	,[intConcurrencyId]				= 1			
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeId] = 20)

print('/*******************  END Populate Bank Transaction Types *******************/')