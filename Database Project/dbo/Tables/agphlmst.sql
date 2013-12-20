CREATE TABLE [dbo].[agphlmst] (
    [agphl_phy_loc_no]   CHAR (3)        NOT NULL,
    [agphl_phy_rec_no]   INT             NOT NULL,
    [agphl_lot_no]       CHAR (16)       NOT NULL,
    [agphl_computed_qty] DECIMAL (13, 4) NULL,
    [agphl_actual_qty]   DECIMAL (13, 4) NULL,
    [A4GLIdentity]       NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agphlmst] PRIMARY KEY NONCLUSTERED ([agphl_phy_loc_no] ASC, [agphl_phy_rec_no] ASC, [agphl_lot_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iagphlmst0]
    ON [dbo].[agphlmst]([agphl_phy_loc_no] ASC, [agphl_phy_rec_no] ASC, [agphl_lot_no] ASC);

