MERGE	
	INTO	dbo.tblGLSummary 
	WITH	(HOLDLOCK) 
	AS		gl_summary 
	USING (
				SELECT	intAccountId
						,dtmDate = dbo.fnRemoveTimeOnDate(GLEntries.dtmDate)
						,strCode
						,dblDebit = SUM(CASE WHEN 1 = 1 THEN Debit.Value ELSE Credit.Value * -1 END)
						,dblCredit = SUM(CASE WHEN 1 = 1 THEN Credit.Value ELSE Debit.Value * -1 END)
						,dblDebitUnit = SUM(CASE WHEN 1 = 1 THEN DebitUnit.Value ELSE CreditUnit.Value * -1 END)
						,dblCreditUnit = SUM(CASE WHEN 1 = 1 THEN CreditUnit.Value ELSE DebitUnit.Value * -1 END)						
				FROM	dbo.tblGLDetail GLEntries
						CROSS APPLY dbo.fnGetDebit(ISNULL(GLEntries.dblDebit, 0) - ISNULL(GLEntries.dblCredit, 0)) Debit
						CROSS APPLY dbo.fnGetCredit(ISNULL(GLEntries.dblDebit, 0) - ISNULL(GLEntries.dblCredit, 0))  Credit
						CROSS APPLY dbo.fnGetDebit(ISNULL(GLEntries.dblDebitUnit, 0) - ISNULL(GLEntries.dblCreditUnit, 0)) DebitUnit
						CROSS APPLY dbo.fnGetCredit(ISNULL(GLEntries.dblDebitUnit, 0) - ISNULL(GLEntries.dblCreditUnit, 0))  CreditUnit
				GROUP BY intAccountId, dbo.fnRemoveTimeOnDate(GLEntries.dtmDate), strCode
	) AS Source_Query  
		ON gl_summary.intAccountId = Source_Query.intAccountId
		AND gl_summary.strCode = Source_Query.strCode 
		AND dbo.fnDateEquals(gl_summary.dtmDate, Source_Query.dtmDate) = 1

	-- Update an existing gl summary record
	WHEN MATCHED THEN 
		UPDATE 
		SET		dblDebit = Source_Query.dblDebit 
				,dblCredit = Source_Query.dblCredit 
				,intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1

	-- Insert a new gl summary record 
	WHEN NOT MATCHED  THEN 
		INSERT (
			intAccountId
			,dtmDate
			,dblDebit
			,dblCredit
			,dblDebitUnit
			,dblCreditUnit
			,strCode
			,intConcurrencyId
		)
		VALUES (
			Source_Query.intAccountId
			,Source_Query.dtmDate
			,Source_Query.dblDebit
			,Source_Query.dblCredit
			,Source_Query.dblDebitUnit
			,Source_Query.dblCreditUnit
			,Source_Query.strCode
			,1
		);