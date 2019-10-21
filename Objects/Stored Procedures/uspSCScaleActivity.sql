CREATE PROCEDURE [dbo].[uspSCScaleActivity]
	
	@Date DATETIME=NULL
 
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
,ISNULL(CONVERT(NVARCHAR,T.dtmTicketDateTime,101),'') AS dtmTicketDateTime
,ISNULL(CONVERT(NVARCHAR,T.dtmTicketTransferDateTime,101),'') AS dtmTicketTransferDateTime
,ISNULL(CONVERT(NVARCHAR,T.dtmTicketVoidDateTime,101),'') AS dtmTicketVoidDateTime
,ARC.strCustomerNumber
,en.strName AS CustomerName
,ISNULL(TI.strItemNo,'') AS strItemNo
,ISNULL(TI.strDescription,'') AS strItemDescription
,T.strTruckName
,T.strDriverName
,T.dblGrossWeight AS dblGrossWeight
,T.dblTareWeight AS dblTareWeight
,T.dblGrossUnits As dblGrossUnits
,T.dblNetUnits As dblNetUnit
FROM tblSCTicket T
JOIN tblSCTicketType TT ON (SELECT intTicketTypeId FROM tblSCListTicketTypes WHERE intTicketTypeId = TT.intListTicketTypeId) =T.intTicketType
LEFT JOIN tblSMCompanyLocation Loc ON Loc.intCompanyLocationId=T.intProcessingLocationId
LEFT JOIN tblARCustomer ARC ON ARC.[intEntityId]=T.intCustomerId
LEFT JOIN tblEMEntity en ON en.intEntityId=ARC.[intEntityId]
LEFT JOIN tblICItem TI ON TI.intItemId=T.intItemId
WHERE 
CONVERT(NVARCHAR,T.dtmTicketDateTime,101)
= 
CASE 
	WHEN @Date IS NOT NULL THEN 
		CONVERT(NVARCHAR,@Date,101) 
	ELSE 
		CONVERT(NVARCHAR,GETDATE(),101) 
END

--ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18

END TRY

BEGIN CATCH

 SET @ErrMsg = ERROR_MESSAGE()
 SET @ErrMsg = 'uspSCScaleActivity: ' + @ErrMsg
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')

END CATCH
