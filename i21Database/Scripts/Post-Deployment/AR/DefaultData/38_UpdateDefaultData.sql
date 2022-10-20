print('/*******************  BEGIN Update tblARCompanyPreference *******************/')
GO

UPDATE tblARCompanyPreference SET intPageLimit = 1000 WHERE intPageLimit IS NULL
UPDATE tblARCompanyPreference SET ysnEnableCustomStatement = CAST(0 AS BIT) WHERE ysnEnableCustomStatement IS NULL

GO
print('/*******************  BEGIN Update tblARCompanyPreference  *******************/')

print('/*******************  BEGIN Update tblARCustomer *******************/')
GO

UPDATE tblARCustomer SET ysnUpdatedAppliedSalesTax = 1, ysnApplySalesTax = 1 WHERE ysnUpdatedAppliedSalesTax IS NULL OR ysnUpdatedAppliedSalesTax = 0

GO
print('/*******************  BEGIN Update tblARCustomer  *******************/')

print('/*******************  BEGIN Update tblARInvoice *******************/')
GO

UPDATE tblARInvoice SET dblInvoiceTotal = 0 WHERE dblInvoiceTotal IS NULL
UPDATE tblARInvoice SET dblAmountDue = 0 WHERE dblAmountDue IS NULL
UPDATE tblARInvoice SET dblDiscount = 0 WHERE dblDiscount IS NULL
UPDATE tblARInvoice SET dblInterest = 0 WHERE dblInterest IS NULL
UPDATE tblARInvoice SET dblShipping = 0 WHERE dblShipping IS NULL
UPDATE tblARInvoice SET dtmDate = CAST(dtmDate AS DATE) WHERE CAST(dtmDate AS TIME) <> '00:00:00.0000000'
UPDATE tblARInvoice SET dtmPostDate = CAST(dtmPostDate AS DATE) WHERE CAST(dtmPostDate AS TIME) <> '00:00:00.0000000'

GO
print('/*******************  BEGIN Update tblARInvoice  *******************/')

print('/*******************  BEGIN Update tblARPayment *******************/')
GO

ALTER TABLE tblARPayment DISABLE TRIGGER trg_tblARPaymentUpdate
ALTER TABLE tblARPaymentDetail DISABLE TRIGGER trg_tblARPaymentDetailUpdate

UPDATE tblARPayment SET dblAmountPaid = 0 WHERE dblAmountPaid IS NULL
UPDATE tblARPayment SET dtmDatePaid = CAST(dtmDatePaid AS DATE) WHERE CAST(dtmDatePaid AS TIME) <> '00:00:00.0000000'

GO
print('/*******************  BEGIN Update tblARPayment  *******************/')

print('/*******************  BEGIN Update tblARPaymentDetail *******************/')
GO

UPDATE tblARPaymentDetail SET dblPayment = 0 WHERE dblPayment IS NULL
UPDATE tblARPaymentDetail SET dblAmountDue = 0 WHERE dblAmountDue IS NULL
UPDATE tblARPaymentDetail SET dblDiscount = 0 WHERE dblDiscount IS NULL
UPDATE tblARPaymentDetail SET dblInterest = 0 WHERE dblInterest IS NULL
UPDATE tblARPaymentDetail SET dblWriteOffAmount = 0 WHERE dblWriteOffAmount IS NULL

ALTER TABLE tblARPayment ENABLE TRIGGER trg_tblARPaymentUpdate
ALTER TABLE tblARPaymentDetail ENABLE TRIGGER trg_tblARPaymentDetailUpdate

GO
print('/*******************  BEGIN Update tblARPaymentDetail  *******************/')

print('/*******************  BEGIN INSERT DEFAULT STATEMENT FORMATS *******************/')
GO

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblARCustomerStatementFormat')
BEGIN
	IF NOT EXISTS (SELECT TOP 1 NULL FROM tblARCustomerStatementFormat WHERE strStatementFormat = 'None')
        BEGIN
            INSERT INTO tblARCustomerStatementFormat (strStatementFormat, ysnCustomFormat) 
            SELECT strStatementFormat = 'None', ysnCustomFormat = 0
        END

    IF NOT EXISTS (SELECT TOP 1 NULL FROM tblARCustomerStatementFormat WHERE strStatementFormat = 'Open Item')
        BEGIN
            INSERT INTO tblARCustomerStatementFormat (strStatementFormat, ysnCustomFormat) 
            SELECT strStatementFormat = 'Open Item', ysnCustomFormat = 0
        END

    IF NOT EXISTS (SELECT TOP 1 NULL FROM tblARCustomerStatementFormat WHERE strStatementFormat = 'Open Statement - Lazer')
        BEGIN
            INSERT INTO tblARCustomerStatementFormat (strStatementFormat, ysnCustomFormat) 
            SELECT strStatementFormat = 'Open Statement - Lazer', ysnCustomFormat = 0
        END

    IF NOT EXISTS (SELECT TOP 1 NULL FROM tblARCustomerStatementFormat WHERE strStatementFormat = 'Balance Forward')
        BEGIN
            INSERT INTO tblARCustomerStatementFormat (strStatementFormat, ysnCustomFormat) 
            SELECT strStatementFormat = 'Balance Forward', ysnCustomFormat = 0
        END

    IF NOT EXISTS (SELECT TOP 1 NULL FROM tblARCustomerStatementFormat WHERE strStatementFormat = 'Budget Reminder')
        BEGIN
            INSERT INTO tblARCustomerStatementFormat (strStatementFormat, ysnCustomFormat) 
            SELECT strStatementFormat = 'Budget Reminder', ysnCustomFormat = 0
        END

    IF NOT EXISTS (SELECT TOP 1 NULL FROM tblARCustomerStatementFormat WHERE strStatementFormat = 'Budget Reminder Alternate 2')
        BEGIN
            INSERT INTO tblARCustomerStatementFormat (strStatementFormat, ysnCustomFormat) 
            SELECT strStatementFormat = 'Budget Reminder Alternate 2', ysnCustomFormat = 0
        END

    IF NOT EXISTS (SELECT TOP 1 NULL FROM tblARCustomerStatementFormat WHERE strStatementFormat = 'Payment Activity')
        BEGIN
            INSERT INTO tblARCustomerStatementFormat (strStatementFormat, ysnCustomFormat) 
            SELECT strStatementFormat = 'Payment Activity', ysnCustomFormat = 0
        END

    IF NOT EXISTS (SELECT TOP 1 NULL FROM tblARCustomerStatementFormat WHERE strStatementFormat = 'Running Balance')
        BEGIN
            INSERT INTO tblARCustomerStatementFormat (strStatementFormat, ysnCustomFormat) 
            SELECT strStatementFormat = 'Running Balance', ysnCustomFormat = 0
        END

    IF NOT EXISTS (SELECT TOP 1 NULL FROM tblARCustomerStatementFormat WHERE strStatementFormat = 'Full Details - No Card Lock')
        BEGIN
            INSERT INTO tblARCustomerStatementFormat (strStatementFormat, ysnCustomFormat) 
            SELECT strStatementFormat = 'Full Details - No Card Lock', ysnCustomFormat = 0
        END

    IF NOT EXISTS (SELECT TOP 1 NULL FROM tblARCustomerStatementFormat WHERE strStatementFormat = 'Honstein Oil')
        BEGIN
            INSERT INTO tblARCustomerStatementFormat (strStatementFormat, ysnCustomFormat) 
            SELECT strStatementFormat = 'Honstein Oil', ysnCustomFormat = 0
        END

    IF NOT EXISTS (SELECT TOP 1 NULL FROM tblARCustomerStatementFormat WHERE strStatementFormat = 'Zeeland Open Item')
        BEGIN
            INSERT INTO tblARCustomerStatementFormat (strStatementFormat, ysnCustomFormat) 
            SELECT strStatementFormat = 'Zeeland Open Item', ysnCustomFormat = 1
        END

    IF NOT EXISTS (SELECT TOP 1 NULL FROM tblARCustomerStatementFormat WHERE strStatementFormat = 'Zeeland Balance Forward')
        BEGIN
            INSERT INTO tblARCustomerStatementFormat (strStatementFormat, ysnCustomFormat) 
            SELECT strStatementFormat = 'Zeeland Balance Forward', ysnCustomFormat = 1
        END
END

GO
print('/*******************  BEGIN INSERT DEFAULT STATEMENT FORMATS  *******************/')