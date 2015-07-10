CREATE PROCEDURE [dbo].[uspNRMigrateCompanyPreference]
AS
IF NOT EXISTS(SELECT TOP 1 1 FROM tblNRCompanyPreference)
BEGIN
    INSERT INTO tblNRCompanyPreference(dblFee, intNotesReceivableAccountId, intClearingAccountId, intNotesWriteOffAccountId, intInterestIncomeAccountId
				, intScheduledInvoiceAccountId, intScheduledInvoiceLateFeeAccountId, intCashAccountId, intBankAccountId, blnContinueInterestCalculationAfterNoteMaturityDate
				, intNumberofDaysPriorNoteBeGenerated, blnOriginCompatible, strOriginSystem, strVersionNumber)
	SELECT
		NRFee AS dblFee,
		NRGLNotesReceivableAccount AS intNotesReceivableAccountId,
		NRGLClearingAccount AS intClearingAccountId,
		NRNoteWriteOffAccount AS intNotesWriteOffAccountId,
		NRGLInterestIncomeAccount AS intInterestIncomeAccountId,
		NRGLScheduledInvoiceAccount AS intScheduledInvoiceAccountId,
		NRScheduledInvoiceLateFeeAccount AS intScheduledInvoiceLateFeeAccountId,
		NRCashAccount AS intCashAccountId,
		nrBankAccount AS intBankAccountId,
		NRContinueInterestCalculation AS blnContinueInterestCalculationAfterNoteMaturityDate,
		NRNumberOfDaysPriorNoteBeGenerated AS intNumberofDaysPriorNoteBeGenerated,
		nrSwitchOrigini21 AS blnOriginCompatible,
		nrOriginSystem AS strOriginSystem,
		nrVersionNumber AS strVersionNumber
		FROM
		(
		  SELECT strValue, strPreference
		  FROM tblSMPreferences
		  WHERE intUserID = 0
		) d
		pivot
		(
		  MAX(strValue)
		  FOR strPreference IN (NRFee, NRGLNotesReceivableAccount, NRGLClearingAccount, NRNoteWriteOffAccount, NRGLInterestIncomeAccount
		  , NRGLScheduledInvoiceAccount, NRScheduledInvoiceLateFeeAccount, NRCashAccount, nrBankAccount, NRContinueInterestCalculation
		  , NRNumberOfDaysPriorNoteBeGenerated, nrSwitchOrigini21, nrOriginSystem, nrVersionNumber)
		) piv
    DELETE FROM tblSMPreferences
    WHERE strPreference
    IN ('NRFee', 'NRGLNotesReceivableAccount', 'NRGLClearingAccount', 'NRNoteWriteOffAccount', 'NRGLInterestIncomeAccount'
	, 'NRGLScheduledInvoiceAccount', 'NRScheduledInvoiceLateFeeAccount', 'NRCashAccount', 'nrBankAccount', 'NRContinueInterestCalculation'
	, 'NRNumberOfDaysPriorNoteBeGenerated', 'nrSwitchOrigini21', 'nrOriginSystem', 'nrVersionNumber')
    AND intUserID = 0

END