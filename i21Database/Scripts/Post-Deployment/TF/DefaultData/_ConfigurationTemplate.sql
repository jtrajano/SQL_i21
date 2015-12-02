
DECLARE @intTaxAuthorityId INT

SELECT TOP 1 @intTaxAuthorityId = intTaxAuthorityId FROM tblTFTaxAuthority WHERE strTaxAuthorityCode = 'IN'
IF (@intTaxAuthorityId IS NOT NULL)
BEGIN
	IF NOT EXISTS(SELECT TOP 1 [intTaxAuthorityId] FROM [tblTFConfigurationTemplate] WHERE [intTaxAuthorityId] = @intTaxAuthorityId)
	BEGIN
		INSERT INTO [tblTFConfigurationTemplate]
		(
			[intTaxAuthorityId],[strConfigurationName],[intConfigurationTypeId],[strValue]
		)
		VALUES
		 (@intTaxAuthorityId
		,'I have a Supplier license'
		, (select top 1 intConfigurationTypeId from tblTFConfigurationType where strType = 'Yes/No')
		,'')
		,(@intTaxAuthorityId
		,'I have a Importer license'
		,(select top 1 intConfigurationTypeId from tblTFConfigurationType where strType = 'Yes/No')
		,'')
		,(@intTaxAuthorityId
		,'I have a Gasoline license'
		,(select top 1 intConfigurationTypeId from tblTFConfigurationType where strType = 'Yes/No')
		,'')
		,(@intTaxAuthorityId
		,'I have a Permissive Supplier license'
		,(select top 1 intConfigurationTypeId from tblTFConfigurationType where strType = 'Yes/No')
		,'')
		,(@intTaxAuthorityId
		,'I have a Blender license'
		,(select top 1 intConfigurationTypeId from tblTFConfigurationType where strType = 'Yes/No')
		,'')
		,(@intTaxAuthorityId
		,'I have an Exporter license'
		,(select top 1 intConfigurationTypeId from tblTFConfigurationType where strType = 'Yes/No')
		,'')
		,(@intTaxAuthorityId
		,'I have an Oil Inspection Distributon license'
		,(select top 1 intConfigurationTypeId from tblTFConfigurationType where strType = 'Yes/No')
		,'')
		,(@intTaxAuthorityId
		,'I have a Gasolhol Blender license'
		,(select top 1 intConfigurationTypeId from tblTFConfigurationType where strType = 'Yes/No')
		,'')
		,(@intTaxAuthorityId
		,'MF-301/MF-401 Transporter Carrier'
		,(select top 1 intConfigurationTypeId from tblTFConfigurationType where strType = 'Selection')
		,'')
		,(@intTaxAuthorityId
		,'PPD Sales Tax License Number'
		,(select top 1 intConfigurationTypeId from tblTFConfigurationType where strType = 'Text')
		,'')
		,(@intTaxAuthorityId
		,'Exporter License Number'
		,(select top 1 intConfigurationTypeId from tblTFConfigurationType where strType = 'Text')
		,'')
		,(@intTaxAuthorityId
		,'Permissive Supplier License Number '
		,(select top 1 intConfigurationTypeId from tblTFConfigurationType where strType = 'Text')
		,'')
		,(@intTaxAuthorityId
		,'MF-360 License Number'
		,(select top 1 intConfigurationTypeId from tblTFConfigurationType where strType = 'Text')
		,'')
		,(@intTaxAuthorityId
		,'Special Fuel License Number'
		,(select top 1 intConfigurationTypeId from tblTFConfigurationType where strType = 'Text')
		, '')
		,(@intTaxAuthorityId
		,'Dyed Fuel License Number'
		,(select top 1 intConfigurationTypeId from tblTFConfigurationType where strType = 'Text')
		,'')
		,(@intTaxAuthorityId
		,'ESpeical Fuel Blender License Number'
		,(select top 1 intConfigurationTypeId from tblTFConfigurationType where strType = 'Text')
		,'')
		,(@intTaxAuthorityId
		,'EFT Filer'
		,(select top 1 intConfigurationTypeId from tblTFConfigurationType where strType = 'Selection')
		,'')
		,(@intTaxAuthorityId
		,'ST-103 Filer '
		,(select top 1 intConfigurationTypeId from tblTFConfigurationType where strType = 'Selection')
		,'')
		,(@intTaxAuthorityId
		,'ST-103 MP Filer'
		,(select top 1 intConfigurationTypeId from tblTFConfigurationType where strType = 'Selection')
		,'')
		

	END
END
