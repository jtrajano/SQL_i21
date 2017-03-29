PRINT '*** ----  Checking Move the Terms per type  ---- ***'

IF NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Move the Terms per type')
BEGIN

PRINT '*** ----  Start Move the Terms per type  ---- ***'

	update a set a.intTermsId = b.intTermsId from tblAPVendor a
	join tblEMEntityLocation b
		on b.intEntityId = a.[intEntityId] and b.ysnDefaultLocation = 1 and b.intTermsId is not null

	update a set a.intTermsId = b.intTermsId from tblARCustomer a
		join tblEMEntityLocation b
			on b.intEntityId = a.intEntityCustomerId and b.ysnDefaultLocation = 1 and b.intTermsId is not null

INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Move the Terms per type', 1)

PRINT '*** ----  End Move the Terms per type ---- ***'

END