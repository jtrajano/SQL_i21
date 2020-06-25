CREATE VIEW [dbo].[vyuAPVendorSynergy]
AS 

SELECT 
	[Id]				=	A.strVendorId,
	[Description]		=	A.strDescription COLLATE Latin1_General_CI_AS,
	[Contact]			=	A.strContact COLLATE Latin1_General_CI_AS,
	[useShipperWeight] 	=	A.ysnUserShipperWeight,
	[vendorType]		=	A.intVendorType
FROM tblAPVendorStagingSynergy A
INNER JOIN tblAPVendorContactInfoSynergy B
	ON A.intVendorStagingId = B.intVendorStagingId
