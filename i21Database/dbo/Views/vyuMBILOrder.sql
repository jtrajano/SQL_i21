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
 , isnull([LGRouteOrder].strRouteNumber,newDispatch.strDispatchOrderNumber) as strRouteId    
 , isnull([LGRouteOrder].intSequence,newDispatch.intSequence) as intSequence
 , [Order].intStopNumber    
 , [Order].intConcurrencyId    
 , [Order].intShiftId    
 , Shift.intShiftNumber
 , [Order].ysnLockPrice
 , [Order].strRecurringPONumber
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
LEFT JOIN 
 (
  SELECT DO.intDispatchOrderId,DO.strDispatchOrderNumber,intTMDispatchId,DOD.intSequence
  FROM tblLGDispatchOrder DO 
  INNER JOIN  tblLGDispatchOrderDetail DOD on DO.intDispatchOrderId = DOD.intDispatchOrderId
  WHERE DO.intDispatchStatus = 3
 ) newDispatch ON newDispatch.intTMDispatchId = [Order].intDispatchId
LEFT JOIN tblMBILShift Shift ON Shift.intShiftId = [Order].intShiftId