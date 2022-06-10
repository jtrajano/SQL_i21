CREATE PROCEDURE [dbo].[uspHDUpdateTimeEntryPeriodDetailStatus]
	@strSessionId		NVARCHAR(50) 	= NULL
AS
BEGIN
	UPDATE TimeEntryPeriodDetailToUpdate
	SET TimeEntryPeriodDetailToUpdate.strBillingPeriodStatus = 'Closed'
	FROM tblARPostInvoiceHeader PID
	INNER JOIN tblHDTicketHoursWorked HDTHW WITH (NOLOCK) ON PID.[intInvoiceId] = HDTHW.[intInvoiceId]
	OUTER APPLY(
				SELECT TOP 1 intTimeEntryPeriodDetailId
				FROM tblHDTimeEntryPeriodDetail
				WHERE CONVERT(DATE, dtmBillingPeriodStart) <= CONVERT(DATE, HDTHW.dtmDate) AND
					  CONVERT(DATE, dtmBillingPeriodEnd) >= CONVERT(DATE, HDTHW.dtmDate) 
	) TimeEntryPeriodDetail
	OUTER APPLY (
			SELECT TOP 1 intTicketHoursWorkedId
			FROM vyuARBillableHoursForImport
			WHERE intTimeEntryPeriodDetailId = TimeEntryPeriodDetail.intTimeEntryPeriodDetailId AND
				  ysnLegacyWeek = 0 AND
				  strApprovalStatus = 'Approved'
	) BillableTimeEntry
	INNER JOIN tblHDTimeEntryPeriodDetail TimeEntryPeriodDetailToUpdate on TimeEntryPeriodDetailToUpdate.intTimeEntryPeriodDetailId = TimeEntryPeriodDetail.intTimeEntryPeriodDetailId
	WHERE PID.strSessionId = @strSessionId AND
		  TimeEntryPeriodDetail.intTimeEntryPeriodDetailId IS NOT NULL AND
		  BillableTimeEntry.intTicketHoursWorkedId IS NULL --no remaining billable time entry for that billing period
	END
GO