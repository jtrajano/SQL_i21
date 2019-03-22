PRINT N'START MIGRATE Contract Basis to Freight Term'
BEGIN


	IF NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'MIGRATE Contract Basis to Freight Term')
	BEGIN
		
		

		update tblSMFreightTerms set strContractBasis = strFreightTerm, strDescription = strFreightTerm 

		update 
			a
				set strContractBasis = b.strContractBasis,
					strDescription = b.strDescription,
					ysnDefault = b.ysnDefault,
					intInsuranceById = b.intInsuranceById,
					intInvoiceTypeId = b.intInvoiceTypeId,
					intPositionId = b.intPositionId,
					strINCOLocationType = b.strINCOLocationType
		from tblSMFreightTerms a 
			join tblCTContractBasis b
				on a.strFreightTerm = b.strContractBasis

		insert into tblSMFreightTerms(
			strFreightTerm, strFobPoint, ysnActive, strContractBasis, strDescription, ysnDefault, intInsuranceById, intInvoiceTypeId, intPositionId, strINCOLocationType
			)
		select 
			strContractBasis, 'None', ysnActive, strContractBasis, strDescription, ysnDefault, intInsuranceById, intInvoiceTypeId, intPositionId, strINCOLocationType
	
			from tblCTContractBasis 
				where strContractBasis  not in ( select strFreightTerm from tblSMFreightTerms)
		
		INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
		VALUES('MIGRATE Contract Basis to Freight Term', 1)


	END

END
PRINT N'END MIGRATE  Contract Basis to Freight Term'