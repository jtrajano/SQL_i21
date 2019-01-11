CREATE VIEW [dbo].[vyuSMRecurringTransaction]

AS

SELECT 
	   rectrans.intRecurringId
	  ,strName = case when rectrans.strTransactionType = 'Sales Order' then oent.strName else ent.strName end
	  ,'' COLLATE Latin1_General_CI_AS as strAssignedUser
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
	LEFT JOIN tblSOSalesOrder so ON rectrans.strTransactionNumber = so.strSalesOrderNumber
	LEFT JOIN tblEMEntity oent ON so.intEntityCustomerId  = oent.intEntityId
