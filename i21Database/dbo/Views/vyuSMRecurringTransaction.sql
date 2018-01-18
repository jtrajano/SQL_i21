CREATE VIEW [dbo].[vyuSMRecurringTransaction]

AS

SELECT 
	   rectrans.intRecurringId
	  ,ent.strName
	  ,'' as strAssignedUser
      ,rectrans.intTransactionId
      ,rectrans.strTransactionNumber
      ,rectrans.strTransactionType
      ,rectrans.strReference
      ,rectrans.strResponsibleUser
      ,rectrans.intEntityId
      ,rectrans.intWarningDays
      ,rectrans.strFrequency
      ,rectrans.dtmLastProcess
      ,rectrans.dtmNextProcess
      ,rectrans.ysnDue
      ,rectrans.strRecurringGroup
      ,rectrans.strDayOfMonth
      ,rectrans.dtmStartDate
      ,rectrans.dtmEndDate
      ,rectrans.ysnActive
      ,rectrans.intIteration
      ,rectrans.intUserId
      ,rectrans.ysnAvailable
      ,rectrans.dtmPreviousLastProcess
      ,rectrans.dtmPreviousNextProcess
      ,rectrans.intConcurrencyId
	FROM tblSMRecurringTransaction rectrans
	LEFT JOIN tblARInvoice inv ON rectrans.strTransactionNumber = inv.strInvoiceNumber
	LEFT JOIN tblEMEntity ent ON inv.intEntityCustomerId  = ent.intEntityId