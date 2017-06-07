
CREATE PROCEDURE [dbo].[uspSCUnsentTickets]

AS 

BEGIN TRY

	SET NOCOUNT ON
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	SELECT 
	DISTINCT
	T.strTicketNumber
	,CASE 
		 WHEN T.strTicketStatus='O' THEN 'Open'
		 WHEN T.strTicketStatus='C' THEN 'Closed'
		 WHEN T.strTicketStatus='A' THEN 'Printed'
	 END 
	 AS 
	 strTicketStatus 
	,CASE 
		WHEN TT.intListTicketTypeId=1 THEN 'Load In'
		WHEN TT.intListTicketTypeId=2 THEN 'Load Out'
		WHEN TT.intListTicketTypeId=3 THEN 'Transfer In'
		WHEN TT.intListTicketTypeId=4 THEN 'Transfer Out'
		WHEN TT.intListTicketTypeId=5 THEN 'Memo/Weigh'
		WHEN TT.intListTicketTypeId=6 THEN 'Storage Take Out'
		WHEN TT.intListTicketTypeId=7 THEN 'AG Outbound'
		WHEN TT.intListTicketTypeId=8 THEN 'Direct In'
		WHEN TT.intListTicketTypeId=9 THEN 'Direct Out'
	END 
	AS strTicketType
	--,CASE 
	--   WHEN T.strInOutFlag='I' THEN 'In'
	--   WHEN T.strInOutFlag='O' THEN 'Out'
	-- END 
	-- AS 
	-- strInOutFlag  
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
	JOIN tblSCTicketType TT ON (SELECT intTicketTypeId FROM tblSCListTicketTypes WHERE intTicketTypeId = TT.intListTicketTypeId)=T.intTicketType
	LEFT JOIN tblSMCompanyLocation Loc ON Loc.intCompanyLocationId=T.intProcessingLocationId
	LEFT JOIN tblARCustomer ARC ON ARC.[intEntityId]=T.intCustomerId
	LEFT JOIN tblEMEntity en ON en.intEntityId=ARC.[intEntityId]
	LEFT JOIN tblICItem TI ON TI.intItemId=T.intItemId
	Where
	T.dtmTicketTransferDateTime IS  NULL AND T.dtmTicketVoidDateTime IS  NULL
	--Order by 1,2,3,4,5,6,7,8,9,10,11,12,13,14

END TRY

BEGIN CATCH

	 SET @ErrMsg = ERROR_MESSAGE()
	 SET @ErrMsg = 'uspSCUnsentTickets: ' + @ErrMsg
	 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')

END CATCH
