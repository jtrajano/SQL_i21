IF EXISTS(SELECT TOP 1 1 from sys.procedures WHERE name = 'uspSMGenerateTooltipControls')
	DROP PROCEDURE uspSMGenerateTooltipControls
GO

CREATE PROCEDURE [dbo].[uspSMGenerateTooltipControls]
	AS
BEGIN

 IF NOT EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblSMTooltip')
		   BEGIN TRY
			   INSERT INTO [dbo].[tblSMTooltip]
				SELECT DISTINCT
					A.intScreenId,
					strControlId,
					strControlName,
					null,
				NULL,
					strControlType,
					B.strScreenName,
	
					NULL,
					'Top',
					0
				FROM [tblSMControl] A
				LEFT JOIN [tblSMScreen] B ON B.intScreenId = A.intScreenId

				UPDATE tblSMCompanySetup
				SET ysnTooltipListingUpdated = 1
			
		   END TRY
				BEGIN CATCH
						PRINT(N'INSERT CONTROLS TO TOOLTIPS FAILED');
				END CATCH
END
