﻿CREATE PROCEDURE [dbo].[uspARForgiveServiceChargeInvoices]
	@InvoiceIds	AS NVARCHAR(MAX)	= NULL,
	@intEntityId AS INT
AS
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

IF ISNULL(@InvoiceIds, '') <> ''
	BEGIN
		DECLARE @ServiceChargeToForgive TABLE (intInvoiceId INT, strInvoiceNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS)

		INSERT INTO @ServiceChargeToForgive
		SELECT SCI.intInvoiceId
			 , SCI.strInvoiceNumber
		FROM dbo.fnGetRowsFromDelimitedValues(@InvoiceIds) DV
		INNER JOIN (
			SELECT intInvoiceId
				 , strInvoiceNumber
			FROM dbo.tblARInvoice WITH (NOLOCK)
			WHERE ysnPosted = 1
			  AND ysnForgiven = 0
			  AND ysnPaid = 0
			  AND strType = 'Service Charge'
		) SCI ON DV.intID = SCI.intInvoiceId

		IF EXISTS(SELECT NULL FROM @ServiceChargeToForgive)
		BEGIN
			UPDATE INV
			SET INV.ysnForgiven = 1
			FROM tblARInvoice INV
			INNER JOIN @ServiceChargeToForgive SCI ON INV.intInvoiceId = SCI.intInvoiceId
			WHERE INV.ysnPosted = 1
			  AND INV.ysnForgiven = 0
			  AND INV.strType = 'Service Charge'

			 --Audit Log

				DECLARE @childData AS NVARCHAR(MAX)
						SET @childData = '{"change": "tblARInvoice","children": [{"action": "Forgive","change": "Forgive - Record: ' + @InvoiceIds + '","iconCls": "small-tree-modified","children": [{"change":"ysnForgive","from":"0","to":"1","leaf":true,"iconCls":"small-gear"}]}]}';
				

				exec uspSMAuditLog 
					@screenName				= 'AccountsReceivable.view.Invoice', 
					@keyValue				= @InvoiceIds,
					@entityId				= @intEntityId,
					@actionType				= 'Updated',
					@actionIcon				= 'small-tree-modified',
					@changeDescription		=  '',
					@fromValue				= '0',
					@toValue				= '1',
					@details				= @childData

			--end of Audit log 

			DECLARE @InvoicesToForgive TABLE (intInvoiceId INT)
			DECLARE @BudgetToForgive TABLE (intBudgetId INT)

			INSERT INTO @InvoicesToForgive
			SELECT ID.intSCInvoiceId
			FROM @ServiceChargeToForgive SCI
			INNER JOIN dbo.tblARInvoiceDetail ID ON SCI.intInvoiceId = ID.intInvoiceId
			WHERE intSCInvoiceId IS NOT NULL

			INSERT INTO @BudgetToForgive
			SELECT ID.intSCBudgetId
			FROM @ServiceChargeToForgive SCI
			INNER JOIN dbo.tblARInvoiceDetail ID ON SCI.intInvoiceId = ID.intInvoiceId
			WHERE ID.intSCBudgetId IS NOT NULL

			IF EXISTS(SELECT NULL FROM @InvoicesToForgive)
				BEGIN
					UPDATE INV
					SET INV.ysnForgiven = 1
					FROM tblARInvoice INV
					INNER JOIN @InvoicesToForgive SCI ON INV.intInvoiceId = SCI.intInvoiceId
					WHERE INV.ysnPosted = 1
				END
			
			IF EXISTS(SELECT NULL FROM @BudgetToForgive)
				BEGIN
					UPDATE CB
					SET CB.ysnForgiven = 1
					FROM tblARCustomerBudget CB
					INNER JOIN @BudgetToForgive SCI ON CB.intCustomerBudgetId = SCI.intBudgetId
				END

			INSERT INTO tblGLDetail (
				   intCompanyId					
				 , dtmDate						
				 , strBatchId					
				 , intAccountId					
				 , dblDebit						
				 , dblCredit					
				 , dblDebitUnit					
				 , dblCreditUnit				
				 , strDescription				
				 , strCode						
				 , strReference					
				 , intCurrencyId				
				 , dblExchangeRate				
				 , dtmDateEntered				
				 , dtmTransactionDate			
				 , strJournalLineDescription	
				 , intJournalLineNo				
				 , ysnIsUnposted				
				 , intUserId					
				 , intEntityId					
				 , strTransactionId				
				 , intTransactionId				
				 , strTransactionType			
				 , strTransactionForm			
				 , strModuleName				
				 , intConcurrencyId				
				 , dblDebitForeign				
				 , dblDebitReport				
				 , dblCreditForeign				
				 , dblCreditReport				
				 , dblReportingRate				
				 , dblForeignRate				
				 , intReconciledId				
				 , dtmReconciled				
				 , ysnReconciled				
				 , ysnRevalued					
			)
			SELECT intCompanyId					= GL.intCompanyId
				 , dtmDate						= GL.dtmDate
				 , strBatchId					= GL.strBatchId
				 , intAccountId					= GL.intAccountId
				 , dblDebit						= GL.dblCredit
				 , dblCredit					= GL.dblDebit
				 , dblDebitUnit					= GL.dblCreditUnit
				 , dblCreditUnit				= GL.dblDebitUnit
				 , strDescription				= 'Forgiven Service Charge: ' + GL.strDescription
				 , strCode						= GL.strCode
				 , strReference					= GL.strReference
				 , intCurrencyId				= GL.intCurrencyId
				 , dblExchangeRate				= GL.dblExchangeRate
				 , dtmDateEntered				= GETDATE()
				 , dtmTransactionDate			= GL.dtmTransactionDate
				 , strJournalLineDescription	= 'Forgiven Service Charge'
				 , intJournalLineNo				= GL.intJournalLineNo
				 , ysnIsUnposted				= 0
				 , intUserId					= GL.intUserId
				 , intEntityId					= GL.intEntityId
				 , strTransactionId				= GL.strTransactionId
				 , intTransactionId				= GL.intTransactionId
				 , strTransactionType			= 'Invoice'
				 , strTransactionForm			= 'Invoice'
				 , strModuleName				= 'Accounts Receivable'
				 , intConcurrencyId				= 1
				 , dblDebitForeign				= GL.dblCreditForeign
				 , dblDebitReport				= GL.dblCreditReport
				 , dblCreditForeign				= GL.dblDebitForeign
				 , dblCreditReport				= GL.dblDebitReport
				 , dblReportingRate				= GL.dblReportingRate
				 , dblForeignRate				= GL.dblForeignRate
				 , intReconciledId				= GL.intReconciledId
				 , dtmReconciled				= GL.dtmReconciled
				 , ysnReconciled				= GL.ysnReconciled
				 , ysnRevalued					= GL.ysnRevalued
			FROM dbo.tblGLDetail GL WITH (NOLOCK)
			INNER JOIN @ServiceChargeToForgive SCI
				ON GL.intTransactionId = SCI.intInvoiceId
				AND GL.strTransactionId = SCI.strInvoiceNumber
			WHERE GL.ysnIsUnposted = 0
		END
	END