IF EXISTS (select top 1 1 from sys.procedures where name = 'uspARUpdateTaxGroup')
	DROP PROCEDURE uspARUpdateTaxGroup
GO

CREATE PROCEDURE [dbo].[uspARUpdateTaxGroup]
AS
BEGIN

	SET NOCOUNT ON;

	UPDATE ELOC 
		SET ELOC.intTaxGroupId = TGP.intTaxGroupId FROM tblEMEntityLocation ELOC
			INNER JOIN tblARCustomer CUS ON ELOC.intEntityId = CUS.intEntityId
			INNER JOIN tblSMTaxGroup TGP ON TGP.strTaxGroup = ELOC.strState
END
			
GO