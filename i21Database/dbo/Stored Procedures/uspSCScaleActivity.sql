CREATE PROCEDURE [dbo].[uspSCScaleActivity]
	
	@Date DATETIME=NULL
 
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
JOIN tblSCTicketType TT ON TT.intTicketType=T.intTicketType
JOIN tblSMCompanyLocation Loc ON Loc.intCompanyLocationId=T.intProcessingLocationId
JOIN tblARCustomer ARC ON ARC.intEntityCustomerId=T.intCustomerId
JOIN tblEntity en ON en.intEntityId=ARC.intEntityCustomerId
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

ORDER BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18

END TRY

BEGIN CATCH

 SET @ErrMsg = ERROR_MESSAGE()
 SET @ErrMsg = 'uspSCScaleActivity: ' + @ErrMsg
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')

END CATCH
