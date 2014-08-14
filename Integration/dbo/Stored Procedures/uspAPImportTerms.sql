GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspAPImportTerms')
	DROP PROCEDURE uspAPImportTerms
GO

IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AP') = 1
BEGIN
	EXEC ('
	CREATE PROCEDURE uspAPImportTerms
		@Total INT OUTPUT
	AS
	BEGIN
	
	--BEGIN TRANSACTION

	DECLARE @increment INT = 0
	DECLARE @tblAPTempTerms TABLE  (
		[intTermID]        INT             IDENTITY (1, 1) NOT NULL,
		[strTerm]          NVARCHAR (100)  COLLATE Latin1_General_CI_AS NOT NULL,
		[strType]          NVARCHAR (100)  COLLATE Latin1_General_CI_AS NOT NULL,
		[dblDiscountEP]    NUMERIC (18, 6) NULL,
		[intBalanceDue]    INT             NULL,
		[intDiscountDay]   INT             NULL,
		[dblAPR]           NUMERIC (18, 6) NULL,
		[strTermCode]      NVARCHAR (100)  NOT NULL,
		[ysnAllowEFT]      BIT             DEFAULT ((1)) NOT NULL,
		[intDayofMonthDue] INT             NULL,
		[intDueNextMonth]  INT             NULL,
		[ysnActive]        BIT             DEFAULT ((1)) NOT NULL,
		[intSort]          INT             NULL
	)

	--Import terms specified in vendor
	INSERT INTO @tblAPTempTerms(
		[strTerm],
		[strType],
		[dblDiscountEP],
		[intBalanceDue],
		[intDiscountDay],
		[dblAPR],
		[strTermCode],
		[ysnAllowEFT],
		[intDayofMonthDue],
		[intDueNextMonth],
		[ysnActive],
		[intSort])
	SELECT
		RTRIM(LTRIM(ISNULL(ssvnd_terms_desc,''''))),
		CASE WHEN ssvnd_terms_type = ''P'' THEN ''Date Driven'' ELSE ''Standard'' END,
		ssvnd_terms_disc_pct,
		ssvnd_terms_due_day,
		ssvnd_terms_disc_day,
		0,
		''None-'' + CAST((ROW_NUMBER() OVER(ORDER BY ssvnd_terms_desc)) AS NVARCHAR(10)),
		1,
		ssvnd_terms_cutoff_day,
		0,
		1,
		0
	FROM ssvndmst
	--Insert vendor terms when all setup does not equal to 0
	WHERE 1 = CASE WHEN ISNULL(ssvnd_terms_disc_pct, 0) = 0 
					AND ISNULL(ssvnd_terms_due_day, 0) = 0
					AND ISNULL(ssvnd_terms_disc_day, 0) = 0
					AND ISNULL(ssvnd_terms_cutoff_day, 0) = 0 THEN 0 ELSE 1 END
	
	GROUP BY
		ssvnd_terms_desc,
		ssvnd_terms_type,
		ssvnd_terms_disc_pct,
		ssvnd_terms_due_day,
		ssvnd_terms_disc_day,
		ssvnd_terms_cutoff_day
		
	--SELECT * FROM @tblAPTempTerms
		
	DECLARE @termId INT 
	
	WHILE EXISTS(SELECT 1 FROM @tblAPTempTerms)
	BEGIN

		SET @termId = (SELECT TOP 1 intTermID FROM @tblAPTempTerms)
		
													
		INSERT INTO tblSMTerm(
			[strTerm],
			[strType],
			[dblDiscountEP],
			[intBalanceDue],
			[intDiscountDay],
			[dblAPR],
			[strTermCode],
			[ysnAllowEFT],
			[intDayofMonthDue],
			[intDueNextMonth],
			[ysnActive],
			[intSort])
		SELECT
			CASE WHEN EXISTS(SELECT TOP 1 1 FROM tblSMTerm A
								WHERE A.strTerm = tmpTerms.strTerm)
				THEN tmpTerms.strTerm + '' - '' + CAST((ROW_NUMBER() OVER(ORDER BY intTermID)) AS VARCHAR(10))
				ELSE tmpTerms.strTerm END,
			[strType],
			[dblDiscountEP],
			[intBalanceDue],
			[intDiscountDay],
			[dblAPR],
			CASE WHEN EXISTS(SELECT TOP 1 1 FROM tblSMTerm A
								WHERE A.strTerm = tmpTerms.strTerm)
				THEN tmpTerms.strTerm + '' - '' + CAST((ROW_NUMBER() OVER(ORDER BY intTermID)) AS VARCHAR(10))
				ELSE tmpTerms.strTerm END,
			[ysnAllowEFT],
			[intDayofMonthDue],
			[intDueNextMonth],
			[ysnActive],
			[intSort]
		FROM @tblAPTempTerms tmpTerms
		WHERE 
		intTermID = @termId
		AND
		--Insert if not yet exists on tblSMTerm based on type
			1 = CASE WHEN [strType] = ''Standard'' 
								AND NOT EXISTS(	SELECT TOP 1 1 FROM tblSMTerm A 
												INNER JOIN @tblAPTempTerms B
												ON A.dblDiscountEP = B.[dblDiscountEP]
													AND A.intBalanceDue = B.[intBalanceDue]
													AND A.intDiscountDay = B.[intDiscountDay]
													AND A.strType = ''Standard''
													AND B.intTermID = @termId)
					THEN 1
					WHEN [strType] = ''Date Driven''
							AND NOT EXISTS(SELECT TOP 1 1 FROM tblSMTerm A 
									WHERE A.intDayofMonthDue = [dblDiscountEP]
										AND A.intBalanceDue = [intBalanceDue]
										AND A.intDiscountDay = [intDiscountDay]
										AND A.intDayofMonthDue = [intDayofMonthDue]
										AND A.strType = ''Date Driven'')
					THEN 1
					ELSE 0 END
			
					
		DELETE FROM @tblAPTempTerms
		WHERE intTermID = @termId
	
	END
	
	
	--Insert Due on Receipt if not yet exists
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMTerm WHERE strTerm = ''Due on Receipt'')
	BEGIN
		INSERT INTO tblSMTerm(
			[strTerm],
			[strType],
			[dblDiscountEP],
			[intBalanceDue],
			[intDiscountDay],
			[dblAPR],
			[strTermCode],
			[ysnAllowEFT],
			[intDayofMonthDue],
			[intDueNextMonth],
			[ysnActive],
			[intSort])
		SELECT ''Due on Receipt'', --Add default term
			''Standard'',
			0,
			0,
			0,
			0,
			''None'',
			1,
			0,
			0,
			1,
			0	
	END
	
	INSERT INTO tblAPTermsImported 
	SELECT intTermID FROM tblSMTerm A
	LEFT JOIN tblAPTermsImported B ON A.intTermID = B.Id AND B.Id IS NULL

	--SELECT * FROM tblSMTerm
	--ROLLBACK TRANSACTION 
	
	SET @Total = (SELECT COUNT(*) FROM @tblAPTempTerms)
			
	END
	')
END