
GO
PRINT 'START TF tblTFConfigurationType'
GO

IF NOT EXISTS(SELECT TOP 1 [intConfigurationTypeId] FROM [tblTFConfigurationType] WHERE strType = 'Yes/No')
	BEGIN
		INSERT INTO tblTFConfigurationType([strType])
		VALUES('Yes/No')
	END

IF NOT EXISTS(SELECT TOP 1 [intConfigurationTypeId] FROM [tblTFConfigurationType] WHERE strType = 'Decimal')
	BEGIN
		INSERT INTO tblTFConfigurationType([strType])
		VALUES('Decimal')
	END

IF NOT EXISTS(SELECT TOP 1 [intConfigurationTypeId] FROM [tblTFConfigurationType] WHERE strType = 'Text')
	BEGIN
		INSERT INTO tblTFConfigurationType([strType])
		VALUES('Text')
	END
	
IF NOT EXISTS(SELECT TOP 1 [intConfigurationTypeId] FROM [tblTFConfigurationType] WHERE strType = 'Selection')
	BEGIN
		INSERT INTO tblTFConfigurationType([strType])
		VALUES('Selection')
	END

GO
PRINT 'END TF tblTFConfigurationType'
GO
