CREATE VIEW [dbo].[vyuHDCustomerCompany]
AS
	SELECT  intCustomerProductVersionId	 = CONVERT(INT,ROW_NUMBER() OVER ( ORDER BY CustomerProductVersion.strCompany ))
		   ,strCompany					 = CustomerProductVersion.strCompany
		   ,intCustomerId				 = CustomerProductVersion.intCustomerId
		   ,strName						 = CustomerProductVersion.strName
	FROM tblARCustomerProductVersion CustomerProductVersion
	GROUP BY CustomerProductVersion.intCustomerId
			,CustomerProductVersion.strCompany
			,CustomerProductVersion.strName
GO