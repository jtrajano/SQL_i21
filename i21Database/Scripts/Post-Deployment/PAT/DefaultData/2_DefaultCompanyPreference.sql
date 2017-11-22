GO
PRINT N'*** BEGIN - INSERT DEFAULT COMPANY PREFERENCE ***'
GO
SET IDENTITY_INSERT [dbo].[tblPATCompanyPreference] ON 

IF NOT EXISTS (SELECT * FROM tblPATCompanyPreference)
BEGIN
	INSERT INTO tblPATCompanyPreference([intCompanyPreferenceId],
			[strRefund],
			[dblMinimumRefund],
			[dblServiceFee],
			[dblCutoffAmount],
			[strCutoffTo],
			[strPayOnGrain],
			[strPrintCheck],
			[intPaymentItemId],
			[dblMinimumDividends],
			[ysnProRatedDividends],
			[dtmCutoffDate],
			[intVotingStockId],
			[intNonVotingStockId],
			[intFractionalShareId],
			[intServiceFeeIncomeId],
			[intDividendsGLAccount],
			[intAPClearingGLAccount],
			[intConcurrencyId])
	VALUES(1, --intCompanyPreferenceId
			'A', --strRefund
			0, --dblMinimumRefund
			0, --dblServiceFee
			0, --dblCutoffAmount
			'Cash', --strCutoffTo
			'Paid', --strPayOnGrain
			NULL, --strPrintCheck
			NULL, --intPaymentItemId
			0, --dblMinimumDividends
			NULL, --ysnProRatedDividends
			NULL, --dtmCutoffDate
			NULL, --intVotingStockId
			NULL, --intNonVotingStockId
			NULL, --intFractionalShareId
			NULL, --intServiceFeeIncomeId
			NULL, --intDividendsGLAccount
			NULL, --intAPClearingGLAccount
			1 --intConcurrencyId
	);
END
SET IDENTITY_INSERT [dbo].[tblPATCompanyPreference] OFF
GO
PRINT N'*** END - INSERT DEFAULT COMPANY PREFERENCE ***'
GO