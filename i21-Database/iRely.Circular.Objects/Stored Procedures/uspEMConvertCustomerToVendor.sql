CREATE PROCEDURE [dbo].[uspEMConvertCustomerToVendor]
     @CustomerIds AS [Id] READONLY     
    ,@UserId AS INT
AS

BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @DateNow AS DATETIME
        ,@TermId AS INT
        ,@CurrencyId AS INT
        ,@ZeroDecimal NUMERIC(18, 6)

SELECT TOP 1
     @DateNow       = GETDATE()
	,@ZeroDecimal   = 0.000000
    ,@TermId        = [intDefaultTermId]
    ,@CurrencyId    = [intDefaultCurrencyId]
FROM
    tblSMCompanyPreference
    
IF @TermId IS NULL
    SELECT TOP 1
        @TermId = [intTermID]
    FROM
        tblSMTerm
    WHERE
        [ysnActive] = 1
        
        
DECLARE @VendorLog AuditLogStagingTable	
DELETE FROM @VendorLog
INSERT INTO @VendorLog
    ([strScreenName]
    ,[intKeyValueId]
    ,[intEntityId]
    ,[strActionType]
    ,[strDescription]
    ,[strActionIcon]
    ,[strChangeDescription]
    ,[strFromValue]
    ,[strToValue]
    ,[strDetails])
SELECT 
     [strScreenName]        = 'EntityManagement.view.Entity'
    ,[intKeyValueId]        = ARC.[intEntityId]
    ,[intEntityId]          = @UserId
    ,[strActionType]        = 'Created'
    ,[strDescription]       = 'Customer(' + ARC.[strCustomerNumber] + ') converted to Vendor(' + ARC.[strCustomerNumber] + ').'
    ,[strActionIcon]        = NULL
    ,[strChangeDescription] = 'Customer(' + ARC.[strCustomerNumber] + ') converted to Vendor(' + ARC.[strCustomerNumber] + ').'
    ,[strFromValue]         = 'Customer(' + ARC.[strCustomerNumber] + ')'
    ,[strToValue]           = 'Vendor(' + ARC.[strCustomerNumber] + ')'
    ,[strDetails]           = NULL
FROM
     tblARCustomer ARC
INNER JOIN
    @CustomerIds C
        ON ARC.[intEntityId] = C.[intId]
WHERE
    NOT EXISTS(SELECT NULL FROM tblAPVendor APV WHERE APV.[intEntityId] = ARC.[intEntityId])       
              
        
INSERT INTO tblAPVendor
    ([intEntityId]
    ,[intDefaultLocationId]
    ,[intDefaultContactId]
    ,[intCurrencyId]
    ,[strVendorPayToId]
    ,[intPaymentMethodId]
    ,[intTaxCodeId]
    ,[intGLAccountExpenseId]
    ,[intVendorType]
    ,[strVendorId]
    ,[strVendorAccountNum]
    ,[ysnPymtCtrlActive]
    ,[ysnPymtCtrlAlwaysDiscount]
    ,[ysnPymtCtrlEFTActive]
    ,[ysnPymtCtrlHold]
    ,[ysnWithholding]
    ,[dblCreditLimit]
    ,[intCreatedUserId]
    ,[intLastModifiedUserId]
    ,[dtmLastModified]
    ,[dtmCreated]
    ,[strTaxState]
    ,[ysnTransportTerminal]
    ,[intConcurrencyId]
    ,[strTaxNumber]
    ,[intBillToId]
    ,[intShipFromId]
    ,[ysnDeleted]
    ,[dtmDateDeleted]
    ,[ysnOneBillPerPayment]
    ,[strFLOId]
    ,[intApprovalListId]
    ,[intTermsId]
    ,[intRiskVendorPriceFixationLimitId]
    ,[dblRiskTotalBusinessVolume]
    ,[intRiskUnitOfMeasureId]
    ,[strStoreFTPPath]
    ,[strStoreFTPUsername]
    ,[strStoreFTPPassword]
    ,[intStoreStoreId])
SELECT
     [intEntityId]                          = ARC.[intEntityId]
    ,[intDefaultLocationId]                 = ARC.[intDefaultLocationId]
    ,[intDefaultContactId]                  = ARC.[intDefaultContactId]
    ,[intCurrencyId]                        = ISNULL(ARC.[intCurrencyId], @CurrencyId)
    ,[strVendorPayToId]                     = NULL
    ,[intPaymentMethodId]                   = ARC.[intPaymentMethodId]
    ,[intTaxCodeId]                         = ARC.[intTaxCodeId]
    ,[intGLAccountExpenseId]                = NULL
    ,[intVendorType]                        = 0
    ,[strVendorId]                          = ARC.[strCustomerNumber]
    ,[strVendorAccountNum]                  = ARC.[strAccountNumber]
    ,[ysnPymtCtrlActive]                    = 1
    ,[ysnPymtCtrlAlwaysDiscount]            = 0
    ,[ysnPymtCtrlEFTActive]                 = 1
    ,[ysnPymtCtrlHold]                      = 0
    ,[ysnWithholding]                       = 0
    ,[dblCreditLimit]                       = ARC.[dblCreditLimit]
    ,[intCreatedUserId]                     = @UserId
    ,[intLastModifiedUserId]                = @UserId
    ,[dtmLastModified]                      = @DateNow
    ,[dtmCreated]                           = @DateNow
    ,[strTaxState]                          = ARC.[strTaxState]
    ,[ysnTransportTerminal]                 = 0
    ,[intConcurrencyId]                     = 0
    ,[strTaxNumber]                         = ARC.[strTaxNumber]
    ,[intBillToId]                          = ARC.[intBillToId]
    ,[intShipFromId]                        = ARC.[intShipToId]
    ,[ysnDeleted]                           = 0
    ,[dtmDateDeleted]                       = NULL
    ,[ysnOneBillPerPayment]                 = 0
    ,[strFLOId]                             = ARC.[strFLOId]
    ,[intApprovalListId]                    = NULL
    ,[intTermsId]                           = ISNULL(ARC.[intTermsId], @TermId)
    ,[intRiskVendorPriceFixationLimitId]    = NULL
    ,[dblRiskTotalBusinessVolume]           = @ZeroDecimal
    ,[intRiskUnitOfMeasureId]               = NULL
    ,[strStoreFTPPath]                      = NULL
    ,[strStoreFTPUsername]                  = NULL
    ,[strStoreFTPPassword]                  = NULL
    ,[intStoreStoreId]                      = NULL
FROM
     tblARCustomer ARC
INNER JOIN
    @CustomerIds C
        ON ARC.[intEntityId] = C.[intId]
WHERE
    NOT EXISTS(SELECT NULL FROM tblAPVendor APV WHERE APV.[intEntityId] = ARC.[intEntityId])


INSERT INTO tblAPVendorTerm
    ([intEntityVendorId]
    ,[intTermId]
    ,[intConcurrencyId])
SELECT
     [intEntityVendorId]	= APV.[intEntityId]
    ,[intTermId]            = APV.[intTermsId]
    ,[intConcurrencyId]     = 0 
FROM
	tblAPVendor APV
INNER JOIN
    @CustomerIds C
        ON APV.[intEntityId] = C.[intId]
WHERE
    NOT EXISTS(SELECT NULL FROM tblAPVendorTerm APVT WHERE APVT.[intEntityVendorId] = APV.[intEntityId] AND APVT.[intTermId] = APV.[intTermsId])
    

INSERT INTO tblEMEntityType ( intEntityId, strType, intConcurrencyId)
SELECT  intId, 'Vendor', 0
    FROM @CustomerIds C
        WHERE C.intId not in (SELECT intEntityId FROM tblEMEntityType WHERE strType = 'Vendor')


EXEC [dbo].[uspSMInsertAuditLogs] @LogEntries = @VendorLog

END
