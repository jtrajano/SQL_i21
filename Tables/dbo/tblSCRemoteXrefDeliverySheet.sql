CREATE TABLE [dbo].[tblSCRemoteXrefDeliverySheet] (
    [intConcurrencyId]   INT           DEFAULT 1 NOT NULL,
    [intRemoteXrefDeliverySheetId] INT           IDENTITY (1, 1) NOT NULL,
    [intMainId]   INT NOT NULL, 
    [intRemoteId] INT NOT NULL, 
    [intRemoteLocationId] INT NOT NULL 
 
);


GO