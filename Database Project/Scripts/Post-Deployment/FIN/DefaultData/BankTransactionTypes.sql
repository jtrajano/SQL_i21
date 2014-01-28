-- --------------------------------------------------
-- Script for SQL Server 2005, 2008, and Azure
-- Purpose: Insert fresh data for the transaction types. 
-- This table holds the prefix and number for the bank 
-- transaction ids. 
-- --------------------------------------------------
-- Date Created: 10/09/2013 5:32 PM
-- Created by: Feb Montefrio
-- --------------------------------------------------

INSERT INTO dbo.[tblCMBankTransactionType] (
	[intBankTransactionTypeID]
	,[strBankTransactionTypeName]
	,[intConcurrencyId]
)
SELECT 
	[intBankTransactionTypeID]		= 1
	,[strBankTransactionTypeName]	= 'Bank Deposit'
	,[intConcurrencyId]				= 1
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeID] = 1)
	
UNION ALL 
SELECT 
	[intBankTransactionTypeID]		= 2
	,[strBankTransactionTypeName]	= 'Bank Withdrawal'
	,[intConcurrencyId]				= 1
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeID] = 2)
	
UNION ALL 
SELECT 
	[intBankTransactionTypeID]		= 3
	,[strBankTransactionTypeName]	= 'Misc Checks'
	,[intConcurrencyId]				= 1
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeID] = 3)
	
UNION ALL 
SELECT 
	[intBankTransactionTypeID]		= 4
	,[strBankTransactionTypeName]	= 'Bank Transfer'
	,[intConcurrencyId]				= 1
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeID] = 4)

UNION ALL 
SELECT 
	[intBankTransactionTypeID]		= 5
	,[strBankTransactionTypeName]	= 'Bank Transaction'
	,[intConcurrencyId]				= 1
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeID] = 5)
	
UNION ALL 
SELECT 
	[intBankTransactionTypeID]		= 6
	,[strBankTransactionTypeName]	= 'Credit Card Charge'
	,[intConcurrencyId]				= 1
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeID] = 6)
	
UNION ALL 
SELECT 
	[intBankTransactionTypeID]		= 7
	,[strBankTransactionTypeName]	= 'Credit Card Returns'
	,[intConcurrencyId]				= 1
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeID] = 7)
	
UNION ALL 
SELECT 
	[intBankTransactionTypeID]		= 8
	,[strBankTransactionTypeName]	= 'Credit Card Payments'
	,[intConcurrencyId]				= 1
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeID] = 8)	
	
UNION ALL 
SELECT 
	[intBankTransactionTypeID]		= 9
	,[strBankTransactionTypeName]	= 'Bank Transfer (WD)'
	,[intConcurrencyId]				= 1
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeID] = 9)	
	
UNION ALL 
SELECT 
	[intBankTransactionTypeID]		= 10
	,[strBankTransactionTypeName]	= 'Bank Transfer (DEP)'
	,[intConcurrencyId]				= 1
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeID] = 10)		
	
UNION ALL 
SELECT 
	[intBankTransactionTypeID]		= 11
	,[strBankTransactionTypeName]	= 'Origin Deposit'
	,[intConcurrencyId]				= 1	
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeID] = 11)	
	
UNION ALL 
SELECT 
	[intBankTransactionTypeID]		= 12
	,[strBankTransactionTypeName]	= 'Origin Checks'
	,[intConcurrencyId]				= 1	
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeID] = 12)	
UNION ALL 
SELECT 
	[intBankTransactionTypeID]		= 13
	,[strBankTransactionTypeName]	= 'Origin EFT'
	,[intConcurrencyId]				= 1			
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeID] = 13)
UNION ALL 
SELECT 
	[intBankTransactionTypeID]		= 14
	,[strBankTransactionTypeName]	= 'Origin Withdrawal'
	,[intConcurrencyId]				= 1			
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeID] = 14)
UNION ALL 
SELECT 
	[intBankTransactionTypeID]		= 15
	,[strBankTransactionTypeName]	= 'Origin Wire'
	,[intConcurrencyId]				= 1			
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeID] = 15)
UNION ALL 
SELECT 
	[intBankTransactionTypeID]		= 16
	,[strBankTransactionTypeName]	= 'AP Payment'
	,[intConcurrencyId]				= 1			
WHERE NOT EXISTS (SELECT TOP 1 1 FROM dbo.[tblCMBankTransactionType] WHERE [intBankTransactionTypeID] = 16)