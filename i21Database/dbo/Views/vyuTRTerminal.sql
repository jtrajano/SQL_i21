
CREATE VIEW [dbo].[vyuTRTerminal]
WITH SCHEMABINDING
	AS 
SELECT 
   
	A.intEntityVendorId,	
     case when A.strVendorId is null then C.strEntityNo 	   	
	     when A.strVendorId = '          ' then C.strEntityNo
	     when A.strVendorId is not null then A.strVendorId 
		 end strVendorId,
	C.strName 

FROM
    
	 dbo.tblAPVendor A
	INNER JOIN dbo.tblEntity C
		ON A.intEntityVendorId = C.intEntityId and A.ysnTransportTerminal = 1
		
	
	

