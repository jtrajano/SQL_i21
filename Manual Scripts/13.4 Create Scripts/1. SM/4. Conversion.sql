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