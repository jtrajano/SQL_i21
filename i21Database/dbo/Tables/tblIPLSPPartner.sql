CREATE TABLE [dbo].[tblIPLSPPartner]
(
	intPartnerId INT NOT NULL IDENTITY,
	strWarehouseVendorAccNo	NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strPartnerNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	CONSTRAINT [PK_tblIPLSPPartner_intPartnerId] PRIMARY KEY ([intPartnerId]) 
)
