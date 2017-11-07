CREATE PROCEDURE [dbo].[uspARForgiveServiceChargeInvoices] 
	@InvoiceIds	AS NVARCHAR(MAX)	= NULL,
	@intEntityId AS INT,
	@isForgive AS BIT = 0
AS
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

IF ISNULL(@InvoiceIds, '') <> ''
	BEGIN
		DECLARE @ServiceChargeToForgive TABLE (intInvoiceId INT, strInvoiceNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS)
		DECLARE @ServiceChargeHasPayments NVARCHAR(MAX)

		INSERT INTO @ServiceChargeToForgive
		SELECT SCI.intInvoiceId
			 , SCI.strInvoiceNumber
		FROM dbo.fnGetRowsFromDelimitedValues(@InvoiceIds) DV
		INNER JOIN (
			SELECT intInvoiceId
				 , strInvoiceNumber
			FROM dbo.tblARInvoice WITH (NOLOCK)
			WHERE ysnPosted = 1
			  AND ysnForgiven = 
				(CASE WHEN @isForgive = 1 THEN 0 ELSE 1 END)
			  AND ysnPaid = 0
			  AND strType = 'Service Charge'
		) SCI ON DV.intID = SCI.intInvoiceId

		IF EXISTS(SELECT NULL FROM @ServiceChargeToForgive)
		BEGIN			
			SELECT @ServiceChargeHasPayments = COALESCE(@ServiceChargeHasPayments + ', ', '') + RTRIM(LTRIM(I.strInvoiceNumber)) 
			FROM @ServiceChargeToForgive I
			INNER JOIN (
				SELECT PD.intPaymentId
					 , PD.intInvoiceId
				FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
				INNER JOIN (
					SELECT intPaymentId
					FROM dbo.tblARPayment WITH (NOLOCK)
				) P ON PD.intPaymentId = P.intPaymentId
			) P ON I.intInvoiceId = P.intInvoiceId

			IF ISNULL(@ServiceChargeHasPayments, '') <> ''
				BEGIN
					SET @ServiceChargeHasPayments = 'These Service Charges Invoice has payments: ' + @ServiceChargeHasPayments
					RAISERROR(@ServiceChargeHasPayments, 16, 1)
					RETURN;
				END

			UPDATE INV
			SET INV.ysnForgiven = CASE WHEN @isForgive = 1 THEN 1 ELSE 0 END
			FROM tblARInvoice INV
			INNER JOIN @ServiceChargeToForgive SCI ON INV.intInvoiceId = SCI.intInvoiceId
			WHERE INV.ysnPosted = 1
			  AND INV.ysnForgiven =  CASE WHEN @isForgive = 1 THEN 0 ELSE 1 END
			  AND INV.strType = 'Service Charge'

			 --Audit Log
				DECLARE @auditAction AS VARCHAR(10);
				DECLARE @valueFrom VARCHAR(10) 
				DECLARE @valueTo VARCHAR(10);

				SELECT @valueFrom = CASE WHEN @isForgive = 1 THEN '0' ELSE '1' END;
				SELECT @valueTo = CASE WHEN @isForgive = 1 THEN '1' ELSE '0' END;

				SET @auditAction = CASE WHEN @isForgive = 1 THEN 'Forgive' ELSE 'Unforgive' END;
				DECLARE @childData AS NVARCHAR(MAX)
						SET @childData = '{"change": "tblARInvoice","children": [{"action": "' + @auditAction + '","change": "'+ @auditAction +' - Record: ' + @InvoiceIds + '","iconCls": "small-tree-modified","children": [{"change":"ysnForgive","from":"'+ @valueFrom +'","to":"'+ @valueTo +'","leaf":true,"iconCls":"small-gear"}]}]}';
				

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
					SET INV.ysnForgiven =  CASE WHEN @isForgive = 1 THEN 1 ELSE 0 END
					FROM tblARInvoice INV
					INNER JOIN @InvoicesToForgive SCI ON INV.intInvoiceId = SCI.intInvoiceId
					WHERE INV.ysnPosted = 1
				END
			
			IF EXISTS(SELECT NULL FROM @BudgetToForgive)
				BEGIN
					UPDATE CB
					SET CB.ysnForgiven = CASE WHEN @isForgive = 1 THEN 1 ELSE 0 END
					FROM tblARCustomerBudget CB
					INNER JOIN @BudgetToForgive SCI ON CB.intCustomerBudgetId = SCI.intBudgetId
				END
			IF(@isForgive = 1)
				BEGIN
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
			ELSE
				BEGIN
					DELETE FROM tblGLDetail 
					WHERE intGLDetailId IN(
						SELECT intGLDetailId FROM dbo.tblGLDetail GL WITH (NOLOCK)
						INNER JOIN @ServiceChargeToForgive SCI
							ON GL.intTransactionId = SCI.intInvoiceId
							AND GL.strTransactionId = SCI.strInvoiceNumber
							AND strJournalLineDescription = 'Forgiven Service Charge'
					WHERE GL.ysnIsUnposted = 0 and strJournalLineDescription = 'Forgiven Service Charge')
				END

		END
	END