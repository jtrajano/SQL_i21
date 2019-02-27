
PRINT 'Begin Checking unique constraint for Tax Group Tax Code'
IF OBJECTPROPERTY(OBJECT_ID('UK_tblSMTaxGroupCode_intTaxGroupId_intTaxCodeId'), 'IsConstraint') is null
BEGIN
	PRINT 'Execute Checking unique constraint for Tax Group Tax Code'
	
	IF 
		EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMTaxGroupCode' and [COLUMN_NAME] = 'intTaxGroupCodeId') and 
		EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMTaxGroupCode' and [COLUMN_NAME] = 'intTaxGroupId') and 
		EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMTaxGroupCode' and [COLUMN_NAME] = 'intTaxCodeId')  and

		EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMTaxGroupCodeCategoryExemption' and [COLUMN_NAME] = 'intTaxGroupCodeCategoryExemptionId') and 
		EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMTaxGroupCodeCategoryExemption' and [COLUMN_NAME] = 'intCategoryId') and 
		EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMTaxGroupCodeCategoryExemption' and [COLUMN_NAME] = 'intTaxGroupCodeId')  
	BEGIN
		
		declare @TaxCode table ( id int)
		declare @TaxElimination table(parentid int, tag int, tag2 int, childid int)
		declare @Result table(intTaxGroupCodeId int, intTaxGroupId int, intTaxCodeId int ,rn int)

		insert into @Result(intTaxGroupCodeId, intTaxGroupId, intTaxCodeId, rn)
		select intTaxGroupCodeId, intTaxGroupId, intTaxCodeId, RowNumber from  (
			select
				intTaxGroupCodeId,
				intTaxGroupId, 
				intTaxCodeId		
				,ROW_NUMBER() over (partition by intTaxGroupId, intTaxCodeId order by intTaxGroupId) RowNumber 
			from tblSMTaxGroupCode 
		) a

		--these are the taxgroup code that will be deleted
		insert into @TaxCode
		select intTaxGroupCodeId from @Result where rn > 1
	
		--these will be used for tax category exemption update
		insert into @TaxElimination(tag, tag2, childid)
		select intTaxGroupId, 
				intTaxCodeId,
				intTaxGroupCodeId 
		from @Result where rn > 1 

		--set the parent id that will be used to move the category exemption
		update a  set parentid = b.intTaxGroupCodeId
		from
			@TaxElimination a
			join @Result b 
				on a.tag = b.intTaxGroupId and a.tag2 = b.intTaxCodeId and rn = 1


	
		-- this will eliminate the duplicate category exemption that will be moved to the parent
		delete from tblSMTaxGroupCodeCategoryExemption   where intTaxGroupCodeCategoryExemptionId in (
		select intTaxGroupCodeCategoryExemptionId from tblSMTaxGroupCodeCategoryExemption  aa
			join (
		select childid, intCategoryId from tblSMTaxGroupCodeCategoryExemption a 
			join @TaxElimination b
				on a.intTaxGroupCodeId = b.parentid  ) bb
			on aa.intTaxGroupCodeId = bb.childid and aa.intCategoryId = bb.intCategoryId
			) 

		--update the tax group exemption and move it to the parent of the duplicate
		update a set intTaxGroupCodeId = b.parentid
		from tblSMTaxGroupCodeCategoryExemption a
			join @TaxElimination b
				on a.intTaxGroupCodeId = b.childid
	
	
		delete from tblSMTaxGroupCode where intTaxGroupCodeId in ( select id from @TaxCode)

	END
END
PRINT 'End Checking unique constraint for Tax Group Tax Code'



