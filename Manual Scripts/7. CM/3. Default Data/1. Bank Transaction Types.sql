-- --------------------------------------------------
-- Script for SQL Server 2005, 2008, and Azure
-- Purpose: Insert fresh data for the transaction types. 
-- This table holds the prefix and number for the bank 
-- transaction ids. 
--
-- WARNING! This script resets the data in the table.
-- You may lose data and reset the transaction numbers
-- for all the Cash Management transactions
-- --------------------------------------------------
-- Date Created: 10/09/2013 5:32 PM
-- Created by: Feb Montefrio
-- --------------------------------------------------

TRUNCATE TABLE dbo.[tblCMBankTransactionType]

-- SET IDENTITY_INSERT to ON.
-- SET IDENTITY_INSERT dbo.[tblCMBankTransactionType] ON

INSERT INTO dbo.[tblCMBankTransactionType] (
	[intBankTransactionTypeID]
	,[strBankTransactionTypeName]
	,[strTransactionPrefix]
	,[intTransactionNo]
	,[intConcurrencyID]
)
SELECT 
	[intBankTransactionTypeID]		= 1
	,[strBankTransactionTypeName]	= 'Bank Deposit'
	,[strTransactionPrefix]			= 'BDEP'
	,[intTransactionNo]				= 1
	,[intConcurrencyID]				= 1
UNION ALL 
SELECT 
	[intBankTransactionTypeID]		= 2
	,[strBankTransactionTypeName]	= 'Bank Withdrawal'
	,[strTransactionPrefix]			= 'BWD'
	,[intTransactionNo]				= 1
	,[intConcurrencyID]				= 1
UNION ALL 
SELECT 
	[intBankTransactionTypeID]		= 3
	,[strBankTransactionTypeName]	= 'Misc Checks'
	,[strTransactionPrefix]			= 'MCHK'
	,[intTransactionNo]				= 1
	,[intConcurrencyID]				= 1
UNION ALL 
SELECT 
	[intBankTransactionTypeID]		= 4
	,[strBankTransactionTypeName]	= 'Bank Transfer'
	,[strTransactionPrefix]			= 'BTFR'
	,[intTransactionNo]				= 1
	,[intConcurrencyID]				= 1
UNION ALL 
SELECT 
	[intBankTransactionTypeID]		= 5
	,[strBankTransactionTypeName]	= 'Bank Transaction'
	,[strTransactionPrefix]			= 'BTRN'
	,[intTransactionNo]				= 1
	,[intConcurrencyID]				= 1
UNION ALL 
SELECT 
	[intBankTransactionTypeID]		= 6
	,[strBankTransactionTypeName]	= 'Credit Card Charge'
	,[strTransactionPrefix]			= 'CCHG'
	,[intTransactionNo]				= 1
	,[intConcurrencyID]				= 1
UNION ALL 
SELECT 
	[intBankTransactionTypeID]		= 7
	,[strBankTransactionTypeName]	= 'Credit Card Returns'
	,[strTransactionPrefix]			= 'CRTN'
	,[intTransactionNo]				= 1
	,[intConcurrencyID]				= 1
UNION ALL 
SELECT 
	[intBankTransactionTypeID]		= 8
	,[strBankTransactionTypeName]	= 'Credit Card Payments'
	,[strTransactionPrefix]			= 'CPMT'
	,[intTransactionNo]				= 1
	,[intConcurrencyID]				= 1
UNION ALL 
SELECT 
	[intBankTransactionTypeID]		= 9
	,[strBankTransactionTypeName]	= 'Bank Transfer (WD)'
	,[strTransactionPrefix]			= ''
	,[intTransactionNo]				= 1
	,[intConcurrencyID]				= 1
UNION ALL 
SELECT 
	[intBankTransactionTypeID]		= 10
	,[strBankTransactionTypeName]	= 'Bank Transfer (DEP)'
	,[strTransactionPrefix]			= ''
	,[intTransactionNo]				= 1
	,[intConcurrencyID]				= 1