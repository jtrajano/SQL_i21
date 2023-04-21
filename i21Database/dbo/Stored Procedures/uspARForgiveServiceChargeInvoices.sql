CREATE PROCEDURE [dbo].[uspARForgiveServiceChargeInvoices] 
	  @strInvoiceIds		AS NVARCHAR(MAX)	= NULL
	, @intEntityId 			AS INT
	, @ysnForgive 			AS BIT 				= 0
	, @ServiceChargeParam 	AS [dbo].[ServiceChargeInvoiceParam] READONLY
AS
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

IF ISNULL(@strInvoiceIds, '') <> ''
	BEGIN
		DECLARE @tblCreditMemoEntries			InvoiceIntegrationStagingTable
		DECLARE @tblInvoiceEntries				InvoiceIntegrationStagingTable
		DECLARE @strServiceChargeHasPayments 	NVARCHAR(MAX)
			  , @strErrorMsg					NVARCHAR(MAX)
			  , @strCreatedCreditMemo			NVARCHAR(MAX)
			  , @strCreatedInvoices				NVARCHAR(MAX)
			  , @dtmDateToday 					DATETIME 
			  , @strBatchId 					VARCHAR(16)
		
		--GET BATCH NUMBER
		EXEC uspSMGetStartingNumber 3, @strBatchId OUTPUT, NULL
		
		IF(OBJECT_ID('tempdb..#SERVICECHARGETOFORGIVE') IS NOT NULL)
		BEGIN
			DROP TABLE #SERVICECHARGETOFORGIVE
		END

		SELECT  @dtmDateToday = DV.dtmToday FROM @ServiceChargeParam DV

		--GET SERVICE CHARGES TO FORGIVE
		SELECT intInvoiceId		= SCI.intInvoiceId
			 , strInvoiceNumber	= SCI.strInvoiceNumber
			 , dtmForgiveDate	= ISNULL(CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), DV.dtmForgiveDate))), @dtmDateToday)
		INTO #SERVICECHARGETOFORGIVE
		FROM @ServiceChargeParam DV
		INNER JOIN (
			SELECT intInvoiceId
				 , strInvoiceNumber
			FROM dbo.tblARInvoice WITH (NOLOCK)
			WHERE ysnPosted = 1
			  AND ysnForgiven = (CASE WHEN @ysnForgive = 1 THEN 0 ELSE 1 END)			  
			  AND strType = 'Service Charge'
		) SCI ON DV.intInvoiceId = SCI.intInvoiceId

		IF EXISTS(SELECT TOP 1 NULL FROM #SERVICECHARGETOFORGIVE)
		BEGIN
			--VALIDATE SERVICE CHARGES IF ALREADY USED IN PAYMENTS
			SELECT @strServiceChargeHasPayments = COALESCE(@strServiceChargeHasPayments + ', ', '') + RTRIM(LTRIM(I.strInvoiceNumber)) 
			FROM #SERVICECHARGETOFORGIVE I
			INNER JOIN (
				SELECT PD.intPaymentId
					 , PD.intInvoiceId
					 , P.strPaymentInfo
				FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
				INNER JOIN (
					SELECT intPaymentId
						 , strPaymentInfo
					FROM dbo.tblARPayment WITH (NOLOCK)
				) P ON PD.intPaymentId = P.intPaymentId
			) P ON I.intInvoiceId = P.intInvoiceId 
			   AND I.strInvoiceNumber <> ISNULL(P.strPaymentInfo, 0)

			IF ISNULL(@strServiceChargeHasPayments, '') <> ''
				BEGIN
					SET @strServiceChargeHasPayments = 'These Service Charges Invoice has payments: ' + @strServiceChargeHasPayments
					RAISERROR(@strServiceChargeHasPayments, 16, 1)
					RETURN;
				END

			--VALIDATE SERVICE CHARGES THAT HAS BEEN UNFORGIVEN ALREADY ONCE
			IF (@ysnForgive = 0)
				BEGIN
					DECLARE @strUnforgivenServiceCharges  NVARCHAR(MAX)

					SELECT @strUnforgivenServiceCharges = I.strInvoiceNumber + ' has been already unforgiven once. Service Charge linked: (' + UNFORGIVEN.strInvoiceNumber + ')'
					FROM #SERVICECHARGETOFORGIVE I
					INNER JOIN tblARInvoice UNFORGIVEN ON UNFORGIVEN.strInvoiceOriginId = I.strInvoiceNumber AND UNFORGIVEN.strType = 'Service Charge'
					WHERE I.dtmForgiveDate <> @dtmDateToday 

					IF ISNULL(@strUnforgivenServiceCharges, '') <> ''
						BEGIN
							RAISERROR(@strUnforgivenServiceCharges, 16, 1)
							RETURN;
						END
				END

			--UPDATE SERVICE CHARGES TO MARK AS FORGIVEN
			UPDATE INV
			SET INV.ysnForgiven 	= @ysnForgive,
				INV.dtmForgiveDate 	= CASE WHEN @ysnForgive = 1 THEN ISNULL(SCI.dtmForgiveDate, @dtmDateToday) ELSE NULL END
			FROM tblARInvoice INV
			INNER JOIN #SERVICECHARGETOFORGIVE SCI ON INV.intInvoiceId = SCI.intInvoiceId
			WHERE INV.ysnPosted = 1
			  AND INV.ysnForgiven = CASE WHEN @ysnForgive = 1 THEN 0 ELSE 1 END			  
			  AND INV.strType = 'Service Charge'
			  AND ((@ysnForgive = 0 AND SCI.dtmForgiveDate = @dtmDateToday) OR @ysnForgive = 1)

			IF (@ysnForgive = 1)
				BEGIN
					--CREATE CREDIT MEMO
					INSERT INTO @tblCreditMemoEntries (
						strTransactionType
						, strType	
						, strSourceTransaction
						, strSourceId
						, intEntityCustomerId
						, intCompanyLocationId
						, intCurrencyId
						, intTermId
						, dtmDate
						, dtmPostDate
						, dtmShipDate
						, intEntitySalespersonId
						, intFreightTermId
						, intShipViaId
						, strInvoiceOriginId
						, strPONumber
						, strBOLNumber
						, strComments
						, strFooterComments	
						, intShipToLocationId
						, intBillToLocationId
						, intEntityId	
						, ysnServiceChargeCredit
						, ysnPost
						, strDocumentNumber
						, strItemDescription
						, dblQtyShipped
						, dblPrice
						, intSalesAccountId
					)
					SELECT strTransactionType		= 'Credit Memo'
						, strType					= 'Standard'
						, strSourceTransaction		= 'Direct'
						, strSourceId				= INV.strInvoiceNumber
						, intEntityCustomerId		= INV.intEntityCustomerId
						, intCompanyLocationId		= INV.intCompanyLocationId
						, intCurrencyId				= INV.intCurrencyId
						, intTermId					= INV.intTermId
						, dtmDate					= ISNULL(SCI.dtmForgiveDate, @dtmDateToday)
						, dtmPostDate				= ISNULL(SCI.dtmForgiveDate, @dtmDateToday)
						, dtmShipDate				= @dtmDateToday
						, intEntitySalespersonId	= INV.intEntitySalespersonId
						, intFreightTermId			= INV.intFreightTermId
						, intShipViaId				= INV.intShipViaId
						, strInvoiceOriginId		= INV.strInvoiceNumber				 
						, strPONumber				= INV.strPONumber
						, strBOLNumber				= INV.strBOLNumber
						, strComments				= INV.strInvoiceNumber + ' Forgiven'
						, strFooterComments			= 'System Generated for prior forgiven Service Charge'
						, intShipToLocationId		= INV.intShipToLocationId
						, intBillToLocationId		= INV.intBillToLocationId
						, intEntityId				= INV.intEntityId
						, ysnServiceChargeCredit	= CAST(1 AS BIT)
						, ysnPost					= CAST(1 AS BIT)
						, strDocumentNumber			= INV.strInvoiceNumber
						, strItemDescription		= INV.strInvoiceNumber + ' Forgiven'
						, dblQtyShipped				= 1
						, dblPrice					= INV.dblInvoiceTotal
						, intSalesAccountId			= ARID.intSalesAccountId				 
					FROM tblARInvoice INV
					INNER JOIN #SERVICECHARGETOFORGIVE SCI ON INV.intInvoiceId = SCI.intInvoiceId
					INNER JOIN tblARInvoiceDetail ARID ON ARID.intInvoiceId = INV.intInvoiceId
					GROUP BY  strTransactionType
						, strType
						, INV.strInvoiceNumber
						, INV.intEntityCustomerId
						, INV.intCompanyLocationId
						, INV.intCurrencyId
						, INV.intTermId
						, ISNULL(SCI.dtmForgiveDate, @dtmDateToday)
						, ISNULL(SCI.dtmForgiveDate, @dtmDateToday)
						, dtmShipDate
						, INV.intEntitySalespersonId
						, INV.intFreightTermId
						, INV.intShipViaId
						, INV.strInvoiceNumber				 
						, INV.strPONumber
						, INV.strBOLNumber
						, INV.strInvoiceNumber + ' Forgiven'
						, strFooterComments
						, INV.intShipToLocationId
						, INV.intBillToLocationId
						, INV.intEntityId
						, ysnServiceChargeCredit
						, INV.strInvoiceNumber
						, INV.strInvoiceNumber + ' Forgiven'
						, dblQtyShipped
						, INV.dblInvoiceTotal
						, ARID.intSalesAccountId

					IF EXISTS (SELECT TOP 1 NULL FROM @tblCreditMemoEntries)
						EXEC dbo.uspARProcessInvoices @InvoiceEntries 	= @tblCreditMemoEntries
													, @UserId			= @intEntityId
													, @GroupingOption	= 0
													, @RaiseError		= 1
													, @ErrorMessage		= @strErrorMsg OUT
													, @CreatedIvoices	= @strCreatedCreditMemo OUT

					IF ISNULL(@strErrorMsg, '') <> ''
						BEGIN
							RAISERROR(@strErrorMsg, 16, 1)
							RETURN;
						END
					ELSE IF ISNULL(@strCreatedCreditMemo, '') <> ''
						BEGIN
							--INSERT CM AND SC TO PAYMENT AND POST
							DECLARE @tblPaymentEntries	PaymentIntegrationStagingTable
								  , @ErrorMessage		NVARCHAR(MAX)
								  , @intPaymentMethodId	INT
								  , @strPaymentMethod	NVARCHAR(100)

							--GET DEFAULT PAYMENT METHOD
							SELECT TOP 1 @intPaymentMethodId 	= intPaymentMethodID
								       , @strPaymentMethod		= strPaymentMethod
							FROM tblSMPaymentMethod 
							WHERE strPaymentMethod = 'Debit Memos and Payments'

							IF ISNULL(@intPaymentMethodId, 0) = 0
								BEGIN
									INSERT INTO tblSMPaymentMethod (
										strPaymentMethod
										, intNumber
										, ysnActive
										, intSort
										, intConcurrencyId
									)
									SELECT strPaymentMethod = 'Debit Memos and Payments'
										, intNumber		 	= 1
										, ysnActive			= 1
										, intSort			= 0
										, intConcurrencyId	= 1

									SELECT TOP 1 @intPaymentMethodId 	= intPaymentMethodID
											   , @strPaymentMethod		= strPaymentMethod
									FROM tblSMPaymentMethod 
									WHERE strPaymentMethod = 'Debit Memos and Payments'
								END

							INSERT INTO @tblPaymentEntries (
								  intId
								, strSourceTransaction
								, intSourceId
								, strSourceId
								, intEntityCustomerId
								, intCompanyLocationId
								, intCurrencyId
								, dtmDatePaid
								, intPaymentMethodId
								, strPaymentMethod
								, strNotes
								, strPaymentInfo
								, intBankAccountId
								, dblAmountPaid
								, intEntityId
								, intInvoiceId
								, strTransactionType
								, strTransactionNumber
								, intTermId
								, intInvoiceAccountId
								, dblInvoiceTotal
								, dblBaseInvoiceTotal
								, dblPayment
								, dblAmountDue
								, dblBaseAmountDue
								, strInvoiceReportNumber
								, intCurrencyExchangeRateTypeId
								, intCurrencyExchangeRateId
								, dblCurrencyExchangeRate
								, ysnPost
							)
							SELECT intId						= CM.intInvoiceId
								, strSourceTransaction			= 'Direct'
								, intSourceId					= CM.intInvoiceId
								, strSourceId					= CM.strInvoiceNumber
								, intEntityCustomerId			= CM.intEntityCustomerId
								, intCompanyLocationId			= CM.intCompanyLocationId
								, intCurrencyId					= CM.intCurrencyId
								, dtmDatePaid					= SCF.dtmForgiveDate
								, intPaymentMethodId			= @intPaymentMethodId
								, strPaymentMethod				= @strPaymentMethod
								, strNotes						= 'Forgiven Service Charge ' + INV.strInvoiceOriginId
								, strPaymentInfo				= INV.strInvoiceOriginId
								, intBankAccountId				= NULL
								, dblAmountPaid					= 0.000000
								, intEntityId					= @intEntityId
								, intInvoiceId					= CM.intInvoiceId
								, strTransactionType			= CM.strTransactionType
								, strTransactionNumber			= CM.strInvoiceNumber
								, intTermId						= CM.intTermId
								, intInvoiceAccountId			= CM.intAccountId
								, dblInvoiceTotal				= CM.dblInvoiceTotal
								, dblBaseInvoiceTotal			= CM.dblBaseInvoiceTotal
								, dblPayment					= CM.dblInvoiceTotal
								, dblAmountDue					= 0.000000
								, dblBaseAmountDue				= 0.000000
								, strInvoiceReportNumber		= CM.strInvoiceNumber
								, intCurrencyExchangeRateTypeId	= CM.intCurrencyExchangeRateTypeId
								, intCurrencyExchangeRateId		= CM.intCurrencyExchangeRateId
								, dblCurrencyExchangeRate		= CM.dblCurrencyExchangeRate
								, ysnPost						= CAST(1 AS BIT)
							FROM dbo.vyuARInvoicesForPayment CM
							INNER JOIN tblARInvoice INV ON CM.intInvoiceId = INV.intInvoiceId
							INNER JOIN dbo.fnGetRowsFromDelimitedValues(@strCreatedCreditMemo) CCM ON CCM.intID = CM.intInvoiceId
							INNER JOIN #SERVICECHARGETOFORGIVE SCF ON SCF.strInvoiceNumber = INV.strInvoiceOriginId

							UNION ALL

							SELECT intId						= SC.intInvoiceId
								, strSourceTransaction			= 'Direct'
								, intSourceId					= SC.intInvoiceId
								, strSourceId					= SC.strInvoiceNumber
								, intEntityCustomerId			= SC.intEntityCustomerId
								, intCompanyLocationId			= SC.intCompanyLocationId
								, intCurrencyId					= SC.intCurrencyId
								, dtmDatePaid					= SCF.dtmForgiveDate
								, intPaymentMethodId			= @intPaymentMethodId
								, strPaymentMethod				= @strPaymentMethod
								, strNotes						= 'Forgiven Service Charge ' + SC.strInvoiceNumber
								, strPaymentInfo				= SC.strInvoiceNumber
								, intBankAccountId				= NULL
								, dblAmountPaid					= 0.000000
								, intEntityId					= @intEntityId
								, intInvoiceId					= SC.intInvoiceId
								, strTransactionType			= SC.strTransactionType
								, strTransactionNumber			= SC.strInvoiceNumber
								, intTermId						= SC.intTermId
								, intInvoiceAccountId			= SC.intAccountId
								, dblInvoiceTotal				= SC.dblInvoiceTotal
								, dblBaseInvoiceTotal			= SC.dblBaseInvoiceTotal
								, dblPayment					= SC.dblInvoiceTotal
								, dblAmountDue					= 0.000000
								, dblBaseAmountDue				= 0.000000
								, strInvoiceReportNumber		= SC.strInvoiceNumber
								, intCurrencyExchangeRateTypeId	= SC.intCurrencyExchangeRateTypeId
								, intCurrencyExchangeRateId		= SC.intCurrencyExchangeRateId
								, dblCurrencyExchangeRate		= SC.dblCurrencyExchangeRate
								, ysnPost						= CAST(1 AS BIT)
							FROM dbo.vyuARInvoicesForPayment SC
							INNER JOIN #SERVICECHARGETOFORGIVE SCF ON SCF.intInvoiceId = SC.intInvoiceId

							EXEC dbo.uspARProcessPayments @PaymentEntries	= @tblPaymentEntries
														, @UserId			= @intEntityId
														, @GroupingOption	= 7
														, @RaiseError		= 1
														, @ErrorMessage		= @ErrorMessage OUTPUT

							IF ISNULL(@ErrorMessage, '') <> ''
								BEGIN
									RAISERROR(@strErrorMsg, 16, 1)
									RETURN;
								END
						END
				END
			ELSE
				BEGIN					
					--GET THE CREDIT MEMO LINKED
					DECLARE @strCreditMemoToUnpost 	NVARCHAR(MAX)
					DECLARE @strPaymentToUnpost		NVARCHAR(MAX)

					IF(OBJECT_ID('tempdb..#CREDITMEMOTODELETE') IS NOT NULL)
					BEGIN
						DROP TABLE #CREDITMEMOTODELETE
					END

					IF(OBJECT_ID('tempdb..#PAYMENTSTODELETE') IS NOT NULL)
					BEGIN
						DROP TABLE #PAYMENTSTODELETE
					END

					SELECT intInvoiceId	= INV.intInvoiceId
					INTO #CREDITMEMOTODELETE
					FROM tblARInvoice INV
					INNER JOIN #SERVICECHARGETOFORGIVE SCI ON INV.strInvoiceOriginId = SCI.strInvoiceNumber
					WHERE INV.strTransactionType = 'Credit Memo'						
					  AND INV.ysnServiceChargeCredit = 1
					  AND CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), INV.dtmPostDate))) = @dtmDateToday

					--UNPOST AND DELETE PAYMENT OF SC AND CM
					SELECT DISTINCT P.intPaymentId
					INTO #PAYMENTSTODELETE
					FROM tblARPayment P
					INNER JOIN tblARPaymentDetail PD ON P.intPaymentId = PD.intPaymentId
					INNER JOIN #CREDITMEMOTODELETE CM ON PD.intInvoiceId = CM.intInvoiceId

					SELECT @strPaymentToUnpost = COALESCE(@strPaymentToUnpost + ', ', '') + RTRIM(LTRIM(P.intPaymentId)) 
					FROM tblARPayment P
					INNER JOIN #PAYMENTSTODELETE PD ON P.intPaymentId = PD.intPaymentId AND P.ysnPosted = 1

					IF ISNULL(@strPaymentToUnpost, '') <> ''
						EXEC dbo.uspARPostPayment @param = @strPaymentToUnpost, @post = 0, @recap = 0, @userId = @intEntityId, @raiseError = 1

					DELETE P
					FROM tblARPayment P
					INNER JOIN #PAYMENTSTODELETE PD ON P.intPaymentId = PD.intPaymentId

					--UNPOST AND DELETE CREDIT MEMO WITHIN TODAYS DATE
					UPDATE INV
					SET ysnServiceChargeCredit = CAST(0 AS BIT)
					FROM tblARInvoice INV
					INNER JOIN #CREDITMEMOTODELETE CM ON INV.intInvoiceId = CM.intInvoiceId 

					SELECT @strCreditMemoToUnpost = COALESCE(@strCreditMemoToUnpost + ', ', '') + RTRIM(LTRIM(INV.intInvoiceId)) 
					FROM tblARInvoice INV
					INNER JOIN #CREDITMEMOTODELETE CM ON INV.intInvoiceId = CM.intInvoiceId AND INV.ysnPosted = 1

					IF ISNULL(@strCreditMemoToUnpost, '') <> ''
						EXEC dbo.uspARPostInvoice @param = @strCreditMemoToUnpost, @post = 0, @recap = 0, @userId = @intEntityId, @raiseError = 1

					DELETE INV 
					FROM tblARInvoice INV
					INNER JOIN #CREDITMEMOTODELETE CM ON INV.intInvoiceId = CM.intInvoiceId

					--CREATE SERVICE CHARGES NOT WITHIN TODAYS DATE
					INSERT INTO @tblInvoiceEntries (
						  strTransactionType
						, strType	
						, strSourceTransaction
						, strSourceId
						, intEntityCustomerId
						, intCompanyLocationId
						, intCurrencyId
						, intTermId
						, dtmDate
						, dtmPostDate
						, dtmShipDate
						, intEntitySalespersonId
						, intFreightTermId
						, intShipViaId
						, strInvoiceOriginId
						, strPONumber
						, strBOLNumber
						, strComments
						, strFooterComments	
						, intShipToLocationId
						, intBillToLocationId
						, intEntityId	
						, ysnPost
						, strDocumentNumber
						, strItemDescription
						, dblQtyShipped
						, dblPrice
					)
					SELECT strTransactionType		= 'Invoice'
						, strType					= 'Service Charge'
						, strSourceTransaction		= 'Direct'
						, strSourceId				= INV.strInvoiceNumber
						, intEntityCustomerId		= INV.intEntityCustomerId
						, intCompanyLocationId		= INV.intCompanyLocationId
						, intCurrencyId				= INV.intCurrencyId
						, intTermId					= INV.intTermId
						, dtmDate					= @dtmDateToday
						, dtmPostDate				= @dtmDateToday
						, dtmShipDate				= @dtmDateToday
						, intEntitySalespersonId	= INV.intEntitySalespersonId
						, intFreightTermId			= INV.intFreightTermId
						, intShipViaId				= INV.intShipViaId
						, strInvoiceOriginId		= INV.strInvoiceNumber				 
						, strPONumber				= INV.strPONumber
						, strBOLNumber				= INV.strBOLNumber
						, strComments				= INV.strInvoiceNumber + ' Unforgiven'
						, strFooterComments			= 'System Generated for prior unforgiven Service Charge'
						, intShipToLocationId		= INV.intShipToLocationId
						, intBillToLocationId		= INV.intBillToLocationId
						, intEntityId				= INV.intEntityId
						, ysnPost					= CAST(1 AS BIT)
						, strDocumentNumber			= INV.strInvoiceNumber
						, strItemDescription		= INV.strInvoiceNumber + ' Unforgiven'
						, dblQtyShipped				= 1
						, dblPrice					= INV.dblInvoiceTotal				 
					FROM tblARInvoice INV
					INNER JOIN #SERVICECHARGETOFORGIVE SCI ON INV.intInvoiceId = SCI.intInvoiceId
					WHERE SCI.dtmForgiveDate <> @dtmDateToday					

					IF EXISTS (SELECT TOP 1 NULL FROM @tblInvoiceEntries)
						EXEC dbo.uspARProcessInvoices @InvoiceEntries 	= @tblInvoiceEntries
													, @UserId			= @intEntityId
													, @GroupingOption	= 0
													, @RaiseError		= 1
													, @ErrorMessage		= @strErrorMsg OUT
													, @CreatedIvoices	= @strCreatedInvoices OUT

					IF ISNULL(@strErrorMsg, '') <> ''
						BEGIN
							RAISERROR(@strErrorMsg, 16, 1)
							RETURN;
						END
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
		END
	END
GO