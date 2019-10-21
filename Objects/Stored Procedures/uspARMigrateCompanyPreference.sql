CREATE PROCEDURE [dbo].[uspARMigrateCompanyPreference]
AS
IF NOT EXISTS(SELECT TOP 1 1 FROM tblARCompanyPreference)
BEGIN
    INSERT INTO tblARCompanyPreference(intARAccountId, intDiscountAccountId)
    SELECT
    DefaultARAccount AS intARAccountId,
	DefaultARDiscountAccount AS intDiscountAccountId
    FROM
    (
      SELECT strValue, strPreference
      FROM tblSMPreferences
      WHERE intUserID = 0
    ) d
    pivot
    (
      MAX(strValue)
      FOR strPreference IN (DefaultARAccount, DefaultARDiscountAccount)
    ) piv
    DELETE FROM tblSMPreferences
    WHERE strPreference
    IN ('DefaultARAccount', 'DefaultARDiscountAccount')
    AND intUserID = 0
END