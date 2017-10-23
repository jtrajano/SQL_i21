
PRINT 'MFT Remove FK of Obsolete table/s'

	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblTFTaxCriteria')
		BEGIN
			IF EXISTS(SELECT TOP 1 * FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS WHERE CONSTRAINT_NAME ='FK_tblTFTaxCriteria_tblTFReportingComponent')
			 BEGIN
				ALTER TABLE tblTFTaxCriteria
				DROP CONSTRAINT FK_tblTFTaxCriteria_tblTFReportingComponent
				PRINT 'tblTFTaxCriteria Foreign Key Removed'
			END 
			ELSE
				BEGIN
					PRINT 'tblTFTaxCriteria Foreign Key does not exist'
				END
		END
	ELSE
		BEGIN
			PRINT 'TABLE tblTFTaxCriteria does NOT EXIST!'
		END

	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblTFTransactionException')
		BEGIN
			IF EXISTS(SELECT TOP 1 * FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS WHERE CONSTRAINT_NAME ='FK_tblTFTransactionException_tblTFTransaction')
			 BEGIN
				ALTER TABLE tblTFTransactionException
				DROP CONSTRAINT FK_tblTFTransactionException_tblTFTransaction
				PRINT 'FK_tblTFTransactionException_tblTFTransaction Removed'
			END 
		END

GO
	
