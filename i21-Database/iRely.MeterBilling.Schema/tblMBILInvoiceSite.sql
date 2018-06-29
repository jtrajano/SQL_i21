CREATE TABLE [dbo].[tblMBILInvoiceSite](
	[intMBILInvoiceSiteId]	INT				IDENTITY(1,1) NOT NULL,
	[intMBILInvoiceId]		INT				NOT NULL,
	[intOrderId]			INT				NOT NULL,
	[strOrderNumber]		NVARCHAR (30) COLLATE Latin1_General_CI_AS NULL,
	[strOrderStatus]		NVARCHAR (40) COLLATE Latin1_General_CI_AS NULL,
	[dtmRequestedDate]		DATETIME		NULL,
	[strCustomerNumber]		NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL,
	[intEntityId]			INT				NULL,
	[intUserId]				INT				NULL,
	[strUser]				NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[intSiteId]				INT				NULL,
	[intSiteNumber]			INT				NULL,
	[strSiteName]			NVARCHAR (400) COLLATE Latin1_General_CI_AS NULL,	
	[intContractSeq]		INT				NULL,
	[intContractDetailId]	INT				NULL,
	[strContractNumber]		NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[intTermId]				INT				NULL,
	[strTermId]				NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL,
	[strComments]			NVARCHAR (400) COLLATE Latin1_General_CI_AS NULL,
	[intDriverId]			INT				NULL,
	[strDriver]				NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL,
	[intRouteId]			INT				NULL,
	[strRouteNumber]		NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL,
	[intStopNumber]			INT				NULL,
	[intTaxStateID]			INT				NULL,
	[intShipToId]			INT				NULL,
	[strLocation]			NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[intLocationId]			INT				NULL,
	[intFreightTermId]		INT				NULL,
	[strSerialNumber]		NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
	[dblTankCapacity]		NUMERIC (18, 6) NULL,
	[intConcurrencyId]		INT				DEFAULT 1 NOT NULL,
	CONSTRAINT [PK_tblMBILInvoiceSite] PRIMARY KEY CLUSTERED ([intMBILInvoiceSiteId] ASC)
)