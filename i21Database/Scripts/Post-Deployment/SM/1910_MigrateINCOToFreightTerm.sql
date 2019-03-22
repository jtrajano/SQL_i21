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


		
			declare @screenId int
			select @screenId = intScreenId from tblSMScreen where strNamespace = 'i21.view.FreightTerm'

			if @screenId is not null
			begin
				declare @t table (
					id int identity,
					intScreenId int,
					intRecordId int,
					intReportTransaction int
				)
				insert into @t(intScreenId, intRecordId, intReportTransaction)
				select @screenId ,e.intFreightTermId, a.intReportTranslationId

				from
					tblSMReportTranslation a
				join tblSMTransaction b
					on a.intTransactionId = b.intTransactionId
				join tblSMScreen c
					on b.intScreenId = c.intScreenId and c.strNamespace = 'ContractManagement.view.INCOShipTerm'
				join tblCTContractBasis d
					on b.intRecordId = d.intContractBasisId
				join tblSMFreightTerms e
					on e.strContractBasis = d.strContractBasis

				declare @current_id int
				declare @transaction_id int
				declare @current_rep int
				declare @current_record_id int
				
				while exists(Select top 1 1 from @t)
				begin
					select top 1 

						@current_id = id, 
						@current_rep = intReportTransaction,
						@current_record_id = intRecordId
							
					from @t

					set @transaction_id = null
					select top 1 @transaction_id = intTransactionId from tblSMTransaction where intScreenId = @screenId and intRecordId = @current_record_id

					if  @transaction_id is null
					begin
						
						insert into tblSMTransaction(intScreenId, intRecordId)
						select intScreenId, intRecordId from @t where id = @current_id
						set @transaction_id = @@IDENTITY

					end			

					insert into tblSMReportTranslation(strFieldName, strTranslation, intTransactionId, intLanguageId)
					select strFieldName, strTranslation, @transaction_id, intLanguageId from tblSMReportTranslation where intReportTranslationId = @current_rep

					delete from @t where id = @current_id
				end

			end

		
		INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
		VALUES('MIGRATE Contract Basis to Freight Term', 1)
	

	END

END
PRINT N'END MIGRATE  Contract Basis to Freight Term'