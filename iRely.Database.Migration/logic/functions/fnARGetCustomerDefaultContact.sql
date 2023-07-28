--liquibase formatted sql

-- changeset Von:fnARGetCustomerDefaultContact.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234


	CREATE OR ALTER FUNCTION [dbo].[fnARGetCustomerDefaultContact]
	(
		@EntityCustomerId    INT
	)
	RETURNS INT
	AS
	BEGIN
		RETURN    (                
					SELECT TOP 1    
						D.intEntityId                                
					FROM dbo.tblEMEntity AS B             
						INNER JOIN dbo.[tblEMEntityToContact] AS C 
								ON B.[intEntityId] = C.[intEntityId] 
						INNER JOIN dbo.tblEMEntity AS D 
								ON C.[intEntityContactId] = D.[intEntityId] 
						INNER JOIN tblARCustomer F
							ON F.intEntityId = B.intEntityId
					WHERE
						B.intEntityId = @EntityCustomerId
						AND C.ysnDefaultContact = 1
				)
   
	END



