GO
IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'glhstmst') RETURN
IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'glactmst') RETURN

IF  (SELECT TOP 1 ysnLegacyIntegration FROM tblSMCompanyPreference WHERE ysnLegacyIntegration = 1) = 1

BEGIN

EXEC (
    '
      ALTER VIEW [dbo].[vyuGLglhstmstDifference] AS

     select A.strJournalId, A.strAccountId, A.dblDebit, A.dblCredit, A.dblDebitUnit, A.dblCreditUnit, A.strSourceId, A.strSourceType, A.strSourceKey,
	  B.glhst_acct1_8, B.glhst_acct9_16, B.glhst_amt, B.glhst_units, B.glhst_dr_cr_ind, B.Debit, B.Credit, B.DebitUnit, B.CreditUnit, B.glhst_date, B.glhst_period, B.glhst_src_id, B.glhst_src_seq, CAST(B.A4GLIdentity AS int) A4GLIdentity
	  from ( SELECT	   B.strJournalId,
                  A.intLineNo,
                  C.intAccountId,
                  C.strAccountId,
                  A.dblDebitUnit,
                  A.dblCreditUnit,
                  A.dblDebit,
                  A.dblCredit,
                  B.dtmDate,
                  B.strSourceId,
                  B.strSourceType,
                  A.strSourceKey
           FROM tblGLJournalDetail AS A
                INNER JOIN tblGLJournal AS B ON A.intJournalId = B.intJournalId
                INNER JOIN tblGLAccount AS C ON C.intAccountId = A.intAccountId
           WHERE B.strJournalType IN( ''Origin Journal'', ''Adjusted Origin Journal'' )
           GROUP BY B.strJournalId,
                    A.intLineNo,
                    C.intAccountId,
                    C.strAccountId,
                    A.dblDebitUnit,
                    A.dblCreditUnit,
                    A.dblDebit,
                    A.dblCredit,
                    B.dtmDate,
                    B.strSourceId,
                    B.strSourceType,
                    A.strSourceKey ) AS A
         INNER JOIN( 
                                       SELECT SUM(CASE
                                    WHEN glhst_dr_cr_ind = ''D''
                                    THEN glhst_units
                                    ELSE 0
                                END) AS DebitUnit,
                            SUM(CASE
                                    WHEN glhst_dr_cr_ind = ''C''
                                    THEN glhst_units
                                    ELSE 0
                                END) AS CreditUnit,
                            SUM(CASE
                                    WHEN glhst_dr_cr_ind = ''D''  and glhst_amt > 0 OR glhst_dr_cr_ind = ''C'' and glhst_amt <  0 
							 THEN ABS (glhst_amt)
                                    ELSE 0
                                END) AS Debit,
                            SUM(CASE
                                    WHEN glhst_dr_cr_ind = ''C'' and glhst_amt > 0 OR glhst_dr_cr_ind = ''D'' and glhst_amt <  0 or  glhst_dr_cr_ind is NULL
                                    THEN ABS (glhst_amt)
                                    ELSE 0
                                END) AS Credit,
                            A.glhst_date,
							A.glhst_amt,
					   A.glhst_units,
					   A.glhst_dr_cr_ind,
					   A.glhst_period,
                            A.glhst_src_id,
                            A.glhst_src_seq,
                            A.A4GLIdentity,
                            C.stri21Id,
                            C.inti21Id,
                            A.glhst_line_no,
                            glhst_acct1_8,
					   glhst_acct9_16
                     FROM glhstmst AS A
					 INNER JOIN glactmst AS B ON A.glhst_acct1_8 = B.glact_acct1_8
					 AND A.glhst_acct9_16 = B.glact_acct9_16
				      INNER JOIN tblGLCOACrossReference AS C ON C.intLegacyReferenceId = B.A4GLIdentity
                          INNER JOIN tblGLAccount AS D ON D.intAccountId = C.inti21Id
                     GROUP BY A.glhst_dr_cr_ind,
					   A.glhst_amt,
					   A.glhst_units,
					   A.glhst_period,
                            A.glhst_src_id,
                            A.glhst_src_seq,
                            A.A4GLIdentity,
                            C.stri21Id,
                            C.inti21Id,
                            A.glhst_line_no,
                            A.glhst_acct1_8,
					   A.glhst_acct9_16,
					   A.glhst_date) AS B 
						
						ON  A.strSourceKey = B.A4GLIdentity
     WHERE A.strSourceType = B.glhst_src_id COLLATE Latin1_General_CI_AS
     
	'
				
      )
	 
END