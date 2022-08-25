CREATE VIEW [dbo].[vyuMBILOrder]  
 AS  
   
SELECT [Order].intOrderId  
 , [Order].intDispatchId  
 , [Order].strOrderNumber  
 , [Order].strOrderStatus  
 , [Order].dtmRequestedDate  
 , [Order].intEntityId  
 , strCustomerNumber = Customer.strEntityNo  
 , strCustomerName = Customer.strName  
 , [Order].intTermId  
 , Term.strTerm  
 , [Order].strComments  
 , [Order].intDriverId  
 , Driver.strDriverNo  
 , Driver.strDriverName  
 , [Order].intRouteId  
 , [LGRouteOrder].strRouteNumber as strRouteId  
 , [LGRouteOrder].intSequence  
 , [Order].intStopNumber  
 , [Order].intConcurrencyId  
 , [Order].intShiftId  
 , Shift.intShiftNumber  
FROM tblMBILOrder [Order]  
LEFT JOIN tblEMEntity Customer ON Customer.intEntityId = [Order].intEntityId  
LEFT JOIN tblSMTerm Term ON Term.intTermID = [Order].intTermId  
LEFT JOIN vyuMBILDriver Driver ON Driver.intEntityId = [Order].intDriverId  
LEFT JOIN 
	(SELECT [LGRoute].strRouteNumber,[LGRouteOrder].intSequence,LGRouteOrder.strOrderNumber 
	 FROM tblLGRouteOrder LGRouteOrder 
	 LEFT JOIN tblLGRoute LGRoute ON [LGRoute].intRouteId = [LGRouteOrder].intRouteId 
	 WHERE [LGRoute].ysnPosted = 1
	) [LGRouteOrder] ON  [LGRouteOrder].strOrderNumber = [Order].strOrderNumber
LEFT JOIN tblMBILShift Shift ON Shift.intShiftId = [Order].intShiftId