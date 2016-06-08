CREATE FUNCTION [dbo].[fnGLGetPostErrors] (
	@JournalIds JournalIDTableType READONLY,
	@strJournalType NVARCHAR(30) = '',
	@ysnPost BIT
)
RETURNS TABLE 
AS
RETURN (
	SELECT * FROM (
				--REGION @ysnPost = 0
				SELECT DISTINCT A.intJournalId,
				'You cannot Unpost this General Journal. You must Unpost and Delete the Reversing transaction: ' + A.strJournalId + ' first!' AS strMessage
				FROM tblGLJournal A 
				WHERE A.strReverseLink IN (SELECT strJournalId FROM tblGLJournal WHERE intJournalId IN (SELECT intJournalId FROM @JournalIds))AND @ysnPost = 0 
				UNION
				--REGION NO CONDITION
				SELECT DISTINCT A.intJournalId,
					'Unable to find an open accounting period to match the transaction date.' AS strMessage
				FROM tblGLJournal A 
				WHERE A.intJournalId IN (SELECT [intJournalId] FROM @JournalIds) AND ISNULL([dbo].isOpenAccountingDate(A.dtmDate), 0) = 0  
				AND ISNULL(A.strSourceType,'') <> 'AA'
				AND ISNULL(A.strJournalType,'') NOT IN('Origin Journal','Adjusted Origin Journal')
				UNION 
				SELECT DISTINCT A.intJournalId,'Unable to post. Account id:' + B.strAccountId + ' is under the ' + C.strAccountCategory + ' category. Please remove it from the transaction detail.' AS strMessage
					FROM tblGLJournalDetail A JOIN vyuGLAccountDetail B
					ON A.intAccountId = B.intAccountId
					JOIN tblGLJournal J
					ON A.intJournalId = J.intJournalId
					JOIN tblGLAccountCategory C
					ON B.intAccountCategoryId = C.intAccountCategoryId
					WHERE A.intJournalId IN (SELECT [intJournalId] FROM @JournalIds)	
					AND ISNULL(C.strAccountCategory,'') in ('AR Account','Cash Account','AP Account')  AND @strJournalType NOT IN('Origin Journal','Adjusted Origin Journal')
					GROUP BY A.intJournalId	,B.strAccountId,C.strAccountCategory
				--REGION @ysnPost = 1
				UNION
				SELECT DISTINCT A.intJournalId,
					'Unable to find an open accounting period to match the reverse date.' AS strMessage
					FROM tblGLJournal A 
					WHERE 0 = CASE WHEN ISNULL(A.dtmReverseDate, '') = '' THEN 1 ELSE ISNULL([dbo].isOpenAccountingDate(A.dtmReverseDate), 0) END 
					  AND A.intJournalId IN (SELECT [intJournalId] FROM @JournalIds) AND @ysnPost = 1 
				UNION
				SELECT DISTINCT A.intJournalId,
					'This transaction cannot be posted because the posting date is empty.' AS strMessage
					FROM tblGLJournal A 
					WHERE 0 = CASE WHEN ISNULL(A.dtmDate, '') = '' THEN 0 ELSE 1 END 
					AND A.intJournalId IN (SELECT [intJournalId] FROM @JournalIds) AND @ysnPost = 1 
				UNION
				SELECT DISTINCT A.intJournalId,
					'This transaction cannot be posted because the currency is missing.' AS strMessage
					FROM tblGLJournal A 
					WHERE 0 = CASE WHEN ISNULL(A.intCurrencyId, '') = '' THEN 0 ELSE 1 END 
					  AND A.intJournalId IN (SELECT [intJournalId] FROM @JournalIds) AND @ysnPost = 1 
				UNION
				SELECT DISTINCT A.intJournalId,
					'Reverse date must be later than Post Date.' AS strMessage
					FROM tblGLJournal A 
					WHERE 0 = CASE WHEN ISNULL(A.dtmReverseDate, '') = '' THEN 1 ELSE 
							CASE WHEN A.dtmReverseDate <= A.dtmDate THEN 0 ELSE 1 END
						END AND A.intJournalId IN (SELECT [intJournalId] FROM @JournalIds) AND @ysnPost = 1 
				UNION
				SELECT DISTINCT A.intJournalId,
					'You cannot post this transaction because it has inactive account id: ' + B.strAccountId + '.' AS strMessage
				FROM tblGLJournalDetail A JOIN tblGLJournal J ON A.intJournalId = J.intJournalId
					LEFT OUTER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
				WHERE ISNULL(B.ysnActive, 0) = 0 AND A.intJournalId IN (SELECT [intJournalId] FROM @JournalIds) AND @ysnPost = 1 
				AND ISNULL(J.strJournalType,'') NOT IN('Origin Journal','Adjusted Origin Journal', 'Historical Journal')
				UNION
				SELECT DISTINCT A.intJournalId,
					'You cannot post this transaction because it has invalid account(s).' AS strMessage
				FROM tblGLJournalDetail A 
					LEFT OUTER JOIN tblGLAccount B ON A.intAccountId = B.intAccountId
				WHERE (A.intAccountId IS NULL OR 0 = CASE WHEN ISNULL(A.intAccountId, '') = '' THEN 0 ELSE 1 END) AND A.intJournalId IN (SELECT [intJournalId] FROM @JournalIds)								
					AND @ysnPost = 1 
				UNION
					SELECT DISTINCT A.intJournalId,'You cannot post empty transaction.' AS strMessage
					FROM tblGLJournal A 
					LEFT JOIN tblGLJournalDetail B ON A.intJournalId = B.intJournalId
					WHERE A.intJournalId IN (SELECT [intJournalId] FROM @JournalIds) AND @ysnPost = 1 
					GROUP BY A.intJournalId						
					HAVING COUNT(B.intJournalId) < 1				
				UNION 
				SELECT DISTINCT A.intJournalId,'Unable to post. The transaction is out of balance.' AS strMessage
					FROM tblGLJournalDetail A 
					WHERE A.intJournalId IN (SELECT [intJournalId] FROM @JournalIds) AND @ysnPost = 1 
					GROUP BY A.intJournalId		
					HAVING SUM(ISNULL(A.dblCredit,0)) <> SUM(ISNULL(A.dblDebit,0)) 
				) AS query

				
)