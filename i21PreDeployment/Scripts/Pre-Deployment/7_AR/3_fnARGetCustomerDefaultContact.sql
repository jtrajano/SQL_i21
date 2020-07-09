print('/*******************  BEGIN Fix amounts for tblARInvoice.intEntityContactId *******************/')
GO

IF(EXISTS(SELECT NULL FROM sys.objects WHERE name = N'fnARGetCustomerDefaultContact'))
BEGIN
    DROP FUNCTION [dbo].[fnARGetCustomerDefaultContact]
END
GO

IF(EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblEMEntity') 
			AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intEntityId' AND [object_id] = OBJECT_ID(N'tblEMEntity'))
			AND EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblEMEntityToContact') 
			AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intEntityContactId' AND [object_id] = OBJECT_ID(N'tblEMEntityToContact'))
			AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'ysnDefaultContact' AND [object_id] = OBJECT_ID(N'tblEMEntityToContact'))
			AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intEntityId' AND [object_id] = OBJECT_ID(N'tblEMEntityToContact'))
			AND EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblARCustomer') 
			AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intEntityId' AND [object_id] = OBJECT_ID(N'tblARCustomer')))
BEGIN
	EXEC('
	CREATE FUNCTION [dbo].[fnARGetCustomerDefaultContact]
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
   
	END')

	IF(EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblARInvoice') 
		AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intEntityContactId' AND [object_id] = OBJECT_ID(N'tblARInvoice'))
		AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intEntityCustomerId' AND [object_id] = OBJECT_ID(N'tblARInvoice'))
		AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intInvoiceId' AND [object_id] = OBJECT_ID(N'tblARInvoice'))
		AND EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblEMEntity') 
		AND EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intEntityId' AND [object_id] = OBJECT_ID(N'tblEMEntity'))
	)
	BEGIN
		EXEC('		
		UPDATE tblARInvoice SET intEntityContactId = NULL
		FROM 
			tblARInvoice 
		INNER JOIN 
			(SELECT intEntityContactId, intInvoiceId 
			 FROM 
				tblARInvoice 
			 WHERE intEntityContactId NOT IN 
								(SELECT intEntityId FROM tblEMEntity) AND intEntityContactId IS NOT NULL) ABC ON tblARInvoice.intEntityContactId = ABC.intEntityContactId AND tblARInvoice.intInvoiceId = ABC.intInvoiceId
		WHERE tblARInvoice.intEntityContactId NOT IN (SELECT intEntityId FROM tblEMEntity) AND tblARInvoice.intEntityContactId IS NOT NULL AND tblARInvoice.intInvoiceId = ABC.intInvoiceId
		
		UPDATE tblARInvoice   
		SET intEntityContactId = dbo.fnARGetCustomerDefaultContact(intEntityCustomerId)
		WHERE ISNULL(intEntityContactId, 0) = 0')
	END

END


GO
print('/*******************  END Fix amounts for tblARInvoice.intEntityContactId  *******************/')