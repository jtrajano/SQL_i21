/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/
GO
	PRINT N'Set Create and Post voucher to True on First Upgrade'
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblAPVendor' AND [COLUMN_NAME] IN ('ysnCreateVoucher','ysnPostVoucher')) 
		BEGIN
			IF NOT EXISTS (SELECT * FROM tblEMEntityPreferences WHERE strPreference = 'AP tblAPVendor UpdateVendorCreatePostVoucher')
				BEGIN
					UPDATE tblAPVendor
					SET ysnCreateVoucher = 1 , ysnPostVoucher = 1

					  --Insert into EM Preferences. This will serve as the checking if the update will be executed or not.
					  INSERT INTO tblEMEntityPreferences (strPreference,strValue) VALUES ('AP tblAPVendor UpdateVendorCreatePostVoucher','1')
				END
		END
	PRINT N'END Set Create and Post voucher to True on First Upgrade'
GO