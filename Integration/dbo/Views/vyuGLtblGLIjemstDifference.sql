GO

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuGLtblGLIjemstDifference')
	DROP VIEW vyuGLtblGLIjemstDifference
GO

IF  (SELECT TOP 1 ysnLegacyIntegration FROM tblSMCompanyPreference WHERE ysnLegacyIntegration = 1) = 1

BEGIN

EXEC (
    '
    CREATE VIEW [dbo].[vyuGLtblGLIjemstDifference] AS
     SELECT *
     FROM( 
           SELECT B.strJournalId,
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
                                    WHEN glije_dr_cr_ind = ''D''
                                    THEN glije_units
                                    ELSE 0
                                END) AS DebitUnit,
                            SUM(CASE
                                    WHEN glije_dr_cr_ind = ''C''
                                    THEN glije_units
                                    ELSE 0
                                END) AS CreditUnit,
                            SUM(CASE
                                    WHEN glije_dr_cr_ind = ''D''
                                    THEN glije_amt
                                    ELSE 0
                                END) AS Debit,
                            SUM(CASE
                                    WHEN glije_dr_cr_ind = ''C''
                                    THEN glije_amt
                                    ELSE 0
                                END) AS Credit,
                            CONVERT( DATETIME, SUBSTRING(CONVERT(VARCHAR(10), glije_date), 1, 4) + ''/'' + SUBSTRING(CONVERT(VARCHAR(10), glije_date), 5, 2) + ''/'' + SUBSTRING(CONVERT(VARCHAR(10), glije_date), 7, 2)) AS glije_date,
                            A.glije_period,
                            A.glije_src_sys,
                            A.glije_src_no,
                            A.A4GLIdentity,
                            B.stri21Id,
                            B.inti21Id,
                            A.glije_line_no,
                            A.glije_acct_no
                     FROM tblGLIjemst AS A
                          INNER JOIN tblGLCOACrossReference AS B ON A.glije_acct_no = B.strExternalId
                          INNER JOIN glactmst AS C ON C.A4GLIdentity = B.intLegacyReferenceId
                          INNER JOIN tblGLAccount AS D ON D.intAccountId = B.inti21Id
                     GROUP BY glije_date,
                              glije_period,
                              glije_src_sys,
                              glije_src_no,
                              A.A4GLIdentity,
                              B.stri21Id,
                              B.inti21Id,
                              A.glije_line_no,
                              A.glije_acct_no ) AS B ON A.strSourceId = B.glije_src_no COLLATE Latin1_General_CI_AS
     WHERE A.strSourceType = B.glije_src_sys COLLATE Latin1_General_CI_AS
       AND A.intAccountId = B.inti21Id
       AND A.intLineNo = B.glije_line_no
       AND A.strSourceKey = B.A4GLIdentity
       AND ( A.dblDebit <> B.Debit
          OR A.dblCredit <> B.Credit
           ) 
		
	'
				
      )

END