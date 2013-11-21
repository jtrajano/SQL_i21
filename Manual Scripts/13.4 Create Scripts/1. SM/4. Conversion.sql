/*
	BEGIN CONVERSION Company Setup
*/
truncate table tblSMCompanySetup
GO
insert into tblSMCompanySetup (strCompanyName)
	select top 1 coctl_co_name from [coctlmst]
GO

/*
	END CONVERSION Company Setup
*/


/*
	BEGIN CONVERSION Company Preference
*/
-- Legacy integration is ON by default
	insert tblSMPreferences
	(
	strPreference
	,strDescription
	,strValue
	,intSort
	,intConcurrencyID
	)
	select 'isLegacyIntegration', 'isLegacyIntegration', 'true', 0, 0

/*
	BEGIN CONVERSION Company Preference
*/
