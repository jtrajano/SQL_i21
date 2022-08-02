print('/*******************  BEGIN Update tblARCompanyPreference *******************/')
GO

UPDATE tblARCompanyPreference SET ysnEnableCustomStatement = CAST(0 AS BIT) WHERE ysnEnableCustomStatement IS NULL

GO
print('/*******************  BEGIN Update tblARCompanyPreference  *******************/')


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