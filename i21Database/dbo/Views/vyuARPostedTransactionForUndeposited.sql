CREATE VIEW vyuARPostedTransactionForUndeposited            
AS            
SELECT         
'Receipts' strType,        
strRecordNumber, dtmDatePaid dtmDate,            
dblAmount    = CASE WHEN (ISNULL(PAYMENT.dblAmountPaid, 0) < 0 AND SMPM.strPaymentMethod IN ('Prepay')) THEN PAYMENT.dblAmountPaid *-1 ELSE PAYMENT.dblAmountPaid END            
,PAYMENT.intAccountId      
,PAYMENT.ysnPosted          
FROM tblARPayment PAYMENT            
LEFT OUTER JOIN tblSMPaymentMethod SMPM ON PAYMENT.intPaymentMethodId = SMPM.intPaymentMethodID            
WHERE -- PAYMENT.ysnPosted = 1       AND         
   PAYMENT.ysnProcessedToNSF = 0            
   AND PAYMENT.intAccountId IS NOT NULL            
   AND (PAYMENT.ysnImportedFromOrigin <> 1 AND PAYMENT.ysnImportedAsPosted <> 1)            
   AND UPPER(ISNULL(SMPM.strPaymentMethod,'')) not in ('WRITE OFF', 'CF Invoice')            
   AND (ISNULL(PAYMENT.dblAmountPaid, 0) > 0 OR (ISNULL(PAYMENT.dblAmountPaid, 0) < 0 AND SMPM.strPaymentMethod IN ('ACH','Prepay', 'Cash', 'Manual Credit Card', 'Debit Card')))            
union             
select         
'Invoice' strType,        
strInvoiceNumber, dtmDate, dblInvoiceTotal            
, INVOICE.intAccountId    
, INVOICE.ysnPosted       
FROM tblARInvoice INVOICE            
LEFT OUTER JOIN tblSMPaymentMethod SMPM ON INVOICE.intPaymentMethodId = SMPM.intPaymentMethodID            
WHERE-- INVOICE.ysnPosted = 1       AND         
INVOICE.intAccountId IS NOT NULL            
   AND INVOICE.strTransactionType = 'Cash'            
   AND UPPER(ISNULL(SMPM.strPaymentMethod,'')) <> UPPER('Write Off')            
   AND (ISNULL(INVOICE.ysnImportedFromOrigin,0) <> 1 AND ISNULL(INVOICE.ysnImportedAsPosted,0) <> 1)            
   and dblInvoiceTotal <> 0          
UNION            
SELECT         
'Receipts' strType,        
EOD.strEODNo, dtmClose dtmDate,            
EOD.dblFinalEndingBalance - ((EOD.dblOpeningBalance + ISNULL(EOD.dblExpectedEndingBalance,0) + ISNULL(EOD.dblCashPaymentReceived,0)) - ABS(ISNULL(EOD.dblCashReturn,0)))            
, EOD.intUndepositedFundsId       
, cast(1 as bit) ysnPosted         
FROM tblARPOSEndOfDay EOD            
INNER JOIN (            
 SELECT intCompanyLocationId            
   , intCompanyLocationPOSDrawerId            
   , strPOSDrawerName            
 FROM tblSMCompanyLocationPOSDrawer            
) DRAWER ON EOD.intCompanyLocationPOSDrawerId = DRAWER.intCompanyLocationPOSDrawerId            
WHERE EOD.ysnClosed = 1            
 AND intCashOverShortId IS NOT NULL            
 AND (EOD.dblFinalEndingBalance - ((EOD.dblOpeningBalance + ISNULL(EOD.dblExpectedEndingBalance,0) + ISNULL(EOD.dblCashPaymentReceived,0)) - ABS(ISNULL(EOD.dblCashReturn,0)))) <> 0.000000