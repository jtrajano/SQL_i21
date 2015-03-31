
CREATE PROCEDURE [dbo].[uspSCUnsentTickets]

AS 

BEGIN TRY

	SET NOCOUNT ON
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	SELECT 
	DISTINCT
	T.intTicketNumber
	,CASE 
		 WHEN T.strTicketStatus='O' THEN 'Open'
		 WHEN T.strTicketStatus='C' THEN 'Closed'
		 WHEN T.strTicketStatus='A' THEN 'Printed'
	 END 
	 AS 
	 strTicketStatus 
	,CASE 
		WHEN TT.intTicketType=1 THEN 'Load'
		WHEN TT.intTicketType=2 THEN 'Transfer'
		WHEN TT.intTicketType=3 THEN 'Memo'
		WHEN TT.intTicketType=4 THEN 'Storage Take out'
	END 
	AS strTicketType
	,CASE 
	   WHEN T.strInOutFlag='I' THEN 'In'
	   WHEN T.strInOutFlag='O' THEN 'Out'
	 END 
	 AS 
	 strInOutFlag  
	,Loc.strLocationName
	,ISNULL(Convert(Nvarchar,T.dtmTicketDateTime,101),'') AS dtmTicketDateTime
	,ARC.strCustomerNumber
	,ISNULL(TI.strItemNo,'') AS strItemNo
	,T.strTruckName
	,T.strDriverName
	,T.dblGrossWeight AS dblGrossWeight
	,T.dblTareWeight AS dblTareWeight
	,T.dblGrossUnits As dblGrossUnits
	,T.dblNetUnits As dblNetUnit
	FROM tblSCTicket T
	JOIN tblSCTicketType TT ON TT.intTicketType=T.intTicketType
	JOIN tblSMCompanyLocation Loc ON Loc.intCompanyLocationId=T.intProcessingLocationId
	JOIN tblARCustomer ARC ON ARC.intCustomerId=T.intCustomerId
	JOIN tblEntity en ON en.intEntityId=ARC.intEntityId
	LEFT JOIN tblICItem TI ON TI.intItemId=T.intItemId
	Where
	T.dtmTicketTransferDateTime IS  NULL AND T.dtmTicketVoidDateTime IS  NULL
	Order by 1,2,3,4,5,6,7,8,9,10,11,12,13,14

END TRY

BEGIN CATCH

	 SET @ErrMsg = ERROR_MESSAGE()
	 SET @ErrMsg = 'Report_ScaleActivity: ' + @ErrMsg
	 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')

END CATCH
