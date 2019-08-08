GO
	PRINT N'BEGIN INSERT DEFAULT TM PREFERENCE COMPANY'
GO


IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblTMPreferenceCompany]') AND type in (N'U')) 
BEGIN
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[tblTMPreferenceCompany])
	BEGIN
		EXEC('
			IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''[dbo].[coctlmst]'') AND type IN (N''U'')) 
			BEGIN
				GOTO Insert_default;
			END
			IF((SELECT TOP 1 coctl_pt FROM coctlmst) = ''Y'')
			BEGIN 
				INSERT INTO [tblTMPreferenceCompany] (strSummitIntegration,ysnUseOriginIntegration) VALUES (''Petro'',0)
				GOTO end_insert;
			END
			IF((SELECT TOP 1 coctl_ag FROM coctlmst) = ''Y'')
			BEGIN
				INSERT INTO [tblTMPreferenceCompany] (strSummitIntegration,ysnUseOriginIntegration) VALUES (''AG'',0)
				GOTO end_insert;
			END
			Insert_default:
			INSERT INTO tblTMPreferenceCompany(intConcurrencyId,ysnUseOriginIntegration)VALUES(0,0)
			end_insert:
		')
	END
END

exec(
'
delete from tblTMTankMonitorInterfaceType;
set identity_insert tblTMTankMonitorInterfaceType on;
insert into tblTMTankMonitorInterfaceType (
	[intInterfaceTypeId],
	[strInterfaceType],
    [ysnFromAPI],
    [intConcurrencyId]
)
	select
	intInterfaceTypeId = 1,
	strInterfaceType = ''Wesroc'',
    ysnFromAPI = 0,
    intConcurrencyId = 1

insert into tblTMTankMonitorInterfaceType (
	[intInterfaceTypeId],
	[strInterfaceType],
    [ysnFromAPI],
    [intConcurrencyId]
)
	select
	intInterfaceTypeId = 2,
	strInterfaceType = ''EcoGreen'',
    ysnFromAPI = 1,
    intConcurrencyId = 1

set identity_insert tblTMTankMonitorInterfaceType off;
'
);

GO
	PRINT N'END INSERT DEFAULT TM PREFERENCE COMPANY'
GO