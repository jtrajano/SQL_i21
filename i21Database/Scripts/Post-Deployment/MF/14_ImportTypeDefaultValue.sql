﻿PRINT 'Begin Adding of Import Type Default Value'
GO

IF NOT EXISTS (SELECT TOP 1 * FROM tblQMImportType WHERE intImportTypeId = 1)
	BEGIN
		INSERT INTO tblQMImportType (intImportTypeId, strName, strDescription) VALUES (1, 'Catalogue', 'Catalogue')
	END
GO
IF NOT EXISTS (SELECT TOP 1 * FROM tblQMImportType WHERE intImportTypeId = 2)
	BEGIN
		INSERT INTO tblQMImportType (intImportTypeId, strName, strDescription) VALUES (2, 'Tasting Score', 'Tasting Score')
	END
GO
IF NOT EXISTS (SELECT TOP 1 * FROM tblQMImportType WHERE intImportTypeId = 3)
	BEGIN
		INSERT INTO tblQMImportType (intImportTypeId, strName, strDescription) VALUES (3, 'Supplier Valuation', 'Supplier Valuation')
	END
GO
IF NOT EXISTS (SELECT TOP 1 * FROM tblQMImportType WHERE intImportTypeId = 4)
	BEGIN
		INSERT INTO tblQMImportType (intImportTypeId, strName, strDescription) VALUES (4, 'Initial Buy', 'Initial Buy')
	END
GO
IF NOT EXISTS (SELECT TOP 1 * FROM tblQMImportType WHERE intImportTypeId = 5)
	BEGIN
		INSERT INTO tblQMImportType (intImportTypeId, strName, strDescription) VALUES (5, 'Contract Line Allocation', 'Contract Line Allocation')
	END
GO


PRINT 'End of Adding of Import Type Default Value'
GO