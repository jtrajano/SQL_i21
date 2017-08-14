CREATE PROCEDURE [dbo].[uspARInvoiceProductRecapReport]
	@strCustomerName NVARCHAR(100),
	@strInvoiceNumber NVARCHAR(100)
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

SELECT 
	ARI.intInvoiceId, 
	ARI.strInvoiceNumber,
	ARI.strType,
	ARI.intEntityCustomerId, 
	ARI.intEntityId,
	ARC.strName,
	ARI.intCompanyLocationId,
	ARID.intInvoiceDetailId,
	ARID.intItemId,
	ARID.strItemDescription,
	ARID.intItemUOMId,
	ARID.intStorageLocationId,
	ARID.intCompanyLocationSubLocationId,
	ARID.dblQtyOrdered,
	ARID.dblQtyShipped,
	ARID.dblPrice,
	ARID.dblTotal	
FROM 
	tblARInvoice ARI
INNER JOIN 
	(SELECT 
		intInvoiceId,
		intInvoiceDetailId,
		intItemId,
		strItemDescription,
		dblQtyOrdered,
		dblQtyShipped,
		intItemUOMId,
		intStorageLocationId,
		intCompanyLocationSubLocationId,
		dblPrice,
		dblTotal
	FROM 
		tblARInvoiceDetail) ARID ON ARI.intInvoiceId = ARID.intInvoiceId
 INNER JOIN 
	(SELECT 
		ARC.intEntityId,
		strName
	FROM
		tblARCustomer ARC
	INNER JOIN 
		(SELECT 
			intEntityId,
			strName
		 FROM 
			tblEMEntity) EME ON ARC.intEntityId = EME.intEntityId) ARC ON ARI.intEntityCustomerId = ARC.intEntityId
 WHERE 
 	(@strCustomerName IS NULL OR ARC.strName LIKE '%'+@strCustomerName+'%')
	AND (@strInvoiceNumber IS NULL OR ARI.strInvoiceNumber LIKE '%'+@strInvoiceNumber+'%')


 