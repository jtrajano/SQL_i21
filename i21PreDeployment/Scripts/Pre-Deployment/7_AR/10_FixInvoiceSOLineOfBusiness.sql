GO 
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE WHERE CONSTRAINT_NAME = 'FK_tblARInvoice_tblEMEntityLineOfBusiness_intEntityLineOfBusiness')
	BEGIN
		PRINT 'BEGIN Drop FK_tblARInvoice_tblEMEntityLineOfBusiness_intEntityLineOfBusiness'
		EXEC('
			ALTER TABLE tblARInvoice
			DROP CONSTRAINT FK_tblARInvoice_tblEMEntityLineOfBusiness_intEntityLineOfBusiness		
		');
		PRINT 'END Drop FK_tblARInvoice_tblEMEntityLineOfBusiness_intEntityLineOfBusiness';

		PRINT 'BEGIN DROPPING COLUMN intEntityLineOfBusinessId FROM tblARInvoice'
		EXEC('ALTER TABLE tblARInvoice
			  DROP COLUMN intEntityLineOfBusinessId
		');
	END	
GO
IF EXISTS(SELECT * FROM INFORMATION_SCHEMA.CONSTRAINT_TABLE_USAGE WHERE CONSTRAINT_NAME = 'FK_tblSOSalesOrder_tblEMEntityLineOfBusiness_intEntityLineOfBusinessId')
	BEGIN
		PRINT 'BEGIN Drop FK_tblSOSalesOrder_tblEMEntityLineOfBusiness_intEntityLineOfBusinessId'
		EXEC('
			ALTER TABLE tblSOSalesOrder
			DROP CONSTRAINT FK_tblSOSalesOrder_tblEMEntityLineOfBusiness_intEntityLineOfBusinessId		
		');
		PRINT 'END Drop FK_tblSOSalesOrder_tblEMEntityLineOfBusiness_intEntityLineOfBusinessId';

		PRINT 'BEGIN DROPPING COLUMN intEntityLineOfBusinessId FROM tblSOSalesOrder'
		EXEC('
			ALTER TABLE tblSOSalesOrder
			DROP COLUMN intEntityLineOfBusinessId
		');
		PRINT 'END DROPPING COLUMN intEntityLineOfBusinessId FROM tblSOSalesOrder'
	END
GO