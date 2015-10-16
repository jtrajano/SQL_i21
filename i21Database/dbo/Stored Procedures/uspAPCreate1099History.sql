﻿CREATE PROCEDURE [dbo].[uspAPCreate1099History]
	@vendorFrom NVARCHAR(100) = NULL,
	@vendorTo NVARCHAR(100) = NULL,
	@year INT,
	@form1099 INT
AS

CREATE TABLE #tmpCreated(id INT);

IF @form1099 = 1
BEGIN
	
	INSERT INTO tblAP1099History(
		[intEntityVendorId]	
		,[intYear]			
		,[ysnPrinted]		
		,[ysnFiled]			
		,[strComment]		
		,[dblAmount]			
		,[strVendorName]		
		,[intConcurrencyId]	
		,[dtmDatePrinted]	
		,[dtmDateFiled]		
	)
	OUTPUT inserted.int1099HistoryId INTO #tmpCreated
	SELECT
		[intEntityVendorId]	=	A.intEntityVendorId, 
		[intYear]			=	A.intYear, 
		[ysnPrinted]		=	CAST(1 AS BIT), 
		[ysnFiled]			=	CAST(0 AS BIT), 
		[strComment]		=	NULL, 
		[dblAmount]			=	A.dblTotalPayment, 
		[strVendorName]		=	A.strVendorCompanyName, 
		[intConcurrencyId]	=	0, 
		[dtmDatePrinted]	=	GETDATE(), 
		[dtmDateFiled]		=	NULL
	FROM vyuAP1099MISC A
	WHERE 
	--A.intEntityVendorId BETWEEN (CASE WHEN @vendorTo < @vendorFrom THEN @vendorTo ELSE @vendorFrom END) 
	--				AND (CASE WHEN @vendorTo < @vendorFrom THEN @vendorFrom ELSE @vendorTo END)
	1 = (CASE WHEN ISNULL(@vendorFrom,'') = '' THEN 1
				WHEN ISNULL(@vendorFrom,'') <> '' AND A.strVendorId BETWEEN @vendorFrom AND @vendorTo THEN 1 ELSE 0 END)
			AND A.intYear = @year

END

EXEC [uspAPUpdateBill1099Status] @vendorFrom, @vendorTo, @year, @form1099
SELECT  * FROM tblAP1099History WHERE int1099HistoryId IN (SELECT id FROM #tmpCreated)