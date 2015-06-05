
CREATE VIEW [dbo].[vyuTRTerminal]
WITH SCHEMABINDING
	AS 
SELECT 
   
	A.intEntityVendorId,	
	A.strVendorId,	
	C.strName 

FROM
    
	 dbo.tblAPVendor A
	INNER JOIN dbo.tblEntity C
		ON A.intEntityVendorId = C.intEntityId and A.ysnTransportTerminal = 1
		
	
	

