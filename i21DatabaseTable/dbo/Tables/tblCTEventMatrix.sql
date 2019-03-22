CREATE TABLE [dbo].[tblCTEventMatrix]
(
	intEventMatrixId [int] IDENTITY(1,1) NOT NULL,
	strLoadingPointType [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[intLoadingPointId] INT NULL,	
	strDestinationPointType	 [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[intDestinationPointId] INT NULL,
	intConcurrencyId INT NOT NULL, 
	CONSTRAINT [PK_tblCTEventMatrix_intEventMatrixId] PRIMARY KEY CLUSTERED ([intEventMatrixId] ASC),
	CONSTRAINT [UK_tblCTEventMatrix_LoadingDestinationPointTypeAndId] UNIQUE (strLoadingPointType,[intLoadingPointId],strDestinationPointType,[intDestinationPointId]),
	CONSTRAINT [FK_tblCTEventMatrix_tblSMCity_intLoadingPointId_intCityId] FOREIGN KEY ([intLoadingPointId]) REFERENCES [tblSMCity]([intCityId]),
	CONSTRAINT [FK_tblCTEventMatrix_tblSMCity_intDestinationPointId_intCityId] FOREIGN KEY ([intDestinationPointId]) REFERENCES [tblSMCity]([intCityId])
)
