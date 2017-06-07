PRINT '*** Start Migrate Vendor Approval***'
IF NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Migrate Vendor Approval')
BEGIN
	PRINT '***Execute***'
	
	DECLARE @ScreenId INT

	select @ScreenId = intScreenId from tblSMScreen where strScreenName ='Voucher'
	INSERT INTO tblEMEntityRequireApprovalFor(intEntityId, intApprovalListId, intScreenId, intConcurrencyId)
	select [intEntityId], intApprovalListId, @ScreenId, 1 from tblAPVendor where intApprovalListId is not null and [intEntityId] not in (select intEntityId from tblEMEntityRequireApprovalFor )



	INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Migrate Vendor Approval', 1)
END
PRINT '*** End Migrate Vendor Approval***'
