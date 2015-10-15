GO
	PRINT 'START OF CREATING [uspEMRecreateCheckIfOriginVendor] SP'
GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspEMRecreateCheckIfOriginVendor]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].uspEMRecreateCheckIfOriginVendor
GO


CREATE PROCEDURE uspEMRecreateCheckIfOriginVendor 
AS
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[uspEMCheckIfOriginVendor]') AND type in (N'P', N'PC'))
	BEGIN
		DROP PROCEDURE uspEMCheckIfOriginVendor
	END

	IF ((SELECT TOP 1 ysnLegacyIntegration FROM tblSMCompanyPreference) = 1)
	BEGIN
		EXEC('
			CREATE PROCEDURE [dbo].[uspEMCheckIfOriginVendor]
				@Id			NVARCHAR(100),
				@GoDelete	BIT OUTPUT
			AS
			BEGIN
				IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = ''tblAPImportedVendors'') 
				BEGIN
					if exists(select top 1 1 from tblAPImportedVendors where strVendorId = @Id AND ysnOrigin = 1)
					begin
						set @GoDelete = 0
					end
				END
			END
		')
	END	
END
GO
	PRINT 'END OF CREATING [uspEMRecreateCheckIfOriginVendor] SP'
GO
	PRINT 'START OF Execute [uspEMRecreateCheckIfOriginVendor] SP'
GO
	EXEC ('uspEMRecreateCheckIfOriginVendor')
GO
	PRINT 'END OF Execute [uspEMRecreateCheckIfOriginVendor] SP'
GO