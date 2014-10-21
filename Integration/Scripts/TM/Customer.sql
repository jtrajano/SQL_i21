PRINT N'BEGIN Update of data in tblTMCustomer Populate strOriginCustomerKey'
GO

IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vwcusmst') 
	AND EXISTS(SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strOriginCustomerKey' AND OBJECT_ID = OBJECT_ID(N'tblTMCustomer'))
BEGIN
		EXEC ('
				UPDATE tblTMCustomer
				SET strOriginCustomerKey = ISNULL(A.vwcus_key,'''')
				FROM vwcusmst A
				WHERE tblTMCustomer.intCustomerNumber = A.A4GLIdentity
				AND tblTMCustomer.strOriginCustomerKey IS NULL OR tblTMCustomer.strOriginCustomerKey = ''''
			  ')
END
GO

PRINT N'END Update of data in tblTMCustomer Populate strOriginCustomerKey'
GO