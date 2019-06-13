﻿GO
	PRINT N'START BASIS COMPONENT MIGRATION'
GO
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE UPPER(TABLE_NAME) = 'TBLCTCOMPANYPREFERENCE') 
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE UPPER(TABLE_NAME) = 'TBLCTCOMPANYPREFERENCE' AND UPPER(COLUMN_NAME) = 'YSNBASISCOMPONENT') 
		BEGIN
			EXEC
			('
				ALTER table tblCTCompanyPreference
				ADD ysnBasisComponentPurchase BIT NOT NULL DEFAULT(0)

				ALTER table tblCTCompanyPreference
				ADD ysnBasisComponentSales BIT NOT NULL DEFAULT(0)
			')

			EXEC
			('
				UPDATE tblCTCompanyPreference 
				SET ysnBasisComponentPurchase = ysnBasisComponent, ysnBasisComponentSales = ysnBasisComponent
				FROM tblCTCompanyPreference
			')
		END		
	END
GO
	PRINT N'END BASIS COMPONENT MIGRATION'
GO