CREATE VIEW [dbo].[vyuAPVendorSynergy]
AS 

SELECT 
	[Id]				=	A.strVendorId,
	[Description]		=	A.strDescription,
	[Contact]			=	A.strContact,
	[useShipperWeight] 	=	A.ysnUserShipperWeight,
	[vendorType]		=	A.intVendorType
FROM tblAPVendorStagingSynergy A
INNER JOIN tblAPVendorContactInfoSynergy B
	ON A.intVendorStagingId = B.intVendorStagingId
