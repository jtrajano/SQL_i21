CREATE TABLE [dbo].[tblWHPickForShipment]
(
	 [id] [int] IDENTITY(1,1) NOT NULL,
	 [strShipmentNo] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	 [intLotId] [int] NULL,
	 [ysnManifestAdded] [bit] NULL
)
