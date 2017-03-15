CREATE VIEW [dbo].[vyuARPaymentReport]
AS
SELECT [intPaymentId]
          ,[strRecordNumber]
          ,[dtmDatePaid]
           ,[strLocationName]
          ,[strCurrency]
          ,[strPaymentInfo]
          ,[strNotes]
          ,[dblAmountPaid]            = ISNULL([dblAmountPaid],0)
          ,[dblUnappliedAmount]       = ISNULL([dblUnappliedAmount],0)
          ,[strBatchNumber]
          ,[intEntityCustomerId]
          ,[strCustomerNumber]
          ,[strCustomerName]
          ,[strCustomerAddress]        
          ,[dblCustomerARBalance]     = ISNULL([dblARBalance],0) + ISNULL([dblPendingInvoice],0) - ISNULL([dblPendingPayment],0)        
          ,[dblPendingInvoice]        = ISNULL([dblPendingInvoice],0)
          ,[dblPendingPayment]        = ISNULL([dblPendingPayment],0)
          ,[intInvoiceId]
          ,[strInvoiceNumber]
          ,[strInvoiceType]
          ,[ysnIsCredit]
          ,[dblInvoiceTotal]          = ISNULL([dblInvoiceTotal],0)
          ,[dtmDueDate]
          ,[dblInterest]              = ISNULL([dblInterest],0)
          ,[dblDiscount]              = ISNULL([dblDiscount],0)
          ,[dblPayment]               = ISNULL([dblPayment],0)
          ,[strCompanyName]
          ,[strCompanyAddress] 
  FROM  
  (
      SELECT [intPaymentId]
          ,[strRecordNumber]
          ,[dtmDatePaid]
           ,[strLocationName]  
          ,[strCurrency]
          ,[strPaymentInfo]
          ,[strNotes]
          ,[dblAmountPaid]
          ,[dblUnappliedAmount]
          ,[strBatchNumber]
          ,[intEntityCustomerId]
          ,[strCustomerNumber]
          ,[strCustomerName]
          ,[strCustomerAddress]
          ,[dblARBalance]
          ,[dblPendingInvoice]        = (SELECT ISNULL(SUM(CASE WHEN strTransactionType NOT IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(dblInvoiceTotal,0) * -1 ELSE ISNULL(dblInvoiceTotal,0) END), 0) FROM tblARInvoice WHERE intEntityCustomerId = A.intEntityCustomerId AND ysnPosted = 0 AND ((strType = 'Service Charge' AND ysnForgiven = 0) OR ((strType <> 'Service Charge' AND ysnForgiven = 1) OR (strType <> 'Service Charge' AND ysnForgiven = 0))))
          ,[dblPendingPayment]
          ,[intInvoiceId]
          ,[strInvoiceNumber]
          ,[strInvoiceType]
          ,[ysnIsCredit]
          ,[dblInvoiceTotal]
          ,[dtmDueDate]
          ,[dblInterest]
          ,[dblDiscount]
          ,[dblPayment]
          ,[strCompanyName]
          ,[strCompanyAddress]
      FROM 
       (
  
          SELECT
               [intPaymentId]            = ARP.[intPaymentId]
              ,[strRecordNumber]        = ARP.[strRecordNumber]
              ,[dtmDatePaid]            = ARP.[dtmDatePaid]
              ,[strLocationName]        = SMCL.[strLocationName]
              ,[strCurrency]            = SMC.[strCurrency]
              ,[strPaymentInfo]        = ARP.[strPaymentInfo]
              ,[strNotes]                = ARP.[strNotes]
              ,[dblAmountPaid]        = ARP.[dblAmountPaid]
              ,[dblUnappliedAmount]    = ARP.[dblUnappliedAmount]
              ,[strBatchNumber]        = GLB.[strBatchId]
              ,[intEntityCustomerId]    = ARP.[intEntityCustomerId]
              ,[strCustomerNumber]    = ARC.[strCustomerNumber]
              ,[strCustomerName]        = EME.[strName]
              ,[strCustomerAddress]    = CASE WHEN ISNULL(EMEL1.[intEntityLocationId],0) <> 0
                                              THEN [dbo].fnARFormatCustomerAddress(NULL, NULL, EMEL1.[strLocationName], EMEL1.[strAddress], EMEL1.[strCity], EMEL1.[strState], EMEL1.[strZipCode], EMEL1.[strCountry], EME.[strName], ARC.[ysnIncludeEntityName])
                                          WHEN ISNULL(EMEL.[intEntityLocationId],0) <> 0
                                              THEN [dbo].fnARFormatCustomerAddress(NULL, NULL, EMEL.[strLocationName], EMEL.[strAddress], EMEL.[strCity], EMEL.[strState], EMEL.[strZipCode], EMEL.[strCountry], EME.[strName], ARC.[ysnIncludeEntityName])
                                        ELSE 
                                          ''
                                        END
              ,[dblARBalance]            = ARC.[dblARBalance]
              ,[dblPendingPayment]    = ISNULL((SELECT SUM(ISNULL(tblARPayment.[dblAmountPaid], 0.00)) FROM tblARPayment WHERE tblARPayment.[intEntityCustomerId] = ARP.[intEntityCustomerId] AND tblARPayment.[ysnPosted] = 0), 0.00)
              ,[intInvoiceId]            = ARI.[intInvoiceId]
              ,[strInvoiceNumber]        = ARI.[strInvoiceNumber]
              ,[strInvoiceType]        = ARI.[strTransactionType]
              ,[ysnIsCredit]            = CASE WHEN ARI.[strTransactionType] IN ('Credit Memo', 'Cash Refund', 'Overpayment', 'Customer Prepayment') THEN 1 ELSE 0 END
              ,[dblInvoiceTotal]        = ISNULL(ARI.[dblInvoiceTotal], 0.00) * (CASE WHEN ARI.[strTransactionType] IN ('Credit Memo', 'Cash Refund', 'Overpayment', 'Customer Prepayment') THEN -1 ELSE 1 END)
              ,[dtmDueDate]            = ARI.[dtmDueDate]
              ,[dblInterest]            = ISNULL(ARPD.[dblInterest], 0.00)
              ,[dblDiscount]            = ISNULL(ARPD.[dblDiscount], 0.00)
              ,[dblPayment]            = ISNULL(ARPD.[dblPayment], 0.00)
              ,[strCompanyName]        = CASE WHEN SMCL.[strUseLocationAddress] = 'Letterhead'
                                          THEN ''
                                        ELSE
                                          (SELECT TOP 1 [strCompanyName] FROM tblSMCompanySetup)
                                        END
              ,[strCompanyAddress]    = CASE WHEN SMCL.[strUseLocationAddress] IS NULL OR SMCL.[strUseLocationAddress] IN ('','No','Always')
                                              THEN (SELECT TOP 1 [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, [strAddress], [strCity], [strState], [strZip], [strCountry], NULL, ARC.[ysnIncludeEntityName]) FROM tblSMCompanySetup)
                                          WHEN SMCL.strUseLocationAddress = 'Yes'
                                              THEN [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, SMCL.[strAddress], SMCL.[strCity], SMCL.[strStateProvince], SMCL.[strZipPostalCode], SMCL.[strCountry], NULL, ARC.[ysnIncludeEntityName])
                                          WHEN SMCL.[strUseLocationAddress] = 'Letterhead'
                                              THEN ''
                                        END
          FROM
              tblARPayment ARP
          INNER JOIN
              tblARCustomer ARC
                  ON ARP.[intEntityCustomerId] = ARC.[intEntityCustomerId]
          INNER JOIN
              tblEMEntity EME
                  ON ARC.[intEntityCustomerId] = EME.[intEntityId]
          LEFT OUTER JOIN
              (
              SELECT
                   [intEntityLocationId]
                  ,[strLocationName]
                  ,[strAddress]
                  ,[intEntityId]
                  ,[strCountry]
                  ,[strState]
                  ,[strCity]
                  ,[strZipCode]
                  ,[intTermsId]
                  ,[intShipViaId]
              FROM
                  [tblEMEntityLocation]
              WHERE
                  ysnDefaultLocation = 1
              ) EMEL
              ON ARC.[intEntityCustomerId] = EMEL.[intEntityId]
          LEFT OUTER JOIN
              [tblEMEntityLocation] EMEL1
                  ON ARC.[intBillToId] = EME.[intEntityId]
          INNER JOIN
              tblSMCompanyLocation SMCL
                  ON ARP.[intLocationId] = SMCL.[intCompanyLocationId]
          LEFT OUTER JOIN
              tblSMCurrency SMC
                  ON ARP.[intCurrencyId] = SMC.[intCurrencyID]
          LEFT OUTER JOIN
              (
              SELECT --TOP 1
                   GLD.[intTransactionId]
                  ,GLD.[strTransactionId]
                  ,GLD.[intAccountId]
                  ,GLD.[strBatchId]
              FROM
                  tblGLDetail GLD
              WHERE
                      GLD.[strTransactionType] IN ('Receive Payments')
                  AND GLD.[ysnIsUnposted] = 0
                  AND GLD.[strCode] = 'AR'
              ) GLB
                  ON ARP.intPaymentId = GLB.intTransactionId
                  AND ARP.intAccountId = GLB.intAccountId
                  AND ARP.strRecordNumber = GLB.strTransactionId
          LEFT OUTER JOIN
              tblARPaymentDetail ARPD
                  ON ARP.[intPaymentId] = ARPD.[intPaymentId]
          INNER JOIN
              tblARInvoice ARI
                  ON ARPD.[intInvoiceId] = ARI.[intInvoiceId]
          WHERE
              ISNULL(ARPD.[dblPayment], 0.00) <> 0
      
          UNION ALL
   
          SELECT
               [intPaymentId]            = ARP.[intPaymentId]
              ,[strRecordNumber]        = ARP.[strRecordNumber]
              ,[dtmDatePaid]            = ARP.[dtmDatePaid]
              ,[strLocationName]        = SMCL.[strLocationName]
              ,[strCurrency]            = SMC.[strCurrency]
              ,[strPaymentInfo]        = ARP.[strPaymentInfo]
              ,[strNotes]                = ARP.[strNotes]
              ,[dblAmountPaid]        = ARP.[dblAmountPaid]
              ,[dblUnappliedAmount]    = ARP.[dblUnappliedAmount]
              ,[strBatchNumber]        = GLB.[strBatchId]
              ,[intEntityCustomerId]    = ARP.[intEntityCustomerId]
              ,[strCustomerNumber]    = ARC.[strCustomerNumber]
              ,[strCustomerName]        = EME.[strName]
              ,[strCustomerAddress]    = CASE WHEN ISNULL(EMEL1.[intEntityLocationId],0) <> 0
                                              THEN [dbo].fnARFormatCustomerAddress(NULL, NULL, EMEL1.[strLocationName], EMEL1.[strAddress], EMEL1.[strCity], EMEL1.[strState], EMEL1.[strZipCode], EMEL1.[strCountry], EME.[strName], ARC.[ysnIncludeEntityName])
                                          WHEN ISNULL(EMEL.[intEntityLocationId],0) <> 0
                                              THEN [dbo].fnARFormatCustomerAddress(NULL, NULL, EMEL.[strLocationName], EMEL.[strAddress], EMEL.[strCity], EMEL.[strState], EMEL.[strZipCode], EMEL.[strCountry], EME.[strName], ARC.[ysnIncludeEntityName])
                                        ELSE
                                          ''
                                        END
              ,[dblARBalance]    = ARC.[dblARBalance]
              ,[dblPendingPayment]    = ISNULL((SELECT SUM(ISNULL(tblARPayment.[dblAmountPaid], 0.00)) FROM tblARPayment WHERE tblARPayment.[intEntityCustomerId] = ARP.[intEntityCustomerId] AND tblARPayment.[ysnPosted] = 0), 0.00)
              ,[intInvoiceId]            = ARI.[intInvoiceId]
              ,[strInvoiceNumber]        = ARI.[strInvoiceNumber]
              ,[strInvoiceType]        = ARI.[strTransactionType]
              ,[ysnIsCredit]            = CASE WHEN ARI.[strTransactionType] IN ('Credit Memo', 'Cash Refund', 'Overpayment', 'Customer Prepayment') THEN 1 ELSE 0 END
              ,[dblInvoiceTotal]        = ISNULL(ARI.[dblInvoiceTotal], 0.00)
              ,[dtmDueDate]            = ARI.[dtmDueDate]
              ,[dblInterest]            = ISNULL(ARI.[dblInterest], 0.00)
              ,[dblDiscount]            = ISNULL(ARI.[dblDiscount], 0.00)
              ,[dblPayment]            = ISNULL(ARI.[dblInvoiceTotal], 0.00)
              ,[strCompanyName]        = CASE WHEN SMCL.[strUseLocationAddress] = 'Letterhead'
                                          THEN ''
                                        ELSE
                                          (SELECT TOP 1 [strCompanyName] FROM tblSMCompanySetup)
                                        END
              ,[strCompanyAddress]    = CASE WHEN SMCL.[strUseLocationAddress] IS NULL OR SMCL.[strUseLocationAddress] IN ('','No','Always')
                                              THEN (SELECT TOP 1 [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, [strAddress], [strCity], [strState], [strZip], [strCountry], NULL, ARC.[ysnIncludeEntityName]) FROM tblSMCompanySetup)
                                          WHEN SMCL.strUseLocationAddress = 'Yes'
                                              THEN [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, SMCL.[strAddress], SMCL.[strCity], SMCL.[strStateProvince], SMCL.[strZipPostalCode], SMCL.[strCountry], NULL, ARC.[ysnIncludeEntityName])
                                          WHEN SMCL.[strUseLocationAddress] = 'Letterhead'
                                              THEN ''
                                        END
          FROM
              tblARPayment ARP
          INNER JOIN
              tblARCustomer ARC
                  ON ARP.[intEntityCustomerId] = ARC.[intEntityCustomerId]
          INNER JOIN
              tblEMEntity EME
                  ON ARC.[intEntityCustomerId] = EME.[intEntityId]
          LEFT OUTER JOIN
              (
              SELECT
                   [intEntityLocationId]
                  ,[strLocationName]
                  ,[strAddress]
                  ,[intEntityId]
                  ,[strCountry]
                  ,[strState]
                  ,[strCity]
                  ,[strZipCode]
                  ,[intTermsId]
                  ,[intShipViaId]
              FROM
                  [tblEMEntityLocation]
              WHERE
                  ysnDefaultLocation = 1
              ) EMEL
              ON ARC.[intEntityCustomerId] = EMEL.[intEntityId]
          LEFT OUTER JOIN
              [tblEMEntityLocation] EMEL1
                  ON ARC.[intBillToId] = EME.[intEntityId]
          INNER JOIN
              tblSMCompanyLocation SMCL
                  ON ARP.[intLocationId] = SMCL.[intCompanyLocationId]
          LEFT OUTER JOIN
              tblSMCurrency SMC
                  ON ARP.[intCurrencyId] = SMC.[intCurrencyID]
          LEFT OUTER JOIN
              (
              SELECT --TOP 1
                   GLD.[intTransactionId]
                  ,GLD.[strTransactionId]
                  ,GLD.[intAccountId]
                  ,GLD.[strBatchId]
              FROM
                  tblGLDetail GLD
              WHERE
                      GLD.[strTransactionType] IN ('Receive Payments')
                  AND GLD.[ysnIsUnposted] = 0
                  AND GLD.[strCode] = 'AR'
              ) GLB
                  ON ARP.intPaymentId = GLB.intTransactionId
                  AND ARP.intAccountId = GLB.intAccountId
                  AND ARP.strRecordNumber = GLB.strTransactionId
          INNER JOIN
              tblARInvoice ARI
                  ON ARP.[intPaymentId] = ARI.[intPaymentId]
                  AND ARI.[ysnPosted] = 1    
      ) A
  ) B

GO