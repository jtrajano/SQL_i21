CREATE FUNCTION [dbo].[fnAP1099EFileMISCPayee]
(
	@year INT,
	@corrected BIT = 0
)
RETURNS @returntable TABLE
(
	B NVARCHAR(1500)
)
AS
BEGIN

	DECLARE @maxAmount DECIMAL(18,6) = 9999999999.99;

	INSERT @returntable
	SELECT 
		'B'
		+ CAST(@year AS NVARCHAR(10))  --Position 2-5
		+ ' '
		+ SPACE(4)
		+ '1'
		+ ISNULL(NULLIF(A.strFederalTaxId,''),SPACE(9)) -- 12-20
		+ dbo.fnTrim(A.strVendorId) + SPACE(20 - LEN(dbo.fnTrim(A.strVendorId))) -- 21-40
		+ SPACE(4) -- 41-44
		+ SPACE(10) -- 45-54
		+ CASE WHEN A.dblRents > @maxAmount 
			THEN dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - ROUND(A.dblRents,2) AS NVARCHAR(100))) 
				+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - ROUND(A.dblRents,2) AS NVARCHAR(100)))))
			ELSE 
				+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(ROUND(A.dblRents,2) AS NVARCHAR(100)))))
		END
		+ CASE WHEN A.dblRoyalties > @maxAmount 
			THEN dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - ROUND(A.dblRoyalties,2) AS NVARCHAR(100))) 
				+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - ROUND(A.dblRoyalties,2) AS NVARCHAR(100)))))
			ELSE 
				+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(ROUND(A.dblRoyalties,2) AS NVARCHAR(100)))))
		END
		+ CASE WHEN A.dblOtherIncome > @maxAmount 
			THEN dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - ROUND(A.dblOtherIncome,2) AS NVARCHAR(100))) 
				+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - ROUND(A.dblOtherIncome,2) AS NVARCHAR(100)))))
			ELSE 
				+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(ROUND(A.dblOtherIncome,2) AS NVARCHAR(100)))))
		END
		+ CASE WHEN A.dblFederalIncome > @maxAmount 
			THEN dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - ROUND(A.dblFederalIncome,2) AS NVARCHAR(100))) 
				+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - ROUND(A.dblFederalIncome,2) AS NVARCHAR(100)))))
			ELSE 
				+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(ROUND(A.dblFederalIncome,2) AS NVARCHAR(100)))))
		END
		+ CASE WHEN A.dblBoatsProceeds > @maxAmount 
			THEN dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - ROUND(A.dblBoatsProceeds,2) AS NVARCHAR(100))) 
				+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - ROUND(A.dblBoatsProceeds,2) AS NVARCHAR(100)))))
			ELSE 
				+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(ROUND(A.dblBoatsProceeds,2) AS NVARCHAR(100)))))
		END
		+ CASE WHEN A.dblMedicalPayments > @maxAmount 
			THEN dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - ROUND(A.dblMedicalPayments,2) AS NVARCHAR(100))) 
				+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - ROUND(A.dblMedicalPayments,2) AS NVARCHAR(100)))))
			ELSE 
				+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(ROUND(A.dblMedicalPayments,2) AS NVARCHAR(100)))))
		END
		+ CASE WHEN A.dblNonemployeeCompensation > @maxAmount 
			THEN dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - ROUND(A.dblNonemployeeCompensation,2) AS NVARCHAR(100))) 
				+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - ROUND(A.dblNonemployeeCompensation,2) AS NVARCHAR(100)))))
			ELSE 
				+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(ROUND(A.dblNonemployeeCompensation,2) AS NVARCHAR(100)))))
		END
		+ CASE WHEN A.dblSubstitutePayments > @maxAmount 
			THEN dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - ROUND(A.dblSubstitutePayments,2) AS NVARCHAR(100))) 
				+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - ROUND(A.dblSubstitutePayments,2) AS NVARCHAR(100)))))
			ELSE 
				+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(ROUND(A.dblSubstitutePayments,2) AS NVARCHAR(100)))))
		END
		+ CASE WHEN A.dblCropInsurance > @maxAmount 
			THEN dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - ROUND(A.dblCropInsurance,2) AS NVARCHAR(100))) 
				+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - ROUND(A.dblCropInsurance,2) AS NVARCHAR(100)))))
			ELSE 
				+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(ROUND(A.dblCropInsurance,2) AS NVARCHAR(100)))))
		END
		+ CASE WHEN A.dblParachutePayments > @maxAmount 
			THEN dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - ROUND(A.dblParachutePayments,2) AS NVARCHAR(100))) 
				+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - ROUND(A.dblParachutePayments,2) AS NVARCHAR(100)))))
			ELSE 
				+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(ROUND(A.dblParachutePayments,2) AS NVARCHAR(100)))))
		END
		+ CASE WHEN A.dblGrossProceedsAtty > @maxAmount 
			THEN dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - ROUND(A.dblGrossProceedsAtty,2) AS NVARCHAR(100))) 
				+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - ROUND(A.dblGrossProceedsAtty,2) AS NVARCHAR(100)))))
			ELSE 
				+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(ROUND(A.dblGrossProceedsAtty,2) AS NVARCHAR(100)))))
		END
		+ CASE WHEN A.dblGrossProceedsAtty > @maxAmount 
			THEN dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - ROUND(A.dblGrossProceedsAtty,2) AS NVARCHAR(100))) 
				+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(@maxAmount - ROUND(A.dblGrossProceedsAtty,2) AS NVARCHAR(100)))))
			ELSE 
				+ REPLICATE('0',12 - LEN(dbo.fnAPRemoveSpecialChars(CAST(ROUND(A.dblGrossProceedsAtty,2) AS NVARCHAR(100)))))
		END
		+ REPLICATE('0',12)
		+ REPLICATE('0',12)
		+ REPLICATE('0',12)
		+ REPLICATE('0',12) -- 235-246
		+ ' '
		+ A.strPayeeName + SPACE(40 - LEN(A.strPayeeName))
		+ SPACE(40) -- 288-327
		+ ' '
		+ ISNULL(A.strAddress,'') + SPACE(40 - LEN(ISNULL(A.strAddress,'')))
		+ SPACE(40)
		+ ISNULL(A.strCity,'') + SPACE(40 - LEN(ISNULL(A.strCity,'')))
		+ ISNULL(A.strState,SPACE(2))
		+ REPLACE(ISNULL(A.strZip,''),'-','') + SPACE(9 - LEN(REPLACE(ISNULL(A.strZip,''),'-','')))
		+ ' '
		+ '00000003'
		+ SPACE(36)
	FROM vyuAP1099MISC A
	RETURN;
END
