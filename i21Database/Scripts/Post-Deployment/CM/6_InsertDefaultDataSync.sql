GO
    DECLARE @rowUpdated  NVARCHAR(20)
    WHILE EXISTS(SELECT TOP 1 1 FROM tblCMBankTransaction WHERE intFiscalPeriodId IS NULL)
	  BEGIN
		;WITH cte as(
		    SELECT TOP 1000 intTransactionId from tblCMBankTransaction WHERE intFiscalPeriodId IS NULL
		)
        UPDATE T SET intFiscalPeriodId = F.intGLFiscalYearPeriodId FROM tblCMBankTransaction T 
		JOIN cte C ON C.intTransactionId = T.intTransactionId
        CROSS APPLY dbo.fnGLGetFiscalPeriod(T.dtmDate) F
        SELECT  @rowUpdated = CONVERT( NVARCHAR(20) , @@ROWCOUNT )
		PRINT ('Updated fiscal period of ' +  @rowUpdated +  ' records in tblCMBankTransaction')
	END
    WHILE EXISTS(SELECT TOP 1 1 FROM tblCMBankTransfer WHERE intFiscalPeriodId IS NULL)
	  BEGIN
		;WITH cte as(
		    SELECT TOP 1000 intTransactionId from tblCMBankTransfer WHERE intFiscalPeriodId IS NULL
		)
        UPDATE T SET intFiscalPeriodId = F.intGLFiscalYearPeriodId FROM tblCMBankTransfer T 
		JOIN cte C ON C.intTransactionId = T.intTransactionId
        CROSS APPLY dbo.fnGLGetFiscalPeriod(T.dtmDate) F
        SELECT  @rowUpdated = CONVERT( NVARCHAR(20) , @@ROWCOUNT )
		PRINT ('Updated fiscal period of ' +  @rowUpdated +  ' records in tblCMBankTransfer')
	END
GO

IF NOT EXISTS(SELECT TOP 1 1 FROM tblCMLocXRef )
BEGIN 
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (5, N'83350746', N'83350746', N'3130308364', N'3130308364', N'45010030', N'45010030', N'19028094', N'19028094', N'005', N'005', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (6, N'83350747', N'83350747', N'3130683188', N'3130683188', N'45010196', N'45010196', N'19029388', N'19029388', N'006', N'006', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (7, NULL, NULL, N'3130683196', N'3130683196', N'45010204', N'45010204', N'19029389', N'19029389', N'007', N'007', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (10, N'83350748', N'83350748', N'3130683204', N'3130683204', N'45010212', N'45010212', N'19028095', N'19028095', N'010', N'010', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (14, N'83350749', N'83350749', N'3130331226', N'3130331226', N'45010113', N'45010113', N'19029390', N'19029390', N'014', N'014', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (15, N'83350750', N'83350750', N'3130308372', N'3130308372', N'45010048', N'45010048', NULL, NULL, N'015', N'015', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (16, N'83350751', N'83350751', N'3130683212', N'3130683212', N'45010220', N'45010220', N'19029392', N'19029392', N'016', N'016', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (18, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, N'815', N'018', NULL, N'ACH', N'ACH', N'ACH')
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (20, N'83350752', N'83350752', N'3130683220', N'3130683220', N'45010238', N'45010238', NULL, NULL, N'020', N'020', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (21, N'83350753', N'83350753', N'3130080591', N'3130080591', N'45010055', N'45010055', N'19028925', N'19028925', N'021', N'021', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (23, N'83350754', N'83350754', N'3130997455', N'3130997455', N'45010360', N'45010360', N'19029393', N'19029393', N'023', N'023', NULL, NULL, NULL, NULL, NULL, NULL)
 	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (28, N'83350755', N'83350755', N'3130683238', N'3130683238', N'45010246', N'45010246', N'19029395', N'19029395', N'028', N'028', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (30, N'83350756', N'83350756', N'3130683246', N'3130683246', N'45010253', N'45010253', N'19029404', N'19029404', N'030', N'030', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (32, N'83350758', N'83350758', N'3130683261', N'3130683261', N'45010279', N'45010279', N'19029397', N'19029397', N'032', N'032', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (33, N'83351289', N'83351289', N'3137535233', N'3137535233', N'45010519', N'45010519', N'19069343', N'19069343', N'033', N'033', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (34, N'83350759', N'83350759', N'3130331234', N'3130331234', N'45010121', N'45010121', N'19029406', N'19029406', N'034', N'034', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (35, N'83350760', N'83350760', N'3130683287', N'3130683287', N'45010287', N'45010287', N'19029408', N'19029408', N'035', N'035', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (36, N'83350761', N'83350761', N'3130683295', N'3130683295', N'45010295', N'45010295', N'19029409', N'19029409', N'036', N'036', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (37, N'83350981', N'83350981', N'3131865529', N'3131865529', N'45010410', N'45010410', N'19068125', N'19068125', N'037', N'037', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (38, N'83350982', N'83350982', N'3131865545', N'3131865545', N'45010428', N'45010428', N'19068126', N'19068126', N'038', N'038', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (39, N'83350762', N'83350762', N'3130238819', N'3130238819', N'45010071', N'45010071', N'19029398', N'19029398', N'039', N'039', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (40, N'83351130', N'83351130', N'0000000040', N'0000000040', N'45010501', N'45010501', N'19069234', N'19069234', N'040', N'040', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (41, N'83350766', N'83350766', N'3131194276', N'3131194276', N'45010386', N'45010386', N'19063582', N'19063582', N'041', N'041', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (42, N'83350763', N'83350763', N'3130989023', N'3130989023', N'45010303', N'45010303', N'19029399', N'19029399', N'042', N'042', NULL, NULL, N'1809563611', NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (43, N'83350764', N'83350764', N'3130683311', N'3130683311', N'45010311', N'45010311', N'19028093', N'19028093', N'043', N'043', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (44, N'83350765', N'83350765', N'3130023088', N'3130023088', N'45010089', N'45010089', N'19029411', N'19029411', N'044', N'044', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (45, N'83350767', N'83350767', N'3131048233', N'3131048233', N'45010329', N'45010329', N'19029412', N'19029412', N'045', N'045', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (46, N'83350768', N'83350768', N'3130528516', N'3130528516', N'45010188', N'45010188', N'19036809', N'19036809', N'046', N'046', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (47, N'83350769', N'83350769', N'3131379364', N'3131379364', N'45010477', N'45010477', N'19064637', N'19064637', N'047', N'047', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (48, N'83350940', N'83350940', N'3133200089', N'3133200089', N'45010493', N'45010493', N'19067675', N'19067675', N'048', N'048', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (49, N'83350770', N'83350770', N'3131128803', N'3131128803', N'45010378', N'45010378', N'19062677', N'19062677', N'049', N'049', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (551, N'83351048', N'83351048', N'0000000551', N'0000000551', N'45010147', N'45010147', N'19029414', N'19029414', N'551', N'551', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (556, NULL, NULL, N'3344020045', N'3344020045', N'45010402', N'45010402', N'19029418', N'19029418', N'556', N'556', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (557, NULL, NULL, N'3341534543', N'3341534543', N'45010337', N'45010337', N'19029419', N'19029419', N'557', N'557', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (559, N'83351079', N'83351079', N'3342964426', N'3342964426', N'45010394', N'45010394', N'19064913', N'19064913', N'559', N'559', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (562, NULL, NULL, N'3340261049', N'3340261049', N'45010105', N'45010105', N'19029425', N'19029425', N'562', N'562', NULL, NULL, NULL, NULL, NULL, NULL)
	INSERT [dbo].[tblCMLocXRef] ([Loc], [ATM Reimb], [ATM Surchg], [Amex-CR], [Amex-DR], [BA Merchant-CR], [BA Merchant-DR], [Telecheck-CR], [Telecheck-CR1], [Store Deps], [Store Chg Orders], [AR Check Deps], [Misc Office Deps], [Subway], [Cust Init ACH], [Clark], [WEX]) VALUES (565, N'83350771', N'83350771', N'3340793256', N'3340793256', N'45010162', N'45010162', N'19029428', N'19029428', N'565', N'565', NULL, NULL, NULL, NULL, NULL, NULL)
END

IF NOT EXISTS(SELECT TOP 1 1 FROM tblCMMacReportXRef )
BEGIN
	INSERT [dbo].[tblCMMacReportXRef] ([Type], [Description_Contains], [AccountNumber], [Reference], [CR_DR_Equals], [GL_Primary], [Bank_Acct], [X_Ref_Field], [X_Ref_Position], [X_Ref_Length], [ReferenceNot]) VALUES (N'BA Merchant-CR', N'BA MERCHANT', N'*', N'*', N'CR', N'110132', N'100410', N'Description', 39, 8, NULL)
	INSERT [dbo].[tblCMMacReportXRef] ([Type], [Description_Contains], [AccountNumber], [Reference], [CR_DR_Equals], [GL_Primary], [Bank_Acct], [X_Ref_Field], [X_Ref_Position], [X_Ref_Length], [ReferenceNot]) VALUES (N'BA Merchant-CR', N'BAMERCHANT', N'*', N'*', N'CR', N'110132', N'100410', N'Description', 39, 8, NULL)
	INSERT [dbo].[tblCMMacReportXRef] ([Type], [Description_Contains], [AccountNumber], [Reference], [CR_DR_Equals], [GL_Primary], [Bank_Acct], [X_Ref_Field], [X_Ref_Position], [X_Ref_Length], [ReferenceNot]) VALUES (N'BA Merchant-DR', N'BA MERCHANT', N'*', N'*', N'DR', N'110132', N'100410', N'Description', 38, 8, NULL)
	INSERT [dbo].[tblCMMacReportXRef] ([Type], [Description_Contains], [AccountNumber], [Reference], [CR_DR_Equals], [GL_Primary], [Bank_Acct], [X_Ref_Field], [X_Ref_Position], [X_Ref_Length], [ReferenceNot]) VALUES (N'BA Merchant-DR', N'BAMERCHANT', N'*', N'*', N'DR', N'110132', N'100410', N'Description', 38, 8, NULL)
	INSERT [dbo].[tblCMMacReportXRef] ([Type], [Description_Contains], [AccountNumber], [Reference], [CR_DR_Equals], [GL_Primary], [Bank_Acct], [X_Ref_Field], [X_Ref_Position], [X_Ref_Length], [ReferenceNot]) VALUES (N'Subway', N'ADYEN', N'*', N'*', N'CR', N'110132', N'100410', N'Description', 34, 10, NULL)
	INSERT [dbo].[tblCMMacReportXRef] ([Type], [Description_Contains], [AccountNumber], [Reference], [CR_DR_Equals], [GL_Primary], [Bank_Acct], [X_Ref_Field], [X_Ref_Position], [X_Ref_Length], [ReferenceNot]) VALUES (N'Amex-CR', N'AMERICAN EXPRESS', N'*', N'*', N'CR', N'110132', N'100410', N'Description', 32, 10, NULL)
	INSERT [dbo].[tblCMMacReportXRef] ([Type], [Description_Contains], [AccountNumber], [Reference], [CR_DR_Equals], [GL_Primary], [Bank_Acct], [X_Ref_Field], [X_Ref_Position], [X_Ref_Length], [ReferenceNot]) VALUES (N'Amex-CR', N'AMERICANEXPRESS', N'*', N'*', N'CR', N'110132', N'100410', N'Description', 32, 10, NULL)
	INSERT [dbo].[tblCMMacReportXRef] ([Type], [Description_Contains], [AccountNumber], [Reference], [CR_DR_Equals], [GL_Primary], [Bank_Acct], [X_Ref_Field], [X_Ref_Position], [X_Ref_Length], [ReferenceNot]) VALUES (N'AMEX-DR', N'AMERICAN EXPRESS', N'*', N'*', N'DR', N'110132', N'100410', N'Description', 31, 10, NULL)
	INSERT [dbo].[tblCMMacReportXRef] ([Type], [Description_Contains], [AccountNumber], [Reference], [CR_DR_Equals], [GL_Primary], [Bank_Acct], [X_Ref_Field], [X_Ref_Position], [X_Ref_Length], [ReferenceNot]) VALUES (N'AMEX-DR', N'AMERICANEXPRESS', N'*', N'*', N'DR', N'110132', N'100410', N'Description', 31, 10, NULL)
	INSERT [dbo].[tblCMMacReportXRef] ([Type], [Description_Contains], [AccountNumber], [Reference], [CR_DR_Equals], [GL_Primary], [Bank_Acct], [X_Ref_Field], [X_Ref_Position], [X_Ref_Length], [ReferenceNot]) VALUES (N'WEX', N'WRIGHT EXPRESS', N'*', N'*', N'*', N'110132', N'100410', N'Description', 1, 3, NULL)
	INSERT [dbo].[tblCMMacReportXRef] ([Type], [Description_Contains], [AccountNumber], [Reference], [CR_DR_Equals], [GL_Primary], [Bank_Acct], [X_Ref_Field], [X_Ref_Position], [X_Ref_Length], [ReferenceNot]) VALUES (N'WEX', N'WEX', N'*', N'*', N'*', N'110132', N'100410', N'Description', 1, 3, NULL)
	INSERT [dbo].[tblCMMacReportXRef] ([Type], [Description_Contains], [AccountNumber], [Reference], [CR_DR_Equals], [GL_Primary], [Bank_Acct], [X_Ref_Field], [X_Ref_Position], [X_Ref_Length], [ReferenceNot]) VALUES (N'WEX', N'WXS', N'*', N'*', N'*', N'110132', N'100410', N'Description', 1, 3, NULL)
	INSERT [dbo].[tblCMMacReportXRef] ([Type], [Description_Contains], [AccountNumber], [Reference], [CR_DR_Equals], [GL_Primary], [Bank_Acct], [X_Ref_Field], [X_Ref_Position], [X_Ref_Length], [ReferenceNot]) VALUES (N'WEX', N'WRIGHTEXPRESS', N'*', N'*', N'*', N'110132', N'100410', N'Description', 1, 3, NULL)
	INSERT [dbo].[tblCMMacReportXRef] ([Type], [Description_Contains], [AccountNumber], [Reference], [CR_DR_Equals], [GL_Primary], [Bank_Acct], [X_Ref_Field], [X_Ref_Position], [X_Ref_Length], [ReferenceNot]) VALUES (N'Clark', N'CLARK', N'*', N'*', N'*', N'110132', N'100410', N'Description', 1, 3, NULL)
	INSERT [dbo].[tblCMMacReportXRef] ([Type], [Description_Contains], [AccountNumber], [Reference], [CR_DR_Equals], [GL_Primary], [Bank_Acct], [X_Ref_Field], [X_Ref_Position], [X_Ref_Length], [ReferenceNot]) VALUES (N'Telecheck-CR', N'TELECHECK', N'*', N'*', N'CR', N'110137', N'100410', N'Description', 32, 8, NULL)
	INSERT [dbo].[tblCMMacReportXRef] ([Type], [Description_Contains], [AccountNumber], [Reference], [CR_DR_Equals], [GL_Primary], [Bank_Acct], [X_Ref_Field], [X_Ref_Position], [X_Ref_Length], [ReferenceNot]) VALUES (N'Telecheck-DR', N'TELECHECK', N'*', N'*', N'DR', N'110137', N'100410', N'Description', 31, 8, NULL)
	INSERT [dbo].[tblCMMacReportXRef] ([Type], [Description_Contains], [AccountNumber], [Reference], [CR_DR_Equals], [GL_Primary], [Bank_Acct], [X_Ref_Field], [X_Ref_Position], [X_Ref_Length], [ReferenceNot]) VALUES (N'Store Chg Orders', N'MONEY ROOM ORDER', N'*', N'*', N'*', N'100250', N'100420', N'Reference', 10, 3, NULL)
	INSERT [dbo].[tblCMMacReportXRef] ([Type], [Description_Contains], [AccountNumber], [Reference], [CR_DR_Equals], [GL_Primary], [Bank_Acct], [X_Ref_Field], [X_Ref_Position], [X_Ref_Length], [ReferenceNot]) VALUES (N'AR Check Deps', N'DEPOSIT', N'*', N'00000000815', N'*', N'100330', N'100408', N'Reference', 10, 3, NULL)
	INSERT [dbo].[tblCMMacReportXRef] ([Type], [Description_Contains], [AccountNumber], [Reference], [CR_DR_Equals], [GL_Primary], [Bank_Acct], [X_Ref_Field], [X_Ref_Position], [X_Ref_Length], [ReferenceNot]) VALUES (N'Misc Office Deps', N'DEPOSIT', N'*', N'00000000018', N'*', N'100320', N'100418', N'Reference', 10, 3, NULL)
	INSERT [dbo].[tblCMMacReportXRef] ([Type], [Description_Contains], [AccountNumber], [Reference], [CR_DR_Equals], [GL_Primary], [Bank_Acct], [X_Ref_Field], [X_Ref_Position], [X_Ref_Length], [ReferenceNot]) VALUES (N'Cust Init ACH', N'*', N'4623080391', N'*', N'*', N'100330', N'100417', N'Description', 1, 3, NULL)
	INSERT [dbo].[tblCMMacReportXRef] ([Type], [Description_Contains], [AccountNumber], [Reference], [CR_DR_Equals], [GL_Primary], [Bank_Acct], [X_Ref_Field], [X_Ref_Position], [X_Ref_Length], [ReferenceNot]) VALUES (N'ATM Reimb', N'201 Comp ID', N'4645246321', N'*', N'*', N'110142', N'100409', N'Description', 36, 8, NULL)
	INSERT [dbo].[tblCMMacReportXRef] ([Type], [Description_Contains], [AccountNumber], [Reference], [CR_DR_Equals], [GL_Primary], [Bank_Acct], [X_Ref_Field], [X_Ref_Position], [X_Ref_Length], [ReferenceNot]) VALUES (N'ATM Reimb', N'SET Comp ID', N'4645246321', N'*', N'*', N'110142', N'100409', N'Description', 36, 8, NULL)
	INSERT [dbo].[tblCMMacReportXRef] ([Type], [Description_Contains], [AccountNumber], [Reference], [CR_DR_Equals], [GL_Primary], [Bank_Acct], [X_Ref_Field], [X_Ref_Position], [X_Ref_Length], [ReferenceNot]) VALUES (N'ATM Surchg', N'SC Comp ID', N'4645246321', N'*', N'*', N'430454', N'100409', N'Description', 36, 8, NULL)
	INSERT [dbo].[tblCMMacReportXRef] ([Type], [Description_Contains], [AccountNumber], [Reference], [CR_DR_Equals], [GL_Primary], [Bank_Acct], [X_Ref_Field], [X_Ref_Position], [X_Ref_Length], [ReferenceNot]) VALUES (N'ATM Surchg', N'SCH Comp ID', N'4645246321', N'*', N'*', N'430454', N'100409', N'Description', 36, 8, NULL)
	INSERT [dbo].[tblCMMacReportXRef] ([Type], [Description_Contains], [AccountNumber], [Reference], [CR_DR_Equals], [GL_Primary], [Bank_Acct], [X_Ref_Field], [X_Ref_Position], [X_Ref_Length], [ReferenceNot]) VALUES (N'Store Deps', N'MONEY ROOM DEP', N'*', N'*', N'*', N'100200', N'100420', N'Reference', 10, 3, N'00000000815')
	INSERT [dbo].[tblCMMacReportXRef] ([Type], [Description_Contains], [AccountNumber], [Reference], [CR_DR_Equals], [GL_Primary], [Bank_Acct], [X_Ref_Field], [X_Ref_Position], [X_Ref_Length], [ReferenceNot]) VALUES (N'Store Deps', N'DEPOSIT', N'*', N'*', N'*', N'100200', N'100420', N'Reference', 10, 3, N'00000000815')
	INSERT [dbo].[tblCMMacReportXRef] ([Type], [Description_Contains], [AccountNumber], [Reference], [CR_DR_Equals], [GL_Primary], [Bank_Acct], [X_Ref_Field], [X_Ref_Position], [X_Ref_Length], [ReferenceNot]) VALUES (N'Store Deps', N'MONEY ROOM DEP', N'*', N'*', N'*', N'100200', N'100420', N'Reference', 10, 3, N'00000000018')
	INSERT [dbo].[tblCMMacReportXRef] ([Type], [Description_Contains], [AccountNumber], [Reference], [CR_DR_Equals], [GL_Primary], [Bank_Acct], [X_Ref_Field], [X_Ref_Position], [X_Ref_Length], [ReferenceNot]) VALUES (N'Store Deps', N'DEPOSIT', N'*', N'*', N'*', N'100200', N'100420', N'Reference', 10, 3, N'00000000018')
END
