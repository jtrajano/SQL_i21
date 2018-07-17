print('/*******************  BEGIN Fix FK Constraints for NR Company Preference *******************/')
GO

IF (EXISTS(SELECT NULL FROM sys.tables WHERE [name] = N'tblNRCompanyPreference'))
BEGIN
    IF (EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intNotesReceivableAccountId' AND [object_id] = OBJECT_ID(N'tblNRCompanyPreference')))
		UPDATE tblNRCompanyPreference SET intNotesReceivableAccountId = NULLIF(intNotesReceivableAccountId, 0)

	IF (EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intClearingAccountId' AND [object_id] = OBJECT_ID(N'tblNRCompanyPreference')))
		UPDATE tblNRCompanyPreference SET intClearingAccountId = NULLIF(intClearingAccountId, 0)

	IF (EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intNotesWriteOffAccountId' AND [object_id] = OBJECT_ID(N'tblNRCompanyPreference')))
		UPDATE tblNRCompanyPreference SET intNotesWriteOffAccountId = NULLIF(intNotesWriteOffAccountId, 0)

	IF (EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intInterestIncomeAccountId' AND [object_id] = OBJECT_ID(N'tblNRCompanyPreference')))
		UPDATE tblNRCompanyPreference SET intInterestIncomeAccountId = NULLIF(intInterestIncomeAccountId, 0)

	IF (EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intScheduledInvoiceAccountId' AND [object_id] = OBJECT_ID(N'tblNRCompanyPreference')))
		UPDATE tblNRCompanyPreference SET intScheduledInvoiceAccountId = NULLIF(intScheduledInvoiceAccountId, 0)

	IF (EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intScheduledInvoiceLateFeeAccountId' AND [object_id] = OBJECT_ID(N'tblNRCompanyPreference')))
		UPDATE tblNRCompanyPreference SET intScheduledInvoiceLateFeeAccountId = NULLIF(intScheduledInvoiceLateFeeAccountId, 0)

	IF (EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intCashAccountId' AND [object_id] = OBJECT_ID(N'tblNRCompanyPreference')))
		UPDATE tblNRCompanyPreference SET intCashAccountId = NULLIF(intCashAccountId, 0)

	IF (EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intNotesReceivableAccountId' AND [object_id] = OBJECT_ID(N'tblNRCompanyPreference')))
		UPDATE tblNRCompanyPreference SET intBankAccountId = NULLIF(intBankAccountId, 0)
END

GO
print('/*******************  END Fix FK Constraints for NR Company Preference *******************/')