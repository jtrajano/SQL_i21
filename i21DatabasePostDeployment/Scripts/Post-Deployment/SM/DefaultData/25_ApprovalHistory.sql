GO
print('/*******************  START UPDATING APPROVAL HISTORY  *******************/')

IF OBJECT_ID('tempdb..#TempApprovalHistory') IS NOT NULL
    DROP TABLE #TempApprovalHistory

Create TABLE #TempApprovalHistory
(
	[intApprovalHistoryId]			INT				NOT NULL PRIMARY KEY IDENTITY,
	[intApprovalId]					[int]			NOT NULL,
	[intEntityId]					[int]			NOT NULL,
	[ysnRejected]					[bit]			NULL DEFAULT(0),
	[ysnClosed]						[bit]			NULL DEFAULT(0),
	[ysnApproved]					[bit]			NULL DEFAULT(0),
	[ysnRead]						[bit]			NULL DEFAULT(0),
	[intConcurrencyId]				[int]			NOT NULL DEFAULT ((1)), 
)

--APPROVED APPROVER ENTRIES
INSERT INTO #TempApprovalHistory(intApprovalId, intEntityId, ysnApproved)
SELECT intApprovalId, intApproverId, 1
FROM tblSMApproval 
WHERE intTransactionId IN (
    SELECT intTransactionId 
    FROM tblSMTransaction 
    WHERE strApprovalStatus = 'Approved'
) 
and ysnCurrent = 1  and strStatus = 'Approved' 

--APPROVED SUBMITTER ENTRIES
INSERT INTO #TempApprovalHistory(intApprovalId, intEntityId, ysnApproved)
SELECT intApprovalId, intSubmittedById, 1
FROM tblSMApproval 
WHERE intTransactionId IN (
    SELECT intTransactionId 
    FROM tblSMTransaction 
    WHERE strApprovalStatus = 'Approved'
) 
and ysnCurrent = 1  and strStatus = 'Approved' 

--ALL POSSIBLE USERS
DECLARE users_cursor CURSOR FOR
SELECT intEntityId FROM tblEMEntityCredential

--APPEND REJECTED AND CLOSED TO ALL POSSIBLE USERS
DECLARE @userId INT;
OPEN users_cursor
FETCH NEXT FROM users_cursor into @userId;
WHILE @@FETCH_STATUS = 0
BEGIN
	--REJECTED TRANSACTIONS
	INSERT INTO #TempApprovalHistory(intApprovalId, intEntityId, ysnRejected)
	SELECT intApprovalId, @userId, 1
	FROM tblSMApproval
	WHERE    ysnCurrent = 1 AND strStatus = 'Rejected'

	--CLOSED REJECTED TRANSACTIONS
	INSERT INTO #TempApprovalHistory(intApprovalId, intEntityId, ysnClosed)
	SELECT intApprovalId, @userId, 1
    FROM tblSMApproval 
    WHERE intTransactionId IN (
            SELECT intTransactionId 
            FROM tblSMTransaction 
            WHERE strApprovalStatus = 'Closed'
        ) 
        AND ysnCurrent = 1 
        AND strStatus = 'Closed'

FETCH NEXT FROM users_cursor INTO @userId;
END
CLOSE users_cursor
DEALLOCATE users_cursor



DECLARE @intApprovalId int;
DECLARE @intEntityId int;
DECLARE @ysnRead bit;
DECLARE @ysnApproved bit;
DECLARE @ysnRejected bit;
DECLARE @ysnClosed bit;

DECLARE db_cursor CURSOR FOR  
SELECT intApprovalId, intEntityId, ysnRead, ysnApproved, ysnRejected, ysnClosed FROM #TempApprovalHistory;
 

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @intApprovalId, @intEntityId, @ysnRead, @ysnApproved, @ysnRejected, @ysnClosed;
WHILE @@FETCH_STATUS = 0   
BEGIN
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM [dbo].[tblSMApprovalHistory] WHERE intApprovalId = @intApprovalId and 
																		intEntityId = @intEntityId and
																		ysnApproved = @ysnApproved and
																		ysnRejected = @ysnRejected and
																		ysnClosed = @ysnClosed)
		BEGIN
			INSERT INTO [dbo].[tblSMApprovalHistory] ([intApprovalId], [intEntityId], [ysnRead], [ysnApproved], [ysnRejected], [ysnClosed])
			VALUES (@intApprovalId, @intEntityId, @ysnRead, @ysnApproved, @ysnRejected, @ysnClosed);
		END	  

FETCH NEXT FROM db_cursor INTO @intApprovalId, @intEntityId, @ysnRead, @ysnApproved, @ysnRejected, @ysnClosed;
END   

CLOSE db_cursor   
DEALLOCATE db_cursor


print('/*******************  END UPDATING APPROVAL HISTORY  *******************/')