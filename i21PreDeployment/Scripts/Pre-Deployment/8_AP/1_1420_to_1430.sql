--CHANGING strVendorId to intVendorId
--BACK UP Bill Data
IF COL_LENGTH('tblAPBill','strVendorId') IS NOT NULL
BEGIN
	PRINT('Backing up Vendor Bill Data')
	IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblAPTempBillData]'))
	BEGIN
		DROP TABLE tblAPTempBillData
	END

	CREATE TABLE tblAPTempBillData
	(
		intBillId INT,
		strVendorId NVARCHAR(50) COLLATE Latin1_General_CI_AS
	)
	EXEC('
	INSERT INTO tblAPTempBillData
	SELECT intBillId, strVendorId FROM tblAPBill
	')
	PRINT('END Backing up Vendor Bill Data')
END

--BACK UP Payment Data
IF COL_LENGTH('tblAPPayment','strVendorId') IS NOT NULL
BEGIN
	PRINT('Backing up Vendor Payment Data')
	IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblAPTempPaymentData]'))
	BEGIN
		DROP TABLE tblAPTempPaymentData
	END

	CREATE TABLE tblAPTempPaymentData
	(
		intPaymentId INT,
		strVendorId NVARCHAR(50) COLLATE Latin1_General_CI_AS
	)

	EXEC('
	INSERT INTO tblAPTempPaymentData
	SELECT intPaymentId, strVendorId FROM tblAPPayment
	')
	PRINT('End Backing up Vendor Payment Data')
END

--Fix Terms Data Imported From FortBooks DB, strTerm should be unique
IF EXISTS(SELECT 1 FROM tblSMTerm GROUP BY LOWER(strTerm) HAVING COUNT(*) > 1)
BEGIN

	PRINT 'BEGIN UPDATE tblSMTerm FROM AP Module'
	DECLARE @intTermsId INT,
	@term NVARCHAR(200),
	@hasDuplicate BIT
	
	SELECT * INTO #tmpTermsData FROM tblSMTerm
	WHILE EXISTS(SELECT 1 FROM #tmpTermsData)
	BEGIN

		SELECT @intTermsId = intTermID, @term = strTerm FROM #tmpTermsData

		--Check if the current term has duplicate
		IF EXISTS(SELECT 1 FROM (SELECT LOWER(strTerm) Duplicate FROM tblSMTerm GROUP BY LOWER(strTerm) HAVING COUNT(*) > 1) DuplicateTerms WHERE Duplicate = LOWER(@term))
		BEGIN

			IF NOT EXISTS(SELECT 1 FROM tblSMTerm WHERE LOWER(strTerm) = @term AND intTermID IN (SELECT intTermsId FROM tblAPBill UNION SELECT intTermsId FROM tblEntityLocation))
			BEGIN
				--DELETE TOP 1 ONLY IF ANY OF THE DUPLICATE TERMS IS NOT BEING USED
				DELETE TOP (1) FROM tblSMTerm
				FROM tblSMTerm A
				WHERE LOWER(A.strTerm) = @term

			END
			ELSE
			BEGIN

				--DELETE Duplicate Terms that is not using in Bill or Vendor
				DELETE FROM tblSMTerm
				FROM tblSMTerm A
				WHERE LOWER(A.strTerm) = @term
				AND intTermID NOT IN (
					SELECT intTermsId FROM tblAPBill
					UNION
					SELECT intTermsId FROM tblEntityLocation
				)
			END

		END

		DELETE FROM #tmpTermsData WHERE intTermID = @intTermsId

	END

	--Update the name of strTerm to be unique
	UPDATE tblSMTerm
	SET strTerm = dbo.fnTrim(A.strTerm) + ' - ' + CAST(A.intTermID AS NVARCHAR(20))
	FROM tblSMTerm A
	WHERE LOWER(A.strTerm) IN (
		SELECT LOWER(strTerm) FROM tblSMTerm GROUP BY LOWER(strTerm) HAVING COUNT(*) > 1
	)

	PRINT 'END UPDATE tblSMTerm FROM AP Module'

END