﻿CREATE PROCEDURE [dbo].[uspARForgiveServiceChargeInvoices] 
	@InvoiceIds	AS NVARCHAR(MAX)	= NULL,
	@intEntityId AS INT,
	@ysnForgive AS BIT = 0,
	@ServiceChargeParam AS [dbo].[ServiceChargeInvoiceParam] READONLY
AS
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

IF ISNULL(@InvoiceIds, '') <> ''
	BEGIN
		DECLARE @ServiceChargeToForgive TABLE (intInvoiceId INT, strInvoiceNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS, dtmForgiveDate DATETIME NULL)
		DECLARE @ServiceChargeHasPayments NVARCHAR(MAX)

		INSERT INTO @ServiceChargeToForgive
		SELECT SCI.intInvoiceId
			 , SCI.strInvoiceNumber
			 , DV.dtmForgiveDate
		FROM @ServiceChargeParam DV
		INNER JOIN (
			SELECT intInvoiceId
				 , strInvoiceNumber
			FROM dbo.tblARInvoice WITH (NOLOCK)
			WHERE ysnPosted = 1
			  AND ysnForgiven = (CASE WHEN @ysnForgive = 1 THEN 0 ELSE 1 END)
			  AND ysnPaid = 0
			  AND strType = 'Service Charge'
		) SCI ON DV.intInvoiceId = SCI.intInvoiceId

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
			SET INV.ysnForgiven = @ysnForgive,
				INV.dtmForgiveDate =  CASE WHEN @ysnForgive = 1 THEN ISNULL(SCI.dtmForgiveDate, GETDATE()) ELSE NULL END
			FROM tblARInvoice INV
			INNER JOIN @ServiceChargeToForgive SCI ON INV.intInvoiceId = SCI.intInvoiceId
			WHERE INV.ysnPosted = 1
			  AND INV.ysnForgiven = CASE WHEN @ysnForgive = 1 THEN 0 ELSE 1 END
			  AND INV.strType = 'Service Charge'

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
					SET INV.ysnForgiven = @ysnForgive
					FROM tblARInvoice INV
					INNER JOIN @InvoicesToForgive SCI ON INV.intInvoiceId = SCI.intInvoiceId
					WHERE INV.ysnPosted = 1
				END
			
			IF EXISTS(SELECT NULL FROM @BudgetToForgive)
				BEGIN
					UPDATE CB
					SET CB.ysnForgiven = @ysnForgive
					FROM tblARCustomerBudget CB
					INNER JOIN @BudgetToForgive SCI ON CB.intCustomerBudgetId = SCI.intBudgetId
				END

			/****************** AUDIT LOG ******************/
			BEGIN TRANSACTION [AUDITLOG]
			BEGIN 
				DECLARE @auditAction AS VARCHAR(10);
				DECLARE @valueFrom VARCHAR(10) 
				DECLARE @valueTo VARCHAR(10);
				DECLARE @a VARCHAR(10);
				DECLARE @childData AS NVARCHAR(MAX);
				DECLARE @intInvoiceId as INT;
				DECLARE @fromDtmForgiveDate AS DATETIME;
				DECLARE @toDtmForgiveDate as DATETIME;
				DECLARE @invoiceNo AS VARCHAR(10);
				SELECT @valueFrom = CASE WHEN @ysnForgive = 1 THEN '0' ELSE '1' END;
				SELECT @valueTo = CASE WHEN @ysnForgive = 1 THEN '1' ELSE '0' END;


				SET @auditAction = CASE WHEN @ysnForgive = 1 THEN 'Forgive' ELSE 'Unforgive' END;	 
				DECLARE @ServiceChargeAuditLogCursor as CURSOR;
 
				SET @ServiceChargeAuditLogCursor = CURSOR FOR
				SELECT C.intInvoiceId, C.dtmForgiveDate as [TO], T.dtmForgiveDate as [FROM], T.strInvoiceNumber FROM @ServiceChargeParam C INNER JOIN tblARInvoice T ON C.intInvoiceId = T.intInvoiceId; 
				OPEN @ServiceChargeAuditLogCursor;
				FETCH NEXT FROM @ServiceChargeAuditLogCursor INTO @intInvoiceId, @fromDtmForgiveDate,@toDtmForgiveDate, @invoiceNo; 
				WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @childData = '{"change": "tblARInvoice","children": [{"action": "' + @auditAction + '","change": "'+ @auditAction +' - Invoice No: ' + CAST(@invoiceNo as VARCHAR(MAX)) + '","iconCls": "small-tree-modified","children": [{"change":"ysnForgive","from":"'+ @valueFrom +'","to":"'+ @valueTo +'","leaf":true,"iconCls":"small-gear"},{"change":"dtmForgiveDate","from":"'+   CASE WHEN @ysnForgive = 1 THEN '' ELSE ISNULL(CAST(@fromDtmForgiveDate AS VARCHAR(20)),'') END  +'","to":"'+ CASE WHEN @ysnForgive = 1 THEN ISNULL(CAST(@toDtmForgiveDate AS VARCHAR(20)),'') ELSE '' END +'","leaf":true,"iconCls":"small-gear"}]}]}';
					DECLARE @strInvoiceId VARCHAR(MAX) = CAST(@intInvoiceId as VARCHAR(MAX))
					EXEC uspSMAuditLog @screenName = 'AccountsReceivable.view.Invoice', @keyValue = @strInvoiceId, @entityId = @intEntityId, @actionType = 'Updated', @actionIcon = 'small-tree-modified', @changeDescription =  '', @fromValue = '0', @toValue = '1', @details = @childData
				 FETCH NEXT FROM @ServiceChargeAuditLogCursor INTO @intInvoiceId, @fromDtmForgiveDate,@toDtmForgiveDate, @invoiceNo;
				END
 
				CLOSE @ServiceChargeAuditLogCursor;
				DEALLOCATE @ServiceChargeAuditLogCursor;
			COMMIT TRANSACTION [AUDITLOG]
			END
			/****************** AUDIT LOG ******************/

			IF(@ysnForgive = 1)
				BEGIN
					DELETE FROM tblGLDetail 
					WHERE intGLDetailId IN(
						SELECT intGLDetailId FROM dbo.tblGLDetail GL WITH (NOLOCK)
						INNER JOIN @ServiceChargeToForgive SCI
							ON GL.intTransactionId = SCI.intInvoiceId
							AND GL.strTransactionId = SCI.strInvoiceNumber
							AND strJournalLineDescription = 'Unforgive Service Charge'
					WHERE GL.ysnIsUnposted = 0 AND strJournalLineDescription = 'Unforgive Service Charge')


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
						, dblCredit						= GL.dblDebit
						, dblDebitUnit					= GL.dblCreditUnit
						, dblCreditUnit					= GL.dblDebitUnit
						, strDescription				= 'Forgiven Service Charge: ' + GL.strDescription
						, strCode						= GL.strCode
						, strReference					= GL.strReference
						, intCurrencyId					= GL.intCurrencyId
						, dblExchangeRate				= GL.dblExchangeRate
						, dtmDateEntered				= GETDATE()
						, dtmTransactionDate			= GL.dtmTransactionDate
						, strJournalLineDescription		= 'Forgiven Service Charge'
						, intJournalLineNo				= GL.intJournalLineNo
						, ysnIsUnposted					= 0
						, intUserId						= GL.intUserId
						, intEntityId					= GL.intEntityId
						, strTransactionId				= GL.strTransactionId
						, intTransactionId				= GL.intTransactionId
						, strTransactionType			= 'Invoice'
						, strTransactionForm			= 'Invoice'
						, strModuleName					= 'Accounts Receivable'
						, intConcurrencyId				= 1
						, dblDebitForeign				= GL.dblCreditForeign
						, dblDebitReport				= GL.dblCreditReport
						, dblCreditForeign				= GL.dblDebitForeign
						, dblCreditReport				= GL.dblDebitReport
						, dblReportingRate				= GL.dblReportingRate
						, dblForeignRate				= GL.dblForeignRate
						, intReconciledId				= GL.intReconciledId
						, dtmReconciled					= GL.dtmReconciled
						, ysnReconciled					= GL.ysnReconciled
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
					WHERE GL.ysnIsUnposted = 0 AND strJournalLineDescription = 'Forgiven Service Charge')

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
						, dblDebit						= GL.dblDebit
						, dblCredit						= GL.dblCredit
						, dblDebitUnit					= GL.dblDebitUnit
						, dblCreditUnit					= GL.dblCreditUnit
						, strDescription				= 'Unforgive Service Charge: ' + GL.strDescription
						, strCode						= GL.strCode
						, strReference					= GL.strReference
						, intCurrencyId					= GL.intCurrencyId
						, dblExchangeRate				= GL.dblExchangeRate
						, dtmDateEntered				= GETDATE()
						, dtmTransactionDate			= GL.dtmTransactionDate
						, strJournalLineDescription		= 'Unforgive Service Charge'
						, intJournalLineNo				= GL.intJournalLineNo
						, ysnIsUnposted					= 0
						, intUserId						= GL.intUserId
						, intEntityId					= GL.intEntityId
						, strTransactionId				= GL.strTransactionId
						, intTransactionId				= GL.intTransactionId
						, strTransactionType			= 'Invoice'
						, strTransactionForm			= 'Invoice'
						, strModuleName					= 'Accounts Receivable'
						, intConcurrencyId				= 1
						, dblDebitForeign				= GL.dblDebitForeign
						, dblDebitReport				= GL.dblDebitReport
						, dblCreditForeign				= GL.dblCreditForeign
						, dblCreditReport				= GL.dblCreditReport
						, dblReportingRate				= GL.dblReportingRate
						, dblForeignRate				= GL.dblForeignRate
						, intReconciledId				= GL.intReconciledId
						, dtmReconciled					= GL.dtmReconciled
						, ysnReconciled					= GL.ysnReconciled
						, ysnRevalued					= GL.ysnRevalued
					FROM dbo.tblGLDetail GL WITH (NOLOCK)
					INNER JOIN @ServiceChargeToForgive SCI
						ON GL.intTransactionId = SCI.intInvoiceId
						AND GL.strTransactionId = SCI.strInvoiceNumber
					WHERE GL.ysnIsUnposted = 0
					  AND ISNULL(GL.strJournalLineDescription, '') <> 'Forgiven Service Charge'
				END

		END
	END