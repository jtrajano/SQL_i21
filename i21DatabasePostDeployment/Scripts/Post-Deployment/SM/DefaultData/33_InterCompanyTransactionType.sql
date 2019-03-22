GO
	PRINT N'BEGIN INTER-COMPANY TRANSACTION TYPE'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMInterCompanyTransactionType WHERE strTransactionType = 'Purchase Contract')
	INSERT INTO tblSMInterCompanyTransactionType(strTransactionType) VALUES('Purchase Contract')

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMInterCompanyTransactionType WHERE strTransactionType = 'Sales Contract')
	INSERT INTO tblSMInterCompanyTransactionType(strTransactionType) VALUES('Sales Contract')

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMInterCompanyTransactionType WHERE strTransactionType = 'Purchase Price Fixation')
	INSERT INTO tblSMInterCompanyTransactionType(strTransactionType) VALUES('Purchase Price Fixation')

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMInterCompanyTransactionType WHERE strTransactionType = 'Sales Price Fixation')
	INSERT INTO tblSMInterCompanyTransactionType(strTransactionType) VALUES('Sales Price Fixation')

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMInterCompanyTransactionType WHERE strTransactionType = 'Long Futures')
	INSERT INTO tblSMInterCompanyTransactionType(strTransactionType) VALUES('Long Futures')

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMInterCompanyTransactionType WHERE strTransactionType = 'Short Futures')
	INSERT INTO tblSMInterCompanyTransactionType(strTransactionType) VALUES('Short Futures')

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMInterCompanyTransactionType WHERE strTransactionType = 'Inbound Shipping Instruction')
	INSERT INTO tblSMInterCompanyTransactionType(strTransactionType) VALUES('Inbound Shipping Instruction')

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMInterCompanyTransactionType WHERE strTransactionType = 'Outbound Shipping Instruction')
	INSERT INTO tblSMInterCompanyTransactionType(strTransactionType) VALUES('Outbound Shipping Instruction')

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMInterCompanyTransactionType WHERE strTransactionType = 'Drop Shipping Instruction')
	INSERT INTO tblSMInterCompanyTransactionType(strTransactionType) VALUES('Drop Shipping Instruction')

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMInterCompanyTransactionType WHERE strTransactionType = 'Inbound Shipment')
	INSERT INTO tblSMInterCompanyTransactionType(strTransactionType) VALUES('Inbound Shipment')

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMInterCompanyTransactionType WHERE strTransactionType = 'Drop Shipment')
	INSERT INTO tblSMInterCompanyTransactionType(strTransactionType) VALUES('Drop Shipment')

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMInterCompanyTransactionType WHERE strTransactionType = 'Outbound Shipment')
	INSERT INTO tblSMInterCompanyTransactionType(strTransactionType) VALUES('Outbound Shipment')

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMInterCompanyTransactionType WHERE strTransactionType = 'Inbound Weight Claims')
	INSERT INTO tblSMInterCompanyTransactionType(strTransactionType) VALUES('Inbound Weight Claims')

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMInterCompanyTransactionType WHERE strTransactionType = 'Outbound Weight Claims')
	INSERT INTO tblSMInterCompanyTransactionType(strTransactionType) VALUES('Outbound Weight Claims')

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMInterCompanyTransactionType WHERE strTransactionType = 'Drop Shipment Weight Claims')
	INSERT INTO tblSMInterCompanyTransactionType(strTransactionType) VALUES('Drop Shipment Weight Claims')

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMInterCompanyTransactionType WHERE strTransactionType = 'Purchase Invoice')
	INSERT INTO tblSMInterCompanyTransactionType(strTransactionType) VALUES('Purchase Invoice')

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMInterCompanyTransactionType WHERE strTransactionType = 'Sales Invoice')
	INSERT INTO tblSMInterCompanyTransactionType(strTransactionType) VALUES('Sales Invoice')	
	
	PRINT N'END INTER-COMPANY TRANSACTION TYPE'
GO