CREATE PROCEDURE [dbo].[uspSMGenerateTooltipControls]
	AS
BEGIN
		BEGIN TRY
			BEGIN TRANSACTION

				DELETE FROM tblSMTooltip

				INSERT INTO tblSMTooltip
				SELECT DISTINCT
					A.intScreenId,
					strControlId,
					strControlName,
					null,
				NULL,
					strControlType,
					--B.strScreenName,
					CASE WHEN A.intParentScreenId != 0
					THEN 
						 --B.strScreenName + ': ' +  B.strModule improve script
						 'Company Configuration: ' + B.strModule
					ELSE B.strScreenName
					END AS strScreenName,
					NULL,
					CASE WHEN A.intParentScreenId != 0
					THEN 
						(SELECT strScreenName FROM tblSMScreen WHERE intScreenId = A.intParentScreenId)
					ELSE ''
				END AS strParentScreen,
				'Top',
				0
				FROM tblSMControl A
				LEFT JOIN tblSMScreen B ON B.intScreenId = A.intScreenId

				UPDATE tblSMCompanySetup
				SET ysnTooltipListingUpdated = 1
				COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
				ROLLBACK TRANSACTION
		END CATCH
END