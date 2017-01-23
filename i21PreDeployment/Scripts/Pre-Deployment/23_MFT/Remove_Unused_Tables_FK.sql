GO
PRINT 'MFT Remove FK of Obsolete table/s'
GO
	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'tblTFTaxCriteria')
		BEGIN
			IF EXISTS(SELECT 1 FROM sys.foreign_keys WHERE parent_object_id = OBJECT_ID(N'dbo.tblTFTaxCriteria'))
			 BEGIN 
					ALTER TABLE tblTFTaxCriteria
					DROP CONSTRAINT FK_tblTFTaxCriteria_tblTFReportingComponent
					PRINT 'Foreign Key Removed'
			END 
		END
	ELSE
		BEGIN
			PRINT 'TABLE tblTFTaxCriteria does NOT EXIST!'
		END
