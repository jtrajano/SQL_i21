GO
IF NOT EXISTS(SELECT 1 FROM tblAP1099Threshold)
BEGIN
	INSERT INTO tblAP1099Threshold (
		 [dbl1099INT]
		,[dbl1099B]
		,[dbl1099MISCRent]
		,[dbl1099MISCRoyalties]
		,[dbl1099MISCOtherIncome] 
		,[dbl1099MISCFederalIncome]
		,[dbl1099MISCFishing]
		,[dbl1099MISCMedical]
		,[dbl1099MISCNonemployee]
		,[dbl1099MISCSubstitute]
		,[dbl1099MISCDirecSales]
		,[dbl1099MISCCrop]
		,[dbl1099MISCExcessGolden]
		,[dbl1099MISCGrossProceeds]
		,[strContactName]
		,[strContactPhone]
		,[strContactEmail]
	)
	SELECT
		[dbl1099INT]						=	0
		,[dbl1099B]							=	0
		,[dbl1099MISCRent]					=	0
		,[dbl1099MISCRoyalties]				=	0
		,[dbl1099MISCOtherIncome] 			=	0
		,[dbl1099MISCFederalIncome]			=	0
		,[dbl1099MISCFishing]				=	0
		,[dbl1099MISCMedical]				=	0
		,[dbl1099MISCNonemployee]			=	0
		,[dbl1099MISCSubstitute]			=	0
		,[dbl1099MISCDirecSales]			=	5000
		,[dbl1099MISCCrop]					=	0
		,[dbl1099MISCExcessGolden]			=	0
		,[dbl1099MISCGrossProceeds]			=	0
		,[strContactName]					=	NULL
		,[strContactPhone]					=	NULL
		,[strContactEmail]					=	NULL
END