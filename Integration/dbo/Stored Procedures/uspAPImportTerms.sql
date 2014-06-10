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

	DECLARE @tblAPTempTerms TABLE  (intTermID INT)

	--Import terms specified in vendor
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
		OUTPUT INSERTED.intTermID INTO @tblAPTempTerms
	SELECT
		ISNULL(ssvnd_terms_desc,''''),
		CASE WHEN ssvnd_terms_type = ''P'' THEN ''Date Driven'' ELSE ''Standard'' END,
		ssvnd_terms_disc_pct,
		ssvnd_terms_due_day,
		ssvnd_terms_disc_day,
		0,
		''None'',
		1,
		ssvnd_terms_cutoff_day,
		0,
		1,
		0
	FROM ssvndmst

	WHERE 1 = CASE WHEN ssvnd_terms_disc_pct = 0 
		AND ssvnd_terms_due_day = 0
		AND ssvnd_terms_disc_day = 0
		AND ssvnd_terms_cutoff_day = 0 THEN 0 ELSE 1 END
		
		AND ((ssvnd_terms_type = ''D'' 
			AND NOT EXISTS(SELECT 1 FROM tblSMTerm A 
						WHERE A.dblDiscountEP = ssvnd_terms_disc_pct
							AND A.intBalanceDue = ssvnd_terms_due_day
							AND A.intDiscountDay = ssvnd_terms_disc_day))
			OR ssvnd_terms_type = ''P''
				AND NOT EXISTS(SELECT 1 FROM tblSMTerm A 
						WHERE A.intDayofMonthDue = ssvnd_terms_disc_pct
							AND A.intBalanceDue = ssvnd_terms_due_day
							AND A.intDiscountDay = ssvnd_terms_disc_day
							AND A.intDayofMonthDue = ssvnd_terms_cutoff_day))

	GROUP BY ssvnd_terms_desc,
			ssvnd_terms_type,
			ssvnd_terms_disc_pct,
			ssvnd_terms_due_day,
			ssvnd_terms_disc_day,
			ssvnd_terms_cutoff_day
	UNION
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

	SELECT * INTO tblAPTempTerms FROM tblSMTerm WHERE intTermID in (SELECT intTermID FROM @tblAPTempTerms)

	SET @Total = (SELECT COUNT(*) FROM tblAPTempTerms)
			
	END
	')
END