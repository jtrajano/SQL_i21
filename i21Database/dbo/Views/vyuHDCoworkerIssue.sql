CREATE VIEW [dbo].[vyuHDCoworkerIssue]
AS 
SELECT intCoworkerIssueId = CI.intCoworkerIssueId,
           intUserId = CI.intUserId,
           intTimeEntryPeriodDetailId = CI.intTimeEntryPeriodDetailId,
           intEntityId = CI.intEntityId,
           strAgentName = CI.strAgentName,
           dblHours = CONVERT(DECIMAL(18, 2), TimeEntry.dblTotalHours),
           strRemarks = CASE
                            WHEN TimeEntry.dblTotalHours >= 1 AND TimeEntry.dblTotalHours < TimeEntry.intRequiredHours 
							THEN CONCAT('Insufficient Time Entry. ',CONVERT(DECIMAL (18,2), TimeEntry.intRequiredHours - TimeEntry.dblTotalHours), ' hours short. ', 
							ApproverSingle.Remarks)
                            WHEN TimeEntry.dblTotalHours <= 0 OR TimeEntry.dblTotalHours IS NULL THEN 'No Time Entry'
                            ELSE 
								CASE WHEN ApproverSingle.intApproverId IS NULL AND ApproverGroupInfo.intApproverGroupId IS NOT NULL 
								THEN ApproverGroupInfo.strStatus ---Remarks if the Approver is within the ApproverGroup.
								WHEN ApproverSingle.intApproverId IS NOT NULL AND ApproverGroupInfo.intApproverGroupId IS NULL 
								THEN ApproverSingle.Remarks ---Remarks if the Approver is within the single approver.
								WHEN ApproverSingle.intApproverId IS NULL AND ApproverGroupInfo.intApproverGroupId IS NULL 
								THEN 'Waiting for Submit' ---Remarks if the Approver if there is no approver yet.
								ELSE ApproverSingle.Remarks ---Remarks if the Approver has approved the time entry (if necessary).
								END
                        END,
			ysnActive = CI.ysnActive,
			strCountry = WorkersComp.strCountry,
			strApprover = CASE WHEN ApproverSingle.intApproverId IS NULL AND ApproverGroupInfo.intApproverGroupId IS NULL
							THEN NULL
							WHEN ApproverSingle.intApproverId IS NULL AND ApproverGroupInfo.intApproverGroupId IS NOT NULL
							THEN ApproverGroupInfo.Approver
							ELSE ApproverSingle.Approver
							END,
           intConcurrencyId = CI.intConcurrencyId
		 
		FROM tblHDCoworkerIssue CI
    OUTER APPLY (
        SELECT TOP 1 EMP.intEntityId, EMP.intWorkersCompensationId, PC.strWCCode as strCountry
        FROM [dbo].[tblPREmployee] EMP
        JOIN tblPRWorkersCompensation PC ON EMP.intEntityId = CI.intEntityId AND PC.intWorkersCompensationId = EMP.intWorkersCompensationId
    ) WorkersComp

	OUTER APPLY (
	SELECT TOP 1 AgentDetail.strFullName as Approver, AP.intApproverId, AP.intApproverGroupId,
	AP.strStatus as Remarks
		FROM tblSMApproval AP
		JOIN vyuHDAgentDetail AgentDetail 
		ON AgentDetail.intId = AP.intApproverId
		JOIN tblSMTransaction TR
		ON TR.intTransactionId = AP.intTransactionId AND CI.intEntityId = TR.intEntityId
		JOIN tblHDTimeEntryPeriodDetail TE
		ON TR.dtmDate = TE.dtmBillingPeriodEnd
		JOIN tblSMScreen SC
		ON AP.intScreenId = SC.intScreenId
		WHERE SC.strScreenName = 'Time Entry' AND
			TE.intTimeEntryPeriodDetailId = CI.intTimeEntryPeriodDetailId AND 
			AP.ysnCurrent = 1
	) ApproverSingle

	OUTER APPLY (
		SELECT TOP 1  AP.intApproverGroupId, AP.strStatus,
		STUFF((SELECT ', '+ AgentDetail.strFullName
			FROM tblSMApproval AP
			INNER JOIN tblSMApproverGroupUserSecurity GU
			ON GU.intApproverGroupId = AP.intApproverGroupId
			INNER JOIN vyuHDAgentDetail AgentDetail 
			ON AgentDetail.intId = GU.intEntityUserSecurityId
			INNER JOIN tblSMTransaction TR
			ON TR.intTransactionId = AP.intTransactionId AND CI.intEntityId = TR.intEntityId
			INNER JOIN tblHDTimeEntryPeriodDetail TE
			ON TR.dtmDate = TE.dtmBillingPeriodEnd 
			INNER JOIN tblSMScreen SC
			ON AP.intScreenId = SC.intScreenId
			WHERE SC.strScreenName = 'Time Entry' AND
				TE.intTimeEntryPeriodDetailId = CI.intTimeEntryPeriodDetailId AND 
				AP.ysnCurrent = 1
			FOR XML PATH('')), 1,1,'') AS Approver --- CONCATINATED Approver names within a group separated with ','.
		FROM tblSMApproval AP
		INNER JOIN tblSMApproverGroupUserSecurity GU
		ON GU.intApproverGroupId = AP.intApproverGroupId
		INNER JOIN vyuHDAgentDetail AgentDetail 
		ON AgentDetail.intId = GU.intEntityUserSecurityId
		INNER JOIN tblSMTransaction TR
		ON TR.intTransactionId = AP.intTransactionId AND CI.intEntityId = TR.intEntityId
		INNER JOIN tblHDTimeEntryPeriodDetail TE
		ON TR.dtmDate = TE.dtmBillingPeriodEnd 
		INNER JOIN tblSMScreen SC
			ON AP.intScreenId = SC.intScreenId
			WHERE SC.strScreenName = 'Time Entry' AND
			TE.intTimeEntryPeriodDetailId = CI.intTimeEntryPeriodDetailId AND 
			AP.ysnCurrent = 1
	)AS ApproverGroupInfo

    OUTER APPLY (
        SELECT TOP 1 intAgentTimeEntryPeriodDetailSummaryId, intEntityId, intTimeEntryPeriodDetailId, dblTotalHours, intRequiredHours
        FROM tblHDAgentTimeEntryPeriodDetailSummary AgentTimeEntry
        WHERE AgentTimeEntry.intEntityId = CI.intEntityId AND AgentTimeEntry.intTimeEntryPeriodDetailId = CI.intTimeEntryPeriodDetailId
    ) TimeEntry
GO