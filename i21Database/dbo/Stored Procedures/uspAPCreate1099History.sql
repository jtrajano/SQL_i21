CREATE PROCEDURE [dbo].[uspAPCreate1099History]
	@vendorFrom NVARCHAR(100) = NULL,
	@vendorTo NVARCHAR(100) = NULL,
	@year INT,
	@form1099 INT
AS

CREATE TABLE #tmpCreated(id INT);

IF @form1099 = 1
BEGIN
	
	CREATE TABLE #tmp1099History(
		[intEntityVendorId] INT NOT NULL, 
		[intYear] INT NOT NULL DEFAULT 0, 
		[int1099Form] INT NOT NULL DEFAULT 0, 
		[ysnPrinted] BIT NOT NULL DEFAULT 0, 
		[ysnFiled] BIT NOT NULL DEFAULT 0, 
		[strComment] NVARCHAR(500) NULL, 
		[dblAmount] DECIMAL(18, 6) NULL, 
		[strVendorName] NVARCHAR(200) NULL, 
		[strVendorId]	NVARCHAR(100) NULL,
		[intConcurrencyId] INT NOT NULL DEFAULT 0, 
		[dtmDatePrinted] DATETIME NULL, 
		[dtmDateFiled] DATETIME NULL
	)

	IF @form1099 = 1
	BEGIN
		INSERT INTO #tmp1099History
		SELECT
			[intEntityVendorId]	=	A.intEntityVendorId, 
			[intYear]			=	A.intYear, 
			[int1099Form]		=	@form1099,
			[ysnPrinted]		=	CAST(1 AS BIT), 
			[ysnFiled]			=	CAST(0 AS BIT), 
			[strComment]		=	NULL, 
			[dblAmount]			=	A.dblTotalPayment, 
			[strVendorName]		=	A.strVendorCompanyName, 
			[strVendorId]		=	A.strVendorId,
			[intConcurrencyId]	=	0, 
			[dtmDatePrinted]	=	GETDATE(), 
			[dtmDateFiled]		=	NULL
		FROM vyuAP1099MISC A
		WHERE 
		1 = (CASE WHEN ISNULL(@vendorFrom,'') = '' THEN 1
					WHEN ISNULL(@vendorFrom,'') <> '' AND A.strVendorId BETWEEN @vendorFrom AND @vendorTo THEN 1 ELSE 0 END)
				AND A.intYear = @year

	END
	ELSE IF @form1099 = 2
	BEGIN
		INSERT INTO #tmp1099History
		SELECT
			[intEntityVendorId]	=	A.intEntityVendorId, 
			[intYear]			=	A.intYear, 
			[int1099Form]		=	@form1099,
			[ysnPrinted]		=	CAST(1 AS BIT), 
			[ysnFiled]			=	CAST(0 AS BIT), 
			[strComment]		=	NULL, 
			[dblAmount]			=	A.dbl1099INT, 
			[strVendorName]		=	A.strVendorCompanyName, 
			[strVendorId]		=	A.strVendorId,
			[intConcurrencyId]	=	0, 
			[dtmDatePrinted]	=	GETDATE(), 
			[dtmDateFiled]		=	NULL
		FROM vyuAP1099 A
		WHERE 
		1 = (CASE WHEN ISNULL(@vendorFrom,'') = '' THEN 1
					WHEN ISNULL(@vendorFrom,'') <> '' AND A.strVendorId BETWEEN @vendorFrom AND @vendorTo THEN 1 ELSE 0 END)
				AND A.intYear = @year
	END
	ELSE IF @form1099 = 3
	BEGIN
		INSERT INTO #tmp1099History
		SELECT
			[intEntityVendorId]	=	A.intEntityVendorId, 
			[intYear]			=	A.intYear, 
			[int1099Form]		=	@form1099,
			[ysnPrinted]		=	CAST(1 AS BIT), 
			[ysnFiled]			=	CAST(0 AS BIT), 
			[strComment]		=	NULL, 
			[dblAmount]			=	A.dbl1099B, 
			[strVendorName]		=	A.strVendorCompanyName, 
			[strVendorId]		=	A.strVendorId,
			[intConcurrencyId]	=	0, 
			[dtmDatePrinted]	=	GETDATE(), 
			[dtmDateFiled]		=	NULL
		FROM vyuAP1099 A
		WHERE 
		1 = (CASE WHEN ISNULL(@vendorFrom,'') = '' THEN 1
					WHEN ISNULL(@vendorFrom,'') <> '' AND A.strVendorId BETWEEN @vendorFrom AND @vendorTo THEN 1 ELSE 0 END)
				AND A.intYear = @year
	END

	INSERT INTO tblAP1099History(
		[intEntityVendorId]	
		,[intYear]			
		,[int1099Form]
		,[ysnPrinted]		
		,[ysnFiled]			
		,[strComment]		
		,[dblAmount]			
		,[strVendorName]	
		,[strVendorId]
		,[intConcurrencyId]	
		,[dtmDatePrinted]	
		,[dtmDateFiled]		
	)
	OUTPUT inserted.int1099HistoryId INTO #tmpCreated
	SELECT * FROM #tmp1099History

	
END

EXEC [uspAPUpdateBill1099Status] @vendorFrom, @vendorTo, @year, @form1099
SELECT  * FROM tblAP1099History WHERE int1099HistoryId IN (SELECT id FROM #tmpCreated)